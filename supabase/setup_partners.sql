-- ============================================================================
-- SETUP PARTNER RELATIONSHIPS
-- ============================================================================
-- Run this after creating users to set up the partner relationships
-- saketh_nandu127 ↔ srirenu127
-- ============================================================================

-- Step 1: Get user IDs
SELECT 'Step 1: Getting user IDs' as step;
SELECT id, email FROM public.users 
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');

-- Step 2: Set up partner relationships
-- saketh's partner is srirenu
UPDATE public.users 
SET partner_id = (
  SELECT id FROM public.users 
  WHERE email = 'srirenu127@example.com'
)
WHERE email = 'saketh_nandu127@example.com';

-- srirenu's partner is saketh
UPDATE public.users 
SET partner_id = (
  SELECT id FROM public.users 
  WHERE email = 'saketh_nandu127@example.com'
)
WHERE email = 'srirenu127@example.com';

-- Step 3: Verify relationships
SELECT 'Step 3: Verifying partner relationships' as step;
SELECT 
  u.email,
  u.display_name,
  p.email as partner_email,
  p.display_name as partner_name
FROM public.users u
LEFT JOIN public.users p ON u.partner_id = p.id
WHERE u.email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');

SELECT 'Partner setup complete!' as result;
