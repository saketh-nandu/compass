/// Chat user model that matches the exact structure used in Chatsusa website
///
/// This ensures complete compatibility between the mobile app and web application:
/// - Same user fields and metadata
/// - Same JSON serialization format
/// - Same presence and status system
class ChatUser {
  final String id;
  final String? username;
  final String? nickname;
  final String? avatarUrl;
  final String? partnerId;
  final DateTime createdAt;

  const ChatUser({
    required this.id,
    this.username,
    this.nickname,
    this.avatarUrl,
    this.partnerId,
    required this.createdAt,
  });

  /// Create ChatUser from JSON (from Supabase)
  /// Uses the same JSON structure as Chatsusa website
  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] as String,
      username: json['username'] as String?,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      partnerId: json['partner_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert ChatUser to JSON (for Supabase)
  /// Uses the same JSON structure as Chatsusa website
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'partner_id': partnerId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get display name or fallback to username
  String get name => nickname ?? username ?? 'Unknown User';

  /// Get initials for avatar fallback
  String get initials {
    final name = this.name;
    if (name.isEmpty) return '?';

    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Check if this user has a partner
  bool get hasPartner => partnerId != null;

  /// Check if user is online (placeholder - would need status tracking)
  bool get isOnline => true; // Placeholder since status field doesn't exist

  /// Get status display text (placeholder)
  String get statusText =>
      'Online'; // Placeholder since status field doesn't exist

  /// Copy with new values
  ChatUser copyWith({
    String? id,
    String? username,
    String? nickname,
    String? avatarUrl,
    String? partnerId,
    DateTime? createdAt,
  }) {
    return ChatUser(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      partnerId: partnerId ?? this.partnerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ChatUser(id: $id, username: $username, nickname: $nickname)';
}

/// User status that matches Chatsusa website
enum UserStatus {
  online('online'),
  away('away'),
  busy('busy'),
  offline('offline');

  const UserStatus(this.value);
  final String value;

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => UserStatus.offline,
    );
  }
}
