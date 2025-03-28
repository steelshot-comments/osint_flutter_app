import json
import sqlite3
import redis
import requests
import subprocess
from celery import Celery
from subprocess import run, PIPE

# Initialize Celery with Redis
celery = Celery("osint_worker", broker="redis://localhost:6379/0")

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
def run_cli_tool(source_name, query):
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
            result = json.loads(output) if source["output_format"] == "json" else {"raw_output": output}
        else:
            result = {"error": result.stderr.strip()}

    save_result(source_name, query, result)  # Save result
    return result

# Initialize database when worker starts
init_db()
