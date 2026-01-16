# Subscription-Based Feature Gating - Implementation Summary

## Overview

Subscription-based feature gating has been implemented to restrict feature access based on tenant subscription plans (Starter, Growth, Enterprise) as defined in the pricing comparison table.

## Implementation Details

### Backend Implementation

#### 1. Subscription Plan Configuration
**File:** `QEnabler-backend/src/subscription/planConfig.ts`

- Defines three subscription plans: Starter, Growth, Enterprise
- Maps each plan to its allowed features based on the comparison table
- Provides helper functions:
  - `getPlanCodeFromPlan()` - Resolves plan code from plan ID or code
  - `planHasFeature()` - Checks if a plan has access to a specific feature

#### 2. Subscription Service
**File:** `QEnabler-backend/src/services/subscription.service.ts`

- `getAllSubscriptionPlans()` - Lists all active subscription plans
- `getSubscriptionPlanByCode()` - Gets plan by code
- `updateTenantSubscription()` - Updates tenant's subscription plan
- `seedSubscriptionPlans()` - Seeds Starter, Growth, Enterprise plans in database

#### 3. Subscription Controller
**File:** `QEnabler-backend/src/controllers/subscription.controller.ts`

- `getAllSubscriptionPlans()` - API endpoint to list plans
- `seedSubscriptionPlans()` - API endpoint to seed plans
- `updateTenantSubscription()` - API endpoint to update tenant subscription
- `getSubscriptionEntitlements()` - Returns tenant's plan and allowed features
- `requireFeature()` - Middleware to guard routes by subscription feature

#### 4. Tenant Model Updates
**File:** `QEnabler-backend/src/models/Tenant.ts`

- Uncommented subscription fields:
  - `subscriptionPlanId` - Foreign key to subscription_plans table
  - `subscriptionStatus` - active/suspended/cancelled/trial
  - `subscriptionStartDate` - When subscription started
  - `subscriptionEndDate` - When subscription ends

#### 5. Tenant Controller Updates
**File:** `QEnabler-backend/src/controllers/tenant.controller.ts`

- `getCurrentTenant()` - Now includes `subscriptionPlanCode` and `subscriptionPlan` in response

#### 6. Auth Service Updates
**File:** `QEnabler-backend/src/services/auth.service.ts`

- `registerTenant()` - New tenants default to Starter plan
- Automatically seeds plans if they don't exist

#### 7. Route Guards
**Files:** 
- `QEnabler-backend/src/routes/test-debt.routes.ts`
- `QEnabler-backend/src/routes/change-tracker.routes.ts`

- Added `requireFeature()` middleware to protect routes:
  - Test Debt Register routes require `test_debt_register` feature
  - Change Tracker routes require `change_management` feature

#### 8. API Routes
**Files:**
- `QEnabler-backend/src/routes/tenant.routes.ts` - Added `/api/tenants/subscription/entitlements`
- `QEnabler-backend/src/routes/platformAdmin.routes.ts` - Added subscription management routes

### Frontend Implementation

#### 1. Subscription Plan Configuration
**File:** `QEnabler-ui/src/subscription/planConfig.ts`

- Frontend mirror of backend plan configuration
- Ensures consistency between frontend and backend

#### 2. Subscription Context
**File:** `QEnabler-ui/src/subscription/SubscriptionContext.tsx`

- `SubscriptionProvider` - React context provider
- `useSubscription()` - Hook to access subscription data
- Fetches plan from backend API (`/api/tenants/me` or `/api/tenants/subscription/entitlements`)
- Provides `hasFeature()` method to check feature access

#### 3. Feature Gate Component
**File:** `QEnabler-ui/src/subscription/FeatureGate.tsx`

- Wraps protected content
- Shows upsell message if feature is not available
- Displays current plan and required plan tier

#### 4. Navigation Gating
**File:** `QEnabler-ui/src/layouts/tenant/Sidebar.tsx`

- Filters menu items based on subscription features
- Maps menu paths to subscription feature keys
- Hides Growth/Enterprise-only features from Starter users

#### 5. Page-Level Gating
**File:** `QEnabler-ui/src/App.tsx`

- Wrapped key routes with `FeatureGate`:
  - `/dashboard/squads` - Requires `squad_management` (Growth+)
  - `/dashboard/test-debt` - Requires `test_debt_register` (Growth+)
  - `/dashboard/change-tracker` - Requires `change_management` (Growth+)
  - `/dashboard/impact-timeline` - Requires `impact_timeline` (Growth+)
  - `/dashboard/career-framework` - Requires `career_framework` (Enterprise)

#### 6. Platform Admin Subscription Management
**File:** `QEnabler-ui/src/pages/platform-admin/TenantDetails.tsx`

- Added "Subscription" tab
- Shows current subscription plan
- Dropdown to change tenant's subscription plan
- Table showing all available plans with pricing

#### 7. API Utilities
**File:** `QEnabler-ui/src/utils/api.ts`

- `fetchSubscriptionEntitlements()` - Fetches tenant's subscription entitlements
- `fetchSubscriptionPlans()` - Lists all subscription plans
- `seedSubscriptionPlans()` - Seeds subscription plans
- `updateTenantSubscription()` - Updates tenant subscription

## Feature Mapping

### Starter Plan Features
- Coaching Tracker
- Quality Scorecard (Basic)
- Maturity Ladder (Team-level)
- Feedback Form

### Growth Plan Features (includes all Starter features)
- Test Debt Register
- Change Management
- Squad Management
- Impact Timeline
- Enablement Hub (Basic)
- Integrations (Limited)
- Quality Scorecard (Advanced)
- Maturity Ladder (Org-level)

### Enterprise Plan Features (includes all Growth features)
- Career Framework
- Exploratory Testing
- Integrations (Full)
- Quality Scorecard (Custom)
- Maturity Ladder (Org + Squad)
- Enablement Hub (Advanced)

## API Endpoints

### Tenant Endpoints
- `GET /api/tenants/me` - Returns tenant info including `subscriptionPlanCode`
- `GET /api/tenants/subscription/entitlements` - Returns subscription entitlements

### Platform Admin Endpoints
- `GET /api/platform-admin/subscription-plans` - List all subscription plans
- `POST /api/platform-admin/subscription-plans/seed` - Seed subscription plans
- `PUT /api/platform-admin/tenants/:tenantId/subscription` - Update tenant subscription

## Security

### Backend Guards
- Test Debt Register routes are protected by `requireFeature('test_debt_register')`
- Change Tracker routes are protected by `requireFeature('change_management')`
- Returns 403 Forbidden if tenant doesn't have required feature

### Frontend Guards
- Navigation items are filtered based on subscription features
- Page-level `FeatureGate` components prevent access to restricted features
- Upsell messages guide users to upgrade

## Testing

See `SUBSCRIPTION_TESTING_GUIDE.md` for comprehensive testing scenarios.

## Next Steps (Future Enhancements)

1. **Billing Integration** - Connect with Stripe or similar for payment processing
2. **Usage Limits** - Enforce squad/user limits per plan
3. **Trial Periods** - Support trial subscriptions
4. **Subscription History** - Track subscription changes over time
5. **Automated Upgrades/Downgrades** - Handle plan changes via billing system

## Notes

- Subscription plans are tenant-level, not per-user
- Existing RBAC/roles work alongside subscription plans (both must allow access)
- Default plan for new tenants is Starter
- Plans are automatically seeded if they don't exist in the database
