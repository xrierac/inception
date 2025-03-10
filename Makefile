DOCKER_COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE = srcs/.env
SSL_DIR = srcs/requirements/nginx/ssl
SSL_CERT = $(SSL_DIR)/nginx.crt
SSL_KEY = $(SSL_DIR)/nginx.key

# Colors for better output
GREEN = $$(printf '\033[0;32m')
YELLOW = $$(printf '\033[0;33m')
RED = $$(printf '\033[0;31m')
RESET = $$(printf '\033[0m')

all: setup build up

# Setup environment
setup: ssl_cert
	@echo "$(YELLOW)Setting up environment...$(RESET)"
	@if [ ! -d "/home/$(USER)/data/wordpress" ]; then \
		echo "$(YELLOW)Creating data directories...$(RESET)"; \
		mkdir -p /home/$(USER)/data/wordpress; \
		chmod 755 /home/$(USER)/data/wordpress; \
		echo "$(GREEN)Wordpress directory created.$(RESET)"; \
	fi
	@if [ ! -d "/home/$(USER)/data/mariadb" ]; then \
		mkdir -p /home/$(USER)/data/mariadb; \
		chmod 755 /home/$(USER)/data/mariadb; \
		echo "$(GREEN)MariaDB directory created.$(RESET)"; \
	fi

# Generate SSL certificate for nginx
ssl_cert:
	@mkdir -p $(SSL_DIR)
	@if [ ! -f $(SSL_CERT) ] || [ ! -f $(SSL_KEY) ]; then \
		echo "$(YELLOW)Generating SSL certificate...$(RESET)"; \
		openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
			-keyout $(SSL_DIR)/nginx.key \
			-out $(SSL_DIR)/nginx.crt \
			-subj "/C=FI/ST=Uusimaa/L=Helsinki/O=42/OU=Hive/CN=xriera-c.42.fr" \
			2>/dev/null; \
		echo "$(GREEN)SSL certificate generated.$(RESET)"; \
	else \
		echo "$(YELLOW)SSL certificate already exists.$(RESET)"; \
	fi

# Build docker images
build:
	@echo "$(YELLOW)Building docker images...$(RESET)"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) build
	@echo "$(GREEN)Docker images built.$(RESET)"

# Start containers
up:
	@echo "$(YELLOW)Starting containers...$(RESET)"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) up -d
	@echo "$(GREEN)Containers are up and running.$(RESET)"

# Stop containers
down:
	@echo "$(YELLOW)Stopping containers...$(RESET)"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) down
	@echo "$(GREEN)Containers stopped.$(RESET)"

# Stop and remove all containers and images
clean: down
	@echo "$(YELLOW)Cleaning up...$(RESET)"
	@docker system prune -af --volumes
	@echo "$(GREEN)Clean up complete.$(RESET)"

# Remove all data
fclean: clean
	@echo "$(YELLOW)Removing all data...$(RESET)"
	@sudo rm -rf /home/$(USER)/data/wordpress
	@sudo rm -rf /home/$(USER)/data/mariadb
	@rm -rf $(SSL_DIR)/*
	@echo "$(GREEN)All data removed.$(RESET)"

# Show container status
status:
	@echo "$(YELLOW)Container status:$(RESET)"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) ps

# Show container logs
logs:
	@echo "$(YELLOW)Container logs:$(RESET)"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) logs

# Restart containers
restart: down up

# Re-build and restart containers
re: clean setup build up

.PHONY: all setup ssl_cert build up down clean fclean status logs restart re
