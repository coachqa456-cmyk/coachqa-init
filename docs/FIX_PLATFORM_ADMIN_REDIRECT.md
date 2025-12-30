# Fix: Platform Admin Session Expiration Redirect

## Issue
When a platform admin's session expires (401 Unauthorized), the system was redirecting to the tenant login page (`/login`) instead of the platform admin login page (`/admin/login`).

## Root Cause
The `handleUnauthorized` function in `coachqa-ui/src/utils/api.ts` was calling `getUserType()` to determine which login page to redirect to. However, `getUserType()` relies on reading from localStorage, and the function was checking the user type AFTER potentially clearing storage or when storage might already be empty.

The `getUserType()` function uses `getStorageKeys()` which checks the current path, but if the storage was already cleared or the check happened at the wrong time, it could default to tenant storage keys.

## Solution
Updated `handleUnauthorized` to check the current path (`window.location.pathname`) BEFORE clearing storage. This ensures that:

1. If the user is on any `/admin/*` route, they are redirected to `/admin/login`
2. Otherwise, they are redirected to `/login`
3. The stored `userType` is used as a fallback if path checking isn't sufficient

## Changes Made

### File: `coachqa-ui/src/utils/api.ts`

**Before:**
```typescript
const handleUnauthorized = () => {
  const userType = getUserType();
  
  // Clear all storage
  Object.values(TENANT_STORAGE_KEYS).forEach((key) => localStorage.removeItem(key));
  Object.values(PLATFORM_STORAGE_KEYS).forEach((key) => localStorage.removeItem(key));
  
  // Call global logout handler if available
  if (globalLogoutHandler) {
    globalLogoutHandler();
  }
  
  // Navigate to appropriate login page
  if (userType === 'platform_admin') {
    window.location.href = '/admin/login';
  } else {
    window.location.href = '/login';
  }
};
```

**After:**
```typescript
const handleUnauthorized = () => {
  // Check current path BEFORE clearing storage to determine redirect target
  const isAdminPath = window.location.pathname.startsWith('/admin');
  
  // Try to get user type from storage before clearing (fallback)
  const userType = getUserType();
  
  // Clear all storage
  Object.values(TENANT_STORAGE_KEYS).forEach((key) => localStorage.removeItem(key));
  Object.values(PLATFORM_STORAGE_KEYS).forEach((key) => localStorage.removeItem(key));
  
  // Call global logout handler if available
  if (globalLogoutHandler) {
    globalLogoutHandler();
  }
  
  // Navigate to appropriate login page based on current path or user type
  // Priority: current path > stored user type
  if (isAdminPath || userType === 'platform_admin') {
    window.location.href = '/admin/login';
  } else {
    window.location.href = '/login';
  }
};
```

## How It Works

1. **Path Check First**: The function checks if the current URL path starts with `/admin`
2. **User Type Fallback**: It also tries to get the user type from storage (as a fallback)
3. **Clear Storage**: All storage is cleared (both tenant and platform admin)
4. **Redirect Logic**: 
   - If on admin path OR user type is platform_admin → redirect to `/admin/login`
   - Otherwise → redirect to `/login`

## Testing

To verify the fix works:

1. **As Platform Admin:**
   - Log in as platform admin
   - Navigate to any `/admin/*` route (e.g., `/admin/roles`)
   - Simulate session expiration (e.g., manually expire token in backend or wait for token expiry)
   - Make an API call that returns 401
   - Verify redirect goes to `/admin/login` (not `/login`)

2. **As Tenant User:**
   - Log in as tenant user
   - Navigate to any `/dashboard/*` route
   - Simulate session expiration
   - Make an API call that returns 401
   - Verify redirect goes to `/login` (not `/admin/login`)

## Related Files

- `coachqa-ui/src/utils/api.ts` - Main fix location
- `coachqa-ui/src/contexts/AuthContext.tsx` - Logout function (already correct)
- `coachqa-ui/src/contexts/PlatformAdminAuthContext.tsx` - Platform admin logout (already correct)

## Notes

- The logout functions in auth contexts already handle redirects correctly
- This fix specifically addresses the 401 Unauthorized error handling in API calls
- The fix uses path-based detection as the primary method, with user type as fallback
- This ensures reliability even if storage is corrupted or partially cleared








