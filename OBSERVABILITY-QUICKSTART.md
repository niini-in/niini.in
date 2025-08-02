# MiniShop Observability Quick Start

🎯 **Goal**: Get comprehensive observability for MiniShop running in under 5 minutes.

## 🚀 30-Second Setup

1. **Start the observability stack:**
   ```powershell
   .\scripts\setup-observability.ps1
   ```

2. **Access your dashboards:**
   - **Grafana**: http://localhost:3000 (admin/admin)
   - **Prometheus**: http://localhost:9090
   - **Jaeger**: http://localhost:16686

## 📊 What's Included

### Services
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **Jaeger**: Distributed tracing
- **Loki**: Log aggregation
- **Alertmanager**: Alert routing and notifications
- **Node Exporter**: System metrics

### Pre-configured Dashboards
- **MiniShop Overview**: Service health, request rates, error rates, latency
- **Infrastructure**: CPU, memory, disk usage
- **Business Metrics**: Orders, cart additions, user registrations

### Alerts
- Service down
- High error rate (>5%)
- High latency (>1s P95)
- High memory usage (>512MB)
- Database connection issues

## 🔧 Service Configuration

### Spring Boot Services (User, Order, Gateway)
Add to `application.yml`:
```yaml
management:
  endpoints.web.exposure.include: health,info,metrics,prometheus
  endpoint.prometheus.enabled: true
  metrics.export.prometheus.enabled: true
```

### Node.js Services (Product, Payment)
Install: `npm install prom-client express-prom-bundle`

### Python Services (Notification)
Install: `pip install prometheus-client`

## 📈 Key Metrics

| Metric | Description | Threshold |
|--------|-------------|-----------|
| `up` | Service health | Alert if 0 |
| `http_requests_total` | Request volume | Monitor trends |
| `http_request_duration_seconds` | Response time | Alert if P95 > 1s |
| `minishop_orders_total` | Business KPI | Monitor daily |
| `process_resident_memory_bytes` | Memory usage | Alert if >512MB |

## 🎯 Quick Actions

### View Service Health
1. Open Grafana: http://localhost:3000
2. Go to "MiniShop Overview" dashboard
3. Check the "Service Health" panel

### Check Recent Traces
1. Open Jaeger: http://localhost:16686
2. Select a service from dropdown
3. Click "Find Traces"

### Investigate Alerts
1. Open Alertmanager: http://localhost:9093
2. View active alerts
3. Check alert details and labels

## 🛠️ Troubleshooting

### No data in Grafana?
```bash
# Check if Prometheus is scraping targets
curl http://localhost:9090/api/v1/targets

# Check service metrics endpoints
curl http://localhost:8081/actuator/prometheus
```

### Service not appearing?
```bash
# Check Docker logs
docker-compose -f docker-compose.observability.yml logs prometheus

# Verify service is running
docker-compose ps
```

### Reset everything
```bash
.\scripts\setup-observability.ps1 -Reset
```

## 📚 Next Steps

1. **Customize alerts** in `prometheus/alert-rules.yml`
2. **Add custom dashboards** in `grafana/dashboards/`
3. **Configure log shipping** with Loki
4. **Set up email notifications** in Alertmanager
5. **Add business metrics** to your services

## 🔗 Useful URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Grafana | http://localhost:3000 | Main dashboard |
| Prometheus | http://localhost:9090 | Raw metrics |
| Jaeger | http://localhost:16686 | Distributed tracing |
| Alertmanager | http://localhost:9093 | Alert management |
| Loki | http://localhost:3100 | Log aggregation |

## 💡 Pro Tips

- **Pin important dashboards** in Grafana
- **Set up Slack notifications** for critical alerts
- **Use recording rules** for expensive queries
- **Create custom alerts** for business KPIs
- **Monitor during deployments** with Jaeger

---

**Need help?** Check the full documentation in `docs/observability.md` and `docs/metrics-setup.md`