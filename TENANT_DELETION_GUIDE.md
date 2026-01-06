# Tenant Deletion Implementation Guide

## Overview

The CoachQA platform implements **safe tenant deletion** with validation checks and **automatic cascading deletion** of all related data. This document explains the complete deletion flow, safety measures, and data cleanup process.

## 🔒 Safety Measures

### 1. User Validation Check

**Before deletion, the system checks if the tenant has any users:**

```typescript
// Backend validation (platformAdmin.controller.ts)
const tenant = await Tenant.findByPk(id, {
  include: [{ model: User, as: 'users' }],
});

if (!tenant) {
  throw new AppError('Tenant not found', 404);
}

// ✅ SAFETY CHECK: Prevent deletion if tenant has users
if (Array.isArray((tenant as any).users) && (tenant as any).users.length > 0) {
  throw new AppError('Cannot delete a tenant that still has users', 400);
}

await tenant.destroy();
```

**Result:** Tenant can only be deleted if it has **ZERO users**.

### 2. Confirmation Dialog

The frontend requires explicit user confirmation:

```typescript
// Frontend confirmation (TenantManagement.tsx)
if (!window.confirm(`Are you sure you want to delete tenant "${tenant.name}"? This action cannot be undone.`)) {
  return;
}
```

## 📊 Deletion Flow

### Step-by-Step Process

```
1. Platform Admin clicks Delete button
         ↓
2. Confirmation dialog appears
   "Are you sure you want to delete tenant 'X'? This action cannot be undone."
         ↓
3. If user confirms:
   - Frontend sends: DELETE /api/platform-admin/tenants/:id
         ↓
4. Backend validates:
   ✅ Does tenant exist?
   ✅ Does tenant have any users?
         ↓
5. If validation fails:
   ❌ Return error: "Cannot delete a tenant that still has users"
   (Stop here - no deletion)
         ↓
6. If validation passes:
   ✅ Delete tenant from database
   ✅ Cascade delete all related data
   ✅ Return success message
         ↓
7. Frontend:
   - Shows success notification
   - Refreshes tenant list
   - Tenant removed from UI
```

## 🗑️ Cascading Deletion

When a tenant is deleted, **ALL related data is automatically deleted** via database cascade constraints:

### Tables with CASCADE DELETE

#### Core Tables (001-create-core-tables.sql)
```sql
✅ users (tenant_id → CASCADE)
✅ squads (tenant_id → CASCADE)
✅ squad_members (via squads → CASCADE)
✅ user_invitations (tenant_id → CASCADE)
✅ refresh_tokens (via users → CASCADE)
```

#### Module Tables (002-create-module-tables.sql)
```sql
✅ coaching_sessions (tenant_id → CASCADE)
✅ coaching_session_attendees (via sessions → CASCADE)
✅ quality_scorecards (tenant_id → CASCADE)
✅ feedback_submissions (tenant_id → CASCADE)
✅ maturity_assessments (tenant_id → CASCADE)
✅ enablement_resources (tenant_id → CASCADE)
✅ resource_squad_access (via resources → CASCADE)
✅ exploratory_test_sessions (tenant_id → CASCADE)
✅ test_debt_items (tenant_id → CASCADE)
✅ change_tracking (tenant_id → CASCADE)
✅ career_assessments (tenant_id → CASCADE)
```

#### Permission Tables (004-create-roles-and-permissions-schema.sql)
```sql
✅ roles (tenant_id → CASCADE)
```

#### Other Tables
```sql
✅ settings (tenant_id → CASCADE)
✅ menus (tenant_id → CASCADE)
✅ maturity_levels (tenant_id → CASCADE)
```

### Database Constraint Example

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  ...
);
```

**`ON DELETE CASCADE`** means: When a tenant is deleted, all users with that `tenant_id` are automatically deleted.

## 🛡️ Why Users Must Be Deleted First?

The backend explicitly checks for users before deletion:

```typescript
if ((tenant as any).users.length > 0) {
  throw new AppError('Cannot delete a tenant that still has users', 400);
}
```

### Reasoning:

1. **Data Integrity**: Ensures admins explicitly handle user accounts
2. **Prevent Accidents**: Forces review of what will be deleted
3. **Audit Trail**: Admin must manually delete/migrate users first
4. **Legal Compliance**: User data deletion may require separate workflows

## 📋 Complete Deletion Workflow

### For Platform Administrators

#### Pre-Deletion Checklist

1. **Review Tenant Data**
   - Check number of users
   - Review critical data
   - Backup if needed

2. **Delete All Users First**
   ```
   Navigate to: Tenant Details → Users Tab
   - Delete each user individually, or
   - Bulk delete via API if implemented
   ```

3. **Verify Empty Tenant**
   ```
   Confirm tenant has 0 users
   ```

4. **Delete Tenant**
   ```
   - Click Delete button
   - Confirm deletion
   - All data automatically deleted
   ```

### Manual Deletion Steps

```typescript
// 1. Get tenant users
GET /api/platform-admin/tenants/:id/users

// 2. Delete each user
DELETE /api/platform-admin/tenants/:tenantId/users/:userId

// 3. Delete tenant (only works if no users)
DELETE /api/platform-admin/tenants/:id
```

## 🔧 API Reference

### Delete Tenant

**Endpoint:**
```
DELETE /api/platform-admin/tenants/:id
```

**Headers:**
```
Authorization: Bearer <platform_admin_token>
```

**Response - Success (200):**
```json
{
  "success": true,
  "message": "Tenant deleted successfully"
}
```

**Response - Has Users (400):**
```json
{
  "success": false,
  "error": {
    "message": "Cannot delete a tenant that still has users",
    "statusCode": 400
  }
}
```

**Response - Not Found (404):**
```json
{
  "success": false,
  "error": {
    "message": "Tenant not found",
    "statusCode": 404
  }
}
```

### Delete Tenant User

**Endpoint:**
```
DELETE /api/platform-admin/tenants/:tenantId/users/:userId
```

**Response - Success (200):**
```json
{
  "success": true,
  "message": "User deleted successfully"
}
```

## 🎯 Frontend Implementation

### Tenant Management UI

**File:** `coachqa-ui/src/pages/platform-admin/TenantManagement.tsx`

**Delete Button:**
```tsx
<IconButton
  size="small"
  onClick={(e) => {
    e.stopPropagation();
    handleDeleteTenant(tenant);
  }}
  color="error"
  title="Delete Tenant"
>
  <DeleteIcon />
</IconButton>
```

**Delete Handler:**
```typescript
const handleDeleteTenant = async (tenant: Tenant) => {
  // 1. Confirmation
  if (!window.confirm(`Are you sure you want to delete tenant "${tenant.name}"?`)) {
    return;
  }
  
  // 2. API Call
  const response = await deletePlatformTenant(tenant.id);
  
  // 3. Handle Response
  if (!response.ok) {
    const result = await response.json();
    const errorMsg = result?.error?.message || 'Failed to delete tenant';
    setDeleteError(errorMsg);
    return;
  }
  
  // 4. Success
  setSuccessMessage(`Tenant "${tenant.name}" deleted successfully!`);
  
  // 5. Refresh List
  const listResponse = await fetchPlatformTenants();
  if (listResponse.ok) {
    const listResult = await listResponse.json();
    setTenants(listResult.data || []);
  }
};
```

### Error Handling

```typescript
try {
  await deletePlatformTenant(tenant.id);
} catch (err) {
  // Show error to user
  setDeleteError('Cannot delete tenant that still has users');
  
  // Auto-hide after 5 seconds
  setTimeout(() => setDeleteError(null), 5000);
}
```

## ⚠️ What Gets Deleted

When you delete a tenant, **ALL of the following is permanently deleted**:

### User Data
- ✅ User accounts
- ✅ User profiles
- ✅ User invitations
- ✅ Refresh tokens
- ✅ User-tenant associations

### Organization Data
- ✅ Squads/Teams
- ✅ Squad members
- ✅ Squad access permissions

### Activity Data
- ✅ Coaching sessions & attendees
- ✅ Quality scorecards
- ✅ Feedback submissions
- ✅ Maturity assessments
- ✅ Career assessments

### Resources
- ✅ Enablement resources
- ✅ Resource access controls
- ✅ Test sessions
- ✅ Test debt items
- ✅ Change tracking records

### Configuration
- ✅ Roles & permissions
- ✅ Settings
- ✅ Custom menus
- ✅ Maturity levels
- ✅ Theme configuration

### Metadata
- ✅ Tenant name, slug
- ✅ Logo URL
- ✅ Company info
- ✅ Created/updated dates

## 🚫 What Cannot Be Recovered

**⚠️ CRITICAL: Tenant deletion is PERMANENT and IRREVERSIBLE**

- ❌ No soft delete
- ❌ No recycle bin
- ❌ No undo functionality
- ❌ No automatic backups

**Recommendation:** Always backup tenant data before deletion!

## 💡 Best Practices

### Before Deleting

1. **Export Data**
   - Generate reports
   - Export user lists
   - Backup critical information

2. **Notify Stakeholders**
   - Inform affected users
   - Get approval from management
   - Document the reason

3. **Check Dependencies**
   - Verify all users are migrated
   - Ensure no active sessions
   - Review external integrations

### Safe Deletion Process

```
Step 1: Backup/Export tenant data
        ↓
Step 2: Notify all tenant users
        ↓
Step 3: Delete all users from tenant
        ↓
Step 4: Verify tenant has 0 users
        ↓
Step 5: Delete tenant
        ↓
Step 6: Verify deletion successful
        ↓
Step 7: Archive exported data
```

## 🔍 Troubleshooting

### Error: "Cannot delete a tenant that still has users"

**Cause:** Tenant has one or more users

**Solution:**
1. Navigate to Tenant Details
2. Go to Users tab
3. Delete all users
4. Try deleting tenant again

### Error: "Tenant not found"

**Cause:** Tenant ID doesn't exist or already deleted

**Solution:** Refresh the tenant list

### Error: "Failed to delete tenant"

**Cause:** Database constraint violation or server error

**Solution:**
1. Check server logs
2. Verify database constraints
3. Check for orphaned foreign keys

## 📊 Database Verification

### Check Tenant Users

```sql
-- Count users for a tenant
SELECT COUNT(*) FROM users WHERE tenant_id = 'your-tenant-id';

-- List all users for a tenant
SELECT id, name, email, role 
FROM users 
WHERE tenant_id = 'your-tenant-id';
```

### Manual Cleanup (If Needed)

```sql
-- ⚠️ USE WITH EXTREME CAUTION - Deletes ALL tenant data

-- 1. Delete all users first
DELETE FROM users WHERE tenant_id = 'your-tenant-id';

-- 2. Delete tenant (cascade will handle rest)
DELETE FROM tenants WHERE id = 'your-tenant-id';
```

## 🔐 Security & Permissions

### Required Permissions

- **Role:** Platform Administrator
- **Permission:** `tenants` (manage tenants)
- **Authentication:** Valid platform admin JWT token

### Authorization Check

```typescript
// Backend middleware
router.delete(
  '/tenants/:id',
  requirePermission('tenants'), // ✅ Checks permission
  platformAdminController.deleteTenantById
);
```

### Who Can Delete Tenants?

- ✅ Platform Administrators with `tenants` permission
- ❌ Tenant Administrators (cannot delete their own tenant)
- ❌ Regular users
- ❌ Unauthenticated users

## 📝 Audit Logging (Recommended)

**Not currently implemented, but recommended:**

```typescript
// Log deletion before it happens
await auditLog.create({
  action: 'TENANT_DELETED',
  performedBy: adminId,
  tenantId: tenant.id,
  tenantName: tenant.name,
  userCount: tenant.users.length,
  timestamp: new Date(),
});
```

## 🔄 Future Enhancements

Potential improvements:

- [ ] Soft delete with retention period
- [ ] Automatic data export before deletion
- [ ] Bulk user deletion
- [ ] Tenant archiving
- [ ] Restoration functionality
- [ ] Audit trail for deletions
- [ ] Scheduled cleanup for archived tenants

## Summary

### Deletion Process
1. ✅ Requires confirmation
2. ✅ Validates no users exist
3. ✅ Cascades to all related data
4. ✅ Permanent and irreversible
5. ✅ Platform admin only

### Safety Features
- ✅ User count validation
- ✅ Explicit confirmation required
- ✅ Error messages for failures
- ✅ Permission-based access

### Data Cleanup
- ✅ Automatic cascade deletion
- ✅ All related data removed
- ✅ No orphaned records
- ✅ Clean database state

---

**Version:** 1.0  
**Last Updated:** January 4, 2026  
**Author:** CoachQA Development Team




