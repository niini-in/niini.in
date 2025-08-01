# MiniShop Infrastructure

This directory contains all the infrastructure code for deploying MiniShop on Kubernetes using modern DevOps tools.

## Directory Structure

```
infra/
├── argo-cd/                 # Argo CD configurations
│   ├── argocd-namespace.yaml
│   └── minishop-applications.yaml
├── cert-manager/            # SSL/TLS certificate management
│   └── cluster-issuer.yaml
├── docker/                  # Docker configurations
│   ├── grafana/
│   ├── postgres/
│   └── prometheus/
├── helm-charts/             # Helm charts for deployment
│   └── minishop/
│       ├── Chart.yaml
│       ├── values-dev.yaml
│       ├── values-staging.yaml
│       ├── values-prod.yaml
│       └── templates/
├── ingress/                 # NGINX ingress configurations
└── terraform/               # Infrastructure as Code
    ├── aws/
    ├── azure/
    └── gcp/
```

## Quick Start

### 1. Install Argo CD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. Install Cert Manager

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml
kubectl apply -f infra/cert-manager/cluster-issuer.yaml
```

### 3. Install NGINX Ingress Controller

```bash
# For AWS
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/aws/deploy.yaml

# For GCP
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# For Azure
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/do/deploy.yaml
```

### 4. Deploy MiniShop Applications

```bash
kubectl apply -f infra/argo-cd/minishop-applications.yaml
```

## Environment Configurations

### Development (values-dev.yaml)
- **Domain**: dev.minishop.local
- **Resources**: Minimal (0.5 CPU, 512Mi memory)
- **Persistence**: Disabled for cost efficiency
- **Replicas**: 1 per service
- **SSL**: Self-signed/staging certificates

### Staging (values-staging.yaml)
- **Domain**: staging.minishop.com
- **Resources**: Medium (0.75 CPU, 768Mi memory)
- **Persistence**: Enabled with 10-50Gi storage
- **Replicas**: 2 per service with autoscaling
- **SSL**: Let's Encrypt staging certificates

### Production (values-prod.yaml)
- **Domain**: api.minishop.com
- **Resources**: High (1 CPU, 1Gi memory)
- **Persistence**: Enabled with 50-200Gi storage
- **Replicas**: 3 per service with autoscaling
- **SSL**: Let's Encrypt production certificates

## Service Configuration

| Service | Port | Description |
|---------|------|-------------|
| user-service | 8081 | User management and authentication |
| product-service | 8082 | Product catalog and inventory |
| order-service | 8083 | Order processing and management |
| payment-service | 8084 | Payment processing |
| notification-service | 8085 | Email and push notifications |

## Monitoring

### Prometheus Metrics
- **URL**: http://prometheus.minishop.local
- **Port**: 9090
- **Scrape Interval**: 15s

### Grafana Dashboards
- **URL**: http://grafana.minishop.local
- **Username**: admin
- **Password**: (see values file)

## Deployment Commands

### Deploy to Development
```bash
helm install minishop-dev infra/helm-charts/minishop -f infra/helm-charts/minishop/values-dev.yaml
```

### Deploy to Staging
```bash
helm install minishop-staging infra/helm-charts/minishop -f infra/helm-charts/minishop/values-staging.yaml
```

### Deploy to Production
```bash
helm install minishop-prod infra/helm-charts/minishop -f infra/helm-charts/minishop/values-prod.yaml
```

## Upgrade Commands

```bash
# Development
helm upgrade minishop-dev infra/helm-charts/minishop -f infra/helm-charts/minishop/values-dev.yaml

# Staging
helm upgrade minishop-staging infra/helm-charts/minishop -f infra/helm-charts/minishop/values-staging.yaml

# Production
helm upgrade minishop-prod infra/helm-charts/minishop -f infra/helm-charts/minishop/values-prod.yaml
```

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n minishop-dev
kubectl describe pod <pod-name> -n minishop-dev
```

### Check Service Endpoints
```bash
kubectl get endpoints -n minishop-dev
```

### Check Ingress
```bash
kubectl get ingress -n minishop-dev
kubectl describe ingress minishop-dev -n minishop-dev
```

### Check Certificate Status
```bash
kubectl get certificates -n minishop-dev
kubectl describe certificate minishop-tls-dev -n minishop-dev
```

## Security Best Practices

1. **Secrets Management**: Use Kubernetes secrets for sensitive data
2. **Network Policies**: Implement network segmentation
3. **RBAC**: Use role-based access control
4. **Pod Security Standards**: Enforce security contexts
5. **Image Scanning**: Scan container images for vulnerabilities

## Cost Optimization

### Development Environment
- Disable persistence for databases
- Use single replicas
- Use local Docker registry

### Staging Environment
- Enable persistence for realistic testing
- Use 2 replicas for high availability
- Use staging certificates

### Production Environment
- Enable all persistence
- Use 3+ replicas
- Use production certificates
- Enable autoscaling

## Backup and Recovery

### Database Backups
```bash
# PostgreSQL backup
kubectl exec -it <postgres-pod> -- pg_dump -U postgres minishop_prod > backup.sql

# Redis backup
kubectl exec -it <redis-pod> -- redis-cli BGSAVE
```

### Persistent Volume Snapshots
```bash
# Create snapshot
kubectl apply -f backup/snapshot.yaml

# Restore from snapshot
kubectl apply -f backup/restore.yaml
```