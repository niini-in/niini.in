# MiniShop Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. Environment Setup

```bash
# Clone and setup
git clone <repository>
cd ministore@nini

# Windows
scripts\setup-dev.bat

# Linux/macOS
chmod +x scripts/setup-dev.sh
./scripts/setup-dev.sh
```

### 2. Verify Installation

```bash
# Check all services
make status

# Expected output:
# ✅ PostgreSQL: Running on port 5432
# ✅ Redis: Running on port 6379
# ✅ Kafka: Running on port 9092
# ✅ Eureka: Running on port 8761
```

### 3. Start Development Environment

```bash
# Start everything
make dev

# OR start infrastructure only
make start-infra

# Check service health
make health-check
```

## 📋 Service URLs

| Service    | URL                    | Description              |
| ---------- | ---------------------- | ------------------------ |
| Gateway    | http://localhost:8080  | Main API entry point     |
| Eureka     | http://localhost:8761  | Service registry         |
| Grafana    | http://localhost:3000  | Monitoring (admin/admin) |
| Prometheus | http://localhost:9090  | Metrics                  |
| Jaeger     | http://localhost:16686 | Tracing                  |

## 🎯 What to Build Next

### Immediate Priority (This Week)

#### 1. User Service - Start Here

```bash
cd services/user-service

# Check what's missing
find src -name "*.java" | wc -l
# Should be > 10 files for basic CRUD

# Quick entity creation
cat > src/main/java/com/minishop/user/entity/User.java << 'EOF'
package in.niini.user.entity;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String email;

    private String passwordHash;
    private String firstName;
    private String lastName;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    // Getters and setters
}
EOF
```

#### 2. Test Database Connection

```bash
# Connect to database
docker exec -it minishop-postgres psql -U postgres -d userdb

# Create test table
CREATE TABLE test_users (id SERIAL PRIMARY KEY, email VARCHAR(255));
INSERT INTO test_users (email) VALUES ('test@example.com');
SELECT * FROM test_users;
```

#### 3. Build & Test

```bash
# Build user service
make build-service SERVICE=user-service

# Check if it registers with Eureka
curl http://localhost:8761/eureka/apps | grep USER-SERVICE
```

## 🔧 Development Commands

### Daily Workflow

```bash
# Start your day
make dev-logs  # Start with logs

# Work on specific service
make restart-service SERVICE=user-service

# Check what's running
make ps

# View logs for specific service
make logs SERVICE=user-service
```

### Quick Fixes

```bash
# Database reset
docker-compose down postgres
docker-compose up -d postgres

# Full reset
make clean
make setup
```

## 📊 Development Checklist

### Before You Start Coding

- [ ] Docker is running
- [ ] All ports are available
- [ ] Environment files created
- [ ] Database accessible

### Your First PR Should Include

- [ ] One working endpoint (GET /health)
- [ ] Basic entity/model
- [ ] Repository/DAO layer
- [ ] Simple unit test
- [ ] Updated README for your service

### Service Health Test

```bash
#!/bin/bash
# Save as test-service.sh
SERVICE=$1
curl -f http://localhost:${SERVICE}808${SERVICE}/actuator/health || echo "❌ $SERVICE not responding"
```

## 🚨 Common Issues

### "Port already in use"

```bash
# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Linux/macOS
lsof -ti:8080 | xargs kill -9
```

### "Database connection refused"

```bash
# Wait for PostgreSQL
docker-compose logs postgres | grep "ready to accept connections"

# Check connection
docker-compose exec postgres pg_isready -U postgres
```

### "Service not registering"

```bash
# Check Eureka
curl http://localhost:8761/eureka/apps

# Restart service
make restart-service SERVICE=user-service
```

## 🎯 Success Metrics

---

## 🚀 **NEW: Kubernetes Deployment** (Advanced)

### Quick Kubernetes Setup

```bash
# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install Cert Manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml
kubectl apply -f infra/cert-manager/cluster-issuer.yaml

# Deploy MiniShop
kubectl apply -f infra/argo-cd/minishop-applications.yaml
```

### Kubernetes URLs (After Deployment)

| Environment | URL                          | Description            |
| ----------- | ---------------------------- | ---------------------- |
| Development | https://dev.minishop.local   | Dev environment        |
| Staging     | https://staging.minishop.com | Staging environment    |
| Production  | https://api.minishop.com     | Production environment |
| Grafana     | https://grafana.minishop.com | Monitoring             |
| Argo CD     | https://argocd.minishop.com  | GitOps dashboard       |

### Helm Commands

```bash
# Deploy to development
helm install minishop-dev infra/helm-charts/minishop -f infra/helm-charts/minishop/values-dev.yaml

# Deploy to staging
helm install minishop-staging infra/helm-charts/minishop -f infra/helm-charts/minishop/values-staging.yaml

# Deploy to production
helm install minishop-prod infra/helm-charts/minishop -f infra/helm-charts/minishop/values-prod.yaml
```

### Your Service is Ready When

- [ ] Responds to GET /health
- [ ] Registers with Eureka
- [ ] Connects to database
- [ ] Has at least 3 endpoints
- [ ] Unit tests pass
- [ ] Docker build succeeds

### End-to-End Test

```bash
# Test full flow
curl -X POST http://localhost:8080/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'

# Should return 201 Created
```

## 📞 Need Help?

### Quick Debug

```bash
# Check what's running
make status

# View all logs
make logs

# Check specific service
docker-compose logs user-service
```

### Documentation

- **Architecture**: docs/architecture.md
- **API Contracts**: docs/api-contracts.md
- **TODO**: docs/TODO.md
- **Implementation Guide**: docs/implementation-guide.md

### Getting Unstuck

1. Check `make status` first
2. Look at service logs: `make logs SERVICE=service-name`
3. Check docs/TODO.md for next steps
4. Create issue with `make status` output

---

## 🎉 Ready to Code!

Your environment is set up. Pick a service and start with:

1. **User Service** (Java) - Most critical
2. **Product Service** (Go) - Simplest to implement
3. **Order Service** (Java) - Complex but important

Start with the **User Service** - it's the foundation for everything else.

**Next**: Run `make dev` and visit http://localhost:8761 to see your services!
