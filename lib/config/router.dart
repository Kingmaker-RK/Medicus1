import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/welcome_screen.dart';
import '../screens/translation_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/patient_profile_screen.dart';
import '../screens/doctor_profile_screen.dart';
import '../screens/profile_completion_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/email_verification_screen.dart';
import '../screens/verify_password_reset_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/appointments_screen.dart';
import '../screens/health_screen.dart';
import '../screens/reminders_screen.dart';
import '../screens/services_hub_screen.dart';
import '../screens/e_rezept_screen.dart';
import '../screens/pregnancy_tracker_screen.dart';
import '../screens/blood_donation_screen.dart';
import '../screens/dentist_screen.dart';
import '../screens/dermo_screen.dart';
import '../screens/baby_tracker_screen.dart';
import '../screens/orthopedic_screen.dart';
import '../screens/fitphysic_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // No automatic redirects to profile completion
      // Profile completion is only accessed during sign-up flow
      return null;
    },
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
        builder: (context, state) => const PatientProfileScreen(),
      ),
      GoRoute(
        path: '/doctor-profile',
        name: 'doctor-profile',
        builder: (context, state) => const DoctorProfileScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        name: 'complete-profile',
        builder: (context, state) => const ProfileCompletionScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/verify-password-reset',
        name: 'verify-password-reset',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyPasswordResetScreen(email: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final code = state.uri.queryParameters['code'] ?? '';
          return ResetPasswordScreen(email: email, code: code);
        },
      ),
      GoRoute(
        path: '/appointments',
        name: 'appointments',
        builder: (context, state) => const AppointmentsScreen(),
      ),
      GoRoute(
        path: '/health',
        name: 'health',
        builder: (context, state) => const HealthScreen(),
      ),
      GoRoute(
        path: '/reminders',
        name: 'reminders',
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: '/services',
        name: 'services',
        builder: (context, state) => const ServicesHubScreen(),
      ),
      GoRoute(
        path: '/e-rezept',
        name: 'e-rezept',
        builder: (context, state) => const ERezeptScreen(),
      ),
      GoRoute(
        path: '/pregnancy-tracker',
        name: 'pregnancy-tracker',
        builder: (context, state) => const PregnancyTrackerScreen(),
      ),
      GoRoute(
        path: '/blood-donation',
        name: 'blood-donation',
        builder: (context, state) => const BloodDonationScreen(),
      ),
      GoRoute(
        path: '/dentist',
        name: 'dentist',
        builder: (context, state) => const DentistScreen(),
      ),
      GoRoute(
        path: '/dermo',
        name: 'dermo',
        builder: (context, state) => const DermoScreen(),
      ),
      GoRoute(
        path: '/baby-tracker',
        name: 'baby-tracker',
        builder: (context, state) => const BabyTrackerScreen(),
      ),
      GoRoute(
        path: '/orthopedic',
        name: 'orthopedic',
        builder: (context, state) => const OrthopedicScreen(),
      ),
      GoRoute(
        path: '/fitphysic',
        name: 'fitphysic',
        builder: (context, state) => const FitPhysicScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
