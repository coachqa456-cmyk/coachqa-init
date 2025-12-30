# CoachQA Database Setup Guide

## Quick Start

### Fresh Database Setup (Recommended)

```bash
# Start with complete database setup
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up -d postgres

# Wait for initialization (check logs)
docker logs -f coachqa-postgres-dev
```

### Using Individual Migrations

```bash
# Set environment variable
USE_COMPLETE_SETUP=false docker-compose -f docker-compose.dev.yml down -v
USE_COMPLETE_SETUP=false docker-compose -f docker-compose.dev.yml up -d postgres
```

## Database Configuration

### Environment Variables

In `docker-compose.dev.yml`:

```yaml
postgres:
  environment:
    POSTGRES_DB: coachqa_db
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres
    USE_COMPLETE_SETUP: ${USE_COMPLETE_SETUP:-true}  # Use complete setup by default
```

### Connection Details

- **Host**: `localhost` or `127.0.0.1`
- **Port**: `5432`
- **Database**: `coachqa_db`
- **User**: `postgres`
- **Password**: `postgres`

## What Gets Created

### Tables

- **Core**: tenants, users, squads, refresh_tokens, user_invitations
- **Platform Admin**: platform_admins
- **Modules**: coaching_sessions, quality_scorecards, feedback_submissions, maturity_assessments, enablement_resources, exploratory_test_sessions, test_debt_items, change_tracking, career_assessments
- **Roles & Permissions**: roles, permissions, menu_permissions
- **Menus**: system_menus, custom_menus
- **Settings**: settings
- **Subscriptions**: subscription_plans, menu_subscription_plans (for future use)

### Seed Data

- **System Roles**: 6 roles with appropriate permissions
- **System Menus**: 13 menu items
- **Menu Permissions**: Permissions for all system roles
- **Platform Admin**: admin@coachqa.com / Admin@123
- **Demo Tenant**: demo-tenant
- **Demo User**: user@demo.com / Demo@123
- **Custom Role**: Custom Team Lead for demo tenant

## Default Users

### Platform Admin

- **Email**: `admin@coachqa.com`
- **Password**: `Admin@123`
- **Permissions**: All platform admin permissions enabled
- **Login URL**: `http://127.0.0.1:9001/admin/login`

### Demo Tenant User

- **Email**: `user@demo.com`
- **Password**: `Demo@123`
- **Role**: Quality Engineer
- **Login URL**: `http://127.0.0.1:9001/login`

## System Roles

| Role | Code | Description |
|------|------|-------------|
| Administrator | `ADMIN` | Full access to all modules and features |
| QA Manager | `QA_MANAGER` | Quality modules and team management |
| Quality Engineer | `QUALITY_ENGINEER` | Coaching and quality modules |
| Developer | `DEVELOPER` | Testing and quality modules |
| Product | `PRODUCT` | Quality metrics and feedback |
| Engineering Manager | `ENGINEERING_MANAGER` | Quality and team management |

## Verification

### Check Database Connection

```bash
docker exec -it coachqa-postgres-dev psql -U postgres -d coachqa_db -c "SELECT version();"
```

### List All Tables

```bash
docker exec -it coachqa-postgres-dev psql -U postgres -d coachqa_db -c "\dt"
```

### Check Roles

```bash
docker exec -it coachqa-postgres-dev psql -U postgres -d coachqa_db -c "SELECT code, name, is_system_role FROM roles ORDER BY is_system_role DESC, name;"
```

### Check Platform Admin

```bash
docker exec -it coachqa-postgres-dev psql -U postgres -d coachqa_db -c "SELECT email, name, status FROM platform_admins;"
```

## Troubleshooting

### Database Not Initializing

1. **Check logs**: `docker logs coachqa-postgres-dev`
2. **Remove volume**: `docker-compose -f docker-compose.dev.yml down -v`
3. **Restart**: `docker-compose -f docker-compose.dev.yml up -d postgres`

### Migration Errors

1. **"already exists" errors**: Normal for idempotent migrations
2. **"column does not exist"**: Run fix migrations (011-013)
3. **"duplicate key"**: Run migration 013 to remove duplicates

### Connection Issues

1. **Check container status**: `docker ps`
2. **Check port**: `netstat -ano | findstr :5432`
3. **Check logs**: `docker logs coachqa-postgres-dev`

## Maintenance

### Backup Database

```bash
docker exec coachqa-postgres-dev pg_dump -U postgres coachqa_db > backup.sql
```

### Restore Database

```bash
docker exec -i coachqa-postgres-dev psql -U postgres coachqa_db < backup.sql
```

### Reset Database

```bash
# WARNING: This deletes all data!
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up -d postgres
```

## Related Files

- `coachqa-backend/migrations/000-complete-database-setup.sql` - Complete setup
- `coachqa-backend/migrations/00-init-database.sh` - Init script
- `docker-compose.dev.yml` - Docker configuration
- `coachqa-backend/migrations/MIGRATION-GUIDE.md` - Detailed migration guide

