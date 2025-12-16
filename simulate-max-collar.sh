#!/bin/bash

# Simulación de collar ESP32 para Max (Pastor Alemán)
# Collar ID: PET_002
# Pet ID: 741cac7a-a2e8-4fd1-abdd-878942d5c927

PET_ID="741cac7a-a2e8-4fd1-abdd-878942d5c927"
COLLAR_ID="123"
BACKEND_URL="http://localhost:3000"
LOCATION_URL="http://localhost:3002"

echo "🐕 Simulando collar ESP32 para Max (Pastor Alemán)"
echo "📡 Collar ID: $COLLAR_ID"
echo "🐕 Pet ID: $PET_ID"

# Función para simular polling de comandos
check_commands() {
    echo "📡 Polling comandos para Max..."
    RESPONSE=$(curl -s "$BACKEND_URL/commands/$PET_ID")
    COMMAND=$(echo $RESPONSE | grep -o '"command":"[^"]*"' | cut -d'"' -f4)
    
    if [ "$COMMAND" = "FIND_PET" ]; then
        echo "🚨 ¡Comando FIND_PET recibido para Max!"
        execute_command
    else
        echo "⏳ No hay comandos pendientes para Max"
    fi
}

# Función para ejecutar comando y enviar ubicación
execute_command() {
    echo "🔊 Max: Activando buzzer y LEDs..."
    
    # Simular coordenadas GPS (área diferente de Medellín)
    LAT=$(echo "6.2600 + ($RANDOM % 100 - 50) / 10000" | bc -l)
    LON=$(echo "-75.5800 + ($RANDOM % 100 - 50) / 10000" | bc -l)
    ACCURACY=$((RANDOM % 10 + 5))
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    
    echo "📍 Max enviando ubicación: $LAT, $LON"
    
    # Enviar ubicación
    curl -X POST "$LOCATION_URL/location/collar/$COLLAR_ID/position" \
        -H "Content-Type: application/json" \
        -d "{
            \"collarId\":\"$COLLAR_ID\",
            \"petId\":\"$PET_ID\",
            \"latitude\":$LAT,
            \"longitude\":$LON,
            \"accuracy\":$ACCURACY,
            \"timestamp\":\"$TIMESTAMP\"
        }" > /dev/null 2>&1
    
    echo "✅ Max: Comando ejecutado, ubicación enviada"
    
    # Enviar acknowledgment
    curl -X POST "$BACKEND_URL/commands/ack" \
        -H "Content-Type: application/json" \
        -d "{
            \"petId\":\"$PET_ID\",
            \"status\":\"ACK_RECEIVED\"
        }" > /dev/null 2>&1
    
    echo "📤 Max: Acknowledgment enviado"
}

# Función para activar comando manualmente
activate_max() {
    echo "🚨 Activando comando FIND_PET para Max..."
    
    # Insertar comando en base de datos
    docker exec alpha-tech-deploy-postgres-1 psql -U alpha_user -d alpha_tech_db -c \
        "INSERT INTO collar_commands (pet_id, command_type, issued_by, expires_at) 
         VALUES ('$PET_ID', 'FIND_PET', 'e032669a-a290-4186-a384-3650ebce6c89', NOW() + INTERVAL '5 minutes');" > /dev/null 2>&1
    
    echo "✅ Comando enviado - Max responderá en 5 segundos"
}

# Si se pasa argumento "activate", activar comando
if [ "$1" = "activate" ]; then
    activate_max
    exit 0
fi

# Simulación continua (polling cada 5 segundos)
echo "🔄 Iniciando simulación continua para Max..."
echo "💡 Usa 'bash simulate-max-collar.sh activate' para activar comando"

while true; do
    check_commands
    sleep 5
done