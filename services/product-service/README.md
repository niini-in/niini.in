# Product Service

This service manages the product catalog for MiniShop e-commerce platform.

## Features

- Product catalog management
- Product search and filtering
- Inventory tracking
- Category management
- RESTful API with full CRUD operations
- Docker support for easy deployment

## Tech Stack

- Go 1.19
- Gin web framework
- GORM ORM
- PostgreSQL
- Docker & Docker Compose

## Quick Start

### Option 1: Using Docker Compose (Recommended)

1. Start the PostgreSQL database and service:
```bash
docker-compose up -d
```

2. The service will be available at: http://localhost:8082

### Option 2: Manual Setup

1. **Install PostgreSQL** and create a database:
```sql
CREATE DATABASE productdb;
CREATE USER postgres WITH PASSWORD 'postgres';
GRANT ALL PRIVILEGES ON DATABASE productdb TO postgres;
```

2. **Set up environment variables**:
```bash
cp .env.example .env
# Edit .env with your database credentials
```

3. **Install dependencies**:
```bash
go mod tidy
```

4. **Run the service**:
```bash
go run main.go
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/products` | Get all products |
| GET | `/api/products/:id` | Get product by ID |
| POST | `/api/products` | Create new product |
| PUT | `/api/products/:id` | Update product |
| DELETE | `/api/products/:id` | Delete product |
| GET | `/api/products/search` | Search products |

### Search Parameters

- `q`: Search query (searches in name and description)
- `category`: Filter by category

### Example Product JSON

```json
{
  "name": "iPhone 15",
  "description": "Latest iPhone model with advanced features",
  "price": 999.99,
  "stock": 100,
  "category": "Electronics",
  "image_url": "https://example.com/iphone15.jpg"
}
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | localhost | Database host |
| `DB_PORT` | 5432 | Database port |
| `DB_NAME` | productdb | Database name |
| `DB_USER` | postgres | Database username |
| `DB_PASSWORD` | postgres | Database password |
| `PORT` | 8082 | Service port |

## Running Tests

```bash
go test ./...
```

## Building

```bash
go build -o product-service
```

### Docker Build

```bash
docker build -t product-service .
```

## Troubleshooting

### Database Connection Issues

1. **PostgreSQL not running**: Ensure PostgreSQL is running on your system
2. **Authentication failed**: Check your database credentials in .env file
3. **Database doesn't exist**: Create the database manually:
   ```sql
   CREATE DATABASE productdb;
   ```

### Port Already in Use

If port 8082 is already in use, change the PORT environment variable:
```bash
export PORT=8083
go run main.go
```

### Docker Issues

1. **Port conflicts**: Ensure ports 5432 and 8082 are available
2. **Volume issues**: Run `docker-compose down -v` to clean up volumes
3. **Rebuild**: Run `docker-compose build --no-cache` to rebuild images