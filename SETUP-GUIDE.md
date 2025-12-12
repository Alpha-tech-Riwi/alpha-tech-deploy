# 🚀 Alpha Tech - Setup Guide para Nuevo PC

## 📋 Requisitos Previos

### Software Necesario:
```bash
# Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# PostgreSQL
sudo apt update
sudo apt install postgresql postgresql-contrib -y

# Git
sudo apt install git -y

# Docker (opcional)
sudo apt install docker.io docker-compose -y
sudo usermod -aG docker $USER
```

## 📁 Estructura de Repositorios

```
Alpha Tech Organization: https://github.com/Alpha-tech-Riwi/
├── alpha-tech-backend      # Backend principal + Frontend
├── alpha-tech-location     # Servicio GPS
└── alpha-tech-notifications # Servicio Notificaciones
```

## 🔧 Clonar Repositorios

```bash
# Crear directorio principal
mkdir alpha-tech-project
cd alpha-tech-project

# Clonar todos los repositorios
git clone https://github.com/Alpha-tech-Riwi/alpha-tech-backend.git
git clone https://github.com/Alpha-tech-Riwi/alpha-tech-location.git
git clone https://github.com/Alpha-tech-Riwi/alpha-tech-notifications.git
```

## 🗄️ Configuración de Base de Datos

### PostgreSQL Setup:
```bash
# Iniciar PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Crear usuario y bases de datos
sudo -u postgres psql

-- En PostgreSQL:
CREATE USER alpha_user WITH PASSWORD 'alpha123';
CREATE DATABASE alpha_tech_db OWNER alpha_user;
CREATE DATABASE location_db OWNER alpha_user;
CREATE DATABASE notifications_db OWNER alpha_user;
GRANT ALL PRIVILEGES ON DATABASE alpha_tech_db TO alpha_user;
GRANT ALL PRIVILEGES ON DATABASE location_db TO alpha_user;
GRANT ALL PRIVILEGES ON DATABASE notifications_db TO alpha_user;
\q
```

## 🔑 Variables de Entorno

### Backend Principal (.env):
```env
# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=alpha_user
DATABASE_PASSWORD=alpha123
DATABASE_NAME=alpha_tech_db

# Server
PORT=3000
NODE_ENV=development

# JWT
JWT_SECRET=alpha_tech_jwt_secret_key_2024

# CORS
FRONTEND_URL=http://localhost:5173
LOCATION_SERVICE_URL=http://localhost:3002
NOTIFICATION_SERVICE_URL=http://localhost:3003
```

### Location Service (.env):
```env
# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=alpha_user
DATABASE_PASSWORD=alpha123
DATABASE_NAME=location_db

# Server
PORT=3002
NODE_ENV=development

# CORS
FRONTEND_URL=http://localhost:5173
BACKEND_URL=http://localhost:3000
NOTIFICATION_SERVICE_URL=http://localhost:3003

# JWT
JWT_SECRET=alpha_tech_jwt_secret_key_2024

# Geofencing
DEFAULT_GEOFENCE_RADIUS=100
MAX_GEOFENCE_RADIUS=1000
GPS_ACCURACY_THRESHOLD=10
LOCATION_UPDATE_INTERVAL=30000
```

### Notification Service (.env):
```env
# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=alpha_user
DATABASE_PASSWORD=alpha123
DATABASE_NAME=notifications_db

# Server
PORT=3003
NODE_ENV=development

# CORS
FRONTEND_URL=http://localhost:5173
BACKEND_URL=http://localhost:3000
LOCATION_SERVICE_URL=http://localhost:3002

# WebSocket
WEBSOCKET_CORS_ORIGIN=http://localhost:5173
WEBSOCKET_PATH=/socket.io

# JWT
JWT_SECRET=alpha_tech_jwt_secret_key_2024

# Notifications
MAX_NOTIFICATIONS_PER_USER=1000
NOTIFICATION_RETENTION_DAYS=30
BATCH_SIZE=50
```

### Frontend (.env):
```env
VITE_API_URL=http://localhost:3000
VITE_LOCATION_API_URL=http://localhost:3002
VITE_NOTIFICATION_API_URL=http://localhost:3003
VITE_WEBSOCKET_URL=ws://localhost:3003
```

## 🚀 Instalación y Ejecución

### 1. Backend Principal:
```bash
cd alpha-tech-backend
npm install
# Crear archivo .env con las variables de arriba
npm run start:dev
# Servidor en http://localhost:3000
```

### 2. Location Service:
```bash
cd alpha-tech-location
npm install
# Crear archivo .env con las variables de arriba
npm run start:dev
# Servidor en http://localhost:3002
```

### 3. Notification Service:
```bash
cd alpha-tech-notifications
npm install
# Crear archivo .env con las variables de arriba
npm run start:dev
# Servidor en http://localhost:3003
```

### 4. Frontend:
```bash
cd alpha-tech-backend/frontend
npm install
# Crear archivo .env con las variables de arriba
npm run dev
# Aplicación en http://localhost:5173
```

## 🔍 Verificación de Servicios

### Health Checks:
```bash
# Backend
curl http://localhost:3000/health

# Location Service
curl http://localhost:3002/health

# Notification Service
curl http://localhost:3003/health

# Frontend
curl http://localhost:5173
```

## 📊 Datos de Prueba

### Collar ID para Testing:
- **Collar ID**: `123456`
- **Pet Name**: `Zeus`
- **Coordinates**: `6.250000, -75.590000` (Medellín)
- **Heart Rate**: `88.5 bpm`

### Endpoints de Prueba:
```bash
# Enviar ubicación GPS
curl -X POST http://localhost:3002/location \
  -H "Content-Type: application/json" \
  -d '{"collarId":"123456","latitude":6.250000,"longitude":-75.590000}'

# Obtener ubicación actual
curl http://localhost:3002/location/123456

# Enviar notificación
curl -X POST http://localhost:3003/notifications \
  -H "Content-Type: application/json" \
  -d '{"userId":"user123","type":"geofence_violation","title":"Test","message":"Test message"}'
```

## 🐳 Alternativa con Docker

### Docker Compose (Opcional):
```bash
# En el directorio principal
docker-compose up -d

# Verificar servicios
docker-compose ps
docker-compose logs
```

## 🔧 Troubleshooting

### Problemas Comunes:

**Puerto ocupado:**
```bash
sudo lsof -i :3000
sudo kill -9 <PID>
```

**PostgreSQL no conecta:**
```bash
sudo systemctl status postgresql
sudo systemctl restart postgresql
```

**Permisos de Docker:**
```bash
sudo usermod -aG docker $USER
# Reiniciar sesión
```

**CORS Errors:**
- Verificar que las URLs en .env coincidan
- Verificar que todos los servicios estén corriendo

## 📝 Notas Importantes

- ✅ Todos los archivos .env deben crearse manualmente
- ✅ PostgreSQL debe estar corriendo antes de iniciar servicios
- ✅ Iniciar servicios en orden: DB → Backend → Location → Notifications → Frontend
- ✅ Verificar que todos los puertos estén libres (3000, 3002, 3003, 5173)
- ✅ El frontend se conecta automáticamente a los servicios backend

## 🚀 URLs de Acceso

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3000
- **Location API**: http://localhost:3002
- **Notifications API**: http://localhost:3003
- **PostgreSQL**: localhost:5432

---

**Creado por**: Alpha Tech Team  
**Fecha**: Diciembre 2024  
**Versión**: 1.0