#!/usr/bin/env pwsh

<#
.SYNOPSIS
    MiniShop Observability Setup Script
.DESCRIPTION
    This script sets up the complete observability stack for MiniShop including
    Prometheus, Grafana, Jaeger, Loki, and Alertmanager.
.PARAMETER Environment
    The environment to set up (local, staging, production)
.PARAMETER Reset
    Reset all data volumes before starting
#>

param(
    [Parameter()]
    [ValidateSet('local', 'staging', 'production')]
    [string]$Environment = 'local',
    
    [Parameter()]
    [switch]$Reset
)

$ErrorActionPreference = "Stop"

Write-Host @"
   __  ___ _       ___           __
  /  |/  /(_)____ / (_)___  ____/ /___ __   _____
 / /|_/ // // __// // / _ \/ __  // _ \ | / / _ \
/ /  / // // /__ / // /  __/ /_/ //  __/ |/ /  __/
/_/  /_//_/ \___//_//_/\___/\__,_/ \___/|___/\___/

Observability Setup - Environment: $Environment
"@ -ForegroundColor Cyan

Write-Host ""

# Check prerequisites
Write-Host "🔍 Checking prerequisites..." -ForegroundColor Yellow

# Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker is not installed. Please install Docker Desktop." -ForegroundColor Red
    exit 1
}

try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

# Check Docker Compose
if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker Compose is not installed." -ForegroundColor Red
    exit 1
}

Write-Host "✅ All prerequisites met" -ForegroundColor Green

# Create data directories
Write-Host ""
Write-Host "📁 Creating data directories..." -ForegroundColor Yellow

$baseDir = "infra/docker"
$dirs = @(
    "$baseDir/prometheus/data",
    "$baseDir/grafana/data",
    "$baseDir/loki/data",
    "$baseDir/alertmanager/data",
    "$baseDir/jaeger/data"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $PWD.Path $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Force -Path $fullPath | Out-Null
        Write-Host "  📂 Created: $dir" -ForegroundColor Green
    } else {
        Write-Host "  ✅ Exists: $dir" -ForegroundColor Gray
    }
}

# Reset data if requested
if ($Reset) {
    Write-Host ""
    Write-Host "🗑️  Resetting data volumes..." -ForegroundColor Red
    
    $confirm = Read-Host "This will delete all existing observability data. Continue? (y/N)"
    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        docker-compose -f docker-compose.observability.yml down -v
        foreach ($dir in $dirs) {
            $fullPath = Join-Path $PWD.Path $dir
            if (Test-Path $fullPath) {
                Remove-Item -Recurse -Force $fullPath
                New-Item -ItemType Directory -Force -Path $fullPath | Out-Null
                Write-Host "  🧹 Reset: $dir" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "❌ Reset cancelled" -ForegroundColor Gray
    }
}

# Set environment variables based on environment
Write-Host ""
Write-Host "⚙️  Configuring environment..." -ForegroundColor Yellow

$env:ENVIRONMENT = $Environment
$env:GRAFANA_ADMIN_PASSWORD = if ($Environment -eq 'production') { 
    Read-Host "Enter Grafana admin password" -AsSecureString | ConvertFrom-SecureString -AsPlainText 
} else { 
    "admin" 
}

# Pull latest images
Write-Host ""
Write-Host "📦 Pulling latest images..." -ForegroundColor Yellow
docker-compose -f docker-compose.observability.yml pull

# Start the stack
Write-Host ""
Write-Host "🚀 Starting observability stack..." -ForegroundColor Green

try {
    docker-compose -f docker-compose.observability.yml up -d
    
    Write-Host ""
    Write-Host "✅ Observability stack started successfully!" -ForegroundColor Green
    Write-Host ""
    
    # Wait for services to be ready
    Write-Host "⏳ Waiting for services to be ready..." -ForegroundColor Yellow
    $services = @(
        @{ name = "Prometheus"; url = "http://localhost:9090"; timeout = 30 },
        @{ name = "Grafana"; url = "http://localhost:3000"; timeout = 30 },
        @{ name = "Jaeger"; url = "http://localhost:16686"; timeout = 30 }
    )
    
    foreach ($service in $services) {
        Write-Host "  🔍 Checking $($service.name)..." -ForegroundColor Gray
        $startTime = Get-Date
        $ready = $false
        
        while (-not $ready -and ((Get-Date) - $startTime).TotalSeconds -lt $service.timeout) {
            try {
                $response = Invoke-WebRequest -Uri $service.url -UseBasicParsing -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 200) {
                    Write-Host "  ✅ $($service.name) is ready" -ForegroundColor Green
                    $ready = $true
                    break
                }
            } catch {
                Start-Sleep -Seconds 2
            }
        }
        
        if (-not $ready) {
            Write-Host "  ⚠️  $($service.name) might not be ready yet" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "🌐 Access URLs:" -ForegroundColor Cyan
    Write-Host "  🎯 Grafana Dashboard: http://localhost:3000" -ForegroundColor White
    Write-Host "     Username: admin" -ForegroundColor Gray
    Write-Host "     Password: $($env:GRAFANA_ADMIN_PASSWORD)" -ForegroundColor Gray
    Write-Host "  📊 Prometheus: http://localhost:9090" -ForegroundColor White
    Write-Host "  🔍 Jaeger Tracing: http://localhost:16686" -ForegroundColor White
    Write-Host "  🚨 Alertmanager: http://localhost:9093" -ForegroundColor White
    Write-Host ""
    
    Write-Host "📚 Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Open Grafana at http://localhost:3000" -ForegroundColor White
    Write-Host "  2. Import the MiniShop dashboard" -ForegroundColor White
    Write-Host "  3. Configure alerts in Alertmanager" -ForegroundColor White
    Write-Host "  4. View traces in Jaeger" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Useful commands:" -ForegroundColor Cyan
    Write-Host "  • View logs: docker-compose -f docker-compose.observability.yml logs -f [service]" -ForegroundColor Gray
    Write-Host "  • Stop stack: docker-compose -f docker-compose.observability.yml down" -ForegroundColor Gray
    Write-Host "  • Reset data: .\scripts\setup-observability.ps1 -Reset" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Error starting observability stack: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Check logs with: docker-compose -f docker-compose.observability.yml logs" -ForegroundColor Yellow
    exit 1
}