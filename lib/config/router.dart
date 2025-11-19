import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
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
        name: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.translation}',
        name: AppRoutes.translation,
        builder: (context, state) => const TranslationScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.settings}',
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.profile}',
        name: AppRoutes.profile,
        builder: (context, state) => const PatientProfileScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.doctorProfile}',
        name: AppRoutes.doctorProfile,
        builder: (context, state) => const DoctorProfileScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.completeProfile}',
        name: AppRoutes.completeProfile,
        builder: (context, state) => const ProfileCompletionScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.forgotPassword}',
        name: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.verifyEmail}',
        name: AppRoutes.verifyEmail,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/${AppRoutes.verifyPasswordReset}',
        name: AppRoutes.verifyPasswordReset,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyPasswordResetScreen(email: email);
        },
      ),
      GoRoute(
        path: '/${AppRoutes.resetPassword}',
        name: AppRoutes.resetPassword,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final code = state.uri.queryParameters['code'] ?? '';
          return ResetPasswordScreen(email: email, code: code);
        },
      ),
      GoRoute(
        path: '/${AppRoutes.appointments}',
        name: AppRoutes.appointments,
        builder: (context, state) => const AppointmentsScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.health}',
        name: AppRoutes.health,
        builder: (context, state) => const HealthScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.reminders}',
        name: AppRoutes.reminders,
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.services}',
        name: AppRoutes.services,
        builder: (context, state) => const ServicesHubScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.eRezept}',
        name: AppRoutes.eRezept,
        builder: (context, state) => const ERezeptScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.pregnancyTracker}',
        name: AppRoutes.pregnancyTracker,
        builder: (context, state) => const PregnancyTrackerScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.bloodDonation}',
        name: AppRoutes.bloodDonation,
        builder: (context, state) => const BloodDonationScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.dentist}',
        name: AppRoutes.dentist,
        builder: (context, state) => const DentistScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.dermo}',
        name: AppRoutes.dermo,
        builder: (context, state) => const DermoScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.babyTracker}',
        name: AppRoutes.babyTracker,
        builder: (context, state) => const BabyTrackerScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.orthopedic}',
        name: AppRoutes.orthopedic,
        builder: (context, state) => const OrthopedicScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.fitphysic}',
        name: AppRoutes.fitphysic,
        builder: (context, state) => const FitPhysicScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
