# ✅ Create Test Users - CLI Only

Create test users entirely via Supabase CLI commands.

## Prerequisites

- Supabase CLI v2.75.0+ installed
- Project linked: `supabase link --project-ref oltzkkchoohpwbipqkeh`
- Database migrations deployed: `supabase db push`

## Step 1: Create Male User

Run this command:

```bash
supabase auth admin create-user \
  --email saketh_nandu127@example.com \
  --password SupriyaSaketh127 \
  --autoconfirm
```

**Expected output:**
```
User created successfully
ID: <user-id>
Email: saketh_nandu127@example.com
```

## Step 2: Create Female User

Run this command:

```bash
supabase auth admin create-user \
  --email srirenu127@example.com \
  --password '#filmmaking' \
  --autoconfirm
```

**Expected output:**
```
User created successfully
ID: <user-id>
Email: srirenu127@example.com
```

## Step 3: Verify Users Created

Check that users were created:

```bash
supabase auth admin list-users
```

You should see both users in the list.

## Step 4: Verify User Profiles

Check that user profiles were automatically created:

```bash
supabase db execute "SELECT id, email, full_name, gender, status FROM users;"
```

You should see both user profiles with:
- Email: saketh_nandu127@example.com and srirenu127@example.com
- Status: offline
- Full names and genders set

## Step 5: Test in App

Login with these credentials:

**Male Account:**
- Email: `saketh_nandu127@example.com`
- Password: `SupriyaSaketh127`

**Female Account:**
- Email: `srirenu127@example.com`
- Password: `#filmmaking`

## What Happens Automatically

1. ✅ Auth user created in `auth.users` table
2. ✅ User profile automatically created in `users` table (via trigger)
3. ✅ Status set to 'offline'
4. ✅ Email stored in profile
5. ✅ Ready to use immediately

## Troubleshooting

### Command not found: supabase
Install Supabase CLI:
```bash
npm install -g supabase
```

Or follow: https://supabase.com/docs/guides/cli

### Project not linked
Link your project:
```bash
supabase link --project-ref oltzkkchoohpwbipqkeh
```

### User already exists
Delete and recreate:
```bash
supabase auth admin delete-user <user-id>
```

### Password with special characters
Wrap in quotes:
```bash
supabase auth admin create-user \
  --email test@example.com \
  --password '#password' \
  --autoconfirm
```

### Migrations not deployed
Deploy migrations:
```bash
supabase db push
```

## CLI Commands Reference

### Create User
```bash
supabase auth admin create-user \
  --email <email> \
  --password <password> \
  --autoconfirm
```

### List Users
```bash
supabase auth admin list-users
```

### Delete User
```bash
supabase auth admin delete-user <user-id>
```

### Execute SQL
```bash
supabase db execute "<sql-query>"
```

### View Database
```bash
supabase db list
```

### Push Migrations
```bash
supabase db push
```

### Check Status
```bash
supabase status
```

## Complete Setup Commands

Run these commands in order:

```bash
# 1. Link project
supabase link --project-ref oltzkkchoohpwbipqkeh

# 2. Deploy migrations
supabase db push

# 3. Create male user
supabase auth admin create-user \
  --email saketh_nandu127@example.com \
  --password SupriyaSaketh127 \
  --autoconfirm

# 4. Create female user
supabase auth admin create-user \
  --email srirenu127@example.com \
  --password '#filmmaking' \
  --autoconfirm

# 5. Verify users
supabase auth admin list-users

# 6. Verify profiles
supabase db execute "SELECT id, email, full_name, gender, status FROM users;"
```

## Next Steps

1. ✅ Run CLI commands to create users
2. ✅ Verify users created
3. Test login in app
4. Send test messages
5. Verify all features work

## Support

For CLI help:
```bash
supabase auth admin --help
supabase db --help
```

For more info:
- Supabase CLI: https://supabase.com/docs/guides/cli
- Supabase Auth: https://supabase.com/docs/guides/auth
