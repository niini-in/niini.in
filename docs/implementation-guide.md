# MiniShop Implementation Guide

## 🚀 Quick Start - Next 48 Hours

### Day 1: Service Bootstrap
Focus on getting one service fully functional to establish patterns.

#### Priority 1: User Service (Java/Spring Boot)
```bash
cd services/user-service
# 1. Check current structure
ls -la src/main/java/com/minishop/user/

# 2. Create basic entities
# 3. Add REST controllers
# 4. Configure application.yml
```

**Files to create:**
- `User.java` entity
- `UserRepository.java` 
- `UserController.java`
- `UserService.java`
- Basic security config

#### Priority 2: Database Schema
```sql
-- Connect to PostgreSQL
docker exec -it minishop-postgres psql -U postgres -d userdb

-- Create basic tables
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Day 2: API Gateway & Service Discovery

#### Test Current Setup
```bash
# Start infrastructure
make start-infra

# Check service registry
curl http://localhost:8761/eureka/apps

# Test user service health
curl http://localhost:8081/actuator/health
```

## 📋 Service-by-Service Implementation Checklist

### User Service (Java/Spring Boot)
**Current Status**: Basic structure exists

**Next Steps**:
1. **Entity Creation** (30 min)
   ```java
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
       
       @CreationTimestamp
       private LocalDateTime createdAt;
       
       @UpdateTimestamp
       private LocalDateTime updatedAt;
   }
   ```

2. **Repository** (15 min)
   ```java
   public interface UserRepository extends JpaRepository<User, Long> {
       Optional<User> findByEmail(String email);
   }
   ```

3. **Controller** (45 min)
   ```java
   @RestController
   @RequestMapping("/api/users")
   public class UserController {
       
       @PostMapping("/register")
       public ResponseEntity<User> register(@RequestBody UserRegistrationDto dto) {
           // Implementation
       }
       
       @PostMapping("/login")
       public ResponseEntity<AuthResponse> login(@RequestBody LoginDto dto) {
           // Implementation
       }
   }
   ```

### Product Service (Go)
**Current Status**: Basic structure exists

**Next Steps**:
1. **Model Definition** (20 min)
   ```go
   type Product struct {
       ID          uint      `json:"id" gorm:"primaryKey"`
       Name        string    `json:"name" gorm:"not null"`
       Description string    `json:"description"`
       Price       float64   `json:"price"`
       Stock       int       `json:"stock"`
       Category    string    `json:"category"`
       CreatedAt   time.Time `json:"created_at"`
       UpdatedAt   time.Time `json:"updated_at"`
   }
   ```

2. **Handler Setup** (30 min)
   ```go
   func (h *ProductHandler) GetProducts(c *gin.Context) {
       var products []Product
       h.db.Find(&products)
       c.JSON(200, products)
   }
   ```

### Order Service (Java/Spring Boot)
**Current Status**: Basic structure exists

**Next Steps**:
1. **Order Entity** (30 min)
2. **Order Service** (60 min)
3. **Kafka Integration** (45 min)

### Payment Service (Python/FastAPI)
**Current Status**: Basic structure exists

**Next Steps**:
1. **Payment Model** (15 min)
2. **Stripe Integration** (60 min)
3. **Webhook Handler** (30 min)

### Notification Service (Node.js)
**Current Status**: Basic structure exists

**Next Steps**:
1. **Email Service** (30 min)
2. **Queue Consumer** (45 min)
3. **Template Engine** (30 min)

## 🔧 Development Environment Setup

### Prerequisites Check
```bash
# Verify Docker
docker --version
docker-compose --version

# Check ports
netstat -an | grep -E ':(8080|8081|8082|8083|8084|8085|8761|9090|3000|16686)'

# Verify databases
docker-compose up -d postgres redis
```

### Quick Health Check Script
```bash
#!/bin/bash
echo "🔍 Checking MiniShop Health..."

# Infrastructure
echo "📊 PostgreSQL: "
docker-compose exec postgres pg_isready -U postgres && echo "✅" || echo "❌"

echo "📊 Redis: "
docker-compose exec redis redis-cli ping && echo "✅" || echo "❌"

echo "📊 Kafka: "
docker-compose exec kafka kafka-topics --list --bootstrap-server localhost:9092 && echo "✅" || echo "❌"

# Services
echo "📊 Eureka: "
curl -s http://localhost:8761/eureka/apps | grep -q "application" && echo "✅" || echo "❌"

echo "📊 Gateway: "
curl -s http://localhost:8080/actuator/health | grep -q "UP" && echo "✅" || echo "❌"
```

## 🎯 MVP Development Sprint

### Week 1 Focus Areas

#### Day 1-2: User Service
- [ ] User registration endpoint
- [ ] User login endpoint
- [ ] Basic JWT token generation
- [ ] User profile retrieval

#### Day 3-4: Product Service
- [ ] Product listing endpoint
- [ ] Product detail endpoint
- [ ] Basic search functionality
- [ ] Category filtering

#### Day 5-6: Order Service
- [ ] Create order endpoint
- [ ] Get order details
- [ ] Order status management
- [ ] Basic cart functionality

#### Day 7: Integration
- [ ] API Gateway routing
- [ ] Service discovery verification
- [ ] End-to-end flow testing

### Testing Strategy

#### Unit Tests Structure
```
services/{service-name}/
├── src/test/
│   ├── unit/
│   ├── integration/
│   └── e2e/
```

#### Sample Test Cases
```java
@Test
public void testUserRegistration() {
    UserRegistrationDto dto = new UserRegistrationDto("test@example.com", "password");
    ResponseEntity<User> response = userController.register(dto);
    
    assertEquals(HttpStatus.CREATED, response.getStatusCode());
    assertNotNull(response.getBody().getId());
}
```

## 🚨 Common Issues & Solutions

### Port Conflicts
```bash
# Find process using port
lsof -i :8080
# Kill process
kill -9 <PID>
```

### Database Connection Issues
```bash
# Reset PostgreSQL volume
docker-compose down -v
docker-compose up postgres

# Check connection string
docker-compose exec postgres psql -U postgres -d userdb -c "\dt"
```

### Service Discovery Issues
```bash
# Check Eureka
curl http://localhost:8761/eureka/apps

# Verify service registration
curl http://localhost:8761/eureka/apps/USER-SERVICE
```

## 🚀 **NEW: Kubernetes Deployment Guide**

### Week 3: Production Deployment

#### Day 1: Kubernetes Setup
```bash
# Install required tools
kubectl version --client
helm version

# Verify cluster access
kubectl cluster-info
kubectl get nodes

# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install Cert Manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml
```

#### Day 2: Deploy Infrastructure
```bash
# Apply infrastructure manifests
kubectl apply -f infra/cert-manager/cluster-issuer.yaml
kubectl apply -f infra/argo-cd/minishop-applications.yaml

# Verify deployment
kubectl get applications -n argocd
kubectl get certificates -A
```

#### Day 3: Service Deployment
```bash
# Deploy development environment
helm install minishop-dev infra/helm-charts/minishop -f infra/helm-charts/minishop/values-dev.yaml

# Check deployment status
kubectl get pods -n minishop-dev
kubectl get services -n minishop-dev
kubectl get ingress -n minishop-dev
```

#### Day 4: Staging Environment
```bash
# Deploy staging
helm install minishop-staging infra/helm-charts/minishop -f infra/helm-charts/minishop/values-staging.yaml

# Run integration tests
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl http://minishop-staging-gateway/api/health
```

#### Day 5: Production Deployment
```bash
# Deploy production
helm install minishop-prod infra/helm-charts/minishop -f infra/helm-charts/minishop/values-prod.yaml

# Verify SSL certificates
kubectl get certificates -n minishop-prod
kubectl describe certificate minishop-tls-prod -n minishop-prod
```

### Helm Chart Structure
```
infra/helm-charts/minishop/
├── Chart.yaml          # Dependencies and metadata
├── values-dev.yaml     # Development configuration
├── values-staging.yaml # Staging configuration
├── values-prod.yaml    # Production configuration
└── templates/
    ├── deployment.yaml # Service deployments
    ├── service.yaml    # Kubernetes services
    ├── ingress.yaml    # Ingress routing
    ├── hpa.yaml        # Horizontal pod autoscaler
    └── networkpolicy.yaml # Security policies
```

### Environment Configuration
| Environment | Domain | Resources | Replicas | SSL |
|-------------|--------|-----------|----------|-----|
| Development | dev.minishop.local | 0.5 CPU, 512Mi | 1 | Staging |
| Staging | staging.minishop.com | 0.75 CPU, 768Mi | 2 | Staging |
| Production | api.minishop.com | 1 CPU, 1Gi | 3+ | Production |

## 📊 Progress Tracking

### Kubernetes Deployment Checklist
- [ ] **Cluster Setup** - Kubernetes cluster provisioned
- [ ] **Argo CD** - GitOps operator installed
- [ ] **Cert Manager** - SSL certificate management
- [ ] **Ingress Controller** - NGINX ingress setup
- [ ] **Monitoring** - Prometheus/Grafana deployed
- [ ] **Dev Environment** - Development namespace ready
- [ ] **Staging Environment** - Staging namespace ready
- [ ] **Production Environment** - Production namespace ready
- [ ] **SSL Certificates** - All domains secured
- [ ] **Autoscaling** - HPA configured for all services
- [ ] **Network Policies** - Security isolation in place

### Daily Standup Template
```markdown
**Yesterday:**
- [x] Completed user entity
- [x] Added repository layer

**Today:**
- [ ] Add authentication controller
- [ ] Implement JWT token
- [ ] Write unit tests

**Blockers:**
- Database connection issue
```

### Definition of Done
- [ ] Code complete
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Documentation updated
- [ ] API documented
- [ ] Docker build successful
- [ ] Kubernetes manifests ready
- [ ] Helm charts validated
- [ ] SSL certificates issued
- [ ] Monitoring configured

## 🚀 Next Steps After MVP

1. **Security Hardening**
   - OAuth2 implementation
   - Rate limiting
   - Input validation

2. **Performance Optimization**
   - Redis caching
   - Database indexing
   - Connection pooling

3. **Advanced Features**
   - Search with Elasticsearch
   - File uploads
   - Real-time notifications

4. **Production Readiness**
   - Kubernetes deployment
   - Monitoring alerts
   - Backup strategies

---

## 📞 Getting Help

### Resources
- **Service README files**: Check each service's README.md
- **Architecture docs**: See architecture.md
- **API contracts**: See api-contracts.md

### Common Commands
```bash
# View logs
make logs SERVICE=user-service

# Rebuild specific service
make build-service SERVICE=user-service

# Health check
make health-check

# Clean everything
make clean
```

### Emergency Contacts
- **Dev Environment**: Check Makefile for all commands
- **Database Issues**: Check postgres logs
- **Service Issues**: Check individual service logs
```