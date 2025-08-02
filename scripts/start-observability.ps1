#!/usr/bin/env pwsh

Write-Host "🚀 Starting MiniShop Observability Stack..." -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Create necessary directories if they don't exist
$dirs = @(
    "infra/docker/prometheus/data",
    "infra/docker/grafana/data",
    "infra/docker/loki/data",
    "infra/docker/alertmanager/data"
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "📁 Created directory: $dir" -ForegroundColor Yellow
    }
}

# Start the observability stack
docker-compose -f docker-compose.observability.yml up -d

Write-Host ""
Write-Host "📊 Observability Stack Started!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Access URLs:" -ForegroundColor Cyan
Write-Host "  • Grafana: http://localhost:3000 (admin/admin)" -ForegroundColor White
Write-Host "  • Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "  • Jaeger: http://localhost:16686" -ForegroundColor White
Write-Host "  • Alertmanager: http://localhost:9093" -ForegroundColor White
Write-Host ""
Write-Host "📋 To stop the stack, run: docker-compose -f docker-compose.observability.yml down" -ForegroundColor Yellow