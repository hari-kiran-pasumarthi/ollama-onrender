# syntax=docker/dockerfile:1.6
FROM golang:1.23 AS builder

WORKDIR /app
COPY . .

# ✅ FIX: Add "builder-" prefix to cache mount IDs
RUN --mount=type=cache,id=builder-go-mod,target=/go/pkg/mod \
    --mount=type=cache,id=builder-go-build,target=/root/.cache/go-build \
    go mod download

# Build the Ollama binary
RUN go build -o /usr/local/bin/ollama .

# -----------------------
# Final Runtime Stage
# -----------------------
FROM debian:bookworm-slim

WORKDIR /app

# Install basic dependencies
RUN apt-get update && apt-get install -y curl tar ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy compiled Ollama binary
COPY --from=builder /usr/local/bin/ollama /usr/local/bin/ollama

# Expose Ollama’s API port
EXPOSE 11434

# ✅ Start Ollama and preload model
CMD sh -c "/usr/local/bin/ollama serve & sleep 10 && /usr/local/bin/ollama pull llama3 && tail -f /dev/null"
