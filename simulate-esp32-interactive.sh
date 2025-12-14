#!/bin/bash

echo "🐾 Alpha Tech - ESP32 Collar Simulation (Interactive Mode)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Collar configuration
COLLAR_ID="123"
PET_ID="741cac7a-a2e8-4fd1-abdd-878942d5c927"
LOST_MODE=false
SOUND_ENABLED=false
LIGHT_ENABLED=false
SOUND_COUNTER=0

# Locations
LOCATIONS_SAFE=(
    "6.250000,-75.590000"
    "6.250800,-75.590800"
    "6.249200,-75.589200"
)

LOCATIONS_OUTSIDE=(
    "6.253000,-75.590000"
    "6.247000,-75.590000"
    "6.250000,-75.586000"
)

# Function to simulate lost mode alerts
simulate_lost_mode_alerts() {
    if [ "$LOST_MODE" = "true" ]; then
        echo -e "${RED}🚨 LOST MODE ACTIVE${NC}"
        
        if [ "$SOUND_ENABLED" = "true" ]; then
            ((SOUND_COUNTER++))
            if [ $((SOUND_COUNTER % 3)) -eq 0 ]; then  # Every 3 cycles (30 seconds)
                echo -e "${YELLOW}🔊 BEEP BEEP BEEP - Distress sound emitted${NC}"
                echo -e "${YELLOW}   Volume: HIGH | Pattern: 3 short beeps${NC}"
            fi
        fi
        
        if [ "$LIGHT_ENABLED" = "true" ]; then
            echo -e "${BLUE}💡 LED FLASHING: Red/Blue alternating${NC}"
            echo -e "${BLUE}   Pattern: Fast blink (500ms intervals)${NC}"
        fi
        
        # Simulate people noticing
        if [ $((RANDOM % 15)) -eq 0 ]; then
            echo -e "${GREEN}👥 Someone noticed the sounds and lights!${NC}"
            echo -e "${GREEN}   Approaching to check the QR code...${NC}"
            
            # Simulate QR scan
            sleep 2
            curl -s "https://interesting-civilization-beauty-decided.trycloudflare.com/qr/found/PETD9DB6E1B" > /dev/null 2>&1
            echo -e "${GREEN}   📱 QR Code scanned successfully!${NC}"
            echo -e "${GREEN}   🔔 Owner notification sent!${NC}"
        fi
    fi
}

# Function to send sensor data
send_sensor_data() {
    local heart_rate=$((80 + RANDOM % 50))
    local temperature=$((380 + RANDOM % 20))
    local activity_level=$((1 + RANDOM % 10))
    local battery_level=$((60 + RANDOM % 40))
    
    echo -e "${BLUE}📊 Sensor Data:${NC}"
    echo "   ❤️  Heart Rate: ${heart_rate} bpm"
    echo "   🌡️  Temperature: $((temperature/10)).$((temperature%10))°C"
    echo "   🏃 Activity: ${activity_level}/10"
    echo "   🔋 Battery: ${battery_level}%"
    
    curl -s -X POST "https://interesting-civilization-beauty-decided.trycloudflare.com/sensor-data/collar/${COLLAR_ID}" \
        -H "Content-Type: application/json" \
        -d "{
            \"heartRate\": ${heart_rate},
            \"temperature\": $((temperature/10)).$((temperature%10)),
            \"activityLevel\": ${activity_level},
            \"batteryLevel\": ${battery_level},
            \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\"
        }" > /dev/null 2>&1
}

# Function to send GPS location
send_gps_location() {
    if [ $((RANDOM % 10)) -lt 7 ]; then
        local location=${LOCATIONS_SAFE[$RANDOM % ${#LOCATIONS_SAFE[@]}]}
        local zone_status="SAFE"
    else
        local location=${LOCATIONS_OUTSIDE[$RANDOM % ${#LOCATIONS_OUTSIDE[@]}]}
        local zone_status="OUTSIDE"
    fi
    
    local lat=$(echo $location | cut -d',' -f1)
    local lng=$(echo $location | cut -d',' -f2)
    
    echo -e "${BLUE}📍 GPS Location:${NC}"
    echo "   🗺️  Lat: ${lat}, Lng: ${lng}"
    if [ "$zone_status" = "OUTSIDE" ]; then
        echo -e "   ${RED}⚠️  OUTSIDE SAFE ZONE${NC}"
    else
        echo -e "   ${GREEN}✅ Inside safe zone${NC}"
    fi
    
    curl -s -X POST "https://nobody-advancement-charleston-latitude.trycloudflare.com/location/collar/${COLLAR_ID}/position" \
        -H "Content-Type: application/json" \
        -d "{
            \"collarId\": \"${COLLAR_ID}\",
            \"latitude\": ${lat},
            \"longitude\": ${lng},
            \"accuracy\": $((5 + RANDOM % 10)),
            \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\"
        }" > /dev/null 2>&1
}

# Function to toggle lost mode
toggle_lost_mode() {
    if [ "$LOST_MODE" = "true" ]; then
        LOST_MODE=false
        SOUND_ENABLED=false
        LIGHT_ENABLED=false
        SOUND_COUNTER=0
        echo -e "${GREEN}✅ Lost mode DEACTIVATED${NC}"
    else
        LOST_MODE=true
        SOUND_ENABLED=true
        LIGHT_ENABLED=true
        SOUND_COUNTER=0
        echo -e "${RED}🚨 Lost mode ACTIVATED${NC}"
        echo -e "${RED}   - Sound alerts: ENABLED${NC}"
        echo -e "${RED}   - Light alerts: ENABLED${NC}"
        echo -e "${RED}   - QR priority mode: ACTIVE${NC}"
    fi
}

# Function to show help
show_help() {
    echo -e "${PURPLE}📋 Available Commands:${NC}"
    echo "   L - Toggle Lost Mode"
    echo "   S - Manual sound test"
    echo "   F - Manual light flash"
    echo "   Q - Show QR URL"
    echo "   H - Show this help"
    echo "   X - Exit simulation"
}

# Main simulation
echo -e "${BLUE}Starting Interactive ESP32 Collar Simulation${NC}"
echo -e "${BLUE}Collar ID: ${COLLAR_ID} | Pet: Max (Pastor Alemán)${NC}"
echo ""
show_help
echo ""

counter=1
while true; do
    echo -e "${BLUE}=== Cycle ${counter} ===${NC}"
    
    # Send data
    send_sensor_data
    echo ""
    send_gps_location
    echo ""
    
    # Lost mode alerts
    simulate_lost_mode_alerts
    echo ""
    
    # Show status
    if [ "$LOST_MODE" = "true" ]; then
        echo -e "${RED}🔴 STATUS: LOST MODE ACTIVE${NC}"
    else
        echo -e "${GREEN}🟢 STATUS: Normal operation${NC}"
    fi
    
    echo -e "${YELLOW}Commands: L(ost) S(ound) F(lash) Q(R) H(elp) X(exit)${NC}"
    echo "Next cycle in 10 seconds..."
    
    # Wait for input with timeout
    read -t 10 -n 1 input
    case $input in
        [Ll])
            echo ""
            toggle_lost_mode
            ;;
        [Ss])
            echo ""
            echo -e "${YELLOW}🔊 BEEP BEEP BEEP - Manual sound test${NC}"
            ;;
        [Ff])
            echo ""
            echo -e "${BLUE}💡 FLASH FLASH FLASH - Manual light test${NC}"
            ;;
        [Qq])
            echo ""
            echo -e "${PURPLE}🏷️ QR URL: https://interesting-civilization-beauty-decided.trycloudflare.com/qr/found/PETD9DB6E1B${NC}"
            ;;
        [Hh])
            echo ""
            show_help
            ;;
        [Xx])
            echo ""
            echo -e "${GREEN}👋 Stopping ESP32 simulation...${NC}"
            exit 0
            ;;
    esac
    
    echo "----------------------------------------"
    ((counter++))
done