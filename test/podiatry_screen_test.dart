import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ai_gris/screens/podiatry_screen.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

  group('Podiatry Screen Tests', () {
    testWidgets('Podiatry Screen renders tabs and default view', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        child: const PodiatryScreen(),
        userProvider: mockUserProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Podiatry'), findsOneWidget);
      expect(find.text('Find Specialist'), findsOneWidget);
      expect(find.text('My Reports'), findsOneWidget);
      
      // Default view should be Find Specialist
      expect(find.text('Showing specialists near you'), findsOneWidget);
      expect(find.text('City Foot Care Center'), findsOneWidget);
    });

    testWidgets('Search functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        child: const PodiatryScreen(),
        userProvider: mockUserProvider,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      
      // Search for "Hospital"
      await tester.enterText(find.byType(TextField), 'Hospital');
      await tester.pump();

      expect(find.text('City Foot Care Center'), findsNothing);
      expect(find.text('General Hospital - Podiatry Dept'), findsOneWidget);
    });

    testWidgets('AI Search button exists and triggers', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        child: const PodiatryScreen(),
        userProvider: mockUserProvider,
      ));
      await tester.pumpAndSettle();

      final aiButton = find.byIcon(LucideIcons.sparkles);
      expect(aiButton, findsOneWidget);
      
      await tester.tap(aiButton);
      await tester.pump(const Duration(seconds: 3)); // Wait for timer
      await tester.pumpAndSettle();
      
      // Just check if it doesn't crash
      expect(find.text('Podiatry'), findsOneWidget);
    });

    testWidgets('Reports tab handles upload', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        child: const PodiatryScreen(),
        userProvider: mockUserProvider,
      ));
      await tester.pumpAndSettle();

      // Switch to Reports tab
      await tester.tap(find.text('My Reports'));
      await tester.pumpAndSettle();

      expect(find.text('No reports uploaded yet'), findsOneWidget);

      // Upload Report
      await tester.tap(find.text('Upload First Report'));
      await tester.pumpAndSettle();

      expect(find.text('No reports uploaded yet'), findsNothing);
      expect(find.textContaining('Foot_Report_'), findsOneWidget);
    });
  });
}
