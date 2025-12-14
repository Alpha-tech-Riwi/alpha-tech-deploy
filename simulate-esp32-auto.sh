#!/bin/bash

# Simulación automática del collar ESP32 con datos del usuario
echo "🐕 Alpha Tech - Simulación Automática del Collar"
echo "================================================"
echo "Collar ID: 123 | Mascota: Max | Usuario: Demo"
echo "Conectando a servicios públicos..."
echo ""

# URLs de servicios públicos
LOCATION_URL="https://nobody-advancement-charleston-latitude.trycloudflare.com"
BACKEND_URL="https://interesting-civilization-beauty-decided.trycloudflare.com"

# Datos reales del collar/mascota
COLLAR_ID="123"
PET_NAME="Max"
USER_ID="e0326699a-a290-4186-a384-3650ebce6c89"
USER_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlMDMyNjY5YS1hMjkwLTQxODYtYTM4NC0zNjUwZWJjZTZjODkiLCJlbWFpbCI6Im5vYWgxMjNAbWFpbC5jb20iLCJpYXQiOjE3NjU3MjkzNDksImV4cCI6MTc2NTgxNTc0OX0.dRhNnooeLY_NuxmuK7Va4Z2jBJyqawqSZRaLDNbhyrc"

# Coordenadas base (Medellín)
BASE_LAT=6.250000
BASE_LNG=-75.590000

cycle=1
while true; do
    echo "========================================"
    echo "=== Ciclo $cycle - $(date '+%H:%M:%S') ==="
    
    # Generar datos de sensores realistas para Max (Pastor Alemán)
    HEART_RATE=$((80 + RANDOM % 25))  # 80-105 bpm normal para perro grande
    TEMPERATURE=$(echo "scale=1; 38.5 + ($RANDOM % 15) / 10" | bc)  # 38.5-40°C
    ACTIVITY=$((1 + RANDOM % 8))  # Actividad variable
    BATTERY=$((55 + RANDOM % 35))  # 55-90% batería
    
    # Pequeña variación en GPS
    LAT_OFFSET=$(echo "scale=6; ($RANDOM % 200 - 100) / 100000" | bc)
    LNG_OFFSET=$(echo "scale=6; ($RANDOM % 200 - 100) / 100000" | bc)
    LATITUDE=$(echo "scale=6; $BASE_LAT + $LAT_OFFSET" | bc)
    LONGITUDE=$(echo "scale=6; $BASE_LNG + $LNG_OFFSET" | bc)
    
    echo "📊 Datos del Sensor:"
    echo "   ❤️  Ritmo Cardíaco: $HEART_RATE bpm"
    echo "   🌡️  Temperatura: ${TEMPERATURE}°C"
    echo "   🏃 Actividad: $ACTIVITY/10"
    echo "   🔋 Batería: $BATTERY%"
    echo ""
    echo "📍 Ubicación GPS:"
    echo "   🗺️  Lat: $LATITUDE, Lng: $LONGITUDE"
    echo "   ✅ Dentro de zona segura"
    echo ""
    
    # Enviar datos de ubicación
    curl -s -X POST "$LOCATION_URL/location" \
        -H "Content-Type: application/json" \
        -d "{
            \"collarId\": \"$COLLAR_ID\",
            \"latitude\": $LATITUDE,
            \"longitude\": $LONGITUDE,
            \"timestamp\": \"$(date -Iseconds)\"
        }" > /dev/null
    
    # Enviar datos de sensores al backend con autenticación
    curl -s -X POST "$BACKEND_URL/mobile/sensor-data" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $USER_TOKEN" \
        -d "{
            \"collarId\": \"$COLLAR_ID\",
            \"petName\": \"$PET_NAME\",
            \"species\": \"perro\",
            \"breed\": \"pastor aleman\",
            \"age\": 6,
            \"weight\": 24.0,
            \"heartRate\": $HEART_RATE,
            \"temperature\": $TEMPERATURE,
            \"activityLevel\": $ACTIVITY,
            \"batteryLevel\": $BATTERY,
            \"latitude\": $LATITUDE,
            \"longitude\": $LONGITUDE,
            \"timestamp\": \"$(date -Iseconds)\"
        }" > /dev/null
    
    echo "🟢 ESTADO: Funcionamiento normal"
    echo "📱 Datos enviados a la APK"
    echo "Próximo ciclo en 15 segundos..."
    echo ""
    
    # Generar alertas ocasionales
    if [ $((cycle % 5)) -eq 0 ]; then
        if [ $BATTERY -lt 20 ]; then
            echo "⚠️  ALERTA: Batería baja ($BATTERY%)"
        fi
        if [ $HEART_RATE -gt 110 ]; then
            echo "⚠️  ALERTA: Ritmo cardíaco elevado ($HEART_RATE bpm)"
        fi
    fi
    
    sleep 15
    ((cycle++))
done