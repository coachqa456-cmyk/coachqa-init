# CoachQA Platform

A comprehensive quality assurance and coaching platform for engineering teams.

## 🚀 Quick Start

```bash
# Start all services
docker-compose -f docker-compose.dev.yml up -d

# Wait for database initialization
docker logs -f coachqa-postgres-dev

# Access the application
# Frontend: http://127.0.0.1:9001
# Backend API: http://127.0.0.1:9002/api
```

## 📚 Documentation

### Getting Started
- **[SETUP-GUIDE.md](SETUP-GUIDE.md)** - Complete setup guide with troubleshooting
- **[DATABASE-SETUP.md](DATABASE-SETUP.md)** - Database configuration and setup

### Database Migrations
- **[MIGRATION-GUIDE.md](coachqa-backend/migrations/MIGRATION-GUIDE.md)** - Detailed migration guide
- **[README-COMPLETE-SETUP.md](coachqa-backend/migrations/README-COMPLETE-SETUP.md)** - Complete database setup details
- **[DOCKER-INIT-SETUP.md](coachqa-backend/migrations/DOCKER-INIT-SETUP.md)** - Docker initialization guide
- **[QUICK-START.md](coachqa-backend/migrations/QUICK-START.md)** - Quick reference

### Docker Configuration
- **[docker-compose-setup.md](docker-compose-setup.md)** - Docker Compose configuration details

## 🔐 Default Credentials

### Platform Admin
- **URL**: `http://127.0.0.1:9001/admin/login`
- **Email**: `admin@coachqa.com`
- **Password**: `Admin@123`

### Demo Tenant User
- **URL**: `http://127.0.0.1:9001/login`
- **Email**: `user@demo.com`
- **Password**: `Demo@123`

## 🏗️ Architecture

### Services

- **Frontend** (`coachqa-ui`) - React/Vite application on port 9001
- **Backend** (`coachqa-backend`) - Node.js/Express API on port 9002
- **Database** (`postgres`) - PostgreSQL database on port 5432

### Technology Stack

- **Frontend**: React, TypeScript, Vite, TailwindCSS
- **Backend**: Node.js, Express, TypeScript, PostgreSQL
- **Database**: PostgreSQL 15+
- **Containerization**: Docker, Docker Compose

## 📁 Project Structure

```
CoachQA-Project/
├── coachqa-backend/          # Backend API
│   ├── src/                  # Source code
│   ├── migrations/           # Database migrations
│   └── docs/                 # Backend documentation
├── coachqa-ui/               # Frontend application
│   └── src/                  # Source code
├── docker-compose.dev.yml    # Development configuration
├── docker-compose.yml        # Production configuration
└── docs/                     # Project documentation
```

## 🛠️ Development

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for local development)
- PostgreSQL 15+ (or use Docker)

### Common Commands

```bash
# Start services
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Stop services
docker-compose -f docker-compose.dev.yml down

# Reset database (WARNING: Deletes all data!)
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up -d postgres
```

### Running Migrations

```bash
# Connect to database
docker exec -it coachqa-postgres-dev psql -U postgres -d coachqa_db

# Run a migration
\i /docker-entrypoint-initdb.d/012-add-code-column-to-roles.sql
```

## 🔧 Configuration

### Environment Variables

#### Frontend
- `VITE_API_URL` - Backend API URL (default: `http://127.0.0.1:9002`)

#### Backend
- `CORS_ORIGIN` - CORS allowed origin (default: `http://127.0.0.1:9001`)
- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - JWT signing secret
- `JWT_REFRESH_SECRET` - JWT refresh token secret

#### Database
- `POSTGRES_DB` - Database name (default: `coachqa_db`)
- `POSTGRES_USER` - Database user (default: `postgres`)
- `POSTGRES_PASSWORD` - Database password (default: `postgres`)
- `USE_COMPLETE_SETUP` - Use complete setup migration (default: `true`)

## 📊 System Roles

| Role | Code | Description |
|------|------|-------------|
| Administrator | `ADMIN` | Full access to all modules |
| QA Manager | `QA_MANAGER` | Quality modules and team management |
| Quality Engineer | `QUALITY_ENGINEER` | Coaching and quality modules |
| Developer | `DEVELOPER` | Testing and quality modules |
| Product | `PRODUCT` | Quality metrics and feedback |
| Engineering Manager | `ENGINEERING_MANAGER` | Quality and team management |

## 🐛 Troubleshooting

### Services Not Starting

1. Check Docker is running: `docker ps`
2. Check logs: `docker logs coachqa-postgres-dev`
3. Check port conflicts: `netstat -ano | findstr :9001`

### Database Issues

1. Check initialization: `docker logs coachqa-postgres-dev`
2. Verify migrations: See [MIGRATION-GUIDE.md](coachqa-backend/migrations/MIGRATION-GUIDE.md)
3. Reset database if needed (see Common Commands above)

### Connection Issues

- Ensure all services are running: `docker ps`
- Check API URL is correct: `http://127.0.0.1:9002`
- Verify CORS settings in backend

## 📝 API Documentation

Once the backend is running, access API documentation at:
- **Swagger UI**: `http://127.0.0.1:9002/api-docs`
- **Health Check**: `http://127.0.0.1:9002/api/health`

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## 📄 License

[Add your license here]

## 🔗 Links

- **Frontend**: http://127.0.0.1:9001
- **Backend API**: http://127.0.0.1:9002/api
- **API Docs**: http://127.0.0.1:9002/api-docs
- **Health Check**: http://127.0.0.1:9002/api/health

---

For detailed setup instructions, see [SETUP-GUIDE.md](SETUP-GUIDE.md)
