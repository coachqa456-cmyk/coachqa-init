# QEnabler Platform

A comprehensive quality assurance and coaching platform for engineering teams.

## 🚀 Quick Start

### Clone Repositories

```bash
# Clone the main project repository
git clone https://github.com/coachqa456-cmyk/coachqa-init.git QEnabler-Project
cd QEnabler-Project

# Clone backend repository
git clone https://github.com/coachqa456-cmyk/coachqa-backend.git qenabler-backend

# Clone frontend repository
git clone https://github.com/coachqa456-cmyk/coachqa-ui.git qenabler-ui

# Clone Swagger UI repository
git clone https://github.com/coachqa456-cmyk/coachqa-swagger-ui.git qenabler-swagger-ui

# Clone documentation repository
git clone https://github.com/coachqa456-cmyk/coachqa-docs.git qenabler-docs
```

### Start Services

```bash
# Start all services
docker-compose -f docker-compose.dev.yml up -d

# Wait for database initialization
docker logs -f qenabler-postgres-dev

# Access the application
# Frontend: http://127.0.0.1:9001
# Backend API: http://127.0.0.1:9002/api
```

## 📚 Documentation

### Getting Started
- **[SETUP-GUIDE.md](SETUP-GUIDE.md)** - Complete setup guide with troubleshooting
- **[DATABASE-SETUP.md](DATABASE-SETUP.md)** - Database configuration and setup

### Database Migrations
- **[MIGRATION-GUIDE.md](qenabler-backend/migrations/MIGRATION-GUIDE.md)** - Detailed migration guide
- **[README-COMPLETE-SETUP.md](qenabler-backend/migrations/README-COMPLETE-SETUP.md)** - Complete database setup details
- **[DOCKER-INIT-SETUP.md](qenabler-backend/migrations/DOCKER-INIT-SETUP.md)** - Docker initialization guide
- **[QUICK-START.md](qenabler-backend/migrations/QUICK-START.md)** - Quick reference

### Docker Configuration
- **[docker-compose-setup.md](docker-compose-setup.md)** - Docker Compose configuration details

## 🔐 Default Credentials

### Platform Admin
- **URL**: `http://127.0.0.1:9001/admin/login`
- **Email**: `admin@qenabler.com`
- **Password**: `Admin@123`

### Demo Tenant User
- **URL**: `http://127.0.0.1:9001/login`
- **Email**: `user@demo.com`
- **Password**: `Demo@123`

## 🏗️ Architecture

### Services

- **Frontend** (`qenabler-ui`) - React/Vite application on port 9001
- **Backend** (`qenabler-backend`) - Node.js/Express API on port 9002
- **Database** (`postgres`) - PostgreSQL database on port 5432
- **Swagger UI** (`qenabler-swagger-ui`) - Interactive API documentation on port 9004
- **Documentation** (`qenabler-docs`) - Docusaurus documentation site on port 9003

### Technology Stack

- **Frontend**: React, TypeScript, Vite, TailwindCSS
- **Backend**: Node.js, Express, TypeScript, PostgreSQL
- **Database**: PostgreSQL 15+
- **Containerization**: Docker, Docker Compose

## 📁 Project Structure

```
QEnabler-Project/
├── qenabler-backend/          # Backend API
│   ├── src/                  # Source code
│   ├── migrations/           # Database migrations
│   └── docs/                 # Backend documentation
├── qenabler-ui/               # Frontend application
│   └── src/                  # Source code
├── qenabler-swagger-ui/       # Swagger UI service (separate repository)
├── qenabler-docs/             # Docusaurus documentation (separate repository)
├── docker-compose.dev.yml    # Development configuration
├── docker-compose.yml        # Production configuration
└── docs/                     # Project documentation
```

## 🛠️ Development

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for local development)
- PostgreSQL 15+ (or use Docker)
- Git

### Repository Setup

If the backend and frontend are in separate repositories:

```bash
# Clone backend repository
git clone https://github.com/coachqa456-cmyk/coachqa-backend.git qenabler-backend

# Clone frontend repository
git clone https://github.com/coachqa456-cmyk/coachqa-ui.git qenabler-ui

# Clone Swagger UI repository
git clone https://github.com/coachqa456-cmyk/coachqa-swagger-ui.git qenabler-swagger-ui

# Clone documentation repository
git clone https://github.com/coachqa456-cmyk/coachqa-docs.git qenabler-docs
```

If using a monorepo, clone the main repository:

```bash
git clone <main-repository-url> QEnabler-Project
cd QEnabler-Project
```

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
docker exec -it qenabler-postgres-dev psql -U postgres -d qenabler_db

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
- `POSTGRES_DB` - Database name (default: `qenabler_db`)
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
2. Check logs: `docker logs qenabler-postgres-dev`
3. Check port conflicts: `netstat -ano | findstr :9001`

### Database Issues

1. Check initialization: `docker logs qenabler-postgres-dev`
2. Verify migrations: See [MIGRATION-GUIDE.md](qenabler-backend/migrations/MIGRATION-GUIDE.md)
3. Reset database if needed (see Common Commands above)

### Connection Issues

- Ensure all services are running: `docker ps`
- Check API URL is correct: `http://127.0.0.1:9002`
- Verify CORS settings in backend

## 📝 API Documentation

Once the backend is running, access API documentation at:
- **Swagger UI (Standalone)**: `http://127.0.0.1:9004` - Interactive API documentation
- **Swagger UI (Legacy)**: `http://127.0.0.1:9002/api-docs` - Legacy endpoint (to be removed)
- **OpenAPI Spec (JSON)**: `http://127.0.0.1:9002/api-docs.json` - OpenAPI specification
- **Health Check**: `http://127.0.0.1:9002/api/health`
- **Documentation Site**: `http://127.0.0.1:9003` - Docusaurus documentation

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
- **Swagger UI**: http://127.0.0.1:9004
- **Documentation**: http://127.0.0.1:9003
- **API Docs (Legacy)**: http://127.0.0.1:9002/api-docs
- **Health Check**: http://127.0.0.1:9002/api/health

---

For detailed setup instructions, see [SETUP-GUIDE.md](SETUP-GUIDE.md)
