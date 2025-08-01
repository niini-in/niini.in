# Order Service

This service manages order processing and lifecycle for MiniShop e-commerce platform.

## Features

- Create and manage orders
- Order status tracking
- Order history by user
- Integration with Kafka for event processing
- RESTful API with full CRUD operations
- Docker support for easy deployment

## Tech Stack

- Java 11
- Spring Boot 2.7.18
- PostgreSQL
- Kafka
- Docker & Docker Compose
- Spring Data JPA
- Spring Cloud Netflix Eureka

## Quick Start

### Option 1: Using Docker Compose (Recommended)

1. Start the PostgreSQL database and service:
```bash
docker-compose up -d
```

2. The service will be available at: http://localhost:8083

### Option 2: Manual Setup

1. **Install PostgreSQL** and create a database:
```sql
CREATE DATABASE orderdb;
CREATE USER postgres WITH PASSWORD 'postgres';
GRANT ALL PRIVILEGES ON DATABASE orderdb TO postgres;
```

2. **Install Java 11+** and **Maven**:
```bash
java -version
mvn -version
```

3. **Install dependencies and build**:
```bash
mvn clean install -DskipTests
```

4. **Run the service**:
```bash
java -jar target/order-service-1.0.0.jar
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/orders` | Get all orders |
| GET | `/api/orders/{id}` | Get order by ID |
| GET | `/api/orders/user/{userId}` | Get orders by user ID |
| POST | `/api/orders` | Create new order |
| PUT | `/api/orders/{id}/status` | Update order status |
| DELETE | `/api/orders/{id}` | Delete order |

### Example Order JSON

```json
{
  "userId": 1,
  "items": [
    {
      "productId": 1,
      "quantity": 2,
      "price": 29.99
    }
  ],
  "totalAmount": 59.98,
  "status": "PENDING"
}
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_PORT` | 8083 | Service port |
| `DB_HOST` | localhost | Database host |
| `DB_PORT` | 5432 | Database port |
| `DB_NAME` | orderdb | Database name |
| `DB_USER` | postgres | Database username |
| `DB_PASSWORD` | postgres | Database password |
| `KAFKA_BOOTSTRAP_SERVERS` | localhost:9092 | Kafka server |
| `EUREKA_SERVER` | http://localhost:8761/eureka/ | Eureka server |

## Database Schema

The service automatically creates the following tables:

```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id BIGINT REFERENCES orders(id),
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL
);
```

## Running Tests

```bash
mvn test
```

## Building

### Standard Build
```bash
mvn clean package -DskipTests
```

### Docker Build
```bash
docker build -t order-service .
```

## Development

### Running with Hot Reload
```bash
mvn spring-boot:run
```

### Debugging
```bash
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

## Troubleshooting

### Database Connection Issues
1. **PostgreSQL not running**: Ensure PostgreSQL is running on your system
2. **Authentication failed**: Check your database credentials in application.properties
3. **Database doesn't exist**: Create the database manually:
   ```sql
   CREATE DATABASE orderdb;
   ```

### Port Already in Use
If port 8083 is already in use, change the SERVER_PORT environment variable:
```bash
export SERVER_PORT=8084
java -jar target/order-service-1.0.0.jar
```

### Kafka Issues
If Kafka is not available, the service will still run but with limited event processing capabilities.

### Docker Issues
1. **Port conflicts**: Ensure ports 5432 and 8083 are available
2. **Volume issues**: Run `docker-compose down -v` to clean up volumes
3. **Rebuild**: Run `docker-compose build --no-cache` to rebuild images

## Monitoring

The service provides actuator endpoints:
- Health: http://localhost:8083/actuator/health
- Metrics: http://localhost:8083/actuator/metrics
- Info: http://localhost:8083/actuator/info