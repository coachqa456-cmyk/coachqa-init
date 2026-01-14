# Role Management Quick Reference Guide

## Quick Start

### Creating Roles

**Global Role (All Tenants):**
```typescript
POST /api/platform-admin/roles
{
  "name": "role-name",
  "description": "Description",
  "tenantId": null  // null = global
}
```

**Tenant-Specific Role:**
```typescript
POST /api/platform-admin/roles
{
  "name": "role-name",
  "description": "Description",
  "tenantId": "tenant-uuid"  // specific tenant
}
```

### Updating Menu Permissions

```typescript
PUT /api/platform-admin/tenants/:tenantId/roles/:roleId/menu-permissions
{
  "permissions": {
    "systemMenus": { "/dashboard": true, "/coaching": false },
    "customMenus": { "/custom-page": true }
  }
}
```

## Frontend Routes

| Route | Description |
|-------|-------------|
| `/admin/roles` | Role Management (all roles) |
| `/admin/tenants/:id` → Roles tab | Tenant-specific roles |
| `/admin/tenants/:id` → Role Permissions tab | Manage menu permissions |

## API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/platform-admin/roles` | Get all roles |
| GET | `/api/platform-admin/roles/:id` | Get role by ID |
| GET | `/api/platform-admin/tenants/:id/roles` | Get tenant roles |
| POST | `/api/platform-admin/roles` | Create role |
| PUT | `/api/platform-admin/roles/:id` | Update role |
| DELETE | `/api/platform-admin/roles/:id` | Delete role |
| GET | `/api/platform-admin/tenants/:id/roles/:roleId/menu-permissions` | Get permissions |
| PUT | `/api/platform-admin/tenants/:id/roles/:roleId/menu-permissions` | Update permissions |

## Role Types

- **System Role**: Pre-defined, cannot be deleted (admin, qe, manager, developer, executive)
- **Global Custom Role**: Created by platform admin, available to all tenants (`tenantId: null`)
- **Tenant-Specific Role**: Created for a specific tenant (`tenantId: "uuid"`)

## Common Tasks

### Task: Create a new global role
1. Go to `/admin/roles`
2. Click "Create Role"
3. Select "Global (Available to All Tenants)"
4. Enter name and description
5. Click "Create Role"

### Task: Assign menu permissions
1. Go to `/admin/tenants/:id`
2. Click "Role Permissions" tab
3. Select a role
4. Toggle menu permissions
5. Save automatically

### Task: Create tenant-specific role
1. Go to `/admin/tenants/:id`
2. Click "Roles" tab
3. Click "Create Role"
4. Enter role details (tenant is pre-selected)
5. Click "Create Role"

## TypeScript Types

```typescript
interface Role {
  id: string;
  name: string;
  description?: string | null;
  tenantId?: string | null;
  isSystemRole: boolean;
  permissions: Record<string, boolean>;
}

interface RolePayload {
  name: string;
  description?: string;
  tenantId?: string | null;
  isSystemRole?: boolean;
  permissions?: Record<string, boolean>;
}
```

## Error Codes

| Code | Meaning | Solution |
|------|---------|----------|
| 400 | Bad Request | Check required fields |
| 403 | Forbidden | Must be platform admin |
| 404 | Not Found | Role doesn't exist |
| 409 | Conflict | Role name already exists |

## Notes

- System roles cannot be deleted
- Role names must be unique per tenant (or globally if `tenantId` is null)
- Menu permissions are saved automatically
- Global roles are accessible to all tenants
- Tenant-specific roles are only visible to that tenant







