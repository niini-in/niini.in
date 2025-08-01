# MiniShop Deployment Guide

## Overview

This guide provides detailed instructions for deploying the MiniShop e-commerce platform in various environments, from local development to production Kubernetes clusters.

## Prerequisites

### Development Environment

- Docker and Docker Compose
- Kubernetes CLI (kubectl)
- Helm 3
- Git
- JDK 17+ (for Java services)
- Go 1.19+ (for Go services)
- Python 3.9+ (for Python services)
- Node.js 18+ (for Node.js services)

### Production Environment

- Kubernetes cluster (EKS, GKE, or AKS)
- ArgoCD installed on the cluster
- Helm 3
- Domain with DNS configured for `niini.in`
- TLS certificates (or cert-manager for automatic provisioning)

## Local Development

### Using Docker Compose

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/minishop.git
   cd minishop
   ```

2. Start all services:
   ```bash
   make up
   ```

3. Start specific services:
   ```bash
   make up service=user-service,product-service
   ```

4. View logs:
   ```bash
   make logs service=user-service
   ```

5. Stop all services:
   ```bash
   make down
   ```

### Local Kubernetes (Minikube/Kind)

1. Start local Kubernetes cluster:
   ```bash
   minikube start --memory=8g --cpus=4
   # OR
   kind create cluster --name minishop
   ```

2. Deploy services:
   ```bash
   make k8s-deploy env=local
   ```

3. Access services:
   ```bash
   # For Minikube
   minikube service list
   # For Kind
   kubectl port-forward svc/api-gateway 8080:80
   ```

## Cloud Deployment

### Infrastructure Provisioning

#### AWS (EKS)

1. Configure AWS credentials:
   ```bash
   aws configure
   ```

2. Provision infrastructure:
   ```bash
   cd infra/terraform/aws
   terraform init
   terraform apply
   ```

3. Configure kubectl:
   ```bash
   aws eks update-kubeconfig --name minishop-cluster --region us-west-2
   ```

#### GCP (GKE)

1. Configure GCP credentials:
   ```bash
   gcloud auth login
   gcloud config set project your-project-id
   ```

2. Provision infrastructure:
   ```bash
   cd infra/terraform/gcp
   terraform init
   terraform apply
   ```

3. Configure kubectl:
   ```bash
   gcloud container clusters get-credentials minishop-cluster --region us-central1
   ```

#### Azure (AKS)

1. Configure Azure credentials:
   ```bash
   az login
   ```

2. Provision infrastructure:
   ```bash
   cd infra/terraform/azure
   terraform init
   terraform apply
   ```

3. Configure kubectl:
   ```bash
   az aks get-credentials --resource-group minishop-rg --name minishop-cluster
   ```

### ArgoCD Setup

1. Install ArgoCD:
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

2. Access ArgoCD UI:
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

3. Get initial admin password:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

4. Apply ArgoCD application manifests:
   ```bash
   kubectl apply -f infra/argo-cd/applications/
   ```

### Manual Deployment (Without GitOps)

1. Build and push Docker images:
   ```bash
   make docker-build-push
   ```

2. Deploy using Helm:
   ```bash
   make helm-deploy env=prod
   ```

## Domain and TLS Setup

### Domain Configuration

1. Configure DNS records for `niini.in` domains:
   - `api.niini.in` → API Gateway LoadBalancer IP/CNAME
   - `www.niini.in` → Web Application LoadBalancer IP/CNAME
   - `admin.niini.in` → Admin Dashboard LoadBalancer IP/CNAME
   - `metrics.niini.in` → Grafana LoadBalancer IP/CNAME

### TLS Certificate Management

1. Install cert-manager:
   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
   ```

2. Create ClusterIssuer for Let's Encrypt:
   ```bash
   kubectl apply -f infra/cert-manager/cluster-issuer.yaml
   ```

3. Certificates will be automatically provisioned when Ingress resources are created.

## Monitoring and Observability

### Prometheus and Grafana

1. Install Prometheus Operator:
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
   ```

2. Access Grafana:
   ```bash
   kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80
   ```
   Default credentials: admin/prom-operator

### Distributed Tracing (Jaeger)

1. Install Jaeger Operator:
   ```bash
   kubectl create namespace observability
   kubectl apply -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.41.0/jaeger-operator.yaml -n observability
   ```

2. Deploy Jaeger instance:
   ```bash
   kubectl apply -f infra/observability/jaeger.yaml
   ```

3. Access Jaeger UI:
   ```bash
   kubectl port-forward svc/jaeger-query -n observability 16686:16686
   ```

## Scaling and High Availability

### Horizontal Pod Autoscaling

1. Configure HPA for services:
   ```bash
   kubectl apply -f infra/kubernetes/hpa/
   ```

### Cluster Autoscaling

Cluster autoscaling is configured through the infrastructure provisioning (Terraform).

## Backup and Disaster Recovery

### Database Backups

1. Configure automated backups:
   ```bash
   kubectl apply -f infra/kubernetes/backup/
   ```

### Disaster Recovery

Refer to the disaster recovery documentation for detailed procedures.

## Troubleshooting

### Common Issues

1. **Services not starting**: Check logs with `kubectl logs -n minishop deployment/service-name`
2. **Database connection issues**: Verify secrets and connection strings
3. **TLS certificate errors**: Check cert-manager logs and certificate resources

### Getting Support

For additional support, contact the platform team or open an issue in the GitHub repository.

## Maintenance

### Upgrading Services

1. Update version in CI/CD pipeline or manually trigger a build
2. ArgoCD will automatically sync the changes

### Database Migrations

Database migrations are handled automatically during service startup.

## Security Considerations

- Regularly update dependencies
- Rotate secrets periodically
- Review Kubernetes RBAC permissions
- Implement network policies
- Run security scans on container images