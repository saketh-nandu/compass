# Fix Login Issue - Step by Step

## The Problem
You're getting "invalid credentials" error when trying to login.

## The Solution

### STEP 1: Verify Supabase Project
1. Open your Supabase project dashboard
2. Go to **Settings → API**
3. Copy the **Project URL** and **Anon Key**
4. Verify they match what's in `lib/config/app_config.dart`:
   ```dart
   static const String supabaseUrl = 'YOUR_URL_HERE';
   static const String supabaseAnonKey = 'YOUR_KEY_HERE';
   ```

### STEP 2: Create Test Users in Supabase Dashboard
**IMPORTANT: Do this via the Dashboard, NOT SQL**

1. Go to your Supabase project dashboard
2. Click **Authentication** (left sidebar)
3. Click **Users** tab
4. Click **Add user** button

**Create User 1:**
- Email: `saketh_nandu127@example.com`
- Password: `SupriyaSaketh127`
- Click **Create user**

**Create User 2:**
- Email: `srirenu127@example.com`
- Password: `#filmmaking`
- Click **Create user**

**Verify:** You should see both users in the Users list

### STEP 3: Sync Users to public.users Table
1. Go to **SQL Editor** in Supabase
2. Click **New Query**
3. Copy the entire content from `supabase/SIMPLE_USER_SETUP.sql`
4. Paste it into the SQL editor
5. Click **Run**
6. Check the output - you should see:
   - Users found in `auth.users`
   - Users synced to `public.users`
   - Notification preferences created
   - Final verification showing counts

### STEP 4: Test Login
1. Run the Flutter app
2. Go to **Unlock Screen**
3. Enter:
   - **ID**: `saketh_nandu127` (or full email)
   - **Password**: `SupriyaSaketh127`
4. Click **Sign In**

## If Still Getting "Invalid Credentials"

### Check 1: Verify Users Exist
Run this SQL query in Supabase SQL Editor:
```sql
SELECT id, email FROM auth.users 
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');
```

**Expected result:** Should show 2 rows with the emails

**If empty:** Users don't exist - go back to STEP 2

### Check 2: Verify Users in public.users
Run this SQL query:
```sql
SELECT id, email, display_name FROM public.users 
WHERE email IN ('saketh_nandu127@example.com', 'srirenu127@example.com');
```

**Expected result:** Should show 2 rows with display names

**If empty:** Run STEP 3 again

### Check 3: Check Supabase Logs
1. Go to **Logs** in Supabase dashboard
2. Look for authentication errors
3. Check if there are any error messages related to your login attempts

### Check 4: Verify Credentials in app_config.dart
Make sure you're using the CORRECT Supabase project:
```dart
// This should match your NEW Supabase project
static const String supabaseUrl = 'https://mveocemlkrxdvpcdpuvh.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

## Quick Checklist

- [ ] Verified Supabase project URL and key in app_config.dart
- [ ] Created both test users in Supabase Dashboard → Authentication → Users
- [ ] Ran SIMPLE_USER_SETUP.sql in SQL Editor
- [ ] Verified users exist in auth.users table
- [ ] Verified users exist in public.users table
- [ ] Tried logging in with correct credentials
- [ ] Checked Supabase logs for errors

## Test Credentials

**User 1:**
- Email: `saketh_nandu127@example.com`
- Username: `saketh_nandu127`
- Password: `SupriyaSaketh127`

**User 2:**
- Email: `srirenu127@example.com`
- Username: `srirenu127`
- Password: `#filmmaking`

## Still Not Working?

If you've done all these steps and still getting errors:

1. **Take a screenshot of the error message** - Send it to me
2. **Run the diagnostic script:**
   - Go to SQL Editor
   - Copy content from `supabase/diagnose_auth_issue.sql`
   - Run it and share the output
3. **Check Supabase logs** - Look for any error messages

## Important Notes

- The app now handles Firebase initialization gracefully (no crash if Firebase not configured)
- Users MUST be created via Supabase Dashboard, not SQL
- Passwords are case-sensitive
- Email format must include @example.com
