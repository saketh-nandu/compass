import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_user.dart';
import 'supabase_service.dart';
import 'notification_service.dart';

/// Authentication service that integrates with Chatsusa backend
///
/// Provides secure authentication using the same Supabase auth system:
/// - Compatible with existing Chatsusa user accounts
/// - Secure PIN storage for app-level security
/// - Biometric authentication support
/// - Auto-lock functionality
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SupabaseService _supabaseService = SupabaseService.instance;

  // Storage keys
  static const String _pinKey = 'hushnav_pin';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _autoLockTimeoutKey = 'auto_lock_timeout';
  static const String _lastActiveKey = 'last_active_time';

  /// Current authenticated user
  User? get currentUser => _supabaseService.currentUser;

  /// Check if user is authenticated with Supabase
  bool get isAuthenticated => currentUser != null;

  /// Authentication state stream
  Stream<AuthState> get authStateChanges => _supabaseService.authStateChanges;

  /// Sign in with email and password (Chatsusa account)
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Initialize notification service for this user
        await NotificationService.instance.initialize();

        return AuthResult.success(response.user!);
      } else {
        return AuthResult.failure('Sign in failed');
      }
    } catch (e) {
      debugPrint('Sign in error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _supabaseService.signUpWithEmail(
        email: email,
        password: password,
        metadata: displayName != null ? {'display_name': displayName} : null,
      );

      if (response.user != null) {
        return AuthResult.success(response.user!);
      } else {
        return AuthResult.failure('Sign up failed');
      }
    } catch (e) {
      debugPrint('Sign up error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// Sign out from Supabase
  Future<void> signOut() async {
    try {
      // Remove device token
      await NotificationService.instance.removeDeviceToken();

      // Sign out from Supabase
      await _supabaseService.signOut();

      // Clear PIN and biometric settings (optional - user choice)
      // await clearAppSecurity();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  /// Get current user profile
  Future<ChatUser?> getCurrentUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final profile = await _supabaseService.getUserProfile(user.id);
      if (profile != null) {
        return ChatUser.fromJson(profile);
      }
      return null;
    } catch (e) {
      debugPrint('Get current user profile error: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (metadata != null) updates['metadata'] = metadata;

      await _supabaseService.updateUserProfile(
        userId: user.id,
        updates: updates,
      );

      return true;
    } catch (e) {
      debugPrint('Update user profile error: $e');
      return false;
    }
  }

  // ============================================================================
  // APP-LEVEL SECURITY (PIN, BIOMETRIC, AUTO-LOCK)
  // ============================================================================

  /// Set up PIN for app-level security
  Future<bool> setupPin(String pin) async {
    try {
      await _secureStorage.write(key: _pinKey, value: pin);
      return true;
    } catch (e) {
      debugPrint('Setup PIN error: $e');
      return false;
    }
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await _secureStorage.read(key: _pinKey);
      return storedPin == pin;
    } catch (e) {
      debugPrint('Verify PIN error: $e');
      return false;
    }
  }

  /// Check if PIN is set up
  Future<bool> isPinSetup() async {
    try {
      final pin = await _secureStorage.read(key: _pinKey);
      return pin != null && pin.isNotEmpty;
    } catch (e) {
      debugPrint('Check PIN setup error: $e');
      return false;
    }
  }

  /// Clear PIN
  Future<void> clearPin() async {
    try {
      await _secureStorage.delete(key: _pinKey);
    } catch (e) {
      debugPrint('Clear PIN error: $e');
    }
  }

  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
    } catch (e) {
      debugPrint('Set biometric enabled error: $e');
    }
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      debugPrint('Check biometric enabled error: $e');
      return false;
    }
  }

  /// Set auto-lock timeout (in minutes)
  Future<void> setAutoLockTimeout(int minutes) async {
    try {
      await _secureStorage.write(
        key: _autoLockTimeoutKey,
        value: minutes.toString(),
      );
    } catch (e) {
      debugPrint('Set auto-lock timeout error: $e');
    }
  }

  /// Get auto-lock timeout (in minutes)
  Future<int> getAutoLockTimeout() async {
    try {
      final timeout = await _secureStorage.read(key: _autoLockTimeoutKey);
      return int.tryParse(timeout ?? '5') ?? 5; // Default 5 minutes
    } catch (e) {
      debugPrint('Get auto-lock timeout error: $e');
      return 5;
    }
  }

  /// Update last active time
  Future<void> updateLastActiveTime() async {
    try {
      await _secureStorage.write(
        key: _lastActiveKey,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      debugPrint('Update last active time error: $e');
    }
  }

  /// Check if app should be locked based on timeout
  Future<bool> shouldAutoLock() async {
    try {
      final lastActiveStr = await _secureStorage.read(key: _lastActiveKey);
      if (lastActiveStr == null) return true;

      final lastActive = DateTime.fromMillisecondsSinceEpoch(
        int.parse(lastActiveStr),
      );
      final timeout = await getAutoLockTimeout();
      final now = DateTime.now();

      return now.difference(lastActive).inMinutes >= timeout;
    } catch (e) {
      debugPrint('Check should auto-lock error: $e');
      return true;
    }
  }

  /// Clear all app security settings
  Future<void> clearAppSecurity() async {
    try {
      await _secureStorage.delete(key: _pinKey);
      await _secureStorage.delete(key: _biometricEnabledKey);
      await _secureStorage.delete(key: _autoLockTimeoutKey);
      await _secureStorage.delete(key: _lastActiveKey);
    } catch (e) {
      debugPrint('Clear app security error: $e');
    }
  }
}

/// Authentication result wrapper
class AuthResult {
  final bool isSuccess;
  final String? error;
  final User? user;

  AuthResult.success(this.user)
      : isSuccess = true,
        error = null;
  AuthResult.failure(this.error)
      : isSuccess = false,
        user = null;
}
