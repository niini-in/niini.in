#!/bin/bash

# MiniShop Development Environment Setup Script

set -e

echo "🚀 Setting up MiniShop development environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi

# Check if required tools are installed
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 is not installed. Please install $1 and try again.${NC}"
        exit 1
    fi
}

echo "📋 Checking required tools..."
check_command "docker"
check_command "docker-compose"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo -e "${GREEN}✅ .env file created. Please review and update as needed.${NC}"
fi

# Create .env files for services if they don't exist
create_service_env() {
    local service=$1
    local env_file="services/${service}/.env"
    local example_file="services/${service}/.env.example"
    
    if [ ! -f "$env_file" ] && [ -f "$example_file" ]; then
        echo "📝 Creating .env file for ${service}..."
        cp "$example_file" "$env_file"
    fi
}

echo "📝 Setting up service environment files..."
create_service_env "notification-service"
create_service_env "payment-service"
create_service_env "product-service"

# Build all services
echo "🔨 Building all services..."
docker-compose build

# Start infrastructure services first
echo "🚀 Starting infrastructure services..."
docker-compose up -d postgres redis zookeeper kafka

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check service health
echo "🔍 Checking service health..."
docker-compose ps

echo ""
echo -e "${GREEN}🎉 Development environment setup complete!${NC}"
echo ""
echo "📖 Quick Start Guide:"
echo "1. Start all services: docker-compose up"
echo "2. View logs: docker-compose logs -f [service-name]"
echo "3. Stop services: docker-compose down"
echo "4. Access services:"
echo "   - Gateway: http://localhost:8080"
echo "   - Grafana: http://localhost:3000 (admin/admin)"
echo "   - Prometheus: http://localhost:9090"
echo ""
echo "🔧 For local development without Docker:"
echo "1. Install dependencies for each service"
echo "2. Copy .env.example to .env in each service directory"
echo "3. Start PostgreSQL and Kafka locally"
echo "4. Run each service individually"