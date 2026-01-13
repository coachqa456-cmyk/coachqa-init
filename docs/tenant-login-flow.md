# Tenant-Based Login Flow - Complete Documentation

## Overview

The CoachQA platform uses a **two-step tenant-based login process** that allows users to belong to multiple tenant organizations and select which tenant context they want to work in during login.

---

## 🔄 Complete Login Flow

### Architecture Overview

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐         ┌─────────────┐
│   Browser   │────────>│   Frontend  │────────>│   Backend   │────────>│  Database   │
│  (User)     │         │   (React)   │         │  (Node.js)  │         │(PostgreSQL) │
└─────────────┘         └──────────────┘         └─────────────┘         └─────────────┘
```

---

## 📋 Step-by-Step Process

### **Phase 1: User Initiates Login**

#### 1. User Enters Credentials

**Location:** `coachqa-ui/src/pages/public/LoginPage.tsx`

- User enters **email** and **password** (or uses Google OAuth)
- Clicks "Sign In" button

**What happens:**
- Frontend validates email format
- Password is sent securely to backend (never logged)

---

### **Phase 2: Backend Verifies Credentials**

#### 2. Backend Receives Login Request

**Location:** `coachqa-backend/src/routes/auth.routes.ts` → `coachqa-backend/src/controllers/auth.controller.ts`

**Endpoint:** `POST /api/auth/login`

```typescript
// Request body
{
  email: "user@example.com",
  password: "password123"
}
```

#### 3. Backend Validates Credentials

**Location:** `coachqa-backend/src/services/auth.service.ts` - `login()` function

**Process:**

1. **Find User by Email**
   ```typescript
   const user = await User.findOne({
     where: { email: data.email }
   });
   ```
   - Email is globally unique across all tenants
   - If user not found → Returns `401 Unauthorized`

2. **Verify Password**
   ```typescript
   const isValidPassword = await comparePassword(data.password, user.passwordHash);
   ```
   - Uses bcrypt to compare password hash
   - If password invalid → Returns `401 Unauthorized`

3. **Get User's Tenant Associations**
   ```typescript
   const userTenants = await UserTenant.findAll({
     where: { 
       userId: user.id,
       status: UserStatus.ACTIVE  // Only active associations
     },
     include: [{ model: Tenant, as: 'tenant' }]
   });
   ```
   - Retrieves all active tenant associations for this user
   - Each association includes:
     - `tenantId`: The tenant organization ID
     - `role`: User's role in that tenant (admin, qe, manager, developer, executive)
     - `status`: Must be ACTIVE
     - `tenant`: Full tenant details (name, slug)

4. **Check User Has Tenants**
   ```typescript
   if (userTenants.length === 0) {
     throw new UnauthorizedError('User has no active tenant associations');
   }
   ```
   - If user has no active tenants → Returns `401 Unauthorized`

#### 4. Backend Returns User Info + Tenant List

**Response Structure:**

```typescript
{
  success: true,
  data: {
    user: {
      id: "user-uuid",
      name: "John Doe",
      email: "user@example.com",
      avatarUrl: "https://..."
    },
    tenants: [
      {
        id: "tenant-1-uuid",
        name: "Acme Corporation",
        slug: "acme-corp",
        role: "admin"
      },
      {
        id: "tenant-2-uuid",
        name: "Tech Startup Inc",
        slug: "tech-startup",
        role: "developer"
      }
    ]
  }
}
```

**Important:** 
- **No tokens are generated yet** at this stage
- Backend only returns user info and available tenants
- User must select a tenant before tokens are issued

---

### **Phase 3: Frontend Handles Tenant Selection**

#### 5. Frontend Receives Response

**Location:** `coachqa-ui/src/contexts/AuthContext.tsx` - `login()` function

**Process:**

1. **Check if User Has Only One Tenant**
   ```typescript
   if (tenants.length === 1) {
     // Auto-select the single tenant
     return await loginWithTenant(user.id, tenants[0].id);
   }
   ```
   - If user has only one tenant → Automatically proceeds to tenant login
   - No tenant selector shown

2. **If Multiple Tenants**
   ```typescript
   setPendingLogin({
     user: result.user,
     tenants: result.tenants
   });
   ```
   - Stores user and tenant list in React state (`pendingLogin`)
   - Navigates to tenant selector page (`/select-tenant`)

#### 6. Tenant Selector Page

**Location:** `coachqa-ui/src/pages/public/TenantSelectorPage.tsx`

**What User Sees:**
- List of tenant organizations they belong to
- Each tenant shows:
  - Organization name
  - User's role in that tenant
  - "Select" button

**User Action:**
- User clicks "Select" on desired tenant
- Frontend calls `loginWithTenant(userId, tenantId)`

---

### **Phase 4: Backend Generates Tenant-Specific Tokens**

#### 7. Frontend Sends Tenant Selection

**Location:** `coachqa-ui/src/contexts/AuthContext.tsx` - `loginWithTenant()` function

**API Call:** `POST /api/auth/login-with-tenant`

```typescript
// Request body
{
  userId: "user-uuid",
  tenantId: "tenant-1-uuid"
}
```

#### 8. Backend Validates Tenant Access

**Location:** `coachqa-backend/src/services/auth.service.ts` - `loginWithTenant()` function

**Process:**

1. **Verify User Exists**
   ```typescript
   const user = await User.findByPk(userId);
   if (!user) {
     throw new UnauthorizedError('User not found');
   }
   ```

2. **Verify User Has Access to Tenant**
   ```typescript
   const userTenant = await UserTenant.findOne({
     where: {
       userId,
       tenantId,
       status: UserStatus.ACTIVE  // Must be active
     },
     include: [{ model: Tenant, as: 'tenant' }]
   });
   
   if (!userTenant) {
     throw new UnauthorizedError('User does not have access to this tenant');
   }
   ```
   - Checks that user has an active association with the selected tenant
   - If no access → Returns `401 Unauthorized`

3. **Generate Access Token**
   ```typescript
   const accessToken = generateAccessToken({
     userId: user.id,
     tenantId: tenantId,           // Tenant context included
     email: user.email,
     role: userTenant.role,         // Role specific to this tenant
     userType: 'tenant_user'
   });
   ```
   - JWT token includes:
     - `userId`: User ID
     - `tenantId`: Selected tenant ID (critical for data isolation)
     - `email`: User email
     - `role`: User's role in THIS tenant (can differ per tenant)
     - `userType`: Always `'tenant_user'` for tenant users

4. **Generate Refresh Token**
   ```typescript
   const refreshTokenValue = generateRefreshToken();
   const expiresAt = getTokenExpirationDate(7); // 7 days
   
   // Delete old refresh tokens
   await RefreshToken.destroy({ where: { userId: user.id } });
   
   // Create new refresh token
   await RefreshToken.create({
     userId: user.id,
     token: refreshTokenValue,
     expiresAt
   });
   ```

#### 9. Backend Returns Tokens + User Data

**Response Structure:**

```typescript
{
  success: true,
  data: {
    user: {
      id: "user-uuid",
      name: "John Doe",
      email: "user@example.com",
      role: "admin",              // Role in selected tenant
      roleId: "role-uuid",        // Optional role ID
      tenantId: "tenant-1-uuid",  // Selected tenant
      avatarUrl: "https://..."
    },
    accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    refreshToken: "random-refresh-token-string"
  }
}
```

---

### **Phase 5: Frontend Stores Session**

#### 10. Frontend Stores Tokens and User Data

**Location:** `coachqa-ui/src/contexts/AuthContext.tsx` - `loginWithTenant()` function

**Storage:**

```typescript
// Store in localStorage with tenant namespace
localStorage.setItem("tenant.accessToken", accessToken);
localStorage.setItem("tenant.refreshToken", refreshToken);
localStorage.setItem("tenant.user", JSON.stringify(user));
localStorage.setItem("tenant.userType", "tenant_user");
```

**Why Tenant Namespace?**
- Separates tenant user sessions from platform admin sessions
- Platform admin uses `platform.*` keys
- Prevents conflicts when switching between user types

#### 11. Update React State

```typescript
setUser(result.user as TenantUser);
setUserType("tenant_user");
setPendingLogin(null); // Clear pending login
```

#### 12. Navigate to Dashboard

```typescript
navigate("/dashboard");
```

- User is now authenticated
- All API requests will include the access token
- Token contains `tenantId` for automatic data filtering

---

## 🔐 Key Concepts

### 1. Multi-Tenant User Model

**Database Structure:**

```
Users Table (Global)
├── id (UUID)
├── email (globally unique)
├── passwordHash
├── name
└── ...

UserTenant Table (Junction)
├── userId → Users.id
├── tenantId → Tenants.id
├── role (admin, qe, manager, developer, executive)
└── status (ACTIVE, INACTIVE, PENDING)

Tenants Table
├── id (UUID)
├── name
├── slug
└── ...
```

**Key Points:**
- One user can belong to multiple tenants
- Each tenant association has its own role
- User can have different roles in different tenants
- Only ACTIVE associations allow login

### 2. Two-Step Authentication

**Step 1: Credential Verification**
- Validates email/password
- Returns user info + tenant list
- **No tokens generated**

**Step 2: Tenant Selection**
- User selects tenant
- Backend generates tenant-specific tokens
- Tokens include tenant context

### 3. Token Structure

**Access Token (JWT):**
```json
{
  "userId": "user-uuid",
  "tenantId": "tenant-uuid",    // Critical for data isolation
  "email": "user@example.com",
  "role": "admin",               // Role in THIS tenant
  "userType": "tenant_user",
  "iat": 1234567890,
  "exp": 1234567890
}
```

**Why Tenant ID in Token?**
- All API requests automatically filtered by tenant
- Prevents cross-tenant data access
- Backend middleware extracts `tenantId` from token

### 4. Data Isolation

**Backend Middleware:**

```typescript
// Every authenticated request includes tenantId
req.user = {
  userId: "...",
  tenantId: "...",  // Extracted from token
  role: "...",
  email: "..."
}

// All database queries filtered by tenantId
const squads = await Squad.findAll({
  where: { tenantId: req.user.tenantId }
});
```

---

## 🔄 Login Methods

### 1. Email/Password Login

**Flow:**
1. User enters email/password
2. Backend verifies credentials
3. Returns tenant list
4. User selects tenant
5. Tokens generated

**Endpoints:**
- `POST /api/auth/login` - Step 1: Verify credentials
- `POST /api/auth/login-with-tenant` - Step 2: Select tenant

### 2. Google OAuth Login

**Flow:**
1. User clicks "Sign in with Google"
2. Google returns ID token
3. Backend verifies token with Google
4. Backend finds user by email
5. Returns tenant list (same as email/password)
6. User selects tenant
7. Tokens generated

**Endpoints:**
- `POST /api/auth/google` - Step 1: Verify Google token
- `POST /api/auth/login-with-tenant` - Step 2: Select tenant (same as email/password)

**Note:** Google login also requires tenant selection if user has multiple tenants.

### 3. Invitation Acceptance

**Flow:**
1. User receives invitation email
2. Clicks invitation link (`/accept-invitation/{token}`)
3. User enters name and password
4. Backend creates user account
5. Associates user with tenant
6. Tokens generated immediately (user has only one tenant)

**Endpoint:**
- `POST /api/auth/accept-invitation/{token}` - Creates account + generates tokens

**Note:** New users from invitations typically have only one tenant, so no tenant selection needed.

---

## 📊 Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    TENANT LOGIN FLOW                        │
└─────────────────────────────────────────────────────────────┘

1. USER ENTERS CREDENTIALS
   │   Email + Password (or Google OAuth)
   │
   ▼
2. BACKEND VERIFIES CREDENTIALS
   │   ✓ Check user exists
   │   ✓ Verify password
   │   ✓ Get active tenant associations
   │
   ▼
3. BACKEND RETURNS USER + TENANT LIST
   │   {
   │     user: { id, name, email },
   │     tenants: [
   │       { id, name, role },
   │       { id, name, role }
   │     ]
   │   }
   │
   ▼
4. FRONTEND CHECKS TENANT COUNT
   │
   ├─► ONE TENANT → Auto-select
   │   │
   │   └─► Skip to Step 6
   │
   └─► MULTIPLE TENANTS → Show Selector
       │
       ▼
5. USER SELECTS TENANT
   │   Clicks "Select" on desired tenant
   │
   ▼
6. FRONTEND SENDS TENANT SELECTION
   │   POST /api/auth/login-with-tenant
   │   { userId, tenantId }
   │
   ▼
7. BACKEND VALIDATES TENANT ACCESS
   │   ✓ Verify user exists
   │   ✓ Verify user has access to tenant
   │   ✓ Get tenant-specific role
   │
   ▼
8. BACKEND GENERATES TOKENS
   │   ✓ Access token (includes tenantId)
   │   ✓ Refresh token (7 days)
   │
   ▼
9. FRONTEND STORES SESSION
   │   localStorage:
   │   - tenant.accessToken
   │   - tenant.refreshToken
   │   - tenant.user
   │   - tenant.userType
   │
   ▼
10. USER AUTHENTICATED
    │   - Redirected to /dashboard
    │   - All API requests include token
    │   - Data automatically filtered by tenant
```

---

## 🛡️ Security Features

### 1. Password Security
- Passwords hashed with bcrypt
- Never stored in plain text
- Never logged or exposed

### 2. Token Security
- JWT tokens signed with secret key
- Access tokens short-lived (15 min - 1 hour)
- Refresh tokens stored in database
- Tokens can be revoked (logout)

### 3. Tenant Isolation
- Every token includes `tenantId`
- Backend middleware enforces tenant filtering
- Cross-tenant access prevented
- User can only access tenants they belong to

### 4. Role-Based Access
- Role is tenant-specific
- User can have different roles in different tenants
- Role stored in token for authorization checks

### 5. Session Management
- Separate storage namespaces for tenant vs platform admin
- Prevents session conflicts
- Clear separation of concerns

---

## 🔄 Token Refresh Flow

When access token expires:

1. **Frontend detects expired token** (401 response)
2. **Frontend calls refresh endpoint:**
   ```typescript
   POST /api/auth/refresh
   {
     refreshToken: "...",
     tenantId: "..."  // Required for multi-tenant
   }
   ```
3. **Backend validates refresh token:**
   - Checks token exists in database
   - Checks token not expired
   - Verifies user still has access to tenant
4. **Backend generates new access token:**
   - Includes same `tenantId` and `role`
   - Same user context
5. **Frontend updates access token:**
   - Stores new token in localStorage
   - Retries original request

**Important:** Refresh token must include `tenantId` to maintain tenant context.

---

## 📝 Code Locations

### Frontend
- **Login Page**: `coachqa-ui/src/pages/public/LoginPage.tsx`
- **Tenant Selector**: `coachqa-ui/src/pages/public/TenantSelectorPage.tsx`
- **Auth Context**: `coachqa-ui/src/contexts/AuthContext.tsx`
- **API Helpers**: `coachqa-ui/src/utils/api.ts`

### Backend
- **Auth Routes**: `coachqa-backend/src/routes/auth.routes.ts`
- **Auth Controller**: `coachqa-backend/src/controllers/auth.controller.ts`
- **Auth Service**: `coachqa-backend/src/services/auth.service.ts`
- **Token Service**: `coachqa-backend/src/services/token.service.ts`
- **Auth Middleware**: `coachqa-backend/src/middleware/auth.ts`

### Database Models
- **User Model**: `coachqa-backend/src/models/User.ts`
- **Tenant Model**: `coachqa-backend/src/models/Tenant.ts`
- **UserTenant Model**: `coachqa-backend/src/models/UserTenant.ts`
- **RefreshToken Model**: `coachqa-backend/src/models/RefreshToken.ts`

---

## 🚨 Error Scenarios

### Scenario 1: Invalid Credentials
```
User → Login → Backend
Backend → Check User → NOT FOUND
Response: 401 "Invalid credentials"
Frontend: Shows error message
```

### Scenario 2: User Has No Active Tenants
```
User → Login → Backend
Backend → Verify Credentials → SUCCESS
Backend → Get Tenants → EMPTY ARRAY
Response: 401 "User has no active tenant associations"
Frontend: Shows error message
```

### Scenario 3: User Tries to Access Unauthorized Tenant
```
User → Select Tenant → Backend
Backend → Check UserTenant → NOT FOUND or INACTIVE
Response: 401 "User does not have access to this tenant"
Frontend: Shows error message
```

### Scenario 4: Expired Refresh Token
```
User → API Request → Backend
Backend → Token Expired → 401
Frontend → Refresh Token → Backend
Backend → Check Refresh Token → EXPIRED
Response: 401 "Refresh token expired"
Frontend: Redirects to login
```

---

## 🎯 Summary

**Tenant-based login works by:**

1. **User authenticates** → Backend verifies credentials
2. **Backend returns tenant list** → User sees all organizations they belong to
3. **User selects tenant** → Chooses which organization context to work in
4. **Backend generates tenant-specific tokens** → Tokens include `tenantId` and tenant-specific `role`
5. **Frontend stores session** → Tokens stored with tenant namespace
6. **All API requests filtered by tenant** → Backend automatically isolates data by `tenantId`

**Key Benefits:**
- ✅ Users can belong to multiple organizations
- ✅ Different roles per organization
- ✅ Complete data isolation between tenants
- ✅ Secure token-based authentication
- ✅ Flexible tenant switching (logout and login to different tenant)

**Security:**
- ✅ Passwords never exposed
- ✅ Tokens include tenant context
- ✅ Backend enforces tenant isolation
- ✅ Role-based access control per tenant

---

## 📚 Related Documentation

- **[Multi-Tenant Dashboard](./multi-tenant-dashboard.md)** - How the dashboard works when users belong to multiple tenants
  - How tenant context is maintained
  - How data is filtered by tenant
  - How to switch between tenants
