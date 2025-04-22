# Dockerfile

# Stage 1: Scraper
FROM node:18-slim as scraper

# Install Chromium dependencies
RUN apt-get update && apt-get install -y \
    chromium \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgdk-pixbuf2.0-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Set Puppeteer env to skip Chromium download
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV SCRAPE_URL=https://example.com

WORKDIR /app
COPY scraper/package*.json ./
RUN npm install
COPY scraper/scrape.cjs ./
RUN node scrape.cjs

# Stage 2: Python Flask Server
FROM python:3.10-slim as server

WORKDIR /app

# Copy Python files
COPY server/server.py .
COPY server/requirements.txt .

# Copy scraped data from scraper stage
COPY --from=scraper /app/scraped_data.json .

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["python", "server.py"]
