# Subscription Feature Gating - Testing Guide

This guide provides manual testing scenarios to verify subscription-based feature gating is working correctly.

## Prerequisites

1. Ensure subscription plans are seeded in the database:
   - Starter ($79/month)
   - Growth ($349/month)
   - Enterprise (Custom pricing)

2. Create or identify test tenants with different subscription plans:
   - One tenant with Starter plan
   - One tenant with Growth plan
   - One tenant with Enterprise plan

## Backend Testing

### 1. Test Subscription Plan Configuration

Verify that the plan configuration correctly maps features:

**Starter Plan Should Have:**
- ✅ coaching_tracker
- ✅ quality_scorecard_basic
- ✅ maturity_ladder_team
- ✅ feedback_form

**Starter Plan Should NOT Have:**
- ❌ test_debt_register
- ❌ change_management
- ❌ squad_management
- ❌ impact_timeline
- ❌ enablement_hub_basic
- ❌ career_framework
- ❌ exploratory_testing

**Growth Plan Should Have:**
- ✅ All Starter features
- ✅ test_debt_register
- ✅ change_management
- ✅ squad_management
- ✅ impact_timeline
- ✅ enablement_hub_basic
- ✅ integrations_limited

**Growth Plan Should NOT Have:**
- ❌ career_framework
- ❌ exploratory_testing
- ❌ integrations_full

**Enterprise Plan Should Have:**
- ✅ All Growth features
- ✅ career_framework
- ✅ exploratory_testing
- ✅ integrations_full
- ✅ quality_scorecard_custom
- ✅ maturity_ladder_org_squad
- ✅ enablement_hub_advanced

### 2. Test API Endpoints

#### GET /api/tenants/subscription/entitlements
- **As Starter tenant:** Should return planCode: "starter" and list of Starter features
- **As Growth tenant:** Should return planCode: "growth" and list of Growth features
- **As Enterprise tenant:** Should return planCode: "enterprise" and list of Enterprise features

#### GET /api/tenants/me
- Should include `subscriptionPlanCode` field
- Should include `subscriptionPlan` object with plan details

#### PUT /api/platform-admin/tenants/:tenantId/subscription
- **As Platform Admin:** Should be able to update tenant subscription plan
- Verify plan changes are reflected in subsequent API calls

### 3. Test Backend Guards

#### Test Debt Register Routes
- **Starter tenant:** All `/api/test-debt/*` routes should return 403 Forbidden
- **Growth tenant:** All `/api/test-debt/*` routes should work normally
- **Enterprise tenant:** All `/api/test-debt/*` routes should work normally

#### Change Tracker Routes
- **Starter tenant:** All `/api/change-tracker/*` routes should return 403 Forbidden
- **Growth tenant:** All `/api/change-tracker/*` routes should work normally
- **Enterprise tenant:** All `/api/change-tracker/*` routes should work normally

## Frontend Testing

### 1. Navigation Menu (Sidebar)

**Starter Plan:**
- ✅ Should see: Dashboard, Coaching Tracker, Quality Scorecard, Feedback Form, Maturity Ladder
- ❌ Should NOT see: Test Debt Register, Change Tracker, Impact Timeline, Squad Management, Enablement Hub, Career Framework, Test Logger

**Growth Plan:**
- ✅ Should see: All Starter features + Test Debt Register, Change Tracker, Impact Timeline, Squad Management, Enablement Hub
- ❌ Should NOT see: Career Framework, Test Logger (Exploratory Testing)

**Enterprise Plan:**
- ✅ Should see: All features including Career Framework and Test Logger

### 2. Page Access

**Test Debt Register Page (`/dashboard/test-debt`):**
- **Starter:** Should show FeatureGate upsell message
- **Growth:** Should show full page
- **Enterprise:** Should show full page

**Change Tracker Page (`/dashboard/change-tracker`):**
- **Starter:** Should show FeatureGate upsell message
- **Growth:** Should show full page
- **Enterprise:** Should show full page

**Career Framework Page (`/dashboard/career-framework`):**
- **Starter:** Should show FeatureGate upsell message
- **Growth:** Should show FeatureGate upsell message
- **Enterprise:** Should show full page

**Squad Management Page (`/dashboard/squads`):**
- **Starter:** Should show FeatureGate upsell message
- **Growth:** Should show full page
- **Enterprise:** Should show full page

**Impact Timeline Page (`/dashboard/impact-timeline`):**
- **Starter:** Should show FeatureGate upsell message
- **Growth:** Should show full page
- **Enterprise:** Should show full page

### 3. Subscription Context

- Verify that `useSubscription()` hook returns correct plan code
- Verify that `hasFeature()` correctly identifies feature access
- Verify plan is fetched from backend on login (not localStorage)

### 4. Platform Admin Subscription Management

1. Navigate to Platform Admin → Tenants → Select a tenant
2. Go to "Subscription" tab
3. Verify current plan is displayed
4. Change plan from dropdown
5. Verify plan update is saved
6. Log in as that tenant and verify features match new plan

## Test Scenarios

### Scenario 1: Starter Tenant User Journey
1. Log in as Starter tenant user
2. Verify sidebar shows only Starter-available features
3. Try to navigate to `/dashboard/test-debt` directly
4. Verify upsell message is shown
5. Verify API calls to test-debt endpoints return 403

### Scenario 2: Growth Tenant User Journey
1. Log in as Growth tenant user
2. Verify sidebar shows Growth-available features
3. Navigate to Test Debt Register - should work
4. Navigate to Change Tracker - should work
5. Try to navigate to Career Framework - should show upsell

### Scenario 3: Enterprise Tenant User Journey
1. Log in as Enterprise tenant user
2. Verify sidebar shows all features
3. Navigate to all feature pages - all should work
4. Verify no upsell messages appear

### Scenario 4: Plan Upgrade Flow
1. As Platform Admin, change tenant from Starter to Growth
2. Log in as that tenant user
3. Verify new features appear in sidebar
4. Verify previously blocked pages now work

### Scenario 5: Plan Downgrade Flow
1. As Platform Admin, change tenant from Enterprise to Starter
2. Log in as that tenant user
3. Verify Enterprise-only features disappear from sidebar
4. Verify previously accessible pages now show upsell

## Verification Checklist

- [ ] Backend plan configuration matches feature table
- [ ] Subscription plans are seeded in database
- [ ] Tenant creation defaults to Starter plan
- [ ] API endpoints return correct subscription data
- [ ] Backend guards block unauthorized feature access
- [ ] Frontend navigation respects subscription plans
- [ ] FeatureGate component shows correct upsell messages
- [ ] Subscription context fetches plan from backend
- [ ] Platform admin can manage tenant subscriptions
- [ ] Plan changes are reflected immediately in UI

## Troubleshooting

### Issue: Features not gating correctly
- Check that tenant has subscriptionPlanId set in database
- Verify subscription plan code matches exactly ('starter', 'growth', 'enterprise')
- Check browser console for API errors

### Issue: Backend guards not working
- Verify requireFeature middleware is applied to routes
- Check that tenant subscription plan is loaded correctly
- Verify planHasFeature function logic

### Issue: Frontend not showing correct plan
- Check network tab for `/api/tenants/me` response
- Verify subscriptionPlanCode is in response
- Check SubscriptionContext useEffect is running
