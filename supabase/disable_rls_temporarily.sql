-- TEMPORARY: Disable RLS to diagnose the issue
-- This is for debugging only - re-enable RLS after testing

-- Disable RLS on users table
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- Disable RLS on messages table
ALTER TABLE public.messages DISABLE ROW LEVEL SECURITY;

-- Disable RLS on other tables
ALTER TABLE public.typing_indicators DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.memories DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.recordings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_tokens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_preferences DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_logs DISABLE ROW LEVEL SECURITY;

-- Verify RLS is disabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;

-- Now try to login in the app
-- If it works, the issue is with RLS policies
-- If it still fails, the issue is elsewhere
