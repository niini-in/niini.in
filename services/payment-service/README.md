# Payment Service

This service handles payment processing and integration with payment gateways for MiniShop e-commerce platform.

## Features

- Payment processing
- Multiple payment methods support
- Transaction tracking
- Payment status management
- Integration with external payment gateways

## Tech Stack

- Python 3.9
- FastAPI
- SQLAlchemy
- PostgreSQL
- Docker

## API Endpoints

- `GET /api/payments` - Get all payments
- `GET /api/payments/{payment_id}` - Get payment by ID
- `POST /api/payments` - Create new payment
- `PUT /api/payments/{payment_id}` - Update payment
- `GET /api/payments/order/{order_id}` - Get payments by order ID
- `GET /api/payments/user/{user_id}` - Get payments by user ID

## Running Locally

```bash
pip install -r requirements.txt
uvicorn main:app --reload --port 8084
```

## Running Tests

```bash
pytest
```

## Environment Variables

- `DB_HOST` - Database host
- `DB_PORT` - Database port
- `DB_NAME` - Database name
- `DB_USER` - Database user
- `DB_PASSWORD` - Database password