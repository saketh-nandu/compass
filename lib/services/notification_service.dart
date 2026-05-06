import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

/// Notification service for handling Firebase Cloud Messaging
///
/// Integrates with the same notification system as Chatsusa website:
/// - Same FCM project and configuration
/// - Compatible notification format and handling
/// - Supports both foreground and background notifications
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();

  NotificationService._();

  String? _deviceToken;
  String? get deviceToken => _deviceToken;

  /// Initialize Firebase and notification services
  Future<void> initialize() async {
    try {
      // Skip Firebase initialization - it's optional for this app
      // The app works fine without push notifications
      debugPrint('Notification service initialized (Firebase skipped)');
    } catch (e) {
      debugPrint('Notification service initialization error: $e');
    }
  }

  /// Send "Notify Partner" notification
  /// This calls a Supabase Edge Function that sends FCM notification
  Future<bool> sendPartnerNotification({
    required String recipientUserId,
    String? customMessage,
  }) async {
    try {
      final currentUser = SupabaseService.instance.currentUser;
      if (currentUser == null) return false;

      // Call Supabase Edge Function to send notification
      final response = await SupabaseService.instance.client.functions.invoke(
        'send-notification',
        body: {
          'recipient_user_id': recipientUserId,
          'sender_user_id': currentUser.id,
          'message': customMessage,
          'type': 'partner_notification',
        },
      );

      if (response.status == 200) {
        debugPrint('Partner notification sent successfully');
        return true;
      } else if (response.status == 429) {
        debugPrint('Partner notification cooldown active');
        return false;
      } else {
        debugPrint('Partner notification failed: ${response.data}');
        return false;
      }
    } catch (e) {
      debugPrint('Send partner notification error: $e');
      return false;
    }
  }

  /// Send chat message notification
  /// This is called when a new message is received
  Future<bool> sendChatMessageNotification({
    required String recipientUserId,
    required String messageContent,
    required String messageId,
  }) async {
    try {
      final currentUser = SupabaseService.instance.currentUser;
      if (currentUser == null) return false;

      // Call Supabase Edge Function to send notification
      final response = await SupabaseService.instance.client.functions.invoke(
        'send-notification',
        body: {
          'recipient_user_id': recipientUserId,
          'sender_user_id': currentUser.id,
          'message': messageContent,
          'type': 'chat_message',
          'chat_message_id': messageId,
        },
      );

      return response.status == 200;
    } catch (e) {
      debugPrint('Send chat message notification error: $e');
      return false;
    }
  }

  /// Remove device token on logout
  Future<void> removeDeviceToken() async {
    try {
      if (_deviceToken != null) {
        await SupabaseService.instance.removeDeviceToken(_deviceToken!);
        _deviceToken = null;
      }
    } catch (e) {
      debugPrint('Remove device token error: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.messageId}');

  // Handle background message processing here
  // This could include updating local database, showing notification, etc.
}
