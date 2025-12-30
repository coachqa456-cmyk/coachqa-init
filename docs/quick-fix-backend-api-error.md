# Quick Fix: Backend API Error

## Error: `BadRequest - An unsupported API call for method: POST at '/api/auth/login'`

This XML-formatted error typically indicates one of the following:

### 1. Backend Server Not Running

**Check:**
```bash
# In coachqa-backend directory
npm run dev
```

**Expected Output:**
```
Database connection established successfully.
Server is running on port 9000
Environment: development
```

### 2. Wrong API URL Configuration

**Check Frontend `.env` file:**
```env
VITE_API_URL=http://localhost:9000
```

**Verify in browser console:**
```javascript
console.log(import.meta.env.VITE_API_URL);
// Should output: http://localhost:9000
```

### 3. Database Connection Issue

**Check backend console for:**
- `Database connection established successfully.`
- If you see connection errors, check database credentials

**Verify database is running:**
```bash
# For PostgreSQL
psql -U postgres -d coachqa_db -c "SELECT 1;"
```

### 4. Route Registration Order

The routes are correctly ordered in `app.ts`:
- `/api/auth` is registered before `/api` (menu routes)
- This ensures auth routes are matched first

### 5. CORS Configuration

**Verify CORS in `app.ts`:**
```typescript
app.use(cors({
  origin: [
    process.env.CORS_ORIGIN || 'http://localhost:9001',
    'http://localhost:9001',
  ],
  credentials: true,
}));
```

### Quick Test Commands

**Test Backend Health:**
```bash
curl http://localhost:9000/health
```

**Test Auth Endpoint:**
```bash
curl -X POST http://localhost:9000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

**Expected Response (if working):**
```json
{
  "success": true,
  "data": {
    "user": {...},
    "accessToken": "...",
    "refreshToken": "..."
  }
}
```

### If Backend is Running but Still Getting Error

1. **Check for Proxy/Load Balancer:**
   - The XML error format suggests AWS or cloud service
   - Verify you're hitting the correct endpoint
   - Check if there's a reverse proxy in front

2. **Verify Port:**
   - Backend should be on port 9000
   - Frontend should be on port 9001
   - Check for port conflicts

3. **Clear Browser Cache:**
   - Hard refresh (Ctrl+Shift+R)
   - Clear localStorage
   - Try incognito mode

4. **Check Network Tab:**
   - Open browser DevTools → Network
   - Look at the actual request URL
   - Check if it's being redirected

### Common Solutions

**Solution 1: Restart Backend**
```bash
cd coachqa-backend
# Stop current process (Ctrl+C)
npm run dev
```

**Solution 2: Rebuild Backend**
```bash
cd coachqa-backend
npm run build
npm start
```

**Solution 3: Check Environment Variables**
```bash
# Backend .env should have:
DATABASE_URL=postgresql://...
PORT=9000
NODE_ENV=development
```

**Solution 4: Verify Database Migration**
```bash
# Ensure migration has been run
# Check if tables exist in database
```

If the error persists after these checks, the issue is likely:
- Backend server not running
- Wrong API URL in frontend
- Network/proxy configuration issue
- Database connection problem










