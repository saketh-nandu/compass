import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration
///
/// IMPORTANT: Update these values with your actual Chatsusa project credentials
/// before building for production.
class AppConfig {
  // ============================================================================
  // SUPABASE CONFIGURATION (MUST MATCH CHATSUSA WEBSITE)
  // ============================================================================

  /// Supabase project URL
  /// Loaded from .env file at runtime
  static String get supabaseUrl {
    return dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co';
  }

  /// Supabase anon key
  /// Loaded from .env file at runtime
  static String get supabaseAnonKey {
    return dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-anon-key-here';
  }

  // ============================================================================
  // YOUTUBE API CONFIGURATION
  // ============================================================================

  /// YouTube Data API v3 key for fetching shorts
  /// Loaded from .env file at runtime
  static String get youtubeApiKey {
    return dotenv.env['YOUTUBE_API_KEY'] ?? 'your-youtube-api-key-here';
  }

  /// YouTube API base URL
  static const String youtubeApiBaseUrl =
      'https://www.googleapis.com/youtube/v3';

  // ============================================================================
  // STORAGE BUCKET NAMES (MUST MATCH CHATSUSA WEBSITE)
  // ============================================================================

  /// Chat media storage bucket (images, videos, audio, files)
  static const String chatMediaBucket = 'chat-media';

  /// User avatars storage bucket
  static const String avatarsBucket = 'avatars';

  /// Temporary uploads bucket
  static const String tempUploadsBucket = 'temp-uploads';

  // ============================================================================
  // TILT DETECTION CONFIGURATION
  // ============================================================================

  /// Target tilt angle in degrees (127° ± tolerance)
  static const double targetTiltAngle = 127.0;

  /// Tilt tolerance in degrees (±3°)
  static const double tiltTolerance = 3.0;

  /// Minimum tilt angle (124°)
  static double get minTiltAngle => targetTiltAngle - tiltTolerance;

  /// Maximum tilt angle (130°)
  static double get maxTiltAngle => targetTiltAngle + tiltTolerance;

  /// Gyroscope threshold for "low motion" detection
  static const double gyroThreshold = 0.5;

  /// Duration to hold tilt position (3 seconds)
  static const Duration tiltHoldDuration = Duration(seconds: 3);

  /// Cooldown period after unlock attempt (10 seconds)
  static const Duration unlockCooldown = Duration(seconds: 10);

  // ============================================================================
  // NOTIFICATION CONFIGURATION
  // ============================================================================

  /// Partner notification cooldown (5 minutes)
  static const Duration partnerNotificationCooldown = Duration(minutes: 5);

  /// Default compass notification message
  static const String defaultCompassMessage = 'Heading NW (312°)';

  /// Notification channel ID for chat messages
  static const String chatNotificationChannelId = 'chat_messages';

  /// Notification channel name
  static const String chatNotificationChannelName = 'Chat Messages';

  // ============================================================================
  // SECURITY CONFIGURATION
  // ============================================================================

  /// Auto-lock timeout in minutes (default 5 minutes)
  static const int defaultAutoLockTimeout = 5;

  /// PIN length (4 digits)
  static const int pinLength = 4;

  /// Maximum PIN attempts before lockout
  static const int maxPinAttempts = 5;

  /// Lockout duration after max attempts (30 minutes)
  static const Duration pinLockoutDuration = Duration(minutes: 30);

  // ============================================================================
  // APP METADATA
  // ============================================================================

  /// App name (appears as utility app)
  static const String appName = 'Compass & Level';

  /// App version
  static const String appVersion = '1.0.0';

  /// App package name
  static const String packageName = 'com.example.hushnav';

  // ============================================================================
  // DEVELOPMENT/DEBUG CONFIGURATION
  // ============================================================================

  /// Enable debug logging
  static const bool enableDebugLogging = true;

  /// Enable demo shortcuts (DISABLE IN PRODUCTION)
  static const bool enableDemoShortcuts = true;

  /// Mock data for testing (DISABLE IN PRODUCTION)
  static const bool useMockData = false;

  // ============================================================================
  // VALIDATION METHODS
  // ============================================================================

  /// Validate that all required configuration is set
  static bool get isConfigurationValid {
    return supabaseUrl != 'https://your-project-ref.supabase.co' &&
        supabaseAnonKey != 'your-anon-key-here' &&
        supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty;
  }

  /// Get configuration validation errors
  static List<String> get configurationErrors {
    final errors = <String>[];

    if (supabaseUrl == 'https://your-project-ref.supabase.co') {
      errors.add('Supabase URL not configured');
    }

    if (supabaseAnonKey == 'your-anon-key-here') {
      errors.add('Supabase anon key not configured');
    }

    if (supabaseUrl.isEmpty) {
      errors.add('Supabase URL is empty');
    }

    if (supabaseAnonKey.isEmpty) {
      errors.add('Supabase anon key is empty');
    }

    return errors;
  }

  /// Check if tilt angle is within valid range
  static bool isTiltAngleValid(double angle) {
    return angle >= minTiltAngle && angle <= maxTiltAngle;
  }

  /// Check if gyroscope reading indicates low motion
  static bool isLowMotion(double gyroMagnitude) {
    return gyroMagnitude < gyroThreshold;
  }
}
