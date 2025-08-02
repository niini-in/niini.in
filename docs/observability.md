# MiniShop Observability Guide

## Overview

This document outlines the comprehensive observability strategy for the MiniShop e-commerce platform, covering monitoring, logging, tracing, and alerting. A robust observability stack is essential for maintaining system reliability, troubleshooting issues, and understanding user behavior in a microservices architecture.

## 🎯 Observability Pillars

### 1. Metrics (The Four Golden Signals)
- **Latency**: Time taken to serve requests
- **Traffic**: How much demand is being placed on your system
- **Errors**: Rate of requests that fail
- **Saturation**: How "full" your service is

### 2. Logging
Structured, centralized logging with correlation IDs

### 3. Tracing
End-to-end request tracking across microservices

### 4. Alerting
Proactive notifications based on SLOs and SLIs

## 🛠️ Technology Stack

### Metrics Collection
- **Prometheus**: Time-series database for metrics
- **Grafana**: Visualization and dashboards
- **Service Exporters**: Application-specific metrics
- **Node Exporter**: System metrics

### Logging Stack
- **Loki**: Log aggregation system
- **Promtail**: Log collection agent
- **Grafana**: Log visualization

### Distributed Tracing
- **Jaeger**: Full distributed tracing
- **OpenTelemetry**: Instrumentation libraries

### Alerting
- **Alertmanager**: Alert routing and notifications
- **Slack/Teams**: Team notifications
- **PagerDuty**: On-call management

## 📊 Core Metrics Implementation

### Service-Level Metrics

#### HTTP Request Metrics
- `http_requests_total` - Total HTTP requests
- `http_request_duration_seconds` - Request latency histogram
- `http_requests_in_progress` - Current active requests
- `http_response_size_bytes` - Response size

#### Business Metrics
- `minishop_orders_total` - Total orders processed
- `minishop_order_value_total` - Total order value
- `minishop_users_active` - Active users count
- `minishop_products_viewed_total` - Product views

#### System Metrics
- `process_cpu_seconds_total` - CPU usage
- `process_resident_memory_bytes` - Memory usage
- `go_goroutines` / `jvm_threads_current` - Active threads
- `process_open_fds` - File descriptors

### Database Metrics
- `postgresql_connections_active` - Active DB connections
- `postgresql_query_duration_seconds` - Query latency
- `postgresql_transactions_total` - Transaction count
- `redis_connected_clients` - Redis connections

### Message Queue Metrics
- `kafka_consumer_lag_sum` - Consumer lag
- `kafka_broker_messages_in_rate` - Message ingestion rate
- `kafka_topic_partitions` - Topic partition count

## 📈 Grafana Dashboards

### 1. System Overview Dashboard

**Dashboard ID**: `minishop-system-overview`

**Key Panels**:
- Service Health Overview (UP/DOWN status)
- Request Rate by Service
- Error Rate by Service  
- P95 Latency by Service
- Resource Utilization (CPU/Memory)
- Active Connections

**PromQL Queries**:
```promql
# Service Health
up{job=~".*service"}

# Request Rate
sum(rate(http_requests_total[5m])) by (service)

# Error Rate
sum(rate(http_requests_total{status=~"5.."}[5m])) by (service) / 
sum(rate(http_requests_total[5m])) by (service)

# P95 Latency
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (service, le))
```

### 2. Service-Specific Dashboards

#### User Service Dashboard
```json
{
  "dashboard": {
    "title": "User Service Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{service=\"user-service\"}[5m]))"
          }
        ]
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{service=\"user-service\",status=~\"5..\"}[5m])) / sum(rate(http_requests_total{service=\"user-service\"}[5m]))"
          }
        ]
      },
      {
        "title": "P95 Response Time",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{service=\"user-service\"}[5m])) by (le))"
          }
        ]
      },
      {
        "title": "Active Users",
        "targets": [
          {
            "expr": "minishop_users_active"
          }
        ]
      }
    ]
  }
}
```

#### Product Service Dashboard
```json
{
  "dashboard": {
    "title": "Product Service Metrics",
    "panels": [
      {
        "title": "Product Views Rate",
        "targets": [
          {
            "expr": "sum(rate(minishop_products_viewed_total[5m]))"
          }
        ]
      },
      {
        "title": "Inventory Levels",
        "targets": [
          {
            "expr": "minishop_product_inventory_count"
          }
        ]
      },
      {
        "title": "Search Response Time",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{service=\"product-service\",path=~\".*search.*\"}[5m])) by (le))"
          }
        ]
      }
    ]
  }
}
```

### 3. Business Metrics Dashboard

**Key Business KPIs**:
- Daily Active Users (DAU)
- Order Conversion Rate
- Average Order Value (AOV)
- Cart Abandonment Rate
- Revenue per Day

**PromQL Queries**:
```promql
# Daily Active Users
max_over_time(minishop_users_active[1d])

# Order Conversion Rate
sum(rate(minishop_orders_total[1d])) / sum(rate(minishop_users_active[1d]))

# Average Order Value
sum(rate(minishop_order_value_total[1d])) / sum(rate(minishop_orders_total[1d]))
```

### 4. Infrastructure Dashboard

**Components Monitored**:
- PostgreSQL Performance
- Redis Cache Hit Rates
- Kafka Consumer Lag
- Container Resource Usage

## 🔍 Logging Implementation

### Structured Log Format

All services implement JSON structured logging:

```json
{
  "timestamp": "2024-01-15T14:22:10.123Z",
  "level": "INFO",
  "service": "user-service",
  "trace_id": "7a3f1b2c4d5e6f7a",
  "span_id": "8b4c2d3e5f6a7b8c",
  "user_id": "user123",
  "request_id": "req456",
  "message": "User login successful",
  "method": "POST",
  "path": "/api/users/login",
  "status": 200,
  "duration_ms": 45,
  "metadata": {
    "ip": "192.168.1.100",
    "user_agent": "Mozilla/5.0..."
  }
}
```

### Log Levels and Usage

- **ERROR**: Critical failures requiring immediate attention
- **WARN**: Potential issues or degraded performance
- **INFO**: Normal operational events
- **DEBUG**: Detailed troubleshooting information (development only)

### Log Aggregation with Loki

**Loki Configuration**:
```yaml
# loki-config.yml
auth_enabled: false
server:
  http_listen_port: 3100
common:
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory
query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        max_size_mb: 100
```

## 🔗 Distributed Tracing

### Jaeger Configuration

**Jaeger Setup**:
```yaml
# docker-compose.yml addition
services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"
      - "14268:14268"
    environment:
      - COLLECTOR_OTLP_ENABLED=true
```

### Trace Context Propagation

**HTTP Headers**:
- `uber-trace-id`: Jaeger trace context
- `x-request-id`: Request correlation ID
- `x-user-id`: User identification

### Key Spans to Instrument

1. **API Gateway**
   - Request routing
   - Authentication/authorization
   - Rate limiting

2. **Service Entry Points**
   - HTTP handlers
   - Message consumers
   - Scheduled jobs

3. **Database Operations**
   - Query execution time
   - Connection pool usage
   - Transaction duration

4. **External API Calls**
   - Payment gateway calls
   - Email service calls
   - Third-party integrations

## 🚨 Alerting Rules

### Service-Level Alerts

#### Critical Alerts (24/7)
```yaml
# alert-rules.yml
groups:
- name: minishop-critical
  rules:
  - alert: ServiceDown
    expr: up{job=~".*service"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Service {{ $labels.service }} is down"
      description: "{{ $labels.service }} has been down for more than 1 minute"

  - alert: HighErrorRate
    expr: |
      (
        sum(rate(http_requests_total{status=~"5.."}[5m])) by (service)
        /
        sum(rate(http_requests_total[5m])) by (service)
      ) > 0.05
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High error rate detected"
      description: "{{ $labels.service }} has error rate above 5%"

  - alert: HighLatency
    expr: |
      histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (service, le)) > 1
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High latency detected"
      description: "{{ $labels.service }} 95th percentile latency is above 1 second"
```

#### Warning Alerts (Business Hours)
```yaml
- name: minishop-warning
  rules:
  - alert: HighMemoryUsage
    expr: process_resident_memory_bytes / 1024 / 1024 > 512
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "High memory usage"
      description: "{{ $labels.service }} memory usage is above 512MB"

  - alert: DatabaseConnectionsHigh
    expr: postgresql_connections_active > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High database connections"
      description: "PostgreSQL has {{ $value }} active connections"
```

### Business-Level Alerts

```yaml
  - alert: LowOrderVolume
    expr: sum(rate(minishop_orders_total[1h])) < 10
    for: 30m
    labels:
      severity: warning
    annotations:
      summary: "Low order volume"
      description: "Order volume is below 10 orders per hour"

  - alert: HighCartAbandonment
    expr: |
      (
        1 - (sum(rate(minishop_orders_total[1h])) / sum(rate(minishop_cart_additions_total[1h])))
      ) > 0.7
    for: 1h
    labels:
      severity: warning
    annotations:
      summary: "High cart abandonment rate"
      description: "Cart abandonment rate is above 70%"
```

## 🚀 Deployment Guide

### Local Development Setup

**Step 1: Start Observability Stack**
```bash
# Start Prometheus, Grafana, Jaeger, and Loki
docker-compose -f docker-compose.observability.yml up -d
```

**Step 2: Access Dashboards**
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Jaeger**: http://localhost:16686
- **Alertmanager**: http://localhost:9093

### Production Deployment

**Step 1: Kubernetes Manifests**
```yaml
# monitoring-namespace.yml
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
  labels:
    name: monitoring
```

**Step 2: Prometheus Configuration**
```yaml
# prometheus-config.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert-rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'user-service'
    static_configs:
      - targets: ['user-service:8081']
    metrics_path: '/actuator/prometheus'
  
  - job_name: 'product-service'
    static_configs:
      - targets: ['product-service:8082']
    metrics_path: '/metrics'
  
  - job_name: 'order-service'
    static_configs:
      - targets: ['order-service:8083']
    metrics_path: '/actuator/prometheus'
  
  - job_name: 'payment-service'
    static_configs:
      - targets: ['payment-service:8084']
    metrics_path: '/metrics'
  
  - job_name: 'notification-service'
    static_configs:
      - targets: ['notification-service:8085']
    metrics_path: '/metrics'
```

## 📋 Monitoring Checklist

### Pre-Production
- [ ] All services expose `/metrics` endpoint
- [ ] Prometheus scrape configs updated
- [ ] Grafana dashboards imported
- [ ] Alert rules configured and tested
- [ ] Jaeger tracing enabled
- [ ] Log aggregation configured

### Post-Deployment
- [ ] Verify all services appear in Prometheus targets
- [ ] Test alert notifications
- [ ] Validate trace collection
- [ ] Check log ingestion
- [ ] Review dashboard accuracy
- [ ] Set up SLO/SLI tracking

## 🔧 Troubleshooting

### Common Issues

**1. Metrics Not Appearing**
```bash
# Check service endpoints
curl http://localhost:8081/actuator/prometheus

# Verify Prometheus targets
http://localhost:9090/targets
```

**2. High Cardinality**
- Limit label values
- Use recording rules for expensive queries
- Implement metric expiration

**3. Alert Fatigue**
- Tune alert thresholds
- Implement alert routing
- Use alert inhibition rules

### Performance Optimization

**1. Prometheus**
- Use recording rules for complex queries
- Implement proper retention policies
- Configure appropriate scrape intervals

**2. Grafana**
- Use query caching
- Optimize dashboard queries
- Implement user-specific dashboards

## 📊 SLO/SLI Examples

### Service Level Objectives

| Service | SLO | SLI | Target |
|---------|-----|-----|--------|
| User Service | 99.9% uptime | HTTP 200 responses | 99.9% |
| Product Service | <500ms latency | P95 response time | 95% < 500ms |
| Order Service | 99.5% success rate | Successful order creation | 99.5% |
| Payment Service | 99.9% availability | Payment processing success | 99.9% |

### Error Budgets
- User Service: 43.2 minutes/month downtime
- Product Service: 21.6 minutes/month >500ms latency
- Order Service: 21.6 minutes/month failed orders

## 🔄 Maintenance

### Regular Tasks
- **Daily**: Review critical alerts
- **Weekly**: Check SLO compliance
- **Monthly**: Update dashboards and alert rules
- **Quarterly**: Review and update SLOs

### Capacity Planning
- Monitor resource trends
- Plan for traffic growth
- Update alert thresholds
- Scale infrastructure proactively