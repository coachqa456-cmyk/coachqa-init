# Swagger Two-Step Login Fix

## 🎯 Problem

When trying to login via Swagger, users were getting:
```json
{
  "message": "Please select a tenant to continue"
}
```

But no clear instructions on what to do next.

## ✅ Solution

Updated Swagger documentation to clearly explain the **two-step login process**:

### Step 1: Login → Get Tenant List
**Endpoint:** `POST /api/auth/login`

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "email": "admin@test.com",
      "name": "Admin User"
    },
    "tenants": [
      {
        "id": "987e6543-e21b-43d2-b567-987654321000",
        "name": "Acme Corporation",
        "slug": "acme-corp",
        "role": "admin"
      }
    ]
  },
  "message": "Please select a tenant to continue"
}
```

### Step 2: Select Tenant → Get Access Token
**Endpoint:** `POST /api/auth/login-with-tenant`

**Request:**
```json
{
  "userId": "123e4567-e89b-12d3-a456-426614174000",
  "tenantId": "987e6543-e21b-43d2-b567-987654321000"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": { ... },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

## 📝 Changes Made

### 1. Updated `/api/auth/login` Documentation
- ✅ Clear explanation that this is Step 1
- ✅ Shows actual response structure (with tenants array, not accessToken)
- ✅ Explains what to do next
- ✅ Added example response with multiple tenants

### 2. Updated `/api/auth/login-with-tenant` Documentation
- ✅ Clear explanation that this is Step 2
- ✅ Shows complete login flow
- ✅ Added examples for single and multiple tenants
- ✅ Shows complete response with accessToken

### 3. Updated Swagger Homepage
- ✅ Updated Quick Start guide with 2-step process
- ✅ Clear step-by-step instructions
- ✅ Notes that even single tenant requires both steps

### 4. Updated Quick Start Guide
- ✅ Changed from 3-minute to 5-minute setup
- ✅ Added Step 2 instructions
- ✅ Updated cheat sheet with both endpoints

## 🚀 How to Use Now

### Complete Flow in Swagger:

1. **Open Swagger**: `http://127.0.0.1:9002/api-docs`

2. **Step 1 - Login**:
   - Go to **Authentication** → **POST /api/auth/login**
   - Click "Try it out"
   - Enter credentials:
     ```json
     {
       "email": "admin@test.com",
       "password": "Password123!"
     }
     ```
   - Click "Execute"
   - **Copy `userId` and `tenantId` from response**

3. **Step 2 - Select Tenant**:
   - Go to **Authentication** → **POST /api/auth/login-with-tenant**
   - Click "Try it out"
   - Enter:
     ```json
     {
       "userId": "<from-step-1>",
       "tenantId": "<from-step-1>"
     }
     ```
   - Click "Execute"
   - **Copy `accessToken`**

4. **Authorize**:
   - Click **🔓 Authorize** button
   - Enter: `Bearer <accessToken>`
   - Click "Authorize" → "Close"

5. **Test Endpoints** ✅

## 💡 Why Two Steps?

The system supports **multi-tenant users** - one user can belong to multiple organizations. The two-step process:
1. Shows all available tenants
2. Lets user choose which tenant context to use
3. Generates tenant-specific access token

Even if user has only 1 tenant, the process is the same for consistency.

## 📚 Files Updated

1. `coachqa-backend/src/routes/auth.routes.ts`
   - Enhanced `/api/auth/login` documentation
   - Enhanced `/api/auth/login-with-tenant` documentation

2. `coachqa-backend/src/config/swagger.ts`
   - Updated homepage Quick Start guide

3. `SWAGGER_QUICK_START.md`
   - Updated with 2-step process
   - Updated cheat sheet

## 🎉 Result

Users now have:
- ✅ Clear understanding of 2-step login
- ✅ Step-by-step instructions
- ✅ Example requests and responses
- ✅ No more confusion about "Please select a tenant"

**The Swagger UI now guides users through the complete login flow!** 🚀


