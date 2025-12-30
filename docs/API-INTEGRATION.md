# CoachQA API Integration Guide

## ✅ Integration Status

The CoachQA frontend (UI) is successfully integrated with the backend API. Both services are running and configured to work together.

### Current Setup

- **Backend API**: Running on `http://localhost:9000`
- **Frontend UI**: Running on `http://localhost:9001`
- **Database**: PostgreSQL connected and models synchronized
- **Proxy**: Vite development server configured with API proxy

---

## Architecture Overview

```
┌─────────────────┐         ┌──────────────────┐         ┌──────────────┐
│   React UI      │ ──────> │  Vite Dev Server │ ──────> │  Backend API │
│  (Port 9001)    │  Proxy  │   (Port 9001)    │  HTTP   │  (Port 9000) │
└─────────────────┘         └──────────────────┘         └──────────────┘
                                                                   │
                                                                   ▼
                                                          ┌──────────────┐
                                                          │  PostgreSQL  │
                                                          │   Database   │
                                                          └──────────────┘
```

---

## API Configuration

### Environment Variables

`.env` and `.env.development` files are configured with:

```env
VITE_API_URL=http://localhost:9000
```

### Vite Proxy Configuration

The Vite development server (`vite.config.ts`) is configured to proxy API requests:

```typescript
server: {
  port: 9001,
  strictPort: true,
  proxy: {
    "/api": {
      target: "http://localhost:9000",
      changeOrigin: true,
      secure: false,
    },
  },
}
```

This allows the frontend to make requests to `/api/*` which are automatically forwarded to `http://localhost:9000/api/*`.

---

## API Integration Methods

### Method 1: Using the API Utility (Recommended)

A centralized API utility has been created at `src/utils/api.ts`:

```typescript
import api, { API_ENDPOINTS } from '@/utils/api';

// GET request
const tenants = await api.get(API_ENDPOINTS.TENANTS);

// POST request
const newSession = await api.post(API_ENDPOINTS.COACHING_SESSIONS, {
  title: 'Test Strategy Session',
  date: '2025-12-16',
});

// PUT request
const updated = await api.put(`${API_ENDPOINTS.USERS}/123`, userData);

// DELETE request
await api.delete(`${API_ENDPOINTS.TEST_DEBT_ITEMS}/456`);
```

**Features:**
- Automatic authentication header injection
- Token refresh on 401 errors
- Centralized error handling
- Type-safe endpoints
- Request/response interceptors

### Method 2: Using Fetch Directly

Example from `AuthContext.tsx`:

```typescript
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:9000';

const response = await fetch(`${API_URL}/api/auth/login`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  credentials: 'include',
  body: JSON.stringify({ email, password }),
});
```

---

## Available API Endpoints

### Authentication
- `POST /api/auth/login` - Tenant user login
- `POST /api/auth/logout` - Logout
- `POST /api/auth/refresh` - Refresh access token

### Platform Admin
- `POST /api/platform-admin/login` - Platform admin login
- `GET /api/platform-admin/tenants` - List all tenants
- `POST /api/platform-admin/tenants` - Create tenant
- `GET /api/platform-admin/admins` - List platform admins
- `POST /api/platform-admin/admins` - Create platform admin

### Tenant Management
- `GET /api/tenants` - Get tenant details
- `PUT /api/tenants/:id` - Update tenant
- `DELETE /api/tenants/:id` - Delete tenant

### User Management
- `GET /api/users` - List users
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### Squad Management
- `GET /api/squads` - List squads
- `POST /api/squads` - Create squad
- `PUT /api/squads/:id` - Update squad
- `DELETE /api/squads/:id` - Delete squad

### Coaching
- `GET /api/coaching/sessions` - List coaching sessions
- `POST /api/coaching/sessions` - Create session
- `PUT /api/coaching/sessions/:id` - Update session
- `DELETE /api/coaching/sessions/:id` - Delete session

### Quality Scorecards
- `GET /api/scorecards` - List scorecards
- `POST /api/scorecards` - Create scorecard
- `PUT /api/scorecards/:id` - Update scorecard

### Feedback
- `GET /api/feedback` - List feedback submissions
- `POST /api/feedback` - Submit feedback

### Maturity Assessments
- `GET /api/maturity/assessments` - List assessments
- `POST /api/maturity/assessments` - Create assessment

### Enablement Resources
- `GET /api/enablement/resources` - List resources
- `POST /api/enablement/resources` - Create resource

### Impact Timeline
- `GET /api/impact/events` - List impact events
- `POST /api/impact/events` - Create event

### Test Logger
- `GET /api/test-logger/sessions` - List test sessions
- `POST /api/test-logger/sessions` - Create session

### Test Debt
- `GET /api/test-debt/items` - List test debt items
- `POST /api/test-debt/items` - Create item
- `PUT /api/test-debt/items/:id` - Update item

### Change Tracker
- `GET /api/change-tracker/changes` - List changes
- `POST /api/change-tracker/changes` - Track change

### Career Framework
- `GET /api/career/assessments` - List career assessments
- `POST /api/career/assessments` - Create assessment

### Health Check
- `GET /health` - API health status
- `GET /` - API information and endpoints list

---

## Authentication Flow

### 1. Tenant User Login

```typescript
import { useAuth } from '@/contexts/AuthContext';

const { login } = useAuth();

try {
  await login('user@example.com', 'password');
  // User is redirected to /dashboard
} catch (error) {
  console.error('Login failed:', error);
}
```

### 2. Platform Admin Login

```typescript
import { useAuth } from '@/contexts/AuthContext';

const { loginPlatformAdmin } = useAuth();

try {
  await loginPlatformAdmin('admin@coachqa.com', 'password');
  // Admin is redirected to /admin/dashboard
} catch (error) {
  console.error('Login failed:', error);
}
```

### 3. Token Management

Tokens are automatically stored in localStorage:
- `accessToken` - Short-lived JWT for API requests
- `refreshToken` - Long-lived token for refreshing access
- `user` - User profile data
- `userType` - Either 'platform_admin' or 'tenant_user'

The API utility automatically:
- Includes the access token in request headers
- Refreshes expired tokens
- Redirects to login on authentication failure

---

## CORS Configuration

The backend is configured to accept requests from the frontend:

```typescript
// Backend: app.ts
app.use(
  cors({
    origin: process.env.CORS_ORIGIN || 'http://localhost:9001',
    credentials: true,
  })
);
```

---

## Testing the Integration

### 1. Visual Test Page

Open the test page in your browser:
```
http://localhost:9001/test-api.html
```

This page automatically tests:
- Health endpoint via proxy
- Root API endpoint via proxy
- Direct backend connection (CORS test)

### 2. Browser DevTools

1. Open the browser DevTools (F12)
2. Navigate to the Network tab
3. Login or interact with the application
4. Inspect the API requests to `http://localhost:9001/api/*`
5. Verify responses are coming from the backend

### 3. Manual API Testing

Use PowerShell, curl, or Postman:

```powershell
# Health check (direct)
Invoke-RestMethod -Uri "http://localhost:9000/health"

# Root endpoint (direct)
Invoke-RestMethod -Uri "http://localhost:9000/"
```

---

## Common Issues & Solutions

### Issue: API requests fail with 404

**Solution**: Ensure the backend server is running:
```bash
cd coachqa-backend
npm run dev
```

### Issue: CORS errors in browser console

**Solution**: 
1. Make sure requests go through the Vite proxy (`/api/*`)
2. Don't make direct requests to `http://localhost:9000` from the browser
3. Verify CORS_ORIGIN in backend `.env` file

### Issue: 401 Unauthorized errors

**Solution**:
1. Check if access token is present in localStorage
2. Verify token hasn't expired
3. Try logging in again
4. Check if refresh token mechanism is working

### Issue: Proxy not working

**Solution**:
1. Restart the Vite dev server
2. Check `vite.config.ts` proxy configuration
3. Ensure backend is running on port 9000
4. Clear browser cache

---

## Development Workflow

### Starting Both Servers

1. **Backend:**
   ```bash
   cd coachqa-backend
   npm run dev
   # Runs on http://localhost:9000
   ```

2. **Frontend:**
   ```bash
   cd coachqa-ui
   npm run dev
   # Runs on http://localhost:9001
   ```

### Making API Changes

1. Update backend endpoint in `coachqa-backend/src/routes/`
2. Update API_ENDPOINTS in `coachqa-ui/src/utils/api.ts` if needed
3. Use the updated endpoint in your React components

### Adding New API Endpoints

1. **Backend**: Create/update route in `src/routes/`
2. **Frontend**: Add endpoint to `API_ENDPOINTS` in `src/utils/api.ts`
3. **Frontend**: Use `api.get/post/put/delete()` in components

---

## Security Features

✅ **Helmet**: Security headers enabled  
✅ **CORS**: Configured for localhost:9001  
✅ **Rate Limiting**: 100 requests per 15 minutes per IP  
✅ **JWT Authentication**: Access & refresh tokens  
✅ **Request Logging**: All API requests logged  
✅ **Error Handling**: Centralized error middleware  

---

## Next Steps

1. ✅ Backend API running
2. ✅ Frontend UI running
3. ✅ API proxy configured
4. ✅ Authentication integrated
5. ✅ API utilities created
6. 🔄 Connect all UI pages to real API endpoints (in progress)
7. 🔄 Add loading states and error handling in UI
8. 🔄 Implement full authentication flow
9. 🔄 Add API response caching
10. 🔄 Write integration tests

---

## Support

For issues or questions:
1. Check the [API Documentation](../coachqa-backend/docs/API.md)
2. Review the [Backend Architecture](../coachqa-backend/docs/ARCHITECTURE.md)
3. Test endpoints using the test page at `/test-api.html`

---

**Last Updated**: December 16, 2025
