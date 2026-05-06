# Compass App - Troubleshooting Guide

## Issue: Login Failed - Invalid Credentials

### Root Causes

1. **Users not synced to public.users table** - You manually created users in Supabase Dashboard, but they weren't automatically added to the `public.users` table
2. **Trigger not firing** - The `on_auth_user_created` trigger may not have executed
3. **Wrong Supabase credentials** - The app is pointing to the wrong Supabase project
4. **Firebase not configured** - The app was crashing on Firebase initialization

### Solution

#### Step 1: Fix Firebase Initialization (DONE ✓)
The app now gracefully handles Firebase initialization errors. If Firebase is not configured, the app will still work without push notifications.

#### Step 2: Sync Auth Users to public.users

1. Go to your Supabase project → SQL Editor
2. Click "New Query"
3. Copy the entire content from `supabase/fix_auth_users_sync.sql`
4. Paste it into the SQL editor
5. Click "Run"
6. Check the output - you should see:
   - List of users in `auth.users`
   - List of users in `public.users` after sync
   - Sync status showing "SYNCED" for all users

#### Step 3: Verify Users Are Created

After running the sync script, verify:

1. **Check auth.users table:**
   ```sql
   SELECT id, email FROM auth.users;
   ```
   Should show your test users:
   - `saketh_nandu127@example.com`
   - `srirenu127@example.com`

2. **Check public.users table:**
   ```sql
   SELECT id, email, display_name FROM public.users;
   ```
   Should show the same users with display names populated

3. **Check notification_preferences:**
   ```sql
   SELECT user_id FROM public.notification_preferences;
   ```
   Should show entries for both users

#### Step 4: Test Login

1. Run the Flutter app
2. Go to Unlock Screen
3. Try logging in:
   - **ID**: `saketh_nandu127` (or full email `saketh_nandu127@example.com`)
   - **Password**: `SupriyaSaketh127`

### If Still Getting "Invalid Credentials"

#### Check 1: Verify Supabase Credentials
```dart
// In lib/config/app_config.dart
static const String supabaseUrl = 'YOUR_PROJECT_URL';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

Make sure these match your NEW Supabase project (not the old one).

#### Check 2: Verify User Passwords
In Supabase Dashboard → Authentication → Users, click on each user and check:
- Email is correct
- Password is set (should show "Password set" or similar)

#### Check 3: Check Supabase Logs
In Supabase Dashboard → Logs, look for authentication errors:
1. Go to Logs
2. Filter by "auth" or "error"
3. Look for any error messages related to your login attempts

#### Check 4: Manually Test Auth
In Supabase Dashboard → SQL Editor, run:
```sql
-- This won't work directly, but you can check if users exist
SELECT id, email FROM auth.users WHERE email = 'saketh_nandu127@example.com';
```

### If Users Don't Exist in auth.users

You need to create them via Supabase Dashboard:

1. Go to Supabase Dashboard → Authentication → Users
2. Click "Add user"
3. Enter email: `saketh_nandu127@example.com`
4. Enter password: `SupriyaSaketh127`
5. Click "Create user"
6. Repeat for second user:
   - Email: `srirenu127@example.com`
   - Password: `#filmmaking`

Then run the sync script again.

### If Trigger Didn't Fire

If users exist in `auth.users` but not in `public.users`, the trigger didn't fire. Run the sync script to manually sync them.

## Issue: Firebase Not Configured

### Symptoms
- Error: "No Firebase App '{DEFAULT}' has been created"
- App crashes on startup

### Solution
The app now handles this gracefully. Firebase is optional - the app will work without push notifications.

If you want to enable Firebase:
1. Create a Firebase project
2. Add your Android/iOS app to the Firebase project
3. Download the configuration files
4. Add them to your Flutter project

## Issue: Storage Buckets Not Working

### Solution
The `FRESH_PROJECT_SETUP.sql` script creates storage buckets automatically. If they're missing:

1. Go to Supabase Dashboard → Storage
2. Create three buckets:
   - `chat-media` (for images, videos, audio, files)
   - `avatars` (for user avatars)
   - `recordings` (for audio/video recordings)

3. Set each bucket to public (allow public access)

## Issue: Notifications Not Working

### Solution
1. Ensure Firebase is configured (optional but recommended)
2. Ensure device tokens are being stored:
   ```sql
   SELECT * FROM public.device_tokens;
   ```
3. Check notification preferences:
   ```sql
   SELECT * FROM public.notification_preferences;
   ```

## Quick Checklist

- [ ] Created NEW Supabase project
- [ ] Updated `lib/config/app_config.dart` with new credentials
- [ ] Ran `FRESH_PROJECT_SETUP.sql` in Supabase SQL Editor
- [ ] Created test users via Supabase Dashboard (NOT SQL)
- [ ] Ran `fix_auth_users_sync.sql` to sync users
- [ ] Verified users exist in both `auth.users` and `public.users`
- [ ] Tested login with correct credentials
- [ ] App runs without Firebase errors

## Test Credentials

**User 1 (Male):**
- Email: `saketh_nandu127@example.com`
- Username: `saketh_nandu127`
- Password: `SupriyaSaketh127`

**User 2 (Female):**
- Email: `srirenu127@example.com`
- Username: `srirenu127`
- Password: `#filmmaking`

## Support

If you're still having issues:
1. Check the Supabase logs for error messages
2. Verify all SQL scripts ran without errors
3. Ensure you're using the correct Supabase project
4. Check that users exist in Supabase Dashboard → Authentication → Users
