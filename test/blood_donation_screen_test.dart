import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_gris/screens/blood_donation_screen.dart';
import 'package:provider/provider.dart';
import 'package:ai_gris/providers/user_provider.dart';

// Mock UserProvider
class MockUserProvider extends ChangeNotifier implements UserProvider {
  @override
  String get selectedLanguage => 'en';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockUserProvider mockUserProvider;

  setUp(() {
    mockUserProvider = MockUserProvider();
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<UserProvider>.value(
      value: mockUserProvider,
      child: const MaterialApp(
        home: BloodDonationScreen(),
      ),
    );
  }

  testWidgets('Blood Donation Screen - Eligibility Flow', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify Eligibility Check is shown first
    expect(find.text('Eligibility Check'), findsOneWidget);
    expect(find.text('Find Donation Centers'), findsOneWidget);

    // Tap "Find Donation Centers" without checking boxes
    // Scroll to make sure it's visible
    await tester.drag(find.text('Eligibility Check'), const Offset(0, -300));
    await tester.pump();
    
    await tester.tap(find.text('Find Donation Centers'));
    await tester.pump();
    
    // Should still be on Eligibility screen (button is disabled/no-op)
    expect(find.text('Eligibility Check'), findsOneWidget);
    expect(find.text('Nearby Donation Centers'), findsNothing);

    // Scroll back up to see checkboxes
    await tester.drag(find.text('Find Donation Centers'), const Offset(0, 300));
    await tester.pump();

    // Check all boxes
    final checkboxes = find.byIcon(Icons.check_box_outline_blank_rounded);
    expect(checkboxes, findsNWidgets(6));

    // Tap all of them
    for (int i = 0; i < 6; i++) {
      await tester.tap(find.byIcon(Icons.check_box_outline_blank_rounded).first);
      await tester.pump();
    }

    // Scroll down again
    await tester.drag(find.text('Eligibility Check'), const Offset(0, -500));
    await tester.pump();

    // Now tap "Find Donation Centers" again
    await tester.tap(find.text('Find Donation Centers'));
    await tester.pumpAndSettle();

    // Should now see the Main Content
    expect(find.text('Nearby Donation Centers'), findsOneWidget);
    expect(find.text('City Blood Bank'), findsOneWidget);
  });

  testWidgets('Blood Donation Screen - Search Functionality', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Bypass eligibility for this test by checking all boxes
    final checkboxes = find.byIcon(Icons.check_box_outline_blank_rounded);
    for (int i = 0; i < 6; i++) {
      await tester.tap(find.byIcon(Icons.check_box_outline_blank_rounded).first);
      await tester.pump();
    }
    
    // Scroll down to button
    await tester.drag(find.text('Eligibility Check'), const Offset(0, -500));
    await tester.pump();

    await tester.tap(find.text('Find Donation Centers'));
    await tester.pumpAndSettle();

    // Open Search
    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pump();

    // Verify Search Field appears
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Ask AI to Find Location'), findsOneWidget);

    // Test Manual Search
    await tester.enterText(find.byType(TextField), 'University');
    await tester.pump();

    // Should show University Hospital but NOT City Blood Bank
    expect(find.text('University Hospital Blood Center'), findsOneWidget);
    expect(find.text('City Blood Bank'), findsNothing);
  });
}
