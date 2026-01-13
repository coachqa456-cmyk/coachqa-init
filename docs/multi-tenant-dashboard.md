# Multi-Tenant Dashboard - How It Works

## Overview

When a user belongs to multiple tenant organizations, the dashboard displays data **only for the currently selected tenant**. The system ensures complete data isolation between tenants through token-based tenant context.

---

## 🔄 How Multi-Tenant Dashboard Works

### Key Principle: **One Tenant Per Session**

- User logs in and **selects ONE tenant** during authentication
- Access token includes the selected `tenantId`
- **All dashboard data is automatically filtered** by this `tenantId`
- To see data from another tenant, user must **logout and login again** with a different tenant

---

## 📋 Complete Flow

### **Step 1: User Logs In and Selects Tenant**

```
User Login Flow:
1. User enters credentials → Backend verifies
2. Backend returns list of tenants user belongs to
3. User selects ONE tenant (e.g., "Acme Corporation")
4. Backend generates token with tenantId = "acme-corp-uuid"
5. Token stored in localStorage
```

**Token Structure:**
```json
{
  "userId": "user-uuid",
  "tenantId": "acme-corp-uuid",  // Selected tenant
  "email": "user@example.com",
  "role": "admin",               // Role in THIS tenant
  "userType": "tenant_user"
}
```

---

### **Step 2: Frontend Makes API Requests**

**Location:** `coachqa-ui/src/utils/api.ts`

**Process:**

1. **Frontend extracts token from localStorage**
   ```typescript
   const token = localStorage.getItem("tenant.accessToken");
   ```

2. **Token automatically included in all API requests**
   ```typescript
   headers.set("Authorization", `Bearer ${token}`);
   ```

3. **Dashboard component calls API**
   ```typescript
   // Dashboard.tsx
   const response = await fetchDashboardStats();
   // Calls: GET /api/dashboard/stats
   ```

**Example API Request:**
```http
GET /api/dashboard/stats
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

### **Step 3: Backend Extracts Tenant Context**

**Location:** `coachqa-backend/src/middleware/auth.ts`

**Process:**

1. **Auth middleware extracts token**
   ```typescript
   const token = authHeader.substring(7); // Remove 'Bearer '
   const decoded = verifyAccessToken(token);
   ```

2. **Extracts tenantId from token**
   ```typescript
   if (decoded.userType === 'tenant_user' && decoded.tenantId) {
     req.tenantId = decoded.tenantId;  // Set on request object
   }
   ```

3. **Request object now has tenantId**
   ```typescript
   req.tenantId = "acme-corp-uuid"
   req.user = { userId, email, role, ... }
   ```

---

### **Step 4: Backend Filters Data by Tenant**

**Location:** `coachqa-backend/src/controllers/dashboard.controller.ts`

**Controller:**
```typescript
export const getDashboardStats = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  const tenantId = req.tenantId!;  // Extracted from token
  const stats = await dashboardService.getDashboardStats(tenantId);
  // ...
};
```

**Service Layer:** `coachqa-backend/src/services/dashboard.service.ts`

**All database queries filter by tenantId:**
```typescript
export const getDashboardStats = async (tenantId: string) => {
  // All queries include: where: { tenantId }
  
  const coachingSessions = await CoachingSession.findAll({
    where: { tenantId },  // ← Only sessions for this tenant
  });
  
  const scorecards = await QualityScorecard.findAll({
    where: { tenantId },  // ← Only scorecards for this tenant
  });
  
  const testDebtItems = await TestDebtItem.findAll({
    where: { tenantId },  // ← Only test debt for this tenant
  });
  
  const squads = await Squad.findAll({
    where: { tenantId },  // ← Only squads for this tenant
  });
  
  // ... all other queries filtered by tenantId
};
```

**Result:**
- Dashboard only shows data for the selected tenant
- No data from other tenants is ever returned
- Complete data isolation

---

### **Step 5: Frontend Displays Tenant-Specific Data**

**Location:** `coachqa-ui/src/pages/Dashboard.tsx`

**Process:**

1. **Dashboard receives filtered data**
   ```typescript
   const stats = await fetchDashboardStats();
   // stats contains ONLY data for selected tenant
   ```

2. **Dashboard displays metrics**
   ```typescript
   metrics: [
     { label: 'Teams Coached', value: stats.metrics.teamsCoached },
     { label: 'Total Squads', value: stats.metrics.totalSquads },
     // ... all metrics are tenant-specific
   ]
   ```

3. **Charts and visualizations show tenant data only**
   - Coaching sessions chart → Only sessions for this tenant
   - Quality scores → Only scores for this tenant's squads
   - Maturity assessments → Only assessments for this tenant
   - Test debt → Only test debt items for this tenant

---

## 🔐 Data Isolation Mechanism

### **Backend Pattern: Every Query Filters by Tenant**

**Example from Squads Controller:**
```typescript
export const getAllSquads = async (req, res, next) => {
  const tenantId = req.tenantId!;  // From token
  
  const squads = await squadService.getAllSquads(tenantId);
  // Returns ONLY squads for this tenant
};
```

**Example from Service:**
```typescript
export const getAllSquads = async (tenantId: string) => {
  return await Squad.findAll({
    where: { tenantId }  // Database-level filtering
  });
};
```

### **Why This Works:**

1. **Token-Based Context**
   - `tenantId` is embedded in JWT token
   - Cannot be tampered with (cryptographically signed)
   - Automatically included in every request

2. **Middleware Enforcement**
   - Auth middleware extracts `tenantId` from token
   - Sets `req.tenantId` on every authenticated request
   - Controllers use `req.tenantId` for all queries

3. **Database-Level Filtering**
   - All queries include `where: { tenantId }`
   - Database returns only matching records
   - No application-level filtering needed

4. **No Cross-Tenant Access**
   - User cannot access data from other tenants
   - Even if they know IDs, queries filter by tenantId
   - Complete isolation guaranteed

---

## 🔄 Switching Between Tenants

### **Current Behavior: Logout and Re-Login**

**Process:**

1. **User logs out**
   ```typescript
   logout(); // Clears localStorage, clears session
   ```

2. **User logs in again**
   - Enters credentials
   - Sees tenant selector page
   - Selects different tenant (e.g., "Tech Startup Inc")

3. **New token generated**
   ```json
   {
     "tenantId": "tech-startup-uuid",  // Different tenant
     "role": "developer",              // Different role
     ...
   }
   ```

4. **Dashboard shows new tenant's data**
   - All metrics, charts, and data for "Tech Startup Inc"
   - Complete context switch

---

## 📊 Dashboard Components and Tenant Filtering

### **All Dashboard Modules Filter by Tenant**

| Module | Data Filtered | Location |
|--------|--------------|----------|
| **Dashboard Stats** | All metrics, charts, activities | `dashboard.service.ts` |
| **Coaching Tracker** | Coaching sessions | `coaching-session.service.ts` |
| **Quality Scorecard** | Scorecards | `quality-scorecard.service.ts` |
| **Squads** | Squad list | `squad.service.ts` |
| **Users** | User list | `user.service.ts` |
| **Maturity Ladder** | Maturity assessments | `maturity-assessment.service.ts` |
| **Test Debt** | Test debt items | `test-debt.service.ts` |
| **Feedback Form** | Feedback submissions | `feedback.service.ts` |

**Pattern:** Every service function receives `tenantId` and filters queries:
```typescript
// Standard pattern in all services
export const getSomeData = async (tenantId: string) => {
  return await SomeModel.findAll({
    where: { tenantId }
  });
};
```

---

## 🎯 Key Points

### ✅ What Happens

1. **User selects ONE tenant during login**
2. **Token includes tenantId**
3. **All API requests include token**
4. **Backend extracts tenantId from token**
5. **All database queries filter by tenantId**
6. **Dashboard shows ONLY selected tenant's data**

### ✅ Data Isolation

- **Complete separation** between tenants
- **No cross-tenant data leakage**
- **Database-level filtering** ensures security
- **Token-based context** prevents tampering

### ✅ User Experience

- **Clear tenant context** - User knows which tenant they're viewing
- **Consistent filtering** - All modules show same tenant's data
- **Easy switching** - Logout and login to switch tenants

---

## 🔍 Example Scenario

### **User: John Doe**

**Tenant Associations:**
- Tenant A: "Acme Corporation" (Role: Admin)
- Tenant B: "Tech Startup Inc" (Role: Developer)

### **Scenario 1: Logged into Tenant A**

1. **Login:** Selects "Acme Corporation"
2. **Token:** `{ tenantId: "acme-uuid", role: "admin" }`
3. **Dashboard Shows:**
   - Squads: Only Acme's squads
   - Coaching Sessions: Only Acme's sessions
   - Users: Only Acme's users
   - Metrics: Only Acme's metrics

### **Scenario 2: Switches to Tenant B**

1. **Logout:** Clears session
2. **Login:** Selects "Tech Startup Inc"
3. **Token:** `{ tenantId: "tech-startup-uuid", role: "developer" }`
4. **Dashboard Shows:**
   - Squads: Only Tech Startup's squads
   - Coaching Sessions: Only Tech Startup's sessions
   - Users: Only Tech Startup's users
   - Metrics: Only Tech Startup's metrics
   - **Different role** - May see different UI/permissions

---

## 🛡️ Security Guarantees

### **1. Token-Based Isolation**
- `tenantId` in token cannot be modified (cryptographically signed)
- Backend verifies token signature
- Invalid tokens rejected

### **2. Middleware Enforcement**
- Every authenticated request goes through auth middleware
- `req.tenantId` set automatically from token
- Controllers cannot bypass tenant filtering

### **3. Database-Level Filtering**
- All queries include `where: { tenantId }`
- Database enforces filtering
- No application-level filtering needed

### **4. No Cross-Tenant Access**
- User cannot access other tenants' data
- Even with direct API calls, tenantId from token is used
- Complete isolation guaranteed

---

## 📝 Code Examples

### **Frontend: Dashboard Component**

```typescript
// coachqa-ui/src/pages/Dashboard.tsx
const Dashboard = () => {
  const { user } = useTenantAuth(); // User has tenantId
  
  useEffect(() => {
    const loadDashboardStats = async () => {
      // API call automatically includes token with tenantId
      const response = await fetchDashboardStats();
      const stats = await apiCall<DashboardStats>(Promise.resolve(response));
      setStats(stats); // Stats filtered by tenant
    };
    loadDashboardStats();
  }, []);
  
  // Display tenant-specific data
  return (
    <Box>
      <Typography>Welcome back, {user?.name}</Typography>
      {/* All metrics are tenant-specific */}
      <Metrics metrics={stats.metrics} />
    </Box>
  );
};
```

### **Backend: Dashboard Controller**

```typescript
// coachqa-backend/src/controllers/dashboard.controller.ts
export const getDashboardStats = async (req, res, next) => {
  const tenantId = req.tenantId!; // From token via middleware
  
  const stats = await dashboardService.getDashboardStats(tenantId);
  // Returns ONLY data for this tenant
  
  res.json({ success: true, data: stats });
};
```

### **Backend: Dashboard Service**

```typescript
// coachqa-backend/src/services/dashboard.service.ts
export const getDashboardStats = async (tenantId: string) => {
  // All queries filter by tenantId
  const [coachingSessions, scorecards, squads] = await Promise.all([
    CoachingSession.findAll({ where: { tenantId } }),
    QualityScorecard.findAll({ where: { tenantId } }),
    Squad.findAll({ where: { tenantId } }),
  ]);
  
  // Calculate metrics from tenant-specific data
  return {
    metrics: {
      teamsCoached: uniqueSquadsWithCoaching,
      totalSquads: squads.length,
      // ... all metrics for this tenant only
    }
  };
};
```

---

## 🔄 Future Enhancements (Potential)

### **Tenant Switcher (Not Currently Implemented)**

A potential future feature could allow switching tenants without logout:

1. **Store all tenant associations** in localStorage
2. **Add tenant switcher dropdown** in header
3. **On tenant switch:**
   - Call `loginWithTenant(userId, newTenantId)`
   - Generate new token with new tenantId
   - Refresh dashboard data
   - Update UI

**Current Limitation:** Requires logout/login to switch tenants.

---

## 🎯 Summary

**How Multi-Tenant Dashboard Works:**

1. ✅ **User selects ONE tenant** during login
2. ✅ **Token includes tenantId** for selected tenant
3. ✅ **All API requests** include token automatically
4. ✅ **Backend extracts tenantId** from token via middleware
5. ✅ **All database queries** filter by `tenantId`
6. ✅ **Dashboard displays** only selected tenant's data
7. ✅ **Complete data isolation** between tenants
8. ✅ **To switch tenants:** Logout and login with different tenant

**Key Security Features:**
- Token-based tenant context (cannot be tampered)
- Middleware enforcement (automatic tenant filtering)
- Database-level filtering (guaranteed isolation)
- No cross-tenant access possible

**User Experience:**
- Clear tenant context
- Consistent filtering across all modules
- Easy tenant switching (logout/login)

The dashboard ensures users only see and interact with data from their currently selected tenant, providing complete data isolation and security.
