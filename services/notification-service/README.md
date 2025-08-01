# Notification Service

A Node.js/Express service for managing user notifications in the MiniShop e-commerce platform.

## Purpose

This service handles:
- Real-time notifications for user events
- Order status updates
- Payment confirmations and failures
- Inventory alerts
- Promotional notifications
- User-specific notification management

## Features

- **Real-time Notifications**: Instant notifications via Kafka event processing
- **Notification Types**: Support for order, payment, inventory, and promotional notifications
- **User-specific**: Personalized notifications for each user
- **Mark as Read**: Track read/unread status
- **Scalable**: Kafka-based event processing for high throughput
- **RESTful API**: Clean API design for notification management
- **Database Storage**: Persistent notification storage with PostgreSQL

## Tech Stack

- **Runtime**: Node.js 18
- **Framework**: Express.js
- **Database**: PostgreSQL with Sequelize ORM
- **Message Queue**: Apache Kafka
- **Logging**: Winston
- **Container**: Docker
- **Testing**: Jest + Supertest

## API Endpoints

### Notification Management

- `GET /api/notifications` - Get all notifications (paginated)
- `GET /api/notifications/:id` - Get specific notification by ID
- `POST /api/notifications` - Create a new notification
- `GET /api/notifications/user/:userId` - Get notifications for specific user
- `PUT /api/notifications/:id/read` - Mark notification as read
- `PUT /api/notifications/user/:userId/read-all` - Mark all user notifications as read
- `GET /api/notifications/user/:userId/unread-count` - Get unread notification count

### Health Check

- `GET /health` - Service health check

## Local Development

### Prerequisites

- Node.js 18+
- PostgreSQL 13+
- Apache Kafka (or use Docker Compose)

### Setup

1. Install dependencies:
```bash
npm install
```

2. Set environment variables:
```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=minishop_notifications
DB_USER=postgres
DB_PASSWORD=password

# Kafka
KAFKA_BROKERS=localhost:9092

# Service
PORT=8085
NODE_ENV=development
```

3. Create database:
```bash
# Connect to PostgreSQL and create database
createdb minishop_notifications
```

4. Start development server:
```bash
npm run dev
```

### Docker Development

1. Build and run with Docker Compose:
```bash
docker-compose up --build
```

2. Or build manually:
```bash
docker build -t notification-service .
docker run -p 8085:8085 --env-file .env notification-service
```

## Testing

### Run Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

### Test Structure

- Unit tests: `src/**/*.test.js`
- Integration tests: `tests/**/*.test.js`
- Mock data: `tests/fixtures/`

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Service port | `8085` |
| `NODE_ENV` | Environment mode | `development` |
| `DB_HOST` | PostgreSQL host | `localhost` |
| `DB_PORT` | PostgreSQL port | `5432` |
| `DB_NAME` | Database name | `minishop_notifications` |
| `DB_USER` | Database username | `postgres` |
| `DB_PASSWORD` | Database password | `password` |
| `KAFKA_BROKERS` | Kafka broker list | `localhost:9092` |

## Notification Types

- `ORDER_CONFIRMED`: Order successfully placed
- `ORDER_SHIPPED`: Order has been shipped
- `ORDER_DELIVERED`: Order has been delivered
- `PAYMENT_SUCCESS`: Payment processed successfully
- `PAYMENT_FAILED`: Payment processing failed
- `INVENTORY_LOW`: Product running low on stock
- `PROMOTION`: Special offers and promotions

## Kafka Topics

The service listens to these Kafka topics:
- `order.created` - New order placed
- `order.shipped` - Order shipped
- `order.delivered` - Order delivered
- `payment.success` - Payment successful
- `payment.failed` - Payment failed
- `inventory.low` - Low inventory alert

## Database Schema

### Notifications Table
- `id` (UUID): Primary key
- `user_id` (UUID): Associated user
- `type` (ENUM): Notification type
- `title` (STRING): Notification title
- `message` (TEXT): Notification content
- `is_read` (BOOLEAN): Read status
- `metadata` (JSONB): Additional data
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

## Deployment

### Docker

```bash
# Build image
docker build -t notification-service:latest .

# Run container
docker run -d \
  --name notification-service \
  -p 8085:8085 \
  -e DB_HOST=your-db-host \
  -e DB_PASSWORD=your-db-password \
  notification-service:latest
```

### Kubernetes

See deployment configurations in `k8s/` directory.

## Monitoring

- Health check endpoint: `GET /health`
- Logs: Winston logging to console and files
- Metrics: Available via `/metrics` (when enabled)
- Database: Sequelize query logging

## Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open pull request

## License

MIT License - see LICENSE file for details.