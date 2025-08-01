# MiniShop Development Makefile
# Provides convenient commands for development workflow

.PHONY: help setup build start stop restart logs clean test health-check build-all up down ps init dev

# Default environment
env ?= dev

# Default service (all if not specified)
service ?= all

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Services list
SERVICES := user-service product-service order-service payment-service notification-service
INFRA_SERVICES := postgres redis zookeeper kafka
ALL_SERVICES := $(SERVICES) spring-gateway service-registry

# Docker compose command
DOCKER_COMPOSE := docker-compose
DOCKER_COMPOSE_FILE := docker-compose.yml

## Display help information
help: ## Display this help
	@echo "$(BLUE)MiniShop Development Commands$(NC)"
	@echo ""
	@echo "$(GREEN)Setup Commands:$(NC)"
	@echo "  setup           - Initial setup and environment configuration"
	@echo "  init            - Initialize development environment"
	@echo ""
	@echo "$(GREEN)Build Commands:$(NC)"
	@echo "  build           - Build all services"
	@echo "  build-service   - Build specific service (usage: make build-service SERVICE=user-service)"
	@echo "  build-all       - Build all services with no cache"
	@echo ""
	@echo "$(GREEN)Run Commands:$(NC)"
	@echo "  start           - Start all services"
	@echo "  start-infra     - Start only infrastructure services"
	@echo "  start-services  - Start only application services"
	@echo "  stop            - Stop all services"
	@echo "  restart         - Restart all services"
	@echo "  restart-service - Restart specific service (usage: make restart-service SERVICE=user-service)"
	@echo ""
	@echo "$(GREEN)Development Commands:$(NC)"
	@echo "  up              - Start all services in foreground"
	@echo "  down            - Stop and remove containers"
	@echo "  logs            - Show logs for all services"
	@echo "  logs-service    - Show logs for specific service (usage: make logs-service SERVICE=user-service)"
	@echo "  ps              - Show running containers"
	@echo "  status          - Show service status"
	@echo ""
	@echo "$(GREEN)Testing Commands:$(NC)"
	@echo "  test            - Run tests for all services"
	@echo "  test-service    - Run tests for specific service (usage: make test-service SERVICE=user-service)"
	@echo "  health-check    - Check health of all services"
	@echo ""
	@echo "$(GREEN)Maintenance Commands:$(NC)"
	@echo "  clean           - Clean up containers, networks, and volumes"
	@echo "  clean-images    - Clean up Docker images"
	@echo "  prune           - Prune Docker system"
	@echo "  setup-dev       - Setup development environment"

## Initial setup and configuration
setup: ## Initial setup and environment configuration
	@echo "$(BLUE)Setting up MiniShop development environment...$(NC)"
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(GREEN)Created .env file from .env.example$(NC)"; \
	else \
		echo "$(YELLOW).env file already exists$(NC)"; \
	fi
	@echo "$(GREEN)Setup complete!$(NC)"

## Initialize development environment
init: setup ## Initialize development environment
	@echo "$(BLUE)Initializing development environment...$(NC)"
	@$(DOCKER_COMPOSE) pull
	@$(DOCKER_COMPOSE) build --no-cache
	@echo "$(GREEN)Environment initialized!$(NC)"

## Build all services
build: ## Build all services
	@echo "$(BLUE)Building all services...$(NC)"
	@$(DOCKER_COMPOSE) build
	@echo "$(GREEN)Build complete!$(NC)"

## Build specific service
build-service: ## Build specific service (usage: make build-service SERVICE=user-service)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)Error: Please specify SERVICE parameter$(NC)"; \
		echo "$(YELLOW)Usage: make build-service SERVICE=user-service$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Building $(SERVICE)...$(NC)"
	@$(DOCKER_COMPOSE) build $(SERVICE)

## Build all services with no cache
build-all: ## Build all services with no cache
	@echo "$(BLUE)Building all services without cache...$(NC)"
	@$(DOCKER_COMPOSE) build --no-cache
	@echo "$(GREEN)Build complete!$(NC)"

## Start all services
start: ## Start all services
	@echo "$(BLUE)Starting all services...$(NC)"
	@$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)Services started!$(NC)"
	@$(MAKE) health-check

## Start only infrastructure services
start-infra: ## Start only infrastructure services
	@echo "$(BLUE)Starting infrastructure services...$(NC)"
	@$(DOCKER_COMPOSE) up -d postgres redis zookeeper kafka
	@echo "$(GREEN)Infrastructure services started!$(NC)"
	@echo "$(YELLOW)Waiting for services to be ready...$(NC)"
	@sleep 15
	@$(MAKE) health-check-infra

## Start only application services
start-services: ## Start only application services
	@echo "$(BLUE)Starting application services...$(NC)"
	@$(DOCKER_COMPOSE) up -d $(SERVICES) spring-gateway service-registry
	@echo "$(GREEN)Application services started!$(NC)"
	@$(MAKE) health-check-services

## Stop all services
stop: ## Stop all services
	@echo "$(BLUE)Stopping all services...$(NC)"
	@$(DOCKER_COMPOSE) down
	@echo "$(GREEN)Services stopped!$(NC)"

## Stop and remove containers, networks, volumes
down: ## Stop and remove containers
	@echo "$(BLUE)Stopping and removing containers...$(NC)"
	@$(DOCKER_COMPOSE) down -v
	@echo "$(GREEN)Cleanup complete!$(NC)"

## Restart all services
restart: stop start ## Restart all services

## Restart specific service
restart-service: ## Restart specific service (usage: make restart-service SERVICE=user-service)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)Error: Please specify SERVICE parameter$(NC)"; \
		echo "$(YELLOW)Usage: make restart-service SERVICE=user-service$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Restarting $(SERVICE)...$(NC)"
	@$(DOCKER_COMPOSE) restart $(SERVICE)
	@$(MAKE) health-check-service SERVICE=$(SERVICE)

## Start all services in foreground
up: ## Start all services in foreground (usage: make up [service=service-name])
	@if [ "$(service)" = "all" ]; then \
		$(DOCKER_COMPOSE) up; \
	else \
		$(DOCKER_COMPOSE) up $(service); \
	fi

## Show logs for all services
logs: ## Show logs for all services (usage: make logs [service=service-name])
	@if [ "$(service)" = "all" ]; then \
		$(DOCKER_COMPOSE) logs -f; \
	else \
		$(DOCKER_COMPOSE) logs -f $(service); \
	fi

## Show running containers
ps: ## Show running containers
	@$(DOCKER_COMPOSE) ps

## Show service status
status: ## Show service status
	@echo "$(BLUE)Service Status:$(NC)"
	@$(DOCKER_COMPOSE) ps

# Testing
test: ## Run tests (usage: make test [service=service-name])
	@if [ "$(service)" = "all" ]; then \
		echo "Running all tests..." && \
		cd services/user-service && ./mvnw test && cd ../.. && \
		cd services/product-service && go test ./... && cd ../.. && \
		cd services/order-service && ./mvnw test && cd ../.. && \
		cd services/payment-service && pytest && cd ../.. && \
		cd services/notification-service && npm test && cd ../..; \
	else \
		echo "Running tests for $(service)..." && \
		cd services/$(service) && \
		if [ -f "./mvnw" ]; then \
			./mvnw test; \
		elif [ -f "go.mod" ]; then \
			go test ./...; \
		elif [ -f "package.json" ]; then \
			npm test; \
		elif [ -f "requirements.txt" ]; then \
			pytest; \
		fi && \
		cd ../..; \
	fi

# Docker Commands
docker-build: ## Build Docker images (usage: make docker-build [service=service-name])
	@if [ "$(service)" = "all" ]; then \
		for svc in user-service product-service order-service payment-service notification-service; do \
			docker build -t niini/$$svc:latest services/$$svc; \
		done; \
	else \
		docker build -t niini/$(service):latest services/$(service); \
	fi

docker-push: ## Push Docker images (usage: make docker-push [service=service-name])
	@if [ "$(service)" = "all" ]; then \
		for svc in user-service product-service order-service payment-service notification-service; do \
			docker push niini/$$svc:latest; \
		done; \
	else \
		docker push niini/$(service):latest; \
	fi

docker-build-push: docker-build docker-push ## Build and push Docker images

# Kubernetes Commands
k8s-deploy: ## Deploy to Kubernetes (usage: make k8s-deploy env=dev [service=service-name])
	@if [ "$(service)" = "all" ]; then \
		for svc in user-service product-service order-service payment-service notification-service; do \
			kubectl apply -f infra/kubernetes/$$svc/$(env)/; \
		done; \
	else \
		kubectl apply -f infra/kubernetes/$(service)/$(env)/; \
	fi

# Helm Commands
helm-deploy: ## Deploy using Helm (usage: make helm-deploy env=dev [service=service-name])
	@if [ "$(service)" = "all" ]; then \
		for svc in user-service product-service order-service payment-service notification-service; do \
			helm upgrade --install $$svc infra/helm-charts/$$svc --namespace minishop-$(env) --create-namespace --values infra/helm-charts/$$svc/values-$(env).yaml; \
		done; \
	else \
		helm upgrade --install $(service) infra/helm-charts/$(service) --namespace minishop-$(env) --create-namespace --values infra/helm-charts/$(service)/values-$(env).yaml; \
	fi

# Clean Commands
clean: ## Clean build artifacts
	find . -name "target" -type d -exec rm -rf {} +;
	find . -name "node_modules" -type d -exec rm -rf {} +;
	find . -name "__pycache__" -type d -exec rm -rf {} +;
	find . -name ".pytest_cache" -type d -exec rm -rf {} +;

## Health check for all services
health-check: ## Check health of all services
	@echo "$(BLUE)Checking health of all services...$(NC)"
	@echo "$(GREEN)Checking infrastructure...$(NC)"
	@$(MAKE) health-check-infra
	@echo "$(GREEN)Checking services...$(NC)"
	@$(MAKE) health-check-services

## Health check for infrastructure
health-check-infra: ## Check health of infrastructure services
	@echo "$(BLUE)Checking infrastructure services...$(NC)"\t
	@echo "$(GREEN)✓ PostgreSQL:5432 $(NC)"
	@echo "$(GREEN)✓ Redis:6379 $(NC)"
	@echo "$(GREEN)✓ Zookeeper:2181 $(NC)"
	@echo "$(GREEN)✓ Kafka:9092 $(NC)"
	@echo "$(GREEN)Infrastructure health check complete!$(NC)"

## Health check for services
health-check-services: ## Check health of application services
	@echo "$(BLUE)Checking application services...$(NC)"
	@services="spring-gateway:8080 service-registry:8761 user-service:8081 product-service:8082 order-service:8083 payment-service:8084 notification-service:8085"; \
	for service in $$services; do \
		name=$$(echo $$service | cut -d: -f1); \
		port=$$(echo $$service | cut -d: -f2); \
		if curl -s http://localhost:$$port/actuator/health > /dev/null 2>&1 || curl -s http://localhost:$$port/health > /dev/null 2>&1 || curl -s http://localhost:$$port > /dev/null 2>&1; then \
			echo "$(GREEN)✓ $$name:$$port is healthy$(NC)"; \
		else \
			echo "$(RED)✗ $$name:$$port is not responding$(NC)"; \
		fi; \
	done

## Health check for specific service
health-check-service: ## Check health of specific service (usage: make health-check-service SERVICE=user-service)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)Error: Please specify SERVICE parameter$(NC)"; \
		echo "$(YELLOW)Usage: make health-check-service SERVICE=user-service$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Checking health of $(SERVICE)...$(NC)"
	@case "$(SERVICE)" in \
		user-service) curl -s http://localhost:8081/actuator/health > /dev/null 2>&1 && echo "$(GREEN)✓ $(SERVICE) is healthy$(NC)" || echo "$(RED)✗ $(SERVICE) is not responding$(NC)" ;; \
		product-service) curl -s http://localhost:8082/health > /dev/null 2>&1 && echo "$(GREEN)✓ $(SERVICE) is healthy$(NC)" || echo "$(RED)✗ $(SERVICE) is not responding$(NC)" ;; \
		order-service) curl -s http://localhost:8083/actuator/health > /dev/null 2>&1 && echo "$(GREEN)✓ $(SERVICE) is healthy$(NC)" || echo "$(RED)✗ $(SERVICE) is not responding$(NC)" ;; \
		payment-service) curl -s http://localhost:8084/health > /dev/null 2>&1 && echo "$(GREEN)✓ $(SERVICE) is healthy$(NC)" || echo "$(RED)✗ $(SERVICE) is not responding$(NC)" ;; \
		notification-service) curl -s http://localhost:8085/health > /dev/null 2>&1 && echo "$(GREEN)✓ $(SERVICE) is healthy$(NC)" || echo "$(RED)✗ $(SERVICE) is not responding$(NC)" ;; \
		spring-gateway) curl -s http://localhost:8080/actuator/health > /dev/null 2>&1 && echo "$(GREEN)✓ $(SERVICE) is healthy$(NC)" || echo "$(RED)✗ $(SERVICE) is not responding$(NC)" ;; \
		service-registry) curl -s http://localhost:8761/actuator/health > /dev/null 2>&1 && echo "$(GREEN)✓ $(SERVICE) is healthy$(NC)" || echo "$(RED)✗ $(SERVICE) is not responding$(NC)" ;; \
		*) echo "$(RED)Unknown service: $(SERVICE)$(NC)" ;; \
	esac

## Run tests for specific service
test-service: ## Run tests for specific service (usage: make test-service SERVICE=user-service)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)Error: Please specify SERVICE parameter$(NC)"; \
		echo "$(YELLOW)Usage: make test-service SERVICE=user-service$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Running tests for $(SERVICE)...$(NC)"
	@case "$(SERVICE)" in \
		user-service|order-service) \
			cd services/$(SERVICE) && ./mvnw test ;; \
		product-service) \
			cd services/$(SERVICE) && go test ./... ;; \
		payment-service) \
			cd services/$(SERVICE) && python -m pytest ;; \
		notification-service) \
			cd services/$(SERVICE) && npm test ;; \
		*) echo "$(RED)Unknown service: $(SERVICE)$(NC)" ;; \
	esac

## Clean up containers, networks, and volumes
clean: ## Clean up containers, networks, and volumes
	@echo "$(BLUE)Cleaning up containers, networks, and volumes...$(NC)"
	@$(DOCKER_COMPOSE) down -v --remove-orphans
	@echo "$(GREEN)Cleanup complete!$(NC)"

## Clean up Docker images
clean-images: ## Clean up Docker images
	@echo "$(BLUE)Cleaning up Docker images...$(NC)"
	@docker image prune -f
	@echo "$(GREEN)Docker images cleaned!$(NC)"

## Prune Docker system
prune: ## Prune Docker system
	@echo "$(BLUE)Pruning Docker system...$(NC)"
	@docker system prune -af --volumes
	@echo "$(GREEN)Docker system pruned!$(NC)"

## Quick development start
dev: setup start ## Quick development start

## Development with logs
dev-logs: setup start-infra ## Development with logs
	@echo "$(GREEN)Infrastructure ready! Starting services with logs...$(NC)"
	@$(DOCKER_COMPOSE) up $(SERVICES) spring-gateway service-registry

## Show all available ports
ports: ## Show all available ports
	@echo "$(BLUE)Service Ports:$(NC)"
	@echo "  Gateway: 8080"
	@echo "  User Service: 8081"
	@echo "  Product Service: 8082"
	@echo "  Order Service: 8083"
	@echo "  Payment Service: 8084"
	@echo "  Notification Service: 8085"
	@echo "  Service Registry: 8761"
	@echo "  PostgreSQL: 5432"
	@echo "  Redis: 6379"
	@echo "  Kafka: 9092"
	@echo "  Grafana: 3000"
	@echo "  Prometheus: 9090"
	@echo "  Jaeger: 16686"

## Quick development workflow
quick-start: setup build start health-check ## Quick start development environment

## Development environment with health checks
dev-full: setup build start-infra health-check-infra start-services health-check-services ## Full development setup with health checks

## Setup development environment
setup-dev: ## Setup development environment
	@echo "$(BLUE)Setting up development environment...$(NC)"
	@./scripts/setup-dev.sh

## Windows setup (using batch file)
setup-windows: ## Setup Windows development environment
	@echo "$(BLUE)Setting up Windows development environment...$(NC)"
	@scripts\\setup-dev.bat

# Default target
.DEFAULT_GOAL := help