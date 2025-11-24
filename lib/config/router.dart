import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
import '../screens/welcome_screen.dart';
import '../screens/translation_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/patient_profile_screen.dart';
import '../screens/doctor_profile_screen.dart';
import '../screens/doctor_home_screen.dart';
import '../screens/report_generation_screen.dart';
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
import '../screens/physiotherapy_screen.dart';
import '../screens/chiropractic_screen.dart';
import '../screens/ent_screen.dart';
import '../screens/eye_care_screen.dart';
import '../screens/addiction_recovery_screen.dart';
import '../screens/hiv_prevention_screen.dart';
import '../screens/hiv_clinics_screen.dart';
import '../screens/hiv_prevention_programs_screen.dart';
import '../screens/hiv_support_organizations_screen.dart';
import '../screens/hiv_history_screen.dart';
import '../screens/pulmonology_screen.dart';
import '../screens/podiatry_screen.dart';
import '../screens/fertility/fertility_home_screen.dart';
import '../screens/fertility/fertility_tracking_screen.dart';
import '../screens/fertility/pregnancy_planning_screen.dart';
import '../screens/fertility/medical_data_screen.dart';
import '../screens/fertility/pregnancy_tracking_screen.dart';
import '../screens/fertility/newborn_child_care_screen.dart';
import '../screens/fertility/mothers_health_screen.dart';
import '../screens/legal_policy_screen.dart';

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
        path: '/${AppRoutes.privacyPolicy}',
        name: AppRoutes.privacyPolicy,
        builder: (context, state) => const LegalPolicyScreen(),
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
        path: '/${AppRoutes.doctorHome}',
        name: AppRoutes.doctorHome,
        builder: (context, state) => const DoctorHomeScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.reportGeneration}',
        name: AppRoutes.reportGeneration,
        builder: (context, state) => const ReportGenerationScreen(),
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
      GoRoute(
        path: '/${AppRoutes.physiotherapy}',
        name: AppRoutes.physiotherapy,
        builder: (context, state) => const PhysiotherapyScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.chiropractic}',
        name: AppRoutes.chiropractic,
        builder: (context, state) => const ChiropracticScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.ent}',
        name: AppRoutes.ent,
        builder: (context, state) => const ENTScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.eyeCare}',
        name: AppRoutes.eyeCare,
        builder: (context, state) => const EyeCareScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.addictionRecovery}',
        name: AppRoutes.addictionRecovery,
        builder: (context, state) => const AddictionRecoveryScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.hivPrevention}',
        name: AppRoutes.hivPrevention,
        builder: (context, state) => const HIVPreventionScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.hivClinics}',
        name: AppRoutes.hivClinics,
        builder: (context, state) => const HIVClinicsScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.hivPreventionPrograms}',
        name: AppRoutes.hivPreventionPrograms,
        builder: (context, state) => const HIVPreventionProgramsScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.hivSupportOrganizations}',
        name: AppRoutes.hivSupportOrganizations,
        builder: (context, state) => const HIVSupportOrganizationsScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.hivHistory}',
        name: AppRoutes.hivHistory,
        builder: (context, state) => const HIVHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.pulmonology,
        name: AppRoutes.pulmonology,
        builder: (context, state) => const PulmonologyScreen(),
      ),
      GoRoute(
        path: AppRoutes.podiatry,
        name: AppRoutes.podiatry,
        builder: (context, state) => const PodiatryScreen(),
      ),
      GoRoute(
        path: AppRoutes.fertilityChildCare,
        name: AppRoutes.fertilityChildCare,
        builder: (context, state) => const FertilityHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.fertilityTracking,
        name: AppRoutes.fertilityTracking,
        builder: (context, state) => const FertilityTrackingScreen(),
      ),
      GoRoute(
        path: AppRoutes.pregnancyPlanning,
        name: AppRoutes.pregnancyPlanning,
        builder: (context, state) => const PregnancyPlanningScreen(),
      ),
      GoRoute(
        path: AppRoutes.medicalData,
        name: AppRoutes.medicalData,
        builder: (context, state) => const MedicalDataScreen(),
      ),
      GoRoute(
        path: AppRoutes.pregnancyTracking,
        name: AppRoutes.pregnancyTracking,
        builder: (context, state) => const PregnancyTrackingScreen(),
      ),
      GoRoute(
        path: AppRoutes.newbornChildCare,
        name: AppRoutes.newbornChildCare,
        builder: (context, state) => const NewbornChildCareScreen(),
      ),
      GoRoute(
        path: AppRoutes.mothersHealth,
        name: AppRoutes.mothersHealth,
        builder: (context, state) => const MothersHealthScreen(),
      ),
    ],
  );
}
