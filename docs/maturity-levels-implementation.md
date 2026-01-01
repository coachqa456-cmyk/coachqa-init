# Maturity Levels Implementation: Tenant vs Platform Admin

## Overview

Maturity levels in CoachQA are implemented as **global/shared** entities that are used across all tenants, but managed differently depending on the context (tenant user vs platform admin).

## Architecture

### Database Structure

The `maturity_levels` table is **global** (not tenant-specific):

```sql
CREATE TABLE maturity_levels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  level INTEGER NOT NULL UNIQUE CHECK (level >= 1 AND level <= 5),
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  detailed_criteria TEXT[] NOT NULL DEFAULT '{}',
  color VARCHAR(7) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Key Points:**
- ❌ **NO `tenant_id` column** - maturity levels are shared across all tenants
- ✅ **Unique `level` constraint** - only one level 1, one level 2, etc. can exist
- ✅ **Level range: 1-5** - enforced by database constraint

### Backend Implementation

#### Routes (`coachqa-backend/src/routes/maturity.routes.ts`)

All maturity level routes use:
- `authenticate` middleware - requires authentication
- `tenantMiddleware` - sets tenant context (even though levels are global)

```typescript
router.use(authenticate);
router.use(tenantMiddleware);

// Maturity Level endpoints
router.get('/levels', maturityController.getAllMaturityLevels);
router.get('/levels/:level', maturityController.getMaturityLevelById);
router.post('/levels', maturityController.createMaturityLevel);
router.put('/levels/:id', maturityController.updateMaturityLevel);
router.delete('/levels/:id', maturityController.deleteMaturityLevel);
```

#### Service Layer (`coachqa-backend/src/services/maturity.service.ts`)

**Key Functions:**

1. **`getAllMaturityLevels()`** - Returns ALL maturity levels (no tenant filtering)
   ```typescript
   export const getAllMaturityLevels = async () => {
     return MaturityLevel.findAll({ order: [['level', 'ASC']] });
   };
   ```

2. **`createMaturityLevel()`** - Creates a global maturity level
   - Validates level is between 1-5
   - Checks if level already exists (unique constraint)
   - No tenant_id is stored

3. **`updateMaturityLevel()`** - Updates a global maturity level by ID
   - Can update name, description, criteria, color
   - **Cannot change level number** (would require deletion and recreation)

4. **`deleteMaturityLevel()`** - Deletes a global maturity level
   - **Prevents deletion** if any assessments reference it
   - Checks `MaturityAssessment` table for references

#### Controller Layer (`coachqa-backend/src/controllers/maturity.controller.ts`)

All controllers are accessible to **authenticated tenant users**:
- No special platform admin check
- Uses `tenantMiddleware` for context (but doesn't filter by tenant)

## Frontend Implementation

### Tenant Context (Regular Users)

#### 1. **Maturity Ladder Page** (`/dashboard/maturity-ladder`)

**File:** `coachqa-ui/src/pages/maturity-ladder/MaturityLadder.tsx`

**Purpose:** View and create maturity assessments for squads

**Features:**
- ✅ **Read-only access** to maturity levels
- ✅ Fetches all maturity levels: `fetchMaturityLevels()`
- ✅ Uses levels to display options in assessment form
- ❌ **Cannot create/edit/delete** maturity levels

**API Calls:**
```typescript
// Read maturity levels
apiCall<MaturityLevel[]>(fetchMaturityLevels())

// Read assessments (tenant-specific)
apiCall<MaturityAssessment[]>(fetchSquadMaturityHistory(selectedSquadId))
apiCall<MaturityAssessment | null>(fetchCurrentSquadMaturity(selectedSquadId))
```

#### 2. **Maturity Level Management Page** (`/dashboard/maturity-levels`)

**File:** `coachqa-ui/src/pages/maturity-levels/MaturityLevelManagement.tsx` (if exists)

**Note:** Based on `App.tsx`, this route exists but the file may not be implemented yet.

**Expected Features:**
- View all maturity levels
- Create/edit/delete maturity levels
- Similar to platform admin implementation

### Platform Admin Context

#### **Tenant Details Page** (`/admin/tenants/:tenantId`)

**File:** `coachqa-ui/src/pages/platform-admin/TenantDetails.tsx`

**Tab:** "Maturity Levels" (Tab index 4)

**Purpose:** Manage global maturity levels from platform admin panel

**Features:**
- ✅ **Full CRUD operations** on maturity levels
- ✅ Create new maturity levels
- ✅ Edit existing maturity levels (name, description, criteria, color)
- ✅ Delete maturity levels (with validation)
- ✅ View all maturity levels in a table

**Implementation Details:**

```typescript
// State management
const [maturityLevels, setMaturityLevels] = useState<MaturityLevel[]>([]);
const [loadingMaturityLevels, setLoadingMaturityLevels] = useState(false);
const [maturityLevelDialogOpen, setMaturityLevelDialogOpen] = useState(false);
const [editingMaturityLevel, setEditingMaturityLevel] = useState<MaturityLevel | null>(null);

// Load maturity levels when tab is active
useEffect(() => {
  if (activeTab === 4 && !loadingMaturityLevels) {
    const loadMaturityLevels = async () => {
      setLoadingMaturityLevels(true);
      try {
        const res = await fetchMaturityLevels();
        if (!res.ok) throw new Error('Failed to load maturity levels');
        const data = await res.json();
        setMaturityLevels(data.data || []);
      } catch (error) {
        console.error('Error loading maturity levels:', error);
        setMaturityLevels([]);
      } finally {
        setLoadingMaturityLevels(false);
      }
    };
    loadMaturityLevels();
  }
}, [activeTab, loadingMaturityLevels]);
```

**API Functions Used:**
```typescript
import {
  fetchMaturityLevels,
  createMaturityLevel,
  updateMaturityLevel,
  deleteMaturityLevel,
  MaturityLevel,
  CreateMaturityLevelPayload,
  UpdateMaturityLevelPayload,
} from '../../utils/api';
```

## Key Differences: Tenant vs Platform Admin

| Aspect | Tenant Users | Platform Admin |
|--------|-------------|----------------|
| **View Levels** | ✅ Yes (read-only) | ✅ Yes (read-only) |
| **Create Levels** | ❌ No | ✅ Yes (in Tenant Details tab) |
| **Edit Levels** | ❌ No | ✅ Yes (in Tenant Details tab) |
| **Delete Levels** | ❌ No | ✅ Yes (in Tenant Details tab) |
| **Create Assessments** | ✅ Yes (for their squads) | ❌ No (not in tenant context) |
| **View Assessments** | ✅ Yes (for their tenant) | ❌ No (not in tenant context) |
| **Route** | `/dashboard/maturity-ladder` | `/admin/tenants/:tenantId` (tab 4) |

## Important Notes

### 1. **Global vs Tenant-Specific**

- **Maturity Levels** = **Global** (shared across all tenants)
- **Maturity Assessments** = **Tenant-specific** (each tenant has their own assessments)

This design allows:
- Consistent maturity framework across all tenants
- Platform admins can standardize the maturity model
- Tenants can still have their own assessment history

### 2. **Level Number Immutability**

Once a maturity level is created, its `level` number (1-5) **cannot be changed**. This is because:
- The level number is used as a foreign key reference in assessments
- Changing it would break existing assessments
- To change a level number, you must:
  1. Delete the level (if no assessments reference it)
  2. Create a new level with the desired number

### 3. **Deletion Protection**

Maturity levels **cannot be deleted** if they are referenced by any assessments:
```typescript
const assessmentCount = await MaturityAssessment.count({
  where: { assessedLevel: maturityLevel.level },
});

if (assessmentCount > 0) {
  throw new Error(
    `Cannot delete maturity level ${maturityLevel.level}. There are ${assessmentCount} assessment(s) using this level.`
  );
}
```

### 4. **API Access Control**

Currently, **all authenticated users** (tenant users and platform admins) can:
- ✅ Read maturity levels
- ✅ Create/edit/delete maturity levels (via API)

**Recommendation:** Consider adding role-based access control to restrict create/edit/delete operations to platform admins only.

## API Endpoints Summary

### Maturity Levels (Global)

| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| GET | `/api/maturity/levels` | All authenticated users | Get all maturity levels |
| GET | `/api/maturity/levels/:level` | All authenticated users | Get maturity level by number (1-5) |
| POST | `/api/maturity/levels` | All authenticated users | Create new maturity level |
| PUT | `/api/maturity/levels/:id` | All authenticated users | Update maturity level |
| DELETE | `/api/maturity/levels/:id` | All authenticated users | Delete maturity level |

### Maturity Assessments (Tenant-Specific)

| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| GET | `/api/maturity/assessments` | Tenant users | Get all assessments for tenant |
| GET | `/api/maturity/squad/:squadId/current` | Tenant users | Get current assessment for squad |
| GET | `/api/maturity/squad/:squadId/history` | Tenant users | Get assessment history for squad |
| POST | `/api/maturity/assessments` | Tenant users | Create new assessment |

## Future Enhancements

1. **Tenant-Specific Maturity Levels**
   - Add `tenant_id` column to `maturity_levels` table
   - Allow tenants to customize their maturity framework
   - Platform admins can still manage global defaults

2. **Role-Based Access Control**
   - Restrict create/edit/delete to platform admins
   - Tenant users can only read maturity levels

3. **Maturity Level Management Page for Tenants**
   - Implement `/dashboard/maturity-levels` page
   - Allow tenant admins to view (and potentially customize) maturity levels

4. **Level Number Editing**
   - Allow changing level numbers with cascade updates to assessments
   - Or provide a "reorder" feature that updates all references

