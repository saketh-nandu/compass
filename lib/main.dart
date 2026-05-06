import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';
import 'theme.dart' as app_theme;
import 'nav.dart';

/// Main entry point for the application
///
/// This sets up:
/// - Environment variables from .env file
/// - Supabase backend integration (same as Chatsusa website)
/// - Firebase Cloud Messaging for notifications
/// - Provider state management
/// - go_router navigation
/// - Material 3 theming with light/dark modes
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables from .env file
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  try {
    // Initialize Supabase (same project as Chatsusa website)
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
  }

  try {
    // Initialize Firebase and notifications
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('Notification service initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider wraps the app to provide state to all widgets
    return MultiProvider(
      providers: [
        // Add providers here as needed
        // Example:
        // ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp.router(
        title: 'Compass',
        debugShowCheckedModeBanner: false,

        // Theme configuration
        theme: app_theme.AppTheme.lightTheme,
        darkTheme: app_theme.AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // Use context.go() or context.push() to navigate to the routes.
        routerConfig: AppRouter.router,
      ),
    );
  }
}
