-- Fix RLS policies to allow authentication

-- 1. Enable RLS on users table
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing policies (if any)
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can view all profiles" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;

-- 3. Create new policies that allow authentication
-- Allow users to view all profiles (needed for chat partner selection)
CREATE POLICY "Users can view all profiles"
  ON public.users FOR SELECT
  USING (TRUE);

-- Allow authenticated users to view their own profile
CREATE POLICY "Users can view their own profile"
  ON public.users FOR SELECT
  USING (auth.uid() = id);

-- Allow authenticated users to update their own profile
CREATE POLICY "Users can update their own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);

-- Allow authenticated users to insert their own profile
CREATE POLICY "Users can insert their own profile"
  ON public.users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- 4. Enable RLS on other tables with permissive policies
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view messages they sent or received" ON public.messages;
DROP POLICY IF EXISTS "Users can insert messages they send" ON public.messages;
DROP POLICY IF EXISTS "Users can update messages they sent" ON public.messages;
DROP POLICY IF EXISTS "Users can delete messages they sent" ON public.messages;

CREATE POLICY "Users can view messages they sent or received"
  ON public.messages FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = recipient_id);

CREATE POLICY "Users can insert messages they send"
  ON public.messages FOR INSERT
  WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can update messages they sent"
  ON public.messages FOR UPDATE
  USING (auth.uid() = sender_id);

CREATE POLICY "Users can delete messages they sent"
  ON public.messages FOR DELETE
  USING (auth.uid() = sender_id);

-- 5. Verify policies
SELECT tablename, policyname, permissive 
FROM pg_policies 
WHERE tablename IN ('users', 'messages')
ORDER BY tablename, policyname;
