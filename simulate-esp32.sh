#!/bin/bash

echo "🐾 Alpha Tech - ESP32 Collar Simulation"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Collar configuration
COLLAR_ID="2025"  # Kelmin's collar ID
PET_ID="kelmin-pet-id"  # Kelmin's pet ID
LOST_MODE=false  # Lost mode status
SOUND_ENABLED=false  # Sound alerts enabled
LIGHT_ENABLED=false  # Light alerts enabled

# Medellín coordinates (simulate movement around the city)
# Zona segura: Centro en 6.250000,-75.590000 con radio de 300m
LOCATIONS_SAFE=(
    "6.250000,-75.590000"  # Centro - Zona Segura
    "6.250800,-75.590800"  # Dentro de zona segura
    "6.249200,-75.589200"  # Dentro de zona segura
    "6.250400,-75.589600"  # Dentro de zona segura
    "6.249600,-75.590400"  # Dentro de zona segura
)

LOCATIONS_OUTSIDE=(
    "6.253000,-75.590000"  # Fuera de zona segura - Norte
    "6.247000,-75.590000"  # Fuera de zona segura - Sur
    "6.250000,-75.586000"  # Fuera de zona segura - Este
    "6.250000,-75.594000"  # Fuera de zona segura - Oeste
    "6.252500,-75.587500"  # Fuera de zona segura - Noreste
    "6.247500,-75.592500"  # Fuera de zona segura - Suroeste
)

# Simulate realistic sensor data for Kelmin (Doberman)
simulate_sensor_data() {
    local heart_rate=$((80 + RANDOM % 50))      # 80-130 bpm (larger dog)
    local temperature=$((380 + RANDOM % 20))    # 38.0-40.0°C (in tenths)
    local activity_level=$((1 + RANDOM % 10))   # 1-10 activity level
    local battery_level=$((60 + RANDOM % 40))   # 60-100% battery
    
    echo -e "${BLUE}📊 Sending sensor data...${NC}"
    echo "   Heart Rate: ${heart_rate} bpm"
    echo "   Temperature: $((temperature/10)).$((temperature%10))°C"
    echo "   Activity: ${activity_level}/10"
    echo "   Battery: ${battery_level}%"
    
    curl -s -X POST "http://localhost:3000/sensor-data/collar/${COLLAR_ID}" \
        -H "Content-Type: application/json" \
        -d "{
            \"heartRate\": ${heart_rate},
            \"temperature\": $((temperature/10)).$((temperature%10)),
            \"activityLevel\": ${activity_level},
            \"batteryLevel\": ${battery_level},
            \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\"
        }" > /dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}   ✅ Sensor data sent successfully${NC}"
    else
        echo -e "${RED}   ❌ Failed to send sensor data${NC}"
    fi
}

# Simulate GPS location with geofence logic
simulate_gps_location() {
    # 50% probabilidad de estar en zona segura, 50% fuera (para demo)
    if [ $((RANDOM % 10)) -lt 5 ]; then
        local location=${LOCATIONS_SAFE[$RANDOM % ${#LOCATIONS_SAFE[@]}]}
        local zone_status="SAFE"
    else
        local location=${LOCATIONS_OUTSIDE[$RANDOM % ${#LOCATIONS_OUTSIDE[@]}]}
        local zone_status="OUTSIDE"
    fi
    
    local lat=$(echo $location | cut -d',' -f1)
    local lng=$(echo $location | cut -d',' -f2)
    
    echo -e "${BLUE}📍 Sending GPS location...${NC}"
    echo "   Latitude: ${lat}"
    echo "   Longitude: ${lng}"
    echo "   Location: Medellín, Colombia"
    if [ "$zone_status" = "OUTSIDE" ]; then
        echo -e "   ${RED}⚠️  FUERA DE ZONA SEGURA${NC}"
    else
        echo -e "   ${GREEN}✅ En zona segura${NC}"
    fi
    
    # Send to location service
    curl -s -X POST "http://localhost:3002/location/collar/${COLLAR_ID}/position" \
        -H "Content-Type: application/json" \
        -d "{
            \"collarId\": \"${COLLAR_ID}\",
            \"latitude\": ${lat},
            \"longitude\": ${lng},
            \"accuracy\": $((5 + RANDOM % 10)),
            \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\"
        }" > /dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}   ✅ GPS location sent successfully${NC}"
        
        # Si está fuera de zona segura, enviar alerta de geofence
        if [ "$zone_status" = "OUTSIDE" ]; then
            echo -e "${YELLOW}🚨 Generating geofence alert...${NC}"
            curl -s -X POST "http://localhost:3003/notifications" \
                -H "Content-Type: application/json" \
                -d "{
                    \"type\": \"GEOFENCE_ALERT\",
                    \"title\": \"Alerta de Geofence\",
                    \"message\": \"¡Kelmin ha salido de la zona segura! Ubicación: ${lat}, ${lng}\",
                    \"priority\": \"HIGH\",
                    \"ownerId\": \"6cfc0a78-f926-4993-b88a-c45d17e94487\",
                    \"petId\": \"c9233072-2116-4b8f-87c3-d332893a7f43\",
                    \"petName\": \"kelmin\",
                    \"collarId\": \"${COLLAR_ID}\"
                }" > /dev/null
            echo -e "${GREEN}   ✅ Geofence alert sent${NC}"
        fi
    else
        echo -e "${RED}   ❌ Failed to send GPS location${NC}"
    fi
}

# Simulate emergency notification
simulate_emergency_notification() {
    local notifications=(
        "Geofence Alert: Kelmin has left the safe zone!"
        "Health Alert: Elevated heart rate detected (130 bpm)"
        "Battery Warning: Collar battery is low (15%)"
        "Activity Alert: Kelmin has been inactive for 2 hours"
        "Temperature Alert: High body temperature detected (40.5°C)"
    )
    
    local notification=${notifications[$RANDOM % ${#notifications[@]}]}
    local type_options=("geofence_violation" "health_alert" "battery_low" "inactivity_alert" "temperature_alert")
    local alert_type=${type_options[$RANDOM % ${#type_options[@]}]}
    
    echo -e "${YELLOW}🚨 Sending emergency notification...${NC}"
    echo "   Type: ${alert_type}"
    echo "   Message: ${notification}"
    
    curl -s -X POST "http://localhost:3003/notifications" \
        -H "Content-Type: application/json" \
        -d "{
            \"type\": \"HEALTH_ALERT\",
            \"title\": \"Alpha Tech Alert\",
            \"message\": \"${notification}\",
            \"priority\": \"HIGH\",
            \"ownerId\": \"6cfc0a78-f926-4993-b88a-c45d17e94487\",
            \"petId\": \"c9233072-2116-4b8f-87c3-d332893a7f43\",
            \"petName\": \"kelmin\",
            \"collarId\": \"${COLLAR_ID}\"
        }" > /dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}   ✅ Notification sent successfully${NC}"
    else
        echo -e "${RED}   ❌ Failed to send notification${NC}"
    fi
}

# Simulate lost mode alerts
simulate_lost_mode_alerts() {
    if [ "$LOST_MODE" = "true" ]; then
        echo -e "${RED}🚨 LOST MODE ACTIVE - Emitting sounds and lights${NC}"
        
        if [ "$SOUND_ENABLED" = "true" ]; then
            echo -e "${YELLOW}🔊 Playing distress sound: BEEP BEEP BEEP${NC}"
            echo -e "${YELLOW}   Sound pattern: 3 beeps every 30 seconds${NC}"
        fi
        
        if [ "$LIGHT_ENABLED" = "true" ]; then
            echo -e "${BLUE}💡 Flashing LED lights: BLINK BLINK BLINK${NC}"
            echo -e "${BLUE}   Light pattern: Fast blinking red/blue${NC}"
        fi
        
        echo -e "${YELLOW}📱 QR Code in PRIORITY MODE - Enhanced visibility${NC}"
        
        # Simulate someone noticing the pet
        if [ $((RANDOM % 20)) -eq 0 ]; then  # 5% chance per cycle
            echo -e "${GREEN}👥 Someone noticed the sounds and lights!${NC}"
            echo -e "${GREEN}   Simulating QR scan...${NC}"
            
            # Simulate QR scan
            curl -s "https://prefers-cheapest-blues-parental.trycloudflare.com/qr/found/PETD9DB6E1B" > /dev/null
            echo -e "${GREEN}   ✅ QR Code scanned - Owner notified!${NC}"
        fi
    fi
}

# Check for lost mode commands
check_lost_mode_commands() {
    # Simulate receiving commands from the app
    if [ $((RANDOM % 50)) -eq 0 ]; then  # Random command simulation
        if [ "$LOST_MODE" = "false" ]; then
            echo -e "${RED}📱 Received ACTIVATE_LOST_MODE command${NC}"
            LOST_MODE=true
            SOUND_ENABLED=true
            LIGHT_ENABLED=true
            echo -e "${RED}🚨 LOST MODE ACTIVATED${NC}"
        fi
    fi
}

# Main simulation loop
echo -e "${BLUE}Starting ESP32 collar simulation for Kelmin (Collar ID: ${COLLAR_ID})${NC}"
echo -e "${BLUE}Simulating real-time data every 10 seconds...${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo -e "${YELLOW}Commands: Press 'L' + Enter to toggle Lost Mode${NC}"
echo ""

counter=1
while true; do
    echo -e "${BLUE}=== Simulation Cycle ${counter} ===${NC}"
    
    # Check for lost mode commands
    check_lost_mode_commands
    
    # Always send sensor data and GPS
    simulate_sensor_data
    echo ""
    simulate_gps_location
    echo ""
    
    # Lost mode alerts (if active)
    simulate_lost_mode_alerts
    echo ""
    
    # Randomly send notifications (20% chance)
    if [ $((RANDOM % 5)) -eq 0 ]; then
        simulate_emergency_notification
        echo ""
    fi
    
    echo -e "${BLUE}Waiting 10 seconds for next cycle...${NC}"
    echo "----------------------------------------"
    sleep 10
    
    ((counter++))
done