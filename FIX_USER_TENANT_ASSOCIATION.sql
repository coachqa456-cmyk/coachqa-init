-- Fix: Create User-Tenant Association for Google OAuth User
-- Run this in your PostgreSQL database

-- Step 1: Find the user
SELECT id, email, name FROM users WHERE email = 'ukendiran.my@gmail.com';

-- Step 2: Find or create a tenant (if needed)
-- Option A: Use existing tenant
SELECT id, name, slug FROM tenants LIMIT 1;

-- Option B: Create new tenant (if none exists)
-- INSERT INTO tenants (id, name, slug, created_at, updated_at)
-- VALUES (gen_random_uuid(), 'Your Organization', 'your-org', NOW(), NOW())
-- RETURNING id, name;

-- Step 3: Create UserTenant association
-- Replace USER_ID and TENANT_ID with actual values from steps 1 and 2
INSERT INTO user_tenants (
  id,
  user_id,
  tenant_id,
  role,
  status,
  created_at,
  updated_at
)
SELECT
  gen_random_uuid(),
  u.id,
  t.id,
  'admin',  -- or 'developer', 'qe', 'manager', etc.
  'active',
  NOW(),
  NOW()
FROM users u
CROSS JOIN tenants t
WHERE u.email = 'ukendiran.my@gmail.com'
  AND t.id = (SELECT id FROM tenants LIMIT 1)  -- Use first tenant, or specify tenant ID
  AND NOT EXISTS (
    SELECT 1 FROM user_tenants ut
    WHERE ut.user_id = u.id AND ut.tenant_id = t.id
  )
RETURNING *;

-- Step 4: Verify the association
SELECT 
  u.email,
  u.name,
  t.name as tenant_name,
  ut.role,
  ut.status
FROM user_tenants ut
JOIN users u ON ut.user_id = u.id
JOIN tenants t ON ut.tenant_id = t.id
WHERE u.email = 'ukendiran.my@gmail.com';

