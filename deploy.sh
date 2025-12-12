#!/bin/bash

echo "🚀 Alpha Tech Deployment Script"

# Variables
REPO_URL="https://github.com/Alpha-tech-Riwi"
DEPLOY_DIR="/opt/alpha-tech"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create deployment directory
log_info "Creating deployment directory..."
sudo mkdir -p $DEPLOY_DIR
cd $DEPLOY_DIR

# Clone repositories
log_info "Cloning repositories..."
git clone $REPO_URL/alpha-tech-backend.git || log_error "Failed to clone backend"
git clone $REPO_URL/alpha-tech-location.git || log_error "Failed to clone location service"
git clone $REPO_URL/alpha-tech-notifications.git || log_error "Failed to clone notification service"

# Build Docker images
log_info "Building Docker images..."
cd alpha-tech-location && docker build -t alpha-tech-location:latest . && cd ..
cd alpha-tech-notifications && docker build -t alpha-tech-notifications:latest . && cd ..

# Copy production files
log_info "Setting up production configuration..."
cp docker-compose.production.yml docker-compose.yml
cp nginx.conf .

# Set environment variables
log_info "Setting up environment variables..."
cat > .env << EOF
DATABASE_HOST=postgres
DATABASE_PASSWORD=${DB_PASSWORD:-your_secure_password}
JWT_SECRET=${JWT_SECRET:-your_jwt_secret}
NODE_ENV=production
EOF

# Start services
log_info "Starting services..."
docker-compose down
docker-compose up -d

# Wait for services
log_info "Waiting for services to start..."
sleep 30

# Health check
log_info "Running health checks..."
curl -f http://localhost/api/health || log_error "Backend health check failed"
curl -f http://localhost/location/health || log_error "Location service health check failed"
curl -f http://localhost/notifications/health || log_error "Notification service health check failed"

log_success "Deployment completed successfully!"
log_info "Services running on:"
log_info "  Frontend: http://your-domain.com"
log_info "  Backend API: http://your-domain.com/api"
log_info "  Location API: http://your-domain.com/location"
log_info "  Notifications API: http://your-domain.com/notifications"