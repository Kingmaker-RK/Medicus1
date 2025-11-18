import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/welcome_screen.dart';
import '../screens/translation_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/doctor_profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/translation',
        name: 'translation',
        builder: (context, state) => const TranslationScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: '/doctor-profile',
        name: 'doctor-profile',
        builder: (context, state) => const DoctorProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
