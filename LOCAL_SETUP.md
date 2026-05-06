# Local Setup Guide

## Prerequisites

- Flutter SDK installed
- Android SDK/Emulator or physical device
- Git

## Step 1: Clone Repository

```bash
git clone https://github.com/saketh-nandu/compass.git
cd compass/my_app
```

## Step 2: Create .env File

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your credentials:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   YOUTUBE_API_KEY=your-youtube-api-key-here
   ```

## Step 3: Install Dependencies

```bash
flutter pub get
```

## Step 4: Run the App

```bash
flutter run
```

Or with environment variables:

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=your-anon-key-here \
            --dart-define=YOUTUBE_API_KEY=your-youtube-api-key-here
```

## Step 5: Test Login

1. Go to Unlock Screen
2. Enter credentials:
   - **ID**: `saketh_nandu127`
   - **Password**: `SupriyaSaketh127`
3. Click **Sign In**

## Environment Variables

### Required
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Your Supabase anon key

### Optional
- `YOUTUBE_API_KEY` - For YouTube Shorts feature
- `FIREBASE_PROJECT_ID` - For push notifications
- `FIREBASE_PRIVATE_KEY` - For push notifications
- `FIREBASE_CLIENT_EMAIL` - For push notifications

## Troubleshooting

### "Invalid credentials" error
- Verify Supabase credentials in `.env`
- Check that test users exist in Supabase
- Run `SIMPLE_USER_SETUP.sql` in Supabase SQL Editor

### "No Firebase App" error
- Firebase is optional - app works without it
- To enable notifications, add `google-services.json` to `android/app/`

### Build errors
```bash
flutter clean
flutter pub get
flutter run
```

## Important Notes

- **Never commit `.env` file** - it contains secrets
- Use `.env.example` as template for new developers
- Environment variables are loaded at build time
- For CI/CD, set environment variables in GitHub Actions secrets

## Next Steps

1. ✅ Clone repository
2. ✅ Create `.env` file with credentials
3. ✅ Run `flutter pub get`
4. ✅ Run `flutter run`
5. ✅ Test login
6. ✅ Test notifications (if Firebase configured)
