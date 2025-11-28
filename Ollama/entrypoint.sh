#!/bin/bash
set -e

# Start the Ollama server in the background
echo "Starting Ollama server..."
/bin/ollama serve &
OLLAMA_PID=$!

# Wait for the Ollama server to be accessible via its API
echo "Waiting for Ollama API to be ready..."
until curl -s http://localhost:11434 > /dev/null; do
  sleep 1
done

# Pull the Mistral model
echo "✅ Ollama is ready. Pulling mistral:latest model..."
ollama pull mistral:latest

echo "🟢 Model pull complete. Ollama service is operational."

# Wait indefinitely for the background Ollama process (pid) to finish
# This keeps the container running until stopped externally
wait $OLLAMA_PID
