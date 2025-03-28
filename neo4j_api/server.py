import os
import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from neo4j import GraphDatabase
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

NEO4J_URI = os.getenv("NEO4J_URI", "bolt://localhost:7687")
NEO4J_USER = os.getenv("NEO4J_USER")
NEO4J_PASS = os.getenv("NEO4J_PASS")
NEO4J_DB = os.getenv("NEO4J_DB")

# Initialize Neo4j driver
driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASS))

# FastAPI instance
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or restrict to specific frontend origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Models for requests
class NodeCreateRequest(BaseModel):
    type: str
    properties: dict

class RelationshipCreateRequest(BaseModel):
    from_node: int
    to_node: int
    relationship: str

class NodeUpdateRequest(BaseModel):
    id: int
    updates: dict

class NodeDeleteRequest(BaseModel):
    id: int

# Utility function to run Cypher queries
async def run_query(query: str, parameters: dict = {}):
    with driver.session(database=NEO4J_DB) as session:
        result = session.run(query, parameters)
        return list(result)  # Fetch all records before session closes

# Route to add a node
@app.post("/add-record")
async def add_node(request: NodeCreateRequest):
    query = f"CREATE (n:{request.type} $properties) RETURN n"
    result = await run_query(query, {"properties": request.properties})
    records = result.data()
    if not records:
        raise HTTPException(status_code=500, detail="Failed to add node")
    return {"message": "Node added successfully", "node": records[0]["n"]}

# Route to view all nodes
@app.get("/view-nodes")
async def view_nodes():
    query = "MATCH (n) RETURN labels(n) AS labels, n AS node"
    result = await run_query(query)
    nodes = [{"labels": record["labels"], "properties": record["node"]} for record in result]
    return {"nodes": nodes}

# Route to get the full graph (nodes + relationships)
@app.get("/graph")
async def get_graph():
    query = "MATCH (n) OPTIONAL MATCH (n)-[r]->(m) RETURN n, r, m"
    result = await run_query(query)

    nodes = []
    edges = []
    for record in result:
        print(record)
        if record["n"]:
            nodes.append({
                "id": str(record["n"].id),
                "label": record["n"].labels,
                "properties": record["n"]._properties
            })
        r = record["r"]
        if r is not None:
            edge_id = str(r.element_id)
            if edge_id not in {e["id"] for e in edges}:  # Prevent duplicate edges
                edges.append({
                    "id": edge_id,
                    "source": str(r.nodes[0].id),
                    "target": str(r.nodes[1].id),
                    "label": r.type
                })

    return {"nodes": nodes, "edges": edges}

# Route to add a relationship
@app.post("/add-relationship")
async def add_relationship(request: RelationshipCreateRequest):
    query = """
    MATCH (a) WHERE id(a)=$from, (b) WHERE id(b)=$to
    CREATE (a)-[r:$relationship]->(b)
    RETURN r
    """
    result = await run_query(query, request.model_dump())
    records = result.data()
    if not records:
        raise HTTPException(status_code=500, detail="Failed to create relationship")
    return {"message": "Relationship created successfully", "relationship": records[0]["r"]}

# Route to update a node
@app.put("/update-node")
async def update_node(request: NodeUpdateRequest):
    if not request.updates:
        raise HTTPException(status_code=400, detail="Updates are required")

    set_query = ", ".join([f"n.{key} = ${key}" for key in request.updates.keys()])
    query = f"MATCH (n) WHERE id(n) = $id SET {set_query} RETURN n"

    parameters = {"id": request.id, **request.updates}
    result = await run_query(query, parameters)
    records = result.data()
    if not records:
        raise HTTPException(status_code=404, detail="No matching node found")
    return {"message": "Node updated successfully", "node": records[0]["n"]}

# Route to delete a node
@app.delete("/delete-node")
async def delete_node(request: NodeDeleteRequest):
    query = "MATCH (n) WHERE id(n)=$id DETACH DELETE n"
    await run_query(query, {"id": request.id})
    return {"message": "Node deleted successfully"}

# Run the FastAPI server
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=5500, reload=True)
