---
name: Test Debt Register Integration
overview: "Complete backend integration for Test Debt Register: add API functions, replace mock data with real API calls, implement CRUD operations, add permission-based access control, and improve UI/UX with proper error handling and validation."
todos:
  - id: add-api-functions
    content: Add test debt API functions to api.ts (fetchTestDebtItems, createTestDebtItem, updateTestDebtItem, deleteTestDebtItem, updateTestDebtStatus) with TypeScript interfaces
    status: pending
  - id: update-component-state
    content: Replace mock data with useState, add loading/error states, and implement loadItems() function with useEffect
    status: pending
    dependencies:
      - add-api-functions
  - id: add-data-transformation
    content: Create transformTestDebtItemForDisplay() function to map backend format to frontend display format with enum conversions, use squadId relationship (not area field), exclude effort field
    status: pending
    dependencies:
      - add-api-functions
  - id: implement-crud
    content: Implement handleSaveItem(), handleDeleteItem() with confirmation dialog, and integrate with form dialog
    status: pending
    dependencies:
      - update-component-state
      - add-data-transformation
  - id: update-form-dialog
    content: Make form fields controlled, replace "Area" with "Squad" dropdown (required), remove "Effort" field, add validation, fetch squads/users for dropdowns, handle form submission
    status: pending
    dependencies:
      - add-api-functions
  - id: add-permissions
    content: Add permission-based access control using useAuth() hook to show/hide create/edit/delete buttons
    status: pending
    dependencies:
      - update-component-state
  - id: add-notifications
    content: Add Snackbar notifications for success/error messages and improve error handling throughout
    status: pending
    dependencies:
      - implement-crud
  - id: update-filters
    content: Update filtering to work with real data - replace "Area" filter with "Squad" filter dropdown, remove "Effort" from sorting, maintain existing filter/sort functionality for priority and status
    status: pending
    dependencies:
      - update-component-state
---

# Test

Debt Register - Complete Backend Integration

## Overview

The Test Debt Register currently uses mock data. This plan implements full backend integration with API calls, CRUD operations, permission-based access control, and improved UI/UX.

## Current State

- Frontend: [`coachqa-ui/src/pages/test-debt/TestDebtRegister.tsx`](coachqa-ui/src/pages/test-debt/TestDebtRegister.tsx) uses mock data
- Backend: API endpoints exist at `/api/test-debt/items` with full CRUD support
- Backend model: [`coachqa-backend/src/models/TestDebtItem.ts`](coachqa-backend/src/models/TestDebtItem.ts) includes relationships to Squad, User (assignee/creator)

## Implementation Plan

### 1. Add API Functions (`coachqa-ui/src/utils/api.ts`)

Add test debt API functions following the pattern used for coaching sessions:

- `fetchTestDebtItems(squadId?: string, status?: string)` - GET `/api/test-debt/items`
- `fetchTestDebtItemById(id: string)` - GET `/api/test-debt/items/:id`
- `createTestDebtItem(payload)` - POST `/api/test-debt/items`
- `updateTestDebtItem(id, payload)` - PATCH `/api/test-debt/items/:id`
- `deleteTestDebtItem(id)` - DELETE `/api/test-debt/items/:id`
- `updateTestDebtStatus(id, status)` - PATCH `/api/test-debt/items/:id/status`

Define TypeScript interfaces:

- `BackendTestDebtItem` (matches backend model with relationships - includes area and effort fields from backend)
- `TestDebtItem` (frontend display format - uses squadId/squad.name instead of area, excludes effort field)
- `CreateTestDebtItemPayload` / `UpdateTestDebtItemPayload` (uses squadId instead of area, excludes effort)

### 2. Update TestDebtRegister Component

Transform the component to use real API calls:**Data Loading:**

- Replace `mockTestDebtItems` with `useState` initialized as empty array
- Add `useEffect` to load items on mount
- Add loading state with `CircularProgress`
- Add error state with `Alert` component

**Data Transformation:**

- Create `transformTestDebtItemForDisplay()` function similar to `transformSessionForDisplay()` in CoachingTracker
- Map backend enums (lowercase) to frontend display format (Title Case)
- Handle relationships: `squad.name` (use squadId relationship, not area field), `assignee.name`, `creator.name`
- Format dates properly
- Exclude `effort` field from frontend interface (not displayed or used)

**CRUD Operations:**

- `loadItems()` - Fetch all items with optional squad/status filters
- `handleSaveItem()` - Create or update item via API
- `handleDeleteItem()` - Delete with confirmation dialog
- `handleStatusUpdate()` - Quick status update (if needed)

**Form Dialog:**

- Make form fields controlled components with state
- Add form validation (required fields: title, description, squadId, priority, impact, status)
- Replace "Area" dropdown with "Squad" dropdown (required field, use squadId)
- Remove "Effort" field from form completely
- Fetch squads and users for dropdowns (use `fetchSquads()` and `fetchAllUsers()` from api.ts)
- Handle form submission with proper error handling
- Show success/error notifications using Snackbar

**Permission-Based Access:**

- Check user permissions using `useAuth()` hook
- Hide/show create/edit/delete buttons based on permissions (`testDebt.create`, `testDebt.edit`, `testDebt.delete`)
- Similar pattern to CoachingTracker's `isAdmin` check

**UI Improvements:**

- Update table columns: Replace "Area" column with "Squad" column (display squad.name), remove "Effort" column
- Add loading spinner during API calls
- Add error alerts for failed operations
- Add success notifications for successful operations
- Improve delete confirmation dialog
- Add view details dialog (optional, similar to CoachingTracker)

### 3. Enum Mapping and Field Changes

Map backend enums to frontend display:

- `Priority`: `'low' | 'medium' | 'high' | 'critical'` → `'Low' | 'Medium' | 'High' | 'Critical'`
- `TestDebtStatus`: `'open' | 'in_progress' | 'resolved' | 'deferred'` → `'Open' | 'In Progress' | 'Resolved' | 'Deferred'`

**Field Changes:**

- Replace "Area" field with "Squad" dropdown - use `squadId` relationship instead of `area` string field
- Remove "Effort" field completely from UI (backend may still have it, but won't be used/displayed)

### 4. Error Handling

- Use `apiCall()` wrapper for consistent error handling
- Display user-friendly error messages
- Handle network errors gracefully
- Show validation errors from backend

### 5. Filtering and Sorting

- Keep existing filter functionality (priority, status)
- Replace "Area" filter with "Squad" filter dropdown (fetch squads from API, filter by squadId)
- Remove "Effort" from sorting options
- Maintain sorting functionality for remaining fields (priority, status, dateUpdated, etc.)
- Update filters to work with real data

## Files to Modify

1. [`coachqa-ui/src/utils/api.ts`](coachqa-ui/src/utils/api.ts) - Add test debt API functions and types
2. [`coachqa-ui/src/pages/test-debt/TestDebtRegister.tsx`](coachqa-ui/src/pages/test-debt/TestDebtRegister.tsx) - Complete rewrite to use API calls

## Dependencies

- Uses existing `apiCall`, `apiGet`, `apiPost`, `apiPatch`, `apiDelete` utilities
- Uses `useAuth()` from `contexts/useAuth`
- Uses `fetchSquads()` and `fetchAllUsers()` for dropdown data
- Follows patterns from `CoachingTracker.tsx` and `AddCoachingSessionDialog.tsx`

## Testing Considerations

- Test with different user roles and permissions
- Test CRUD operations
- Test filtering and sorting