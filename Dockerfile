# Use an official, lightweight Python image
FROM python:3.10-slim

# Prevent Python from writing .pyc files and buffer stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Silence the pip root warning during the build process
ENV PIP_ROOT_USER_ACTION=ignore

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies silently (fixes the debconf warnings)
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y --no-install-recommends gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file first to leverage Docker layer caching
COPY app/requirements.txt /app/

# Install the Python dependencies
RUN pip install --upgrade pip \
    && pip install -r requirements.txt

# Copy the rest of the Django project code into the container
COPY app/ /app/

# Create a non-root user and grant ownership of the app folder (Security Best Practice)
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Expose the port that Gunicorn will use
EXPOSE 8000

# Start Gunicorn to serve the Django application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "status_project.wsgi:application"]
