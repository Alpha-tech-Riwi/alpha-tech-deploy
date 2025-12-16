#!/bin/bash
echo "🚨 Activando ESP32..."
docker-compose -f docker-compose.local.yml exec postgres psql -U alpha_user -d alpha_tech_db -c "INSERT INTO collar_commands (pet_id, command_type, status, issued_by, expires_at, created_at) VALUES ('3c5387e8-cb87-4fc7-8e18-0fe44adc9519', 'FIND_PET', 'PENDING', '00000000-0000-0000-0000-000000000000', NOW() + INTERVAL '10 minutes', NOW());" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Comando enviado - ESP32 pitará en 5 segundos"
else
    echo "❌ Error al enviar comando"
fi
