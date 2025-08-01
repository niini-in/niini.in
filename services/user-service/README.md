# User Service

The User Service is a Spring Boot microservice responsible for user management and authentication in the MiniShop e-commerce platform.

## Features

- User registration and authentication
- JWT-based authentication
- Role-based access control
- User profile management
- RESTful API for user operations

## Tech Stack

- Java 17
- Spring Boot 3.1.x
- Spring Security with JWT
- Spring Data JPA
- PostgreSQL
- Flyway for database migrations
- Spring Cloud Netflix Eureka for service discovery

## API Endpoints

### Authentication

- `POST /api/auth/signup` - Register a new user
- `POST /api/auth/signin` - Authenticate a user and get JWT token

### User Management

- `GET /api/users` - Get all users (Admin only)
- `GET /api/users/{id}` - Get user by ID
- `GET /api/users/me` - Get current user profile
- `DELETE /api/users/{id}` - Delete a user (Admin only)

## Local Development

### Prerequisites

- Java 17 or higher
- Maven 3.6+
- Docker and Docker Compose (for running PostgreSQL)

### Running the Service

1. Start the required infrastructure using Docker Compose:

```bash
# From the project root directory
docker-compose up -d postgres
```

2. Run the application:

```bash
# From the user-service directory
./mvnw spring-boot:run
```

### Building the Docker Image

```bash
# From the user-service directory
./mvnw clean package
docker build -t minishop/user-service .
```

## Configuration

The service can be configured using environment variables or by modifying the `application.yml` file:

- `SPRING_DATASOURCE_URL` - Database URL
- `SPRING_DATASOURCE_USERNAME` - Database username
- `SPRING_DATASOURCE_PASSWORD` - Database password
- `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE` - Eureka server URL
- `JWT_SECRET` - Secret key for JWT token generation
- `JWT_EXPIRATION` - JWT token expiration time in milliseconds

## Monitoring

The service exposes the following actuator endpoints:

- `/api/actuator/health` - Health information
- `/api/actuator/info` - Application information
- `/api/actuator/prometheus` - Prometheus metrics

## API Documentation

Swagger UI is available at `/api/swagger-ui.html` when the service is running.