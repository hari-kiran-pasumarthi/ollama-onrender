# syntax=docker/dockerfile:1.6
FROM golang:1.23 AS builder

WORKDIR /app

# Copy all source code
COPY . .

# ✅ Properly prefixed cache mount IDs
RUN --mount=type=cache,id=ollama-go-mod,target=/go/pkg/mod \
    --mount=type=cache,id=ollama-go-build,target=/root/.cache/go-build \
    go mod download

# Build Ollama binary
RUN go build -o /usr/local/bin/ollama .

# -----------------------
# Final Stage (runtime)
# -----------------------
FROM debian:bookworm-slim

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y curl tar ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy the built binary from builder
COPY --from=builder /usr/local/bin/ollama /usr/local/bin/ollama

# Expose Ollama API port
EXPOSE 11434

# ✅ Optional: preload llama3 model for immediate use
CMD sh -c "/usr/local/bin/ollama serve & sleep 10 && /usr/local/bin/ollama pull llama3 && tail -f /dev/null"
