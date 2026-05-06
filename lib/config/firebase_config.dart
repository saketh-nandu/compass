/// Firebase configuration for notifications
///
/// This contains your Firebase project settings for Cloud Messaging
class FirebaseConfig {
  // Your Firebase project configuration
  static const String projectId = 'compass-d098d';
  static const String projectNumber = '764176495852';
  static const String senderId = '764176495852';
  static const String apiKey = 'AIzaSyCkyU0nVgmBkBi_lUdNCMuf8SUj_UEYTVc';

  // FCM Configuration
  static const String fcmServerKey =
      'YOUR_SERVER_KEY_HERE'; // Get this from Firebase Console
  static const String vapidKey =
      'YOUR_VAPID_KEY_HERE'; // Get this from Web Push certificates

  // Notification settings
  static const String defaultChannelId = 'chat_messages';
  static const String defaultChannelName = 'Chat Messages';
  static const String compassNotificationTitle = 'Compass Update';
  static const String compassNotificationBody = 'Heading NW (312°)';
}
