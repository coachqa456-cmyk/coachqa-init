# Swagger Endpoints Not Showing - Fix Guide

## 🔍 Problem

The endpoints `/api/auth/login` and `/api/auth/login-with-tenant` are not appearing in Swagger UI.

## ✅ Solution Steps

### Step 1: Restart Backend Server

The Swagger documentation is generated at server startup. **You must restart the backend** for changes to appear.

**Stop the backend:**
- Press `Ctrl+C` in the terminal running the backend

**Start the backend:**
```bash
cd QEnabler-backend
npm run dev
```

Wait for the server to fully start (you'll see "Server running on port 9002").

### Step 2: Clear Browser Cache

1. Open Swagger UI: `http://127.0.0.1:9002/api-docs`
2. Press `Ctrl+Shift+R` (hard refresh) or `Ctrl+F5`
3. Or clear browser cache for that domain

### Step 3: Verify Endpoints

After restart, you should see in Swagger UI:

**Authentication Section:**
- ✅ POST /api/auth/register
- ✅ POST /api/auth/login
- ✅ POST /api/auth/login-with-tenant
- ✅ POST /api/auth/refresh
- ✅ POST /api/auth/logout
- ✅ POST /api/auth/google
- ✅ POST /api/auth/google/signup

## 🔧 Troubleshooting

### If endpoints still don't appear:

#### Check 1: Verify Routes File
```bash
# Check if routes are defined
cat QEnabler-backend/src/routes/auth.routes.ts | grep "router.post"
```

You should see:
- `router.post('/login', ...)`
- `router.post('/login-with-tenant', ...)`

#### Check 2: Verify Swagger Config
```bash
# Check Swagger is scanning routes
cat QEnabler-backend/src/config/swagger.ts | grep "apis:"
```

Should show:
```typescript
apis: ['./src/routes/*.ts', './src/controllers/*.ts']
```

#### Check 3: Check Server Logs
When backend starts, check for:
- No errors about Swagger
- Routes being registered: `[AUTH ROUTES] POST /login`

#### Check 4: Direct API Test
Test if routes work (even if Swagger doesn't show them):

```bash
# Test login endpoint
curl -X POST http://127.0.0.1:9002/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"Password123!"}'
```

If this works, the routes are fine - it's just a Swagger display issue.

### Alternative: Check Swagger JSON

Access the raw Swagger JSON:
```
http://127.0.0.1:9002/api-docs/swagger.json
```

Search for:
- `"/api/auth/login"`
- `"/api/auth/login-with-tenant"`

If they're in the JSON but not in UI, it's a browser/cache issue.

## 🎯 Quick Fix Commands

### Windows PowerShell:
```powershell
# Stop backend (Ctrl+C in terminal)
# Then restart:
cd QEnabler-backend
npm run dev
```

### Linux/Mac:
```bash
# Stop backend (Ctrl+C)
# Then restart:
cd QEnabler-backend
npm run dev
```

## 📋 Verification Checklist

After restarting:

- [ ] Backend server started without errors
- [ ] Swagger UI accessible at `http://127.0.0.1:9002/api-docs`
- [ ] Authentication section visible
- [ ] POST /api/auth/login visible
- [ ] POST /api/auth/login-with-tenant visible
- [ ] Can expand endpoints and see "Try it out" button

## 🚨 Common Issues

### Issue: "Cannot GET /api-docs"
**Solution:** Backend not running or wrong port

### Issue: Swagger shows but no Authentication section
**Solution:** Check if tags are defined in swagger.ts

### Issue: Endpoints show but can't expand
**Solution:** Browser JavaScript issue - try different browser

### Issue: Changes not appearing after restart
**Solution:** 
1. Hard refresh browser (Ctrl+Shift+R)
2. Check if TypeScript compiled correctly
3. Check server logs for errors

## 💡 Pro Tips

1. **Always restart backend** after changing Swagger docs
2. **Use hard refresh** (Ctrl+Shift+R) in browser
3. **Check Swagger JSON** directly if UI doesn't update
4. **Test endpoints directly** with curl/Postman to verify they work

## 🔄 Complete Restart Process

```bash
# 1. Stop backend (Ctrl+C)

# 2. Clear any build artifacts (optional)
cd QEnabler-backend
rm -rf dist  # or on Windows: rmdir /s dist

# 3. Restart
npm run dev

# 4. Wait for "Server running on port 9002"

# 5. Open browser
# http://127.0.0.1:9002/api-docs

# 6. Hard refresh (Ctrl+Shift+R)
```

## ✅ Expected Result

After following these steps, you should see:

```
Authentication
├── POST /api/auth/register
├── POST /api/auth/login          ← Should be here!
├── POST /api/auth/login-with-tenant  ← Should be here!
├── POST /api/auth/refresh
├── POST /api/auth/logout
├── POST /api/auth/google
└── POST /api/auth/google/signup
```

**If you still don't see them after restart, let me know and I'll investigate further!**






