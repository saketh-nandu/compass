import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../models/chat_user.dart';
import 'supabase_service.dart';

/// Chat service that reuses the exact same backend logic as Chatsusa website
///
/// This service ensures complete compatibility with the existing web application:
/// - Same message structure and format
/// - Same database tables and relationships
/// - Same realtime synchronization
/// - Messages sent from web appear instantly in app and vice versa
class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ??= ChatService._();

  ChatService._();

  final SupabaseClient _client = SupabaseService.instance.client;

  /// Send a text message
  /// Uses the same message structure as Chatsusa website
  Future<Message?> sendTextMessage({
    required String content,
    required String receiverId, // Changed from recipientId to match database
    String? replyToId,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final messageData = {
        'sender_id': currentUser.id,
        'receiver_id': receiverId, // Changed from recipient_id
        'content': content,
        'type': 'text', // Changed from message_type
        'created_at': DateTime.now().toIso8601String(),
        'reply_to_id': replyToId,
        'edited': false,
        'reactions': [],
      };

      final response =
          await _client.from('messages').insert(messageData).select().single();

      return Message.fromJson(response);
    } catch (e) {
      debugPrint('Send text message error: $e');
      return null;
    }
  }

  /// Send a media message (image, video, audio, file)
  /// Reuses the same Supabase Storage buckets as Chatsusa
  Future<Message?> sendMediaMessage({
    required String filePath,
    required String fileName,
    required String messageType, // 'image', 'video', 'audio', 'file'
    required String receiverId, // Changed from recipientId
    String? caption,
    String? replyToId,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Upload file to the same storage bucket as Chatsusa
      final fileExt = fileName.split('.').last;
      final storagePath =
          '${currentUser.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _client.storage
          .from('chat-files') // Same bucket as Chatsusa (from CSV data)
          .upload(storagePath, File(filePath));

      // Get public URL
      final mediaUrl =
          _client.storage.from('chat-files').getPublicUrl(storagePath);

      // Get file size
      final file = File(filePath);
      final fileSize = await file.length();

      // Create message with media
      final messageData = {
        'sender_id': currentUser.id,
        'receiver_id': receiverId, // Changed from recipient_id
        'content': caption ?? '',
        'type': messageType, // Changed from message_type
        'file_url': mediaUrl, // Changed from media_url
        'file_name': fileName, // Changed from media_filename
        'file_size': fileSize, // Added
        'created_at': DateTime.now().toIso8601String(),
        'reply_to_id': replyToId,
        'edited': false,
        'reactions': [],
      };

      final response =
          await _client.from('messages').insert(messageData).select().single();

      return Message.fromJson(response);
    } catch (e) {
      debugPrint('Send media message error: $e');
      return null;
    }
  }

  /// Get messages for a conversation
  /// Uses the same query structure as Chatsusa website
  Future<List<Message>> getMessages({
    required String otherUserId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return [];

      final response = await _client
          .from('messages')
          .select('''
            *,
            sender:sender_id(id, username, nickname, avatar_url),
            receiver:receiver_id(id, username, nickname, avatar_url)
          ''')
          .or('and(sender_id.eq.${currentUser.id},receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.${currentUser.id})')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Get messages error: $e');
      return [];
    }
  }

  /// Listen to new messages in real-time
  /// Uses the same realtime subscriptions as Chatsusa website
  Stream<Message> listenToMessages({required String otherUserId}) {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    // Create a stream that listens to messages between current user and other user
    return _client
        .from('messages')
        .stream(primaryKey: ['id']).asyncMap((data) async {
      // Filter messages for this conversation
      final filteredData = data.where((json) {
        final senderId = json['sender_id'] as String;
        final receiverId =
            json['receiver_id'] as String; // Changed from recipient_id
        return (senderId == currentUser.id && receiverId == otherUserId) ||
            (senderId == otherUserId && receiverId == currentUser.id);
      }).toList();

      return filteredData.map((json) => Message.fromJson(json)).toList();
    }).expand((messages) => messages);
  }

  /// Mark message as read
  /// Updates the same read status as Chatsusa website
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _client.from('messages').update(
          {'read_at': DateTime.now().toIso8601String()}).eq('id', messageId);
    } catch (e) {
      debugPrint('Mark message as read error: $e');
    }
  }

  /// Delete message
  /// Uses the same soft delete approach as Chatsusa if applicable
  Future<void> deleteMessage(String messageId) async {
    try {
      await _client.from('messages').update(
          {'deleted_at': DateTime.now().toIso8601String()}).eq('id', messageId);
    } catch (e) {
      debugPrint('Delete message error: $e');
    }
  }

  /// Get chat users/contacts
  /// Retrieves users from the same users table as Chatsusa
  Future<List<ChatUser>> getChatUsers() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return [];

      // Get users who have exchanged messages with current user
      final response = await _client
          .from('users')
          .select('id, username, nickname, avatar_url, partner_id, created_at')
          .neq('id', currentUser.id);

      return response.map((json) => ChatUser.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Get chat users error: $e');
      return [];
    }
  }

  /// Update user online status
  /// Note: The actual users table doesn't have status/last_seen fields
  /// This is a placeholder for future implementation
  Future<void> updateUserStatus(String status) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return;

      // The actual users table only has: id, username, nickname, avatar_url, partner_id, created_at
      // Status tracking would need to be implemented separately if needed
      debugPrint('User status update requested: $status');
    } catch (e) {
      debugPrint('Update user status error: $e');
    }
  }

  /// Send typing indicator
  /// Note: typing_indicators table may not exist in current database
  /// This is a placeholder for future implementation
  Future<void> sendTypingIndicator({
    required String receiverId, // Changed from recipientId
    required bool isTyping,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return;

      // Typing indicators would need to be implemented if the table exists
      debugPrint('Typing indicator: $isTyping for user $receiverId');
    } catch (e) {
      debugPrint('Send typing indicator error: $e');
    }
  }

  /// Listen to typing indicators
  /// Note: typing_indicators table may not exist in current database
  Stream<Map<String, dynamic>> listenToTypingIndicators(
      {required String otherUserId}) {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    // Return empty stream for now since typing_indicators table may not exist
    return const Stream.empty();
  }
}
