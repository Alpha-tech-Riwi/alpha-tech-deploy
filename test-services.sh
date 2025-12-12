#!/bin/bash

echo "🧪 Testing Alpha Tech Services"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test function
test_endpoint() {
    local url=$1
    local name=$2
    
    echo -n "Testing $name... "
    if curl -s -f "$url" > /dev/null; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        return 1
    fi
}

# Wait for services
echo -e "${BLUE}Waiting for services to start...${NC}"
sleep 30

# Test all endpoints
echo -e "${BLUE}Running health checks:${NC}"
test_endpoint "http://localhost:3000/health" "Backend"
test_endpoint "http://localhost:3002/health" "Location Service"
test_endpoint "http://localhost:3003/health" "Notification Service"
test_endpoint "http://localhost:5173" "Frontend"

# Test GPS endpoint
echo -e "${BLUE}Testing GPS functionality:${NC}"
echo -n "Sending GPS data... "
response=$(curl -s -X POST http://localhost:3002/location \
  -H "Content-Type: application/json" \
  -d '{"collarId":"123456","latitude":6.250000,"longitude":-75.590000}')

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✅ GPS OK${NC}"
else
    echo -e "${RED}❌ GPS FAIL${NC}"
fi

# Test notification endpoint
echo -e "${BLUE}Testing Notification functionality:${NC}"
echo -n "Sending notification... "
response=$(curl -s -X POST http://localhost:3003/notifications \
  -H "Content-Type: application/json" \
  -d '{"userId":"user123","type":"test","title":"Test","message":"Test message"}')

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✅ Notifications OK${NC}"
else
    echo -e "${RED}❌ Notifications FAIL${NC}"
fi

echo -e "${BLUE}🎉 Testing completed!${NC}"
echo -e "${BLUE}Access your app at: http://localhost:5173${NC}"