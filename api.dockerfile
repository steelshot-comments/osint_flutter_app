# Use official Python image
FROM python:3.10

# Set working directory
WORKDIR /app

# Copy the project files
COPY . /app

# Install dependencies
RUN pip install -r requirements.txt

# Run the API
CMD ["uvicorn", "api_server:app", "--host", "0.0.0.0", "--port", "8000"]
