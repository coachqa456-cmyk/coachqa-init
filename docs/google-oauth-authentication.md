# Google OAuth Authentication

This document describes the Google OAuth authentication implementation for the QEnabler platform.

## Overview

The platform supports Google OAuth authentication for both **login** (existing users) and **signup** (new users). The implementation uses Google's OAuth 2.0 ID token verification to authenticate users.

## Endpoints

### 1. Google Login (Existing Users)

**Endpoint:** `POST /api/auth/google`

**Purpose:** Authenticate an existing user using Google OAuth. The user's email must already exist in the system.

**Request Body:**
```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEyMzQ1Njc4OTA..."
}
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "name": "John Doe",
      "email": "john@example.com",
      "role": "admin",
      "roleId": "uuid-or-null",
      "tenantId": "uuid",
      "avatarUrl": "https://lh3.googleusercontent.com/..."
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh-token-value"
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "error": {
    "message": "No account found with this email. Please contact your administrator to create an account.",
    "statusCode": 401
  }
}
```

**Behavior:**
- Verifies the Google ID token
- Checks if user exists in the database by email
- If user doesn't exist, returns 401 error
- If user exists and account is active:
  - Updates avatar URL if provided by Google
  - Marks email as verified
  - Generates access and refresh tokens
  - Returns user data and tokens

---

### 2. Google Signup (New Users)

**Endpoint:** `POST /api/auth/google/signup`

**Purpose:** Create a new user account and tenant organization using Google OAuth.

**Request Body:**
```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEyMzQ1Njc4OTA..."
}
```

**Success Response (201):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "name": "Jane Doe",
      "email": "jane@example.com",
      "role": "admin",
      "roleId": null,
      "tenantId": "uuid",
      "avatarUrl": "https://lh3.googleusercontent.com/..."
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh-token-value"
  }
}
```

**Error Response (400) - User Already Exists:**
```json
{
  "success": false,
  "error": {
    "message": "An account with this email already exists. Please log in instead.",
    "statusCode": 400
  }
}
```

**Behavior:**
- Verifies the Google ID token
- Checks if user already exists in the database by email
- If user exists, returns 400 error
- If user doesn't exist:
  - Creates a new tenant organization with temporary name
  - Creates a new user account with admin role
  - Sets email as verified
  - Stores avatar URL from Google profile
  - Generates access and refresh tokens
  - Returns user data and tokens

---

## Frontend Implementation

### Login Page (`/login`)

The login page uses the `GoogleLogin` component from `@react-oauth/google`:

```typescript
import { GoogleLogin } from '@react-oauth/google';

<GoogleLogin
  onSuccess={handleGoogleSuccess}
  onError={handleGoogleError}
  useOneTap
/>
```

**Handler:**
```typescript
const handleGoogleSuccess = async (credentialResponse: any) => {
  try {
    setIsLoading(true);
    setError('');
    
    if (!credentialResponse.credential) {
      throw new Error('No credential received from Google');
    }

    await loginWithGoogle(credentialResponse.credential);
    // Navigation is handled by the login function in TenantAuthContext
  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : 'Google login failed';
    setError(errorMessage);
    console.error('Google login failed:', err);
  } finally {
    setIsLoading(false);
  }
};
```

### Signup Page (`/signup`)

The signup page also uses the `GoogleLogin` component:

```typescript
<GoogleLogin
  onSuccess={handleGoogleSuccess}
  onError={handleGoogleError}
  useOneTap={false}
/>
```

**Handler:**
```typescript
const handleGoogleSuccess = async (credentialResponse: any) => {
  try {
    setIsLoading(true);
    setError('');
    
    if (!credentialResponse.credential) {
      throw new Error('No credential received from Google');
    }

    await signupWithGoogle(credentialResponse.credential);
    // Navigation is handled by the signupWithGoogle function in TenantAuthContext
  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : 'Google signup failed';
    setError(errorMessage);
    console.error('Google signup failed:', err);
  } finally {
    setIsLoading(false);
  }
};
```

---

## Backend Implementation

### Configuration

The Google OAuth client is configured in `auth.service.ts`:

```typescript
import { OAuth2Client } from 'google-auth-library';

const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID || 'default-client-id';
const client = new OAuth2Client(GOOGLE_CLIENT_ID);
```

**Environment Variable:**
```env
GOOGLE_CLIENT_ID=746343245098-72ffk4klhps027k7po4497bjdag4hv07.apps.googleusercontent.com
```

### Token Verification

Both endpoints verify the Google ID token:

```typescript
const ticket = await client.verifyIdToken({
  idToken: data.idToken,
  audience: GOOGLE_CLIENT_ID,
});

const payload = ticket.getPayload();
const { email, name, picture } = payload;
```

### Service Functions

#### `loginWithGoogle` (Auth Service)

- Verifies Google ID token
- Finds user by email
- Validates user exists and account is active
- Updates user profile (avatar, email verification)
- Generates tokens
- Returns user data and tokens

#### `signupWithGoogle` (Auth Service)

- Verifies Google ID token
- Checks if user already exists
- Creates new tenant organization
- Creates new user account (admin role)
- Generates tokens
- Returns user data and tokens

---

## User Flow

### Login Flow

1. User clicks "Sign in with Google" on login page
2. Google OAuth popup appears
3. User selects Google account and grants permissions
4. Frontend receives ID token from Google
5. Frontend sends ID token to `/api/auth/google`
6. Backend verifies token and checks if user exists
7. If user exists:
   - Backend returns tokens and user data
   - Frontend stores tokens in localStorage
   - User is redirected to dashboard
8. If user doesn't exist:
   - Backend returns 401 error
   - Frontend displays error message
   - User is directed to signup page

### Signup Flow

1. User clicks "Sign up with Google" on signup page
2. Google OAuth popup appears
3. User selects Google account and grants permissions
4. Frontend receives ID token from Google
5. Frontend sends ID token to `/api/auth/google/signup`
6. Backend verifies token and checks if user exists
7. If user doesn't exist:
   - Backend creates new tenant and user
   - Backend returns tokens and user data
   - Frontend stores tokens in localStorage
   - User is redirected to dashboard
8. If user already exists:
   - Backend returns 400 error
   - Frontend displays error message
   - User is directed to login page

---

## Security Considerations

1. **Token Verification:** All Google ID tokens are verified server-side using Google's OAuth2Client
2. **Email Validation:** User email is extracted from the verified token payload
3. **Account Status:** Only active user accounts can authenticate
4. **Unique Emails:** Email addresses must be unique in the system
5. **Token Storage:** Access and refresh tokens are stored securely in localStorage (consider httpOnly cookies for production)

---

## Error Handling

### Common Errors

| Status Code | Error Message | Description |
|------------|---------------|-------------|
| 400 | "An account with this email already exists. Please log in instead." | User tried to signup with an existing email |
| 401 | "No account found with this email. Please contact your administrator to create an account." | User tried to login with non-existent email |
| 401 | "Invalid Google token" | Token verification failed |
| 401 | "Email not provided by Google" | Token payload missing email |
| 401 | "Account is not active" | User account is inactive or pending |

---

## Swagger Documentation

Complete API documentation is available in Swagger UI at:
- **Development:** `http://localhost:9002/api-docs`
- **Production:** `https://api.QEnabler.com/api-docs`

The Swagger documentation includes:
- Request/response schemas
- Example payloads
- Error responses
- Authentication requirements

---

## Testing

### Testing Google Login

1. Ensure a user exists in the database with a valid email
2. Navigate to `/login`
3. Click "Sign in with Google"
4. Select a Google account matching the existing user's email
5. Verify successful login and redirect to dashboard

### Testing Google Signup

1. Ensure no user exists with the test email
2. Navigate to `/signup`
3. Click "Sign up with Google"
4. Select a Google account with a new email
5. Verify new tenant and user creation
6. Verify successful login and redirect to dashboard

### Testing Error Cases

1. **Existing User on Signup:**
   - Try to signup with an email that already exists
   - Verify 400 error with appropriate message

2. **Non-existent User on Login:**
   - Try to login with an email that doesn't exist
   - Verify 401 error with appropriate message

---

## Future Enhancements

1. **Email Verification:** Implement additional email verification steps if needed
2. **Account Linking:** Allow users to link Google account to existing email/password account
3. **Profile Sync:** Periodically sync profile information (name, avatar) from Google
4. **Multiple OAuth Providers:** Support additional OAuth providers (Microsoft, GitHub, etc.)
5. **Token Refresh:** Implement automatic token refresh before expiration
6. **Session Management:** Add session timeout and management features

---

## Related Documentation

- [System Overview](./system-overview.md)
- [API Integration Guide](./API-INTEGRATION.md)
- [Authentication Flow](./invite-user-flow.md)

