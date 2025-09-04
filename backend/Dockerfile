# syntax=docker/dockerfile:1
# ---------- Base image ----------
FROM python:3.12-slim AS base
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_LINK_MODE=copy

# System deps for building wheels (adjust as needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates build-essential gcc git pkg-config libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv (fast Python packaging)
RUN curl -fsSL https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

WORKDIR /app

# ---------- Dependencies layer ----------
FROM base AS deps
WORKDIR /app

# Copy only manifests to leverage cache
COPY pyproject.toml uv.lock* ./

# Build virtualenv in /app/.venv
# If uv.lock exists -> use --frozen; else fall back without it.
RUN --mount=type=cache,target=/root/.cache/uv \
    sh -c 'test -f uv.lock && uv sync --no-dev --frozen || uv sync --no-dev'

# ---------- Application layer ----------
FROM base AS runtime
WORKDIR /app

# Bring the virtualenv over and activate via PATH
COPY --from=deps /app/.venv /app/.venv
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:$PATH"

# Copy application code
COPY app ./app

# Drop privileges
RUN useradd -m appuser
USER appuser

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
