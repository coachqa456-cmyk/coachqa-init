# Platform Admin System Role Permissions Management

## Overview

Platform administrators can now edit permissions and roles for system roles directly from the Role Management interface. This feature allows platform admins to configure menu access permissions for all system roles (admin, qe, manager, developer, executive) without needing to navigate through tenant-specific pages.

## Features

### 1. System Role Permission Editing
- Platform admins can edit menu permissions for all system roles
- System roles are global roles available to all tenants
- Permissions can be configured for both system menus and custom menus (when applicable)

### 2. Unified Role Management Interface
- All roles (system and custom) are managed from a single interface
- Easy filtering by tenant or viewing all roles
- Direct access to permission management for each role

### 3. Permission Management Dialog
- Full-featured permission editor embedded in a dialog
- Shows only relevant menus (system menus for system roles)
- Real-time permission updates with visual feedback

## User Guide

### Accessing Role Management

1. Log in as a platform admin
2. Navigate to **Admin Dashboard** → **Roles** (`/admin/roles`)
3. You will see a list of all roles (system and custom)

### Managing System Role Permissions

1. **Find the System Role**
   - Use the filter dropdown to view "Global Roles (All Tenants)" or "All Roles"
   - System roles are marked with a blue "System Role" chip

2. **Open Permissions Dialog**
   - Click the **Security icon** (🔒) button in the Actions column for the desired role
   - A dialog will open showing the role details and permission editor

3. **Edit Permissions**
   - Toggle switches to enable/disable menu access for each menu item
   - Menus are grouped by category (e.g., "Main", "Quality", "Management")
   - Changes are saved automatically when you toggle a switch

4. **Close Dialog**
   - Click the "Close" button to exit the permissions dialog
   - Changes are persisted immediately

### Understanding System Roles

**System Roles** are pre-defined roles that:
- Are available to all tenants
- Cannot be deleted
- Can only have their permissions edited by platform admins
- Include: `admin`, `qe`, `manager`, `developer`, `executive`

**Admin Role Special Behavior:**
- The `admin` role always has full access to all menus
- Permission switches are disabled for admin role (always enabled)
- This ensures tenant administrators always have full access

### Filtering Roles

The Role Management page provides filtering options:

- **All Roles**: Shows both system and custom roles from all tenants
- **Global Roles (All Tenants)**: Shows only system roles (tenantId = null)
- **Specific Tenant**: Shows roles belonging to a specific tenant

## Technical Details

### API Endpoints

#### Fetch System Menus (Platform Admin)
```
GET /api/platform-admin/system-menus?activeOnly=true
```
Returns all active system menus for platform admin to configure permissions.

#### Update Role Permissions
```
PUT /api/roles/{roleId}/menu-permissions
Body: { permissions: { "/dashboard/path": true, ... } }
```
Updates menu permissions for a role. Platform admin context allows editing system role permissions.

#### Get Role Permissions
```
GET /api/roles/{roleId}/menu-permissions
```
Retrieves current menu permissions for a role.

### Component Architecture

#### MenuPermissionEditor Component
Located at: `coachqa-ui/src/components/role-management/MenuPermissionEditor.tsx`

**Props:**
- `roleId`: ID of the role being edited
- `roleName`: Name of the role
- `isSystemRole`: Boolean indicating if this is a system role
- `isPlatformAdmin`: Boolean indicating if current user is platform admin
- `tenantId`: Optional tenant ID (null for system roles)
- `onUpdate`: Optional callback when permissions are updated

**Behavior:**
- When `isPlatformAdmin=true` and `tenantId=null` (system role):
  - Fetches only system menus (no custom menus)
  - Uses regular permission endpoints (backend handles platform admin context)
- When `isPlatformAdmin=true` and `tenantId` is provided:
  - Fetches both system and custom menus for that tenant
  - Uses platform admin tenant-specific endpoints

#### RoleManagement Page
Located at: `coachqa-ui/src/pages/platform-admin/RoleManagement.tsx`

**Features:**
- Lists all roles with filtering capabilities
- Provides "Manage Permissions" action for each role
- Opens permissions dialog with MenuPermissionEditor component

### Backend Implementation

#### Permission Update Logic
Located at: `coachqa-backend/src/services/menu.service.ts`

The `updateMenuPermissionsForRole` function:
1. Validates that platform admin can edit system roles
2. Prevents tenant admins from editing system role permissions
3. Handles both system and custom menu permissions
4. Updates menu permissions in the database

**Key Checks:**
- Platform admin (`isPlatformAdmin=true`) can edit any role permissions
- Tenant admin cannot edit system role permissions (except admin role for custom menus)
- System menu permissions are preserved for tenant admins

## Security Considerations

### Access Control
- Only platform admins can edit system role permissions
- Tenant admins are restricted from modifying system role permissions
- Backend validates platform admin status on every permission update

### Data Integrity
- System roles cannot be deleted (enforced in UI and backend)
- Admin role always maintains full access (cannot be disabled)
- Permission changes are immediately persisted

## Troubleshooting

### Issue: Cannot Edit System Role Permissions
**Solution:** Ensure you are logged in as a platform admin, not a tenant admin.

### Issue: Permissions Not Saving
**Check:**
1. Verify you have platform admin privileges
2. Check browser console for API errors
3. Ensure backend is running and accessible

### Issue: System Menus Not Showing
**Solution:** System menus are fetched from `/api/platform-admin/system-menus`. Verify:
1. Platform admin authentication token is valid
2. Backend endpoint is accessible
3. System menus exist in the database

## Related Documentation

- [Role-Based Menu Access Control](./role-based-menu-access-control.md)
- [Menu Permissions User Guide](./menu-permissions-user-guide.md)
- [Role Management Documentation](../ROLE_MANAGEMENT_DOCUMENTATION.md)

## Changelog

### Version 1.0.0 (Current)
- Initial implementation of platform admin system role permissions editing
- Added permissions management dialog to Role Management page
- Updated MenuPermissionEditor to handle system roles
- Added API endpoint for fetching system menus

## Future Enhancements

Potential improvements for future versions:
- Bulk permission updates for multiple roles
- Permission templates/presets
- Permission change history/audit log
- Export/import role permissions
- Permission inheritance from parent roles







