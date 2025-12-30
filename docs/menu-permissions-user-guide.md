# Menu Permissions User Guide

## For Platform Administrators

### Managing System Menus

System menus are the default application menus that appear for all tenants. Only platform administrators can create, edit, or delete system menus.

#### Creating a System Menu

1. Log in as a platform administrator
2. Navigate to **Platform Admin** → **System Menu Management** (to be added to navigation)
3. Click **Create System Menu**
4. Fill in the form:
   - **Path**: The route path (e.g., `/dashboard/new-feature`)
     - Must be unique across all system menus
     - Should follow the pattern `/dashboard/feature-name`
   - **Title**: Display name shown in the sidebar
   - **Icon**: Icon name from lucide-react (e.g., `BarChart`, `Clipboard`, `BookOpen`)
   - **Group**: Menu group category
     - `Overview`: For dashboard and overview pages
     - `Modules`: For feature modules
     - `Administration`: For admin features
   - **Order Index**: Number to control display order (lower numbers appear first)
   - **Status**: Active or Inactive
5. Click **Save**

#### Editing a System Menu

1. Navigate to **System Menu Management**
2. Find the menu you want to edit
3. Click the **Edit** icon
4. Modify the fields as needed
5. Click **Save**

#### Deleting a System Menu

1. Navigate to **System Menu Management**
2. Find the menu you want to delete
3. Click the **Delete** icon
4. Confirm the deletion
5. **Note**: Deleting a system menu will also remove all related menu permissions

### Managing Role Permissions

Platform administrators can manage menu permissions for all roles across all tenants.

#### Via Tenant Details

1. Navigate to **Platform Admin** → **Tenant Management**
2. Click on a tenant to view details
3. Click the **Role Permissions** tab
4. Select a role from the list
5. Toggle menu permissions on/off:
   - **System Menus**: All system menus listed with toggle switches
   - **Custom Menus**: All custom menus for this tenant listed with toggle switches
6. Changes are saved automatically

#### Via Role Permissions Page

1. Navigate to **Platform Admin** → **Role Permissions**
2. Use the search box to find a tenant
3. Click **Manage Permissions** on a tenant
4. This will take you to the tenant's Role Permissions tab

### Best Practices for Platform Admins

1. **System Menu Naming**: Use clear, descriptive titles
2. **Menu Paths**: Follow consistent naming conventions
3. **Icon Selection**: Use appropriate icons from lucide-react
4. **Group Organization**: Keep related menus in the same group
5. **Order Index**: Use increments of 10 (0, 10, 20, etc.) to allow easy reordering
6. **Testing**: Test menu permissions after changes to ensure proper access control

## For Tenant Administrators

### Creating Custom Menus

Custom menus are tenant-specific and only visible to users within your tenant.

#### Steps to Create a Custom Menu

1. Log in as a tenant administrator
2. Navigate to **Dashboard** → **Custom Menus** (add this to sidebar if needed)
3. Click **Create Custom Menu**
4. Fill in the form:
   - **Path**: The route path (e.g., `/dashboard/tenant-specific-feature`)
     - Must be unique within your tenant
     - Should follow the pattern `/dashboard/feature-name`
   - **Title**: Display name shown in the sidebar
   - **Icon**: Icon name from lucide-react
   - **Group**: Menu group category
   - **Order Index**: Display order within the group
   - **Status**: Active or Inactive
5. Click **Save**

#### Managing Custom Menus

- **Edit**: Click the edit icon to modify menu properties
- **Delete**: Click the delete icon to remove a custom menu
- **Note**: Deleting a custom menu will also remove all related menu permissions

### Managing Role Permissions

Tenant administrators can manage menu permissions for custom menus and view (but not edit) system menu permissions.

#### Steps to Manage Permissions

1. Navigate to **Dashboard** → **Role Management**
2. Select a role from the tabs at the top
3. View the menu permissions:
   - **System Menus**: 
     - Shown with current permissions
     - Toggle switches are disabled (read-only)
     - Note indicates platform admin manages these
   - **Custom Menus**:
     - Fully editable
     - Toggle switches are enabled
     - Changes save automatically

#### Understanding Permission States

- **Enabled (Green)**: Role has access to this menu
- **Disabled (Gray)**: Role does not have access to this menu
- **Locked**: Cannot be changed (system menus for tenant admin, admin role)

### Limitations for Tenant Admins

1. **System Menus**: Cannot create, edit, or delete system menus
2. **System Menu Permissions**: Cannot edit permissions for system menus
3. **System Roles**: Cannot edit permissions for system roles (qe, manager, developer, executive)
4. **Admin Role**: Cannot edit admin role permissions (always has full access)

### Best Practices for Tenant Admins

1. **Custom Menu Planning**: Plan your custom menus before creating them
2. **Path Naming**: Use descriptive paths that won't conflict with system menus
3. **Permission Management**: Regularly review role permissions to ensure proper access
4. **Testing**: Test menu visibility for different roles after making changes
5. **Documentation**: Document custom menus for your team

## Understanding Menu Access

### How Menu Access Works

1. **Menu Fetching**: When a user logs in, the sidebar fetches:
   - All active system menus
   - All active custom menus for the tenant
   - Menu permissions for the user's role

2. **Filtering**: Menus are filtered based on:
   - User's role permissions
   - Menu active status
   - Admin users see all menus automatically

3. **Display**: Filtered menus are grouped and displayed in the sidebar

### Role Hierarchy

1. **Admin Role**:
   - Always has full access to all menus
   - Cannot be edited by anyone
   - Hardcoded in the system

2. **System Roles** (qe, manager, developer, executive):
   - Permissions managed by platform admin only
   - Tenant admin can view but not edit
   - Default permissions set based on role requirements

3. **Custom Roles**:
   - Can be created by tenant admin (future feature)
   - Permissions fully manageable by tenant admin
   - Platform admin can also manage

## Troubleshooting

### Menus Not Appearing

**Problem**: Menu doesn't appear in sidebar

**Solutions**:
1. Check if menu is active (`is_active = true`)
2. Verify user's role has permission for the menu
3. Check if menu path is correct
4. Refresh the page
5. Check browser console for errors

### Cannot Edit Permissions

**Problem**: Cannot change menu permissions

**Solutions**:
1. **System Menus**: Only platform admin can edit - contact platform admin
2. **System Roles**: Only platform admin can edit - contact platform admin
3. **Admin Role**: Cannot be edited - this is by design
4. Verify you have the correct permissions (tenant admin or platform admin)

### Custom Menu Not Saving

**Problem**: Custom menu creation/update fails

**Solutions**:
1. Check if menu path is unique within your tenant
2. Verify all required fields are filled
3. Check for path conflicts with system menus
4. Review error message in the dialog

### Permission Changes Not Reflecting

**Problem**: Permission changes don't appear immediately

**Solutions**:
1. Refresh the page
2. Clear browser cache
3. Check if changes were saved (look for success message)
4. Verify you're viewing the correct role
5. Check browser console for API errors

## Frequently Asked Questions

### Q: Can I create a menu with the same path as a system menu?
**A**: No, custom menu paths must be unique. However, you can use a different path for a similar feature.

### Q: Why can't I edit system menu permissions?
**A**: System menu permissions can only be edited by platform administrators to maintain consistency across all tenants.

### Q: What happens if I delete a menu?
**A**: Deleting a menu will:
- Remove the menu from the sidebar
- Remove all related menu permissions
- This action cannot be undone

### Q: Can I reorder menus?
**A**: Yes, use the `orderIndex` field when creating/editing menus. Lower numbers appear first within each group.

### Q: How do I know which menus a role can access?
**A**: Navigate to Role Management, select the role, and view the menu permissions. Enabled toggles indicate access.

### Q: Can I temporarily disable a menu without deleting it?
**A**: Yes, set the menu status to "Inactive". The menu will be hidden but can be reactivated later.

## Support

For additional support:
1. Review this documentation
2. Check the API reference documentation
3. Contact your platform administrator
4. Review error messages in the browser console










