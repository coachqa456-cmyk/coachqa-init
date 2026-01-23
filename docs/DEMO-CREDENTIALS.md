# Demo Credentials Quick Reference

## Quick Access

### Demo Tenant Login
- **URL**: `http://127.0.0.1:9001/login`
- **Tenant**: `demo-tenant`

### Platform Admin Login
- **URL**: `http://127.0.0.1:9001/admin/login`

---

## Demo User Accounts

All demo users have the password: **`Demo@123`**

### Quality Engineers
| Email | Name | Role | Use Case |
|-------|------|------|----------|
| `coach@demo.com` | Sarah Coach | Quality Engineer | Primary coach with multiple squads |
| `user@demo.com` | Demo User | Quality Engineer | Original demo user |

### Administrators
| Email | Name | Role | Use Case |
|-------|------|------|----------|
| `admin@demo.com` | Alex Admin | Administrator | Full access, squad lead |

### Managers
| Email | Name | Role | Use Case |
|-------|------|------|----------|
| `manager@demo.com` | Jordan Manager | QA Manager | Squad management, metrics |
| `engmgr@demo.com` | Pat Engineering | Engineering Manager | Mobile squad oversight |

### Developers
| Email | Name | Role | Squad |
|-------|------|------|-------|
| `dev1@demo.com` | Taylor Dev | Developer | Frontend Squad |
| `dev2@demo.com` | Casey Dev | Developer | Frontend Squad |
| `dev3@demo.com` | Morgan Dev | Developer | Backend Squad |
| `dev4@demo.com` | Riley Dev | Developer | Backend Squad |
| `dev5@demo.com` | Avery Dev | Developer | Mobile Squad |
| `dev6@demo.com` | Quinn Dev | Developer | Mobile Squad |

### Product
| Email | Name | Role | Use Case |
|-------|------|------|----------|
| `product@demo.com` | Sam Product | Product | Product perspective, metrics |

---

## Platform Admin

| Email | Password | Use Case |
|-------|----------|----------|
| `admin@qenabler.com` | `Admin@123` | Platform administration, tenant management |

---

## Demo Data Summary

### Squads
- **Frontend Squad** (Web Platform) - 4 members
- **Backend Squad** (Platform Services) - 4 members
- **Mobile Squad** (Mobile Platform) - 4 members
- **Platform Squad** (Infrastructure) - 3 members

### Sample Data
- **7** Coaching Sessions
- **4** Quality Scorecards
- **5** Feedback Submissions
- **4** Maturity Assessments
- **8** Enablement Resources
- **6** Test Logger Sessions
- **7** Test Debt Items
- **4** Change Tracking Entries
- **4** Career Assessments

---

## Quick Test Scenarios

### 1. Quality Engineer View
```
Login: coach@demo.com
Password: Demo@123
```
- View coaching sessions across squads
- Check quality scorecards
- Review test debt register
- Access enablement resources

### 2. Developer View
```
Login: dev1@demo.com
Password: Demo@123
```
- View assigned test debt items
- Check attended coaching sessions
- Submit feedback
- Access resources

### 3. Manager View
```
Login: manager@demo.com
Password: Demo@123
```
- View squad maturity assessments
- Review quality metrics
- Monitor coaching effectiveness
- Track change progress

### 4. Administrator View
```
Login: admin@demo.com
Password: Demo@123
```
- Full access to all modules
- User and squad management
- Comprehensive platform metrics

---

## Setup

To load demo data, run:
```bash
docker exec -i qenabler-postgres-dev psql -U postgres -d qenabler_db < QEnabler-backend/migrations/023-seed-comprehensive-demo-data.sql
```

See [DEMO-DATA-GUIDE.md](./DEMO-DATA-GUIDE.md) for detailed instructions.
