/// Memory model for saved memories (not linked to messages)
///
/// Represents a standalone memory with media and description
/// Compatible with Supabase backend structure matching CSV data
class Memory {
  final String id;
  final String userId;
  final String? title;
  final String? description;
  final String? mediaUrl;
  final String? mediaType;
  final String? category;
  final int likes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Memory({
    required this.id,
    required this.userId,
    this.title,
    this.description,
    this.mediaUrl,
    this.mediaType,
    this.category,
    this.likes = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create Memory from JSON (from Supabase)
  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      mediaUrl: json['media_url'] as String?,
      mediaType: json['media_type'] as String?,
      category: json['category'] as String?,
      likes: json['likes'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Memory to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'category': category,
      'likes': likes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get display title for the memory
  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    return 'Untitled Memory';
  }

  /// Get preview text for the memory
  String get previewText {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    return 'No description';
  }

  /// Check if memory has media
  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;

  /// Check if memory has category
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  /// Copy with new values
  Memory copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? mediaUrl,
    String? mediaType,
    String? category,
    int? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Memory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      category: category ?? this.category,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Memory && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Memory(id: $id, title: $title, category: $category)';
}
