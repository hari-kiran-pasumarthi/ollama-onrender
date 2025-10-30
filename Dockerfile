# syntax=docker/dockerfile:1.6
FROM golang:1.23 AS builder

WORKDIR /app
COPY . .

# ✅ No caching, but guaranteed to build on all Docker builders
RUN go mod download
RUN go build -o /usr/local/bin/ollama .

# ----------------------------
# Final runtime stage
# ----------------------------
FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update && apt-get install -y curl tar ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/ollama /usr/local/bin/ollama

EXPOSE 11434

CMD sh -c "/usr/local/bin/ollama serve & sleep 10 && /usr/local/bin/ollama pull llama3 && tail -f /dev/null"
