# MiniShop GitOps Guide

## Overview

This document outlines the GitOps workflow for the MiniShop e-commerce platform. GitOps is a set of practices that leverages Git as the single source of truth for declarative infrastructure and applications, automating the deployment process through Git operations.

## GitOps Principles

1. **Declarative Configuration**: All system configurations are defined declaratively
2. **Version Controlled**: All configurations are stored in Git
3. **Automated Synchronization**: Changes to Git are automatically applied to the system
4. **Continuous Verification**: System state is continuously verified against Git

## Repository Structure

The MiniShop platform follows a monorepo approach with the following structure:

```
minishop/
├── services/           # Application code for microservices
├── infra/              # Infrastructure as code
│   ├── helm-charts/    # Helm charts for Kubernetes deployments
│   ├── terraform/      # Terraform modules for cloud infrastructure
│   └── argo-cd/        # ArgoCD configuration
└── .github/            # GitHub Actions workflows
```

## GitOps Workflow

### Development Workflow

1. **Feature Development**:
   - Developer creates a feature branch from `main`
   - Implements changes to application code and/or infrastructure
   - Submits a pull request (PR) to `main`

2. **Continuous Integration**:
   - GitHub Actions runs tests, linting, and security scans on the PR
   - Builds Docker images with unique tags (e.g., `{service}:{branch}-{commit_sha}`)
   - Pushes images to container registry

3. **Review and Approval**:
   - Code review by team members
   - Automated checks must pass
   - Approval required before merging

4. **Merge to Main**:
   - PR is merged to `main`
   - CI pipeline builds final images with tags:
     - `{service}:latest`
     - `{service}:{commit_sha}`
     - `{service}:{semver}` (if tagged release)

### Deployment Workflow

1. **Image Update**:
   - CI pipeline updates Helm values with new image tags
   - Commits changes to the Git repository

2. **ArgoCD Synchronization**:
   - ArgoCD detects changes in Git
   - Applies changes to the Kubernetes cluster
   - Reports sync status back to Git (via status checks or comments)

3. **Verification**:
   - Automated tests run against the deployed environment
   - Monitoring checks for any anomalies

## Environment Strategy

MiniShop uses a multi-environment strategy with the following environments:

1. **Development (dev)**:
   - Automatic deployments from `main`
   - Used for integration testing
   - Less stringent resource limits

2. **Staging (staging)**:
   - Automatic deployments from `main` after dev validation
   - Mirrors production configuration
   - Used for pre-production validation

3. **Production (prod)**:
   - Manual promotion from staging
   - Requires approval
   - Strict resource limits and scaling policies

## ArgoCD Configuration

### Application Structure

Each microservice has its own ArgoCD Application:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: user-service
  namespace: argocd
spec:
  project: minishop
  source:
    repoURL: https://github.com/yourusername/minishop.git
    targetRevision: HEAD
    path: infra/helm-charts/user-service
  destination:
    server: https://kubernetes.default.svc
    namespace: minishop
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

### Project Configuration

ArgoCD Project to group all applications:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: minishop
  namespace: argocd
spec:
  description: MiniShop E-commerce Platform
  sourceRepos:
  - https://github.com/yourusername/minishop.git
  destinations:
  - namespace: minishop-dev
    server: https://kubernetes.default.svc
  - namespace: minishop-staging
    server: https://kubernetes.default.svc
  - namespace: minishop-prod
    server: https://kubernetes.default.svc
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
```

### Application Sets

Using ApplicationSets for managing multiple environments:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: minishop-services
  namespace: argocd
spec:
  generators:
  - matrix:
      generators:
      - list:
          elements:
          - service: user-service
          - service: product-service
          - service: order-service
          - service: payment-service
          - service: notification-service
      - list:
          elements:
          - env: dev
            namespace: minishop-dev
          - env: staging
            namespace: minishop-staging
          - env: prod
            namespace: minishop-prod
  template:
    metadata:
      name: '{{service}}-{{env}}'
    spec:
      project: minishop
      source:
        repoURL: https://github.com/yourusername/minishop.git
        targetRevision: HEAD
        path: infra/helm-charts/{{service}}
        helm:
          valueFiles:
          - values-{{env}}.yaml
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{namespace}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
        - CreateNamespace=true
```

## CI/CD Pipeline

### GitHub Actions Workflow

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: make test

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to DockerHub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Build and push user-service
        uses: docker/build-push-action@v4
        with:
          context: ./services/user-service
          push: true
          tags: niini/user-service:latest,niini/user-service:${{ github.sha }}
      
      # Repeat for other services

  update-manifests:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Update Helm values
        run: |
          for service in user-service product-service order-service payment-service notification-service; do
            sed -i "s|tag:.*|tag: ${{ github.sha }}|g" infra/helm-charts/$service/values-dev.yaml
          done
      
      - name: Commit changes
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add infra/helm-charts/*/values-dev.yaml
          git commit -m "Update image tags to ${{ github.sha }}" || echo "No changes to commit"
          git push
```

## Promotion Process

### Dev to Staging

Automatic promotion after successful deployment to dev and passing integration tests:

```yaml
jobs:
  promote-to-staging:
    needs: [deploy-to-dev, integration-tests]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Update Staging Helm values
        run: |
          for service in user-service product-service order-service payment-service notification-service; do
            sed -i "s|tag:.*|tag: ${{ github.sha }}|g" infra/helm-charts/$service/values-staging.yaml
          done
      
      - name: Commit changes
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add infra/helm-charts/*/values-staging.yaml
          git commit -m "Promote to staging: ${{ github.sha }}" || echo "No changes to commit"
          git push
```

### Staging to Production

Manual approval required for production deployment:

```yaml
jobs:
  promote-to-production:
    needs: [deploy-to-staging, staging-tests]
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://api.niini.in
    steps:
      - uses: actions/checkout@v3
      
      - name: Update Production Helm values
        run: |
          for service in user-service product-service order-service payment-service notification-service; do
            sed -i "s|tag:.*|tag: ${{ github.sha }}|g" infra/helm-charts/$service/values-prod.yaml
          done
      
      - name: Commit changes
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add infra/helm-charts/*/values-prod.yaml
          git commit -m "Promote to production: ${{ github.sha }}" || echo "No changes to commit"
          git push
```

## Rollback Process

### Automated Rollbacks

ArgoCD automatically rolls back failed deployments:

```yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
  retry:
    limit: 5
    backoff:
      duration: 5s
      factor: 2
      maxDuration: 3m
```

### Manual Rollbacks

To manually rollback to a previous version:

1. Identify the commit hash of the stable version
2. Update the Helm values files with the previous image tag
3. Commit and push the changes
4. ArgoCD will automatically sync to the previous version

## Secrets Management

### Sealed Secrets

MiniShop uses Bitnami Sealed Secrets for managing Kubernetes secrets:

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: database-credentials
  namespace: minishop
spec:
  encryptedData:
    username: AgBy8hCM8prJxKIylSZbL=
    password: AgBy8hCM8prJxKIylSZbL=
```

### External Secrets

For cloud provider secrets, External Secrets Operator is used:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: payment-gateway-credentials
  namespace: minishop
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secretsmanager
    kind: SecretStore
  target:
    name: payment-gateway-credentials
  data:
  - secretKey: api-key
    remoteRef:
      key: minishop/payment-gateway
      property: api-key
```

## Monitoring and Alerting

### Deployment Metrics

Prometheus metrics for GitOps deployments:

- Deployment frequency
- Lead time for changes
- Change failure rate
- Time to restore service

### ArgoCD Notifications

Notifications for deployment events:

```yaml
apiVersion: notifications.argoproj.io/v1alpha1
kind: Trigger
metadata:
  name: on-sync-succeeded
spec:
  template: app-sync-succeeded
  condition: app.status.operationState.phase in ['Succeeded']
---
apiVersion: notifications.argoproj.io/v1alpha1
kind: Trigger
metadata:
  name: on-sync-failed
spec:
  template: app-sync-failed
  condition: app.status.operationState.phase in ['Error', 'Failed']
```

## Best Practices

1. **Immutable Infrastructure**: Treat infrastructure as immutable and replace rather than modify
2. **Infrastructure as Code**: All infrastructure defined as code and version controlled
3. **Environment Parity**: Keep environments as similar as possible
4. **Automated Testing**: Comprehensive test suite for both application and infrastructure
5. **Progressive Delivery**: Use canary deployments for risk reduction
6. **Observability**: Comprehensive monitoring and logging
7. **Security Scanning**: Regular scanning of code, containers, and infrastructure

## Troubleshooting

### Common Issues

1. **Sync Failures**:
   - Check ArgoCD logs: `kubectl logs -n argocd deployment/argocd-application-controller`
   - Verify Helm chart validity: `helm lint infra/helm-charts/service-name`
   - Check for resource conflicts: `kubectl get events -n minishop`

2. **Image Pull Failures**:
   - Verify image exists in registry
   - Check image pull secrets
   - Ensure correct image tag in Helm values

3. **Resource Constraints**:
   - Check for resource quota issues: `kubectl describe quota -n minishop`
   - Verify node capacity: `kubectl describe nodes`

## References

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)