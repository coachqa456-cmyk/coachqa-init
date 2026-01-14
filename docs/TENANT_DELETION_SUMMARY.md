# Tenant Deletion - Quick Reference

## 🎯 How It Works

### Simple Flow
```
Admin clicks Delete → Confirmation → Checks for users → Deletes tenant + all data
```

### Validation Rule
```
❌ Cannot delete tenant if it has ANY users
✅ Can delete tenant if it has ZERO users
```

## 🔒 Safety Measures

1. **User Check**: Tenant must have 0 users before deletion
2. **Confirmation**: Requires explicit admin confirmation
3. **Permission**: Only Platform Admins with `tenants` permission
4. **Irreversible**: No undo, no recovery, no soft delete

## 📋 Deletion Checklist

```
☐ 1. Backup tenant data (if needed)
☐ 2. Navigate to Tenant Management
☐ 3. Delete all tenant users first
☐ 4. Verify tenant has 0 users
☐ 5. Click Delete button
☐ 6. Confirm deletion
☐ 7. Tenant + all related data deleted
```

## 🗑️ What Gets Deleted (Cascading)

When tenant is deleted, **ALL** related data is automatically deleted:

### Core Data
- ✅ Users & user accounts
- ✅ Squads/Teams
- ✅ User invitations
- ✅ Authentication tokens

### Activity Data
- ✅ Coaching sessions
- ✅ Quality scorecards
- ✅ Feedback submissions
- ✅ Maturity assessments
- ✅ Test sessions & debt items

### Configuration
- ✅ Roles & permissions
- ✅ Settings
- ✅ Menus
- ✅ Theme configuration
- ✅ Maturity levels

**Total:** ~20+ related tables automatically cleaned up via CASCADE DELETE

## 🔧 API Endpoints

### Delete Tenant
```http
DELETE /api/platform-admin/tenants/:id
Authorization: Bearer <admin_token>
```

**Success (200):**
```json
{
  "success": true,
  "message": "Tenant deleted successfully"
}
```

**Error - Has Users (400):**
```json
{
  "success": false,
  "error": {
    "message": "Cannot delete a tenant that still has users"
  }
}
```

### Delete User First
```http
DELETE /api/platform-admin/tenants/:tenantId/users/:userId
```

## 💻 Code Implementation

### Backend (platformAdmin.controller.ts)
```typescript
export const deleteTenantById = async (req, res, next) => {
  const { id } = req.params;
  
  const tenant = await Tenant.findByPk(id, {
    include: [{ model: User, as: 'users' }],
  });

  if (!tenant) {
    throw new AppError('Tenant not found', 404);
  }

  // ✅ SAFETY CHECK
  if (tenant.users && tenant.users.length > 0) {
    throw new AppError('Cannot delete a tenant that still has users', 400);
  }

  // Delete tenant (cascades to all related data)
  await tenant.destroy();

  res.json({
    success: true,
    message: 'Tenant deleted successfully',
  });
};
```

### Frontend (TenantManagement.tsx)
```typescript
const handleDeleteTenant = async (tenant: Tenant) => {
  // Confirmation dialog
  if (!window.confirm(`Delete tenant "${tenant.name}"?`)) {
    return;
  }
  
  try {
    const response = await deletePlatformTenant(tenant.id);
    
    if (!response.ok) {
      // Handle error (e.g., "still has users")
      setError('Cannot delete tenant that still has users');
    } else {
      // Success
      setSuccess(`Tenant "${tenant.name}" deleted!`);
      refreshTenants();
    }
  } catch (err) {
    setError('Failed to delete tenant');
  }
};
```

## 🚨 Common Errors

### "Cannot delete a tenant that still has users"

**Cause:** Tenant has 1+ users

**Fix:**
1. Go to Tenant Details → Users
2. Delete all users
3. Try deletion again

### "Tenant not found"

**Cause:** Invalid tenant ID or already deleted

**Fix:** Refresh tenant list

## 🗂️ Database Schema

### CASCADE DELETE Example
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  ...
);
```

**Meaning:** When tenant is deleted → all its users are automatically deleted

### All Tables with CASCADE
```
users → tenants (CASCADE)
squads → tenants (CASCADE)
coaching_sessions → tenants (CASCADE)
quality_scorecards → tenants (CASCADE)
feedback_submissions → tenants (CASCADE)
maturity_assessments → tenants (CASCADE)
enablement_resources → tenants (CASCADE)
test_debt_items → tenants (CASCADE)
change_tracking → tenants (CASCADE)
career_assessments → tenants (CASCADE)
roles → tenants (CASCADE)
settings → tenants (CASCADE)
menus → tenants (CASCADE)
... (20+ tables total)
```

## ⚠️ Important Notes

1. **Permanent**: No undo, no recovery
2. **Cascading**: Deletes ALL related data automatically
3. **User Check**: Must delete users first
4. **Confirmation**: Always requires explicit confirmation
5. **Permissions**: Platform Admin only
6. **Backup**: Consider exporting data first

## 🎬 Quick Demo

### Via UI
```
1. Login as Platform Admin
2. Navigate to: /admin/tenants
3. Find tenant in list
4. Click Delete icon (red trash)
5. Confirm dialog
6. Tenant deleted ✅
```

### Via API
```bash
# 1. Get tenant users
curl -X GET http://api/platform-admin/tenants/{id}/users \
  -H "Authorization: Bearer {token}"

# 2. Delete users (if any exist)
curl -X DELETE http://api/platform-admin/tenants/{id}/users/{userId} \
  -H "Authorization: Bearer {token}"

# 3. Delete tenant
curl -X DELETE http://api/platform-admin/tenants/{id} \
  -H "Authorization: Bearer {token}"
```

## 📖 Full Documentation

See `TENANT_DELETION_GUIDE.md` for complete details:
- Detailed flow diagrams
- All cascade relationships
- Security considerations
- Database queries
- Troubleshooting guide
- Best practices

---

**Key Takeaway:** Tenant deletion is **safe** (requires 0 users), **thorough** (cascades to all data), and **permanent** (no undo).






