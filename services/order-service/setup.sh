#!/bin/bash

# Order Service Setup Script

echo "Setting up Order Service..."

# Create database (requires PostgreSQL to be running)
echo "Creating order database..."
psql -U postgres -c "CREATE DATABASE orderdb;"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE orderdb TO postgres;"

# Build the service
echo "Building Order Service..."
mvn clean package -DskipTests

# Run the service
echo "Starting Order Service..."
java -jar target/order-service-1.0.0.jar

echo "Order Service is running on http://localhost:8083"