import json
import sqlite3
import redis
import requests
import subprocess
from celery import Celery
from subprocess import run, PIPE
from neo4j import GraphDatabase
# env file
import os
from dotenv import load_dotenv
load_dotenv()
# Load environment variables
NEO4J_URI = os.getenv("NEO4J_URI")
NEO4J_USER = os.getenv("NEO4J_USER")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD")

# Initialize Celery with Redis
celery = Celery("worker", broker="redis://localhost:6379/0", result_backend="redis://localhost:6379/0")

celery.conf.update(
    result_backend="redis://localhost:6379/0"
)

# Connect to Redis
redis_client = redis.Redis(host="localhost", port=6379, db=0)

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

# Celery Task: Run CLI Tool or API
@celery.task
def run_tool(source_name, query):
    sources = load_sources()  # Load sources

    source = next((s for s in sources if s["name"] == source_name), None)
    if not source:
        return {"error": "Source not found"}
    
    if source["type"] == "API":
        result = fetch_api_data(source, query)  # API-based OSINT
    else:
        command = source["command"].format(query=query)
        result = subprocess.run(command, shell=True, stdout=PIPE, stderr=PIPE, text=True)
        if result.returncode == 0:
            output = result.stdout.strip()
            if output:
                try:
                    result = json.loads(output) #if source["output_format"] == "json" else {"raw_output": output}
                except json.JSONDecodeError:
                    result = {"error": "Invalid JSON output", "raw_output": output}
            else:
                result = {"error": "Empty output from command"}
        else:
            result = {"error": result.stderr.strip()}

    save_result(source_name, query, result)  # Save result
    print(result)
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
