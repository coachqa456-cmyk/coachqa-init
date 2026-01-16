# Role & Permission Master

## Overview

The Role & Permission Master implements RBAC for **tenant users**:

- Predefined **system roles**: `admin`, `qe`, `manager`, `developer`, `executive`
- Tenant-specific custom roles
- Central **permission catalog** (e.g. `coaching.create`, `testDebt.resolve`)
- Management from both:
  - **Platform Admin Panel** (`/admin/roles`)
  - **Tenant Admin Panel** (`/dashboard/roles` – to be wired to the new APIs)

---

## Data Model

### `permissions` (master catalog)

- **Table**: `permissions`
- **Model**: `Permission` (`QEnabler-backend/src/models/Permission.ts`)
- **Fields**:
  - `id: UUID`
  - `code: string` (unique, e.g. `coaching.view`)
  - `name: string`
  - `description?: string`
  - `category: string` (module: `coaching`, `scorecard`, `users`, `roles`, etc.)
  - `createdAt`, `updatedAt`

> Seeded in `004-create-role-permission-tables.sql` with all module permission codes.

### `roles`

- **Table**: `roles`
- **Model**: `Role` (`QEnabler-backend/src/models/Role.ts`)
- **Fields**:
  - `id: UUID`
  - `tenantId?: UUID | null`  
    - `NULL` → **system role** (applies to all tenants)  
    - non-NULL → tenant-specific role
  - `name: string` (e.g. `admin`, `qe`, `custom-qa-lead`)
  - `description?: string`
  - `isSystemRole: boolean`
  - `permissions: JSONB`  
    - Shape: `{ "<permissionCode>": true | false, ... }`
  - `createdAt`, `updatedAt`
- **Indexes**:
  - Unique `(tenant_id, name)`
  - `is_system_role`

> System roles are seeded in `004-create-role-permission-tables.sql` with default permission sets.

### `users.roleId`

- **Model**: `User` (`QEnabler-backend/src/models/User.ts`)
- Added fields/associations:
  - `roleId?: UUID | null` → FK to `roles.id`
  - `User.belongsTo(Role, { as: 'roleEntity' })`
  - `Role.hasMany(User, { as: 'users' })`
- Existing `User.role: UserRole` enum is kept for **backward compatibility** and maps logically to system roles.

---

## Types & Permissions

### Core Types (`QEnabler-backend/src/types/index.ts`)

**User type**:

```ts
export type UserType = 'platform_admin' | 'tenant_user';
```

**Platform admin permissions**:

```ts
export interface PlatformAdminPermissions {
  manageTenants: boolean;
  managePlatformSettings: boolean;
  manageAdmins: boolean;
  viewAnalytics: boolean;
  accessTenantData: boolean;
}
```

**Permission codes** (excerpt):

```ts
export type PermissionCode =
  | 'coaching.view'
  | 'coaching.create'
  | 'coaching.edit'
  | 'coaching.delete'
  | 'scorecard.view'
  | 'scorecard.create'
  | 'scorecard.edit'
  | 'scorecard.delete'
  | 'feedback.view'
  | 'feedback.create'
  | 'feedback.edit'
  | 'feedback.delete'
  | 'maturity.view'
  | 'maturity.create'
  | 'maturity.edit'
  | 'maturity.delete'
  | 'enablement.view'
  | 'enablement.create'
  | 'enablement.edit'
  | 'enablement.delete'
  | 'impact.view'
  | 'impact.create'
  | 'impact.edit'
  | 'testLogger.view'
  | 'testLogger.create'
  | 'testLogger.edit'
  | 'testLogger.delete'
  | 'testDebt.view'
  | 'testDebt.create'
  | 'testDebt.edit'
  | 'testDebt.delete'
  | 'testDebt.resolve'
  | 'changeTracker.view'
  | 'changeTracker.create'
  | 'changeTracker.edit'
  | 'career.view'
  | 'career.create'
  | 'career.edit'
  | 'career.delete'
  | 'users.view'
  | 'users.create'
  | 'users.edit'
  | 'users.delete'
  | 'users.invite'
  | 'squads.view'
  | 'squads.create'
  | 'squads.edit'
  | 'squads.delete'
  | 'roles.view'
  | 'roles.create'
  | 'roles.edit'
  | 'roles.delete';
```

**Role permissions**:

```ts
export type RolePermissions = Partial<Record<PermissionCode, boolean>>;
```

**Request payload**:

```ts
export interface JwtPayload {
  userId: string;
  tenantId?: string;
  email: string;
  role: string;        // name of the role (e.g. 'admin')
  userType: UserType;
}

export interface AuthenticatedRequest extends Request {
  user?: JwtPayload;
  tenantId?: string;
  isPlatformAdmin?: boolean;
  rolePermissions?: RolePermissions; // computed at auth time
}
```

---

## Default Roles & Permissions

Seeded in `004-create-role-permission-tables.sql`:

- **Admin** (system role)  
  - All permissions set to `true`.

- **QE**  
  - Full access to: coaching, feedback, maturity, enablement, impact, testLogger, testDebt, changeTracker, career.  
  - View access to: scorecard, users, squads.

- **Manager**  
  - View all modules.  
  - Edit: `scorecard.edit`, `feedback.edit`, `maturity.edit`.

- **Developer**  
  - View: coaching, scorecard, feedback, maturity, enablement.  
  - Create + view: `testLogger.*`, `testDebt.create`, `testDebt.view`.

- **Executive**  
  - View-only: `scorecard.view`, `maturity.view`, `impact.view`, `career.view`.

These system roles are **global** (`tenant_id = NULL`) and marked `is_system_role = TRUE`.

---

## Backend Responsibilities (Planned / In Progress)

### Services

- `QEnabler-backend/src/services/role.service.ts`
  - Role CRUD (system + tenant)
  - Manage `permissions` JSON per role
- `QEnabler-backend/src/services/permission.service.ts`
  - Read-only catalog of all permissions

### Controllers & Routes

- `QEnabler-backend/src/controllers/role.controller.ts`
- `QEnabler-backend/src/routes/role.routes.ts`:
  - `GET /api/roles` – list roles for current tenant (plus system roles)
  - `POST /api/roles` – create tenant role
  - `PUT /api/roles/:id` / `DELETE /api/roles/:id`
  - `GET /api/roles/:id/permissions`
  - `PUT /api/roles/:id/permissions`
  - `GET /api/permissions` / `GET /api/permissions/categories`

### Middleware

- `QEnabler-backend/src/middleware/permission.ts`:
  - `requirePermission(code: PermissionCode)`
  - `requireAnyPermission(codes: PermissionCode[])`
  - `requireAllPermissions(codes: PermissionCode[])`
- Behavior:
  - Lookup user’s `roleId` / `role` name → `Role` record.
  - Evaluate permissions (`Role.permissions` JSON).
  - Return 403 if missing required permission(s).

### Auth Middleware Integration

- `QEnabler-backend/src/middleware/auth.ts` currently attaches:
  - `req.user`, `req.tenantId`, `req.isPlatformAdmin`
- It will be extended to:
  - Load `Role` for `user.roleId` (or map `UserRole` to system `Role`).
  - Attach `req.rolePermissions` for downstream checks.

---

## Frontend Responsibilities (Planned)

### API Client

- `QEnabler-ui/src/services/roleApi.ts`:
  - Wraps `/api/roles` and `/api/permissions` endpoints.

### Tenant Admin Role Management (`/dashboard/roles`)

- `QEnabler-ui/src/pages/role-management/RoleManagement.tsx`:
  - List system + tenant roles.
  - Create/update/delete tenant-specific roles.
  - Permission matrix editor (roles × permissions).

### Platform Admin Role Master (`/admin/roles`)

- `QEnabler-ui/src/pages/platform-admin/RolePermissionMaster.tsx`:
  - View/edit **system roles** and their permissions.
  - View how tenants are using roles (future extension).

### User Management Integration

- `QEnabler-ui/src/pages/users/UserManagement.tsx`
- `QEnabler-ui/src/pages/platform-admin/AdminUserManagement.tsx`
  - Role dropdown based on `/api/roles`.
  - Display user’s main permissions summary (optional).

### Navigation & Route Protection

- Add **Role Management** menu items:
  - Tenant sidebar → `/dashboard/roles`.
  - Platform admin layout → `/admin/roles`.
- Extend `ProtectedRoute` or add a wrapper to accept `requiredPermissions` and check via AuthContext.

---

## Usage & Extension

### Assign Roles to Users

- Backend: set `user.roleId` (and keep `user.role` aligned with the role’s `name` during transition).
- Frontend: user forms use roles from `/api/roles` instead of hardcoded enums.

### Check Permissions in Code

```ts
import { requirePermission } from '../middleware/permission';

router.post(
  '/sessions',
  authenticate,
  tenantMiddleware,
  requirePermission('testLogger.create'),
  controller.createSession
);
```

### Add New Permissions

1. Add a new `PermissionCode` string in `src/types/index.ts`.
2. Insert into `permissions` table (via migration or admin tool).
3. Update system roles’ `permissions` JSON if needed.
4. Use `requirePermission('your.new.permission')` in the appropriate routes.


