# Hushnav Setup Checklist

## ✅ Completed Implementation

### Core Features
- [x] **Compass + Level Base App** - Two-tab interface with realistic functionality
- [x] **Hidden Tilt Detection** - 127° ± 3° tilt detection with gyroscope validation
- [x] **PIN Security System** - 4-digit PIN with secure storage
- [x] **Supabase Integration** - Full backend compatibility with Chatsusa website
- [x] **Chat System** - Text, images, videos, audio, files support
- [x] **Realtime Messaging** - Instant sync with Chatsusa web app
- [x] **Memories Feature** - Save and organize chat messages
- [x] **Firebase Notifications** - FCM integration for partner notifications
- [x] **Panic Mode** - Instant hide and lock functionality
- [x] **Auto-lock** - Background detection and security

### Architecture
- [x] **Clean Service Layer** - Modular backend integration
- [x] **Configuration System** - Centralized app configuration
- [x] **Model Compatibility** - Same data structures as Chatsusa
- [x] **Error Handling** - Comprehensive error management
- [x] **Security Implementation** - Secure storage and authentication

## 🔧 Required Configuration

### 1. Supabase Setup (CRITICAL)
**File**: `lib/config/app_config.dart`

```dart
// Replace these with your actual Chatsusa Supabase credentials
static const String supabaseUrl = 'https://your-actual-project.supabase.co';
static const String supabaseAnonKey = 'your-actual-anon-key';
```

### 2. Firebase Setup (CRITICAL)
**Files to replace**:
- `android/app/google-services.json` - Your Firebase Android config
- `ios/Runner/GoogleService-Info.plist` - Your Firebase iOS config

### 3. Database Schema
Ensure these tables exist in your Supabase database:

```sql
-- Users (should exist from Chatsusa)
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

-- Messages (should exist from Chatsusa)
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

-- Memories for bookmarked messages
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

### 4. Storage Buckets
Ensure these buckets exist in Supabase Storage:
- `chat-media` - For images, videos, audio, files
- `avatars` - For user profile pictures
- `temp-uploads` - For temporary file storage

### 5. Edge Functions
Create Supabase Edge Function for partner notifications:

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

## 🚀 Build and Deploy

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Platform Configuration

#### Android
Update `android/app/build.gradle.kts`:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Add this
}
```

Update `android/build.gradle.kts`:
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.3.15") // Add this
}
```

#### iOS
1. Open `ios/Runner.xcworkspace` in Xcode
2. Add `GoogleService-Info.plist` to Runner target
3. Enable Push Notifications capability
4. Configure background modes for notifications

### 3. Test Build
```bash
flutter build apk --debug  # Android
flutter build ios --debug  # iOS
```

## 🔒 Security Checklist

### Production Deployment
- [ ] Replace Firebase config files with production credentials
- [ ] Update Supabase configuration with production URL and keys
- [ ] Disable debug features in `app_config.dart`:
  ```dart
  static const bool enableDebugLogging = false;
  static const bool enableDemoShortcuts = false;
  ```
- [ ] Enable code obfuscation:
  ```bash
  flutter build apk --obfuscate --split-debug-info=build/debug-info
  ```
- [ ] Test on multiple device types and orientations
- [ ] Verify tilt detection accuracy
- [ ] Test notification delivery
- [ ] Validate chat sync with Chatsusa website
- [ ] Test panic mode and auto-lock

### Security Validation
- [ ] PIN storage uses device keychain
- [ ] No sensitive data in local storage
- [ ] HTTPS-only network communications
- [ ] Proper session management
- [ ] Background app detection works
- [ ] Tilt detection cannot be easily triggered accidentally

## 📱 Usage Instructions

### Normal Operation
1. App appears as standard "Compass & Level" utility
2. Two functional tabs with realistic compass and level tools
3. No visible indication of hidden features

### Accessing Hidden Chat
1. **Tilt Detection**: Hold device at ~127° tilt with minimal movement for 3 seconds
2. **PIN Setup**: First access requires setting 4-digit PIN
3. **Authentication**: Sign in with existing Chatsusa account
4. **Chat Access**: Full secure messaging functionality

### Emergency Features
- **Panic Mode**: Long press chat title or tap shield icon
- **Auto-lock**: App locks when backgrounded
- **Partner Notification**: Tap notification icon (5-minute cooldown)

## 🐛 Troubleshooting

### Common Issues
- **Tilt not working**: Check device sensors, test on physical device
- **Notifications not received**: Verify FCM setup and device tokens
- **Chat not syncing**: Check Supabase credentials and network
- **PIN not saving**: Verify flutter_secure_storage permissions

### Debug Mode
- Enable logging in `app_config.dart`
- Use Flutter Inspector for UI issues
- Check device logs for sensor data
- Monitor Supabase dashboard for API calls

## ✅ Final Verification

Before production deployment:
- [ ] Configuration updated with real credentials
- [ ] Database schema matches Chatsusa exactly
- [ ] Storage buckets configured and accessible
- [ ] Firebase notifications working end-to-end
- [ ] Chat messages sync with Chatsusa website
- [ ] Tilt detection works reliably
- [ ] PIN security functions properly
- [ ] Panic mode hides app instantly
- [ ] Partner notifications deliver correctly
- [ ] App appears completely normal to casual users

## 📞 Support

For issues with:
- **Supabase Integration**: Check Supabase dashboard and logs
- **Firebase Notifications**: Verify FCM configuration and tokens
- **Sensor Detection**: Test on physical device with proper sensors
- **Chat Sync**: Ensure same Supabase project as Chatsusa website

The app is designed to be completely invisible as a hidden chat system while providing full functionality that seamlessly integrates with your existing Chatsusa infrastructure.