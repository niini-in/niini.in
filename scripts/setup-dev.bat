@echo off
REM MiniShop Development Environment Setup Script for Windows

echo 🚀 Setting up MiniShop development environment...

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not running. Please start Docker and try again.
    pause
    exit /b 1
)

REM Check if required tools are available
where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed or not in PATH.
    pause
    exit /b 1
)

where docker-compose >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose is not installed or not in PATH.
    pause
    exit /b 1
)

REM Create .env file if it doesn't exist
if not exist .env (
    echo 📝 Creating .env file from template...
    copy .env.example .env
    echo ✅ .env file created. Please review and update as needed.
)

REM Create .env files for services if they don't exist
echo 📝 Setting up service environment files...

if not exist "services\notification-service\.env" (
    if exist "services\notification-service\.env.example" (
        copy "services\notification-service\.env.example" "services\notification-service\.env"
    )
)

if not exist "services\payment-service\.env" (
    if exist "services\payment-service\.env.example" (
        copy "services\payment-service\.env.example" "services\payment-service\.env"
    )
)

if not exist "services\product-service\.env" (
    if exist "services\product-service\.env.example" (
        copy "services\product-service\.env.example" "services\product-service\.env"
    )
)

REM Build all services
echo 🔨 Building all services...
docker-compose build
if %errorlevel% neq 0 (
    echo ❌ Build failed. Please check the error messages above.
    pause
    exit /b 1
)

REM Start infrastructure services first
echo 🚀 Starting infrastructure services...
docker-compose up -d postgres redis zookeeper kafka

REM Wait for services to be ready
echo ⏳ Waiting for services to be ready...
timeout /t 30 /nobreak >nul

REM Check service health
echo 🔍 Checking service health...
docker-compose ps

echo.
echo 🎉 Development environment setup complete!
echo.
echo 📖 Quick Start Guide:
echo 1. Start all services: docker-compose up
echo 2. View logs: docker-compose logs -f [service-name]
echo 3. Stop services: docker-compose down
echo 4. Access services:
echo    - Gateway: http://localhost:8080
echo    - Grafana: http://localhost:3000 (admin/admin)
echo    - Prometheus: http://localhost:9090
echo.
echo 🔧 For local development without Docker:
echo 1. Install dependencies for each service
echo 2. Copy .env.example to .env in each service directory
echo 3. Start PostgreSQL and Kafka locally
echo 4. Run each service individually
echo.
pause