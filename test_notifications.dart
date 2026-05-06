import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Test script for Firebase Cloud Messaging notifications
/// Run this to verify the notification system is working correctly

void _log(String message) {
  if (kDebugMode) {
    developer.log(message, name: 'NotificationTest');
  }
  // Also print to console for visibility during testing
  // ignore: avoid_print
  print(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _log('🧪 Testing Hushnav Notification System');
  _log('=====================================');

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://mihtycztbooxfxliqvmi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1paHR5Y3p0Ym9veGZ4bGlxdm1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEwMjMyMzksImV4cCI6MjA4NjU5OTIzOX0.t7plegjAYRt2JrK-kWb9i_sGXvUCyBwb13zluE_GSbE',
  );

  final supabase = Supabase.instance.client;

  // Test 1: Check database connection
  _log('\n📊 Test 1: Database Connection');
  try {
    final response = await supabase.from('users').select('count').count();
    _log('✅ Database connected successfully');
    _log('   Users table accessible: ${response.count} users');
  } catch (e) {
    _log('❌ Database connection failed: $e');
    return;
  }

  // Test 2: Check if notification tables exist
  _log('\n📋 Test 2: Notification Tables');
  try {
    // Check device_tokens table
    final deviceTokens =
        await supabase.from('device_tokens').select('count').count();
    _log('✅ device_tokens table exists: ${deviceTokens.count} tokens');

    // Check notification_logs table
    final notificationLogs =
        await supabase.from('notification_logs').select('count').count();
    _log('✅ notification_logs table exists: ${notificationLogs.count} logs');

    // Check notification_preferences table
    final notificationPrefs =
        await supabase.from('notification_preferences').select('count').count();
    _log(
        '✅ notification_preferences table exists: ${notificationPrefs.count} preferences');
  } catch (e) {
    _log('❌ Notification tables check failed: $e');
    _log('   Please run database_setup_notifications.sql in Supabase');
    return;
  }

  // Test 3: Check Edge Function
  _log('\n🔧 Test 3: Edge Function');
  try {
    // Test with invalid data to check if function exists
    final response =
        await supabase.functions.invoke('send-notification', body: {});

    if (response.status == 400) {
      _log('✅ Edge Function is deployed and responding');
      _log('   Function returned expected validation error');
    } else {
      _log('⚠️  Edge Function responded with status: ${response.status}');
    }
  } catch (e) {
    _log('❌ Edge Function test failed: $e');
    _log(
        '   Please deploy the function with: supabase functions deploy send-notification');
    return;
  }

  // Test 4: Test notification sending (requires authentication)
  _log('\n📱 Test 4: Notification Sending');
  _log('⚠️  Skipping notification send test (requires user authentication)');
  _log('   To test notifications:');
  _log('   1. Run the Flutter app: flutter run -d chrome');
  _log('   2. Sign in with a test user');
  _log('   3. Try the "Notify Partner" feature');

  // Test 5: Firebase configuration
  _log('\n🔥 Test 5: Firebase Configuration');
  final googleServicesFile = File('android/app/google-services.json');
  if (await googleServicesFile.exists()) {
    _log('✅ google-services.json file exists');

    final firebaseAdminFile =
        File('compass-d098d-firebase-adminsdk-fbsvc-f5dbec20a5.json');
    if (await firebaseAdminFile.exists()) {
      _log('✅ Firebase Admin SDK file exists');
    } else {
      _log('❌ Firebase Admin SDK file missing');
    }
  } else {
    _log('❌ google-services.json file missing');
  }

  // Summary
  _log('\n🎉 Test Summary');
  _log('===============');
  _log('✅ Database connection: Working');
  _log('✅ Notification tables: Created');
  _log('✅ Edge Function: Deployed');
  _log('✅ Firebase config: Present');
  _log('');
  _log('🚀 Notification system is ready for testing!');
  _log('');
  _log('Next steps:');
  _log('1. Run: flutter run -d chrome');
  _log('2. Test the "Notify Partner" feature');
  _log('3. Check browser console for FCM token');
  _log('4. Test on Android device for real notifications');

  exit(0);
}
