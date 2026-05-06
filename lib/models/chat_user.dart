/// Chat user model that matches the exact structure used in Chatsusa website
///
/// This ensures complete compatibility between the mobile app and web application:
/// - Same user fields and metadata
/// - Same JSON serialization format
/// - Same presence and status system
class ChatUser {
  final String id;
  final String? email;
  final String? username;
  final String? nickname;
  final String? displayName;
  final String? avatarUrl;
  final String? partnerId;
  final String status;
  final DateTime? lastSeenAt;
  final DateTime createdAt;

  const ChatUser({
    required this.id,
    this.email,
    this.username,
    this.nickname,
    this.displayName,
    this.avatarUrl,
    this.partnerId,
    this.status = 'offline',
    this.lastSeenAt,
    required this.createdAt,
  });

  /// Create ChatUser from JSON (from Supabase)
  /// Uses the same JSON structure as Chatsusa website
  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      username: json['username'] as String?,
      nickname: json['nickname'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      partnerId: json['partner_id'] as String?,
      status: json['status'] as String? ?? 'offline',
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'] as String)
          : null,
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
      'email': email,
      'username': username,
      'nickname': nickname,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'partner_id': partnerId,
      'status': status,
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get display name or fallback to username
  String get name => displayName ?? nickname ?? username ?? 'Unknown User';

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

  /// Check if user is online
  bool get isOnline => status == 'online';

  /// Get status display text
  String get statusText => status == 'online' ? 'Online' : 'Offline';

  /// Copy with new values
  ChatUser copyWith({
    String? id,
    String? email,
    String? username,
    String? nickname,
    String? displayName,
    String? avatarUrl,
    String? partnerId,
    String? status,
    DateTime? lastSeenAt,
    DateTime? createdAt,
  }) {
    return ChatUser(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      partnerId: partnerId ?? this.partnerId,
      status: status ?? this.status,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
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
