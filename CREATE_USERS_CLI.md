# Create Test Users via Supabase CLI

This guide shows how to create test users entirely through the command line.

## Prerequisites

- Supabase CLI installed
- Supabase project linked (`supabase link --project-ref oltzkkchoohpwbipqkeh`)
- Database migrations deployed (`supabase db push`)

## Option 1: Automated Script (Recommended)

### Windows
```bash
cd my_app
create_users_cli.bat
```

### Linux/Mac
```bash
cd my_app
chmod +x create_users_cli.sh
./create_users_cli.sh
```

This will:
1. Create male user
2. Create female user
3. Insert user profiles
4. Display test credentials

## Option 2: Manual CLI Commands

### Create Male User
```bash
supabase auth admin create-user \
  --email saketh_nandu127@example.com \
  --password SupriyaSaketh127 \
  --autoconfirm
```

### Create Female User
```bash
supabase auth admin create-user \
  --email srirenu127@example.com \
  --password '#filmmaking' \
  --autoconfirm
```

### Insert User Profiles
```bash
supabase db execute < supabase/setup_users.sql
```

## Verify Users Created

### Check Auth Users
```bash
supabase auth admin list-users
```

### Check User Profiles
```bash
supabase db execute "SELECT id, email, full_name, gender, status FROM users;"
```

## Test Credentials

After running the script, use these credentials to login:

**Male Account:**
- Email: `saketh_nandu127@example.com`
- Password: `SupriyaSaketh127`

**Female Account:**
- Email: `srirenu127@example.com`
- Password: `#filmmaking`

## What Happens

1. **Auth User Created**
   - User created in `auth.users` table
   - Auto-confirmed (no email verification needed)
   - Password set and hashed

2. **User Profile Auto-Created**
   - Trigger automatically creates profile in `users` table
   - Email stored
   - Status set to 'offline'
   - Ready to use immediately

3. **User Profile Updated**
   - Username set
   - Gender set
   - Full name set

## Troubleshooting

### Command not found: supabase
- Install Supabase CLI: https://supabase.com/docs/guides/cli
- Or use: `npm install -g supabase`

### Project not linked
- Run: `supabase link --project-ref oltzkkchoohpwbipqkeh`
- Enter your database password when prompted

### User already exists
- Users are unique by email
- Delete existing user first or use different email

### Password contains special characters
- Wrap password in quotes: `'#filmmaking'`
- Or escape special characters

### Migrations not deployed
- Run: `supabase db push`
- Ensure all migrations are applied

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
supabase db execute < file.sql
```

### View Database
```bash
supabase db list
```

### Push Migrations
```bash
supabase db push
```

## Next Steps

1. ✅ Run the create users script
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
- Supabase CLI Docs: https://supabase.com/docs/guides/cli
- Supabase Auth: https://supabase.com/docs/guides/auth
