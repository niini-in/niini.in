# MiniShop OpenAPI Documentation Guide

This document provides a comprehensive overview of the OpenAPI/Swagger documentation implemented across all MiniShop services.

## 📋 Service Documentation Overview

### User Service (Spring Boot + Springdoc)
- **Technology**: Java/Spring Boot with Springdoc OpenAPI
- **Documentation URL**: `http://localhost:8081/api/swagger-ui.html`
- **API Docs**: `http://localhost:8081/api/v3/api-docs`
- **Status**: ✅ Already configured with Springdoc

### Product Service (Go + Swaggo)
- **Technology**: Go/Gin with Swaggo
- **Documentation URL**: `http://localhost:8082/swagger/index.html`
- **Status**: ✅ Configured with Swaggo annotations

### Order Service (Spring Boot + Springdoc)
- **Technology**: Java/Spring Boot with Springdoc OpenAPI
- **Documentation URL**: `http://localhost:8083/swagger-ui.html`
- **API Docs**: `http://localhost:8083/v3/api-docs`
- **Status**: ✅ Configured with Springdoc

### Payment Service (Python + FastAPI)
- **Technology**: Python/FastAPI with built-in OpenAPI
- **Documentation URL**: `http://localhost:8084/docs`
- **Alternative**: `http://localhost:8084/redoc`
- **Status**: ✅ Enhanced with FastAPI built-in support

### Notification Service (Node.js + Swagger-jsdoc)
- **Technology**: Node.js/Express with Swagger-jsdoc
- **Documentation URL**: `http://localhost:8085/docs`
- **Status**: ✅ Configured with Swagger-jsdoc

### API Gateway (Spring Cloud Gateway)
- **Technology**: Spring Cloud Gateway
- **Documentation**: Routes to individual service documentation
- **Status**: ✅ Routes configured for all services

## 🚀 Quick Start

### 1. Start All Services
```bash
# Start all services
make start

# Or start infrastructure first
make start-infra
```

### 2. Access Documentation
Once services are running, access the documentation URLs:

| Service | Documentation URL |
|---------|-------------------|
| User Service | http://localhost:8081/api/swagger-ui.html |
| Product Service | http://localhost:8082/swagger/index.html |
| Order Service | http://localhost:8083/swagger-ui.html |
| Payment Service | http://localhost:8084/docs |
| Notification Service | http://localhost:8085/docs |

### 3. Generate Documentation (if needed)

#### Product Service (Go)
```bash
cd services/product-service
# Install swag CLI
go install github.com/swaggo/swag/cmd/swag@latest
# Generate documentation
swag init
```

#### Notification Service (Node.js)
```bash
cd services/notification-service
npm install
# Documentation is automatically generated from JSDoc comments
```

## 📖 API Endpoints Documentation

### User Service Endpoints
- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user
- `POST /api/users/login` - User login
- `POST /api/users/register` - User registration

### Product Service Endpoints
- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create new product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product
- `GET /api/products/search` - Search products

### Order Service Endpoints
- `GET /api/orders` - Get all orders
- `GET /api/orders/{id}` - Get order by ID
- `POST /api/orders` - Create new order
- `PUT /api/orders/{id}` - Update order
- `DELETE /api/orders/{id}` - Delete order
- `GET /api/orders/user/{userId}` - Get orders by user ID

### Payment Service Endpoints
- `GET /api/payments` - Get all payments
- `GET /api/payments/{payment_id}` - Get payment by ID
- `POST /api/payments` - Create new payment
- `PUT /api/payments/{payment_id}` - Update payment
- `GET /api/payments/order/{order_id}` - Get payments by order ID
- `GET /api/payments/user/{user_id}` - Get payments by user ID

### Notification Service Endpoints
- `GET /api/notifications` - Get all notifications
- `GET /api/notifications/{id}` - Get notification by ID
- `POST /api/notifications` - Create new notification
- `GET /api/notifications/user/{userId}` - Get notifications by user ID
- `PATCH /api/notifications/{id}/read` - Mark notification as read
- `PUT /api/notifications/user/{userId}/read-all` - Mark all notifications as read
- `GET /api/notifications/user/{userId}/unread-count` - Get unread count

## 🔧 Configuration Details

### Springdoc (Java Services)
```yaml
springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    path: /swagger-ui.html
    operationsSorter: method
```

### Swaggo (Go Service)
```go
// @title Product Service API
// @version 1.0
// @description Product management service for MiniShop e-commerce platform
// @host localhost:8082
// @BasePath /api
```

### FastAPI (Python Service)
```python
app = FastAPI(
    title="Payment Service API",
    description="Payment processing service for MiniShop e-commerce platform",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)
```

### Swagger-jsdoc (Node.js Service)
```javascript
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Notification Service API',
      version: '1.0.0',
      description: 'Notification management service for MiniShop'
    }
  },
  apis: ['./src/routes/*.js']
};
```

## 🔍 Testing Documentation

### Health Check Endpoints
All services include health check endpoints:
- User Service: `http://localhost:8081/health`
- Product Service: `http://localhost:8082/health`
- Order Service: `http://localhost:8083/actuator/health`
- Payment Service: `http://localhost:8084/health`
- Notification Service: `http://localhost:8085/health`

### Service Registry
Check Eureka for registered services:
- `http://localhost:8761` (Eureka Dashboard)
- `http://localhost:8761/eureka/apps` (JSON API)

## 📝 Next Steps

1. **Test Documentation**: Verify all documentation URLs are accessible
2. **Add Examples**: Enhance API documentation with request/response examples
3. **Security**: Add authentication/authorization documentation
4. **Rate Limiting**: Document rate limits and usage guidelines
5. **Error Handling**: Standardize error response documentation

## 🐛 Troubleshooting

### Common Issues

1. **Service not responding**
   ```bash
   make health-check-services
   ```

2. **Documentation not loading**
   - Check if service is running: `make ps`
   - Verify port availability: `make ports`
   - Check service logs: `make logs SERVICE=service-name`

3. **CORS issues**
   - All services are configured with CORS enabled for development
   - Check service-specific CORS configuration

## 🎯 Success Checklist

- [ ] All services are running (`make ps`)
- [ ] All documentation URLs are accessible
- [ ] API endpoints are properly documented
- [ ] Health checks are passing
- [ ] Service registry shows all services registered

## 📊 Monitoring

Access monitoring dashboards:
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Jaeger**: http://localhost:16686

---

**Note**: All documentation is automatically generated and updated when services are restarted. The OpenAPI specifications follow the OpenAPI 3.0 standard and include comprehensive examples and descriptions.