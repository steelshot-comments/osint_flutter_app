from fastapi import FastAPI,WebSocket, WebSocketDisconnect, UploadFile, File, HTTPException
from celery.result import AsyncResult
from worker import run_tool, celery
import sqlite3
import json
import asyncio
import subprocess

active_connections = {}

app = FastAPI()

def fetch_results():
    conn = sqlite3.connect("osint_data.db")
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM osint_results ORDER BY timestamp DESC")
    rows = cursor.fetchall()
    conn.close()

    results = []
    for row in rows:
        print(row)
        results.append({
            "id": row[0],
            "source": row[1],
            "query": row[2],
            "result": json.loads(row[3]),  # Parse stored JSON result
            "timestamp": row[4]
        })
    return results

# Create root endpoint
@app.get("/")
def read_root():
    # explain the routes
    return {
        "message": "Welcome to the OSINT Data Ingestion API!",
        "routes": {
            "/run/{source_name}/{query}": "Run an OSINT task with the specified source and query.",
            "/result/{task_id}": "Get the result of a task by its ID.",
            "/results": "Fetch all results from the database.",
            "/ws/transforms/{node_id}": "WebSocket endpoint for transform updates."
        }
    }

@app.get("/run/{source_name}/{query}")
def run_osint_task(source_name: str, query: str):
    task = run_tool.delay(source_name, query)  # Push task to Celery
    return {"task_id": task.id}

@app.get("/result/{task_id}")
def get_task_result(task_id: str):
    task_result = AsyncResult(task_id, app=celery)
    if task_result.ready():
        return {"status": "SUCCESS", "result": task_result.result}
    return {"status": "pending"}

@app.get("/results")
def get_results():
    return fetch_results()

@app.websocket("/ws/transforms/{node_id}")
async def transform_updates(websocket: WebSocket, node_id: str):
    await websocket.accept()
    active_connections[node_id] = websocket
    try:
        while True:
            await asyncio.sleep(1)
    except WebSocketDisconnect:
        del active_connections[node_id]

# Function to send transform updates
async def send_transform_update(node_id: str, status: str, data:dict=None):
    if node_id in active_connections:
        message = {"status": status, "data": data}
        await active_connections[node_id].send_text(json.dumps(message))

# Example: simulate sending transform updates
async def run_transform(node_id: str):
    await send_transform_update(node_id, "running")
    await asyncio.sleep(3)  # Simulating a delay
    partial_result = {"new_edges": 2, "new_nodes": 1}
    await send_transform_update(node_id, "partial", partial_result)
    
    await asyncio.sleep(3)  # More processing time
    final_result = {"confirmed": True}
    await send_transform_update(node_id, "final", final_result)

    # Close connection after sending the final update
    if node_id in active_connections:
        await active_connections[node_id].close()
        del active_connections[node_id]

# Example: Calling the transform function
@app.post("/start_transform/{node_id}")
async def start_transform(node_id: str):
    asyncio.create_task(run_transform(node_id))
    return {"message": "Transform started"}