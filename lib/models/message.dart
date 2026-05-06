import 'chat_user.dart';

/// Message model that matches the exact structure used in Chatsusa website
///
/// This ensures complete compatibility between the mobile app and web application:
/// - Same field names and types
/// - Same JSON serialization format
/// - Same message status and metadata
class Message {
  final String id;
  final String senderId;
  final String receiverId; // Changed from recipientId to match database
  final String content;
  final MessageType messageType;
  final String? fileUrl; // Changed from mediaUrl to match database
  final String? fileName; // Changed from mediaFilename to match database
  final int? fileSize; // Added to match database
  final bool edited; // Added to match database
  final List<dynamic> reactions; // Added to match database (JSONB array)
  final DateTime createdAt;
  final DateTime? readAt;
  final String? replyToId;

  // Related objects (from joins)
  final ChatUser? sender;
  final ChatUser? receiver; // Changed from recipient to match database

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId, // Changed from recipientId
    required this.content,
    required this.messageType,
    this.fileUrl, // Changed from mediaUrl
    this.fileName, // Changed from mediaFilename
    this.fileSize, // Added
    this.edited = false, // Added
    this.reactions = const [], // Added
    required this.createdAt,
    this.readAt,
    this.replyToId,
    this.sender,
    this.receiver, // Changed from recipient
  });

  /// Create Message from JSON (from Supabase)
  /// Uses the same JSON structure as Chatsusa website
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String, // Changed from recipient_id
      content: json['content'] as String? ?? '',
      messageType: MessageType.fromString(
          json['type'] as String? ?? 'text'), // Changed from message_type
      fileUrl: json['file_url'] as String?, // Changed from media_url
      fileName: json['file_name'] as String?, // Changed from media_filename
      fileSize: json['file_size'] as int?, // Added
      edited: json['edited'] as bool? ?? false, // Added
      reactions: json['reactions'] as List<dynamic>? ?? [], // Added
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      replyToId: json['reply_to_id'] as String?,
      sender: json['sender'] != null
          ? ChatUser.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      receiver: json['receiver'] != null // Changed from recipient
          ? ChatUser.fromJson(json['receiver'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert Message to JSON (for Supabase)
  /// Uses the same JSON structure as Chatsusa website
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId, // Changed from recipient_id
      'content': content,
      'type': messageType.value, // Changed from message_type
      'file_url': fileUrl, // Changed from media_url
      'file_name': fileName, // Changed from media_filename
      'file_size': fileSize, // Added
      'edited': edited, // Added
      'reactions': reactions, // Added
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'reply_to_id': replyToId,
    };
  }

  /// Check if message is from current user
  bool isFromMe(String currentUserId) => senderId == currentUserId;

  /// Check if message is read
  bool get isRead => readAt != null;

  /// Check if message has media
  bool get hasMedia =>
      fileUrl != null && fileUrl!.isNotEmpty; // Changed from mediaUrl

  /// Backward compatibility getters
  String? get mediaUrl => fileUrl; // For backward compatibility
  String? get mediaFilename => fileName; // For backward compatibility

  /// Get display content (for notifications, previews, etc.)
  String get displayContent {
    switch (messageType) {
      case MessageType.text:
        return content;
      case MessageType.image:
        return '📷 Image${content.isNotEmpty ? ': $content' : ''}';
      case MessageType.video:
        return '🎥 Video${content.isNotEmpty ? ': $content' : ''}';
      case MessageType.audio:
        return '🎵 Audio${content.isNotEmpty ? ': $content' : ''}';
      case MessageType.file:
        return '📎 File: ${fileName ?? 'Unknown'}'; // Changed from mediaFilename
      case MessageType.emoji:
        return content;
      case MessageType.iceCandidate:
        return '📞 WebRTC Ice Candidate';
      case MessageType.callAnswer:
        return '📞 Call Answer';
      case MessageType.callEnd:
        return '📞 Call Ended';
    }
  }

  /// Copy with new values
  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId, // Changed from recipientId
    String? content,
    MessageType? messageType,
    String? fileUrl, // Changed from mediaUrl
    String? fileName, // Changed from mediaFilename
    int? fileSize, // Added
    bool? edited, // Added
    List<dynamic>? reactions, // Added
    DateTime? createdAt,
    DateTime? readAt,
    String? replyToId,
    ChatUser? sender,
    ChatUser? receiver, // Changed from recipient
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId, // Changed
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl, // Changed
      fileName: fileName ?? this.fileName, // Changed
      fileSize: fileSize ?? this.fileSize, // Added
      edited: edited ?? this.edited, // Added
      reactions: reactions ?? this.reactions, // Added
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      replyToId: replyToId ?? this.replyToId,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver, // Changed
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Message(id: $id, type: $messageType, content: $content)';
}

/// Message types supported by both Chatsusa website and mobile app
enum MessageType {
  text('text'),
  image('image'),
  video('video'),
  audio('audio'),
  file('file'),
  emoji('emoji'),
  iceCandidate('ice_candidate'), // Added for WebRTC
  callAnswer('call_answer'), // Added for WebRTC
  callEnd('call_end'); // Added for WebRTC

  const MessageType(this.value);
  final String value;

  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MessageType.text,
    );
  }
}

/// Message status that matches Chatsusa website
enum MessageStatus {
  sending('sending'),
  sent('sent'),
  delivered('delivered'),
  read('read'),
  failed('failed');

  const MessageStatus(this.value);
  final String value;

  static MessageStatus fromString(String value) {
    return MessageStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => MessageStatus.sent,
    );
  }
}
