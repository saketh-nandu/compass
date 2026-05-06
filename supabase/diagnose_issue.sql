-- Diagnostic script to find the issue

-- 1. Check if users table exists
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'users'
) as users_table_exists;

-- 2. Check users table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'users' AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. Check if RLS is enabled on users table
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'users';

-- 4. Check RLS policies on users table
SELECT policyname, permissive, roles, qual, with_check 
FROM pg_policies 
WHERE tablename = 'users';

-- 5. Check if auth.users table exists
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'auth' 
  AND table_name = 'users'
) as auth_users_exists;

-- 6. Count users in auth.users
SELECT COUNT(*) as auth_users_count FROM auth.users;

-- 7. Count users in public.users
SELECT COUNT(*) as public_users_count FROM public.users;

-- 8. Check for any foreign key issues
SELECT constraint_name, table_name, column_name, foreign_table_name, foreign_column_name
FROM information_schema.key_column_usage
WHERE table_name = 'users' AND table_schema = 'public';

-- 9. Try a simple select (this might fail if RLS is blocking)
SELECT id, email FROM public.users LIMIT 1;
