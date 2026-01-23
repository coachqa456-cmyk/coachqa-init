# Platform Admin Login Troubleshooting

## Error: `BadRequest - An unsupported API call for method: POST at '/api/platform-admin/login'`

### Route Configuration

The platform admin login route is correctly configured:
- **Route File**: `QEnabler-backend/src/routes/platformAdmin.routes.ts`
- **Route Definition**: `router.post('/login', platformAdminController.login);`
- **Mounted At**: `/api/platform-admin` (in `app.ts`)
- **Full Path**: `/api/platform-admin/login`

### Quick Checks

1. **Verify Backend Server is Running:**
   ```bash
   cd QEnabler-backend
   npm run dev
   ```
   
   Look for:
   ```
   Database connection established successfully.
   Server is running on port 9000
   ```

2. **Test the Endpoint Directly:**
   ```bash
   curl -X POST http://localhost:9000/api/platform-admin/login \
     -H "Content-Type: application/json" \
     -d '{"email":"admin@example.com","password":"password"}'
   ```

3. **Check Route Registration Order:**
   In `app.ts`, the routes are registered in this order:
   ```typescript
   app.use('/api/auth', authRoutes);
   app.use('/api/platform-admin', platformAdminRoutes);  // ← Should match first
   // ... other routes ...
   app.use('/api', menuRoutes);  // ← More general, registered after
   ```
   
   This order ensures `/api/platform-admin/login` matches the platform admin routes before the menu routes.

4. **Verify Controller Exists:**
   - Controller: `QEnabler-backend/src/controllers/platformAdmin.controller.ts`
   - Method: `export const login = async (...) => { ... }`

### Common Issues

#### Issue 1: Backend Server Not Running
**Symptom**: XML error response (unusual for Express)
**Solution**: Start the backend server
```bash
cd QEnabler-backend
npm run dev
```

#### Issue 2: TypeScript Compilation Error
**Symptom**: Server crashes on startup
**Solution**: Fix any TypeScript errors (like unused parameters)
```bash
# Check for errors
cd QEnabler-backend
npm run build
```

#### Issue 3: Port Conflict
**Symptom**: Server can't start on port 9000
**Solution**: 
- Check if port 9000 is already in use
- Change PORT in `.env` if needed
- Kill process using port 9000

#### Issue 4: Database Connection Failed
**Symptom**: Server starts but database connection fails
**Solution**: 
- Verify database is running
- Check database credentials in `.env`
- Ensure database exists

#### Issue 5: Route Conflict (Unlikely)
**Symptom**: Route not matching correctly
**Solution**: The menu routes have `/platform-admin/system-menus` but this shouldn't conflict since platform admin routes are registered first. If issues persist, verify route order in `app.ts`.

### Expected Response

**Success Response:**
```json
{
  "success": true,
  "data": {
    "admin": {
      "id": "...",
      "email": "admin@example.com",
      "name": "...",
      "permissions": [...]
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "..."
  }
}
```

**Error Response (Invalid Credentials):**
```json
{
  "success": false,
  "error": {
    "message": "Invalid email or password",
    "statusCode": 401
  }
}
```

### Debugging Steps

1. **Check Backend Console:**
   - Look for startup messages
   - Check for any error logs
   - Verify route registration messages

2. **Check Browser Network Tab:**
   - Open DevTools → Network
   - Look at the actual request URL
   - Check request method (should be POST)
   - Check request headers
   - Check response status and body

3. **Verify API URL in Frontend:**
   - Check `.env` file: `VITE_API_URL=http://localhost:9000`
   - Ensure no trailing slash
   - Verify frontend is using correct URL

4. **Test with curl:**
   ```bash
   # Test health endpoint first
   curl http://localhost:9000/health
   
   # Then test login
   curl -X POST http://localhost:9000/api/platform-admin/login \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"test"}'
   ```

### Route Order Verification

The routes in `app.ts` should be in this order (most specific first):
1. `/api/auth` - Auth routes
2. `/api/platform-admin` - Platform admin routes (includes `/login`)
3. `/api/tenants` - Tenant routes
4. `/api/users` - User routes
5. ... other specific routes ...
6. `/api` - Menu routes (most general, registered last)

This ensures that `/api/platform-admin/login` matches the platform admin routes before the more general `/api` routes.

### If Issue Persists

1. **Restart Backend Server:**
   ```bash
   # Stop server (Ctrl+C)
   cd QEnabler-backend
   npm run dev
   ```

2. **Clear Browser Cache:**
   - Hard refresh (Ctrl+Shift+R)
   - Clear localStorage
   - Try incognito mode

3. **Check for Proxy/Load Balancer:**
   - The XML error format suggests AWS or cloud service
   - Verify you're hitting `http://localhost:9000` directly
   - Check if there's a reverse proxy configured

4. **Verify Environment Variables:**
   ```bash
   # Backend .env should have:
   DATABASE_URL=postgresql://...
   PORT=9000
   NODE_ENV=development
   JWT_SECRET=...
   ```











