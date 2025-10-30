# syntax=docker/dockerfile:1.6

# ✅ Updated to Go 1.24 to match Ollama’s go.mod requirement
FROM golang:1.24 AS builder

WORKDIR /app
COPY . .

# Install dependencies
RUN go mod download

# Build Ollama binary
RUN go build -o /usr/local/bin/ollama .

# ----------------------------
# Final runtime stage
# ----------------------------
FROM debian:bookworm-slim

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y curl tar ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy built binary from builder
COPY --from=builder /usr/local/bin/ollama /usr/local/bin/ollama

# Expose Ollama API port
EXPOSE 11434

# ✅ Start Ollama and preload the llama3 model
CMD sh -c "/usr/local/bin/ollama serve & sleep 10 && /usr/local/bin/ollama pull llama3 && tail -f /dev/null"
