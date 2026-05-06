-- Verify and setup storage buckets for Compass app
-- Run this in Supabase SQL Editor to ensure all buckets are properly configured

-- 1. Check existing buckets
SELECT id, name, public, file_size_limit, allowed_mime_types 
FROM storage.buckets 
WHERE id IN ('chat-media', 'avatars', 'recordings')
ORDER BY id;

-- 2. Create or update buckets if they don't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('chat-media', 'chat-media', true, 52428800, ARRAY['image/*', 'video/*', 'audio/*', 'application/*']),
  ('avatars', 'avatars', true, 2097152, ARRAY['image/*']),
  ('recordings', 'recordings', true, 104857600, ARRAY['audio/*', 'video/*'])
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- 3. Verify buckets were created
SELECT id, name, public, file_size_limit, allowed_mime_types 
FROM storage.buckets 
WHERE id IN ('chat-media', 'avatars', 'recordings')
ORDER BY id;

-- 4. Check existing storage policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'objects'
ORDER BY policyname;

-- 5. Drop existing policies if they exist (optional - uncomment if needed)
-- DROP POLICY IF EXISTS "Users can upload their own files" ON storage.objects;
-- DROP POLICY IF EXISTS "Users can view their own files" ON storage.objects;
-- DROP POLICY IF EXISTS "Users can update their own files" ON storage.objects;
-- DROP POLICY IF EXISTS "Users can delete their own files" ON storage.objects;
-- DROP POLICY IF EXISTS "Avatar images are publicly accessible" ON storage.objects;
-- DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
-- DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
-- DROP POLICY IF EXISTS "Users can delete their own avatar" ON storage.objects;
-- DROP POLICY IF EXISTS "Recordings are publicly accessible" ON storage.objects;
-- DROP POLICY IF EXISTS "Users can upload their own recordings" ON storage.objects;
-- DROP POLICY IF EXISTS "Users can update their own recordings" ON storage.objects;
-- DROP POLICY IF EXISTS "Users can delete their own recordings" ON storage.objects;

-- 6. Create storage policies for chat-media bucket
CREATE POLICY "Users can upload their own files" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id IN ('chat-media', 'temp-uploads') AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can view their own files" ON storage.objects
  FOR SELECT USING (bucket_id IN ('chat-media', 'temp-uploads') AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update their own files" ON storage.objects
  FOR UPDATE USING (bucket_id IN ('chat-media', 'temp-uploads') AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own files" ON storage.objects
  FOR DELETE USING (bucket_id IN ('chat-media', 'temp-uploads') AND auth.uid()::text = (storage.foldername(name))[1]);

-- 7. Create storage policies for avatars bucket (public read)
CREATE POLICY "Avatar images are publicly accessible" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update their own avatar" ON storage.objects
  FOR UPDATE USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own avatar" ON storage.objects
  FOR DELETE USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- 8. Create storage policies for recordings bucket (public read)
CREATE POLICY "Recordings are publicly accessible" ON storage.objects
  FOR SELECT USING (bucket_id = 'recordings');

CREATE POLICY "Users can upload their own recordings" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'recordings' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update their own recordings" ON storage.objects
  FOR UPDATE USING (bucket_id = 'recordings' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own recordings" ON storage.objects
  FOR DELETE USING (bucket_id = 'recordings' AND auth.uid()::text = (storage.foldername(name))[1]);

-- 9. Verify all policies were created
SELECT 
  policyname,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'objects'
ORDER BY policyname;

-- 10. Test bucket access (verify buckets are accessible)
SELECT 
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types,
  created_at,
  updated_at
FROM storage.buckets 
WHERE id IN ('chat-media', 'avatars', 'recordings')
ORDER BY id;
