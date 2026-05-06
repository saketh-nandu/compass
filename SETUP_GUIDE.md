# Compass App - Setup & Build Guide

## 📱 Overview

Compass is a stealth secure chat application that appears as a legitimate Compass & Level utility app. It includes hidden chat, memories, and recording features powered by Supabase backend.

## 🔐 Login Credentials

### Male Account
- **Username/Email**: `saketh_nandu127`
- **Password**: `SupriyaSaketh127`

### Female Account
- **Username/Email**: `srirenu127`
- **Password**: `#filmmaking`

## 🔓 Hidden Unlock

To access the hidden chat interface:
1. Tilt your device to approximately **127° ± 3°** (nearly upside down)
2. Keep the device steady for **3 seconds**
3. The hidden interface will unlock automatically

## 📋 Features

### 1. **Compass & Level (Public Interface)**
- Real compass using device magnetometer
- Level tool using accelerometer
- Appears as legitimate utility app

### 2. **Hidden Chat (Stealth Mode)**
- Secure messaging between two users
- Real-time message delivery
- Message reactions and replies
- Typing indicators
- Online/offline status

### 3. **Memories**
- Bookmark important messages
- Categorize memories
- Add titles and descriptions
- Like/unlike memories

### 4. **Recordings**
- Record audio and video messages
- Two tabs: "My Recordings" and "Partner Recordings"
- Unread recording count badge
- Mark recordings as read
- Delete recordings

## 🚀 Building with GitHub Actions

### Prerequisites
- GitHub account
- Flutter project pushed to GitHub

### Setup Steps

1. **Push to GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/YOUR_USERNAME/compass.git
   git push -u origin main
   ```

2. **GitHub Actions Workflow**
   - The workflow file is already created at `.github/workflows/build-apk.yml`
   - It automatically triggers on:
     - Push to `main` or `develop` branches
     - Pull requests to `main` or `develop`
     - Manual trigger via "Run workflow"

3. **Build Triggers**
   - **Automatic**: Every push to main/develop
   - **Manual**: Go to Actions tab → Build APK → Run workflow
   - **Tags**: Create a tag to build and release

4. **Download APK**
   - Go to GitHub Actions tab
   - Click on the latest build
   - Download artifacts:
     - `compass-debug.apk` (for testing)
     - `compass-release.apk` (for distribution)

### Build Locally

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APK by architecture (faster)
flutter build apk --release --split-per-abi
```

## 🗄️ Database Setup

### Supabase Configuration

The app uses Supabase for backend:
- **Project URL**: `https://oltzkkchoohpwbipqkeh.supabase.co`
- **Anon Key**: Configured in `lib/config/app_config.dart`

### Database Tables

1. **users** - User profiles
2. **messages** - Chat messages
3. **memories** - Bookmarked content
4. **recordings** - Audio/video recordings
5. **typing_indicators** - Real-time typing status
6. **device_tokens** - FCM notification tokens

### Create Test Users

Users must be created via Supabase Auth API:

```bash
# Using Supabase CLI
supabase auth admin create-user \
  --email saketh_nandu127@compass.app \
  --password SupriyaSaketh127

supabase auth admin create-user \
  --email srirenu127@compass.app \
  --password "#filmmaking"
```

Or use Supabase Dashboard:
1. Go to Authentication → Users
2. Click "Add user"
3. Enter email and password
4. Click "Create user"

## 📦 APK Installation

### On Android Device

1. **Enable Unknown Sources**
   - Settings → Security → Unknown Sources (Enable)

2. **Install APK**
   ```bash
   adb install compass-release.apk
   ```

3. **Or Manual Installation**
   - Transfer APK to device
   - Open file manager
   - Tap APK file
   - Follow installation prompts

### On Android Emulator

```bash
# Start emulator
emulator -avd Pixel_4_API_30

# Install APK
adb install compass-release.apk

# Or use Flutter
flutter install
```

## 🔧 Configuration

### App Config (`lib/config/app_config.dart`)

```dart
// Supabase credentials
static const String supabaseUrl = 'https://oltzkkchoohpwbipqkeh.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';

// Tilt detection
static const double targetTiltAngle = 127.0;
static const double tiltTolerance = 3.0;

// PIN security
static const int pinLength = 4;
static const int maxPinAttempts = 5;
```

## 🛠️ Development

### Project Structure

```
my_app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── nav.dart                  # Navigation routes
│   ├── theme.dart                # App theming
│   ├── config/
│   │   └── app_config.dart       # Configuration
│   ├── models/
│   │   ├── message.dart
│   │   ├── memory.dart
│   │   ├── recording.dart
│   │   └── chat_user.dart
│   ├── services/
│   │   ├── supabase_service.dart
│   │   ├── auth_service.dart
│   │   ├── chat_service.dart
│   │   ├── memory_service.dart
│   │   ├── recording_service.dart
│   │   └── notification_service.dart
│   ├── screens/
│   │   ├── home_page.dart        # Compass & Level
│   │   ├── unlock_screen.dart    # PIN entry
│   │   ├── chat_screen.dart      # Chat interface
│   │   ├── memories_screen.dart  # Memories
│   │   └── recordings_screen.dart # Recordings
│   └── sensors/
│       └── tilt_detector.dart    # Tilt detection
├── android/                      # Android native code
├── ios/                          # iOS native code
├── supabase/
│   └── migrations/               # Database migrations
└── .github/
    └── workflows/
        └── build-apk.yml         # GitHub Actions
```

### Running Tests

```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Build for testing
flutter build apk --debug
```

## 🐛 Troubleshooting

### Build Issues

**Issue**: Gradle build timeout
- **Solution**: Increase Gradle memory in `android/gradle.properties`:
  ```properties
  org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g
  org.gradle.parallel=true
  org.gradle.caching=true
  ```

**Issue**: Firebase plugin errors
- **Solution**: Ensure `google-services.json` is in `android/app/`

**Issue**: Supabase connection errors
- **Solution**: Check credentials in `lib/config/app_config.dart`

### Runtime Issues

**Issue**: Tilt detection not working
- **Solution**: Ensure device has gyroscope sensor
- **Test**: Use device sensors app to verify

**Issue**: Recordings not saving
- **Solution**: Check storage permissions in `AndroidManifest.xml`

**Issue**: Notifications not appearing
- **Solution**: Verify FCM token in Supabase `device_tokens` table

## 📝 Notes

- The app uses Flutter 3.24.5 for stability
- Supabase provides real-time database and authentication
- Firebase Cloud Messaging for push notifications
- All data is encrypted in transit (HTTPS)
- PIN is stored securely using flutter_secure_storage

## 🔐 Security Features

1. **Tilt Detection**: 127° ± 3° with gyroscope validation
2. **PIN Protection**: 4-digit PIN with max 5 attempts
3. **Auto-lock**: Locks when app goes to background
4. **Panic Mode**: Long-press title to trigger panic
5. **Secure Storage**: flutter_secure_storage for sensitive data
6. **Row Level Security**: Supabase RLS policies for data access

## 📞 Support

For issues or questions:
1. Check GitHub Issues
2. Review Supabase documentation
3. Check Flutter documentation
4. Review app logs: `flutter logs`

## 📄 License

This project is private and confidential.

---

**Last Updated**: May 6, 2026
**Version**: 1.0.0
