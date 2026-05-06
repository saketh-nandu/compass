import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Supabase service for managing database connections and operations
///
/// This service reuses the existing Chatsusa backend infrastructure:
/// - Same database schema and tables
/// - Same relationships and constraints
/// - Compatible with existing web application
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  /// Supabase client instance
  SupabaseClient get client => Supabase.instance.client;

  /// Current user
  User? get currentUser => client.auth.currentUser;

  /// Initialize Supabase with your existing project credentials
  ///
  /// IMPORTANT: Replace these with your actual Chatsusa Supabase project credentials
  /// These should match the same project used by your web application
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      debug: kDebugMode && AppConfig.enableDebugLogging,
    );

    // Validate configuration
    if (!AppConfig.isConfigurationValid) {
      debugPrint('⚠️  Supabase configuration errors:');
      for (final error in AppConfig.configurationErrors) {
        debugPrint('   - $error');
      }
      debugPrint(
          '   Please update lib/config/app_config.dart with your actual credentials');
    }
  }

  /// Sign in with email and password
  /// Uses the same authentication system as Chatsusa website
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  /// Sign up with email and password
  /// Creates user in the same users table as Chatsusa
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      return response;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  /// Listen to authentication state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Get user profile from the users table
  /// This should match the same users table structure as Chatsusa
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response =
          await client.from('users').select().eq('id', userId).maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Get user profile error: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await client.from('users').update(updates).eq('id', userId);
    } catch (e) {
      debugPrint('Update user profile error: $e');
      rethrow;
    }
  }

  /// Store device token for push notifications
  /// This integrates with the same notification system as Chatsusa
  Future<void> storeDeviceToken({
    required String userId,
    required String deviceToken,
    required String platform,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      await client.from('device_tokens').upsert({
        'user_id': userId,
        'token': deviceToken,
        'platform': platform,
        'device_info': deviceInfo ?? {},
        'active': true,
        'last_used_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint('Device token stored successfully');
    } catch (e) {
      debugPrint('Store device token error: $e');
      rethrow;
    }
  }

  /// Update device token last used timestamp
  Future<void> updateDeviceTokenUsage(String deviceToken) async {
    try {
      await client.from('device_tokens').update({
        'last_used_at': DateTime.now().toIso8601String(),
      }).eq('token', deviceToken);
    } catch (e) {
      debugPrint('Update device token usage error: $e');
    }
  }

  /// Remove device token (on logout)
  Future<void> removeDeviceToken(String deviceToken) async {
    try {
      await client.from('device_tokens').delete().eq('token', deviceToken);
      debugPrint('Device token removed successfully');
    } catch (e) {
      debugPrint('Remove device token error: $e');
      rethrow;
    }
  }

  /// Deactivate device token (soft delete)
  Future<void> deactivateDeviceToken(String deviceToken) async {
    try {
      await client.from('device_tokens').update({
        'active': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('token', deviceToken);
    } catch (e) {
      debugPrint('Deactivate device token error: $e');
    }
  }

  /// Get user's notification preferences
  Future<Map<String, dynamic>?> getNotificationPreferences(
      String userId) async {
    try {
      final response = await client
          .from('notification_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Get notification preferences error: $e');
      return null;
    }
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      await client.from('notification_preferences').upsert({
        'user_id': userId,
        ...preferences,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Update notification preferences error: $e');
      rethrow;
    }
  }
}
