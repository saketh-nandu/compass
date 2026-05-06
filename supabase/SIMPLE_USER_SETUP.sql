-- ============================================================================
-- SIMPLE USER SETUP - RUN THIS IF LOGIN IS FAILING
-- ============================================================================
-- This script creates test users directly in the auth.users table
-- WARNING: This bypasses normal Supabase auth flow - use only for testing
-- ============================================================================

-- Step 1: Check current users
SELECT 'Current users in auth.users:' as step;
SELECT id, email FROM auth.users;

-- Step 2: Check if test users already exist
SELECT 'Checking for existing test users:' as step;
SELECT id, email FROM auth.users 
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');

-- Step 3: If users don't exist, you MUST create them via Supabase Dashboard
-- Go to: Supabase Dashboard → Authentication → Users → Add user
-- Then come back and run the sync script

-- Step 4: Sync users to public.users table
SELECT 'Syncing users to public.users:' as step;

INSERT INTO public.users (id, email, display_name, status)
SELECT 
  id,
  email,
  COALESCE(raw_user_meta_data->>'display_name', split_part(email, '@', 1)),
  'offline'
FROM auth.users
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com')
ON CONFLICT (id) DO UPDATE SET
  display_name = COALESCE(EXCLUDED.display_name, public.users.display_name),
  updated_at = NOW();

-- Step 5: Verify sync
SELECT 'Users in public.users after sync:' as step;
SELECT id, email, display_name FROM public.users 
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');

-- Step 6: Create notification preferences
SELECT 'Creating notification preferences:' as step;

INSERT INTO public.notification_preferences (user_id, message_notifications, typing_notifications, sound_enabled, vibration_enabled)
SELECT 
  id,
  TRUE,
  TRUE,
  TRUE,
  TRUE
FROM public.users
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com')
ON CONFLICT (user_id) DO NOTHING;

-- Step 7: Final check
SELECT 'FINAL VERIFICATION:' as step;
SELECT 
  'auth.users' as table_name,
  COUNT(*) as count
FROM auth.users
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com')
UNION ALL
SELECT 
  'public.users' as table_name,
  COUNT(*) as count
FROM public.users
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com')
UNION ALL
SELECT 
  'notification_preferences' as table_name,
  COUNT(*) as count
FROM public.notification_preferences
WHERE user_id IN (
  SELECT id FROM public.users 
  WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com')
);

SELECT 'Setup complete! Try logging in now.' as result;
