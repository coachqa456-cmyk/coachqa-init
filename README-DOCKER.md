# Docker Setup for CoachQA

This guide explains how to run the CoachQA application using Docker and Docker Compose.

## Prerequisites

- Docker Desktop (Windows/Mac) or Docker Engine + Docker Compose (Linux)
- At least 4GB of available RAM
- Ports 9001, 9002, and 5432 available on your machine

## Quick Start

### Production Build

```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ deletes database data)
docker-compose down -v
```

### Development Build

```bash
# Build and start all services in development mode
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Stop all services
docker-compose -f docker-compose.dev.yml down
```

## Services

1. **PostgreSQL Database** - Port 5432
   - Database: `coachqa_db`
   - User: `postgres`
   - Password: `postgres`
   - ⚠️ Change password in production!

2. **Backend API** - Port 9002
   - API URL: `http://localhost:9002/api`
   - Health check: `http://localhost:9002/health-check`

3. **Frontend UI** - Port 9001
   - UI URL: `http://localhost:9001`

## Environment Variables

### Backend Environment Variables

Create a `.env` file in the `coachqa-backend` directory or set environment variables in `docker-compose.yml`:

```env
JWT_SECRET=your-secret-key-change-in-production
JWT_REFRESH_SECRET=your-refresh-secret-key-change-in-production
NODE_ENV=production
PORT=9002
DB_HOST=postgres
DB_PORT=5432
DB_NAME=coachqa_db
DB_USER=postgres
DB_PASSWORD=postgres
```

### Frontend Environment Variables

For production, set `VITE_API_URL` in the docker-compose.yml or create a `.env.production` file in `coachqa-ui`:

```env
VITE_API_URL=http://localhost:9002/api
```

## Database Migrations

Database migrations run automatically when the backend service starts. Migrations are located in `coachqa-backend/migrations/` and are executed in alphabetical order.

## Useful Commands

```bash
# Rebuild containers after code changes
docker-compose up -d --build

# View logs for specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres

# Execute commands in running container
docker-compose exec backend sh
docker-compose exec postgres psql -U postgres -d coachqa_db

# Check service status
docker-compose ps

# Restart a specific service
docker-compose restart backend
```

## Troubleshooting

### Port Already in Use

If ports 9001, 9002, or 5432 are already in use, modify the port mappings in `docker-compose.yml`:

```yaml
ports:
  - "9003:9002"  # Map container port 9002 to host port 9003
```

### Database Connection Issues

1. Ensure the PostgreSQL container is healthy:
   ```bash
   docker-compose ps
   ```

2. Check PostgreSQL logs:
   ```bash
   docker-compose logs postgres
   ```

3. Verify database credentials match in both `docker-compose.yml` and backend configuration.

### Frontend Not Connecting to Backend

1. Check that `VITE_API_URL` in `docker-compose.yml` matches your backend URL
2. Ensure both frontend and backend are on the same Docker network
3. Check browser console for CORS errors (backend CORS configuration may need adjustment)

### Container Build Fails

1. Clear Docker cache:
   ```bash
   docker-compose build --no-cache
   ```

2. Remove old containers and volumes:
   ```bash
   docker-compose down -v
   docker system prune -a
   ```

## Production Considerations

1. **Change default passwords** - Update PostgreSQL password in `docker-compose.yml`
2. **Use secrets management** - Don't hardcode secrets in docker-compose.yml
3. **Configure reverse proxy** - Use nginx or traefik for production
4. **Enable SSL/TLS** - Use HTTPS in production
5. **Backup database** - Set up regular backups for the PostgreSQL volume
6. **Monitor resources** - Configure resource limits for containers
7. **Use environment-specific configs** - Separate dev/staging/prod compose files

## Backup and Restore Database

```bash
# Backup
docker-compose exec postgres pg_dump -U postgres coachqa_db > backup.sql

# Restore
docker-compose exec -T postgres psql -U postgres coachqa_db < backup.sql
```




