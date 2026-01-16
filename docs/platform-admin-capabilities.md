## Platform Admin Capabilities Overview

This document summarizes what is currently implemented and working in the **Platform Admin** area of QEnabler.

Platform Admin routes live under `/admin` and use a separate authentication flow and token storage from tenant users.

---

## Authentication & Shell

- **Platform Admin Login**
  - URL: `/admin/login`
  - Uses dedicated storage keys (`platform.user`, `platform.userType`, `platform.accessToken`, `platform.refreshToken`).
  - Successful login redirects to `/admin/dashboard`.

- **Platform Admin Layout**
  - URL root: `/admin`
  - Protected by `PlatformAdminProtectedRoute`.
  - Uses `PlatformAdminLayout` with a left navigation (`PlatformAdminSidebar`) and nested routes:
    - `/admin/dashboard`
    - `/admin/tenants`
    - `/admin/tenants/:tenantId`
    - `/admin/admins`
    - `/admin/settings`
    - `/admin/role-permissions`
    - `/admin/roles`
    - `/admin/system-menus`

---

## 1. Dashboard

- **URL**: `/admin/dashboard`
- **Purpose**: Landing page for platform admins (currently a simple overview; ready for KPIs/metrics).

---

## 2. Tenant Management

### Tenant List

- **URL**: `/admin/tenants`
- **Data source**: `fetchPlatformTenants()` → `/api/platform-admin/tenants`
- **Key features**:
  - Table of tenants: `name`, `slug`, `createdAt`, and user count (when present).
  - Search by tenant name or slug.
  - **Manage Permissions** action → navigates to `/admin/tenants/:tenantId`.

### Tenant Details

- **URL**: `/admin/tenants/:tenantId`
- **Data sources**:
  - `fetchPlatformTenantById(tenantId)` → tenant metadata.
  - `fetchPlatformTenantUsers(tenantId)` → tenant users.
  - `fetchPlatformTenantRoles(tenantId)` → tenant roles.
  - Platform-admin menu/permissions endpoints (see sections below).

#### Tenant Header

- Shows:
  - Tenant name.
  - Slug.
  - Created date.
- Actions:
  - **Edit**: update name/slug via `updatePlatformTenant`.
  - **Delete**: delete tenant via `deletePlatformTenant` (with confirmation).

#### Tabs

1. **Users**
   - Lists tenant users (`name`, `email`, `role`, `status`) in a sortable table.
   - **Add User**:
     - Creates a tenant user via `createPlatformTenantUser(tenantId, payload)`.
     - Supports `name`, `email`, `role`, optional initial `password`.
   - **Edit User**:
     - Updates via `updatePlatformTenantUser(tenantId, userId, payload)` (email is immutable in this flow).
     - Can change `name`, `role`, and `status`.
   - **Delete User**:
     - Deletes via `deletePlatformTenantUser(tenantId, userId)` with confirmation.

2. **Roles**
   - Lists roles for this tenant (from `fetchPlatformTenantRoles(tenantId)`):
     - `name`, `description`, `isSystemRole`, and how many users have that role.
   - Role types:
     - **System Role**: global platform roles (e.g. `admin`, `qe`, `manager`, `developer`, `executive`).
     - **Custom Role**: tenant-specific roles.
   - Actions:
     - **Create Role**:
       - Uses `createRole(rolePayload)` with `tenantId` set to this tenant.
     - **Edit Role**:
       - Uses `updateRole(roleId, payload)`; system role flag and tenant association are preserved.
     - **Delete Role**:
       - Allowed only for non-system roles via `deleteRole(roleId)`.
   - UI safeguards:
     - System roles cannot be deleted.

3. **Role Permissions**

- **Goal**: Manage menu access for each role (system + custom) for this tenant.
- **Data sources**:
  - Menus:
    - `/api/platform-admin/tenants/{tenantId}/menus` → combined system + custom menus.
  - Permissions:
    - `GET /api/platform-admin/tenants/{tenantId}/roles/{roleId}/menu-permissions`
    - `PUT /api/platform-admin/tenants/{tenantId}/roles/{roleId}/menu-permissions`

- **UI**:
  - Uses `MenuPermissionEditor` in **platform-admin mode**:
    - `isPlatformAdmin={true}`
    - `tenantId={tenantId}`
  - Per-role section shows:
    - Role name.
    - Chips for:
      - `System Role` (where applicable).
      - `Full Access` for admin role.
    - A permissions grid (switches) grouped by menu group.

- **UUID guard**:
  - In environments where roles might temporarily use non-UUID IDs (e.g. `"admin"`), the editor:
    - Checks `role.id.includes('-')` to detect UUID-like IDs.
    - Only renders `MenuPermissionEditor` for roles with valid IDs.
    - Shows a warning chip when the ID isn’t suitable:  
      _"Permissions editor unavailable (missing role ID)"_.

- **Error & empty states**:
  - If roles cannot be loaded:
    - Displays a clear error explaining that platform role migrations or seed data may be missing.
  - If there are zero roles:
    - Shows guidance to create roles first before configuring permissions.

4. **Menus (Tenant Custom Menus – Platform Admin control)**

- **Goal**: Let platform admins manage **custom menus** for a specific tenant.
- **Data sources**:
  - `GET /api/platform-admin/tenants/{tenantId}/custom-menus[?activeOnly=true]`
  - `POST /api/platform-admin/tenants/{tenantId}/custom-menus`
  - `PUT /api/platform-admin/tenants/{tenantId}/custom-menus/{id}`
  - `DELETE /api/platform-admin/tenants/{tenantId}/custom-menus/{id}`
- **Frontend helpers** (`utils/api.ts`):
  - `fetchPlatformTenantCustomMenus(tenantId, activeOnly?)`
  - `createPlatformTenantCustomMenu(tenantId, payload)`
  - `updatePlatformTenantCustomMenu(tenantId, menuId, payload)`
  - `deletePlatformTenantCustomMenu(tenantId, menuId)`

- **UI**:
  - Table of tenant custom menus:
    - `title`, `path`, `groupName`, `orderIndex`, `isActive`.
  - Actions:
    - **Create Custom Menu**:
      - Opens `CustomMenuEditor` to capture:
        - `path`, `title`, optional `icon`, `groupName`, `orderIndex`, `isActive`.
    - **Edit**:
      - Opens `CustomMenuEditor` pre-filled for the selected menu.
    - **Delete**:
      - Deletes the menu with confirmation.
  - Notes:
    - This operates on tenant-specific `CustomMenu` records, in addition to global `SystemMenu` entries.

---

## 3. Admin User Management

- **URL**: `/admin/admins`
- **Data source**: `/api/platform-admin/admins`
- **Features**:
  - List of platform admin users with:
    - `name`, `email`, `status`.
    - Permissions structure (e.g. `manageTenants`, `managePlatformSettings`, `manageAdmins`, `viewAnalytics`, `accessTenantData`).
  - Create/Edit/Delete admin users:
    - Uses `apiPost`, `apiPut`, `apiDelete` against platform-admin admin endpoints.

---

## 4. Platform Settings

- **URL**: `/admin/settings`
- **Purpose**:
  - Central location for platform-wide configuration.
  - Currently minimal, but wired as a dedicated entry in the platform-admin sidebar for future expansion.

---

## 5. Role Permissions (Global Tenant Selector)

- **URL**: `/admin/role-permissions`
- **Features**:
  - Lists tenants with search filter.
  - “Manage Permissions” button navigates directly to `/admin/tenants/:tenantId` on the **Role Permissions** tab.
  - Explains:
    - **System roles**: `admin`, `qe`, `manager`, `developer`, `executive` – edited centrally by platform admins.
    - **Custom roles**: created per-tenant, manageable by both platform and tenant admins (where UIs are enabled).
    - **Admin role**: always has full access and is not editable in permission grids.

---

## 6. Platform Role Management

- **URL**: `/admin/roles`
- **Data sources**:
  - `fetchAllRoles(tenantId?)` → `/api/platform-admin/roles[?tenantId=...]`
  - `fetchPlatformTenants()` → `/api/platform-admin/tenants`
- **Features**:
  - View all roles across the platform:
    - Name, description, type (System vs Custom), and associated tenant or Global.
  - Filtering:
    - All roles.
    - **Global** roles (where `tenantId` is null).
    - Roles scoped to a specific tenant.
  - Create/Edit/Delete:
    - `createRole(payload)` – can set `tenantId` (or null for global) and `isSystemRole`.
    - `updateRole(roleId, payload)` – adjust metadata and permissions blob for future use.
    - `deleteRole(roleId)` – disallowed for system roles by UI convention.

---

## 7. System Menu Management

- **URL**: `/admin/system-menus`
- **Data sources**:
  - `GET /api/platform-admin/system-menus`
  - `POST /api/platform-admin/system-menus`
  - `PUT /api/platform-admin/system-menus/{id}`
  - `DELETE /api/platform-admin/system-menus/{id}`
- **Features**:
  - Global **System Menus** that appear across tenants:
    - `path`, `title`, `icon`, `groupName`, `orderIndex`, `isActive`.
  - Only platform admins can:
    - View, create, update, delete system menu entries.
  - Deletion cleans up associated `MenuPermission` records for that menu path.

---

## Tenant vs Platform Responsibilities (Menus & Access)

- **Platform Admin controls**:
  - Global **system menus**.
  - Per-tenant **custom menus**.
  - Role definitions (system + custom) and role-to-menu permissions for each tenant.
  - Platform admin users and their capabilities.

- **Tenants**:
  - Use the `/dashboard/...` experience, with visibility governed by:
    - Role-based menu permissions (from `MenuPermission` data).
    - Additional static `MODULE_PERMISSIONS` fallbacks in `rolePermissions.ts` where applicable.
  - Direct tenant-side Custom Menu Management (`/dashboard/custom-menus`) has been disabled/removed; all custom menu configuration is driven from platform-admin tooling.

---

## Notes for Future Enhancements

- Expand `/admin/dashboard` with real platform metrics (tenant counts, active users, usage).
-,Introduce richer validation/preview for custom menus (e.g. testing a menu path before activation).
- Extend Role Permissions UI to show effective menu visibility per role and per tenant in a single consolidated view.


