# 🧭 Compass - Stealth Secure Chat App

A sophisticated Flutter application that appears as a legitimate Compass & Level utility app while providing secure, real-time messaging, memory bookmarking, and recording capabilities between two users.

## 🎯 Overview

**Compass** is a stealth communication platform designed for secure, private conversations. It masquerades as a standard utility app (Compass & Level) while hiding a fully-featured secure chat system accessible only through a hidden tilt-detection unlock mechanism.

### Key Features
- 🧭 **Real Compass** - Actual magnetometer-based compass
- 📐 **Level Tool** - Accelerometer-based leveling
- 🔐 **Hidden Chat** - Tilt detection at 127° ± 3°
- 💬 **Real-Time Messaging** - Instant message delivery
- 📌 **Memories** - Bookmark and categorize messages
- 🎙️ **Recordings** - Audio and video message recordings
- 🔔 **Notifications** - Firebase Cloud Messaging
- 🛡️ **Security** - PIN protection, auto-lock, panic mode

## 🚀 Quick Start

### Prerequisites
- Android 5.0+ (API 21+)
- 2GB RAM minimum
- Device with magnetometer, accelerometer, and gyroscope

### Installation

1. **Download APK**
   - Get from GitHub Actions artifacts
   - Or build locally: `flutter build apk --release`

2. **Install on Device**
   ```bash
   adb install compass-release.apk
   ```

3. **First Launch**
   - Open Compass app
   - Verify compass works
   - Tilt device to 127° for 3 seconds
   - Create 4-digit PIN
   - Select chat partner
   - Start messaging!

### Login Credentials

| Role | Username | Password |
|------|----------|----------|
|

## 🔓 Unlock Hidden Chat

**Tilt your device to approximately 127° ± 3° (nearly upside down) and hold steady for 3 seconds.**

The hidden chat interface will unlock automatically.

## 📱 Features

### Compass & Level (Public Interface)
- Real-time compass heading using magnetometer
- Cardinal direction display (N, NE, E, SE, S, SW, W, NW)
- Smooth compass needle animation
- Accuracy indicator
- Level tool with bubble indicator
- Tilt angle display

### Hidden Chat (Stealth Mode)
- Real-time messaging with Supabase
- Message reactions and replies
- Typing indicators
- Online/offline status
- Message read receipts
- Media sharing (images, videos, audio, files)
- User selection for chat partners

### Memories
- Bookmark important messages
- Create standalone memories
- Categorize memories
- Add titles and descriptions
- Like/unlike memories
- Search and filter

### Recordings (NEW)
- **My Recordings** - Send audio/video recordings
- **Partner Recordings** - View received recordings
- Unread recording count badge
- Mark recordings as read
- Recording metadata (duration, size, date)
- Delete recordings

### Security
- 4-digit PIN protection
- Secure storage using flutter_secure_storage
- Auto-lock on app background
- Panic mode (long-press title)
- Tilt detection with gyroscope validation
- Notification masking
- Row Level Security on database

## 🛠️ Technology Stack

### Frontend
- **Framework**: Flutter 3.24.5
- **Language**: Dart
- **State Management**: Provider
- **Navigation**: GoRouter
- **UI**: Material 3 Design

### Backend
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Real-Time**: Supabase Realtime
- **Storage**: Supabase Storage
- **Notifications**: Firebase Cloud Messaging

### DevOps
- **Version Control**: Git
- **CI/CD**: GitHub Actions
- **Build Tool**: Gradle
- **Package Manager**: Pub

## 📦 Database Schema

### Tables
- **users** - User profiles and status
- **messages** - Chat messages with reactions
- **memories** - Bookmarked content
- **recordings** - Audio/video recordings
- **typing_indicators** - Real-time typing status
- **device_tokens** - FCM notification tokens
- **notification_preferences** - User settings

### Storage Buckets
- `chat-media` - Messages and recordings
- `avatars` - User profile pictures
- `temp-uploads` - Temporary uploads

## 🚀 Building & Deployment

### Local Build
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split by architecture (faster)
flutter build apk --release --split-per-abi
```

### GitHub Actions
- Automatic builds on push to main/develop
- Manual trigger via Actions tab
- Download APK from workflow artifacts
- Automatic releases on version tags

### Installation
```bash
# Via ADB
adb install compass-release.apk

# Manual: Transfer APK to device and tap to install
```

## 📚 Documentation

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Complete setup instructions
- **[GITHUB_ACTIONS_GUIDE.md](GITHUB_ACTIONS_GUIDE.md)** - CI/CD workflow guide
- **[FEATURES_SUMMARY.md](FEATURES_SUMMARY.md)** - Complete features documentation
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick lookup guide
- **[PUSH_TO_GITHUB.md](PUSH_TO_GITHUB.md)** - GitHub push instructions
- **[PROJECT_COMPLETION_SUMMARY.md](PROJECT_COMPLETION_SUMMARY.md)** - Project overview

## 🔐 Security Features

| Feature | Details |
|---------|---------|
| Tilt Detection | 127° ± 3° with gyroscope validation |
| PIN Protection | 4-digit PIN with max 5 attempts |
| Secure Storage | flutter_secure_storage |
| Auto-Lock | Locks on app background |
| Panic Mode | Long-press title to trigger |
| Notification Masking | Appears as "Compass Update" |
| RLS | Row Level Security on database |
| Encryption | HTTPS in transit |
| Stealth UI | Legitimate app appearance |

## 📊 Project Statistics

- **Total Files**: 188
- **Dart Files**: 20+
- **Lines of Code**: 51,903+
- **Flutter Analysis**: 0 errors ✅
- **Documentation**: 6 comprehensive guides
- **Database Tables**: 7
- **Storage Buckets**: 3

## 🎯 Usage Guide

### First Time Setup
1. Install APK on Android device
2. Open Compass app
3. Tilt device to 127° for 3 seconds
4. Enter 4-digit PIN (create on first use)
5. Select chat partner
6. Start messaging

### Sending Messages
1. Go to Chat tab
2. Type message
3. Tap send button
4. Message appears in real-time

### Recording Messages
1. Go to Recordings tab
2. Click "My Recordings"
3. Record audio or video
4. Add title and description
5. Send to partner

### Viewing Partner Recordings
1. Go to Recordings tab
2. Click "Partner Recordings"
3. See unread count badge
4. Tap recording to view
5. Mark as read

### Creating Memories
1. Go to Memories tab
2. Click "+" button
3. Add title and description
4. Select category
5. Save memory

## 🐛 Troubleshooting

### Tilt Detection Not Working
- Ensure device has gyroscope sensor
- Test with device sensors app
- Verify tilt angle is 127° ± 3°

### Build Timeout
- Increase Gradle memory in `android/gradle.properties`
- Enable parallel builds
- Check internet connection

### APK Won't Install
- Check Android version (API 21+)
- Ensure sufficient storage space
- Try debug APK first

### Supabase Connection Error
- Verify credentials in `lib/config/app_config.dart`
- Check internet connection
- Verify Supabase project is active

### Notifications Not Appearing
- Check FCM token in device_tokens table
- Verify Firebase configuration
- Check notification permissions

## 🔗 Important Links

| Resource | URL |
|----------|-----|
| GitHub Repository | https://github.com/saketh-nandu/compass |
| Supabase Project | https://oltzkkchoohpwbipqkeh.supabase.co |
| Flutter Documentation | https://flutter.dev/docs |
| Supabase Documentation | https://supabase.com/docs |
| Firebase Documentation | https://firebase.google.com/docs |

## 📞 Support

For issues or questions:
1. Check documentation files
2. Review GitHub Issues
3. Check Flutter/Supabase documentation
4. View app logs: `flutter logs`

## 📄 License

This project is private and confidential.

## 👨‍💻 Developer

**Saketh Nandu**
- GitHub: [@saketh-nandu](https://github.com/saketh-nandu)
- Email: mantolsaketh@gmail.com

## 🎉 Status

✅ **Production Ready**

- All features implemented
- Zero code errors
- Comprehensive documentation
- Automated CI/CD pipeline
- Ready for deployment

---

**Version**: 1.0.0  
**Last Updated**: May 6, 2026  
**Status**: Complete ✅

**Repository**: https://github.com/saketh-nandu/compass
