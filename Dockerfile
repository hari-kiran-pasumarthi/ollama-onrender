# syntax=docker/dockerfile:1.6

FROM golang:1.23 AS builder

WORKDIR /app
COPY . .

# ✅ FIXED: Cache IDs prefixed with build context key ("builder:" instead of just name)
RUN --mount=type=cache,id=builder:go-mod,target=/go/pkg/mod \
    --mount=type=cache,id=builder:go-build,target=/root/.cache/go-build \
    go mod download

# Build Ollama binary
RUN go build -o /usr/local/bin/ollama .

# ----------------------------
# Final runtime stage
# ----------------------------
FROM debian:bookworm-slim

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y curl tar ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy built binary
COPY --from=builder /usr/local/bin/ollama /usr/local/bin/ollama

# Expose Ollama API port
EXPOSE 11434

# ✅ Start Ollama and preload a model
CMD sh -c "/usr/local/bin/ollama serve & sleep 10 && /usr/local/bin/ollama pull llama3 && tail -f /dev/null"
