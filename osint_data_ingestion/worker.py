import json
import sqlite3
import requests
import subprocess
from celery import Celery
from subprocess import PIPE
from neo4j import GraphDatabase
import os
from dotenv import load_dotenv
from redis_config import redis_client
import re
import requests

# Load environment variables
load_dotenv()
NEO4J_URI = os.getenv("NEO4J_URI")
NEO4J_USER = os.getenv("NEO4J_USER")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD")

# Initialize Celery with Redis
celery = Celery("worker", broker="redis://localhost:6379/0", result_backend="redis://localhost:6379/0")

celery.conf.update(
    result_backend="redis://localhost:6379/0"
)

def post_to_neo4j(node_id, nodes):
    url = f"http://192.168.0.114:5500/add-record/${node_id}"  # Replace with your actual Neo4j API endpoint

    try:
        response = requests.post(url, json=nodes)
        return response.json()
    except requests.RequestException as e:
        return {"error": str(e)}

# def map_sherlock_result_to_nodes(result):
#     nodes = []
#     for platform, url in result.items():
#         node = {
#             "labels": ["SocialMediaAccount"],
#             "properties": {
#                 "platform": platform,
#                 "url": url
#             }
#         }
#         nodes.append(node)
#     print(nodes)
#     return nodes

# Function to publish transform updates to redis queue
def publish_transform_update(node_id: str, status: str, data: dict = None):
    message = {
        "node_id": node_id,
        "status": status,
        "data": data or {}
    }
    redis_client.publish("transform_updates", json.dumps(message))

# Load OSINT sources from config file
def load_sources(config_file="osint_sources.json"):
    with open(config_file, "r") as f:
        return json.load(f)["sources"]

# Database setup
def init_db():
    conn = sqlite3.connect("osint_data.db")
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS osint_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source TEXT,
            query TEXT,
            result TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    conn.commit()
    conn.close()

# Save result to database
def save_result(source, query, result):
    conn = sqlite3.connect("osint_data.db")
    cursor = conn.cursor()
    cursor.execute("INSERT INTO osint_results (source, query, result) VALUES (?, ?, ?)",
                   (source, query, json.dumps(result)))
    conn.commit()
    conn.close()

# Fetch API data
def fetch_api_data(source, query):
    url = source["url"].format(query=query)
    headers = {"Authorization": f"Bearer {source['api_key']}"} if source.get("key_required") else {}
    
    try:
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            return response.json()
        else:
            return {"error": f"Failed with status {response.status_code}"}
    except Exception as e:
        return {"error": str(e)}

def parse_sherlock_style_output(output):
    nodes = []
    lines = output.splitlines()
    for line in lines:
        match = re.match(r"\[\+\] (.*?): (.+)", line)
        if match:
            site, url = match.groups()
            node = {
                "labels": [site.strip()],
                "properties": {
                    "url": url.strip()
                }
            }
            nodes.append(node)
    
    if nodes:
        return nodes
    
    # Fallback if pattern doesn't match
    return [{
        "labels": ["RawOutput"],
        "properties": {
            "output": output.strip()
        }
    }]


# Celery Task: Run CLI Tool or API
@celery.task
def run_tool(source_name, query, node_id):
    sources = load_sources()  # Load sources from json file

    source = next((s for s in sources if s["name"] == source_name), None)
    if not source:
        return {"error": "Source not found"}
    
    publish_transform_update(node_id, "PENDING", data={"message": "Source found"})
    
    if source["type"] == "API":
        result = fetch_api_data(source, query)
    else:
        command = source["command"].format(query=query) # json has command with {query} placeholder
        result = {}
        try:
            proc = subprocess.run(command, shell=True, stdout=PIPE, stderr=PIPE, text=True)
            if proc.returncode == 0:
                output = proc.stdout.strip()
                publish_transform_update(node_id, "PENDING", data={"message":"Recieved result of command"})
                # Try to parse JSON output
                try:
                    result = json.loads(output)
                except json.JSONDecodeError:
                    result = parse_sherlock_style_output(output)
            else:
                result = {"error": proc.stderr.strip()}
        except Exception as e:
            result = {"error": str(e)}

    publish_transform_update(node_id, "completed", data={"message":"DONEEEE"})

    save_result(source_name, query, result)  # Save result in sqlite database
    post_to_neo4j(node_id,result) # store in neo4j
    return result

def store_scan_results(scan_results):
    """Stores Masscan results in Neo4j."""
    driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))

    with driver.session() as session:
        for result in scan_results:
            ip = result["ip"]
            for port_info in result.get("ports", []):
                port = port_info["port"]
                session.run(
                    """
                    MERGE (h:Host {ip: $ip})
                    MERGE (p:Port {number: $port})
                    MERGE (h)-[:HAS_OPEN_PORT]->(p)
                    """,
                    ip=ip, port=port
                )

    driver.close()

# Initialize database when worker starts
init_db()
