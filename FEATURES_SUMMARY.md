# Compass App - Complete Features Summary

## 🎯 Application Overview

**Compass** is a sophisticated stealth secure communication app that masquerades as a legitimate Compass & Level utility application. It provides secure messaging, memory bookmarking, and recording capabilities between two users with military-grade stealth features.

---

## 🔐 Security & Access

### Hidden Unlock Mechanism
- **Trigger**: Tilt device to 127° ± 3° (nearly upside down)
- **Duration**: Hold steady for 3 seconds
- **Validation**: Gyroscope confirms low motion
- **Result**: Unlocks hidden chat interface

### PIN Protection
- **Length**: 4 digits
- **Setup**: First-time users create PIN
- **Verification**: Required on each unlock
- **Attempts**: Max 5 attempts before 30-minute lockout
- **Storage**: Secure storage using flutter_secure_storage

### Auto-Lock Features
- **Background Lock**: Locks when app goes to background
- **Panic Mode**: Long-press title to trigger panic
- **Last Active**: Tracks user activity
- **Timeout**: Configurable auto-lock timeout

---

## 📱 Public Interface (Compass & Level)

### Compass Tab
- **Real Compass**: Uses device magnetometer for true north
- **Heading Display**: Shows current heading in degrees
- **Cardinal Directions**: N, NE, E, SE, S, SW, W, NW
- **Smooth Animation**: Real-time compass needle animation
- **Accuracy Indicator**: Shows compass accuracy level
- **Auto-Rotation**: Rotates with device orientation

### Level Tab
- **Accelerometer**: Uses device accelerometer for leveling
- **Bubble Level**: Visual bubble indicator
- **Angle Display**: Shows tilt angle in degrees
- **Calibration**: Auto-calibrates on startup
- **Accuracy**: High-precision leveling

### Stealth Features
- **Legitimate Appearance**: Looks like real utility app
- **No Chat Indicators**: No visible messaging features
- **Normal Permissions**: Only requests necessary permissions
- **Notification Masking**: Notifications appear as "Compass Update"

---

## 💬 Hidden Chat Interface

### Chat Features
- **Real-Time Messaging**: Instant message delivery
- **Message Types**: Text, images, videos, audio, files
- **Typing Indicators**: Shows when partner is typing
- **Online Status**: Real-time online/offline status
- **Message Reactions**: React to messages with emojis
- **Message Replies**: Quote and reply to specific messages
- **Read Receipts**: See when messages are read

### Chat Interface
- **Tab-Based**: Chat, Memories, Recordings tabs
- **User Selection**: Choose chat partner from available users
- **Message History**: Loads previous messages on scroll
- **Auto-Scroll**: Automatically scrolls to latest message
- **Scroll-to-Bottom**: Button appears when scrolled up
- **Emoji Picker**: Built-in emoji selection

### Message Management
- **Delete Messages**: Remove sent messages
- **Edit Messages**: Edit message content
- **Forward Messages**: Share messages with partner
- **Search Messages**: Find specific messages
- **Message Status**: Sending, sent, delivered, read, failed

---

## 📌 Memories Feature

### Memory Management
- **Bookmark Messages**: Save important messages
- **Standalone Memories**: Create memories without messages
- **Titles & Descriptions**: Add custom titles and descriptions
- **Categories**: Organize by category (milestone, adventure, important, etc.)
- **Likes**: Like/unlike memories
- **Media Support**: Attach images, videos, or files

### Memory Organization
- **Category Filtering**: Filter by category
- **Date Sorting**: Sort by creation date
- **Search**: Find memories by title or description
- **Tags**: Add multiple tags to memories
- **Favorites**: Mark memories as favorites

### Memory Display
- **Grid View**: Visual memory grid
- **List View**: Detailed memory list
- **Preview**: Quick preview of memory content
- **Metadata**: Shows creation date, likes, category

---

## 🎙️ Recordings Feature (NEW)

### Recording Types
- **Audio Recordings**: Voice messages and audio notes
- **Video Recordings**: Video messages and video calls
- **Duration**: Tracks recording length
- **File Size**: Shows file size information

### Recording Management

#### My Recordings Tab
- **View Sent Recordings**: All recordings you sent
- **Upload Recording**: Record and send new recordings
- **Delete Recording**: Remove sent recordings
- **Edit Metadata**: Add title and description
- **Recording Type**: Audio or video

#### Partner Recordings Tab
- **View Received Recordings**: All recordings from partner
- **Unread Count**: Badge shows unread recordings
- **Mark as Read**: Mark recordings as read
- **Delete Recording**: Remove received recordings
- **Playback**: Play audio/video recordings

### Recording Features
- **Real-Time Streaming**: Live recording updates
- **Unread Indicator**: Shows unread recording count
- **Read Status**: Track which recordings have been read
- **Timestamps**: Shows when recording was created
- **Duration Display**: Shows recording length
- **File Size**: Shows storage size

### Recording Metadata
- **Title**: Custom recording title
- **Description**: Recording description/notes
- **Duration**: Recording length in seconds
- **File Size**: Storage size in bytes
- **Created At**: Timestamp of creation
- **Read At**: When recording was first read

---

## 👥 User Management

### User Accounts

#### Male Account
- **Username**: `saketh_nandu127`
- **Password**: `SupriyaSaketh127`
- **Display Name**: Saketh
- **User ID**: 550e8400-e29b-41d4-a716-446655440001

#### Female Account
- **Username**: `srirenu127`
- **Password**: `#filmmaking`
- **Display Name**: Srirenu
- **User ID**: 550e8400-e29b-41d4-a716-446655440002

### User Profile
- **Display Name**: User's display name
- **Avatar**: User profile picture
- **Status**: Online, away, busy, offline
- **Last Seen**: Last activity timestamp
- **Metadata**: Additional user information

### User Selection
- **Available Users**: List of users to chat with
- **User Search**: Find users by name
- **User Status**: See online/offline status
- **Switch Partner**: Change chat partner anytime

---

## 🔔 Notifications

### Notification Types
- **Message Notifications**: New message alerts
- **Recording Notifications**: New recording alerts
- **Typing Notifications**: Partner typing indicator
- **Status Notifications**: Online/offline status changes

### Notification Masking
- **Stealth Messages**: Appear as "Compass Update"
- **Generic Title**: No indication of chat content
- **Silent Notifications**: Can be configured as silent
- **Custom Sound**: Optional notification sound

### Notification Management
- **Enable/Disable**: Toggle notifications
- **Sound**: Custom notification sound
- **Vibration**: Haptic feedback
- **LED**: LED notification indicator

---

## 🗄️ Database Structure

### Tables

#### users
- `id`: User UUID
- `email`: User email
- `display_name`: Display name
- `avatar_url`: Profile picture URL
- `status`: Online status
- `last_seen`: Last activity time
- `metadata`: Additional data
- `created_at`: Account creation time

#### messages
- `id`: Message UUID
- `sender_id`: Sender user ID
- `recipient_id`: Recipient user ID
- `content`: Message text
- `message_type`: Text, image, video, audio, file, etc.
- `media_url`: Media file URL
- `media_filename`: Media file name
- `reactions`: JSON array of reactions
- `read_at`: When message was read
- `created_at`: Message creation time

#### memories
- `id`: Memory UUID
- `user_id`: Owner user ID
- `message_id`: Linked message ID (optional)
- `title`: Memory title
- `description`: Memory description
- `media_url`: Media file URL
- `category`: Memory category
- `likes`: Like count
- `tags`: Array of tags
- `created_at`: Creation time

#### recordings
- `id`: Recording UUID
- `sender_id`: Sender user ID
- `recipient_id`: Recipient user ID
- `recording_url`: Recording file URL
- `recording_type`: Audio or video
- `duration_seconds`: Recording length
- `file_size`: File size in bytes
- `title`: Recording title
- `description`: Recording description
- `read_at`: When recording was read
- `created_at`: Creation time

#### typing_indicators
- `user_id`: Typing user ID
- `recipient_id`: Recipient user ID
- `is_typing`: Typing status
- `updated_at`: Last update time

#### device_tokens
- `id`: Token UUID
- `user_id`: User ID
- `token`: FCM token
- `platform`: Android, iOS, or web
- `device_info`: Device information
- `active`: Token active status
- `created_at`: Creation time

---

## 🚀 Building & Deployment

### Local Build
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split by architecture
flutter build apk --release --split-per-abi
```

### GitHub Actions Build
- **Automatic**: Triggers on push to main/develop
- **Manual**: Via Actions tab "Run workflow"
- **Artifacts**: Download APK from workflow run
- **Releases**: Create GitHub release with APK

### Installation
```bash
# Via ADB
adb install compass-release.apk

# Manual: Transfer APK to device and tap to install
```

---

## 🔧 Configuration

### Supabase
- **Project URL**: https://oltzkkchoohpwbipqkeh.supabase.co
- **Anon Key**: Configured in app_config.dart
- **Database**: PostgreSQL with real-time capabilities
- **Storage**: File storage for media and recordings

### Firebase
- **Project**: compass-d098d
- **FCM**: Cloud Messaging for notifications
- **Service Account**: For backend notifications

### App Config
- **Tilt Angle**: 127° ± 3°
- **PIN Length**: 4 digits
- **Auto-Lock**: 5 minutes
- **Max PIN Attempts**: 5

---

## 📊 Technical Stack

### Frontend
- **Framework**: Flutter 3.24.5
- **Language**: Dart
- **State Management**: Provider
- **Navigation**: GoRouter
- **UI**: Material 3

### Backend
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Real-Time**: Supabase Realtime
- **Storage**: Supabase Storage
- **Notifications**: Firebase Cloud Messaging

### Sensors
- **Magnetometer**: Compass heading
- **Accelerometer**: Level/tilt detection
- **Gyroscope**: Motion validation

### Security
- **Encryption**: HTTPS in transit
- **Secure Storage**: flutter_secure_storage
- **PIN**: 4-digit PIN protection
- **RLS**: Row Level Security on database

---

## 📈 Performance

### Optimization
- **Lazy Loading**: Messages load on demand
- **Caching**: Network image caching
- **Pagination**: Message pagination
- **Real-Time**: Efficient real-time updates
- **Compression**: Media compression

### Resource Usage
- **Memory**: ~50-100 MB
- **Storage**: ~20-30 MB (app only)
- **Battery**: Optimized sensor usage
- **Network**: Minimal data usage

---

## 🎓 User Guide

### First Time Setup
1. Install APK on Android device
2. Open Compass app
3. Tap on compass to verify it works
4. Tilt device to 127° for 3 seconds
5. Enter 4-digit PIN (create on first use)
6. Access hidden chat interface

### Daily Usage
1. Open Compass app
2. Tilt to unlock (127° for 3 seconds)
3. Enter PIN
4. Select chat partner
5. Send messages, recordings, or memories
6. View partner's recordings in "Partner Recordings" tab

### Recording Usage
1. Go to Recordings tab
2. Click "My Recordings" to send
3. Click "Partner Recordings" to view received
4. Unread count shows in tab badge
5. Mark as read when viewed
6. Delete when no longer needed

---

## ✅ Feature Checklist

- [x] Compass with real magnetometer
- [x] Level with accelerometer
- [x] Hidden tilt detection (127°)
- [x] PIN security (4 digits)
- [x] Real-time chat messaging
- [x] Message reactions and replies
- [x] Typing indicators
- [x] Online/offline status
- [x] Memories with bookmarking
- [x] Audio recordings
- [x] Video recordings
- [x] Recording read status
- [x] Unread recording count
- [x] Auto-lock on background
- [x] Panic mode
- [x] Supabase integration
- [x] Firebase notifications
- [x] GitHub Actions CI/CD
- [x] APK building
- [x] User authentication

---

## 🔐 Security Checklist

- [x] Tilt detection with gyroscope validation
- [x] PIN protection with attempt limiting
- [x] Secure storage for sensitive data
- [x] HTTPS for all network communication
- [x] Row Level Security on database
- [x] Auto-lock on app background
- [x] Panic mode for emergency
- [x] Notification masking
- [x] No visible chat indicators
- [x] Legitimate app appearance

---

**Last Updated**: May 6, 2026
**Version**: 1.0.0
**Status**: Production Ready ✅
