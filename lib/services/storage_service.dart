import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Storage service for uploading and managing files in Supabase
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  final _supabase = Supabase.instance.client;

  // Storage bucket names
  static const String chatMediaBucket = 'chat-media';
  static const String avatarsBucket = 'avatars';
  static const String recordingsBucket = 'recordings';

  /// Upload image to chat-media bucket
  Future<String?> uploadChatImage({
    required File imageFile,
    required String userId,
    required String chatPartnerId,
  }) async {
    try {
      final fileName =
          'chat-images/$userId/$chatPartnerId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage.from(chatMediaBucket).upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl =
          _supabase.storage.from(chatMediaBucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Upload chat image error: $e');
      return null;
    }
  }

  /// Upload video to chat-media bucket
  Future<String?> uploadChatVideo({
    required File videoFile,
    required String userId,
    required String chatPartnerId,
  }) async {
    try {
      final fileName =
          'chat-videos/$userId/$chatPartnerId/${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _supabase.storage.from(chatMediaBucket).upload(
            fileName,
            videoFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl =
          _supabase.storage.from(chatMediaBucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Upload chat video error: $e');
      return null;
    }
  }

  /// Upload audio recording to recordings bucket
  Future<String?> uploadAudioRecording({
    required File audioFile,
    required String userId,
    required String chatPartnerId,
  }) async {
    try {
      final fileName =
          'audio/$userId/$chatPartnerId/${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _supabase.storage.from(recordingsBucket).upload(
            fileName,
            audioFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl =
          _supabase.storage.from(recordingsBucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Upload audio recording error: $e');
      return null;
    }
  }

  /// Upload video recording to recordings bucket
  Future<String?> uploadVideoRecording({
    required File videoFile,
    required String userId,
    required String chatPartnerId,
  }) async {
    try {
      final fileName =
          'video/$userId/$chatPartnerId/${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _supabase.storage.from(recordingsBucket).upload(
            fileName,
            videoFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl =
          _supabase.storage.from(recordingsBucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Upload video recording error: $e');
      return null;
    }
  }

  /// Upload user avatar
  Future<String?> uploadAvatar({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final fileName =
          'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage.from(avatarsBucket).upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl =
          _supabase.storage.from(avatarsBucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Upload avatar error: $e');
      return null;
    }
  }

  /// Upload file to chat-media bucket
  Future<String?> uploadFile({
    required File file,
    required String userId,
    required String chatPartnerId,
    required String fileType, // 'document', 'audio', 'video', etc.
  }) async {
    try {
      final fileName =
          'files/$fileType/$userId/$chatPartnerId/${DateTime.now().millisecondsSinceEpoch}${_getFileExtension(file.path)}';

      await _supabase.storage.from(chatMediaBucket).upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl =
          _supabase.storage.from(chatMediaBucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Upload file error: $e');
      return null;
    }
  }

  /// Delete file from storage
  Future<bool> deleteFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      await _supabase.storage.from(bucketName).remove([filePath]);
      return true;
    } catch (e) {
      debugPrint('Delete file error: $e');
      return false;
    }
  }

  /// Get file size
  Future<int?> getFileSize({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      final file = await _supabase.storage.from(bucketName).info(filePath);
      return file.metadata?['size'] as int?;
    } catch (e) {
      debugPrint('Get file size error: $e');
      return null;
    }
  }

  /// List files in a bucket
  Future<List<FileObject>?> listFiles({
    required String bucketName,
    required String path,
  }) async {
    try {
      final files = await _supabase.storage.from(bucketName).list(path: path);
      return files;
    } catch (e) {
      debugPrint('List files error: $e');
      return null;
    }
  }

  /// Get public URL for a file
  String getPublicUrl({
    required String bucketName,
    required String filePath,
  }) {
    return _supabase.storage.from(bucketName).getPublicUrl(filePath);
  }

  /// Get signed URL for a file (with expiration)
  Future<String?> getSignedUrl({
    required String bucketName,
    required String filePath,
    required int expiresIn, // in seconds
  }) async {
    try {
      final url = await _supabase.storage
          .from(bucketName)
          .createSignedUrl(filePath, expiresIn);
      return url;
    } catch (e) {
      debugPrint('Get signed URL error: $e');
      return null;
    }
  }

  /// Download file from storage
  Future<Uint8List?> downloadFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      final data = await _supabase.storage.from(bucketName).download(filePath);
      return data;
    } catch (e) {
      debugPrint('Download file error: $e');
      return null;
    }
  }

  /// Get file extension
  String _getFileExtension(String filePath) {
    final lastDot = filePath.lastIndexOf('.');
    if (lastDot == -1) return '';
    return filePath.substring(lastDot);
  }

  /// Create storage buckets (admin only)
  Future<void> createBuckets() async {
    try {
      // Create chat-media bucket
      await _supabase.storage.createBucket(
        chatMediaBucket,
        const BucketOptions(public: true),
      );

      // Create avatars bucket
      await _supabase.storage.createBucket(
        avatarsBucket,
        const BucketOptions(public: true),
      );

      // Create recordings bucket
      await _supabase.storage.createBucket(
        recordingsBucket,
        const BucketOptions(public: true),
      );

      debugPrint('Storage buckets created successfully');
    } catch (e) {
      debugPrint('Create buckets error: $e');
    }
  }
}
