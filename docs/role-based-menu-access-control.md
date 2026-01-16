# Role-Based Menu Access Control Documentation

## Overview

The Role-Based Menu Access Control system provides a flexible and secure way to manage sidebar menu visibility and access based on user roles. The system supports two types of menus:

1. **System Menus**: Default application menus (readonly for tenants, editable only by platform admin)
2. **Custom Menus**: Tenant-specific menus (created and managed by tenant admin)

Menu permissions are controlled at the role level, allowing fine-grained access control for different user roles within each tenant.

## Key Features

- **System Menus**: Predefined menus managed by platform admin
- **Custom Menus**: Tenant-specific menus created by tenant admin
- **Role-Based Permissions**: Menu access controlled per role
- **Tenant Admin**: Always has full access to all menus (non-editable)
- **Platform Admin Control**: Can edit menu permissions for all roles
- **Subscription Support**: Database schema ready for future subscription-based restrictions

## Architecture

### Database Schema

#### System Menus Table
```sql
CREATE TABLE system_menus (
  id UUID PRIMARY KEY,
  path VARCHAR(255) UNIQUE NOT NULL,
  title VARCHAR(255) NOT NULL,
  icon VARCHAR(100),
  group_name VARCHAR(100) NOT NULL,
  order_index INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

#### Custom Menus Table
```sql
CREATE TABLE custom_menus (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  path VARCHAR(255) NOT NULL,
  title VARCHAR(255) NOT NULL,
  icon VARCHAR(100),
  group_name VARCHAR(100) NOT NULL,
  order_index INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  UNIQUE(tenant_id, path)
);
```

#### Menu Permissions Table
```sql
CREATE TABLE menu_permissions (
  id UUID PRIMARY KEY,
  role_id UUID NOT NULL REFERENCES roles(id),
  menu_path VARCHAR(255) NOT NULL,
  menu_type VARCHAR(20) CHECK (menu_type IN ('system', 'custom')),
  is_allowed BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  UNIQUE(role_id, menu_path, menu_type)
);
```

### Data Flow

```
User Login
    ↓
AuthContext loads user
    ↓
Sidebar fetches available menus (system + custom)
    ↓
Sidebar fetches menu permissions for user's role
    ↓
Menus filtered based on permissions
    ↓
Filtered menus displayed in sidebar
```

## Backend Implementation

### Models

#### SystemMenu (`QEnabler-backend/src/models/SystemMenu.ts`)
- Represents system-wide menu items
- Editable only by platform admin
- Readonly for tenants

#### CustomMenu (`QEnabler-backend/src/models/CustomMenu.ts`)
- Represents tenant-specific menu items
- Editable by tenant admin for their tenant
- Isolated per tenant

#### MenuPermission (`QEnabler-backend/src/models/MenuPermission.ts`)
- Links roles to menu access permissions
- Supports both system and custom menus
- Stores permission state per role per menu

### Services

#### Menu Service (`QEnabler-backend/src/services/menu.service.ts`)

**System Menu Functions:**
- `getAllSystemMenus(activeOnly)`: Get all system menus
- `getSystemMenuById(id)`: Get specific system menu
- `createSystemMenu(data)`: Create new system menu (platform admin only)
- `updateSystemMenu(id, data)`: Update system menu (platform admin only)
- `deleteSystemMenu(id)`: Delete system menu (platform admin only)

**Custom Menu Functions:**
- `getAllCustomMenus(tenantId, activeOnly)`: Get custom menus for tenant
- `getCustomMenuById(id, tenantId)`: Get specific custom menu
- `createCustomMenu(data, tenantId)`: Create custom menu (tenant admin)
- `updateCustomMenu(id, data, tenantId)`: Update custom menu (tenant admin)
- `deleteCustomMenu(id, tenantId)`: Delete custom menu (tenant admin)

**Menu Permission Functions:**
- `getMenuPermissionsForRole(roleId)`: Get all menu permissions for a role
- `updateMenuPermissionsForRole(roleId, permissions, isPlatformAdmin, tenantId)`: Update menu permissions
- `getAvailableMenusForTenant(tenantId)`: Get all available menus (system + custom) for tenant

### API Endpoints

#### System Menu Endpoints (Platform Admin Only)

```
GET    /api/platform-admin/system-menus          - List all system menus
GET    /api/platform-admin/system-menus/:id       - Get system menu by ID
POST   /api/platform-admin/system-menus           - Create system menu
PUT    /api/platform-admin/system-menus/:id       - Update system menu
DELETE /api/platform-admin/system-menus/:id       - Delete system menu
GET    /api/system-menus                          - Get active system menus (public, readonly)
```

#### Custom Menu Endpoints (Tenant Admin)

```
GET    /api/custom-menus                         - List custom menus for current tenant
GET    /api/custom-menus/:id                     - Get custom menu by ID
POST   /api/custom-menus                         - Create custom menu
PUT    /api/custom-menus/:id                     - Update custom menu
DELETE /api/custom-menus/:id                     - Delete custom menu
```

#### Menu Permission Endpoints

```
GET    /api/roles/:roleId/menu-permissions       - Get menu permissions for role
PUT    /api/roles/:roleId/menu-permissions       - Update menu permissions for role
GET    /api/menus                                - Get available menus for tenant (system + custom)
```

### Authorization Rules

1. **System Menus**:
   - Only platform admin can create/edit/delete
   - Tenants can only view active system menus (readonly)

2. **Custom Menus**:
   - Tenant admin can create/edit/delete for their tenant only
   - Platform admin can view all custom menus

3. **Menu Permissions**:
   - **System menu permissions**: Only platform admin can edit
   - **Custom menu permissions**: Tenant admin can edit for their tenant's custom menus
   - **Admin role**: Always has all menu access (non-editable, hardcoded)

4. **Role Restrictions**:
   - Tenant admin cannot edit permissions for system roles (qe, manager, developer, executive)
   - Tenant admin cannot edit admin role permissions
   - Platform admin can edit all role permissions

## Frontend Implementation

### Components

#### Sidebar (`QEnabler-ui/src/components/layout/Sidebar.tsx`)
- Dynamically fetches menus from backend
- Filters menus based on user's role permissions
- Groups menus by category
- Handles loading states
- Admin users see all menus automatically

#### MenuPermissionEditor (`QEnabler-ui/src/components/role-management/MenuPermissionEditor.tsx`)
- Reusable component for editing menu permissions
- Displays system and custom menus separately
- Shows visual indicators for non-editable permissions
- Handles permission updates with proper authorization

#### SystemMenuEditor (`QEnabler-ui/src/components/menu-management/SystemMenuEditor.tsx`)
- Dialog component for creating/editing system menus
- Platform admin only
- Validates menu paths and properties

#### CustomMenuEditor (`QEnabler-ui/src/components/menu-management/CustomMenuEditor.tsx`)
- Dialog component for creating/editing custom menus
- Tenant admin only
- Validates menu paths and properties

### Pages

#### Platform Admin Pages

**SystemMenuManagement** (`QEnabler-ui/src/pages/platform-admin/SystemMenuManagement.tsx`)
- Manage all system menus
- Create, edit, delete system menus
- Reorder and enable/disable menus
- Future: Configure subscription plan access

**RolePermissions** (`QEnabler-ui/src/pages/platform-admin/RolePermissions.tsx`)
- Overview of all tenants
- Quick access to manage role permissions per tenant
- Search and filter tenants

**TenantDetails** (Updated - `QEnabler-ui/src/pages/platform-admin/TenantDetails.tsx`)
- Added "Role Permissions" tab
- Manage menu permissions for all roles in a tenant
- View and edit role-based menu access

#### Tenant Admin Pages

**CustomMenuManagement** (`QEnabler-ui/src/pages/menu-management/CustomMenuManagement.tsx`)
- Create and manage custom menus for tenant
- Edit menu properties (path, title, icon, group, order)
- Enable/disable custom menus

**RoleManagement** (`QEnabler-ui/src/pages/role-management/RoleManagement.tsx`)
- View and manage menu permissions for roles
- System roles shown as read-only (platform admin manages)
- Custom roles can be fully managed by tenant admin

### API Client Functions

All menu-related API functions are in `QEnabler-ui/src/utils/api.ts`:

```typescript
// System Menus
fetchSystemMenus(activeOnly?)
fetchSystemMenuById(menuId)
createSystemMenu(menu)
updateSystemMenu(menuId, menu)
deleteSystemMenu(menuId)
fetchActiveSystemMenus()

// Custom Menus
fetchCustomMenus(activeOnly?)
fetchCustomMenuById(menuId)
createCustomMenu(menu)
updateCustomMenu(menuId, menu)
deleteCustomMenu(menuId)

// Menu Permissions
fetchRoleMenuPermissions(roleId)
updateRoleMenuPermissions(roleId, permissions)
fetchAvailableMenusForTenant()
```

## Usage Guide

### For Platform Admin

#### Managing System Menus

1. Navigate to **Platform Admin** → **System Menu Management**
2. Click **Create System Menu** to add a new menu
3. Fill in:
   - Path: Route path (e.g., `/dashboard/new-feature`)
   - Title: Display name
   - Icon: Icon name from lucide-react
   - Group: Menu group (Overview, Modules, Administration)
   - Order Index: Display order within group
   - Status: Active/Inactive
4. Click **Save**

#### Managing Role Permissions

1. Navigate to **Platform Admin** → **Role Permissions**
2. Select a tenant
3. Click **Manage Permissions**
4. In the **Role Permissions** tab:
   - Select a role
   - Toggle menu permissions on/off
   - System menus and custom menus are shown separately
   - Admin role shows all menus as always enabled

### For Tenant Admin

#### Creating Custom Menus

1. Navigate to **Dashboard** → **Custom Menus**
2. Click **Create Custom Menu**
3. Fill in menu details:
   - Path: Must be unique within tenant
   - Title: Display name
   - Icon: Icon name from lucide-react
   - Group: Menu group
   - Order Index: Display order
4. Click **Save**

#### Managing Role Permissions

1. Navigate to **Dashboard** → **Role Management**
2. Select a role from the tabs
3. View/edit menu permissions:
   - **System menus**: Read-only (shows current permissions, managed by platform admin)
   - **Custom menus**: Fully editable
   - **Admin role**: Always has all access (non-editable)

## Default Configuration

### System Menus (Seeded)

The following system menus are seeded by default:

**Overview:**
- Dashboard (`/dashboard`)

**Modules:**
- Coaching Tracker (`/dashboard/coaching-tracker`)
- Quality Scorecard (`/dashboard/quality-scorecard`)
- Feedback Form (`/dashboard/feedback-form`)
- Maturity Ladder (`/dashboard/maturity-ladder`)
- Enablement Hub (`/dashboard/enablement-hub`)
- Impact Timeline (`/dashboard/impact-timeline`)
- Exploratory Testing (`/dashboard/test-logger`)
- Test Debt Register (`/dashboard/test-debt`)
- Change Management (`/dashboard/change-tracker`)
- Career Framework (`/dashboard/career-framework`)
- Squad Management (`/dashboard/squads`)
- User Management (`/dashboard/users`)

### Default Role Permissions

Default menu permissions are set based on the original `allowedRoles` configuration:

- **Admin**: All menus enabled
- **QE**: Most modules enabled (coaching, feedback, maturity, enablement, impact, test logger, test debt, change tracker, career, squads, users)
- **Manager**: View access to most modules, edit access to scorecard, feedback, maturity
- **Developer**: View access to coaching, scorecard, feedback, maturity, enablement; create/view access to test logger and test debt
- **Executive**: View-only access to scorecard, maturity, impact timeline, change tracker, career framework

## Security Considerations

1. **Backend Validation**: All authorization checks are enforced at the backend level
2. **Frontend UI**: Frontend disables non-editable options, but backend is source of truth
3. **Role Isolation**: Tenant admin cannot edit system role permissions
4. **Menu Path Validation**: Backend validates menu paths to prevent conflicts
5. **Tenant Isolation**: Custom menus are isolated per tenant
6. **Admin Protection**: Admin role permissions are always full access (hardcoded)

## Future Enhancements

### Subscription-Based Menu Access

The database schema includes support for subscription-based menu restrictions:

- **Subscription Plans Table**: Stores subscription tiers (Starter, Pro, Enterprise)
- **Menu-Subscription Mapping**: Links menus to subscription plans
- **Tenant Subscription**: Links tenants to their subscription plans

When implemented:
- Platform admin can configure which menus are available in which subscription tiers
- Menu fetching will automatically filter based on tenant's subscription plan
- Subscription changes will automatically update available menus

### Implementation Notes for Subscription Feature

1. Update `getAvailableMenusForTenant` to filter by subscription plan
2. Add subscription plan configuration UI in SystemMenuManagement
3. Add tenant subscription management in TenantDetails
4. Handle subscription expiration and downgrades gracefully

## Troubleshooting

### Common Issues

1. **Menus not appearing**:
   - Check if user has proper role permissions
   - Verify menu is active (`is_active = true`)
   - Check if menu permissions are set for the role
   - Admin users should see all menus automatically

2. **Cannot edit system menu permissions**:
   - Only platform admin can edit system menu permissions
   - Tenant admin can only edit custom menu permissions

3. **Custom menu not showing**:
   - Verify menu is created for the correct tenant
   - Check if menu is active
   - Verify role has permission for the menu path

4. **Permission changes not taking effect**:
   - Refresh the page
   - Check browser console for errors
   - Verify backend API response

## API Response Examples

### Get Available Menus
```json
{
  "success": true,
  "data": {
    "systemMenus": [
      {
        "id": "uuid",
        "path": "/dashboard",
        "title": "Dashboard",
        "icon": "BarChart",
        "group": "Overview",
        "orderIndex": 0,
        "menuType": "system"
      }
    ],
    "customMenus": [
      {
        "id": "uuid",
        "path": "/dashboard/custom-feature",
        "title": "Custom Feature",
        "icon": "BookOpen",
        "group": "Modules",
        "orderIndex": 0,
        "menuType": "custom"
      }
    ]
  }
}
```

### Get Menu Permissions
```json
{
  "success": true,
  "data": {
    "/dashboard": true,
    "/dashboard/coaching-tracker": true,
    "/dashboard/quality-scorecard": false,
    "/dashboard/custom-feature": true
  }
}
```

## Migration Guide

### Running the Migration

1. Ensure database is up to date with previous migrations
2. Run migration: `005-add-menu-permissions.sql`
3. Verify tables are created:
   - `system_menus`
   - `custom_menus`
   - `menu_permissions`
   - `subscription_plans` (for future)
   - `menu_subscription_plans` (for future)
4. Verify default data is seeded:
   - System menus
   - Default role permissions
   - Subscription plans (for future)

### Backward Compatibility

- Existing hardcoded menu structure in Sidebar.tsx has been replaced
- Menu permissions are backward compatible with existing roles
- Default permissions match previous `allowedRoles` configuration

## Related Files

### Backend
- `QEnabler-backend/migrations/005-add-menu-permissions.sql`
- `QEnabler-backend/src/models/SystemMenu.ts`
- `QEnabler-backend/src/models/CustomMenu.ts`
- `QEnabler-backend/src/models/MenuPermission.ts`
- `QEnabler-backend/src/services/menu.service.ts`
- `QEnabler-backend/src/controllers/menu.controller.ts`
- `QEnabler-backend/src/routes/menu.routes.ts`

### Frontend
- `QEnabler-ui/src/types/menu.ts`
- `QEnabler-ui/src/utils/api.ts`
- `QEnabler-ui/src/components/layout/Sidebar.tsx`
- `QEnabler-ui/src/components/role-management/MenuPermissionEditor.tsx`
- `QEnabler-ui/src/components/menu-management/SystemMenuEditor.tsx`
- `QEnabler-ui/src/components/menu-management/CustomMenuEditor.tsx`
- `QEnabler-ui/src/pages/platform-admin/SystemMenuManagement.tsx`
- `QEnabler-ui/src/pages/platform-admin/RolePermissions.tsx`
- `QEnabler-ui/src/pages/menu-management/CustomMenuManagement.tsx`
- `QEnabler-ui/src/pages/role-management/RoleManagement.tsx`

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review API response examples
3. Verify database migration completed successfully
4. Check browser console and network tab for errors











