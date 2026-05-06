# Compass App - Quick Reference Guide

## 🔐 Login Credentials

| Role | Username | Password |
|------|----------|----------|
| Male | `saketh_nandu127` | `SupriyaSaketh127` |
| Female | `srirenu127` | `#filmmaking` |

## 🔓 Unlock Hidden Chat

**Tilt device to 127° ± 3° and hold for 3 seconds**

## 📱 App Tabs (Hidden Interface)

| Tab | Icon | Features |
|-----|------|----------|
| Chat | 💬 | Messages, reactions, replies, typing indicators |
| Memories | 📌 | Bookmarked content, categories, likes |
| Recordings | 🎙️ | Audio/video recordings, unread count |

## 🎙️ Recordings Feature

### My Recordings
- View recordings you sent
- Upload new recordings
- Delete recordings
- Add title & description

### Partner Recordings
- View recordings from partner
- Unread count badge
- Mark as read
- Delete recordings

## 🗄️ Database Tables

```
users → messages ← recordings
  ↓
memories
  ↓
typing_indicators
  ↓
device_tokens
```

## 🚀 Build Commands

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split by architecture (faster)
flutter build apk --release --split-per-abi

# Analyze code
flutter analyze

# Get dependencies
flutter pub get
```

## 📦 GitHub Actions

### Automatic Triggers
- Push to `main` or `develop`
- Pull requests to `main` or `develop`

### Manual Trigger
1. Go to Actions tab
2. Click "Build APK"
3. Click "Run workflow"
4. Select branch
5. Click "Run workflow"

### Download APK
1. Go to Actions tab
2. Click latest workflow run
3. Scroll to Artifacts
4. Download APK

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `lib/config/app_config.dart` | App configuration & Supabase credentials |
| `lib/main.dart` | App entry point |
| `lib/nav.dart` | Navigation routes |
| `android/app/build.gradle.kts` | Android build configuration |
| `.github/workflows/build-apk.yml` | GitHub Actions workflow |

## 📊 Key Metrics

| Metric | Value |
|--------|-------|
| Flutter Version | 3.24.5 |
| Min SDK | 21 |
| Target SDK | 36 |
| Package Name | com.company.compass |
| Tilt Angle | 127° ± 3° |
| PIN Length | 4 digits |
| Max PIN Attempts | 5 |
| Lockout Duration | 30 minutes |
| Auto-Lock Timeout | 5 minutes |

## 🔐 Security Features

| Feature | Details |
|---------|---------|
| Tilt Detection | 127° ± 3° with gyroscope validation |
| PIN Protection | 4-digit PIN with max 5 attempts |
| Secure Storage | flutter_secure_storage |
| Auto-Lock | Locks on app background |
| Panic Mode | Long-press title |
| Notification Masking | Appears as "Compass Update" |
| RLS | Row Level Security on database |
| Encryption | HTTPS in transit |

## 📱 Device Requirements

| Requirement | Details |
|-------------|---------|
| OS | Android 5.0+ (API 21+) |
| RAM | 2GB minimum |
| Storage | 50MB free space |
| Sensors | Magnetometer, Accelerometer, Gyroscope |
| Network | Internet connection required |

## 🎯 Feature Checklist

- [x] Compass (magnetometer)
- [x] Level (accelerometer)
- [x] Hidden unlock (tilt detection)
- [x] PIN security
- [x] Chat messaging
- [x] Memories
- [x] Recordings (audio & video)
- [x] Real-time updates
- [x] Notifications
- [x] GitHub Actions CI/CD

## 📚 Documentation Files

| File | Content |
|------|---------|
| `SETUP_GUIDE.md` | Complete setup instructions |
| `GITHUB_ACTIONS_GUIDE.md` | GitHub Actions workflow guide |
| `FEATURES_SUMMARY.md` | Complete features documentation |
| `QUICK_REFERENCE.md` | This file |

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Tilt detection not working | Ensure device has gyroscope |
| Build timeout | Increase Gradle memory |
| APK won't install | Check Android version (API 21+) |
| Supabase connection error | Verify credentials in app_config.dart |
| Notifications not appearing | Check FCM token in device_tokens table |

## 🔗 Important URLs

| Resource | URL |
|----------|-----|
| Supabase Project | https://oltzkkchoohpwbipqkeh.supabase.co |
| GitHub Repository | https://github.com/YOUR_USERNAME/compass |
| Flutter Docs | https://flutter.dev/docs |
| Supabase Docs | https://supabase.com/docs |

## 📞 Quick Commands

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/compass.git

# Navigate to project
cd compass/my_app

# Get dependencies
flutter pub get

# Run analyzer
flutter analyze

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk

# View logs
flutter logs

# Clean build
flutter clean
```

## 🎓 User Quick Start

1. **Install**: Download and install APK on Android device
2. **Open**: Tap Compass app icon
3. **Unlock**: Tilt device to 127° for 3 seconds
4. **PIN**: Enter 4-digit PIN (create on first use)
5. **Chat**: Select partner and start messaging
6. **Record**: Go to Recordings tab to send/receive recordings
7. **Memories**: Bookmark important messages in Memories tab

## 🔐 Security Quick Tips

- ✅ Use strong PIN (not 1111, 1234, etc.)
- ✅ Don't share PIN with anyone
- ✅ Lock app when not in use
- ✅ Use panic mode if compromised
- ✅ Delete sensitive recordings
- ✅ Keep app updated
- ✅ Use secure WiFi only
- ✅ Enable notifications for alerts

## 📈 Performance Tips

- Clear old messages periodically
- Delete unused recordings
- Keep app updated
- Restart app if slow
- Check device storage
- Close other apps
- Use WiFi for large files
- Disable animations if slow

## 🎯 Next Steps

1. Read `SETUP_GUIDE.md` for detailed setup
2. Read `GITHUB_ACTIONS_GUIDE.md` for CI/CD
3. Read `FEATURES_SUMMARY.md` for all features
4. Build APK using GitHub Actions
5. Test on Android device
6. Deploy to users

---

**Last Updated**: May 6, 2026
**Version**: 1.0.0
