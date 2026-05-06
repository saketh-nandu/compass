# Storage Setup Guide - Compass App

## Overview
The Compass app uses Supabase Storage to manage all media files including images, videos, audio recordings, and user avatars. The storage system is fully integrated with the backend and automatically handles file uploads through the `StorageService`.

## Storage Buckets

### 1. **chat-media** (Public)
- **Purpose**: Store chat images, videos, and general files
- **Size Limit**: 50 MB per file
- **Allowed Types**: Images, videos, audio, documents
- **Paths**:
  - `chat-images/{userId}/{chatPartnerId}/{timestamp}.jpg`
  - `chat-videos/{userId}/{chatPartnerId}/{timestamp}.mp4`
  - `files/{fileType}/{userId}/{chatPartnerId}/{timestamp}.{ext}`

### 2. **avatars** (Public)
- **Purpose**: Store user profile pictures
- **Size Limit**: 2 MB per file
- **Allowed Types**: Images only
- **Path**: `avatars/{userId}/{timestamp}.jpg`

### 3. **recordings** (Public)
- **Purpose**: Store audio and video recordings
- **Size Limit**: 100 MB per file
- **Allowed Types**: Audio and video files
- **Paths**:
  - `audio/{userId}/{chatPartnerId}/{timestamp}.m4a`
  - `video/{userId}/{chatPartnerId}/{timestamp}.mp4`

## Storage Service API

### StorageService Class
Located at: `lib/services/storage_service.dart`

#### Methods

##### Chat Media Upload
```dart
// Upload image to chat
Future<String?> uploadChatImage({
  required File imageFile,
  required String userId,
  required String chatPartnerId,
})

// Upload video to chat
Future<String?> uploadChatVideo({
  required File videoFile,
  required String userId,
  required String chatPartnerId,
})

// Upload generic file
Future<String?> uploadFile({
  required File file,
  required String userId,
  required String chatPartnerId,
  required String fileType,
})
```

##### Recording Upload
```dart
// Upload audio recording
Future<String?> uploadAudioRecording({
  required File audioFile,
  required String userId,
  required String chatPartnerId,
})

// Upload video recording
Future<String?> uploadVideoRecording({
  required File videoFile,
  required String userId,
  required String chatPartnerId,
})
```

##### Avatar Upload
```dart
// Upload user avatar
Future<String?> uploadAvatar({
  required File imageFile,
  required String userId,
})
```

##### File Management
```dart
// Delete file from storage
Future<bool> deleteFile({
  required String bucketName,
  required String filePath,
})

// Get file size
Future<int?> getFileSize({
  required String bucketName,
  required String filePath,
})

// List files in bucket
Future<List<FileObject>?> listFiles({
  required String bucketName,
  required String path,
})

// Get public URL
String getPublicUrl({
  required String bucketName,
  required String filePath,
})

// Get signed URL (with expiration)
Future<String?> getSignedUrl({
  required String bucketName,
  required String filePath,
  required int expiresIn,
})

// Download file
Future<Uint8List?> downloadFile({
  required String bucketName,
  required String filePath,
})
```

## Integration Points

### 1. Chat Screen (`lib/screens/chat_screen.dart`)
- **Image/Video Upload**: Uses `_sendMediaMessage()` which calls `ChatService.sendMediaMessage()`
- **Flow**:
  1. User picks image/video via `_pickMedia()`
  2. `_sendMediaMessage()` is called with the file
  3. `ChatService.sendMediaMessage()` uses `StorageService` to upload
  4. File URL is stored in database message record
  5. Message appears in chat with media preview

### 2. Recording Service (`lib/services/recording_service.dart`)
- **Recording Upload**: Uses `StorageService.uploadAudioRecording()` and `uploadVideoRecording()`
- **Flow**:
  1. Recording file is created
  2. `RecordingService.uploadRecording()` uploads file via `StorageService`
  3. File URL is stored in `recordings` table
  4. Recording metadata is saved to database

### 3. Memories Screen (`lib/screens/memories_screen.dart`)
- **Media Display**: Shows media from `mediaUrl` field
- **Future Enhancement**: Can add media upload functionality similar to chat

## Database Integration

### Messages Table
```sql
- file_url: URL of uploaded media file
- file_name: Original filename
- file_size: Size in bytes
- type: Message type (image, video, audio, file, text)
```

### Recordings Table
```sql
- recording_url: URL of uploaded recording
- recording_type: 'audio' or 'video'
- file_size: Size in bytes
```

### Users Table
```sql
- avatar_url: URL of user's profile picture
```

## Security & Policies

### Row Level Security (RLS)
All storage buckets have RLS policies enabled:

1. **Chat Media Bucket**:
   - Users can upload files to their own user ID folder
   - Users can view their own files
   - Users can update/delete their own files

2. **Avatars Bucket**:
   - Avatar images are publicly readable
   - Users can only upload/update/delete their own avatar

3. **Recordings Bucket**:
   - Recordings are publicly readable
   - Users can only upload/update/delete their own recordings

### File Size Limits
- Chat media: 50 MB
- Avatars: 2 MB
- Recordings: 100 MB

## Error Handling

All upload methods return `null` on failure. The calling code should:
1. Check for null return value
2. Show user-friendly error message
3. Log error for debugging

Example:
```dart
final mediaUrl = await StorageService.instance.uploadChatImage(
  imageFile: file,
  userId: userId,
  chatPartnerId: partnerId,
);

if (mediaUrl == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Failed to upload image')),
  );
  return;
}
```

## Testing Storage

### Manual Testing Steps
1. **Upload Image to Chat**:
   - Open chat screen
   - Tap media picker → Photo Library
   - Select image
   - Verify image appears in chat

2. **Upload Recording**:
   - Open recordings tab
   - Start recording
   - Stop and save
   - Verify recording appears in list

3. **Upload Avatar**:
   - Go to profile settings
   - Select avatar image
   - Verify avatar updates

### Debugging
- Check Supabase Storage dashboard for uploaded files
- Verify bucket policies in Supabase console
- Check browser console for CORS errors
- Verify file URLs are accessible

## Deployment Checklist

- [ ] Storage buckets created in Supabase
- [ ] RLS policies applied to all buckets
- [ ] File size limits configured
- [ ] MIME type restrictions set
- [ ] Public access enabled for avatars and recordings
- [ ] Chat media bucket access restricted to authenticated users
- [ ] StorageService integrated in ChatService
- [ ] RecordingService using StorageService
- [ ] Error handling implemented in UI
- [ ] File URLs stored in database
- [ ] Media preview working in chat
- [ ] Recordings list showing uploaded files

## Future Enhancements

1. **Progress Indicators**: Show upload progress for large files
2. **Compression**: Compress images/videos before upload
3. **Thumbnails**: Generate thumbnails for media files
4. **Cleanup**: Implement automatic cleanup of old files
5. **Bandwidth Optimization**: Use CDN for media delivery
6. **Encryption**: Encrypt sensitive files at rest
7. **Virus Scanning**: Scan uploaded files for malware
8. **Analytics**: Track storage usage and bandwidth

## Troubleshooting

### Issue: "Failed to upload media"
- Check file size is within limits
- Verify user is authenticated
- Check network connectivity
- Verify bucket exists in Supabase

### Issue: "File not found" when accessing URL
- Verify file was uploaded successfully
- Check bucket is public (for avatars/recordings)
- Verify file path is correct
- Check file hasn't been deleted

### Issue: CORS errors
- Verify Supabase project settings allow your domain
- Check bucket CORS configuration
- Verify file is publicly accessible

### Issue: Slow uploads
- Check file size
- Verify network speed
- Consider compressing files
- Use signed URLs for large files

## References

- [Supabase Storage Documentation](https://supabase.com/docs/guides/storage)
- [Flutter Supabase Storage](https://supabase.com/docs/reference/dart/storage-createbucket)
- [Storage Security Best Practices](https://supabase.com/docs/guides/storage/security)
