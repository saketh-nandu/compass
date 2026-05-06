# Supabase Backend Setup Guide

This guide walks you through setting up the Compass app backend with Supabase CLI.

## Prerequisites

- Supabase CLI installed: https://supabase.com/docs/guides/cli
- Supabase account with project created
- Project URL and API keys ready

## Step 1: Link Your Supabase Project

```bash
cd my_app
supabase link --project-ref oltzkkchoohpwbipqkeh
```

When prompted, enter your Supabase database password.

## Step 2: Deploy Database Migrations

```bash
supabase db push
```

This will:
- Create all chat tables (messages, typing_indicators, memories, recordings, etc.)
- Set up realtime subscriptions
- Configure Row Level Security (RLS) policies
- Create indexes for performance
- Set up helper functions and triggers

## Step 3: Create Test Users via Supabase Dashboard

Since we can't create auth users directly via SQL, use the Supabase Dashboard:

### Male User
1. Go to: https://app.supabase.com/project/oltzkkchoohpwbipqkeh/auth/users
2. Click "Add user"
3. Enter:
   - **Email**: `saketh_nandu127@example.com`
   - **Password**: `SupriyaSaketh127`
   - Check "Auto confirm user"
4. Click "Create user"

### Female User
1. Click "Add user" again
2. Enter:
   - **Email**: `srirenu127@example.com`
   - **Password**: `#filmmaking`
   - Check "Auto confirm user"
3. Click "Create user"

## Step 4: Insert User Profiles

After creating auth users, insert their profiles:

```bash
supabase db execute < supabase/setup_users.sql
```

Or manually insert via Supabase Dashboard SQL Editor:

```sql
-- Get the user IDs from auth.users table first
-- Then insert profiles:

INSERT INTO users (id, username, email, full_name, gender, status)
VALUES 
  ('USER_ID_1', 'saketh_nandu127', 'saketh_nandu127@example.com', 'Saketh Nandu', 'male', 'offline'),
  ('USER_ID_2', 'srirenu127', 'srirenu127@example.com', 'Sri Renu', 'female', 'offline');

-- Create notification preferences
INSERT INTO notification_preferences (user_id, message_notifications, typing_notifications, sound_enabled, vibration_enabled)
VALUES 
  ('USER_ID_1', TRUE, TRUE, TRUE, TRUE),
  ('USER_ID_2', TRUE, TRUE, TRUE, TRUE);
```

## Step 5: Verify Setup

Check that everything is set up correctly:

```bash
# List all tables
supabase db list

# Check realtime status
supabase status
```

## Step 6: Test the Connection

In your Flutter app, the credentials are:

**Male Account:**
- ID: `saketh_nandu127@example.com`
- Password: `SupriyaSaketh127`

**Female Account:**
- ID: `srirenu127@example.com`
- Password: `#filmmaking`

## Database Schema

### Tables Created

1. **users** - User profiles and status
2. **messages** - Chat messages with read status
3. **typing_indicators** - Real-time typing status
4. **memories** - Saved memories/notes
5. **recordings** - Audio/video recordings
6. **device_tokens** - Push notification tokens
7. **notification_preferences** - User notification settings

### Realtime Features

The following tables have realtime enabled:
- `messages` - See new messages instantly
- `typing_indicators` - See when partner is typing
- `users` - See online/offline status
- `recordings` - See new recordings instantly

### Security

All tables have Row Level Security (RLS) enabled:
- Users can only see their own data
- Users can only modify their own data
- Messages are visible to sender and recipient only
- Typing indicators are visible to both chat partners

## Troubleshooting

### Users not appearing in app
- Verify users are created in auth.users table
- Check that user profiles exist in users table
- Ensure RLS policies allow access

### Realtime not working
- Verify realtime is enabled in Supabase dashboard
- Check that tables are added to supabase_realtime publication
- Ensure your anon key has realtime permissions

### Messages not syncing
- Check network connection
- Verify RLS policies allow message access
- Check browser console for errors

## Next Steps

1. Test login with both accounts
2. Send test messages between accounts
3. Verify typing indicators work
4. Test recording upload/download
5. Check push notifications

## Support

For issues, check:
- Supabase documentation: https://supabase.com/docs
- Flutter Supabase package: https://pub.dev/packages/supabase
- Project logs in Supabase dashboard
