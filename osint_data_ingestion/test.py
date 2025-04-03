from worker import run_cli_tool

# Run the task asynchronously
task = run_cli_tool.delay("Sherlock", "aaboov")

# Wait for the result (blocking)
result = task.get(timeout=10)
print(result)