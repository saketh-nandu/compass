import 'package:go_router/go_router.dart';
import 'screens/home_page.dart';
import 'screens/unlock_screen.dart';
import 'screens/chat_screen.dart';
import 'sensors/tilt_detector.dart';

/// GoRouter configuration for app navigation
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => NoTransitionPage(
          child: TiltDetector(
            onUnlockTriggered: () {
              // On trigger, push the unlock screen
              context.push(AppRoutes.unlock);
            },
            child: const HomePage(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.unlock,
        name: 'unlock',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: UnlockScreen()),
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ChatScreen()),
      ),
    ],
  );
}

/// Route path constants
class AppRoutes {
  static const String home = '/';
  static const String unlock = '/unlock';
  static const String chat = '/chat';
}
