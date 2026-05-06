-- ============================================================================
-- FIX AUTH USERS SYNC
-- ============================================================================
-- This script fixes the sync between auth.users and public.users tables
-- Run this if you manually created users in Supabase Dashboard
-- ============================================================================

-- Step 1: Check if users exist in auth.users
SELECT 'Step 1: Checking auth.users' as step;
SELECT id, email FROM auth.users;

-- Step 2: Check if users exist in public.users
SELECT 'Step 2: Checking public.users' as step;
SELECT id, email, display_name FROM public.users;

-- Step 3: Manually sync users from auth.users to public.users
-- This inserts any auth users that don't have a corresponding public.users record
INSERT INTO public.users (id, email, display_name, status)
SELECT 
  au.id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'display_name', split_part(au.email, '@', 1)),
  'offline'
FROM auth.users au
WHERE NOT EXISTS (
  SELECT 1 FROM public.users pu WHERE pu.id = au.id
)
ON CONFLICT (id) DO NOTHING;

-- Step 4: Verify sync completed
SELECT 'Step 4: Verification - public.users after sync' as step;
SELECT id, email, display_name FROM public.users;

-- Step 5: Create notification preferences for users if they don't exist
INSERT INTO public.notification_preferences (user_id, message_notifications, typing_notifications, sound_enabled, vibration_enabled)
SELECT 
  pu.id,
  TRUE,
  TRUE,
  TRUE,
  TRUE
FROM public.users pu
WHERE NOT EXISTS (
  SELECT 1 FROM public.notification_preferences np WHERE np.user_id = pu.id
)
ON CONFLICT (user_id) DO NOTHING;

-- Step 6: Final verification
SELECT 'Step 6: Final verification - All users synced' as step;
SELECT 
  au.id,
  au.email,
  pu.display_name,
  CASE WHEN pu.id IS NOT NULL THEN 'SYNCED' ELSE 'MISSING' END as sync_status
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id;

SELECT 'Setup complete! Users are now synced.' as result;
