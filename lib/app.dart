import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/nutrition_log_screen.dart';
import 'presentation/screens/workout_screen.dart';
import 'presentation/screens/progress_screen.dart';
import 'presentation/screens/profile_screen.dart';

// pagrindine aplikacija
class FitnessApp extends ConsumerWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // navigacija
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/log', builder: (_, __) => const NutritionLogScreen()),
      GoRoute(path: '/workout', builder: (_, __) => const WorkoutScreen()),
      GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ]);

    return MaterialApp.router(
      title: 'FitBalance',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}