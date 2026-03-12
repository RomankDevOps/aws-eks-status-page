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

# --- THE FOOLPROOF FIX ---
# Dynamically find the file and copy it to configuration.py in the same directory
RUN CONFIG_FILE=$(find . -name "configuration_example.py" | head -n 1) \
    && cp "$CONFIG_FILE" "$(dirname "$CONFIG_FILE")/configuration.py"

# Create a non-root user and grant ownership
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "statuspage.wsgi:application"]
