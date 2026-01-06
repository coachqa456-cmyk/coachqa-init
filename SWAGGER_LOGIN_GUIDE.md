# Swagger API Login & Testing Guide

## 🎯 Quick Start

Access Swagger UI at: **`http://127.0.0.1:9002/api-docs`**

## 🔐 Step-by-Step: Get Your Access Token

### Step 1: Open Swagger UI

Navigate to: `http://127.0.0.1:9002/api-docs`

You'll see the complete API documentation with all endpoints.

### Step 2: Find the Login Endpoint

1. Scroll to the **Authentication** section
2. Find **POST /api/auth/login**
3. Click on it to expand

### Step 3: Test the Login

1. Click **"Try it out"** button (top right of the endpoint)
2. You'll see the request body editor
3. Use these **test credentials**:

```json
{
  "email": "admin@test.com",
  "password": "Password123!"
}
```

4. Click **"Execute"** button
5. Scroll down to see the response

### Step 4: Copy Your Access Token

In the response body, you'll see:

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "...",
      "email": "admin@test.com",
      "name": "Admin User",
      "role": "admin",
      "tenantId": "..."
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "..."
  }
}
```

**Copy the entire `accessToken` value** (the long JWT string)

### Step 5: Authorize Swagger UI

1. Look at the **top of the page**
2. Find the **🔓 Authorize** button (usually green)
3. Click it
4. A dialog will appear showing **bearerAuth**
5. In the **"Value"** field, enter:
   ```
   Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```
   (Replace with your actual token, make sure to include "Bearer " before the token)
6. Click **"Authorize"**
7. You should see **🔒 Authorized** status
8. Click **"Close"**

### Step 6: Test Protected Endpoints

Now you can test any protected endpoint! For example:

1. Go to **Users** → **GET /api/users**
2. Click "Try it out"
3. Click "Execute"
4. You'll get user data (because you're authenticated!) ✅

## 📋 Alternative Methods to Get Tokens

### Method 1: Register New Account

If you don't have credentials:

1. Go to **POST /api/auth/register**
2. Click "Try it out"
3. Enter your details:
```json
{
  "organizationName": "My Company",
  "adminName": "Your Name",
  "adminEmail": "your@email.com",
  "password": "YourPassword123!",
  "newsletterOptIn": false
}
```
4. Execute
5. Copy the `accessToken` from response
6. Follow Step 5 above to authorize

### Method 2: Google OAuth Signup

1. Go to **POST /api/auth/google/signup**
2. You need a Google ID token (get from frontend OAuth flow)
3. Send the token in the request

### Method 3: Platform Admin Login

For platform admin endpoints:

1. Use **POST /api/platform-admin/login**
2. Credentials:
```json
{
  "email": "platform.admin@coachqa.com",
  "password": "SuperSecurePassword123!"
}
```

## 🔄 Refresh Your Token

Access tokens expire after 1 hour. To refresh:

1. Go to **POST /api/auth/refresh**
2. Click "Try it out"
3. Enter your refresh token:
```json
{
  "refreshToken": "your-refresh-token-here"
}
```
4. Execute
5. You'll get a new `accessToken` and `refreshToken`
6. Update your authorization (Step 5)

## 💡 Pro Tips

### Tip 1: Token Stays Active in Swagger

Once you authorize in Swagger, the token is saved in your browser session. You don't need to re-authorize for each request.

### Tip 2: Check Token Expiration

If you get **401 Unauthorized** errors, your token probably expired:
- Refresh your token (see above)
- Or login again to get a new token

### Tip 3: Testing Multiple User Roles

To test different user roles:
1. Login with different credentials
2. Get their token
3. Re-authorize with the new token
4. Test role-specific endpoints

### Tip 4: Copy Examples

Each endpoint in Swagger has example requests. Click the example to auto-fill the request body!

### Tip 5: Check Response Codes

- **200** - Success
- **201** - Created
- **400** - Bad request (check your input)
- **401** - Unauthorized (need to login/authorize)
- **403** - Forbidden (don't have permission)
- **404** - Not found

## 🎨 Swagger UI Features

### Interactive Testing
- ✅ All endpoints are interactive
- ✅ Live API calls to your backend
- ✅ Real-time responses

### Schema Documentation
- ✅ Request/response schemas
- ✅ Field descriptions
- ✅ Required fields marked
- ✅ Data types and formats

### Examples
- ✅ Multiple examples per endpoint
- ✅ Success/error response examples
- ✅ Click to auto-fill

### Authorization
- ✅ Bearer token authentication
- ✅ Persists across requests
- ✅ Easy to update

## 🔧 Troubleshooting

### Issue: "Unauthorized" Error

**Solution:** 
1. Make sure you clicked "Authorize" at the top
2. Check token format: `Bearer <token>` (with space)
3. Token might be expired - login again

### Issue: "CORS Error"

**Solution:**
- Swagger UI is on same domain, shouldn't have CORS issues
- If using different domain, check backend CORS settings

### Issue: "Network Error"

**Solution:**
1. Check if backend is running: `http://127.0.0.1:9002`
2. Verify API is accessible
3. Check browser console for errors

### Issue: "Invalid Credentials"

**Solution:**
1. Double-check email and password
2. Ensure no extra spaces
3. Try registering a new account if testing

### Issue: Token Not Working

**Solution:**
1. Verify you included "Bearer " prefix
2. Copy entire token (very long string)
3. Make sure no line breaks in token
4. Try logging in again

## 📚 API Testing Workflow

### Typical Testing Flow

```
1. Open Swagger UI
   ↓
2. POST /api/auth/login (get token)
   ↓
3. Click Authorize (enter token)
   ↓
4. Test endpoints:
   - GET /api/users (list users)
   - POST /api/squads (create squad)
   - GET /api/coaching/sessions (view sessions)
   - etc.
   ↓
5. Token expires after 1 hour
   ↓
6. POST /api/auth/refresh (get new token)
   ↓
7. Continue testing
```

### Testing User Permissions

```
1. Login as Admin
   → Test admin-only endpoints
   ↓
2. Login as QE
   → Test QE-specific features
   ↓
3. Login as Manager
   → Test manager views
```

## 🎯 Quick Reference

### Essential Endpoints

| Endpoint | Purpose | Auth Required |
|----------|---------|---------------|
| `POST /api/auth/login` | Get access token | ❌ No |
| `POST /api/auth/register` | Create new account | ❌ No |
| `POST /api/auth/refresh` | Refresh token | ❌ No |
| `GET /api/users` | List users | ✅ Yes |
| `GET /api/squads` | List squads | ✅ Yes |
| `GET /api/coaching/sessions` | Coaching sessions | ✅ Yes |

### Authorization Header Format

```
Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMjM...
```

### Test Credentials

```json
{
  "email": "admin@test.com",
  "password": "Password123!"
}
```

## 🚀 Advanced Usage

### Testing with Postman/Insomnia

If you prefer other API clients:

1. Get token from Swagger
2. Export the request as cURL
3. Import into Postman/Insomnia
4. Add Authorization header manually

### API Documentation Export

Swagger provides:
- **OpenAPI/Swagger JSON**: `http://127.0.0.1:9002/api-docs/swagger.json`
- Can import into other tools
- Generate client SDKs

### Environment Variables

For different environments:

```bash
# Development
VITE_API_URL=http://127.0.0.1:9002

# Production
VITE_API_URL=https://api.coachqa.com
```

## 📖 Additional Resources

- **Swagger Editor**: https://editor.swagger.io
- **OpenAPI Specification**: https://swagger.io/specification/
- **JWT Debugger**: https://jwt.io (decode your tokens)

## 🎉 You're Ready!

You now know how to:
- ✅ Access Swagger UI
- ✅ Login and get tokens
- ✅ Authorize requests
- ✅ Test all endpoints
- ✅ Handle token expiration
- ✅ Troubleshoot issues

**Happy Testing!** 🚀

---

**Quick Access**: `http://127.0.0.1:9002/api-docs`




