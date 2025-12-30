# Invite User Flow - Complete Documentation

## Overview
The invite user functionality allows admins and managers to send invitations to new users. Users are created only when they accept the invitation.

## Location & Flow

### 1. Frontend - User Interface

#### Location: `coachqa-ui/src/pages/users/UserManagement.tsx`

**Invite Button:**
- **Line 362-363**: "Invite User" button appears on the Users tab
- **Line 365-372**: "Invite User" button also appears on the Invitations tab
- **Visibility**: Only visible to users with `canInvite` permission (admins and managers)

**Invite Dialog:**
- **Lines 539-620**: The invite user dialog form
- **Fields**:
  - Email (required, validated)
  - Role (required, dropdown: admin, qe, manager, developer, executive)
  - Squads (optional, multi-select)

**Handler Functions:**
- **Line 211-214**: `handleOpenInviteDialog()` - Opens the dialog and resets form
- **Line 216-248**: `handleInviteUser()` - Validates and submits the invitation

**Form State:**
- **Line 120-124**: `inviteForm` state stores:
  ```typescript
  {
    email: '',
    role: 'developer',
    squadIds: []
  }
  ```

### 2. Frontend - API Call

#### Location: `coachqa-ui/src/utils/api.ts`

**API Function:**
- **Line 502-503**: `inviteUser()` function
  ```typescript
  export const inviteUser = (payload: InviteUserPayload): Promise<Response> =>
    apiPost('/api/users/invite', payload);
  ```

**Payload Interface:**
- **Lines 460-464**: `InviteUserPayload` interface
  ```typescript
  export interface InviteUserPayload {
    email: string;
    role: 'admin' | 'qe' | 'manager' | 'developer' | 'executive';
    squadIds?: string[];
  }
  ```

### 3. Backend - API Route

#### Location: `coachqa-backend/src/routes/users.routes.ts`

**Route Definition:**
- **Line 139**: `POST /api/users/invite`
- **Authentication**: Required (Bearer token)
- **Authorization**: Only admins and managers can access

**Swagger Documentation:**
- **Lines 119-138**: API documentation for the invite endpoint

### 4. Backend - Controller

#### Location: `coachqa-backend/src/controllers/users.controller.ts`

**Controller Function:**
- **Lines 128-153**: `inviteUser()` controller
- **Steps**:
  1. Extracts `tenantId` from request (from auth middleware)
  2. Extracts `invitedBy` from authenticated user
  3. Extracts `email`, `role`, `squadIds` from request body
  4. **Authorization Check**: Verifies user is admin or manager
  5. Calls `userService.inviteUser()` with data
  6. Returns success response with invitation data

### 5. Backend - Service Layer

#### Location: `coachqa-backend/src/services/user.service.ts`

**Service Function:**
- **Lines 160-215**: `inviteUser()` service function
- **Process**:

  1. **Validation Checks**:
     - Checks if user with email already exists → throws error if exists
     - Checks for existing pending invitation → throws error if found

  2. **Create Invitation**:
     - Generates unique token using `uuidv4()`
     - Sets expiration date (7 days from now)
     - Creates `UserInvitation` record with:
       - `tenantId`
       - `email`
       - `role`
       - `invitedBy` (user ID who sent invitation)
       - `token` (unique UUID)
       - `expiresAt` (7 days)
       - `squadIds` (array of squad IDs)
       - `status: PENDING`

  3. **Send Email**:
     - Fetches tenant name for email personalization
     - Calls `sendInvitationEmail()` with email, token, and tenant name
     - Email sending errors are logged but don't fail the invitation creation

  4. **Return**: Returns the created invitation object

### 6. Backend - Email Service

#### Location: `coachqa-backend/src/services/email.service.ts`

**Email Function:**
- **Lines 37-108**: `sendInvitationEmail()` function
- **Process**:

  1. **Build Invitation Link**:
     - Gets app base URL from `APP_URL` env var (default: `http://localhost:9001`)
     - Creates link: `${baseUrl}/accept-invitation/${token}`

  2. **Email Content**:
     - **Subject**: "You have been invited to join {tenantName} on CoachQA"
     - **Text Body**: Plain text version with invitation link
     - **HTML Body**: Formatted HTML email with button and link
     - **Expiration**: Mentions 7-day expiration

  3. **Send Email**:
     - Uses nodemailer transporter (if configured)
     - Falls back to logging if SMTP not configured
     - Errors are logged but don't throw (invitation still created)

## Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ 1. FRONTEND - User Management Page                          │
│    Location: UserManagement.tsx                             │
│    - Admin/Manager clicks "Invite User" button              │
│    - Dialog opens with form (email, role, squads)           │
│    - User fills form and clicks "Send Invitation"           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. FRONTEND - API Call                                      │
│    Location: api.ts                                         │
│    - Calls inviteUser(inviteForm)                           │
│    - POST /api/users/invite                                 │
│    - Includes auth token in header                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. BACKEND - Route Handler                                  │
│    Location: users.routes.ts                                │
│    - Route: POST /api/users/invite                          │
│    - Requires authentication                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. BACKEND - Controller                                     │
│    Location: users.controller.ts                            │
│    - Validates user is admin/manager                        │
│    - Extracts tenantId, invitedBy, email, role, squadIds    │
│    - Calls userService.inviteUser()                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. BACKEND - Service Layer                                  │
│    Location: user.service.ts                                │
│    - Validates email doesn't exist                          │
│    - Validates no pending invitation                        │
│    - Generates UUID token                                   │
│    - Sets expiration (7 days)                              │
│    - Creates UserInvitation record                          │
│    - Calls sendInvitationEmail()                            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. BACKEND - Email Service                                  │
│    Location: email.service.ts                               │
│    - Builds invitation link                                 │
│    - Creates email content (text + HTML)                     │
│    - Sends email via SMTP                                  │
│    - Logs if SMTP not configured                            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. USER RECEIVES EMAIL                                      │
│    - Email contains invitation link                         │
│    - Link: {APP_URL}/accept-invitation/{token}              │
│    - User clicks link                                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 8. FRONTEND - Acceptance Page                               │
│    Location: AcceptInvitationPage.tsx                        │
│    - User enters name and password                          │
│    - Submits form                                           │
│    - Calls POST /api/auth/accept-invitation/{token}         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 9. BACKEND - Create User Account                            │
│    Location: user.service.ts (acceptInvitation)             │
│    - Validates invitation token                             │
│    - Checks invitation is pending and not expired           │
│    - Creates User account                                   │
│    - Assigns user to squads                                 │
│    - Marks invitation as ACCEPTED                           │
└─────────────────────────────────────────────────────────────┘
```

## Key Files Summary

| Component | File Path | Key Functionality |
|-----------|-----------|-------------------|
| **UI Component** | `coachqa-ui/src/pages/users/UserManagement.tsx` | Invite button, dialog form, form handling |
| **API Helper** | `coachqa-ui/src/utils/api.ts` | `inviteUser()` function |
| **API Route** | `coachqa-backend/src/routes/users.routes.ts` | `POST /api/users/invite` route |
| **Controller** | `coachqa-backend/src/controllers/users.controller.ts` | `inviteUser()` controller |
| **Service** | `coachqa-backend/src/services/user.service.ts` | `inviteUser()` service logic |
| **Email Service** | `coachqa-backend/src/services/email.service.ts` | `sendInvitationEmail()` function |
| **Acceptance Page** | `coachqa-ui/src/pages/auth/AcceptInvitationPage.tsx` | User acceptance form |

## Data Flow

### Request Payload
```json
{
  "email": "user@example.com",
  "role": "developer",
  "squadIds": ["uuid-1", "uuid-2"]  // optional
}
```

### Invitation Record Created
```typescript
{
  id: "uuid",
  tenantId: "tenant-uuid",
  email: "user@example.com",
  role: "developer",
  invitedBy: "admin-user-uuid",
  token: "unique-uuid-token",
  expiresAt: "2024-01-15T00:00:00Z",  // 7 days from now
  squadIds: ["uuid-1", "uuid-2"],
  status: "pending",
  createdAt: "2024-01-08T00:00:00Z"
}
```

### Email Sent
- **To**: `user@example.com`
- **Subject**: "You have been invited to join {tenantName} on CoachQA"
- **Link**: `{APP_URL}/accept-invitation/{token}`
- **Expiration**: 7 days

## Permissions

- **Who can invite**: Admins and Managers only
- **Who can see invitations**: All authenticated users (for viewing)
- **Who can resend/cancel**: Admins and Managers

## Error Handling

1. **Email already exists**: Returns 409 error
2. **Pending invitation exists**: Returns 409 error
3. **Invalid email format**: Frontend validation prevents submission
4. **Unauthorized user**: Returns 403 Forbidden
5. **Email send failure**: Logged but doesn't fail invitation creation

## Environment Variables

Required for email functionality:
- `SMTP_HOST` - SMTP server hostname
- `SMTP_PORT` - SMTP server port
- `SMTP_USER` - SMTP username
- `SMTP_PASS` - SMTP password
- `EMAIL_FROM` - From email address
- `APP_URL` - Frontend application URL (for invitation links)

