# Use an official, lightweight Python image
FROM python:3.10-slim

# Prevent Python from writing .pyc files and buffer stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_ROOT_USER_ACTION=ignore

WORKDIR /app

# Install system dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y --no-install-recommends gcc libpq-dev build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY app/requirements.txt /app/
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the rest of the Django project code
COPY app/ /app/

# --- BULLETPROOF FIX: Create empty configuration.py files ---
# We do this before switching to the non-root user so the chown command below applies to them.
RUN mkdir -p statuspage/statuspage \
    && touch statuspage/configuration.py \
    && touch statuspage/statuspage/configuration.py

# Create a non-root user and grant ownership of the app folder
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "statuspage.wsgi:application"]
