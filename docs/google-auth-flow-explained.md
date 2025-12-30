# How Google Authentication Works - Step by Step

This document provides a detailed, step-by-step explanation of how Google OAuth authentication works in the CoachQA platform.

## Quick Overview

Google authentication allows users to sign in or sign up using their Google account instead of creating a separate password. The platform uses Google's OAuth 2.0 ID tokens to verify user identity.

---

## 🔄 Complete Authentication Flow

### Architecture Overview

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐         ┌─────────────┐
│   Browser   │────────>│ Google OAuth │────────>│   Frontend  │────────>│   Backend   │
│  (User)     │         │   Provider   │         │   (React)   │         │  (Node.js)  │
└─────────────┘         └──────────────┘         └─────────────┘         └─────────────┘
                                                                                │
                                                                                ▼
                                                                         ┌─────────────┐
                                                                         │  Database   │
                                                                         │ (PostgreSQL)│
                                                                         └─────────────┘
```

---

## 📋 Step-by-Step Process

### **Phase 1: Frontend Setup**

#### 1. Google OAuth Provider Initialization

**Location:** `coachqa-ui/src/components/providers/AppProviders.tsx`

```typescript
import { GoogleOAuthProvider } from "@react-oauth/google";

const GOOGLE_CLIENT_ID = "746343245098-72ffk4klhps027k7po4497bjdag4hv07.apps.googleusercontent.com";

<GoogleOAuthProvider clientId={GOOGLE_CLIENT_ID}>
  {/* App components */}
</GoogleOAuthProvider>
```

**What happens:**
- Google OAuth library is initialized with the client ID
- This enables Google Sign-In components throughout the app
- The client ID identifies your application to Google

---

### **Phase 2: User Initiates Google Sign-In**

#### 2. User Clicks "Sign in with Google"

**Location:** `coachqa-ui/src/pages/auth/LoginPage.tsx` or `SignupPage.tsx`

```typescript
<GoogleLogin
  onSuccess={handleGoogleSuccess}
  onError={handleGoogleError}
  useOneTap={false}  // or true for login page
/>
```

**What happens:**
- Google's sign-in popup/button appears
- User sees Google account selector
- User selects their Google account
- User grants permissions to the application

---

### **Phase 3: Google Returns ID Token**

#### 3. Google OAuth Provider Returns Credential

**What Google sends back:**
```typescript
credentialResponse = {
  credential: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEyMzQ1Njc4OTA..."  // JWT ID Token
}
```

**This ID Token contains:**
- User's email address
- User's name
- Profile picture URL
- Google account ID
- Token expiration
- Issuer information (Google)
- Signature (cryptographically signed by Google)

**Important:** The token is a JWT (JSON Web Token) that is cryptographically signed by Google, ensuring its authenticity.

---

### **Phase 4: Frontend Sends Token to Backend**

#### 4. Frontend Handler Processes the Token

**Location:** `coachqa-ui/src/pages/auth/LoginPage.tsx`

```typescript
const handleGoogleSuccess = async (credentialResponse: any) => {
  try {
    setIsLoading(true);
    setError('');
    
    if (!credentialResponse.credential) {
      throw new Error('No credential received from Google');
    }

    // Send ID token to backend
    await loginWithGoogle(credentialResponse.credential);
    // Navigation happens automatically in loginWithGoogle
  } catch (err) {
    setError(err.message || 'Google login failed');
  } finally {
    setIsLoading(false);
  }
};
```

#### 5. Frontend API Call

**Location:** `coachqa-ui/src/contexts/TenantAuthContext.tsx`

```typescript
const loginWithGoogle = async (idToken: string) => {
  const response = await fetch(`${API_URL}/api/auth/google`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    credentials: "include",
    body: JSON.stringify({ idToken }),  // Send the token to backend
  });
  
  // Process response...
};
```

**What happens:**
- Frontend sends the Google ID token to backend endpoint `/api/auth/google`
- Token is sent as JSON in request body
- Frontend waits for backend response

---

### **Phase 5: Backend Verifies Token**

#### 6. Backend Receives Request

**Location:** `coachqa-backend/src/routes/auth.routes.ts` → `coachqa-backend/src/controllers/auth.controller.ts`

```typescript
export const googleLogin = async (req, res, next) => {
  const { idToken } = req.body;
  
  if (!idToken) {
    throw new AppError('Google ID token is required', 400);
  }
  
  // Call service to verify and authenticate
  const result = await authService.loginWithGoogle({ idToken });
  
  res.json({
    success: true,
    data: result,
  });
};
```

#### 7. Backend Verifies Token with Google

**Location:** `coachqa-backend/src/services/auth.service.ts`

```typescript
import { OAuth2Client } from 'google-auth-library';

const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID || 'default-client-id';
const client = new OAuth2Client(GOOGLE_CLIENT_ID);

export const loginWithGoogle = async (data: GoogleLoginData) => {
  // Verify the token with Google's servers
  const ticket = await client.verifyIdToken({
    idToken: data.idToken,
    audience: GOOGLE_CLIENT_ID,  // Must match our client ID
  });

  const payload = ticket.getPayload();
  // payload contains: email, name, picture, etc.
};
```

**What happens:**
1. **Backend creates Google OAuth2Client** with client ID
2. **Calls `verifyIdToken()`** which:
   - Contacts Google's servers
   - Verifies the token signature (ensures it's really from Google)
   - Verifies the token hasn't expired
   - Verifies the audience (client ID) matches
   - Verifies the issuer is Google
3. **If verification succeeds**, Google returns the decoded token payload
4. **If verification fails**, an error is thrown

**Security Note:** This verification happens server-side with Google's servers, so the token cannot be forged or tampered with.

---

### **Phase 6: Backend Processes User**

#### 8. Extract User Information from Token

```typescript
const { email, picture } = payload;

if (!email) {
  throw new UnauthorizedError('Email not provided by Google');
}
```

**Token payload typically contains:**
- `email`: User's email address (primary identifier)
- `name`: User's full name
- `picture`: Profile picture URL
- `sub`: Google user ID
- `email_verified`: Whether email is verified by Google
- `iat`, `exp`: Token issue and expiration times

#### 9. Check if User Exists (Login vs Signup)

**For Login (`/api/auth/google`):**
```typescript
// Find user by email
const user = await User.findOne({
  where: { email },
  include: [{ model: Tenant, as: 'tenant' }],
});

if (!user) {
  throw new UnauthorizedError(
    'No account found with this email. Please contact your administrator to create an account.'
  );
}
```

**For Signup (`/api/auth/google/signup`):**
```typescript
// Check if user already exists
const existingUser = await User.findOne({
  where: { email },
});

if (existingUser) {
  throw new AppError(
    'An account with this email already exists. Please log in instead.',
    400
  );
}

// Create new user and tenant
const tenant = await Tenant.create({ /* ... */ });
const user = await User.create({ /* ... */ });
```

#### 10. Update User Profile (Login Only)

```typescript
// Update avatar if Google provided a new one
if (picture && picture !== user.avatarUrl) {
  user.avatarUrl = picture;
}

// Mark email as verified
if (!user.emailVerified) {
  user.emailVerified = true;
}

await user.save();
```

---

### **Phase 7: Backend Generates Application Tokens**

#### 11. Generate JWT Access Token

```typescript
const accessToken = generateAccessToken({
  userId: user.id,
  tenantId: user.tenantId,
  email: user.email,
  role: user.role,
  userType: 'tenant_user',
});
```

**What is an access token?**
- JWT token signed by our backend
- Contains user identification (userId, tenantId, email, role)
- Used for authenticating API requests
- Short-lived (typically expires in 15 minutes to 1 hour)

#### 12. Generate Refresh Token

```typescript
const refreshTokenValue = generateRefreshToken();
const expiresAt = getTokenExpirationDate(7); // 7 days

// Store in database
await RefreshToken.create({
  userId: user.id,
  token: refreshTokenValue,
  expiresAt,
});
```

**What is a refresh token?**
- Long-lived token (7 days)
- Used to get new access tokens when they expire
- Stored in database for security
- Can be revoked (logged out)

---

### **Phase 8: Backend Returns Tokens to Frontend**

#### 13. Backend Sends Response

```typescript
res.json({
  success: true,
  data: {
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      tenantId: user.tenantId,
      avatarUrl: user.avatarUrl,
    },
    accessToken: "...",
    refreshToken: "..."
  }
});
```

---

### **Phase 9: Frontend Stores Tokens and User Data**

#### 14. Frontend Stores in localStorage

**Location:** `coachqa-ui/src/contexts/TenantAuthContext.tsx`

```typescript
const result = await response.json();
const { user: userData, accessToken, refreshToken } = result.data;

// Store in localStorage
localStorage.setItem("tenant.accessToken", accessToken);
localStorage.setItem("tenant.refreshToken", refreshToken);
localStorage.setItem("tenant.user", JSON.stringify(userData));

// Update React state
setUser(userData as TenantUser);

// Navigate to dashboard
navigate("/dashboard");
```

**Storage keys:**
- `tenant.accessToken`: JWT access token for API requests
- `tenant.refreshToken`: Refresh token for getting new access tokens
- `tenant.user`: User profile data (JSON string)

**Note:** Tenant-specific storage keys ensure separation from platform admin sessions.

---

### **Phase 10: User is Authenticated**

#### 15. User Can Now Access Protected Routes

- User data is in React state
- Tokens are in localStorage
- All API requests automatically include the access token
- User is redirected to `/dashboard`

---

## 🔐 Security Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    GOOGLE AUTHENTICATION                    │
└─────────────────────────────────────────────────────────────┘

1. USER CLICKS "Sign in with Google"
   │
   ▼
2. Google OAuth Popup Opens
   │
   ▼
3. User Selects Google Account & Grants Permission
   │
   ▼
4. Google Returns ID Token (JWT) to Frontend
   │   ┌─────────────────────────────┐
   │   │ ID Token contains:          │
   │   │ - email                     │
   │   │ - name                      │
   │   │ - picture                   │
   │   │ - signed by Google          │
   │   └─────────────────────────────┘
   │
   ▼
5. Frontend Sends ID Token to Backend
   │   POST /api/auth/google
   │   { idToken: "eyJhbGci..." }
   │
   ▼
6. Backend Verifies Token with Google Servers
   │   ┌─────────────────────────────┐
   │   │ Verification checks:        │
   │   │ ✓ Signature valid           │
   │   │ ✓ Not expired               │
   │   │ ✓ Audience matches          │
   │   │ ✓ Issuer is Google          │
   │   └─────────────────────────────┘
   │
   ▼
7. Backend Extracts Email from Token
   │
   ▼
8. Backend Checks if User Exists in Database
   │
   ├─► USER EXISTS → Login Flow
   │   │
   │   ├─► Update avatar/email verified
   │   │
   │   ├─► Check account status (must be ACTIVE)
   │   │
   │   └─► Generate JWT tokens
   │
   └─► USER DOESN'T EXIST → Error (login endpoint)
       OR → Signup Flow (signup endpoint)
           │
           ├─► Create new tenant
           ├─► Create new user (admin role)
           └─► Generate JWT tokens

9. Backend Returns Tokens + User Data
   │
   ▼
10. Frontend Stores Tokens in localStorage
    │   ┌─────────────────────────────┐
    │   │ localStorage:               │
    │   │ - tenant.accessToken        │
    │   │ - tenant.refreshToken       │
    │   │ - tenant.user               │
    │   └─────────────────────────────┘
    │
    ▼
11. User is Authenticated
    │   - React state updated
    │   - Redirected to /dashboard
    │   - API requests include token
```

---

## 🔑 Key Concepts Explained

### 1. Google ID Token vs Application Tokens

**Google ID Token:**
- Issued by Google
- Proves user identity to our application
- Short-lived (usually 1 hour)
- Used once to authenticate the user
- Never stored permanently

**Application Access Token:**
- Issued by our backend
- Proves user is authenticated in our system
- Used for all API requests
- Stored in localStorage
- Refreshed using refresh token

**Application Refresh Token:**
- Issued by our backend
- Long-lived (7 days)
- Used to get new access tokens
- Stored in database and localStorage

### 2. Why We Verify Tokens Server-Side

- **Security**: Prevents token forgery
- **Trust**: Google's servers verify the signature
- **Expiration**: Ensures token hasn't expired
- **Audience**: Confirms token is for our application
- **Revocation**: Google can revoke tokens if account is compromised

### 3. Multi-Tenant Isolation

- Each user belongs to a tenant organization
- All squads, users, and data are scoped to tenant
- Tokens include `tenantId` for automatic filtering
- Storage keys are prefixed with `tenant.*` to avoid conflicts

### 4. Email as Primary Identifier

- Email from Google is used as the unique identifier
- Users must have the same email in our system
- Email verification status is tracked
- Email cannot be changed after account creation

---

## 🔄 Login vs Signup Flow

### Login Flow (`/api/auth/google`)

1. User clicks "Sign in with Google"
2. Google returns ID token
3. Backend verifies token
4. Backend looks up user by email
5. **If user exists:**
   - Updates profile (avatar, email verified)
   - Checks account is active
   - Generates tokens
   - Returns user data and tokens
6. **If user doesn't exist:**
   - Returns 401 error
   - User must use signup endpoint instead

### Signup Flow (`/api/auth/google/signup`)

1. User clicks "Sign up with Google"
2. Google returns ID token
3. Backend verifies token
4. Backend checks if user exists by email
5. **If user doesn't exist:**
   - Creates new tenant organization
   - Creates new user account (admin role)
   - Generates tokens
   - Returns user data and tokens
6. **If user already exists:**
   - Returns 400 error
   - User must use login endpoint instead

---

## 🛡️ Security Features

### 1. Token Verification
- Server-side verification with Google
- Cannot be bypassed or forged
- Expiration checking
- Audience validation

### 2. Account Status Checking
- Only ACTIVE accounts can log in
- PENDING or INACTIVE accounts are rejected

### 3. Tenant Isolation
- All operations scoped to tenant
- Cross-tenant access prevented
- Data isolation enforced

### 4. Token Storage
- Access tokens in localStorage (for API calls)
- Refresh tokens in database (for security)
- User data in localStorage (for UI state)

### 5. Email Verification
- Email marked as verified automatically
- Google already verified the email
- No additional verification needed

---

## 📊 Data Flow Summary

```
User Action
    │
    ├─► Google OAuth Provider
    │       │
    │       └─► ID Token (JWT)
    │
    └─► Frontend Application
            │
            ├─► Send ID Token → Backend API
            │
            └─► Backend Processing
                    │
                    ├─► Verify Token with Google ✓
                    │
                    ├─► Extract Email
                    │
                    ├─► Database Lookup/Creation
                    │
                    └─► Generate Application Tokens
                            │
                            └─► Return to Frontend
                                    │
                                    ├─► Store in localStorage
                                    │
                                    └─► Update UI State
                                            │
                                            └─► User Authenticated ✓
```

---

## 🚨 Error Scenarios

### Scenario 1: User Doesn't Exist (Login)
```
User → Google Sign-In → ID Token → Backend
Backend → Check Database → User NOT Found
Response: 401 "No account found with this email"
Frontend: Shows error message
```

### Scenario 2: User Already Exists (Signup)
```
User → Google Sign-Up → ID Token → Backend
Backend → Check Database → User EXISTS
Response: 400 "Account already exists, please log in"
Frontend: Shows error message, suggests login
```

### Scenario 3: Invalid Token
```
User → Google Sign-In → ID Token → Backend
Backend → Verify with Google → INVALID
Response: 401 "Invalid Google token"
Frontend: Shows error message
```

### Scenario 4: Account Not Active
```
User → Google Sign-In → ID Token → Backend
Backend → Verify → User Found → Status Check → INACTIVE/PENDING
Response: 401 "Account is not active"
Frontend: Shows error message
```

---

## 🔧 Configuration

### Required Environment Variables

**Backend:**
```env
GOOGLE_CLIENT_ID=746343245098-72ffk4klhps027k7po4497bjdag4hv07.apps.googleusercontent.com
```

**Frontend:**
```typescript
// Hardcoded in AppProviders.tsx
const GOOGLE_CLIENT_ID = "746343245098-72ffk4klhps027k7po4497bjdag4hv07.apps.googleusercontent.com";
```

**Note:** Both must use the same client ID.

---

## 📝 Code Locations

### Frontend
- **Provider Setup**: `coachqa-ui/src/components/providers/AppProviders.tsx`
- **Login Page**: `coachqa-ui/src/pages/auth/LoginPage.tsx`
- **Signup Page**: `coachqa-ui/src/pages/auth/SignupPage.tsx`
- **Auth Context**: `coachqa-ui/src/contexts/TenantAuthContext.tsx`

### Backend
- **Routes**: `coachqa-backend/src/routes/auth.routes.ts`
- **Controller**: `coachqa-backend/src/controllers/auth.controller.ts`
- **Service**: `coachqa-backend/src/services/auth.service.ts`
- **Token Service**: `coachqa-backend/src/services/token.service.ts`

---

## 🎯 Summary

Google authentication works by:

1. **User authenticates with Google** → Gets ID token
2. **Frontend sends token to backend** → `/api/auth/google` or `/api/auth/google/signup`
3. **Backend verifies token with Google** → Ensures authenticity
4. **Backend checks/creates user** → Based on email from token
5. **Backend generates application tokens** → JWT access + refresh tokens
6. **Frontend stores tokens** → localStorage for session management
7. **User is authenticated** → Can access protected routes and APIs

The key security feature is that the Google ID token is verified server-side with Google's servers, ensuring the user's identity is authentic before granting access to the application.

