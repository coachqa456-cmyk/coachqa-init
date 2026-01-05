-- Diagnostic Queries for ukendiran.my@gmail.com
-- Run these to check the current state

-- 1. Check if user exists
SELECT 
  id,
  email,
  name,
  email_verified,
  created_at
FROM users 
WHERE email = 'ukendiran.my@gmail.com';

-- 2. Check all tenant associations for this user (including inactive)
SELECT 
  ut.id,
  ut.user_id,
  ut.tenant_id,
  ut.role,
  ut.status,
  ut.created_at,
  t.name as tenant_name,
  t.slug as tenant_slug
FROM user_tenants ut
LEFT JOIN tenants t ON ut.tenant_id = t.id
WHERE ut.user_id = (
  SELECT id FROM users WHERE email = 'ukendiran.my@gmail.com'
);

-- 3. Check all tenants in the system
SELECT id, name, slug, created_at FROM tenants ORDER BY created_at DESC LIMIT 10;

-- 4. Count total associations for this user
SELECT COUNT(*) as total_associations
FROM user_tenants
WHERE user_id = (SELECT id FROM users WHERE email = 'ukendiran.my@gmail.com');

-- 5. If user exists but has no associations, you can manually create one:
-- First, get the user ID and pick/create a tenant, then:
/*
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
  'admin',
  'active',
  NOW(),
  NOW()
FROM users u
CROSS JOIN (
  SELECT id FROM tenants ORDER BY created_at DESC LIMIT 1
) t
WHERE u.email = 'ukendiran.my@gmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM user_tenants ut
    WHERE ut.user_id = u.id AND ut.tenant_id = t.id
  );
*/


