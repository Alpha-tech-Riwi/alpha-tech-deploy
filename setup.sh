#!/bin/bash

echo "🚀 Alpha Tech - Setup Script"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Clone all repositories
log_info "Cloning Alpha Tech repositories..."

# Backend + Frontend
if [ ! -d "alpha-tech-backend" ]; then
    git clone https://github.com/Alpha-tech-Riwi/alpha-tech-backend.git
    log_success "Backend cloned"
else
    log_info "Backend already exists, pulling latest..."
    cd alpha-tech-backend && git pull && cd ..
fi

# Location Service
if [ ! -d "alpha-tech-location" ]; then
    git clone https://github.com/Alpha-tech-Riwi/alpha-tech-location.git
    log_success "Location service cloned"
else
    log_info "Location service already exists, pulling latest..."
    cd alpha-tech-location && git pull && cd ..
fi

# Notification Service
if [ ! -d "alpha-tech-notifications" ]; then
    git clone https://github.com/Alpha-tech-Riwi/alpha-tech-notifications.git
    log_success "Notification service cloned"
else
    log_info "Notification service already exists, pulling latest..."
    cd alpha-tech-notifications && git pull && cd ..
fi

# Frontend
if [ ! -d "alpha-tech-frontend" ]; then
    git clone https://github.com/Alpha-tech-Riwi/alpha-tech-frontend.git
    log_success "Frontend cloned"
else
    log_info "Frontend already exists, pulling latest..."
    cd alpha-tech-frontend && git pull && cd ..
fi

# Create symlinks for docker-compose
log_info "Creating symlinks for Docker Compose..."
ln -sf alpha-tech-backend Alpha_Tech 2>/dev/null || true
ln -sf alpha-tech-location location-service 2>/dev/null || true
ln -sf alpha-tech-notifications notification-service 2>/dev/null || true

log_success "Setup completed!"
log_info "Run: docker-compose -f docker-compose.local.yml up --build"