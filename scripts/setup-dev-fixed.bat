@echo off
REM MiniShop Development Environment Setup Script - Fixed Version

echo 🚀 Setting up MiniShop development environment...

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not running. Please start Docker and try again.
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

REM Start infrastructure services first
echo 🚀 Starting infrastructure services...
docker-compose up -d postgres redis zookeeper kafka service-registry

REM Wait for services to be ready
echo ⏳ Waiting for services to be ready...
timeout /t 30 /nobreak >nul

REM Check service health
echo 🔍 Checking service health...
docker-compose ps

echo.
echo 🎉 Infrastructure services are running!
echo.
echo 📖 Next Steps:
echo 1. Build individual services manually if needed:
echo    - cd services/[service-name] && docker build .
echo 2. Start specific services: docker-compose up [service-name]
echo 3. Start all services: docker-compose up
echo 4. View logs: docker-compose logs -f [service-name]
echo 5. Stop services: docker-compose down
echo.
echo 🔧 Services URLs:
echo    - Gateway: http://localhost:8080
echo    - Service Registry: http://localhost:8761
echo    - PostgreSQL: localhost:5432
echo    - Redis: localhost:6379
echo    - Kafka: localhost:9092
echo    - Grafana: http://localhost:3000 (admin/admin)
echo    - Prometheus: http://localhost:9090
echo.
pause