# Use Python 3.12 slim image for smaller size
FROM python:3.12-slim

# Install system dependencies (curl for health checks)
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install UV (pinned version for reproducibility)
RUN pip install --no-cache-dir uv==0.4.18

# Create non-root user for security (using higher IDs to avoid host conflicts)
RUN groupadd --gid 10001 appuser && \
    useradd --uid 10001 --gid 10001 --create-home appuser

# Switch to non-root user
USER appuser

# Set working directory
WORKDIR /app

# Set environment variables for optimization and configuration
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_NO_CACHE=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_PROJECT_ENVIRONMENT=/app/.venv \
    HOST=0.0.0.0 \
    CONTAINER_PORT=5689

# Copy UV configuration files first (for better layer caching)
COPY --chown=appuser:appuser src/pyproject.toml src/uv.lock* ./

# Install only production dependencies
RUN uv sync --frozen --no-dev

# Copy only necessary application files
COPY --chown=appuser:appuser src/*.py ./

# Expose the port the app runs on
EXPOSE 5689

# Run the application with graceful shutdown configuration
CMD uv run uvicorn main:app --host $HOST --port $CONTAINER_PORT --timeout-keep-alive 120 --timeout-graceful-shutdown 30
