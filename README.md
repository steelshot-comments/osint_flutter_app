# OSINT Investigation app

## Description
This app abstracts the use complex open source intelligence tools to help in investigations.
It has three APIs - authentication, osint tools and neo4j
The flutter frontend uses a webview with cytoscape.js, a graph visualisation tool, which helps visualise and interact with the infromation collected by the tools.

## Notes
The project is currently under development and does not have a stable build
It has been deigned for mobile use but from now on we will focus on desktop more.
It has not been built on windows and mac yet. Linux does not have good Webview support so that has to be added

## Project structure
```
/assets
    /web - required for rendering the graph
    /policies - markdown file
/auth_api - auth system for the user. **(on hold)**
/lib
    /components - custom widgets used throughout the app. for ui consistency
    /auth - authentication logic and UI

    /graph
        /tools - render the toolbar for interacting with the graph
        /graph_provider - Variales and functions for modifying the graph data fetched from the api
        menubar - (on hold)
        tabs - tab logic and tab bar widget
        node details panel - display details and actions when a node is clicked
        filters - performing search filters on the graph
        investigation page - Main page with all graph components mentioned above

    /providers - contains global variables for theme (api provider is on hold)
    /services - functiom for interacting with websocket
    actions timeline - a history of actions performed
```

## Download and modify
The api urls are hard coded right now so follow these start up commands exactly
All apis are running on the public IP of the device. Check your public IP using `ip a` and accordingly set the url in your local flutter code

I have used FastAPI as it is easy to setup and handle errors

Required libraries for FastAPI
`pip install uvicorn fastapi pydantic`

### Neo4j
[Download neo4j desktop](https://neo4j.com/download/)

Required libraries - `pip install neo4j`

```
cd neo4j_api
uvicorn neo4j_api:app --host 0.0.0.0  --port 5500
```

### Osint tools
Required libraries - `sqlite3 asyncio`

```
cd osint_data_ingestion
uvicron osint_api:app --host 0.0.0.0 --port 8000
```

### Celery and redis
Celery workers communicate with the tools API and perform tasks stored in the redis queue

Required libraries - ```pip install re requests subprocess```

Run the celery worker -
```
celery -A worker worker --loglevel info
```

[Install redis](https://redis.io/docs/latest/operate/oss_and_stack/install/archive/install-redis/install-redis-on-linux/)

The code should work out of the box when redis-server service is running

Auth API is not fully functional yet

The dockerfiles are for running multiple workers at a time. It can be avoided for now as we just need to test it with one worker

