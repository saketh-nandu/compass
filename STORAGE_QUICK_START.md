# Storage Quick Start Guide

## TL;DR - Storage is Ready!

The Compass app now has complete file storage support. Here's what you need to know:

## Quick Facts

- **3 Storage Buckets**: chat-media, avatars, recordings
- **Automatic Uploads**: Files upload automatically when you send messages or recordings
- **Public Access**: Avatars and recordings are publicly accessible
- **Secure**: Chat media requires authentication
- **Size Limits**: 50MB (chat), 2MB (avatars), 100MB (recordings)

## How It Works

### Sending a Chat Image
```dart
// User picks image → ChatScreen._pickMedia() → ChatService.sendMediaMessage()
// → StorageService.uploadChatImage() → File uploaded → URL stored in database
```

### Uploading a Recording
```dart
// User records → RecordingService.uploadRecording()
// → StorageService.uploadAudioRecording() → File uploaded → URL stored in database
```

### Uploading an Avatar
```dart
// User selects avatar → StorageService.uploadAvatar()
// → File uploaded → URL stored in users table
```

## For Developers

### Using StorageService

```dart
import 'package:my_app/services/storage_service.dart';

// Upload image
final imageUrl = await StorageService.instance.uploadChatImage(
  imageFile: file,
  userId: currentUserId,
  chatPartnerId: partnerId,
);

// Upload recording
final recordingUrl = await StorageService.instance.uploadAudioRecording(
  audioFile: file,
  userId: currentUserId,
  chatPartnerId: partnerId,
);

// Upload avatar
final avatarUrl = await StorageService.instance.uploadAvatar(
  imageFile: file,
  userId: currentUserId,
);

// Get public URL
final url = StorageService.instance.getPublicUrl(
  bucketName: 'avatars',
  filePath: 'avatars/user-id/timestamp.jpg',
);

// Delete file
await StorageService.instance.deleteFile(
  bucketName: 'chat-media',
  filePath: 'chat-images/user-id/partner-id/timestamp.jpg',
);
```

### Error Handling

```dart
final url = await StorageService.instance.uploadChatImage(
  imageFile: file,
  userId: userId,
  chatPartnerId: partnerId,
);

if (url == null) {
  // Handle error
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Upload failed')),
  );
  return;
}

// Use URL
print('Uploaded to: $url');
```

## Deployment

### 1. Push to Supabase
```bash
cd my_app
supabase db push
```

### 2. Verify Buckets
Go to Supabase Dashboard → Storage and verify:
- ✅ chat-media bucket exists
- ✅ avatars bucket exists
- ✅ recordings bucket exists

### 3. Test Upload
1. Open app
2. Send a chat image
3. Verify image appears in chat

## Bucket Details

| Bucket | Public | Size | Path |
|--------|--------|------|------|
| chat-media | Yes | 50MB | `chat-images/{userId}/{partnerId}/{ts}.jpg` |
| avatars | Yes | 2MB | `avatars/{userId}/{ts}.jpg` |
| recordings | Yes | 100MB | `audio/{userId}/{partnerId}/{ts}.m4a` |

## Common Tasks

### Add Media Upload to New Screen
```dart
import 'package:my_app/services/storage_service.dart';

// Upload file
final url = await StorageService.instance.uploadChatImage(
  imageFile: file,
  userId: userId,
  chatPartnerId: partnerId,
);

// Save URL to database
await supabase.from('table').insert({
  'media_url': url,
  'media_type': 'image',
});
```

### Display Uploaded Media
```dart
Image.network(
  mediaUrl,
  errorBuilder: (context, error, stackTrace) => 
    const Icon(Icons.broken_image),
)
```

### Delete Uploaded File
```dart
await StorageService.instance.deleteFile(
  bucketName: 'chat-media',
  filePath: 'chat-images/user-id/partner-id/timestamp.jpg',
);
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Upload fails | Check file size, network, authentication |
| File not found | Verify bucket exists, file was uploaded |
| CORS error | Check Supabase project settings |
| Slow upload | Check file size, network speed |

## Files to Know

- `lib/services/storage_service.dart` - Main storage service
- `lib/services/chat_service.dart` - Uses StorageService for chat media
- `lib/services/recording_service.dart` - Uses StorageService for recordings
- `supabase/migrations/20260506083351_add_test_users.sql` - Bucket setup
- `STORAGE_SETUP_GUIDE.md` - Detailed documentation

## Next Steps

1. ✅ Push migrations: `supabase db push`
2. ✅ Test uploads in app
3. ✅ Monitor storage usage in Supabase dashboard
4. 📋 Add progress indicators (optional)
5. 📋 Implement compression (optional)

## Support

- Full docs: See `STORAGE_SETUP_GUIDE.md`
- Implementation details: See `STORAGE_IMPLEMENTATION_COMPLETE.md`
- API reference: See `lib/services/storage_service.dart`

---

**Status**: ✅ Ready for Production
