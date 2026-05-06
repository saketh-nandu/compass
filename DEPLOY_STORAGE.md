# Deploy Storage System - Step by Step

## Prerequisites
- Supabase project set up
- Supabase CLI installed
- Flutter app running locally
- Test users created in Supabase

## Deployment Steps

### Step 1: Push Database Migrations

```bash
# Navigate to project directory
cd my_app

# Push migrations to Supabase
supabase db push
```

**What this does:**
- Creates 3 storage buckets: chat-media, avatars, recordings
- Sets up Row Level Security (RLS) policies
- Configures file size limits
- Sets MIME type restrictions

**Expected output:**
```
Initialising login role...
Connecting to remote database...
Do you want to push these migrations to the remote database?
• 20260506083351_add_test_users.sql [Y/n] y
Applying migration 20260506083351_add_test_users.sql...
✓ Migration applied successfully
```

### Step 2: Verify Storage Buckets in Supabase Dashboard

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to **Storage** section
4. Verify these buckets exist:
   - ✅ chat-media
   - ✅ avatars
   - ✅ recordings

**Expected bucket settings:**

**chat-media:**
- Public: Yes
- Size limit: 50 MB
- Allowed types: image/*, video/*, audio/*, application/*

**avatars:**
- Public: Yes
- Size limit: 2 MB
- Allowed types: image/*

**recordings:**
- Public: Yes
- Size limit: 100 MB
- Allowed types: audio/*, video/*

### Step 3: Verify RLS Policies

1. In Supabase Dashboard, go to **Storage** → **Policies**
2. Verify these policies exist:

**For chat-media bucket:**
- Users can upload their own files
- Users can view their own files
- Users can update their own files
- Users can delete their own files

**For avatars bucket:**
- Avatar images are publicly accessible
- Users can upload their own avatar
- Users can update their own avatar
- Users can delete their own avatar

**For recordings bucket:**
- Recordings are publicly accessible
- Users can upload their own recordings
- Users can update their own recordings
- Users can delete their own recordings

### Step 4: Run Flutter App

```bash
# In my_app directory
flutter pub get
flutter run
```

### Step 5: Test Chat Image Upload

1. **Open the app** and navigate to Chat screen
2. **Tap the media picker icon** (+ button)
3. **Select "Photo Library"**
4. **Choose an image** from your device
5. **Verify:**
   - Image uploads successfully
   - Image appears in chat
   - No error messages

**Expected behavior:**
- Snackbar shows "Uploading media..."
- Image appears in chat bubble
- Snackbar disappears

### Step 6: Test Recording Upload

1. **Navigate to Recordings tab**
2. **Tap record button**
3. **Record audio** for a few seconds
4. **Stop recording**
5. **Verify:**
   - Recording uploads successfully
   - Recording appears in list
   - No error messages

**Expected behavior:**
- Recording file is created
- File uploads to storage
- Recording appears in recordings list

### Step 7: Test Avatar Upload (Optional)

1. **Go to profile settings** (if available)
2. **Select avatar image**
3. **Verify:**
   - Avatar uploads successfully
   - Avatar updates in profile
   - No error messages

### Step 8: Verify Files in Supabase Storage

1. Go to Supabase Dashboard → **Storage**
2. Check **chat-media** bucket:
   - Should see folders: `chat-images/`, `chat-videos/`, `files/`
   - Inside: `{userId}/{chatPartnerId}/` folders with uploaded files
3. Check **recordings** bucket:
   - Should see folders: `audio/`, `video/`
   - Inside: `{userId}/{chatPartnerId}/` folders with uploaded files
4. Check **avatars** bucket:
   - Should see folder: `avatars/`
   - Inside: `{userId}/` folders with avatar images

### Step 9: Verify Database Records

1. Go to Supabase Dashboard → **SQL Editor**
2. Run this query to verify message records:

```sql
SELECT 
  id,
  sender_id,
  receiver_id,
  type,
  file_url,
  file_name,
  file_size,
  created_at
FROM messages
WHERE type IN ('image', 'video', 'audio', 'file')
ORDER BY created_at DESC
LIMIT 10;
```

**Expected output:**
- Rows with file_url populated
- file_name and file_size set correctly
- type matches upload type

3. Run this query to verify recording records:

```sql
SELECT 
  id,
  sender_id,
  recipient_id,
  recording_type,
  recording_url,
  file_size,
  created_at
FROM recordings
ORDER BY created_at DESC
LIMIT 10;
```

**Expected output:**
- Rows with recording_url populated
- recording_type is 'audio' or 'video'
- file_size set correctly

### Step 10: Monitor Storage Usage

1. Go to Supabase Dashboard → **Storage**
2. Check storage usage for each bucket
3. Monitor file uploads over time

## Troubleshooting

### Issue: Buckets not created
**Solution:**
```bash
# Check migration status
supabase db push --debug

# If migration failed, check SQL syntax
# Review: supabase/migrations/20260506083351_add_test_users.sql
```

### Issue: Upload fails with "Permission denied"
**Solution:**
1. Verify RLS policies are created
2. Check user is authenticated
3. Verify bucket is public (for avatars/recordings)
4. Check file size is within limit

### Issue: File URL returns 404
**Solution:**
1. Verify file was uploaded to correct bucket
2. Check file path in Supabase Storage
3. Verify bucket is public
4. Check file hasn't been deleted

### Issue: CORS errors in browser console
**Solution:**
1. Go to Supabase Dashboard → **Project Settings** → **API**
2. Check CORS settings
3. Add your domain if needed
4. Restart app

### Issue: Slow uploads
**Solution:**
1. Check file size (should be within limits)
2. Check network speed
3. Consider compressing files
4. Use signed URLs for large files

## Rollback (If Needed)

If you need to rollback the storage setup:

```bash
# Reset database to previous state
supabase db reset

# This will:
# - Drop all tables
# - Drop all storage buckets
# - Re-run all migrations from scratch
```

**Warning:** This will delete all data!

## Post-Deployment Checklist

- [ ] Migrations pushed successfully
- [ ] Storage buckets created in Supabase
- [ ] RLS policies applied
- [ ] Chat image upload working
- [ ] Chat video upload working
- [ ] Recording upload working
- [ ] Files visible in Supabase Storage
- [ ] Database records created correctly
- [ ] File URLs accessible
- [ ] No error messages in app
- [ ] No CORS errors in console
- [ ] Storage usage monitored

## Performance Optimization (Optional)

### Enable CDN for Faster Delivery
```sql
-- In Supabase SQL Editor
UPDATE storage.buckets 
SET cache_control = '3600'
WHERE id IN ('chat-media', 'avatars', 'recordings');
```

### Implement Image Compression
Add to `lib/services/storage_service.dart`:
```dart
// Compress image before upload
final compressedFile = await _compressImage(imageFile);
await _supabase.storage.from(chatMediaBucket).upload(
  fileName,
  compressedFile,
);
```

### Add Upload Progress Tracking
```dart
// Show progress during upload
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Uploading: ${progress.toStringAsFixed(0)}%')),
);
```

## Monitoring

### Check Storage Usage
```sql
SELECT 
  bucket_id,
  COUNT(*) as file_count,
  SUM(metadata->>'size')::bigint as total_size
FROM storage.objects
GROUP BY bucket_id;
```

### Check Upload Errors
```sql
SELECT 
  id,
  sender_id,
  receiver_id,
  type,
  file_url,
  created_at
FROM messages
WHERE file_url IS NULL AND type IN ('image', 'video', 'audio', 'file')
ORDER BY created_at DESC;
```

## Support

- **Documentation**: See `STORAGE_SETUP_GUIDE.md`
- **Quick Start**: See `STORAGE_QUICK_START.md`
- **Implementation**: See `STORAGE_IMPLEMENTATION_COMPLETE.md`
- **Code**: See `lib/services/storage_service.dart`

## Next Steps

1. ✅ Deploy storage system
2. ✅ Test all upload types
3. ✅ Monitor storage usage
4. 📋 Implement compression (optional)
5. 📋 Add progress indicators (optional)
6. 📋 Set up automated cleanup (optional)

---

**Deployment Status**: Ready to Deploy! 🚀
