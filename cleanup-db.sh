#!/bin/bash

echo "🧹 Cleaning up Alpha Tech database..."

# Stop services
echo "Stopping services..."
docker-compose -f docker-compose.local.yml down

# Remove volumes to clean database
echo "Removing database volumes..."
docker volume rm alpha-tech-deploy_postgres_data 2>/dev/null || true
docker volume rm alpha-tech-deploy_redis_data 2>/dev/null || true

# Start only database services first
echo "Starting database services..."
docker-compose -f docker-compose.local.yml up -d postgres redis

# Wait for database to be ready
echo "Waiting for database to be ready..."
sleep 10

# Start all services
echo "Starting all services..."
docker-compose -f docker-compose.local.yml up -d

echo "✅ Database cleanup complete!"
echo "🚀 All services are starting up..."
echo ""
echo "Access URLs:"
echo "- Frontend: http://localhost:5173"
echo "- Backend API: http://localhost:3000"
echo "- Location Service: http://localhost:3002"
echo "- Notification Service: http://localhost:3003"