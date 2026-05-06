# Firebase Setup - Quick Start (5 Minutes)

## What You Need to Do

### Step 1: Download google-services.json (2 minutes)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click on your "compass" project (or create one if you don't have it)
3. Click **Settings** (gear icon) → **Project settings**
4. Scroll down to **Your apps** section
5. If you see Android app listed, click the 3 dots → **Download google-services.json**
6. If no Android app, click **Add app** → **Android**
   - Package name: `com.example.hushnav`
   - Click **Register app**
   - Click **Download google-services.json**

### Step 2: Place File in Project (1 minute)

1. Copy the downloaded `google-services.json` file
2. Paste it here: `my_app/android/app/google-services.json`

### Step 3: Rebuild App (2 minutes)

```bash
cd my_app
flutter clean
flutter pub get
flutter run
```

## That's It!

Now when you:
1. Login to the app
2. Go to chat
3. Click "Notify Partner" button
4. Your partner will receive a notification on their device

## How It Works

```
You click "Notify Partner"
    ↓
App sends request to Supabase
    ↓
Supabase calls Firebase Cloud Messaging
    ↓
Firebase sends notification to partner's device
    ↓
Partner sees notification (even if app is closed)
```

## Verify It's Working

1. Login with first user on Device 1
2. Login with second user on Device 2
3. In Device 1 chat, click "Notify Partner"
4. Device 2 should show notification

## If Notifications Don't Work

Check:
1. Is `google-services.json` in `android/app/`?
2. Did you rebuild the app after adding the file?
3. Are both users logged in?
4. Check Supabase logs for errors

## Important

- Firebase is optional - app works without it
- Notifications only work if Firebase is configured
- Device tokens are stored automatically when user logs in
- Notifications are sent to ALL devices where user is logged in
