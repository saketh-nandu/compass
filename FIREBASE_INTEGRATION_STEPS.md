# Firebase Integration - Complete Steps

## Overview

The app sends notifications through this flow:

```
User clicks "Notify Partner" in Chat
    ↓
App calls NotificationService.sendPartnerNotification()
    ↓
Calls Supabase Edge Function: send-notification
    ↓
Edge Function gets recipient's device tokens from database
    ↓
Edge Function sends FCM notification via Firebase
    ↓
Firebase sends notification to all recipient's devices
    ↓
Recipient sees notification (even if app is closed)
```

## What You Need to Do

### Step 1: Get Firebase Credentials

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your "compass" project
3. Go to **Settings** (gear icon) → **Service Accounts**
4. Click **Generate New Private Key**
5. A JSON file will download - keep it safe!
6. Copy these values from the JSON:
   - `project_id`
   - `private_key`
   - `client_email`

### Step 2: Add Android App to Firebase

1. In Firebase Console, go to **Project Settings**
2. Scroll to **Your apps** section
3. Click **Add app** → **Android**
4. Package name: `com.example.hushnav`
5. Click **Register app**
6. Click **Download google-services.json**
7. Place file at: `my_app/android/app/google-services.json`

### Step 3: Configure Supabase Edge Function

The edge function needs Firebase credentials to send notifications.

1. Go to your Supabase project → **Edge Functions**
2. Check if `send-notification` function exists
3. If it exists, click it and update the environment variables:
   - `FIREBASE_PROJECT_ID`: Your Firebase project ID
   - `FIREBASE_PRIVATE_KEY`: Your Firebase private key
   - `FIREBASE_CLIENT_EMAIL`: Your Firebase client email

4. If it doesn't exist, create it:
   - Click **Create a new function**
   - Name: `send-notification`
   - Copy code from `supabase/functions/send-notification/index.ts`
   - Add the environment variables above

### Step 4: Rebuild Flutter App

```bash
cd my_app
flutter clean
flutter pub get
flutter run
```

## Testing Notifications

### Test 1: Send from Firebase Console

1. Go to Firebase Console → **Messaging**
2. Click **Create your first campaign**
3. Enter title and message
4. Click **Send test message**
5. Select your device
6. Click **Test**

### Test 2: Send from App

1. Login with User 1 on Device 1
2. Login with User 2 on Device 2
3. In Device 1 chat, click **Notify Partner** button
4. Device 2 should receive notification

### Test 3: Check Notification Logs

In Supabase SQL Editor:
```sql
SELECT * FROM public.notification_logs 
ORDER BY created_at DESC 
LIMIT 10;
```

Should show:
- `sender_user_id`: User who clicked "Notify Partner"
- `recipient_user_id`: User who should receive notification
- `success_count`: Number of devices that received notification
- `total_count`: Total devices attempted

## Troubleshooting

### "No Firebase App" Error
- Make sure `google-services.json` is in `android/app/`
- Run `flutter clean` and rebuild

### Notifications Not Received
1. Check device tokens are stored:
   ```sql
   SELECT * FROM public.device_tokens 
   WHERE user_id = 'USER_ID';
   ```

2. Check notification logs:
   ```sql
   SELECT * FROM public.notification_logs 
   ORDER BY created_at DESC LIMIT 5;
   ```

3. Check if `success_count` is 0 - means Firebase didn't send

### Edge Function Not Working
1. Check Supabase logs: **Edge Functions** → **Logs**
2. Verify environment variables are set correctly
3. Check Firebase credentials are valid

## Important Notes

- Device tokens are stored automatically when user logs in
- Each device gets its own token
- Notifications are sent to ALL active devices for a user
- Notification cooldown is 5 minutes (in `app_config.dart`)
- Firebase is optional - app works without it (no notifications)

## Files Involved

- `lib/services/notification_service.dart` - Sends notification requests
- `supabase/functions/send-notification/index.ts` - Edge function that sends FCM
- `supabase/FRESH_PROJECT_SETUP.sql` - Creates `device_tokens` and `notification_logs` tables
- `lib/config/app_config.dart` - Configuration (cooldown, etc.)

## Next Steps

1. ✅ Create Firebase project (you already have this)
2. ⏳ Add Android app to Firebase
3. ⏳ Download `google-services.json`
4. ⏳ Place file in `android/app/`
5. ⏳ Get Firebase credentials (project ID, private key, client email)
6. ⏳ Configure Supabase edge function with credentials
7. ⏳ Rebuild Flutter app
8. ⏳ Test notifications

## Quick Reference

**Firebase Console:** https://console.firebase.google.com
**Supabase Console:** https://app.supabase.com
**Flutter Docs:** https://firebase.flutter.dev
