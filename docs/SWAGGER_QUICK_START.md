# Swagger API - Quick Start Card

## 🚀 5-Minute Setup (2-Step Login)

### 1. Open Swagger
```
http://127.0.0.1:9002/api-docs
```

### 2. Step 1: Login to Get Tenant List
**Authentication** → **POST /api/auth/login** → Try it out

```json
{
  "email": "admin@test.com",
  "password": "Password123!"
}
```

Execute → **Copy `userId` and pick a `tenantId` from `tenants` array**

### 3. Step 2: Select Tenant to Get Token
**Authentication** → **POST /api/auth/login-with-tenant** → Try it out

```json
{
  "userId": "<paste-userId-from-step-1>",
  "tenantId": "<paste-tenantId-from-step-1>"
}
```

Execute → **Copy `accessToken`**

### 4. Authorize
Click **🔓 Authorize** button (top of page)

Enter:
```
Bearer <paste-your-accessToken-here>
```

Click "Authorize" → "Close"

### 5. Test Endpoints ✅
Now all endpoints work! Try:
- **GET /api/users**
- **GET /api/squads**
- **GET /api/coaching/sessions**

**⚠️ Important:** Even with 1 tenant, you need both login steps!

## 📋 Cheat Sheet

| Action | Endpoint | Auth? | Notes |
|--------|----------|-------|-------|
| **Login (Step 1)** | `POST /api/auth/login` | No | Get userId + tenants list |
| **Select Tenant (Step 2)** | `POST /api/auth/login-with-tenant` | No | Get accessToken |
| **Register** | `POST /api/auth/register` | No | Creates new tenant + user |
| **Refresh Token** | `POST /api/auth/refresh` | No | Get new accessToken |
| **List Users** | `GET /api/users` | Yes | Requires accessToken |
| **Create Squad** | `POST /api/squads` | Yes | Requires accessToken |

## 🔧 Common Issues

**401 Unauthorized?**
→ Click Authorize and enter your token

**Token Expired?**
→ Use `/api/auth/refresh` or login again

**CORS Error?**
→ Backend might not be running on port 9002

## 💡 Pro Tips

✅ Token lasts 1 hour  
✅ Refresh token lasts 7 days  
✅ Use "Bearer " before token (with space!)  
✅ Examples are interactive - click to use  
✅ Authorization persists in browser session  

## 🎯 Full Guide

See `SWAGGER_LOGIN_GUIDE.md` for complete documentation.

---

**URL**: `http://127.0.0.1:9002/api-docs`  
**Test Email**: `admin@test.com`  
**Test Password**: `Password123!`

