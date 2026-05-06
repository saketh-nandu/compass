# Compass App - Setup Instructions

## Step 1: Create New Supabase Project

1. Go to https://supabase.com
2. Create a new project (or use existing one)
3. Copy your project credentials:
   - **Project URL**: Found in Settings → API
   - **Anon Key**: Found in Settings → API (under "anon public")

## Step 2: Update app_config.dart

Update `lib/config/app_config.dart` with your new Supabase credentials:

```dart
static const String supabaseUrl = 'YOUR_PROJECT_URL';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

## Step 3: Run Database Setup SQL

1. Go to your Supabase project → SQL Editor
2. Click "New Query"
3. Copy the ENTIRE content from `supabase/FRESH_PROJECT_SETUP.sql`
4. Paste it into the SQL editor
5. Click "Run"
6. Wait for completion (should see "Setup Complete!" message)

## Step 4: Create Test Users

**IMPORTANT: Create users via Supabase Dashboard, NOT SQL**

### User 1 (Male):
1. Go to Supabase → Authentication → Users
2. Click "Add user"
3. Email: `saketh_nandu127@example.com`
4. Password: `SupriyaSaketh127`
5. Click "Create user"

### User 2 (Female):
1. Click "Add user" again
2. Email: `srirenu127@example.com`
3. Password: `#filmmaking`
4. Click "Create user"

## Step 5: Verify Setup

After creating users, check that:
1. Both users appear in Authentication → Users
2. Both users appear in the `public.users` table (with display_name populated)
3. No errors in the SQL logs

## Step 6: Test Login

1. Run the Flutter app
2. Go to Unlock Screen
3. Try logging in with:
   - **ID**: `saketh_nandu127` (or full email)
   - **Password**: `SupriyaSaketh127`

## Troubleshooting

### "Invalid Credentials" Error
- Verify users exist in Supabase Dashboard → Authentication → Users
- Check that email format is correct (must include @example.com)
- Verify password is exactly as set

### "Relation does not exist" Error
- Run the FRESH_PROJECT_SETUP.sql again
- Check SQL logs for errors
- Ensure you're in the correct Supabase project

### Users not appearing in public.users table
- Check that the trigger `on_auth_user_created` exists
- Verify the trigger is firing (check function logs)
- Manually insert users if trigger fails

## Important Notes

- **YouTube API Key**: Already configured in app_config.dart
- **Storage Buckets**: Created automatically by FRESH_PROJECT_SETUP.sql
- **Notifications**: Will work once users are created and app is deployed
- **Tilt Detection**: 127° ± 3° for 3 seconds to unlock hidden chat
