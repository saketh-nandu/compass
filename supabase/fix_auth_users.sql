-- Fix authentication users in Supabase
-- This script creates the test users in public.users table

-- First, check the actual structure of users table
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'users' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check if users exist in auth.users table
SELECT id, email FROM auth.users 
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');

-- Check if users exist in public.users table
SELECT id, email, display_name, status FROM public.users 
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');

-- Create users in public.users table (if they don't exist in auth.users)
-- First, we need to create them in auth.users via Dashboard or CLI
-- Then run this to create their profiles:

INSERT INTO public.users (id, email, display_name, status)
SELECT 
  id,
  email,
  COALESCE(raw_user_meta_data->>'display_name', split_part(email, '@', 1)),
  'offline'
FROM auth.users
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com')
ON CONFLICT (id) DO NOTHING;

-- Verify users were created
SELECT id, email, display_name, status FROM public.users 
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');
