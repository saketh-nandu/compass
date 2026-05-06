# Hushnav - Hidden Secure Chat Compass App

A Flutter mobile application that appears as a normal Compass + Level utility app, but includes a hidden secure chat system powered by Supabase. The app reuses the same backend logic, database structure, and messaging system as the Chatsusa website.

## Features

### Base App
- **Two-tab interface**: Compass (using flutter_compass) and Level (using sensors_plus)
- **Realistic UI** with smooth animations
- **Professional appearance** - looks like a genuine utility app

### Hidden Unlock Mechanism
- **Accelerometer + Gyroscope detection**
- **Tilt calculation**: `tilt = sqrt(pitch² + roll²)`
- **Unlock condition**: 
  - Tilt ≈ 127° (±3° tolerance)
  - Low motion (gyroscope threshold)
  - Held for 3 seconds
- **Auto-reset** if condition is broken
- **Cooldown period** (10-15 seconds) after unlock attempt

### Security System
- **PIN/Password protection** using flutter_secure_storage
- **Optional biometric authentication**
- **Auto-lock on background**
- **Panic mode** - instantly hide chat and return to compass

### Backend Integration (IMPORTANT)
- **Uses the SAME Supabase project as Chatsusa**
- **NO new schema creation** - reuses existing tables
- **Complete compatibility** with existing web application
- **Realtime synchronization** - messages appear instantly across platforms

### Chat Features
- **Full message support**: Text, Emojis, Images, Videos, Audio, Files
- **Supabase Storage integration** (same buckets as website)
- **Realtime messaging** with instant sync
- **Message status tracking** (sent, delivered, read)
- **Typing indicators**
- **Message replies and threading**

### Memories Feature
- **Save/bookmark messages** from chat
- **Tag and organize** saved content
- **Search functionality**
- **Compatible with Chatsusa backend**

### Notifications
- **Firebase Cloud Messaging (FCM)** integration
- **"Notify Partner" feature** with compass-style messages
- **5-minute cooldown** (backend enforced)
- **Background and foreground** notification handling

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / Xcode for mobile development
- Firebase project (for notifications)
- Supabase project (same as Chatsusa website)

### 2. Supabase Configuration

**CRITICAL**: This app must use the SAME Supabase project as your Chatsusa website.

1. Open `lib/services/supabase_service.dart`
2. Replace the placeholder values with your actual Chatsusa Supabase credentials:

```dart
await Supabase.initialize(
  url: 'https://your-actual-project-ref.supabase.co',
  anonKey: 'your-actual-anon-key-here',
  debug: kDebugMode,
);
```

### 3. Firebase Configuration

1. Create a Firebase project or use existing one
2. Add Android and iOS apps to your Firebase project
3. Download configuration files:
   - `google-services.json` for Android → `android/app/`
   - `GoogleService-Info.plist` for iOS → `ios/Runner/`
4. Replace the placeholder files in the project

### 4. Database Schema

The app expects these tables to exist in your Supabase database (same as Chatsusa):

```sql
-- Users table (should already exist from Chatsusa)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  status TEXT DEFAULT 'offline',
  last_seen TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Messages table (should already exist from Chatsusa)
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID REFERENCES users(id),
  recipient_id UUID REFERENCES users(id),
  content TEXT,
  message_type TEXT DEFAULT 'text',
  media_url TEXT,
  media_filename TEXT,
  reply_to_id UUID REFERENCES messages(id),
  status TEXT DEFAULT 'sent',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  read_at TIMESTAMP WITH TIME ZONE,
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- Device tokens for notifications
CREATE TABLE device_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  token TEXT NOT NULL,
  platform TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Memories table (for bookmarked messages)
CREATE TABLE memories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  message_id UUID REFERENCES messages(id),
  note TEXT,
  tags TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Typing indicators (optional)
CREATE TABLE typing_indicators (
  user_id UUID REFERENCES users(id),
  recipient_id UUID REFERENCES users(id),
  is_typing BOOLEAN DEFAULT false,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (user_id, recipient_id)
);
```

### 5. Supabase Storage Buckets

Ensure these storage buckets exist (same as Chatsusa):
- `chat-media` - for images, videos, audio, files
- `avatars` - for user profile pictures
- `temp-uploads` - for temporary file storage

### 6. Supabase Edge Functions

Create this Edge Function for partner notifications:

```typescript
// supabase/functions/send-partner-notification/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  try {
    const { recipient_user_id, sender_user_id, custom_message } = await req.json()
    
    // Get recipient's device tokens
    const { data: tokens } = await supabase
      .from('device_tokens')
      .select('token, platform')
      .eq('user_id', recipient_user_id)
    
    // Send FCM notifications
    for (const tokenData of tokens) {
      await sendFCMNotification({
        token: tokenData.token,
        title: "Compass Update",
        body: custom_message || "Heading NW (312°)",
        data: {
          type: "compass_notification",
          sender_id: sender_user_id
        }
      })
    }
    
    return new Response(JSON.stringify({ success: true }), {
      headers: { "Content-Type": "application/json" },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    })
  }
})
```

### 7. Install Dependencies

```bash
flutter pub get
```

### 8. Platform-Specific Setup

#### Android
1. Update `android/app/build.gradle.kts` to include Firebase:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Add this line
}
```

2. Update `android/build.gradle.kts`:
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.3.15") // Add this line
}
```

#### iOS
1. Open `ios/Runner.xcworkspace` in Xcode
2. Add `GoogleService-Info.plist` to the Runner target
3. Enable Push Notifications capability
4. Configure background modes for notifications

### 9. Run the App

```bash
flutter run
```

## Usage

### Normal Operation
- App appears as a standard Compass + Level utility
- Two tabs: Compass and Level with realistic functionality
- No indication of hidden features

### Accessing Hidden Chat
1. **Tilt Detection**: Hold device at ~127° tilt with minimal movement for 3 seconds
2. **PIN Setup**: First time will require setting up a 4-digit PIN
3. **Authentication**: Sign in with Chatsusa account credentials
4. **Chat Access**: Full secure chat functionality unlocked

### Panic Mode
- **Long press** the chat screen title
- **OR** press the shield icon
- **OR** app automatically locks when backgrounded
- Instantly returns to Compass tab and locks chat access

### Partner Notification
- Tap the notification icon in chat
- Sends compass-style notification: "Heading NW (312°)"
- 5-minute cooldown between notifications
- Appears as normal compass update to recipient

## Security Features

- **Hidden in plain sight** - appears as legitimate utility app
- **Secure PIN protection** with device keychain storage
- **Auto-lock on background** for immediate security
- **Panic mode** for instant hiding
- **End-to-end compatibility** with Chatsusa security model
- **No local message storage** - all data in secure Supabase backend

## Development Notes

### Architecture
- **Clean separation** between utility and chat features
- **Service-based architecture** for backend integration
- **Reusable components** matching Chatsusa patterns
- **State management** with Provider (expandable)

### Backend Compatibility
- **Identical API calls** to Chatsusa website
- **Same JSON structures** for all data
- **Shared realtime subscriptions**
- **Compatible authentication flow**

### Testing
- Test compass and level functionality on physical device
- Verify tilt detection with various device orientations
- Test notification delivery and handling
- Validate chat sync with Chatsusa website
- Test panic mode and auto-lock features

## Production Deployment

1. **Update Firebase configuration** with production keys
2. **Configure Supabase RLS policies** for security
3. **Set up proper FCM server key** in Supabase
4. **Test on multiple device types** and orientations
5. **Verify backend compatibility** with production Chatsusa
6. **Remove debug features** and demo shortcuts
7. **Enable code obfuscation** for additional security

## Troubleshooting

### Common Issues
- **Tilt detection not working**: Ensure device has accelerometer/gyroscope
- **Notifications not received**: Check FCM configuration and device tokens
- **Chat not syncing**: Verify Supabase credentials and network connectivity
- **PIN not saving**: Check flutter_secure_storage permissions

### Debug Mode
- Enable debug logging in Supabase service
- Use Flutter Inspector for UI debugging
- Check device logs for sensor data
- Monitor network requests to Supabase

## Security Considerations

- **Never store sensitive data locally** beyond encrypted PIN
- **Use HTTPS only** for all network communications
- **Implement proper session management**
- **Regular security audits** of backend integration
- **Monitor for unusual access patterns**

This app provides a sophisticated hidden communication system while maintaining the appearance of a simple utility app. The integration with the existing Chatsusa backend ensures seamless operation and compatibility.