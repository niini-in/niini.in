# MiniShop - Microservices E-commerce Platform

A comprehensive microservices-based e-commerce platform built with modern technologies and cloud-native principles.

## 🏗️ Architecture Overview

MiniShop is designed as a cloud-native, scalable e-commerce platform using microservices architecture. Each service is independently deployable, follows domain-driven design principles, and implements the full software development lifecycle with CI/CD, monitoring, and observability.

## 🎯 Key Features

- **Microservices Architecture**: Independently deployable services
- **Event-Driven Design**: Asynchronous communication via Kafka
- **API Gateway**: Centralized routing and load balancing
- **Service Discovery**: Automatic service registration and discovery
- **Distributed Tracing**: Full request tracing across services
- **Centralized Monitoring**: Prometheus metrics and Grafana dashboards
- **Database per Service**: Each service owns its data
- **Polyglot Persistence**: Different technologies for different needs

## 🚀 Services Overview

### Core Business Services
| Service | Technology | Port | Purpose |
|---------|------------|------|---------|
| **API Gateway** | Spring Cloud Gateway | 8080 | Request routing, load balancing |
| **User Service** | Spring Boot + PostgreSQL | 8081 | User management & authentication |
| **Product Service** | Go + PostgreSQL | 8082 | Product catalog & inventory |
| **Order Service** | Spring Boot + PostgreSQL | 8083 | Order processing & management |
| **Payment Service** | Python/FastAPI + PostgreSQL | 8084 | Payment processing & transactions |
| **Notification Service** | Node.js/Express + PostgreSQL | 8085 | User notifications & alerts |

### Infrastructure Services
| Service | Technology | Port | Purpose |
|---------|------------|------|---------|
| **Service Registry** | Eureka Server | 8761 | Service discovery |
| **PostgreSQL** | PostgreSQL 14 | 5432 | Primary database |
| **Redis** | Redis 7 | 6379 | Caching & session storage |
| **Apache Kafka** | Kafka + Zookeeper | 9092 | Event streaming |
| **Prometheus** | Prometheus | 9090 | Metrics collection |
| **Grafana** | Grafana | 3000 | Monitoring dashboards |
| **Jaeger** | Jaeger All-in-One | 16686 | Distributed tracing |

## 🛠️ Technology Stack

### Backend Services
- **Java/Spring Boot** (User, Order, Gateway)
- **Go/Gin** (Product)
- **Python/FastAPI** (Payment)
- **Node.js/Express** (Notification)

### Databases & Storage
- **PostgreSQL** - Primary database for all services
- **Redis** - Caching and session management
- **Kafka** - Event-driven messaging

### DevOps & Infrastructure
- **Docker & Docker Compose** - Container orchestration
- **Prometheus** - Metrics collection
- **Grafana** - Monitoring dashboards
- **Jaeger** - Distributed tracing
- **GitHub Actions** - CI/CD pipeline

## 🚀 Quick Start

### Prerequisites
- **Docker** and **Docker Compose**
- **Git**
- **Make** (optional, for convenience)

### Option 1: Automated Setup (Recommended)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd minishop
   ```

2. **Run the setup script**
   ```bash
   # Unix/Linux/macOS
   chmod +x scripts/setup-dev.sh
   ./scripts/setup-dev.sh
   
   # Windows
   scripts\setup-dev.bat
   ```

3. **Start all services**
   ```bash
   docker-compose up
   ```

### Option 2: Manual Setup

1. **Clone and configure**
   ```bash
   git clone <repository-url>
   cd minishop
   cp .env.example .env
   # Edit .env with your configuration
   ```

2. **Build and start**
   ```bash
   docker-compose build
   docker-compose up -d postgres redis zookeeper kafka
   sleep 30  # Wait for infrastructure
   docker-compose up
   ```

### Option 3: Local Development (No Docker)

Each service has detailed local development instructions in their respective README files.

## 📊 Service Health & Access

### API Endpoints
| Service | Health Check | API Base URL |
|---------|--------------|--------------|
| Gateway | http://localhost:8080/actuator/health | http://localhost:8080 |
| User | http://localhost:8081/actuator/health | http://localhost:8081/api/users |
| Product | http://localhost:8082/health | http://localhost:8082/api/products |
| Order | http://localhost:8083/actuator/health | http://localhost:8083/api/orders |
| Payment | http://localhost:8084/health | http://localhost:8084/api/payments |
| Notification | http://localhost:8085/health | http://localhost:8085/api/notifications |

### Monitoring & Observability
| Tool | URL | Credentials |
|------|-----|-------------|
| **Grafana** | http://localhost:3000 | admin/admin |
| **Prometheus** | http://localhost:9090 | - |
| **Jaeger** | http://localhost:16686 | - |
| **Eureka** | http://localhost:8761 | - |

## 📁 Project Structure

```
minishop/
├── 📁 services/                 # All microservices
│   ├── user-service/            # Spring Boot user management
│   ├── product-service/         # Go product catalog
│   ├── order-service/           # Spring Boot order processing
│   ├── payment-service/         # Python/FastAPI payments
│   └── notification-service/    # Node.js notifications
├── 📁 gateway/                  # API Gateway
├── 📁 infra/                    # Infrastructure configs
│   ├── docker/                  # Docker configurations
│   ├── kubernetes/              # K8s manifests
│   └── terraform/               # Infrastructure as Code
├── 📁 docs/                     # Documentation
├── 📁 scripts/                  # Development scripts
├── docker-compose.yml           # Local development
├── Makefile                     # Build commands
└── README.md                    # This file
```

## 🔧 Development Commands

### Using Make (Unix/Linux/macOS)
```bash
make help              # Show all available commands
make setup            # Initial setup
make build            # Build all services
make start            # Start all services
make stop             # Stop all services
make logs             # View logs
make clean            # Clean up containers
```

### Using Docker Compose Directly
```bash
# Build all services
docker-compose build

# Start all services
docker-compose up

# Start specific services
docker-compose up user-service product-service

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 🔍 Development Workflow

### 1. Local Development
```bash
# Start infrastructure services only
docker-compose up -d postgres redis zookeeper kafka

# Run services individually
cd services/user-service
./mvnw spring-boot:run
```

### 2. Testing
Each service includes comprehensive testing:
- **Unit Tests** - Service-specific business logic
- **Integration Tests** - Cross-service communication
- **Contract Tests** - API compatibility

### 3. Debugging
- **Logs**: Available via `docker-compose logs [service-name]`
- **Metrics**: Prometheus metrics at `/actuator/prometheus` (Java) or `/metrics`
- **Tracing**: Distributed tracing via Jaeger
- **Health**: Health check endpoints for all services

## 🧪 Testing Strategy

### Service-Level Testing
```bash
# User Service (Spring Boot)
cd services/user-service
./mvnw test

# Product Service (Go)
cd services/product-service
go test ./...

# Payment Service (Python)
cd services/payment-service
python -m pytest

# Notification Service (Node.js)
cd services/notification-service
npm test
```

### Integration Testing
```bash
# Run integration tests
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
```

## 📚 Documentation

- **[Architecture Guide](docs/architecture.md)** - System architecture overview
- **[API Contracts](docs/api-contracts.md)** - API specifications
- **[Deployment Guide](docs/deployment-guide.md)** - Production deployment
- **[GitOps Guide](docs/gitops.md)** - GitOps workflow
- **[Observability Guide](docs/observability.md)** - Monitoring and tracing

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Process
1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** changes: `git commit -m 'Add amazing feature'`
4. **Push** to branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request

### Code Standards
- Follow service-specific coding standards
- Include comprehensive tests
- Update documentation
- Ensure CI/CD pipeline passes

## 🐛 Troubleshooting

### Common Issues

1. **Services not starting**
   ```bash
   # Check Docker resources
   docker system prune -f
   docker-compose down -v
   docker-compose up --build
   ```

2. **Database connection issues**
   ```bash
   # Check PostgreSQL logs
   docker-compose logs postgres
   
   # Reset database
   docker-compose down -v
   docker-compose up postgres
   ```

3. **Kafka connection issues**
   ```bash
   # Check Kafka logs
   docker-compose logs kafka
   
   # Restart Kafka
   docker-compose restart kafka
   ```

### Getting Help
- Check [Issues](https://github.com/your-org/minishop/issues)
- Review [Discussions](https://github.com/your-org/minishop/discussions)
- Contact the development team

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ by the MiniShop team
- Inspired by modern microservices patterns
- Special thanks to the open-source community