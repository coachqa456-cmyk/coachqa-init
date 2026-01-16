# Demo Data Guide

This guide explains how to set up comprehensive demo data for the QEnabler platform free demo.

## Overview

The demo data script (`023-seed-comprehensive-demo-data.sql`) populates the database with realistic sample data across all modules to showcase the platform's capabilities.

## What Gets Created

### Users (12 total)
- **coach@demo.com** - Sarah Coach (Quality Engineer) - Password: `Demo@123`
- **user@demo.com** - Demo User (Quality Engineer) - Password: `Demo@123`
- **admin@demo.com** - Alex Admin (Administrator) - Password: `Demo@123`
- **manager@demo.com** - Jordan Manager (QA Manager) - Password: `Demo@123`
- **dev1@demo.com** - Taylor Dev (Developer) - Password: `Demo@123`
- **dev2@demo.com** - Casey Dev (Developer) - Password: `Demo@123`
- **dev3@demo.com** - Morgan Dev (Developer) - Password: `Demo@123`
- **dev4@demo.com** - Riley Dev (Developer) - Password: `Demo@123`
- **dev5@demo.com** - Avery Dev (Developer) - Password: `Demo@123`
- **dev6@demo.com** - Quinn Dev (Developer) - Password: `Demo@123`
- **product@demo.com** - Sam Product (Product) - Password: `Demo@123`
- **engmgr@demo.com** - Pat Engineering (Engineering Manager) - Password: `Demo@123`

### Squads (4 total)
1. **Frontend Squad** - Web Platform tribe
   - Members: Taylor Dev, Casey Dev, Sarah Coach (QE), Jordan Manager (Lead)
2. **Backend Squad** - Platform Services tribe
   - Members: Morgan Dev, Riley Dev, Demo User (QE), Alex Admin (Lead)
3. **Mobile Squad** - Mobile Platform tribe
   - Members: Avery Dev, Quinn Dev, Sarah Coach (QE), Pat Engineering (Manager)
4. **Platform Squad** - Infrastructure tribe
   - Members: Taylor Dev, Demo User (QE), Jordan Manager (Lead)

### Coaching Sessions (7 total)
- Frontend Squad: 3 sessions (Strategy, Pairing, Workshop)
- Backend Squad: 2 sessions (Strategy, Exploratory)
- Mobile Squad: 2 sessions (Workshop, Pairing)

### Quality Scorecards (4 total)
- One scorecard per squad for the last 30 days
- Includes test coverage, bug counts, quality scores, and detailed metrics

### Feedback Submissions (5 total)
- Feedback from developers to quality engineers
- Ratings from 4-5 stars
- Covers coaching effectiveness and suggestions

### Maturity Assessments (4 total)
- One assessment per squad
- Levels range from 2-4 (out of 5)
- Includes goals and improvement notes

### Enablement Resources (8 total)
- Testing Strategy Guide
- API Testing Checklist
- Component Test Template
- Mobile Testing Video
- Security Testing Playbook
- Test Automation Guide
- Performance Testing Tools
- Accessibility Checklist

### Exploratory Test Sessions (6 total)
- Frontend: 2 sessions (User Dashboard, Checkout Flow)
- Backend: 2 sessions (User API, Payment API)
- Mobile: 2 sessions (Onboarding, Push Notifications)
- Includes structured findings with bugs, improvements, and observations

### Test Debt Items (7 total)
- Various priorities (low, medium, high)
- Different statuses (open, in_progress)
- Covers E2E testing, automation, device testing, etc.

### Change Tracking (4 total)
- One entry per squad for the last 60 days
- Shows maturity progression and coaching effort

### Career Assessments (4 total)
- Assessments for quality engineers at different levels
- Includes competencies, self-reflection, and manager feedback

## Setup Instructions

### Option 1: Using Docker (Recommended)

1. **Ensure the database is running:**
   ```bash
   docker-compose -f docker-compose.dev.yml up -d postgres
   ```

2. **Wait for database initialization:**
   ```bash
   docker logs -f QEnabler-postgres-dev
   ```
   Wait until you see "database system is ready to accept connections"

3. **Run the demo data migration:**
   ```bash
   docker exec -i QEnabler-postgres-dev psql -U postgres -d QEnabler_db < QEnabler-backend/migrations/023-seed-comprehensive-demo-data.sql
   ```

### Option 2: Manual SQL Execution

1. **Connect to the database:**
   ```bash
   docker exec -it QEnabler-postgres-dev psql -U postgres -d QEnabler_db
   ```

2. **Run the migration:**
   ```sql
   \i /docker-entrypoint-initdb.d/023-seed-comprehensive-demo-data.sql
   ```
   Or if running locally:
   ```sql
   \i QEnabler-backend/migrations/023-seed-comprehensive-demo-data.sql
   ```

### Option 3: Fresh Database Setup

If you want to start completely fresh:

```bash
# Remove existing database volume
docker-compose -f docker-compose.dev.yml down -v

# Start database (this will run all migrations including demo data)
docker-compose -f docker-compose.dev.yml up -d postgres

# Wait for initialization
docker logs -f QEnabler-postgres-dev
```

**Note:** The demo data script requires that migration `010-seed-demo-data.sql` has already been run (which creates the demo tenant and initial user).

## Verification

### Check Users
```sql
SELECT email, name, role, status FROM users WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant');
```

### Check Squads
```sql
SELECT name, tribe, description FROM squads WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant');
```

### Check Coaching Sessions
```sql
SELECT COUNT(*) as session_count FROM coaching_sessions WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant');
```

### Check All Data Counts
```sql
SELECT 
  (SELECT COUNT(*) FROM users WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant')) as users,
  (SELECT COUNT(*) FROM squads WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant')) as squads,
  (SELECT COUNT(*) FROM coaching_sessions WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant')) as coaching_sessions,
  (SELECT COUNT(*) FROM quality_scorecards WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant')) as scorecards,
  (SELECT COUNT(*) FROM feedback_submissions WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant')) as feedback,
  (SELECT COUNT(*) FROM maturity_assessments WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant')) as assessments,
  (SELECT COUNT(*) FROM enablement_resources WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant')) as resources,
  (SELECT COUNT(*) FROM exploratory_test_sessions WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant')) as test_sessions,
  (SELECT COUNT(*) FROM test_debt_items WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant')) as test_debt,
  (SELECT COUNT(*) FROM change_tracking WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant')) as change_tracking,
  (SELECT COUNT(*) FROM career_assessments WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant')) as career_assessments;
```

## Demo Scenarios

### Scenario 1: Quality Engineer Dashboard
1. Login as `coach@demo.com` / `Demo@123`
2. View dashboard with statistics
3. Check coaching sessions across different squads
4. Review quality scorecards
5. Explore test debt register

### Scenario 2: Developer Experience
1. Login as `dev1@demo.com` / `Demo@123`
2. View assigned test debt items
3. Check coaching sessions attended
4. Review enablement resources
5. Submit feedback

### Scenario 3: Manager Overview
1. Login as `manager@demo.com` / `Demo@123`
2. View squad maturity assessments
3. Review quality metrics across squads
4. Check change tracking progress
5. Monitor coaching effectiveness

### Scenario 4: Administrator
1. Login as `admin@demo.com` / `Demo@123`
2. Manage users and squads
3. View comprehensive platform metrics
4. Review all coaching sessions
5. Access all modules

## Resetting Demo Data

To reset and re-seed the demo data:

```bash
# Option 1: Reset specific tables (preserves users and squads)
docker exec -it QEnabler-postgres-dev psql -U postgres -d QEnabler_db -c "
  DELETE FROM coaching_sessions WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant');
  DELETE FROM quality_scorecards WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant');
  DELETE FROM feedback_submissions WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant');
  DELETE FROM maturity_assessments WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant');
  DELETE FROM enablement_resources WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant');
  DELETE FROM exploratory_test_sessions WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant');
  DELETE FROM test_debt_items WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant');
  DELETE FROM change_tracking WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant');
  DELETE FROM career_assessments WHERE tenant_id = (SELECT id FROM tenants WHERE slug = 'demo-tenant');
"

# Then re-run the demo data script
docker exec -i QEnabler-postgres-dev psql -U postgres -d QEnabler_db < QEnabler-backend/migrations/023-seed-comprehensive-demo-data.sql
```

## Troubleshooting

### Error: "Demo tenant not found"
- Ensure migration `010-seed-demo-data.sql` has been run first
- Check that the demo tenant exists: `SELECT * FROM tenants WHERE slug = 'demo-tenant';`

### Error: "duplicate key value violates unique constraint"
- The script uses `ON CONFLICT DO NOTHING` to handle existing data
- If you want to replace data, delete existing records first (see Resetting Demo Data)

### Data not appearing in UI
- Ensure backend is running and connected to the database
- Check that you're logged in with a user from the demo tenant
- Verify the tenant context is correct in the frontend

## Notes

- All demo users have the password: `Demo@123`
- Dates are relative to the current date (e.g., `CURRENT_DATE - INTERVAL '7 days'`)
- The script is idempotent - it can be run multiple times safely
- Some relationships (like squad members) may need to be set up after users are created

## Support

For issues or questions:
1. Check database logs: `docker logs QEnabler-postgres-dev`
2. Verify migrations: `docker exec -it QEnabler-postgres-dev psql -U postgres -d QEnabler_db -c "\dt"`
3. Review the migration file: `QEnabler-backend/migrations/023-seed-comprehensive-demo-data.sql`
