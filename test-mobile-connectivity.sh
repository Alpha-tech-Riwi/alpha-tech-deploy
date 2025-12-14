#!/bin/bash

echo "🧪 Alpha Tech - Mobile App Connectivity Test"
echo "=============================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get local IP
LOCAL_IP=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+')
echo -e "${BLUE}📱 Testing connectivity for mobile app${NC}"
echo -e "${BLUE}🌐 Local IP: ${LOCAL_IP}${NC}"
echo ""

# Test Backend Auth
echo -e "${BLUE}🔐 Testing Backend Auth (Port 3000)...${NC}"
AUTH_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/auth_test http://${LOCAL_IP}:3000/auth/login \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test"}')

if [ "$AUTH_RESPONSE" = "401" ]; then
    echo -e "${GREEN}✅ Auth endpoint responding (401 expected for invalid credentials)${NC}"
else
    echo -e "${RED}❌ Auth endpoint issue: HTTP $AUTH_RESPONSE${NC}"
fi

# Test Mobile Service
echo -e "${BLUE}📱 Testing Mobile Service (Port 3007)...${NC}"
MOBILE_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/mobile_test http://${LOCAL_IP}:3007/mobile/pets/e032669a-a290-4186-a384-3650ebce6c89)

if [ "$MOBILE_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Mobile Service responding correctly${NC}"
    echo -e "${GREEN}   Pet data: $(cat /tmp/mobile_test | jq -r '.pets[0].name' 2>/dev/null || echo 'Data available')${NC}"
else
    echo -e "${RED}❌ Mobile Service issue: HTTP $MOBILE_RESPONSE${NC}"
fi

# Test Emergency Endpoint
echo -e "${BLUE}🚨 Testing Emergency Endpoint...${NC}"
EMERGENCY_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/emergency_test http://${LOCAL_IP}:3000/collar/emergency \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"petId":"test","action":"TEST"}')

if [ "$EMERGENCY_RESPONSE" = "200" ] || [ "$EMERGENCY_RESPONSE" = "201" ] || [ "$EMERGENCY_RESPONSE" = "400" ]; then
    echo -e "${GREEN}✅ Emergency endpoint responding${NC}"
else
    echo -e "${RED}❌ Emergency endpoint issue: HTTP $EMERGENCY_RESPONSE${NC}"
fi

# Test Location Service
echo -e "${BLUE}📍 Testing Location Service (Port 3002)...${NC}"
LOCATION_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/location_test http://${LOCAL_IP}:3002/location/collar/123/latest)

if [ "$LOCATION_RESPONSE" = "200" ] || [ "$LOCATION_RESPONSE" = "404" ]; then
    echo -e "${GREEN}✅ Location Service responding${NC}"
else
    echo -e "${RED}❌ Location Service issue: HTTP $LOCATION_RESPONSE${NC}"
fi

echo ""
echo -e "${YELLOW}📋 Mobile App Configuration:${NC}"
echo -e "${BLUE}   API_URL: http://${LOCAL_IP}:3000${NC}"
echo -e "${BLUE}   Mobile Service: http://${LOCAL_IP}:3007${NC}"
echo ""

echo -e "${YELLOW}🔧 APK Connection Status:${NC}"
if [ "$AUTH_RESPONSE" = "401" ] && [ "$MOBILE_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ APK should connect successfully${NC}"
    echo -e "${GREEN}✅ All required endpoints are working${NC}"
    echo ""
    echo -e "${YELLOW}📱 To test in APK:${NC}"
    echo -e "${BLUE}   1. Open Alpha Tech app${NC}"
    echo -e "${BLUE}   2. Try login (should show error for invalid credentials)${NC}"
    echo -e "${BLUE}   3. Backend will respond with proper error messages${NC}"
    echo -e "${BLUE}   4. Pet data should load from mobile service${NC}"
else
    echo -e "${RED}❌ Some endpoints may have issues${NC}"
    echo -e "${YELLOW}   Check Docker services: docker-compose -f docker-compose.local.yml logs${NC}"
fi

echo ""
echo -e "${YELLOW}🎯 Next Steps:${NC}"
echo -e "${BLUE}   • Install APK on your phone${NC}"
echo -e "${BLUE}   • Make sure phone is on same WiFi network${NC}"
echo -e "${BLUE}   • Test login functionality${NC}"
echo -e "${BLUE}   • Verify pet data loads${NC}"
echo -e "${BLUE}   • Test emergency mode activation${NC}"

# Cleanup temp files
rm -f /tmp/auth_test /tmp/mobile_test /tmp/emergency_test /tmp/location_test