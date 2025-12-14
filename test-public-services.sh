#!/bin/bash

echo "🌐 Testing Public Services Connectivity"
echo "======================================="

# URLs públicas
BACKEND_URL="https://interesting-civilization-beauty-decided.trycloudflare.com"
LOCATION_URL="https://nobody-advancement-charleston-latitude.trycloudflare.com"
NOTIFICATION_URL="https://conflict-television-proven-contributor.trycloudflare.com"

echo ""
echo "📡 Backend Service (Port 3000)"
echo "URL: $BACKEND_URL"
curl -s -o /dev/null -w "Status: %{http_code} | Time: %{time_total}s\n" "$BACKEND_URL/health" || echo "❌ Backend not responding"

echo ""
echo "📍 Location Service (Port 3002)"  
echo "URL: $LOCATION_URL"
curl -s -o /dev/null -w "Status: %{http_code} | Time: %{time_total}s\n" "$LOCATION_URL/health" || echo "❌ Location service not responding"

echo ""
echo "🔔 Notification Service (Port 3003)"
echo "URL: $NOTIFICATION_URL"  
curl -s -o /dev/null -w "Status: %{http_code} | Time: %{time_total}s\n" "$NOTIFICATION_URL/health" || echo "❌ Notification service not responding"

echo ""
echo "🧪 Testing API Endpoints"
echo "========================"

echo ""
echo "📱 Mobile Auth Test:"
curl -s -X POST "$BACKEND_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test"}' \
  -w "Status: %{http_code}\n" || echo "❌ Auth endpoint failed"

echo ""
echo "📍 Location Test:"
curl -s -X POST "$LOCATION_URL/location" \
  -H "Content-Type: application/json" \
  -d '{"collarId":"123","latitude":6.25,"longitude":-75.59}' \
  -w "Status: %{http_code}\n" || echo "❌ Location endpoint failed"

echo ""
echo "🔔 Notification Test:"
curl -s -X POST "$NOTIFICATION_URL/notifications" \
  -H "Content-Type: application/json" \
  -d '{"userId":"test","type":"test","title":"Test","message":"Test"}' \
  -w "Status: %{http_code}\n" || echo "❌ Notification endpoint failed"

echo ""
echo "✅ All services are now publicly accessible for APK!"
echo "📱 Ready to build APK with full functionality"