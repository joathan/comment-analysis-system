# Define a default command for docker compose
COMPOSE = docker compose

# Target to set up the entire application from scratch
# Builds images, creates the DB, runs migrations, and then runs tests.
setup: build db-create db-migrate test

# Build or rebuild the docker images
build:
	@echo "Building Docker images..."
	$(COMPOSE) build

# Start all services in detached mode
up:
	@echo "Starting all services..."
	$(COMPOSE) up -d

# Stop all services
down:
	@echo "Stopping all services..."
	$(COMPOSE) down

# Restart all services
restart: down up

# Create the database
db-create:
	@echo "Creating database..."
	$(COMPOSE) run --rm web bundle exec rails db:create

# Run database migrations
db-migrate:
	@echo "Running database migrations..."
	$(COMPOSE) run --rm web bundle exec rails db:migrate

# Seed the database
db-seed:
	@echo "Seeding the database..."
	$(COMPOSE) run --rm web bundle exec rails db:seed

# Run the test suite
test:
	@echo "Running RSpec test suite..."
	$(COMPOSE) run --rm web bundle exec rspec

# Open a bash shell inside the web container
bash:
	@echo "Opening bash shell in web container..."
	$(COMPOSE) exec web /bin/bash

# Open a Rails console
console:
	@echo "Opening Rails console..."
	$(COMPOSE) exec web bundle exec rails console

# View the logs of all services
logs:
	@echo "Tailing logs..."
	$(COMPOSE) logs -f

# Clean up the environment (stop and remove containers, volumes, and networks)
clean:
	@echo "Cleaning up Docker environment (containers, volumes, networks)..."
	$(COMPOSE) down -v --remove-orphans

# Declare targets that are not files
.PHONY: setup build up down restart db-create db-migrate db-seed test bash console logs clean
