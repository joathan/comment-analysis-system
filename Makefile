# Define o alvo padrão que será executado quando 'make' for chamado sem argumentos.
.DEFAULT_GOAL := help

# Define a default command for docker compose
COMPOSE = docker compose

help:
	@echo "Comandos disponíveis:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ==============================================================================
# Comandos de Gerenciamento do Ambiente
# ==============================================================================

setup: build db-create db-migrate test redis-flush ## Configura a aplicação do zero.
build: ## Constrói ou reconstrói as imagens Docker.
	@echo "Building Docker images..."
	$(COMPOSE) build

up: ## Inicia todos os serviços em segundo plano.
	@echo "Starting all services..."
	$(COMPOSE) up -d

down: ## Para todos os serviços.
	@echo "Stopping all services..."
	$(COMPOSE) down

restart: down up ## Reinicia todos os serviços.
	@echo "Restarting services..."

clean: redis-flush ## Limpa o ambiente Docker (containers, volumes, redes).
	@echo "Cleaning up Docker environment (containers, volumes, networks)..."
	$(COMPOSE) down -v --remove-orphans

# ==============================================================================
# Comandos de Banco de Dados
# ==============================================================================

db-create: ## Cria o banco de dados.
	@echo "Creating database..."
	$(COMPOSE) run --rm web bundle exec rails db:create

db-migrate: ## Executa as migrações do banco de dados.
	@echo "Running database migrations..."
	$(COMPOSE) run --rm web bundle exec rails db:migrate

db-seed: ## Popula o banco de dados com dados iniciais.
	@echo "Seeding the database..."
	$(COMPOSE) run --rm web bundle exec rails db:seed

# ==============================================================================
# Comandos de Desenvolvimento e Teste
# ==============================================================================

test: ## Executa a suíte de testes (RSpec).
	@echo "Running RSpec test suite..."
	$(COMPOSE) run --rm web bundle exec rspec

redis-flush: ## Limpa todo o cache do Redis.
	@echo "Flushing Redis cache..."
	@$(COMPOSE) exec redis redis-cli FLUSHALL || echo "Redis container not running or not ready, skipping flush."

bash: ## Abre um terminal (bash) no container da aplicação web.
	@echo "Opening bash shell in web container..."
	$(COMPOSE) exec web /bin/bash

console: ## Abre um console do Rails.
	@echo "Opening Rails console..."
	$(COMPOSE) exec web bundle exec rails console

logs: ## Exibe os logs de todos os serviços em tempo real.
	@echo "Tailing logs..."
	$(COMPOSE) logs -f

attach: ## Anexa ao container web para debugging (ex: binding.pry).
	@echo "Attaching to web container... (Pressione Ctrl+C para desanexar)"
	@docker attach $$(docker compose ps -q web)

# Declara os alvos que não são arquivos para evitar conflitos.
.PHONY: help setup build up down restart clean db-create db-migrate db-seed test redis-flush bash console logs attach
