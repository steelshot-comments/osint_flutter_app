FROM python:3.10

WORKDIR /app

# Install OS dependencies if needed (e.g., for OnionScan)
RUN apt-get update && apt-get install -y tor

COPY . /app

RUN pip install -r requirements.txt

CMD ["celery", "-A", "worker", "worker", "--loglevel=info"]
