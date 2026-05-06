import 'package:intl/intl.dart';

class Recording {
  final String id;
  final String senderId;
  final String recipientId;
  final String recordingUrl;
  final String recordingType; // 'audio' or 'video'
  final int? durationSeconds;
  final int? fileSize;
  final String? title;
  final String? description;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Recording({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.recordingUrl,
    required this.recordingType,
    this.durationSeconds,
    this.fileSize,
    this.title,
    this.description,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Check if recording has been read
  bool get isRead => readAt != null;

  /// Get formatted duration
  String get formattedDuration {
    if (durationSeconds == null) return 'Unknown';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSize == null) return 'Unknown';
    if (fileSize! < 1024) return '${fileSize!} B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(2)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Get formatted creation time
  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(createdAt);
    }
  }

  /// Create from JSON (Supabase response)
  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      recipientId: json['recipient_id'] as String,
      recordingUrl: json['recording_url'] as String,
      recordingType: json['recording_type'] as String? ?? 'audio',
      durationSeconds: json['duration_seconds'] as int?,
      fileSize: json['file_size'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'recording_url': recordingUrl,
      'recording_type': recordingType,
      'duration_seconds': durationSeconds,
      'file_size': fileSize,
      'title': title,
      'description': description,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// Copy with modifications
  Recording copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? recordingUrl,
    String? recordingType,
    int? durationSeconds,
    int? fileSize,
    String? title,
    String? description,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Recording(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      recordingType: recordingType ?? this.recordingType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      fileSize: fileSize ?? this.fileSize,
      title: title ?? this.title,
      description: description ?? this.description,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
