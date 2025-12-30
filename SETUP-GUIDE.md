# CoachQA Setup Guide

## Prerequisites

- Docker and Docker Compose installed
- Git (to clone the repository)
- At least 4GB RAM available for Docker

## Initial Setup

### 1. Clone and Navigate

```bash
cd "D:\AI Projects\CoachQA-Project"
```

### 2. Start Services

```bash
# Development environment
docker-compose -f docker-compose.dev.yml up -d

# Or production environment
docker-compose up -d
```

### 3. Wait for Initialization

```bash
# Watch database initialization
docker logs -f coachqa-postgres-dev

# Wait until you see: "✅ Complete database setup finished!"
```

### 4. Verify Services

```bash
# Check all containers are running
docker ps

# Should see:
# - coachqa-postgres-dev (port 5432)
# - coachqa-backend-dev (port 9002)
# - coachqa-frontend-dev (port 9001)
```

## Access the Application

### Frontend
- **URL**: `http://127.0.0.1:9001` or `http://localhost:9001`
- **Status**: Check `docker logs coachqa-frontend-dev`

### Backend API
- **URL**: `http://127.0.0.1:9002/api`
- **Health Check**: `http://127.0.0.1:9002/api/health`
- **API Docs**: `http://127.0.0.1:9002/api-docs`
- **Status**: Check `docker logs coachqa-backend-dev`

### Database
- **Host**: `127.0.0.1` or `localhost`
- **Port**: `5432`
- **Database**: `coachqa_db`
- **User**: `postgres`
- **Password**: `postgres`

## Login Credentials

### Platform Admin
- **URL**: `http://127.0.0.1:9001/admin/login`
- **Email**: `admin@coachqa.com`
- **Password**: `Admin@123`

### Demo Tenant User
- **URL**: `http://127.0.0.1:9001/login`
- **Email**: `user@demo.com`
- **Password**: `Demo@123`

## Common Commands

### Start Services
```bash
docker-compose -f docker-compose.dev.yml up -d
```

### Stop Services
```bash
docker-compose -f docker-compose.dev.yml down
```

### View Logs
```bash
# All services
docker-compose -f docker-compose.dev.yml logs -f

# Specific service
docker logs -f coachqa-backend-dev
docker logs -f coachqa-frontend-dev
docker logs -f coachqa-postgres-dev
```

### Restart Services
```bash
docker-compose -f docker-compose.dev.yml restart
```

### Rebuild Services
```bash
docker-compose -f docker-compose.dev.yml up -d --build
```

### Reset Database
```bash
# WARNING: Deletes all data!
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up -d postgres
```

## Environment Configuration

### Development (`docker-compose.dev.yml`)

- **Backend**: Hot reload enabled, source code mounted
- **Frontend**: Vite dev server, source code mounted
- **Database**: Complete setup by default (`USE_COMPLETE_SETUP=true`)

### Production (`docker-compose.yml`)

- **Backend**: Production build
- **Frontend**: Nginx serving static files
- **Database**: Complete setup by default

## Troubleshooting

### Backend Not Starting

1. Check logs: `docker logs coachqa-backend-dev`
2. Check database connection: `docker logs coachqa-postgres-dev`
3. Verify environment variables in `docker-compose.dev.yml`

### Frontend Not Loading

1. Check logs: `docker logs coachqa-frontend-dev`
2. Verify API URL: Should be `http://127.0.0.1:9002`
3. Check browser console for errors

### Database Issues

1. Check initialization: `docker logs coachqa-postgres-dev`
2. Verify migrations ran successfully
3. Check for duplicate errors (run migration 013 if needed)

### Port Conflicts

If ports 9001, 9002, or 5432 are already in use:

1. Stop conflicting services
2. Or change ports in `docker-compose.dev.yml`:
   ```yaml
   ports:
     - "9003:9002"  # Change backend port
     - "9004:9001"  # Change frontend port
   ```

## Development Workflow

### Making Code Changes

1. **Backend**: Changes in `coachqa-backend/src/` are automatically reloaded
2. **Frontend**: Changes in `coachqa-ui/src/` are automatically reloaded
3. **Database**: Changes require migration or database reset

### Running Migrations

```bash
# Connect to database
docker exec -it coachqa-postgres-dev psql -U postgres -d coachqa_db

# Run migration
\i /docker-entrypoint-initdb.d/012-add-code-column-to-roles.sql
```

### Creating Test Data

```bash
# Create test admin and tenant
npm run create-test-admin -- --email admin@example.com --password password --name "Test Admin" --tenantName "Test Tenant"
```

## Project Structure

```
CoachQA-Project/
├── coachqa-backend/          # Backend API (Node.js/Express)
│   ├── src/                  # Source code
│   ├── migrations/           # Database migrations
│   └── Dockerfile.dev       # Development Dockerfile
├── coachqa-ui/               # Frontend (React/Vite)
│   ├── src/                  # Source code
│   └── Dockerfile.dev       # Development Dockerfile
├── docker-compose.dev.yml    # Development configuration
├── docker-compose.yml        # Production configuration
└── docs/                     # Documentation
```

## Next Steps

1. ✅ Database is initialized
2. ✅ Services are running
3. ✅ You can log in with default credentials
4. 📝 Review API documentation at `http://127.0.0.1:9002/api-docs`
5. 🎨 Start developing!

## Additional Resources

- **API Documentation**: `http://127.0.0.1:9002/api-docs`
- **Migration Guide**: `coachqa-backend/migrations/MIGRATION-GUIDE.md`
- **Database Setup**: `DATABASE-SETUP.md`
- **Docker Setup**: `docker-compose-setup.md`

