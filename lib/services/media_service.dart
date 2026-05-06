import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../config/app_config.dart';

/// Media service for handling all media operations
///
/// Integrates with the same Supabase Storage buckets as Chatsusa website:
/// - Same storage structure and organization
/// - Compatible file naming and paths
/// - Supports all media types used in Chatsusa
class MediaService {
  static MediaService? _instance;
  static MediaService get instance => _instance ??= MediaService._();

  MediaService._();

  final ImagePicker _imagePicker = ImagePicker();
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Storage bucket names (same as Chatsusa website)
  static const String chatMediaBucket = AppConfig.chatMediaBucket;
  static const String avatarsBucket = AppConfig.avatarsBucket;
  static const String tempBucket = AppConfig.tempUploadsBucket;

  /// Pick image from camera or gallery
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      // Request permissions
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          debugPrint('Camera permission denied');
          return null;
        }
      } else {
        final photosStatus = await Permission.photos.request();
        if (!photosStatus.isGranted) {
          debugPrint('Photos permission denied');
          return null;
        }
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Pick image error: $e');
      return null;
    }
  }

  /// Pick video from camera or gallery
  Future<File?> pickVideo({ImageSource source = ImageSource.gallery}) async {
    try {
      // Request permissions
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          debugPrint('Camera permission denied');
          return null;
        }
      } else {
        final photosStatus = await Permission.photos.request();
        if (!photosStatus.isGranted) {
          debugPrint('Photos permission denied');
          return null;
        }
      }

      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5), // 5 minute limit
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Pick video error: $e');
      return null;
    }
  }

  /// Pick file using file picker
  Future<File?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          return File(file.path!);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Pick file error: $e');
      return null;
    }
  }

  /// Upload file to Supabase Storage
  /// Uses the same bucket structure as Chatsusa website
  Future<String?> uploadFile({
    required File file,
    required String bucket,
    String? customPath,
    Function(double)? onProgress,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('User not authenticated');
        return null;
      }

      // Generate file path (same structure as Chatsusa)
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final storagePath =
          customPath ?? '${currentUser.id}/$timestamp.$fileExtension';

      // Upload file
      await _client.storage.from(bucket).upload(
            storagePath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _client.storage.from(bucket).getPublicUrl(storagePath);

      debugPrint('File uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Upload file error: $e');
      return null;
    }
  }

  /// Upload image with compression
  Future<String?> uploadImage({
    required File imageFile,
    String bucket = chatMediaBucket,
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      // For now, upload directly - in production you might want to compress first
      return await uploadFile(
        file: imageFile,
        bucket: bucket,
      );
    } catch (e) {
      debugPrint('Upload image error: $e');
      return null;
    }
  }

  /// Upload video with optional compression
  Future<String?> uploadVideo({
    required File videoFile,
    String bucket = chatMediaBucket,
  }) async {
    try {
      // Check file size (limit to 50MB for now)
      final fileSize = await videoFile.length();
      if (fileSize > 50 * 1024 * 1024) {
        debugPrint('Video file too large: ${fileSize / (1024 * 1024)}MB');
        return null;
      }

      return await uploadFile(
        file: videoFile,
        bucket: bucket,
      );
    } catch (e) {
      debugPrint('Upload video error: $e');
      return null;
    }
  }

  /// Upload audio file
  Future<String?> uploadAudio({
    required File audioFile,
    String bucket = chatMediaBucket,
  }) async {
    try {
      return await uploadFile(
        file: audioFile,
        bucket: bucket,
      );
    } catch (e) {
      debugPrint('Upload audio error: $e');
      return null;
    }
  }

  /// Upload general file
  Future<String?> uploadGeneralFile({
    required File file,
    String bucket = chatMediaBucket,
  }) async {
    try {
      // Check file size (limit to 25MB for general files)
      final fileSize = await file.length();
      if (fileSize > 25 * 1024 * 1024) {
        debugPrint('File too large: ${fileSize / (1024 * 1024)}MB');
        return null;
      }

      return await uploadFile(
        file: file,
        bucket: bucket,
      );
    } catch (e) {
      debugPrint('Upload general file error: $e');
      return null;
    }
  }

  /// Delete file from storage
  Future<bool> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);
      return true;
    } catch (e) {
      debugPrint('Delete file error: $e');
      return false;
    }
  }

  /// Get file info
  Future<Map<String, dynamic>?> getFileInfo({
    required String bucket,
    required String path,
  }) async {
    try {
      final response = await _client.storage.from(bucket).info(path);
      return {
        'name': response.name,
        'id': response.id,
        'updated_at': response.updatedAt,
        'created_at': response.createdAt,
        'last_accessed_at': response.lastAccessedAt,
        'metadata': response.metadata,
      };
    } catch (e) {
      debugPrint('Get file info error: $e');
      return null;
    }
  }

  /// Download file to local storage
  Future<File?> downloadFile({
    required String url,
    required String fileName,
  }) async {
    try {
      // This is a simplified version - in production you'd want proper HTTP download
      // For now, we'll just return null as files are accessed via URL
      debugPrint('Download not implemented - files accessed via URL: $url');
      return null;
    } catch (e) {
      debugPrint('Download file error: $e');
      return null;
    }
  }

  /// Get media type from file extension
  String getMediaType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    const videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'];
    const audioExtensions = ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac'];

    if (imageExtensions.contains(extension)) {
      return 'image';
    } else if (videoExtensions.contains(extension)) {
      return 'video';
    } else if (audioExtensions.contains(extension)) {
      return 'audio';
    } else {
      return 'file';
    }
  }

  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Check if file type is supported
  bool isFileTypeSupported(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    const supportedExtensions = [
      // Images
      'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp',
      // Videos
      'mp4', 'mov', 'avi', 'mkv', 'webm', '3gp',
      // Audio
      'mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac',
      // Documents
      'pdf', 'doc', 'docx', 'txt', 'rtf',
      // Archives
      'zip', 'rar', '7z',
      // Other
      'json', 'xml', 'csv',
    ];

    return supportedExtensions.contains(extension);
  }
}
