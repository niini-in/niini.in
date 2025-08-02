# MiniShop Metrics Setup Guide

This guide provides step-by-step instructions for setting up comprehensive metrics collection across all MiniShop services.

## Overview

MiniShop uses Prometheus for metrics collection, Grafana for visualization, and includes custom dashboards for:
- Service health monitoring
- Request latency and throughput
- Error rates and status codes
- Business metrics (orders, cart additions)
- Infrastructure metrics (CPU, memory, disk)

## Service Configuration

### 1. User Service (Spring Boot)

Add to `application.yml`:

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    prometheus:
      enabled: true
  metrics:
    export:
      prometheus:
        enabled: true
    distribution:
      percentiles-histogram:
        http.server.requests: true
```

### 2. Product Service (Node.js)

Install dependencies:
```bash
npm install prom-client express-prom-bundle
```

Add to your main app file:
```javascript
const promBundle = require('express-prom-bundle');
const client = require('prom-client');

// Create a Registry to register the metrics
const register = new client.Registry();

// Add a default label and register it with all metrics
register.setDefaultLabels({
  app: 'product-service'
});

// Enable the collection of default metrics
client.collectDefaultMetrics({ register });

// Create a histogram metric
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

// Create a counter for total requests
const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

// Middleware to collect metrics
app.use(promBundle({
  includeMethod: true,
  includePath: true,
  promRegistry: register
}));

// Metrics endpoint
app.get('/metrics', (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(register.metrics());
});
```

### 3. Order Service (Spring Boot)

Same as User Service configuration, plus custom business metrics:

```java
@Component
public class OrderMetrics {
    
    private final MeterRegistry registry;
    private final Counter orderCounter;
    private final Timer orderProcessingTimer;
    
    public OrderMetrics(MeterRegistry registry) {
        this.registry = registry;
        this.orderCounter = Counter.builder("minishop.orders.total")
            .description("Total number of orders")
            .register(registry);
        this.orderProcessingTimer = Timer.builder("minishop.order.processing.time")
            .description("Time taken to process an order")
            .register(registry);
    }
    
    public void recordOrder() {
        orderCounter.increment();
    }
    
    public void recordOrderProcessingTime(Duration duration) {
        orderProcessingTimer.record(duration);
    }
}
```

### 4. Payment Service (Python)

Install dependencies:
```bash
pip install prometheus-client
```

Add to your Flask app:
```python
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from prometheus_client.core import CollectorRegistry
import time

registry = CollectorRegistry()

# Create metrics
http_requests_total = Counter(
    'http_requests_total', 
    'Total HTTP requests',
    ['method', 'endpoint', 'status'],
    registry=registry
)

http_request_duration = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration',
    ['method', 'endpoint'],
    registry=registry
)

payment_success_total = Counter(
    'minishop_payment_success_total',
    'Total successful payments',
    registry=registry
)

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    duration = time.time() - request.start_time
    http_requests_total.labels(
        method=request.method,
        endpoint=request.endpoint,
        status=response.status_code
    ).inc()
    http_request_duration.labels(
        method=request.method,
        endpoint=request.endpoint
    ).observe(duration)
    return response

@app.route('/metrics')
def metrics():
    return generate_latest(registry), 200, {'Content-Type': CONTENT_TYPE_LATEST}
```

## Running the Observability Stack

### Quick Start

1. **Start the observability services:**
   ```bash
   # From project root
   ./scripts/start-observability.ps1
   ```

2. **Verify services are running:**
   ```bash
   docker-compose -f docker-compose.observability.yml ps
   ```

3. **Access the dashboards:**
   - **Grafana**: http://localhost:3000 (admin/admin)
   - **Prometheus**: http://localhost:9090
   - **Jaeger**: http://localhost:16686
   - **Alertmanager**: http://localhost:9093

### Importing Dashboards

The Grafana dashboards are automatically provisioned. You can also manually import them:

1. Go to Grafana → Dashboards → Import
2. Upload the JSON files from `infra/docker/grafana/dashboards/`
3. Select the Prometheus datasource

## Key Metrics to Monitor

### Service Health
- Service availability (up/down)
- Request rate per service
- Error rate per service
- P95/P99 latency per service

### Business Metrics
- Order rate
- Cart abandonment rate
- Payment success rate
- User registration rate

### Infrastructure
- CPU usage per service
- Memory usage per service
- Disk I/O
- Network throughput

### Database
- Active connections
- Query duration
- Lock wait time
- Cache hit ratio

## Alerting Rules

The following alerts are configured in `prometheus/alert-rules.yml`:

- **ServiceDown**: Any service is down for more than 1 minute
- **HighErrorRate**: Error rate above 5% for 5 minutes
- **HighLatency**: P95 latency above 1 second for 5 minutes
- **HighMemoryUsage**: Memory usage above 512MB for 10 minutes
- **DatabaseConnectionsHigh**: PostgreSQL connections above 80
- **LowOrderVolume**: Order volume below 10 per hour
- **HighCartAbandonment**: Cart abandonment rate above 70%

## Custom Metrics

### Adding Custom Metrics

Each service can add custom business metrics. Example for tracking user registrations:

```java
// Java/Spring Boot
Counter.builder("minishop.user.registrations")
    .description("Total user registrations")
    .tag("source", "web")
    .register(registry)
    .increment();
```

```javascript
// Node.js
const userRegistrations = new client.Counter({
  name: 'minishop_user_registrations_total',
  help: 'Total user registrations',
  labelNames: ['source'],
  registers: [register]
});
userRegistrations.inc({ source: 'web' });
```

```python
# Python
user_registrations = Counter(
    'minishop_user_registrations_total',
    'Total user registrations',
    ['source'],
    registry=registry
)
user_registrations.labels(source='web').inc()
```

## Troubleshooting

### Common Issues

1. **No metrics in Grafana**: Check if Prometheus is scraping the targets
2. **High cardinality**: Use proper label cardinality limits
3. **Memory issues**: Monitor Prometheus memory usage with large datasets
4. **Slow queries**: Use recording rules for expensive queries

### Debug Commands

```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# Check service metrics
curl http://localhost:8081/actuator/prometheus  # User service
curl http://localhost:8082/metrics              # Product service

# Check logs
docker-compose -f docker-compose.observability.yml logs prometheus
docker-compose -f docker-compose.observability.yml logs grafana
```