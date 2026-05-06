# Firebase Cloud Messaging Setup Guide

## What is Firebase Cloud Messaging (FCM)?

Firebase Cloud Messaging allows you to send push notifications to users' devices. When a user receives a message in the chat, they'll get a notification even if the app is closed.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Create a project**
3. Enter project name: `Compass` (or any name)
4. Click **Continue**
5. Enable Google Analytics (optional)
6. Click **Create project**
7. Wait for project to be created

## Step 2: Add Android App to Firebase

1. In Firebase Console, click **Add app** → **Android**
2. Enter Android package name: `com.example.hushnav`
3. Click **Register app**
4. Download `google-services.json` file
5. Place it in: `my_app/android/app/google-services.json`
6. Click **Next** → **Next** → **Continue to console**

## Step 3: Add iOS App to Firebase (Optional)

1. In Firebase Console, click **Add app** → **iOS**
2. Enter iOS bundle ID: `com.example.hushnav`
3. Click **Register app**
4. Download `GoogleService-Info.plist` file
5. Place it in: `my_app/ios/Runner/GoogleService-Info.plist`
6. Click **Next** → **Next** → **Continue to console**

## Step 4: Get Server Key (for Supabase Edge Function)

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Click **Service Accounts** tab
3. Click **Generate New Private Key**
4. Save the JSON file (keep it safe!)
5. Copy the `private_key` value from the JSON file

## Step 5: Configure Supabase Edge Function

The `send-notification` edge function in Supabase uses Firebase to send notifications.

1. Go to your Supabase project → **Edge Functions**
2. Check if `send-notification` function exists
3. If not, create it with this code:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import * as admin from "https://www.gstatic.com/firebaserealtimedb/init.js"

const firebaseConfig = {
  apiKey: "YOUR_FIREBASE_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT.appspot.com",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID"
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: { "Access-Control-Allow-Origin": "*" } })
  }

  try {
    const { recipient_user_id, sender_user_id, message, type } = await req.json()

    // Get recipient's device tokens from Supabase
    const { data: deviceTokens } = await supabase
      .from("device_tokens")
      .select("token")
      .eq("user_id", recipient_user_id)
      .eq("active", true)

    if (!deviceTokens || deviceTokens.length === 0) {
      return new Response(
        JSON.stringify({ error: "No device tokens found" }),
        { status: 404 }
      )
    }

    // Send notification to each device
    const tokens = deviceTokens.map(dt => dt.token)
    
    const response = await admin.messaging().sendMulticast({
      tokens: tokens,
      notification: {
        title: type === "partner_notification" ? "Partner Notification" : "New Message",
        body: message || "You have a new message"
      },
      data: {
        type: type,
        sender_user_id: sender_user_id
      }
    })

    // Log notification
    await supabase.from("notification_logs").insert({
      sender_user_id: sender_user_id,
      recipient_user_id: recipient_user_id,
      type: type,
      message: message,
      success_count: response.successCount,
      total_count: response.failureCount + response.successCount
    })

    return new Response(
      JSON.stringify({ success: true, sent: response.successCount }),
      { status: 200 }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500 }
    )
  }
})
```

## Step 6: Test Notifications

### Option 1: Send Test Notification from Firebase Console

1. Go to Firebase Console → **Messaging**
2. Click **Create your first campaign**
3. Click **Send your first message**
4. Enter notification title and body
5. Click **Send test message**
6. Select your device
7. Click **Test**

### Option 2: Send from App

When user clicks "Notify Partner" button in chat:
1. App calls `NotificationService.sendPartnerNotification()`
2. This calls Supabase edge function `send-notification`
3. Edge function sends FCM notification to partner's devices
4. Partner receives notification on all their logged-in devices

## Step 7: Verify Setup

Check that:
- [ ] `google-services.json` is in `android/app/`
- [ ] `GoogleService-Info.plist` is in `ios/Runner/` (iOS)
- [ ] Firebase project is created
- [ ] Android app is registered in Firebase
- [ ] Device tokens are being stored in Supabase `device_tokens` table
- [ ] `send-notification` edge function exists in Supabase

## What Happens When User Gets Notification

1. **App is open (foreground):**
   - Local notification appears at top of screen
   - User can tap to open chat

2. **App is closed (background):**
   - System notification appears
   - User can tap to open app and go to chat

3. **App is terminated:**
   - System notification appears
   - User can tap to open app

## Troubleshooting

### "No Firebase App" Error
- Make sure `google-services.json` is in correct location
- Run `flutter clean` and `flutter pub get`
- Rebuild the app

### Notifications Not Received
1. Check device tokens are stored:
   ```sql
   SELECT * FROM public.device_tokens WHERE user_id = 'YOUR_USER_ID';
   ```

2. Check notification logs:
   ```sql
   SELECT * FROM public.notification_logs ORDER BY created_at DESC LIMIT 10;
   ```

3. Check Firebase Console → Messaging → Reports

### Device Token Not Stored
1. Make sure user is logged in
2. Check notification permissions are granted
3. Check Supabase logs for errors

## Important Notes

- Notifications require Firebase to be configured
- Device tokens are stored per device
- Users can have multiple device tokens (one per device)
- Notifications are sent to ALL active devices for a user
- Notification cooldown is 5 minutes (configurable in `app_config.dart`)

## Next Steps

1. Create Firebase project
2. Add Android app to Firebase
3. Download and place `google-services.json`
4. Update Supabase edge function with Firebase config
5. Test by sending notification from Firebase Console
6. Test by clicking "Notify Partner" in app chat

## Firebase Console Links

- [Firebase Console](https://console.firebase.google.com)
- [Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Setup](https://firebase.flutter.dev/docs/overview)
