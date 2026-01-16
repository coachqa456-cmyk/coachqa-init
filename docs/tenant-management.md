# Tenant Management (Platform Admin)

## Overview

The Tenant Management feature allows **platform admins** to manage tenants and their users from the `/admin` area.

- **Tenant list**: `/admin/tenants`
- **Tenant details & users**: `/admin/tenants/:tenantId`
- Access is restricted to authenticated platform admins with the `manageTenants` permission.

## Backend APIs

All routes below require a valid **platform admin** access token and pass through `authenticatePlatformAdmin` + `requirePermission('manageTenants')`.

### Tenants

- `GET /api/platform-admin/tenants`
  - Returns all tenants, including basic user info for each tenant.
- `GET /api/platform-admin/tenants/:id`
  - Returns a single tenant and its users.
- `POST /api/platform-admin/tenants`
  - Create a new tenant.
  - Body:
    - `name: string` – display name.
    - `slug: string` – unique identifier.
- `PUT /api/platform-admin/tenants/:id`
  - Update tenant name and/or slug.
  - Body:
    - `name?: string`
    - `slug?: string`
- `DELETE /api/platform-admin/tenants/:id`
  - Deletes a tenant.
  - Fails with `400` if the tenant still has users.

### Tenant Users (Platform Admin)

- `GET /api/platform-admin/tenants/:id/users`
  - List all users for a tenant (password hashes are never returned).
- `POST /api/platform-admin/tenants/:id/users`
  - Create a new user under the tenant.
  - Body (subset of tenant user model):
    - `email: string`
    - `name: string`
    - `role: 'admin' | 'qe' | 'manager' | 'developer' | 'executive'`
    - `password?: string` – optional initial password; if omitted, a temporary password is generated and the user remains `pending`.
    - `squadIds?: string[]` – optional squads to assign.
- `PATCH /api/platform-admin/tenants/:tenantId/users/:userId`
  - Update an existing tenant user.
  - Body:
    - `name?: string`
    - `role?: string`
    - `status?: 'active' | 'pending' | 'suspended'`
    - `avatarUrl?: string`
- `DELETE /api/platform-admin/tenants/:tenantId/users/:userId`
  - Deletes a tenant user.

These endpoints internally reuse the tenant-scoped `User` service, but are called with elevated platform-admin privileges.

## Frontend: Routes & Components

### Routes

Defined in `QEnabler-ui/src/App.tsx`:

- `/admin/tenants` → `TenantManagement` (list + tenant CRUD)
- `/admin/tenants/:tenantId` → `TenantDetails` (tenant profile + tenant user CRUD)

Both are wrapped by `PlatformAdminProtectedRoute`, which checks **platform-admin auth**.

### `TenantManagement` page

File: `QEnabler-ui/src/pages/platform-admin/TenantManagement.tsx`

- Displays a table of tenants with:
  - `Name`, `Slug`, `Users`, `Created`, `Actions`.
- Features:
  - **Search**: filter by `name` or `slug`.
  - **Create tenant**: `New Tenant` button → MUI dialog to enter `name` and `slug`.
  - **Edit tenant**: inline edit dialog from each row.
  - **Delete tenant**: delete icon with confirmation; fails if tenant still has users.
  - **View details**: eye icon → navigates to `/admin/tenants/:tenantId`.
- Uses helper functions from `src/utils/api.ts`:
  - `fetchPlatformTenants`
  - `createPlatformTenant`
  - `updatePlatformTenant`
  - `deletePlatformTenant`

### `TenantDetails` page

File: `QEnabler-ui/src/pages/platform-admin/TenantDetails.tsx`

- Header panel shows tenant profile:
  - Name, slug (chip), created date.
  - Actions: **Edit** (inline dialog), **Delete** (with confirmation).
- User table:
  - Columns: `Name`, `Email`, `Role`, `Status`, `Actions`.
  - Actions:
    - **Add User**: opens dialog to create a tenant user (name, email, role, optional password).
    - **Edit User**: update name, role, status.
    - **Delete User**: remove user from the tenant.
- Uses helper functions from `src/utils/api.ts`:
  - `fetchPlatformTenantById`
  - `fetchPlatformTenantUsers`
  - `updatePlatformTenant`
  - `deletePlatformTenant`
  - `createPlatformTenantUser`
  - `updatePlatformTenantUser`
  - `deletePlatformTenantUser`

## How to Use (Platform Admin Flow)

1. **Log in** to the Platform Admin area at `/admin/login`.
2. Go to **Tenants** in the admin navigation (`/admin/tenants`).
3. From the list:
   - Click **New Tenant** to create a tenant.
   - Use the **search** box to find an existing tenant.
   - Use the **eye** icon to open tenant details.
4. On the **Tenant Details** page:
   - Use **Edit** to rename or change the tenant slug.
   - Use **Delete** to remove a tenant (only possible when there are no users).
   - Use **Add User** to create tenant users and assign them roles.
   - Use **Edit** / **Delete** per user to maintain the tenant's user base.

## Notes & Limitations

- Tenant deletion is blocked while users exist to avoid foreign-key issues; delete or migrate users first.
- Email changes for existing users are **not** editable from this UI; create a new user if an email must change.
- Platform admin user operations bypass tenant-level RBAC and act with full authority for that tenant.











