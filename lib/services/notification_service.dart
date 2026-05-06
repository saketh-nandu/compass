import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  late FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _firebaseInitialized = false;
  String? _deviceToken;
  String? get deviceToken => _deviceToken;

  /// Initialize Firebase and notification services
  Future<void> initialize() async {
    try {
      // Initialize Firebase (optional - app works without it)
      try {
        await Firebase.initializeApp();
        _messaging = FirebaseMessaging.instance;
        _firebaseInitialized = true;
        debugPrint('Firebase initialized successfully');
      } catch (e) {
        debugPrint('Firebase initialization skipped: $e');
        debugPrint('App will work without push notifications');
        _firebaseInitialized = false;
        return; // Exit early if Firebase fails
      }

      // Request notification permissions
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get and store device token
      await _getDeviceToken();

      // Set up message handlers
      _setupMessageHandlers();

      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Notification service initialization error: $e');
      // Don't crash the app if notifications fail
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (!_firebaseInitialized) return;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
          'Notification permission status: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Request permissions error: $e');
    }
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Get device token and store in Supabase
  Future<void> _getDeviceToken() async {
    try {
      if (!_firebaseInitialized) {
        debugPrint('Firebase not initialized, skipping device token');
        return;
      }

      if (kIsWeb) {
        debugPrint('Device token not supported on web platform');
        return;
      }

      _deviceToken = await _messaging.getToken();
      debugPrint('FCM Token: $_deviceToken');

      if (_deviceToken != null) {
        await _storeDeviceToken();
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _deviceToken = newToken;
        _storeDeviceToken();
      });
    } catch (e) {
      debugPrint('Get device token error (Firebase may not be configured): $e');
      // Continue without device token
    }
  }

  /// Store device token in Supabase (same table as Chatsusa)
  Future<void> _storeDeviceToken() async {
    try {
      if (kIsWeb) {
        debugPrint('Device token storage not supported on web platform');
        return;
      }

      final currentUser = SupabaseService.instance.currentUser;
      if (currentUser == null || _deviceToken == null) return;

      await SupabaseService.instance.storeDeviceToken(
        userId: currentUser.id,
        deviceToken: _deviceToken!,
        platform: Platform.isIOS ? 'ios' : 'android',
      );
    } catch (e) {
      debugPrint('Store device token error: $e');
    }
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers() {
    if (!_firebaseInitialized) {
      debugPrint('Firebase not initialized, skipping message handlers');
      return;
    }

    try {
      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle messages when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle messages when app is opened from terminated state
      _handleInitialMessage();
    } catch (e) {
      debugPrint('Setup message handlers error: $e');
    }
  }

  /// Handle initial message when app is opened from terminated state
  Future<void> _handleInitialMessage() async {
    if (!_firebaseInitialized) return;

    try {
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
    } catch (e) {
      debugPrint('Handle initial message error: $e');
    }
  }

  /// Handle foreground messages (show local notification)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message: ${message.messageId}');

    // Show local notification
    await _showLocalNotification(message);
  }

  /// Handle messages when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');

    // Navigate to appropriate screen based on message data
    final data = message.data;
    if (data['type'] == 'chat_message') {
      // Navigate to chat screen
      _navigateToChat(data);
    } else if (data['type'] == 'compass_notification') {
      // This is a "Notify Partner" compass-style notification
      // Just open the unlock screen to access chat
      _navigateToUnlock();
    }
  }

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');

    // Parse payload and navigate accordingly
    if (response.payload != null) {
      // Navigate to unlock screen to access chat
      _navigateToUnlock();
    }
  }

  /// Navigate to chat (requires router context)
  void _navigateToChat(Map<String, dynamic> data) {
    // This would need to be called with proper context
    // For now, just navigate to unlock screen
    _navigateToUnlock();
  }

  /// Navigate to unlock screen
  void _navigateToUnlock() {
    // This is a simplified approach - in a real app you'd need proper navigation context
    debugPrint('Should navigate to unlock screen');
  }

  /// Send "Notify Partner" notification
  /// This calls a Supabase Edge Function that sends FCM notification
  Future<bool> sendPartnerNotification({
    required String recipientUserId,
    String? customMessage,
  }) async {
    try {
      if (!_firebaseInitialized) {
        debugPrint('Firebase not initialized, cannot send notifications');
        return false;
      }

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
      if (!_firebaseInitialized || _deviceToken == null) return;

      await SupabaseService.instance.removeDeviceToken(_deviceToken!);
      _deviceToken = null;
    } catch (e) {
      debugPrint('Remove device token error: $e');
    }
  }

  /// Subscribe to topic (for broadcast notifications)
  Future<void> subscribeToTopic(String topic) async {
    try {
      if (!_firebaseInitialized) {
        debugPrint('Firebase not initialized, cannot subscribe to topics');
        return;
      }

      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Subscribe to topic error: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (!_firebaseInitialized) {
        debugPrint('Firebase not initialized, cannot unsubscribe from topics');
        return;
      }

      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Unsubscribe from topic error: $e');
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
