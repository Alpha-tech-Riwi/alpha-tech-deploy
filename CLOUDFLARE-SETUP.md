# 🌐 Alpha Tech - Cloudflare Tunnel Setup Guide

Guía completa para configurar IP pública usando Cloudflare Tunnel para todos los servicios de Alpha Tech.

## 📋 Tabla de Contenidos

1. [Arquitectura con IP Pública](#arquitectura-con-ip-pública)
2. [Instalación de Cloudflare Tunnel](#instalación-de-cloudflare-tunnel)
3. [Configuración por Servicio](#configuración-por-servicio)
4. [Variables de Entorno](#variables-de-entorno)
5. [Archivos Modificados](#archivos-modificados)
6. [Comandos de Inicio](#comandos-de-inicio)
7. [Troubleshooting](#troubleshooting)

## 🏗️ Arquitectura con IP Pública

```
Internet → Cloudflare Tunnel → Vite Dev Server (5173) → Proxy:
├── /api/* → Backend (3000)
├── /qr/* → QR Service (3004)
├── /location/* → Location Service (3002)
└── /notifications/* → Notification Service (3003)
```

## 🚀 Instalación de Cloudflare Tunnel

### 1. Instalar cloudflared

```bash
# Linux/macOS
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb

# macOS con Homebrew
brew install cloudflared

# Windows
# Descargar desde: https://github.com/cloudflare/cloudflared/releases
```

### 2. Autenticar con Cloudflare

```bash
# Solo necesario la primera vez
cloudflared tunnel login
```

### 3. Crear tunnel

```bash
# Crear tunnel para Alpha Tech
cloudflared tunnel create alpha-tech

# Configurar DNS (reemplaza con tu dominio)
cloudflared tunnel route dns alpha-tech your-subdomain.your-domain.com
```

## ⚙️ Configuración por Servicio

### Frontend (Vite) - Puerto 5173

**Archivo:** `vite.config.ts`
```typescript
export default defineConfig({
  server: {
    host: '0.0.0.0',
    port: 5173,
    allowedHosts: [
      'localhost',
      '127.0.0.1',
      'your-subdomain.your-domain.com',  // ← Tu dominio aquí
      '.trycloudflare.com'
    ],
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      },
      '/qr': {
        target: 'http://localhost:3004',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/qr/, '')
      }
    }
  }
})
```

### QR Service - Puerto 3004

**Archivo:** `alpha-tech-qr-service/server.js`
```javascript
// Configurar URL base para notificaciones
const NOTIFICATION_URL = process.env.NOTIFICATION_URL || 'https://your-subdomain.your-domain.com/api/notifications';

// En la función de QR escaneado:
await axios.post(NOTIFICATION_URL, {
  // ... datos de notificación
});
```

### Backend - Puerto 3000

**Archivo:** `alpha-tech-backend/src/main.ts`
```typescript
app.enableCors({
  origin: [
    'http://localhost:5173',
    'https://your-subdomain.your-domain.com'  // ← Tu dominio aquí
  ],
  credentials: true
});
```

## 🔧 Variables de Entorno

### Frontend (.env)
```bash
# alpha-tech-frontend/.env
VITE_API_URL=https://your-subdomain.your-domain.com/api
VITE_WEBSOCKET_URL=https://your-subdomain.your-domain.com
VITE_QR_SERVICE_URL=https://your-subdomain.your-domain.com/qr
```

### QR Service (.env)
```bash
# alpha-tech-qr-service/.env
PORT=3004
NOTIFICATION_URL=https://your-subdomain.your-domain.com/api/notifications
QR_BASE_URL=https://your-subdomain.your-domain.com/qr
```

### Backend (.env)
```bash
# alpha-tech-backend/.env
PORT=3000
FRONTEND_URL=https://your-subdomain.your-domain.com
CORS_ORIGIN=https://your-subdomain.your-domain.com
```

## 📁 Archivos Modificados

### 1. Frontend - PetQRCode.tsx
```typescript
// Cambiar URL hardcodeada por variable de entorno
const qrCode = `PET${petId.substring(0, 8).toUpperCase()}`;
const url = `${import.meta.env.VITE_QR_SERVICE_URL || 'http://localhost:3004'}/found/${qrCode}`;
```

### 2. Frontend - useWebSocket.ts
```typescript
const WS_URL = import.meta.env.VITE_WEBSOCKET_URL || 'http://localhost:3000';
```

### 3. Frontend - api.ts
```typescript
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000';
```

### 4. Dashboard.tsx
```typescript
// Usar variable de entorno para comandos de collar
const response = await api.post('/collar/emergency', {
  // ... datos
});
```

## 🌐 Configuración de Cloudflare Tunnel

### Archivo: ~/.cloudflared/config.yml
```yaml
tunnel: alpha-tech
credentials-file: /home/your-user/.cloudflared/[tunnel-id].json

ingress:
  # Frontend principal
  - hostname: your-subdomain.your-domain.com
    service: http://localhost:5173
  
  # Fallback para rutas no encontradas
  - service: http_status:404
```

## 🚀 Comandos de Inicio

### Secuencia completa de inicio:

```bash
# 1. Clonar repositorios
git clone https://github.com/Alpha-tech-Riwi/alpha-tech-deploy.git
cd alpha-tech-deploy
./setup.sh

# 2. Configurar variables de entorno
# Editar archivos .env según la sección anterior

# 3. Iniciar servicios backend (Docker)
docker-compose -f docker-compose.local.yml up -d

# 4. Iniciar QR Service
cd alpha-tech-qr-service
npm install
npm start &

# 5. Iniciar Frontend
cd ../alpha-tech-frontend
npm install
npm run dev &

# 6. Iniciar Cloudflare Tunnel
cloudflared tunnel run alpha-tech
```

### Script automatizado:

```bash
#!/bin/bash
# start-with-tunnel.sh

echo "🚀 Starting Alpha Tech with Cloudflare Tunnel..."

# Iniciar servicios Docker
docker-compose -f docker-compose.local.yml up -d

# Iniciar QR Service
cd alpha-tech-qr-service && npm start &
QR_PID=$!

# Iniciar Frontend
cd ../alpha-tech-frontend && npm run dev &
FRONTEND_PID=$!

# Iniciar Cloudflare Tunnel
cloudflared tunnel run alpha-tech &
TUNNEL_PID=$!

echo "✅ Services started:"
echo "   - Backend: http://localhost:3000"
echo "   - QR Service: http://localhost:3004"  
echo "   - Frontend: http://localhost:5173"
echo "   - Public URL: https://your-subdomain.your-domain.com"

# Cleanup function
cleanup() {
    echo "🛑 Stopping services..."
    kill $QR_PID $FRONTEND_PID $TUNNEL_PID 2>/dev/null
    docker-compose -f docker-compose.local.yml down
    exit 0
}

trap cleanup SIGINT SIGTERM

# Wait for interrupt
wait
```

## 🔍 URLs de Acceso

### Desarrollo Local:
- Frontend: `http://localhost:5173`
- Backend API: `http://localhost:3000`
- QR Service: `http://localhost:3004`
- Location Service: `http://localhost:3002`
- Notifications: `http://localhost:3003`

### Producción (IP Pública):
- Frontend: `https://your-subdomain.your-domain.com`
- Backend API: `https://your-subdomain.your-domain.com/api`
- QR Service: `https://your-subdomain.your-domain.com/qr`

## 🧪 Testing con IP Pública

### Probar QR Code:
```bash
# El QR generará URLs como:
https://your-subdomain.your-domain.com/qr/found/PETD9DB6E1B
```

### Probar API:
```bash
curl https://your-subdomain.your-domain.com/api/health
```

### Probar Notificaciones:
```bash
curl -X POST https://your-subdomain.your-domain.com/api/notifications \
  -H "Content-Type: application/json" \
  -d '{"type":"test","message":"Test notification"}'
```

## 🐛 Troubleshooting

### Error: "Tunnel not found"
```bash
# Verificar tunnels existentes
cloudflared tunnel list

# Recrear tunnel si es necesario
cloudflared tunnel delete alpha-tech
cloudflared tunnel create alpha-tech
```

### Error: "Connection refused"
```bash
# Verificar que los servicios estén corriendo
docker-compose ps
lsof -i :3000,3004,5173
```

### Error: "CORS policy"
```bash
# Verificar configuración CORS en backend
# Asegurar que el dominio esté en allowedHosts de Vite
```

### Error: "WebSocket connection failed"
```bash
# Verificar configuración de WebSocket en useWebSocket.ts
# Asegurar que VITE_WEBSOCKET_URL esté configurado correctamente
```

## 📝 Checklist de Configuración

- [ ] Cloudflare Tunnel instalado y autenticado
- [ ] Tunnel creado y DNS configurado
- [ ] Variables de entorno configuradas en todos los servicios
- [ ] URLs hardcodeadas reemplazadas por variables
- [ ] CORS configurado en backend
- [ ] allowedHosts configurado en Vite
- [ ] Proxy configurado en vite.config.ts
- [ ] Servicios iniciados en orden correcto
- [ ] Tunnel corriendo y accesible públicamente

## 🎯 Resultado Final

Una vez configurado correctamente:

1. **QR Codes** generarán URLs públicas accesibles desde cualquier celular
2. **Dashboard** será accesible desde internet
3. **API calls** funcionarán desde cualquier dispositivo
4. **WebSocket** mantendrá conexiones en tiempo real
5. **Notificaciones** llegarán instantáneamente

---

**🐕 Alpha Tech Team - Smart Pet Collar System**

Para soporte: [GitHub Issues](https://github.com/Alpha-tech-Riwi/alpha-tech-deploy/issues)