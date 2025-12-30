# Role-Based Access Control Implementation

## Overview
This document describes the role-based access control (RBAC) system implemented for the CoachQA application. The system restricts module access and sidebar menu items based on user roles.

## User Roles
The system supports the following tenant user roles:
- **admin**: Full access to all modules
- **qe**: Quality Engineer - Access to quality-related modules
- **manager**: Manager - Access to management and reporting modules
- **developer**: Developer - Access to development and testing modules
- **executive**: Executive - View-only access to high-level reporting modules

## Module Permissions

### All Roles (admin, qe, manager, developer, executive)
- Dashboard (`/dashboard`)
- Profile (`/dashboard/profile`)

### Admin Only
- Users (`/dashboard/users`)
- Custom Menus (`/dashboard/custom-menus`)
- Roles (`/dashboard/roles`)

### Admin, Manager, Executive
- Squads (`/dashboard/squads`)
- Coaching Tracker (`/dashboard/coaching-tracker`)
- Quality Scorecard (`/dashboard/quality-scorecard`)
- Maturity Ladder (`/dashboard/maturity-ladder`)
- Impact Timeline (`/dashboard/impact-timeline`)

### Admin, QE, Manager, Executive
- Coaching Tracker (`/dashboard/coaching-tracker`)
- Quality Scorecard (`/dashboard/quality-scorecard`)
- Maturity Ladder (`/dashboard/maturity-ladder`)

### Admin, QE, Manager, Developer
- Feedback Form (`/dashboard/feedback-form`)
- Enablement Hub (`/dashboard/enablement-hub`)
- Change Tracker (`/dashboard/change-tracker`)
- Career Framework (`/dashboard/career-framework`)

### Admin, QE, Developer
- Test Logger (`/dashboard/test-logger`)
- Test Debt Register (`/dashboard/test-debt`)

## Implementation Details

### 1. Access Denied Page (`src/pages/AccessDenied.tsx`)
- Displays when a user tries to access a module they don't have permission for
- Shows the user's current role
- Provides navigation back to dashboard or previous page

### 2. Role Permissions Utility (`src/utils/rolePermissions.ts`)
- Centralized mapping of module paths to allowed roles
- Helper functions:
  - `hasModuleAccess(role, modulePath)`: Checks if a role has access to a module
  - `getAccessibleModules(role)`: Returns all accessible modules for a role

### 3. Role Protected Route (`src/components/auth/RoleProtectedRoute.tsx`)
- Wraps protected routes to check role-based permissions
- Shows AccessDenied page if user doesn't have permission
- Redirects to login if user is not authenticated
- Platform admins bypass tenant role checks

### 4. Updated Sidebar (`src/components/layout/Sidebar.tsx`)
- Filters menu items based on user's role permissions
- Only shows modules the user has access to
- Uses `hasModuleAccess` from rolePermissions utility

### 5. Updated Routes (`src/App.tsx`)
- All dashboard module routes wrapped with `RoleProtectedRoute`
- Each route specifies its `modulePath` for permission checking

## Testing Guide

### Test with Different Roles

1. **Admin User**
   - Should see all menu items
   - Should be able to access all modules
   - Test: Login as admin, verify all sidebar items visible

2. **QE User**
   - Should see: Dashboard, Coaching Tracker, Quality Scorecard, Feedback Form, Maturity Ladder, Enablement Hub, Test Logger, Test Debt Register, Change Tracker, Career Framework
   - Should NOT see: Users, Squads, Impact Timeline, Custom Menus, Roles
   - Test: Login as QE, verify sidebar items, try accessing restricted modules (should see Access Denied)

3. **Manager User**
   - Should see: Dashboard, Squads, Coaching Tracker, Quality Scorecard, Feedback Form, Maturity Ladder, Enablement Hub, Impact Timeline, Change Tracker, Career Framework
   - Should NOT see: Users, Test Logger, Test Debt Register, Custom Menus, Roles
   - Test: Login as manager, verify sidebar items, try accessing restricted modules

4. **Developer User**
   - Should see: Dashboard, Coaching Tracker, Quality Scorecard, Feedback Form, Maturity Ladder, Enablement Hub, Test Logger, Test Debt Register, Change Tracker, Career Framework
   - Should NOT see: Users, Squads, Impact Timeline, Custom Menus, Roles
   - Test: Login as developer, verify sidebar items, try accessing restricted modules

5. **Executive User**
   - Should see: Dashboard, Squads, Coaching Tracker, Quality Scorecard, Maturity Ladder, Impact Timeline
   - Should NOT see: Users, Feedback Form, Enablement Hub, Test Logger, Test Debt Register, Change Tracker, Career Framework, Custom Menus, Roles
   - Test: Login as executive, verify sidebar items, try accessing restricted modules

### Testing Steps

1. **Sidebar Menu Filtering**
   - Login with each role
   - Verify only allowed menu items appear in sidebar
   - Verify restricted items are hidden

2. **Direct URL Access**
   - Login with a restricted role (e.g., developer)
   - Try accessing `/dashboard/users` directly in browser
   - Should see Access Denied page

3. **Navigation Protection**
   - Login with restricted role
   - Try clicking on a restricted module link (if visible)
   - Should see Access Denied page

4. **Access Denied Page**
   - Verify Access Denied page displays correctly
   - Verify "Go to Dashboard" button works
   - Verify "Go Back" button works
   - Verify current role is displayed

## Files Modified/Created

### New Files
- `src/pages/AccessDenied.tsx` - Access denied page component
- `src/utils/rolePermissions.ts` - Role permissions mapping and utilities
- `src/components/auth/RoleProtectedRoute.tsx` - Route protection component

### Modified Files
- `src/components/layout/Sidebar.tsx` - Updated to filter by role permissions
- `src/App.tsx` - Updated routes to use RoleProtectedRoute

## Notes

- Platform admins have full access and bypass tenant role checks
- The system uses a centralized permission mapping for easy maintenance
- All permission checks are done client-side; backend should also enforce these permissions
- Role permissions can be easily modified in `src/utils/rolePermissions.ts`







