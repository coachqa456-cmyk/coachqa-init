# Role-Based Access Control & Role Management Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Database Schema](#database-schema)
4. [Backend API](#backend-api)
5. [Frontend Components](#frontend-components)
6. [Usage Guide](#usage-guide)
7. [Examples](#examples)

---

## Overview

The CoachQA platform implements a comprehensive Role-Based Access Control (RBAC) system that allows platform administrators to manage roles and permissions for both global (system-wide) and tenant-specific access control.

### Key Features

- **Global Roles**: Roles accessible to all tenants (created without `tenantId`)
- **Tenant-Specific Roles**: Roles created for specific tenants
- **Menu Permissions**: Fine-grained control over menu access per role
- **System Roles**: Pre-defined roles that cannot be deleted
- **Platform Admin CRUD**: Full create, read, update, delete operations for roles

---

## Architecture

### Role Types

1. **System Roles**: Pre-defined roles (admin, qe, manager, developer, executive) that are available to all tenants
2. **Global Custom Roles**: Custom roles created by platform admin, accessible to all tenants
3. **Tenant-Specific Roles**: Custom roles created for a specific tenant

### Permission System

- **Menu Permissions**: Control which menus/features a role can access
- **Role Permissions**: JSONB field for future extensibility
- **Menu Types**: System menus (platform-wide) and Custom menus (tenant-specific)

---

## Database Schema

### Roles Table

```sql
CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name VARCHAR NOT NULL,
  description TEXT,
  is_system_role BOOLEAN NOT NULL DEFAULT false,
  permissions JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(tenant_id, name)
);

CREATE INDEX idx_roles_tenant_id ON roles(tenant_id);
CREATE INDEX idx_roles_is_system_role ON roles(is_system_role);
```

### Menu Permissions Table

```sql
CREATE TABLE menu_permissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  menu_id UUID NOT NULL,
  menu_type VARCHAR(20) NOT NULL CHECK (menu_type IN ('system', 'custom')),
  has_access BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(role_id, menu_id, menu_type)
);
```

### System Menus Table

```sql
CREATE TABLE system_menus (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  path VARCHAR NOT NULL UNIQUE,
  title VARCHAR NOT NULL,
  icon VARCHAR,
  group_name VARCHAR,
  order_index INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Custom Menus Table

```sql
CREATE TABLE custom_menus (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  path VARCHAR NOT NULL,
  title VARCHAR NOT NULL,
  icon VARCHAR,
  group_name VARCHAR,
  order_index INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(tenant_id, path)
);
```

---

## Backend API

### Base URL
```
/api/platform-admin
```

### Authentication
All endpoints require platform admin authentication via JWT token in the `Authorization` header:
```
Authorization: Bearer <access_token>
```

### Role Management Endpoints

#### 1. Get All Roles
**GET** `/api/platform-admin/roles?tenantId={tenantId}`

**Query Parameters:**
- `tenantId` (optional): Filter roles by tenant. If provided, returns both tenant-specific and global roles. If omitted, returns only global roles.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "role-name",
      "description": "Role description",
      "tenantId": null,
      "isSystemRole": false,
      "permissions": {},
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

#### 2. Get Role by ID
**GET** `/api/platform-admin/roles/:id`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "role-name",
    "description": "Role description",
    "tenantId": null,
    "isSystemRole": false,
    "permissions": {},
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

#### 3. Get Tenant Roles
**GET** `/api/platform-admin/tenants/:tenantId/roles`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "role-name",
      "description": "Role description",
      "tenantId": "tenant-uuid",
      "isSystemRole": false,
      "permissions": {},
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

#### 4. Create Role
**POST** `/api/platform-admin/roles`

**Request Body:**
```json
{
  "name": "role-name",
  "description": "Role description (optional)",
  "tenantId": null,  // null for global role, UUID for tenant-specific
  "isSystemRole": false,  // optional, defaults to false
  "permissions": {}  // optional, defaults to {}
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "role-name",
    "description": "Role description",
    "tenantId": null,
    "isSystemRole": false,
    "permissions": {},
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

**Error Responses:**
- `400`: Missing required fields
- `409`: Role with same name already exists
- `403`: Not a platform admin

#### 5. Update Role
**PUT** `/api/platform-admin/roles/:id`

**Request Body:**
```json
{
  "name": "updated-role-name",  // optional
  "description": "Updated description",  // optional
  "permissions": {}  // optional
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "updated-role-name",
    "description": "Updated description",
    "tenantId": null,
    "isSystemRole": false,
    "permissions": {},
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

#### 6. Delete Role
**DELETE** `/api/platform-admin/roles/:id`

**Response:**
```json
{
  "success": true,
  "message": "Role deleted successfully"
}
```

**Error Responses:**
- `400`: Cannot delete system roles
- `404`: Role not found
- `403`: Not a platform admin

### Menu Permission Endpoints

#### 1. Get Menu Permissions for Role
**GET** `/api/platform-admin/tenants/:tenantId/roles/:roleId/menu-permissions`

**Response:**
```json
{
  "success": true,
  "data": {
    "systemMenus": {
      "/dashboard": true,
      "/coaching": false
    },
    "customMenus": {
      "/custom-page": true
    }
  }
}
```

#### 2. Update Menu Permissions for Role
**PUT** `/api/platform-admin/tenants/:tenantId/roles/:roleId/menu-permissions`

**Request Body:**
```json
{
  "permissions": {
    "systemMenus": {
      "/dashboard": true,
      "/coaching": false
    },
    "customMenus": {
      "/custom-page": true
    }
  }
}
```

---

## Frontend Components

### Pages

#### 1. Role Management Page
**Path:** `/admin/roles`

**Features:**
- View all roles (global and tenant-specific)
- Filter by tenant (All, Global, or specific tenant)
- Create new roles (global or tenant-specific)
- Edit existing roles
- Delete roles (system roles cannot be deleted)
- Display role type (System/Custom) and tenant association

**Component:** `coachqa-ui/src/pages/platform-admin/RoleManagement.tsx`

#### 2. Tenant Details - Roles Tab
**Path:** `/admin/tenants/:tenantId`

**Features:**
- View roles for a specific tenant
- Create tenant-specific roles
- Edit tenant roles
- Delete tenant roles
- See user count per role

**Component:** `coachqa-ui/src/pages/platform-admin/TenantDetails.tsx`

#### 3. Tenant Details - Role Permissions Tab
**Path:** `/admin/tenants/:tenantId` (Role Permissions tab)

**Features:**
- Manage menu permissions for each role
- Edit system menu permissions
- Edit custom menu permissions
- Visual permission editor

**Component:** Uses `MenuPermissionEditor` component

### API Functions

**File:** `coachqa-ui/src/utils/api.ts`

```typescript
// Get all roles
fetchAllRoles(tenantId?: string): Promise<Response>

// Get role by ID
fetchRoleById(roleId: string): Promise<Response>

// Create role
createRole(data: RolePayload): Promise<Response>

// Update role
updateRole(roleId: string, data: Partial<RolePayload>): Promise<Response>

// Delete role
deleteRole(roleId: string): Promise<Response>

// Get tenant roles
fetchPlatformTenantRoles(tenantId: string): Promise<Response>

// Get/Update menu permissions
fetchPlatformTenantRoleMenuPermissions(tenantId: string, roleId: string): Promise<Response>
updatePlatformTenantRoleMenuPermissions(tenantId: string, roleId: string, permissions: MenuPermissions): Promise<Response>
```

### TypeScript Interfaces

```typescript
interface Role {
  id: string;
  name: string;
  description?: string | null;
  tenantId?: string | null;
  isSystemRole: boolean;
  permissions: Record<string, boolean>;
  createdAt?: string;
  updatedAt?: string;
}

interface RolePayload {
  name: string;
  description?: string;
  tenantId?: string | null;
  isSystemRole?: boolean;
  permissions?: Record<string, boolean>;
}

interface MenuPermissions {
  systemMenus: Record<string, boolean>;
  customMenus: Record<string, boolean>;
}
```

---

## Usage Guide

### Creating a Global Role

1. Navigate to **Role Management** (`/admin/roles`)
2. Click **Create Role**
3. Fill in:
   - **Role Name**: e.g., "Senior Developer"
   - **Description**: Optional description
   - **Tenant**: Select "Global (Available to All Tenants)"
   - **System Role**: Leave unchecked (for custom roles)
4. Click **Create Role**

### Creating a Tenant-Specific Role

**Option 1: From Role Management Page**
1. Navigate to **Role Management** (`/admin/roles`)
2. Click **Create Role**
3. Select the specific tenant from the dropdown
4. Fill in role details
5. Click **Create Role**

**Option 2: From Tenant Details**
1. Navigate to **Tenant Management** → Select a tenant
2. Go to the **Roles** tab
3. Click **Create Role**
4. Fill in role details (tenant is pre-selected)
5. Click **Create Role**

### Managing Menu Permissions

1. Navigate to **Tenant Management** → Select a tenant
2. Go to the **Role Permissions** tab
3. Select a role from the list
4. Use the permission editor to:
   - Enable/disable access to system menus
   - Enable/disable access to custom menus
5. Changes are saved automatically

### Editing a Role

1. Navigate to **Role Management** or **Tenant Details** → **Roles** tab
2. Click the **Edit** icon next to the role
3. Modify name, description, or permissions
4. Click **Save Changes**

### Deleting a Role

1. Navigate to **Role Management** or **Tenant Details** → **Roles** tab
2. Click the **Delete** icon next to the role
3. Confirm deletion
4. **Note**: System roles cannot be deleted

---

## Examples

### Example 1: Create a Global "Project Manager" Role

**Request:**
```bash
POST /api/platform-admin/roles
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "project-manager",
  "description": "Project Manager role with access to project management features",
  "tenantId": null,
  "isSystemRole": false,
  "permissions": {}
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "project-manager",
    "description": "Project Manager role with access to project management features",
    "tenantId": null,
    "isSystemRole": false,
    "permissions": {},
    "createdAt": "2024-01-15T10:30:00.000Z",
    "updatedAt": "2024-01-15T10:30:00.000Z"
  }
}
```

### Example 2: Create a Tenant-Specific "Custom QA Lead" Role

**Request:**
```bash
POST /api/platform-admin/roles
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "custom-qa-lead",
  "description": "Custom QA Lead role for Acme Corp",
  "tenantId": "123e4567-e89b-12d3-a456-426614174000",
  "isSystemRole": false,
  "permissions": {}
}
```

### Example 3: Update Menu Permissions for a Role

**Request:**
```bash
PUT /api/platform-admin/tenants/123e4567-e89b-12d3-a456-426614174000/roles/550e8400-e29b-41d4-a716-446655440000/menu-permissions
Authorization: Bearer <token>
Content-Type: application/json

{
  "permissions": {
    "systemMenus": {
      "/dashboard": true,
      "/coaching": true,
      "/scorecards": false,
      "/feedback": true
    },
    "customMenus": {
      "/custom-reports": true,
      "/custom-analytics": false
    }
  }
}
```

### Example 4: Filter Roles by Tenant

**Request:**
```bash
GET /api/platform-admin/roles?tenantId=123e4567-e89b-12d3-a456-426614174000
Authorization: Bearer <token>
```

**Response:** Returns both tenant-specific roles and global roles (accessible to that tenant)

---

## Best Practices

1. **Naming Conventions**
   - Use lowercase with hyphens for role names: `senior-developer`, `qa-lead`
   - Keep names descriptive and consistent

2. **Global vs Tenant-Specific Roles**
   - Use global roles for common roles across all tenants
   - Use tenant-specific roles for unique organizational needs

3. **System Roles**
   - System roles are pre-defined and cannot be deleted
   - Use system roles as templates for custom roles

4. **Menu Permissions**
   - Start with minimal permissions and add as needed
   - Regularly review and update permissions
   - Document permission changes

5. **Role Management**
   - Don't delete roles that are in use
   - Update role descriptions to reflect current usage
   - Use the filter feature to manage roles efficiently

---

## Error Handling

### Common Errors

1. **409 Conflict**: Role name already exists
   - Solution: Use a different name or update the existing role

2. **400 Bad Request**: Cannot delete system role
   - Solution: System roles are protected and cannot be deleted

3. **403 Forbidden**: Not a platform admin
   - Solution: Ensure you're logged in as a platform admin

4. **404 Not Found**: Role not found
   - Solution: Verify the role ID is correct

---

## Security Considerations

1. **Authentication**: All endpoints require platform admin authentication
2. **Authorization**: Only platform admins can manage roles
3. **System Role Protection**: System roles cannot be deleted
4. **Tenant Isolation**: Tenant-specific roles are scoped to their tenant
5. **Permission Validation**: Menu permissions are validated on both frontend and backend

---

## Future Enhancements

1. **Role Hierarchies**: Support for role inheritance
2. **Permission Templates**: Pre-defined permission sets
3. **Bulk Operations**: Create/update multiple roles at once
4. **Role Usage Analytics**: Track which roles are most used
5. **Permission Auditing**: Log all permission changes
6. **Role Expiration**: Time-based role assignments

---

## Support

For issues or questions:
- Check the API documentation
- Review error messages in the browser console
- Check backend logs for detailed error information
- Contact the development team

---

**Last Updated:** January 2024
**Version:** 1.0.0










