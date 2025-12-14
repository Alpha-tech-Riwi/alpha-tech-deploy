# 🏗️ Alpha Tech - Project Architecture

## 📋 Project Overview
**Alpha Tech Smart Pet Collar System** - Enterprise-grade microservices architecture for IoT pet monitoring and management.

## 🎯 System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           ALPHA TECH ECOSYSTEM                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Frontend Layer                                                                 │
│  ├── Web Dashboard (React + TypeScript)                                        │
│  ├── Mobile App (React Native + Expo)                                          │
│  └── Hybrid App (Cordova + React)                                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│  API Gateway & Load Balancer                                                   │
│  └── Nginx Reverse Proxy + SSL Termination                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Microservices Layer                                                           │
│  ├── Auth Service (Port 3005) - JWT + OAuth2                                  │
│  ├── Backend API (Port 3000) - Core Business Logic                            │
│  ├── Location Service (Port 3002) - GPS + Geofencing                          │
│  ├── Notification Service (Port 3003) - WebSocket + Push                      │
│  ├── File Service (Port 3006) - Media Storage                                 │
│  ├── QR Service (Port 3004) - QR Code Generation                              │
│  └── Mobile Service (Port 3007) - Mobile API Gateway                          │
├─────────────────────────────────────────────────────────────────────────────────┤
│  Data Layer                                                                     │
│  ├── PostgreSQL (Port 5432) - Primary Database                                │
│  └── Redis (Port 6379) - Cache + Session Store                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│  IoT Layer                                                                      │
│  └── ESP32 Devices - Smart Collars with Sensors                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 📁 Directory Structure

```
alpha-tech-deploy/
├── 🔧 Infrastructure
│   ├── docker-compose.local.yml      # Development environment
│   ├── docker-compose.production.yml # Production environment
│   ├── nginx.conf                    # Reverse proxy config
│   └── init-databases.sh             # Database initialization
│
├── 🌐 Frontend Applications
│   ├── alpha-tech-frontend/          # React Web Dashboard
│   ├── alpha-tech-mobile-app/        # React Native Mobile App
│   └── alpha-tech-hybrid/            # Cordova Hybrid App
│
├── 🔐 Authentication & Security
│   └── alpha-tech-auth-service/      # JWT Authentication Service
│
├── 🚀 Core Services
│   ├── alpha-tech-backend/           # Main API Gateway
│   ├── alpha-tech-location/          # GPS & Geofencing Service
│   ├── alpha-tech-notifications/     # Real-time Notifications
│   ├── alpha-tech-file-service/      # File Storage Service
│   ├── alpha-tech-qr-service/        # QR Code Service
│   └── alpha-tech-mobile-service/    # Mobile API Gateway
│
├── 🛠️ DevOps & Automation
│   ├── setup.sh                     # Environment setup
│   ├── deploy.sh                    # Production deployment
│   ├── test-services.sh             # Health checks
│   └── cleanup-db.sh                # Database cleanup
│
├── 📱 Mobile Builds
│   ├── alpha-tech-public-urls.apk   # Production APK
│   └── alpha-tech-updated.apk       # Development APK
│
└── 📚 Documentation
    ├── README.md                    # Main documentation
    ├── SETUP-GUIDE.md              # Setup instructions
    ├── CLOUDFLARE-SETUP.md         # Cloudflare configuration
    └── PROJECT-STRUCTURE.md        # This file
```

## 🔄 Service Communication

### Internal Communication (Docker Network)
```yaml
Services communicate via internal Docker network:
- backend → auth-service:3005
- backend → location-service:3002
- backend → notification-service:3003
- location-service → notification-service:3003
```

### External APIs (Public Access)
```yaml
Production URLs (via Cloudflare Tunnel):
- Backend: https://interesting-civilization-beauty-decided.trycloudflare.com
- Location: https://leaves-differently-prisoners-promotion.trycloudflare.com
- Notifications: https://happens-chronicles-priority-ambassador.trycloudflare.com
```

## 🗄️ Database Schema

### Core Entities
- **Users** - Authentication and profiles
- **Pets** - Pet information and ownership
- **Collars** - IoT device management
- **SensorData** - Real-time sensor readings
- **Locations** - GPS tracking data
- **Geofences** - Virtual boundaries
- **Notifications** - Alert system
- **Files** - Media storage

## 🔐 Security Features

- **JWT Authentication** with refresh tokens
- **Role-based Access Control** (RBAC)
- **API Rate Limiting** via Redis
- **CORS Protection** for all services
- **Input Validation** with class-validator
- **SQL Injection Protection** via TypeORM
- **XSS Protection** with helmet.js

## 📊 Monitoring & Observability

- **Health Checks** for all services
- **Docker Health Monitoring**
- **Real-time WebSocket connections**
- **API Response logging**
- **Error tracking and alerts**

## 🚀 Deployment Strategies

### Development
```bash
docker-compose -f docker-compose.local.yml up --build
```

### Production
```bash
./deploy.sh
```

### Mobile Distribution
- **APK**: Direct installation
- **Play Store**: Production release
- **TestFlight**: iOS beta testing

## 🧪 Testing Strategy

- **Unit Tests**: Jest + Testing Library
- **Integration Tests**: Supertest
- **E2E Tests**: Cypress
- **Load Testing**: Artillery
- **Security Testing**: OWASP ZAP

## 📈 Performance Optimization

- **Redis Caching** for frequent queries
- **Database Indexing** for optimal queries
- **CDN Integration** for static assets
- **Image Optimization** for mobile apps
- **Lazy Loading** for frontend components

## 🔧 Development Workflow

1. **Feature Development** in feature branches
2. **Code Review** via Pull Requests
3. **Automated Testing** on CI/CD
4. **Staging Deployment** for QA
5. **Production Release** with rollback capability

---

**Alpha Tech Team** - Enterprise IoT Solutions 🐕