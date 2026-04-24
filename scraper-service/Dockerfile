FROM python:3.12-slim

WORKDIR /app

# Install font packages that playwright --with-deps expects
# (ttf-ubuntu-font-family and ttf-unifont were renamed in newer Debian)
RUN apt-get update && apt-get install -y \
    fonts-ubuntu fonts-unifont \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright Chromium + all remaining system dependencies
RUN playwright install --with-deps chromium

COPY scraper.py server.py ./

EXPOSE 8080

CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8080"]
