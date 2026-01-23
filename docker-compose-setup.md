# Docker Compose Database Setup Configuration

## Overview

The docker-compose files have been updated to support the complete database setup migration (`000-complete-database-setup.sql`) by default, with the option to use individual migrations if needed.

## Configuration

### Environment Variable

Both `docker-compose.dev.yml` and `docker-compose.yml` now include:

```yaml
USE_COMPLETE_SETUP: ${USE_COMPLETE_SETUP:-true}
```

- **Default**: `true` (uses complete database setup)
- **To use individual migrations**: Set to `false`

## Usage

### Option 1: Use Complete Setup (Default - Recommended)

The complete setup is used by default. Just start the containers:

```bash
# Development
docker-compose -f docker-compose.dev.yml up -d

# Production
docker-compose up -d
```

### Option 2: Use Individual Migrations

To use individual migrations instead, set the environment variable:

```bash
# Development
USE_COMPLETE_SETUP=false docker-compose -f docker-compose.dev.yml up -d

# Or create a .env file
echo "USE_COMPLETE_SETUP=false" >> .env
docker-compose -f docker-compose.dev.yml up -d
```

### Option 3: Override in docker-compose.yml

You can also directly edit the docker-compose file:

```yaml
environment:
  USE_COMPLETE_SETUP: "false"  # Change to false
```

## Fresh Database Setup

To start with a fresh database using the complete setup:

```bash
# Remove existing volumes
docker-compose -f docker-compose.dev.yml down -v

# Start with complete setup (default)
docker-compose -f docker-compose.dev.yml up -d postgres

# Check logs
docker logs qenabler-postgres-dev
```

## What Gets Created

When using the complete setup, you get:

- ✅ All database tables and types
- ✅ System roles and permissions
- ✅ System menus and menu permissions
- ✅ Platform admin: `admin@qenabler.com` / `Admin@123`
- ✅ Demo tenant: `demo-tenant`
- ✅ Demo user: `user@demo.com` / `Demo@123`
- ✅ All seed data

## Benefits of Complete Setup

1. **Faster**: Single file execution (~5-10 seconds vs ~30-60 seconds)
2. **Complete**: Everything in one migration
3. **Idempotent**: Safe to run multiple times
4. **Fresh Start**: Perfect for new environments

## Switching Between Methods

### From Individual to Complete Setup

```bash
# Stop containers
docker-compose -f docker-compose.dev.yml down

# Remove volumes (WARNING: deletes all data)
docker-compose -f docker-compose.dev.yml down -v

# Start with complete setup
docker-compose -f docker-compose.dev.yml up -d
```

### From Complete to Individual Migrations

```bash
# Stop containers
docker-compose -f docker-compose.dev.yml down

# Remove volumes (WARNING: deletes all data)
docker-compose -f docker-compose.dev.yml down -v

# Start with individual migrations
USE_COMPLETE_SETUP=false docker-compose -f docker-compose.dev.yml up -d
```

## Files Updated

- ✅ `docker-compose.dev.yml` - Added `USE_COMPLETE_SETUP` environment variable
- ✅ `docker-compose.yml` - Added `USE_COMPLETE_SETUP` environment variable
- ✅ `qenabler-backend/migrations/00-init-database.sh` - Checks environment variable

## Troubleshooting

### Complete Setup Not Running

Check if the environment variable is set correctly:

```bash
docker exec qenabler-postgres-dev env | grep USE_COMPLETE_SETUP
```

### Want to See What's Running

Check the initialization logs:

```bash
docker logs qenabler-postgres-dev | grep -A 20 "Database Initialization"
```

### Reset Everything

```bash
# Complete reset
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up -d
```

## Notes

- The complete setup is **idempotent** - safe to run multiple times
- Individual migrations are better for tracking migration history
- Use complete setup for fresh databases and development
- Use individual migrations for production with existing data

