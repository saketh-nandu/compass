-- ============================================================================
-- DIAGNOSE AUTHENTICATION ISSUE
-- ============================================================================
-- Run this script to understand why login is failing
-- ============================================================================

-- Step 1: Check if auth.users table exists and has users
SELECT 'STEP 1: Checking auth.users table' as diagnostic;
SELECT COUNT(*) as total_auth_users FROM auth.users;
SELECT id, email, created_at FROM auth.users LIMIT 10;

-- Step 2: Check if public.users table exists and has users
SELECT 'STEP 2: Checking public.users table' as diagnostic;
SELECT COUNT(*) as total_public_users FROM public.users;
SELECT id, email, display_name FROM public.users LIMIT 10;

-- Step 3: Check for specific test users in auth.users
SELECT 'STEP 3: Looking for test users in auth.users' as diagnostic;
SELECT id, email, created_at FROM auth.users 
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');

-- Step 4: Check for specific test users in public.users
SELECT 'STEP 4: Looking for test users in public.users' as diagnostic;
SELECT id, email, display_name FROM public.users 
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');

-- Step 5: Check if trigger exists
SELECT 'STEP 5: Checking if trigger exists' as diagnostic;
SELECT trigger_name, event_manipulation, event_object_table 
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- Step 6: Check if function exists
SELECT 'STEP 6: Checking if function exists' as diagnostic;
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name = 'handle_new_user';

-- Step 7: Check RLS policies on users table
SELECT 'STEP 7: Checking RLS policies on public.users' as diagnostic;
SELECT policyname, permissive, roles, qual, with_check 
FROM pg_policies 
WHERE tablename = 'users';

-- Step 8: Check if RLS is enabled on users table
SELECT 'STEP 8: Checking if RLS is enabled' as diagnostic;
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('users', 'messages', 'device_tokens');

-- Step 9: Check storage buckets
SELECT 'STEP 9: Checking storage buckets' as diagnostic;
SELECT id, name, public FROM storage.buckets;

-- Step 10: Summary
SELECT 'STEP 10: SUMMARY' as diagnostic;
SELECT 
  (SELECT COUNT(*) FROM auth.users) as auth_users_count,
  (SELECT COUNT(*) FROM public.users) as public_users_count,
  (SELECT COUNT(*) FROM storage.buckets) as storage_buckets_count;
