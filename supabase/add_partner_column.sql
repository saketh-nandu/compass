-- ============================================================================
-- ADD PARTNER_ID COLUMN TO USERS TABLE
-- ============================================================================
-- Run this if you get "column partner_id does not exist" error
-- ============================================================================

-- Step 1: Check if column exists
SELECT 'Step 1: Checking if partner_id column exists' as step;
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'users' AND column_name = 'partner_id';

-- Step 2: Add partner_id column if it doesn't exist
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS partner_id UUID REFERENCES public.users(id) ON DELETE SET NULL;

-- Step 3: Verify column was added
SELECT 'Step 3: Verifying column added' as step;
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'users' AND column_name = 'partner_id';

-- Step 4: Now set up partner relationships
SELECT 'Step 4: Setting up partner relationships' as step;

-- Get user IDs
SELECT id, email FROM public.users 
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');

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

-- Step 5: Verify relationships
SELECT 'Step 5: Verifying partner relationships' as step;
SELECT 
  u.email,
  u.display_name,
  p.email as partner_email,
  p.display_name as partner_name
FROM public.users u
LEFT JOIN public.users p ON u.partner_id = p.id
WHERE u.email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');

SELECT 'Partner column added and relationships set up!' as result;
