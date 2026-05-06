# Create Test Users in Supabase

The database schema is now deployed! Now you need to create the test user accounts.

## Step 1: Go to Supabase Dashboard

Open: https://app.supabase.com/project/oltzkkchoohpwbipqkeh/auth/users

## Step 2: Create Male User

Click **"Add user"** button and fill in:

- **Email**: `saketh_nandu127@example.com`
- **Password**: `SupriyaSaketh127`
- **Confirm password**: `SupriyaSaketh127`
- ✅ Check **"Auto confirm user"**

Click **"Create user"**

## Step 3: Create Female User

Click **"Add user"** button again and fill in:

- **Email**: `srirenu127@example.com`
- **Password**: `#filmmaking`
- **Confirm password**: `#filmmaking`
- ✅ Check **"Auto confirm user"**

Click **"Create user"**

## Step 4: Insert User Profiles

After creating both users, run this command to insert their profiles:

```bash
cd my_app
supabase db execute < supabase/setup_users.sql
```

Or manually insert via SQL Editor in Supabase Dashboard:

1. Go to: https://app.supabase.com/project/oltzkkchoohpwbipqkeh/sql/new
2. Copy and paste the SQL below
3. Click **"Run"**

```sql
-- Get user IDs from auth.users table
-- Replace USER_ID_1 and USER_ID_2 with actual IDs from auth.users

INSERT INTO users (id, username, email, full_name, gender, status)
VALUES 
  ('USER_ID_1', 'saketh_nandu127', 'saketh_nandu127@example.com', 'Saketh Nandu', 'male', 'offline'),
  ('USER_ID_2', 'srirenu127', 'srirenu127@example.com', 'Supriya', 'female', 'offline')
ON CONFLICT (id) DO NOTHING;

-- Create notification preferences
INSERT INTO notification_preferences (user_id, message_notifications, typing_notifications, sound_enabled, vibration_enabled)
VALUES 
  ('USER_ID_1', TRUE, TRUE, TRUE, TRUE),
  ('USER_ID_2', TRUE, TRUE, TRUE, TRUE)
ON CONFLICT (user_id) DO NOTHING;
```

## Step 5: Find User IDs

To get the actual user IDs:

1. Go to: https://app.supabase.com/project/oltzkkchoohpwbipqkeh/auth/users
2. Click on each user to see their ID
3. Replace `USER_ID_1` and `USER_ID_2` in the SQL above

Or run this query in SQL Editor:

```sql
SELECT id, email FROM auth.users;
```

## Step 6: Test Login in App

Now you can test the app with these credentials:

**Male Account:**
- Email: `saketh_nandu127@example.com`
- Password: `SupriyaSaketh127`

**Female Account:**
- Email: `srirenu127@example.com`
- Password: `#filmmaking`

## Troubleshooting

### Users not appearing in app
- Verify users are created in auth.users table
- Check that user profiles exist in users table
- Ensure RLS policies allow access

### Login fails
- Verify email matches exactly
- Check password is correct
- Ensure user is auto-confirmed

### Can't find user IDs
- Go to auth.users table in Supabase dashboard
- Copy the UUID from the id column

## Database Status

✅ **Deployed:**
- users table
- messages table
- typing_indicators table
- memories table
- recordings table
- device_tokens table
- notification_preferences table
- All indexes
- All RLS policies
- All helper functions
- Realtime enabled

✅ **Ready to use:**
- Chat messaging
- Typing indicators
- Message read receipts
- Recordings
- Memories
- Push notifications

## Next Steps

1. ✅ Create test users (this guide)
2. ✅ Insert user profiles
3. Test login in Flutter app
4. Send test messages
5. Verify typing indicators
6. Test recordings
7. Check push notifications
