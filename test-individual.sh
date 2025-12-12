#!/bin/bash

echo "🧪 Alpha Tech - Individual API Tests"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

COLLAR_ID="123"

echo -e "${BLUE}1. Testing Sensor Data Endpoint${NC}"
curl -X POST "http://localhost:3000/sensor-data/collar/${COLLAR_ID}" \
    -H "Content-Type: application/json" \
    -d '{
        "heartRate": 85,
        "temperature": 38.5,
        "activityLevel": 7,
        "batteryLevel": 85,
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'"
    }'
echo -e "\n${GREEN}✅ Sensor data test completed${NC}\n"

echo -e "${BLUE}2. Testing GPS Location Endpoint${NC}"
curl -X POST "http://localhost:3002/location/collar/${COLLAR_ID}/position" \
    -H "Content-Type: application/json" \
    -d '{
        "collarId": "'${COLLAR_ID}'",
        "latitude": 6.250000,
        "longitude": -75.590000,
        "accuracy": 8,
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'"
    }'
echo -e "\n${GREEN}✅ GPS location test completed${NC}\n"

echo -e "${BLUE}3. Testing Emergency Notification${NC}"
curl -X POST "http://localhost:3003/notifications" \
    -H "Content-Type: application/json" \
    -d '{
        "type": "HEALTH_ALERT",
        "title": "Test Alert",
        "message": "Leon heart rate is elevated: 120 bpm",
        "priority": "HIGH",
        "ownerId": "5545f4b0-77f1-4a94-b752-00e5c3aa1ab5",
        "petId": "c9233072-2116-4b8f-87c3-d332893a7f43",
        "petName": "leon",
        "collarId": "123"
    }'
echo -e "\n${GREEN}✅ Notification test completed${NC}\n"

echo -e "${BLUE}4. Testing Geofence Alert${NC}"
curl -X POST "http://localhost:3003/notifications" \
    -H "Content-Type: application/json" \
    -d '{
        "type": "GEOFENCE_EXIT",
        "title": "Geofence Alert",
        "message": "Leon has left the safe zone at Parque Lleras",
        "priority": "CRITICAL",
        "ownerId": "5545f4b0-77f1-4a94-b752-00e5c3aa1ab5",
        "petId": "c9233072-2116-4b8f-87c3-d332893a7f43",
        "petName": "leon",
        "collarId": "123"
    }'
echo -e "\n${GREEN}✅ Geofence alert test completed${NC}\n"

echo -e "${YELLOW}🎉 All individual tests completed!${NC}"
echo -e "${BLUE}Check your dashboard at: http://localhost:5173${NC}"