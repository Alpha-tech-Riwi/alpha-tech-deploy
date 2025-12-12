# 🚀 Alpha Tech - Deploy & Orchestration

![Docker](https://img.shields.io/badge/Docker-20.10+-blue)
![Docker Compose](https://img.shields.io/badge/Docker%20Compose-3.8+-green)
![AWS](https://img.shields.io/badge/AWS-EC2-orange)

Deployment and orchestration repository for Alpha Tech's smart pet collar microservices system.

## 🎯 Purpose

This repository contains all the necessary files to deploy and orchestrate the complete Alpha Tech ecosystem:
- Backend Service (NestJS)
- Location Service (GPS tracking)
- Notification Service (WebSocket alerts)
- Frontend Application (React)

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   Frontend      │    │   Backend API    │    │  Location Service   │
│   (React)       │◄──►│   (NestJS)       │◄──►│   (GPS/Geofence)    │
│   Port: 5173    │    │   Port: 3000     │    │   Port: 3002        │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
         │                       │                        │
         └───────────────────────┼────────────────────────┘
                                 │
                    ┌─────────────────────┐
                    │ Notification Service│
                    │   (WebSocket)       │
                    │   Port: 3003        │
                    └─────────────────────┘
                                 │
                    ┌─────────────────────┐
                    │   PostgreSQL DB     │
                    │   Port: 5432        │
                    └─────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Git

### Local Development
```bash
# 1. Clone this repository
git clone https://github.com/Alpha-tech-Riwi/alpha-tech-deploy.git
cd alpha-tech-deploy

# 2. Setup all services (auto-clone repositories)
./setup.sh

# 3. Start all services
docker-compose -f docker-compose.local.yml up --build

# 4. Test services (in another terminal)
./test-services.sh
```

### Production Deployment (AWS EC2)
```bash
# On EC2 instance
git clone https://github.com/Alpha-tech-Riwi/alpha-tech-deploy.git
cd alpha-tech-deploy
./deploy.sh
```

## 📋 Services

| Service | Port | Repository | Description |
|---------|------|------------|-------------|
| Frontend | 5173 | [alpha-tech-backend](https://github.com/Alpha-tech-Riwi/alpha-tech-backend) | React dashboard |
| Backend API | 3000 | [alpha-tech-backend](https://github.com/Alpha-tech-Riwi/alpha-tech-backend) | Main NestJS API |
| Location Service | 3002 | [alpha-tech-location](https://github.com/Alpha-tech-Riwi/alpha-tech-location) | GPS tracking |
| Notification Service | 3003 | [alpha-tech-notifications](https://github.com/Alpha-tech-Riwi/alpha-tech-notifications) | Real-time alerts |
| PostgreSQL | 5432 | - | Database |

## 🔧 Configuration Files

- `docker-compose.local.yml` - Local development environment
- `docker-compose.production.yml` - Production environment with Nginx
- `nginx.conf` - Reverse proxy configuration
- `init-databases.sh` - Database initialization script
- `setup.sh` - Auto-clone all repositories
- `test-services.sh` - Health check script
- `deploy.sh` - AWS deployment script

## 🧪 Testing

### Health Checks
```bash
curl http://localhost:3000/health    # Backend
curl http://localhost:3002/health    # Location Service
curl http://localhost:3003/health    # Notification Service
curl http://localhost:5173           # Frontend
```

### GPS Testing
```bash
curl -X POST http://localhost:3002/location \
  -H "Content-Type: application/json" \
  -d '{"collarId":"123456","latitude":6.250000,"longitude":-75.590000}'
```

### Notification Testing
```bash
curl -X POST http://localhost:3003/notifications \
  -H "Content-Type: application/json" \
  -d '{"userId":"user123","type":"test","title":"Test","message":"Test message"}'
```

## 🐳 Docker Commands

```bash
# Start all services
docker-compose -f docker-compose.local.yml up -d

# View logs
docker-compose -f docker-compose.local.yml logs -f

# Stop all services
docker-compose -f docker-compose.local.yml down

# Rebuild specific service
docker-compose -f docker-compose.local.yml up --build backend
```

## 🌐 Access URLs

- **Frontend Dashboard**: http://localhost:5173
- **Backend API**: http://localhost:3000
- **Location API**: http://localhost:3002
- **Notification API**: http://localhost:3003
- **Database**: localhost:5432

## 📊 Monitoring

### Service Status
```bash
docker-compose -f docker-compose.local.yml ps
```

### Resource Usage
```bash
docker stats
```

## 🔒 Security

- All services run in isolated Docker networks
- Environment variables for sensitive data
- Health checks for service reliability
- Non-root users in containers

## 📝 Documentation

- [Setup Guide](SETUP-GUIDE.md) - Complete setup instructions
- [AWS Deployment](docs/aws-deploy.md) - Production deployment guide
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Test changes locally
4. Submit pull request

## 📞 Support

- Issues: [GitHub Issues](https://github.com/Alpha-tech-Riwi/alpha-tech-deploy/issues)
- Organization: [Alpha-tech-Riwi](https://github.com/Alpha-tech-Riwi)

---

**Alpha Tech Team** - Smart Pet Collar System 🐕