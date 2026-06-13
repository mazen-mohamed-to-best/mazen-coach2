import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:to_best/models/user_model.dart';
import 'package:to_best/features/auth/presentation/screens/login_screen.dart';
import 'package:to_best/features/auth/presentation/screens/register_screen.dart';
import 'package:to_best/features/auth/presentation/screens/pending_screen.dart';
import 'package:to_best/features/auth/presentation/screens/setup_screen.dart';
import 'package:to_best/features/home/presentation/screens/home_screen.dart';
import 'package:to_best/features/workout/presentation/screens/workout_screen.dart';
import 'package:to_best/features/workout/presentation/screens/workout_session_screen.dart';
import 'package:to_best/features/nutrition/presentation/screens/nutrition_screen.dart';
import 'package:to_best/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:to_best/features/progress/presentation/screens/progress_screen.dart';
import 'package:to_best/features/chat/presentation/screens/chat_screen.dart';
import 'package:to_best/features/chat/presentation/screens/chat_room_screen.dart';
import 'package:to_best/features/settings/presentation/screens/settings_screen.dart';
import 'package:to_best/features/admin/presentation/screens/admin_screen.dart';
import 'package:to_best/features/profile/presentation/screens/profile_screen.dart';
import 'package:to_best/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:to_best/features/home/presentation/screens/main_shell.dart';

GoRouter createRouter(UserModel? user) {
  return GoRouter(
    initialLocation: user == null ? '/login' : '/',
    redirect: (context, state) {
      final isLoggedIn = user != null;
      final isLoginRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/setup');
      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/';
      if (isLoggedIn && user.isPending) {
        if (state.matchedLocation != '/pending') return '/pending';
      }
      if (isLoggedIn && !user.isPending && state.matchedLocation == '/pending') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/setup', builder: (_, __) => const SetupScreen()),
      GoRoute(path: '/pending', builder: (_, __) => const PendingScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/workout', builder: (_, __) => const WorkoutScreen()),
          GoRoute(
            path: '/workout/session',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return WorkoutSessionScreen(
                sessionName: extra?['sessionName'] ?? '',
                programId: extra?['programId'] ?? '',
              );
            },
          ),
          GoRoute(path: '/nutrition', builder: (_, __) => const NutritionScreen()),
          GoRoute(path: '/attendance', builder: (_, __) => const AttendanceScreen()),
          GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen()),
          GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
          GoRoute(
            path: '/chat/room',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ChatRoomScreen(
                roomId: extra?['roomId'] ?? 'general',
                roomTitle: extra?['title'] ?? '',
              );
            },
          ),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
          GoRoute(path: '/admin', builder: (_, __) => const AdminScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/subscription', builder: (_, __) => const SubscriptionScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('صفحة غير موجودة: ${state.error}')),
    ),
  );
}
