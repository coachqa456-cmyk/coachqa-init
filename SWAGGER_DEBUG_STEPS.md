# Swagger Endpoints Not Showing - Debug Steps

## 🔍 Diagnostic Steps

### Step 1: Check if Server is Running
```bash
# Test if backend is accessible
curl http://127.0.0.1:9002/api/health
```

Should return: `{"status":"ok",...}`

### Step 2: Check Swagger JSON Directly
Open in browser: `http://127.0.0.1:9002/api-docs/swagger.json`

**Search for:**
- `"/api/auth/login"` - Should find it
- `"/api/auth/login-with-tenant"` - Should find it
- `"/api/auth/register"` - Should find it (for comparison)

**If login endpoints are NOT in the JSON:**
→ Swagger parsing issue - endpoints not being scanned

**If login endpoints ARE in the JSON but NOT in UI:**
→ Browser cache or Swagger UI issue

### Step 3: Check Server Logs
When backend starts, look for:
- Any Swagger-related errors
- Routes being registered: `[AUTH ROUTES] POST /login`

### Step 4: Verify File Paths
Check if Swagger is scanning the right files:
```bash
# In coachqa-backend directory
ls src/routes/auth.routes.ts  # Should exist
```

### Step 5: Test Endpoints Directly (Bypass Swagger)
Even if Swagger doesn't show them, test if endpoints work:

```bash
# Test login endpoint
curl -X POST http://127.0.0.1:9002/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"admin@test.com\",\"password\":\"Password123!\"}"
```

If this works → Routes are fine, it's just a Swagger display issue.

## 🔧 Potential Fixes

### Fix 1: Clear All Caches
1. Stop backend server
2. Delete `node_modules/.cache` if it exists
3. Restart backend
4. Hard refresh browser (Ctrl+Shift+R)

### Fix 2: Check Swagger Config Paths
In `coachqa-backend/src/config/swagger.ts`:
```typescript
apis: ['./src/routes/*.ts', './src/controllers/*.ts']
```

Make sure these paths are correct relative to where the server runs from.

### Fix 3: Try Absolute Paths
Change Swagger config to use absolute paths:
```typescript
import path from 'path';
apis: [path.join(__dirname, '../routes/*.ts')]
```

### Fix 4: Check if Register Endpoint Shows
- If `/api/auth/register` shows but `/api/auth/login` doesn't
- Then there's something specific about the login endpoint comments
- Compare the two side-by-side

### Fix 5: Minimal Test Endpoint
Add a minimal test endpoint to verify Swagger is working:

```typescript
/**
 * @swagger
 * /api/auth/test:
 *   get:
 *     summary: Test endpoint
 *     tags: [Authentication]
 *     responses:
 *       200:
 *         description: Test
 */
router.get('/test', (req, res) => res.json({ test: true }));
```

If this shows up, then Swagger is working and the issue is with the login endpoints specifically.

## 🎯 Quick Test

Run this in browser console on Swagger UI page:
```javascript
// Check if endpoints are in the spec
fetch('/api-docs/swagger.json')
  .then(r => r.json())
  .then(data => {
    console.log('Login endpoint:', data.paths['/api/auth/login']);
    console.log('Login-with-tenant:', data.paths['/api/auth/login-with-tenant']);
    console.log('Register endpoint:', data.paths['/api/auth/register']);
  });
```

This will tell you if the endpoints are in the JSON spec.

## 📋 What to Report

If endpoints still don't show, please provide:

1. **Swagger JSON check**: Are `/api/auth/login` and `/api/auth/login-with-tenant` in the JSON?
2. **Register endpoint**: Does `/api/auth/register` show in Swagger UI?
3. **Server logs**: Any errors when backend starts?
4. **Direct API test**: Do the endpoints work when called directly (curl/Postman)?

This will help identify if it's:
- Swagger parsing issue (not in JSON)
- Swagger UI issue (in JSON but not in UI)
- Browser cache issue
- Something else




