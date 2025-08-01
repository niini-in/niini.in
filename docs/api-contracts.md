# MiniShop API Contracts

## Overview

This document defines the API contracts for the MiniShop e-commerce platform. It serves as the source of truth for all service interfaces and ensures consistency across the platform.

## API Design Principles

- **REST-based**: Follow REST principles for resource-oriented APIs
- **Consistent**: Maintain consistent patterns across all services
- **Versioned**: All APIs are versioned to allow for evolution
- **Documented**: OpenAPI/Swagger documentation for all endpoints
- **Secure**: Authentication and authorization for all endpoints

## API Gateway

All client requests go through the API Gateway at `api.niini.in`. The gateway handles:

- Authentication and authorization
- Request routing to appropriate services
- Rate limiting
- Response caching (where appropriate)
- Request/response logging

## Common Patterns

### URL Structure

```
https://api.niini.in/v1/{service}/{resource}/{id}
```

Example: `https://api.niini.in/v1/products/categories/123`

### HTTP Methods

- `GET`: Retrieve resources
- `POST`: Create resources
- `PUT`: Update resources (full update)
- `PATCH`: Partial update of resources
- `DELETE`: Remove resources

### Request Headers

```
Authorization: Bearer {jwt_token}
Content-Type: application/json
Accept: application/json
X-Request-ID: {unique_request_id}
```

### Response Format

Successful response:

```json
{
  "data": { ... },
  "meta": {
    "timestamp": "2023-05-15T14:22:10.123Z",
    "request_id": "abc-123-def-456"
  }
}
```

Error response:

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "The requested resource was not found",
    "details": { ... },
    "request_id": "abc-123-def-456"
  }
}
```

### Pagination

Request:

```
GET /v1/products?page=2&per_page=20
```

Response:

```json
{
  "data": [ ... ],
  "meta": {
    "page": 2,
    "per_page": 20,
    "total_pages": 10,
    "total_items": 198
  }
}
```

### Filtering

```
GET /v1/products?category=electronics&price_min=100&price_max=500&sort=price_asc
```

### Error Codes

| HTTP Status | Error Code | Description |
|-------------|------------|-------------|
| 400 | INVALID_REQUEST | The request is malformed or invalid |
| 401 | UNAUTHORIZED | Authentication is required |
| 403 | FORBIDDEN | The user doesn't have permission |
| 404 | RESOURCE_NOT_FOUND | The requested resource was not found |
| 409 | CONFLICT | The request conflicts with the current state |
| 422 | VALIDATION_ERROR | The request data failed validation |
| 429 | RATE_LIMIT_EXCEEDED | Too many requests |
| 500 | INTERNAL_ERROR | An unexpected error occurred |

## Service APIs

### User Service

#### Authentication

```
POST /v1/users/auth/login
```

Request:

```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

Response:

```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "abc123def456...",
    "expires_in": 3600
  }
}
```

#### User Registration

```
POST /v1/users
```

Request:

```json
{
  "email": "newuser@example.com",
  "password": "securepassword",
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+1234567890"
}
```

Response:

```json
{
  "data": {
    "id": "user123",
    "email": "newuser@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "created_at": "2023-05-15T14:22:10.123Z"
  }
}
```

#### Get User Profile

```
GET /v1/users/me
```

Response:

```json
{
  "data": {
    "id": "user123",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "phone": "+1234567890",
    "addresses": [
      {
        "id": "addr456",
        "type": "shipping",
        "street": "123 Main St",
        "city": "Anytown",
        "state": "CA",
        "postal_code": "12345",
        "country": "US",
        "is_default": true
      }
    ],
    "created_at": "2023-01-15T10:30:00.000Z",
    "updated_at": "2023-05-10T15:45:20.123Z"
  }
}
```

### Product Service

#### Get Products

```
GET /v1/products
```

Response:

```json
{
  "data": [
    {
      "id": "prod123",
      "name": "Smartphone X",
      "description": "Latest smartphone with amazing features",
      "price": 999.99,
      "currency": "USD",
      "category_id": "cat456",
      "inventory": {
        "available": 42,
        "reserved": 3
      },
      "images": [
        {
          "url": "https://cdn.niini.in/products/prod123/main.jpg",
          "type": "main"
        }
      ],
      "attributes": {
        "color": "black",
        "storage": "128GB",
        "dimensions": "150x75x8mm"
      },
      "created_at": "2023-03-10T09:20:30.123Z",
      "updated_at": "2023-05-12T11:15:45.678Z"
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total_pages": 5,
    "total_items": 87
  }
}
```

#### Get Product by ID

```
GET /v1/products/{id}
```

Response:

```json
{
  "data": {
    "id": "prod123",
    "name": "Smartphone X",
    "description": "Latest smartphone with amazing features",
    "price": 999.99,
    "currency": "USD",
    "category_id": "cat456",
    "inventory": {
      "available": 42,
      "reserved": 3
    },
    "images": [
      {
        "url": "https://cdn.niini.in/products/prod123/main.jpg",
        "type": "main"
      },
      {
        "url": "https://cdn.niini.in/products/prod123/side.jpg",
        "type": "gallery"
      }
    ],
    "attributes": {
      "color": "black",
      "storage": "128GB",
      "dimensions": "150x75x8mm"
    },
    "related_products": ["prod124", "prod125"],
    "created_at": "2023-03-10T09:20:30.123Z",
    "updated_at": "2023-05-12T11:15:45.678Z"
  }
}
```

### Order Service

#### Create Order

```
POST /v1/orders
```

Request:

```json
{
  "items": [
    {
      "product_id": "prod123",
      "quantity": 1,
      "unit_price": 999.99
    },
    {
      "product_id": "prod456",
      "quantity": 2,
      "unit_price": 29.99
    }
  ],
  "shipping_address_id": "addr789",
  "billing_address_id": "addr789",
  "shipping_method": "standard",
  "payment_method_id": "pm123"
}
```

Response:

```json
{
  "data": {
    "id": "order123",
    "user_id": "user456",
    "status": "pending_payment",
    "items": [
      {
        "id": "item789",
        "product_id": "prod123",
        "product_name": "Smartphone X",
        "quantity": 1,
        "unit_price": 999.99,
        "total_price": 999.99
      },
      {
        "id": "item790",
        "product_id": "prod456",
        "product_name": "Phone Case",
        "quantity": 2,
        "unit_price": 29.99,
        "total_price": 59.98
      }
    ],
    "subtotal": 1059.97,
    "shipping_fee": 15.00,
    "tax": 106.00,
    "total": 1180.97,
    "currency": "USD",
    "shipping_address": {
      "street": "123 Main St",
      "city": "Anytown",
      "state": "CA",
      "postal_code": "12345",
      "country": "US"
    },
    "shipping_method": "standard",
    "payment_method": "credit_card",
    "payment_status": "pending",
    "created_at": "2023-05-15T14:22:10.123Z"
  }
}
```

#### Get Order by ID

```
GET /v1/orders/{id}
```

Response:

```json
{
  "data": {
    "id": "order123",
    "user_id": "user456",
    "status": "processing",
    "items": [...],
    "subtotal": 1059.97,
    "shipping_fee": 15.00,
    "tax": 106.00,
    "total": 1180.97,
    "currency": "USD",
    "shipping_address": {...},
    "shipping_method": "standard",
    "tracking_number": "1Z999AA10123456784",
    "payment_method": "credit_card",
    "payment_status": "paid",
    "payment_details": {
      "transaction_id": "txn_123456",
      "payment_processor": "stripe"
    },
    "created_at": "2023-05-15T14:22:10.123Z",
    "updated_at": "2023-05-15T14:30:45.678Z"
  }
}
```

### Payment Service

#### Process Payment

```
POST /v1/payments
```

Request:

```json
{
  "order_id": "order123",
  "payment_method_id": "pm123",
  "amount": 1180.97,
  "currency": "USD"
}
```

Response:

```json
{
  "data": {
    "id": "pmt456",
    "order_id": "order123",
    "status": "succeeded",
    "amount": 1180.97,
    "currency": "USD",
    "payment_method": "credit_card",
    "transaction_id": "txn_123456",
    "created_at": "2023-05-15T14:25:30.123Z"
  }
}
```

### Notification Service

#### Send Notification

```
POST /v1/notifications
```

Request:

```json
{
  "user_id": "user456",
  "type": "email",
  "template": "order_confirmation",
  "data": {
    "order_id": "order123",
    "order_total": 1180.97,
    "shipping_method": "standard"
  }
}
```

Response:

```json
{
  "data": {
    "id": "notif789",
    "user_id": "user456",
    "type": "email",
    "status": "sent",
    "created_at": "2023-05-15T14:26:45.123Z"
  }
}
```

## Webhooks

MiniShop provides webhooks for integrating with external systems.

### Webhook Format

```json
{
  "event": "order.created",
  "timestamp": "2023-05-15T14:22:10.123Z",
  "data": {
    "order_id": "order123",
    "user_id": "user456",
    "total": 1180.97,
    "currency": "USD"
  }
}
```

### Available Events

| Event | Description |
|-------|-------------|
| `user.created` | A new user has registered |
| `order.created` | A new order has been created |
| `order.updated` | An order's status has changed |
| `payment.succeeded` | A payment has been successfully processed |
| `payment.failed` | A payment has failed |
| `product.low_stock` | A product's inventory is running low |

## API Versioning

API versioning is handled through the URL path. When breaking changes are introduced, a new version is created.

Example:
- Current version: `/v1/products`
- New version: `/v2/products`

Old versions are supported for a minimum of 6 months after a new version is released.

## Rate Limiting

API requests are rate-limited to protect the system from abuse. Rate limits are applied per API key and vary by endpoint.

Default rate limits:
- 100 requests per minute for authenticated users
- 20 requests per minute for unauthenticated users

Rate limit headers are included in all responses:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1589547420
```

## Authentication

MiniShop uses JWT (JSON Web Tokens) for authentication. Tokens are obtained through the login endpoint and must be included in the `Authorization` header of all authenticated requests.

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## OpenAPI Documentation

Complete OpenAPI/Swagger documentation is available for all services:

- User Service: `https://api.niini.in/docs/user-service`
- Product Service: `https://api.niini.in/docs/product-service`
- Order Service: `https://api.niini.in/docs/order-service`
- Payment Service: `https://api.niini.in/docs/payment-service`
- Notification Service: `https://api.niini.in/docs/notification-service`

## SDK Libraries

Client SDKs are available for easy integration:

- JavaScript/TypeScript: `@minishop/js-sdk`
- Python: `minishop-python-sdk`
- Java: `com.niini.minishop.sdk`
- Go: `github.com/niini/minishop-go-sdk`

## Changelog

### v1.0.0 (2023-05-01)

- Initial release of the MiniShop API

### v1.1.0 (2023-06-15)

- Added product recommendations endpoint
- Enhanced order filtering capabilities
- Improved error messages