#!/bin/bash

echo "🏷️ Starting Alpha Tech QR Service..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd alpha-tech-qr-service

echo -e "${BLUE}Installing dependencies...${NC}"
npm install

echo -e "${BLUE}Starting QR Service on port 3004...${NC}"
echo -e "${YELLOW}QR Service will handle URLs like: http://localhost:3004/found/PETD9DB6E1B${NC}"
echo -e "${GREEN}Press Ctrl+C to stop${NC}"
echo ""

npm start