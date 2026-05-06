-- ============================================================================
-- COMPASS APP - CLEAN SETUP (Run this if FRESH_PROJECT_SETUP.sql had errors)
-- ============================================================================
-- This is a clean version that handles already-existing tables and policies
-- ============================================================================

-- Step 1: Verify tables exist
SELECT 'Step 1: Verifying tables' as step;
SELECT COUNT(*) as tables_count FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name IN (
  'users', 'messages', 'typing_indicators', 'memories', 'recordings', 
  'device_tokens', 'notification_preferences', 'notification_logs'
);

-- Step 2: Verify storage buckets
SELECT 'Step 2: Verifying storage buckets' as step;
SELECT id, name FROM storage.buckets 
WHERE id IN ('chat-media', 'avatars', 'recordings');

-- Step 3: Verify RLS is enabled
SELECT 'Step 3: Verifying RLS enabled' as step;
SELECT tablename, rowsecurity FROM pg_tables 
WHERE schemaname = 'public' AND tablename IN (
  'users', 'messages', 'typing_indicators', 'memories', 'recordings',
  'device_tokens', 'notification_preferences', 'notification_logs'
);

-- Step 4: Verify realtime is enabled
SELECT 'Step 4: Verifying realtime tables' as step;
SELECT schemaname, tablename FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime';

-- Step 5: Verify trigger exists
SELECT 'Step 5: Verifying trigger' as step;
SELECT trigger_name FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- Step 6: Verify function exists
SELECT 'Step 6: Verifying function' as step;
SELECT routine_name FROM information_schema.routines 
WHERE routine_name = 'handle_new_user';

-- Step 7: Final summary
SELECT 'Setup verification complete!' as result;
