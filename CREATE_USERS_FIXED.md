# ✅ Create Test Users - Fixed Version

The database trigger is now in place. When you create auth users, their profiles will be automatically created!

## Step 1: Go to Supabase Dashboard

Open: https://app.supabase.com/project/oltzkkchoohpwbipqkeh/auth/users

## Step 2: Create Male User

Click **"Add user"** button and fill in:

- **Email**: `saketh_nandu127@example.com`
- **Password**: `SupriyaSaketh127`
- **Confirm password**: `SupriyaSaketh127`
- ✅ Check **"Auto confirm user"**

Click **"Create user"**

✅ **User profile will be automatically created!**

## Step 3: Create Female User

Click **"Add user"** button again and fill in:

- **Email**: `srirenu127@example.com`
- **Password**: `#filmmaking`
- **Confirm password**: `#filmmaking`
- ✅ Check **"Auto confirm user"**

Click **"Create user"**

✅ **User profile will be automatically created!**

## Step 4: Update User Profiles (Optional)

If you want to add more details like username and gender, run:

```bash
cd my_app
supabase db execute < supabase/setup_users.sql
```

Or manually update via SQL Editor:

```sql
UPDATE users 
SET username = 'saketh_nandu127', gender = 'male'
WHERE email = 'saketh_nandu127@example.com';

UPDATE users 
SET username = 'srirenu127', gender = 'female'
WHERE email = 'srirenu127@example.com';
```

## Step 5: Test in App

Now you can test the app with these credentials:

**Male Account:**
- Email: `saketh_nandu127@example.com`
- Password: `SupriyaSaketh127`

**Female Account:**
- Email: `srirenu127@example.com`
- Password: `#filmmaking`

## What Happens Automatically

When you create an auth user:
1. ✅ Auth user is created in `auth.users` table
2. ✅ User profile is automatically created in `users` table
3. ✅ User status is set to 'offline'
4. ✅ Email is stored in user profile

## Troubleshooting

### Users not appearing in app
- Go to: https://app.supabase.com/project/oltzkkchoohpwbipqkeh/editor
- Check the `users` table
- Verify user profiles exist

### Login fails
- Verify email matches exactly
- Check password is correct
- Ensure user is auto-confirmed

### Can't see user profiles
- Check the `users` table in Supabase dashboard
- Verify the trigger is working
- Check database logs for errors

## Database Trigger

The automatic user creation is handled by this trigger:

```sql
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

This trigger:
- Runs when a new auth user is created
- Automatically creates a user profile
- Sets default values (status = 'offline')
- Handles conflicts gracefully

## Next Steps

1. ✅ Create male user
2. ✅ Create female user
3. ✅ Test login in app
4. Send test messages
5. Verify typing indicators
6. Test recordings
7. Check push notifications
