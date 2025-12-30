# Squad Management

This document describes how Squad Management works in the CoachQA platform. Squads are teams or groups within an organization that can be assigned Quality Engineers (QEs) and members.

## Table of Contents

1. [Overview](#overview)
2. [Core Concepts](#core-concepts)
3. [Database Schema](#database-schema)
4. [User Interface](#user-interface)
5. [API Endpoints](#api-endpoints)
6. [User Workflows](#user-workflows)
7. [Features](#features)
8. [Integration with Other Modules](#integration-with-other-modules)

---

## Overview

Squad Management allows administrators to:
- Create and organize squads (teams) within their tenant organization
- Assign Quality Engineers (QEs) to squads
- Add and remove members from squads
- Track squad status (active, inactive, archived)
- Organize squads by tribes (optional grouping)

Squads are a fundamental organizational unit in the platform and are used across multiple modules for tracking quality metrics, coaching sessions, feedback, and more.

---

## Core Concepts

### Squad
A **Squad** represents a team or group within a tenant organization. Each squad has:
- **Name** (required): Unique identifier for the squad
- **Tribe** (optional): Organizational grouping (e.g., "Platform Tribe", "Product Tribe")
- **Description** (optional): Additional information about the squad
- **Assigned QE** (optional): Quality Engineer responsible for the squad
- **Status**: `active` or `archived`
- **Members**: Users who belong to the squad
- **Tenant ID**: Links the squad to a specific tenant organization

### Squad Member
A **Squad Member** is a user who belongs to a squad. Members can have:
- **Role in Squad** (optional): Their role within the squad (e.g., "Developer", "Product Owner", "Designer")
- **User ID**: Reference to the user account
- **Squad ID**: Reference to the squad

### Quality Engineer (QE) Assignment
Each squad can have one assigned QE who is responsible for:
- Conducting coaching sessions
- Collecting feedback
- Tracking quality metrics
- Providing quality enablement

The assigned QE must be a user within the same tenant.

---

## Database Schema

### Squad Table

```sql
CREATE TABLE squads (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  name VARCHAR NOT NULL,
  tribe VARCHAR,
  description TEXT,
  assigned_qe_id UUID REFERENCES users(id),
  status VARCHAR NOT NULL DEFAULT 'active', -- 'active', 'archived'
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

**Fields:**
- `id`: Unique identifier (UUID)
- `tenant_id`: Foreign key to tenants table (multi-tenant isolation)
- `name`: Squad name (required, unique per tenant)
- `tribe`: Optional organizational grouping
- `description`: Optional detailed description
- `assigned_qe_id`: Foreign key to users table (the assigned Quality Engineer)
- `status`: Enum - `active`, `inactive`, or `archived`
- `created_at`: Timestamp when squad was created
- `updated_at`: Timestamp when squad was last updated

### Squad Member Table

```sql
CREATE TABLE squad_members (
  id UUID PRIMARY KEY,
  squad_id UUID NOT NULL REFERENCES squads(id),
  user_id UUID NOT NULL REFERENCES users(id),
  role_in_squad VARCHAR,
  created_at TIMESTAMP,
  UNIQUE(squad_id, user_id)
);
```

**Fields:**
- `id`: Unique identifier (UUID)
- `squad_id`: Foreign key to squads table
- `user_id`: Foreign key to users table
- `role_in_squad`: Optional role within the squad (e.g., "Developer", "PO", "Designer")
- `created_at`: Timestamp when member was added
- Unique constraint on `(squad_id, user_id)` prevents duplicate memberships

### Relationships

```
Tenant
  ├── has many Squads
  └── has many Users

Squad
  ├── belongs to Tenant
  ├── belongs to User (assigned QE)
  └── has many SquadMembers

SquadMember
  ├── belongs to Squad
  └── belongs to User

User
  ├── can be assigned as QE to many Squads (assignedQeId)
  └── can be member of many Squads (via SquadMember)
```

---

## User Interface

### Location
**Route:** `/dashboard/squads`

**Access:** Available to tenant users with appropriate permissions (typically admin, manager, or QE roles)

### Main Features

#### 1. Squad List View
- Displays all squads in a table format
- Shows key information:
  - Squad name
  - Tribe (if specified)
  - Assigned QE (with avatar if available)
  - Status (color-coded chips: green for active, yellow for inactive, gray for archived)
  - Member count
  - Actions (Edit, Delete, Manage Members)

#### 2. Create Squad Dialog
Opened via "Create Squad" button. Fields:
- **Name** (required): Squad name
- **Tribe** (optional): Organizational grouping
- **Description** (optional): Squad description
- **Assigned QE** (optional): Dropdown to select a QE from available users

#### 3. Edit Squad Dialog
Opened via Edit icon on a squad row. Allows updating:
- Squad name
- Tribe
- Description
- Assigned QE
- Status (active/archived)

#### 4. Member Management Dialog
Opened via "Manage Members" button. Features:
- **View Current Members**: List of all squad members with:
  - User avatar
  - User name and email
  - Role in squad
  - Remove button
- **Add Members**: 
  - Dropdown to select users from tenant
  - Optional role in squad field
  - Add button

#### 5. Delete Squad
Confirmation dialog before permanently deleting a squad and all its member associations.

---

## API Endpoints

All endpoints require authentication and are tenant-scoped (automatically filtered by tenant ID from the authenticated user's token).

### Base Path
`/api/squads`

### Endpoints

#### 1. Get All Squads
```
GET /api/squads
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Platform Squad",
      "tribe": "Platform Tribe",
      "description": "Platform infrastructure team",
      "tenantId": "uuid",
      "assignedQeId": "uuid",
      "assignedQe": {
        "id": "uuid",
        "name": "Jane QE",
        "email": "jane.qe@example.com"
      },
      "status": "active",
      "members": [
        {
          "id": "uuid",
          "userId": "uuid",
          "roleInSquad": "Developer"
        }
      ],
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### 2. Get Squad by ID
```
GET /api/squads/:id
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Platform Squad",
    "tribe": "Platform Tribe",
    "description": "Platform infrastructure team",
    "tenantId": "uuid",
    "assignedQeId": "uuid",
    "assignedQe": {
      "id": "uuid",
      "name": "Jane QE",
      "email": "jane.qe@example.com"
    },
    "status": "active",
    "members": [
      {
        "id": "uuid",
        "userId": "uuid",
        "roleInSquad": "Developer",
        "user": {
          "id": "uuid",
          "name": "John Developer",
          "email": "john@example.com",
          "role": "developer"
        }
      }
    ],
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
}
```

#### 3. Create Squad
```
POST /api/squads
```

**Request Body:**
```json
{
  "name": "Platform Squad",
  "tribe": "Platform Tribe",
  "description": "Platform infrastructure team",
  "assignedQeId": "uuid"
}
```

**Response:** 201 Created
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Platform Squad",
    "tribe": "Platform Tribe",
    "description": "Platform infrastructure team",
    "tenantId": "uuid",
    "assignedQeId": "uuid",
    "status": "active",
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
}
```

#### 4. Update Squad
```
PATCH /api/squads/:id
```

**Request Body:**
```json
{
  "name": "Updated Squad Name",
  "tribe": "Updated Tribe",
  "description": "Updated description",
  "assignedQeId": "uuid",
  "status": "active"
}
```

**Response:** 200 OK (same structure as Get Squad by ID)

#### 5. Delete Squad
```
DELETE /api/squads/:id
```

**Response:** 200 OK
```json
{
  "success": true,
  "message": "Squad deleted successfully"
}
```

#### 6. Add Squad Member
```
POST /api/squads/:id/members
```

**Request Body:**
```json
{
  "userId": "uuid",
  "roleInSquad": "Developer"
}
```

**Response:** 200 OK
```json
{
  "success": true,
  "message": "Member added successfully"
}
```

**Error:** 409 Conflict if user is already a member

#### 7. Remove Squad Member
```
DELETE /api/squads/:id/members/:userId
```

**Response:** 200 OK
```json
{
  "success": true,
  "message": "Member removed successfully"
}
```

#### 8. Assign QE to Squad
```
PATCH /api/squads/:id/assign-qe
```

**Request Body:**
```json
{
  "qeId": "uuid"  // or null to unassign
}
```

**Response:** 200 OK (same structure as Get Squad by ID)

---

## User Workflows

### Creating a Squad

1. Navigate to `/dashboard/squads`
2. Click "Create Squad" button
3. Fill in the form:
   - Enter squad name (required)
   - Optionally enter tribe name
   - Optionally enter description
   - Optionally select an assigned QE from dropdown
4. Click "Create"
5. Squad appears in the list with status "active"

### Editing a Squad

1. Click the Edit icon (✏️) on the squad row
2. Modify fields in the dialog:
   - Update name, tribe, description
   - Change assigned QE
   - Change status (active/inactive/archived)
3. Click "Save Changes"
4. Updated information is reflected in the squad list

### Managing Squad Members

1. Click "Manage Members" button on a squad row
2. **To add a member:**
   - Select a user from the "Select User" dropdown
   - Optionally enter role in squad
   - Click "Add Member"
3. **To remove a member:**
   - Click the remove icon (➖) next to the member
   - Confirm removal
4. Close the dialog to return to squad list

### Assigning a QE to Squad

**Option 1: During Creation**
- Select QE from "Assigned QE" dropdown in Create Squad dialog

**Option 2: After Creation**
- Open Edit Squad dialog
- Change "Assigned QE" dropdown
- Save changes

**Option 3: Direct Assignment**
- Use the assign QE API endpoint
- Or update via Edit dialog

### Archiving a Squad

1. Open Edit Squad dialog
2. Change Status to "archived"
3. Save changes
4. Squad status changes to archived (gray chip)
5. Archived squads can still be viewed but are typically filtered out of active views

---

## Features

### 1. Multi-Tenant Isolation
- All squads are scoped to a tenant organization
- Users can only see and manage squads from their tenant
- Tenant ID is automatically extracted from the authenticated user's token

### 2. QE Assignment
- Each squad can have one assigned Quality Engineer
- QE assignment is optional
- QE must be a user within the same tenant
- Assigned QE is displayed in the squad list with avatar and name

### 3. Member Management
- Users can belong to multiple squads
- Each membership can have an optional role (e.g., "Developer", "PO", "Designer")
- Unique constraint prevents duplicate memberships
- Member count is displayed in the squad list

### 4. Status Management
- Two statuses: `active` and `archived`
- Status is color-coded in the UI:
  - **Active**: Green/success chip
  - **Archived**: Gray/default chip
- Status can be changed via Edit dialog
- Active squads are shown by default; archived squads are preserved but can be filtered out

### 5. Tribe Organization
- Optional grouping mechanism for organizing squads
- Can be used for organizational hierarchy (e.g., tribes > squads)
- Displayed in the squad list and can be filtered/grouped by

### 6. Validation
- Squad name is required
- Assigned QE must exist in the tenant
- User must exist in tenant before adding as member
- Prevents duplicate member assignments

---

## Integration with Other Modules

Squads are used throughout the platform in various modules:

### 1. Coaching Tracker
- Coaching sessions are linked to squads
- QEs can track sessions for their assigned squads
- Filter coaching sessions by squad

### 2. Quality Scorecard
- Quality metrics are tracked per squad
- Scorecards show squad-level quality indicators
- Aggregate metrics across squads

### 3. Feedback Form
- Feedback is collected at the squad level
- Members can submit feedback about their squad's quality practices
- QEs can view feedback for their assigned squads

### 4. Maturity Ladder
- Maturity assessments are conducted per squad
- Track progression of squad quality maturity
- Compare maturity across squads

### 5. Enablement Hub
- Resources can be assigned to specific squads
- QEs can share enablement materials with their squads
- Track resource usage per squad

### 6. Test Logger
- Exploratory test sessions are logged per squad
- Track testing activities by squad
- Aggregate test findings by squad

### 7. Test Debt Register
- Test debt items are tracked per squad
- Prioritize debt resolution by squad
- Track debt reduction progress per squad

### 8. Change Tracker
- Track changes and their impact per squad
- Monitor how changes affect squad quality
- Historical tracking of changes

### 9. User Management
- Users can be assigned to multiple squads during creation
- View which squads a user belongs to
- Manage squad memberships from user profile

---

## Permissions & Access Control

### Who Can Access Squad Management

- **Admins**: Full access (create, edit, delete, manage members)
- **Managers**: Typically full access (varies by role configuration)
- **QEs**: Typically view and manage members for assigned squads
- **Other Roles**: Typically read-only or no access (varies by role configuration)

Access is controlled by:
1. **Route Protection**: Squad management page is behind authentication
2. **API Middleware**: All endpoints require authentication and tenant middleware
3. **Role-Based Permissions**: UI shows/hides features based on user role
4. **Backend Validation**: Server validates tenant membership for all operations

---

## Best Practices

### 1. Squad Naming
- Use clear, descriptive names
- Consider organizational naming conventions
- Avoid duplicate names within a tenant

### 2. QE Assignment
- Assign a QE to every active squad
- Ensure QEs have the appropriate role and permissions
- Review QE assignments regularly

### 3. Member Management
- Keep squad membership up to date
- Use role in squad to clarify member responsibilities
- Remove members when they leave the squad

### 4. Status Management
- Mark inactive squads as "inactive" rather than deleting
- Archive old squads that are no longer relevant
- Keep active squads current and accurate

### 5. Tribe Organization
- Use tribes consistently for organizational structure
- Group related squads under the same tribe
- Consider tribe structure when creating new squads

---

## Error Handling

### Common Errors

1. **Squad Not Found (404)**
   - Squad ID doesn't exist
   - Squad belongs to a different tenant
   - Solution: Verify squad ID and tenant membership

2. **User Not Found (404)**
   - User ID doesn't exist when assigning QE or adding member
   - User belongs to a different tenant
   - Solution: Verify user exists in the tenant

3. **Duplicate Member (409)**
   - User is already a member of the squad
   - Solution: User can only be added once per squad

4. **Validation Error (400)**
   - Missing required field (e.g., squad name)
   - Invalid status value
   - Solution: Check required fields and valid enum values

5. **Unauthorized (401)**
   - Authentication token missing or invalid
   - Solution: Re-authenticate

6. **Forbidden (403)**
   - User doesn't have permission
   - Solution: Contact administrator

---

## Technical Implementation

### Backend

**Service Layer** (`squad.service.ts`):
- `getAllSquads(tenantId)`: Fetch all squads for tenant
- `getSquadById(squadId, tenantId)`: Get squad with members and QE
- `createSquad(data, tenantId)`: Create new squad
- `updateSquad(squadId, data, tenantId)`: Update squad details
- `deleteSquad(squadId, tenantId)`: Delete squad
- `addSquadMember(squadId, userId, tenantId, roleInSquad)`: Add member
- `removeSquadMember(squadId, userId, tenantId)`: Remove member
- `assignQeToSquad(squadId, qeId, tenantId)`: Assign/unassign QE

**Controller Layer** (`squads.controller.ts`):
- Handles HTTP requests
- Validates input
- Calls service layer
- Returns formatted responses

**Routes** (`squads.routes.ts`):
- Protected by authentication middleware
- Protected by tenant middleware (auto-extracts tenant from token)
- RESTful endpoint structure

### Frontend

**Component** (`SquadManagement.tsx`):
- React functional component with hooks
- Manages local state for squads, users, dialogs
- Uses Material-UI components for UI
- Calls API utility functions
- Handles user interactions (create, edit, delete, manage members)

**API Integration** (`api.ts`):
- TypeScript interfaces for type safety
- Functions for each API endpoint
- Automatic authentication header injection
- Error handling and response parsing

---

## Future Enhancements

Potential improvements and features:

1. **Bulk Operations**
   - Bulk add/remove members
   - Bulk status changes
   - Import/export squads

2. **Advanced Filtering**
   - Filter by tribe
   - Filter by status
   - Filter by assigned QE
   - Search squads by name

3. **Squad Hierarchy**
   - Support for nested squads or sub-squads
   - Squad templates
   - Squad cloning

4. **Analytics & Reporting**
   - Squad activity metrics
   - Member count trends
   - QE assignment statistics

5. **Notifications**
   - Notify QE when assigned to squad
   - Notify members when added/removed
   - Squad activity notifications

---

## Related Documentation

- [User Management](./user-management.md) - Managing users and their squad memberships
- [System Overview](./system-overview.md) - Overall platform architecture
- [API Integration Guide](./API-INTEGRATION.md) - How to integrate with the API
- [Coaching Tracker](./coaching-tracker.md) - Using squads in coaching sessions
- [Quality Scorecard](./quality-scorecard.md) - Squad-level quality metrics

---

**Last Updated**: 2024

