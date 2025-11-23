import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ai_gris/screens/hiv_prevention_screen.dart';
import 'package:ai_gris/screens/hiv_clinics_screen.dart';
import 'package:ai_gris/screens/hiv_prevention_programs_screen.dart';
import 'package:ai_gris/screens/hiv_support_organizations_screen.dart';
import 'package:ai_gris/screens/hiv_history_screen.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'test_helpers.dart';

class MockUserProvider extends Mock implements UserProvider {
  @override
  String get selectedLanguage => 'en';
  
  @override
  bool get hasListeners => false;

  @override
  void addListener(VoidCallback? listener) {}

  @override
  void removeListener(VoidCallback? listener) {}
}

void main() {
  late MockUserProvider mockUserProvider;

  setUp(() {
    mockUserProvider = MockUserProvider();
  });

  group('HIV Prevention Feature Tests', () {
    testWidgets('HIV Prevention Screen renders main navigation grid', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        child: const HIVPreventionScreen(),
        userProvider: mockUserProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.text('HIV/STI Prevention'), findsOneWidget);
      expect(find.text('Clinics Near You'), findsOneWidget);
      expect(find.text('Prevention Programs'), findsOneWidget);
      expect(find.text('Support Organizations'), findsOneWidget);
      expect(find.text('My Reports'), findsOneWidget);
    });

    testWidgets('HIV Clinics Screen renders and searches', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        child: const HIVClinicsScreen(),
        userProvider: mockUserProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.text('HIV/STI Clinics'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      
      // Check for default list items
      expect(find.text('City Health Clinic (Free)'), findsOneWidget);

      // Test Search
      await tester.enterText(find.byType(TextField), 'Global');
      await tester.pump();

      expect(find.text('City Health Clinic (Free)'), findsNothing);
      expect(find.text('Global Health STI Center'), findsOneWidget);
    });

    testWidgets('HIV Prevention Programs Screen renders hierarchy', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        child: const HIVPreventionProgramsScreen(),
        userProvider: mockUserProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Prevention Programs'), findsOneWidget);
      expect(find.text('Programs filtered by your location'), findsOneWidget);
      expect(find.text('Near You (Local)'), findsOneWidget);
      expect(find.text('Regional / District'), findsOneWidget);
      expect(find.text('National (Country)'), findsOneWidget);
    });

    testWidgets('HIV Support Organizations Screen renders categories', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        child: const HIVSupportOrganizationsScreen(),
        userProvider: mockUserProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Support Organizations'), findsOneWidget);
      expect(find.text('Youth & Adolescents'), findsOneWidget);
      expect(find.text('Migrants & Refugees'), findsOneWidget);
      expect(find.text('Vulnerable Groups'), findsOneWidget);
    });

    testWidgets('HIV History Screen handles uploads', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        child: const HIVHistoryScreen(),
        userProvider: mockUserProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.text('My Reports & History'), findsOneWidget);
      expect(find.text('No records found'), findsOneWidget);

      // Test Upload
      await tester.tap(find.text('Upload Report'));
      await tester.pumpAndSettle();

      expect(find.text('No records found'), findsNothing);
      expect(find.textContaining('HIV_Report_'), findsOneWidget);
    });
  });
}