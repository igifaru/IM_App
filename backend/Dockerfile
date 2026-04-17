# Build from repo root: docker build -f backend/Dockerfile -t igisubizo-api .
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y gcc g++ && rm -rf /var/lib/apt/lists/*

# Copy models from repo root (available when building from repo root)
COPY models/ /app/models/

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --prefer-binary -r requirements.txt

# Copy app code
COPY backend/app/ /app/app/

RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/api/v1/health')" || exit 1

CMD uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}
