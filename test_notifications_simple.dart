// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Simple notification system test without linting warnings
/// Run with: dart test_notifications_simple.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🧪 Testing Hushnav Notification System');
  print('=====================================');

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://mihtycztbooxfxliqvmi.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1paHR5Y3p0Ym9veGZ4bGlxdm1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEwMjMyMzksImV4cCI6MjA4NjU5OTIzOX0.t7plegjAYRt2JrK-kWb9i_sGXvUCyBwb13zluE_GSbE',
    );

    final supabase = Supabase.instance.client;
    print('✅ Supabase initialized successfully');

    // Test database connection
    print('\n📊 Testing Database Connection...');
    try {
      final response = await supabase.from('users').select('count').count();
      print('✅ Database connected - Users: ${response.count}');
    } catch (e) {
      print('❌ Database connection failed: $e');
      print('   Make sure your Supabase project is accessible');
    }

    // Test notification tables
    print('\n📋 Testing Notification Tables...');
    final tables = [
      'device_tokens',
      'notification_logs',
      'notification_preferences'
    ];

    for (final table in tables) {
      try {
        final response = await supabase.from(table).select('count').count();
        print('✅ $table table exists - Records: ${response.count}');
      } catch (e) {
        print('❌ $table table missing or inaccessible');
        print('   Run database_setup_notifications.sql in Supabase');
      }
    }

    // Test Edge Function
    print('\n🔧 Testing Edge Function...');
    try {
      final response =
          await supabase.functions.invoke('send-notification', body: {});

      if (response.status == 400) {
        print('✅ Edge Function deployed and responding');
      } else if (response.status == 404) {
        print('❌ Edge Function not found');
        print('   Deploy with: supabase functions deploy send-notification');
      } else {
        print('⚠️  Edge Function status: ${response.status}');
      }
    } catch (e) {
      print('❌ Edge Function test failed: $e');
    }

    // Test Firebase files
    print('\n🔥 Testing Firebase Configuration...');

    final googleServices = File('android/app/google-services.json');
    if (await googleServices.exists()) {
      print('✅ google-services.json exists');
    } else {
      print('❌ google-services.json missing');
    }

    final firebaseAdmin =
        File('compass-d098d-firebase-adminsdk-fbsvc-f5dbec20a5.json');
    if (await firebaseAdmin.exists()) {
      print('✅ Firebase Admin SDK file exists');
    } else {
      print('❌ Firebase Admin SDK file missing');
    }

    // Summary
    print('\n🎉 Test Complete!');
    print('================');
    print('Next steps:');
    print('1. Fix any ❌ issues above');
    print('2. Run: flutter run -d chrome');
    print('3. Test notifications in the app');
  } catch (e) {
    print('❌ Test failed with error: $e');
  }

  exit(0);
}
