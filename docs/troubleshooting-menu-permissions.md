# Troubleshooting Menu Permissions Implementation

## Common Issues and Solutions

### 1. Backend API Not Responding

**Error**: `BadRequest - An unsupported API call for method: POST at '/api/auth/login'`

**Possible Causes:**
- Backend server is not running
- Wrong API URL configuration
- Proxy/load balancer intercepting requests
- CORS issues

**Solutions:**

1. **Verify Backend Server is Running:**
   ```bash
   cd QEnabler-backend
   npm run dev
   ```
   Check console for: `Server is running on port 9000`

2. **Check API URL Configuration:**
   - Verify `VITE_API_URL` in `.env` file (frontend)
   - Default should be: `http://localhost:9000`
   - Ensure no trailing slash

3. **Check Database Connection:**
   - Ensure database is running
   - Verify database credentials in backend `.env`
   - Check for connection errors in backend console

4. **Verify Route Registration:**
   - Check that `app.use('/api/auth', authRoutes)` is in `app.ts`
   - Ensure routes are registered before 404 handler

5. **Check for Route Conflicts:**
   - Menu routes are mounted at `/api` - ensure no conflicts
   - Verify route order in `app.ts` (more specific routes first)

### 2. Menu Permissions Not Loading

**Symptoms:**
- Sidebar shows "No menus available"
- Menus don't appear after login
- Console shows API errors

**Solutions:**

1. **Check Database Migration:**
   ```sql
   -- Verify tables exist
   SELECT * FROM system_menus;
   SELECT * FROM menu_permissions;
   ```

2. **Verify Default Data:**
   ```sql
   -- Check if system menus are seeded
   SELECT COUNT(*) FROM system_menus;
   -- Should return 13 (number of default menus)
   ```

3. **Check Role Permissions:**
   ```sql
   -- Verify permissions exist for roles
   SELECT r.name, COUNT(mp.id) as permission_count
   FROM roles r
   LEFT JOIN menu_permissions mp ON r.id = mp.role_id
   WHERE r.is_system_role = TRUE
   GROUP BY r.name;
   ```

4. **Check Browser Console:**
   - Open browser DevTools → Console
   - Look for API errors
   - Check Network tab for failed requests

### 3. Icon Import Errors

**Error**: `Module 'lucide-react' has no exported member 'Timeline'`

**Solution:**
- Use `Clock` instead of `Timeline` for Impact Timeline menu
- Update icon mapping in Sidebar.tsx
- Update database migration to use 'Clock' as icon name

### 4. TypeScript Type Errors

**Error**: `Property 'role' does not exist on type 'User'`

**Solution:**
- Cast user to `any` when accessing role property:
  ```typescript
  const tenantUser = user as any;
  if (userType === 'tenant_user' && tenantUser.role === 'admin') {
    // ...
  }
  ```
- Or update TenantUser interface to ensure role is always present

### 5. Permission Update Failures

**Error**: `403 Forbidden` when updating permissions

**Causes:**
- Tenant admin trying to edit system menu permissions
- Tenant admin trying to edit system role permissions
- Invalid role ID

**Solutions:**
- Verify user has correct permissions (platform admin vs tenant admin)
- Check role ID is correct
- Ensure you're editing the correct tenant's permissions

### 6. Custom Menu Not Appearing

**Symptoms:**
- Custom menu created but not visible in sidebar
- Menu appears in CustomMenuManagement but not sidebar

**Solutions:**

1. **Check Menu Status:**
   ```sql
   SELECT * FROM custom_menus WHERE tenant_id = '<tenant-id>' AND is_active = TRUE;
   ```

2. **Verify Role Permissions:**
   ```sql
   SELECT * FROM menu_permissions 
   WHERE menu_path = '/dashboard/custom-menu-path' 
   AND role_id = '<role-id>';
   ```

3. **Check User Role:**
   - Verify user's role has permission for the menu
   - Admin users should see all menus automatically

### 7. Database Migration Issues

**Error**: Migration fails or tables not created

**Solutions:**

1. **Run Migration Manually:**
   ```bash
   # Connect to database
   psql -U postgres -d QEnabler_db
   
   # Run migration
   \i migrations/005-add-menu-permissions.sql
   ```

2. **Check for Existing Tables:**
   ```sql
   -- Check if tables already exist
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public' 
   AND table_name IN ('system_menus', 'custom_menus', 'menu_permissions');
   ```

3. **Verify Constraints:**
   - Check foreign key constraints
   - Ensure `roles` table exists before creating `menu_permissions`
   - Ensure `tenants` table exists before creating `custom_menus`

### 8. CORS Issues

**Error**: CORS policy blocking requests

**Solutions:**

1. **Check CORS Configuration:**
   ```typescript
   // In app.ts
   app.use(cors({
     origin: ['http://localhost:9001', process.env.CORS_ORIGIN],
     credentials: true,
   }));
   ```

2. **Verify Frontend URL:**
   - Ensure frontend is running on expected port (default: 9001)
   - Check `VITE_API_URL` matches backend URL

### 9. Authentication Token Issues

**Error**: `401 Unauthorized` on menu API calls

**Solutions:**

1. **Verify Token Storage:**
   - Check localStorage for `tenant.accessToken`
   - Verify token is being sent in Authorization header

2. **Check Token Expiration:**
   - Tokens may have expired
   - Try logging out and logging back in

3. **Verify User Type:**
   - Ensure correct storage keys are used (tenant vs platform admin)
   - Check `userType` in localStorage

## Debugging Steps

### Step 1: Verify Backend is Running
```bash
curl http://localhost:9000/health
# Should return: {"status":"ok","timestamp":"..."}
```

### Step 2: Test Auth Endpoint
```bash
curl -X POST http://localhost:9000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password"}'
```

### Step 3: Check Database
```sql
-- Verify system menus exist
SELECT * FROM system_menus LIMIT 5;

-- Verify permissions exist
SELECT r.name, sm.title, mp.is_allowed
FROM roles r
JOIN menu_permissions mp ON r.id = mp.role_id
JOIN system_menus sm ON mp.menu_path = sm.path
WHERE r.name = 'qe'
LIMIT 10;
```

### Step 4: Check Frontend API Calls
1. Open browser DevTools → Network tab
2. Filter by "Fetch/XHR"
3. Look for failed requests to `/api/menus` or `/api/roles/*/menu-permissions`
4. Check response status and error messages

### Step 5: Verify Route Registration
Check that routes are registered in correct order in `app.ts`:
```typescript
app.use('/api/auth', authRoutes);  // Should be before menu routes
app.use('/api', menuRoutes);       // More general route
```

## Quick Fixes

### Reset Menu Permissions
```sql
-- Delete all menu permissions and reseed
DELETE FROM menu_permissions;
-- Then re-run the permission seeding part of migration
```

### Clear Frontend Cache
```javascript
// In browser console
localStorage.clear();
sessionStorage.clear();
// Then refresh page
```

### Restart Backend Server
```bash
# Stop server (Ctrl+C)
# Then restart
cd QEnabler-backend
npm run dev
```

## Getting Help

If issues persist:
1. Check backend console for errors
2. Check browser console for errors
3. Verify database connection
4. Check network tab for API request/response details
5. Review error messages carefully - they often indicate the specific issue

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `BadRequest - An unsupported API call` | Backend not running or wrong URL | Start backend server, check API_URL |
| `401 Unauthorized` | Invalid or expired token | Re-login |
| `403 Forbidden` | Insufficient permissions | Check user role and authorization rules |
| `404 Not Found` | Route not registered | Check app.ts route registration |
| `409 Conflict` | Duplicate menu path | Use unique path for custom menus |
| `500 Internal Server Error` | Database or server error | Check backend console logs |











