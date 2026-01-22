.PHONY: docker-up-dev docker-up-prod docker-down

docker-up-dev:
	@echo "Starting development environment..."
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
	@echo "\n=== Development Environment Started ==="
	@echo "Frontend:  http://localhost:8080"
	@echo "Backend:   http://localhost:8081"
	@echo "Database:  localhost:1521"
	@echo "ORDS:      http://localhost:8181"
	@echo "Ollama:    http://localhost:11434"
	@echo "========================================\n"

docker-up-prod:
	@echo "Starting production environment..."
	docker compose -f docker-compose.yml up -d
	@echo "\n=== Production Environment Started ==="
	@echo "Frontend:  http://localhost:8080"
	@echo "Backend:   http://localhost:8081"
	@echo "Database:  localhost:1521"
	@echo "ORDS:      http://localhost:8181"
	@echo "Ollama:    http://localhost:11434"
	@echo "========================================\n"

docker-down:
	@echo "Stopping and removing all containers..."
	@docker compose -f docker-compose.yml -f docker-compose.dev.yml down --remove-orphans 2>/dev/null || true
	@docker compose -f docker-compose.yml down --remove-orphans 2>/dev/null || true
	@echo "All containers stopped and removed."
