FROM python:3.10-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends gcc libpq-dev build-essential && rm -rf /var/lib/apt/lists/*
COPY app/requirements.txt /app/
RUN pip install --upgrade pip && pip install --prefix=/install -r requirements.txt

FROM python:3.10-slim AS runtime
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_ROOT_USER_ACTION=ignore
ENV PYTHONPATH="/app/statuspage"
WORKDIR /app

COPY --from=builder /install /usr/local

RUN apt-get update && apt-get install -y --no-install-recommends libpq5 && rm -rf /var/lib/apt/lists/*

COPY app/ /app/
RUN CONFIG_FILE=$(find . -name "configuration_example.py" | head -n 1) && cp "$CONFIG_FILE" "$(dirname "$CONFIG_FILE")/configuration.py"
RUN mkdir -p /app/static && python manage.py collectstatic --no-input

RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--chdir", "/app", "statuspage.wsgi:application"]
