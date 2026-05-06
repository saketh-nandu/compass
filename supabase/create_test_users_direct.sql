-- Create test users directly in public.users table
-- NOTE: Users must first exist in auth.users table (create via Supabase Dashboard)
-- Then run this script to create their profiles

-- Step 1: Check if auth users exist
SELECT id, email FROM auth.users 
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');

-- Step 2: Create user profiles in public.users
-- Male user
INSERT INTO public.users (id, email, display_name, status, metadata)
SELECT 
  id,
  email,
  'Saketh Nandu',
  'offline',
  jsonb_build_object('gender', 'male')
FROM auth.users
WHERE email = 'saketh_nandu127@example.com'
ON CONFLICT (id) DO UPDATE SET
  display_name = 'Saketh Nandu',
  status = 'offline',
  metadata = jsonb_build_object('gender', 'male');

-- Female user
INSERT INTO public.users (id, email, display_name, status, metadata)
SELECT 
  id,
  email,
  'Sri Renu',
  'offline',
  jsonb_build_object('gender', 'female')
FROM auth.users
WHERE email = 'srirenu127@example.com'
ON CONFLICT (id) DO UPDATE SET
  display_name = 'Sri Renu',
  status = 'offline',
  metadata = jsonb_build_object('gender', 'female');

-- Step 3: Verify users were created
SELECT id, email, display_name, status, metadata FROM public.users 
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');
