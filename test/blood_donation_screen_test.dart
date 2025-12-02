import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_gris/screens/blood_donation_screen.dart';
import 'package:provider/provider.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:ai_gris/services/medical_places_service.dart';
import 'package:ai_gris/models/medical_facility_model.dart';

// Mock UserProvider
class MockUserProvider extends ChangeNotifier implements UserProvider {
  @override
  String get selectedLanguage => 'en';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock MedicalPlacesService
class MockMedicalPlacesService implements MedicalPlacesService {
  @override
  Future<List<MedicalFacility>> fetchFacilities({
    required String queryType,
    double? lat,
    double? lon,
    int radius = 5000,
  }) async {
    return [
      MedicalFacility(
        id: '1',
        name: 'City Blood Bank',
        address: 'Hauptstraße 123, 10115 Berlin',
        distance: 2.3,
        phone: '+49 30 12345678',
        latitude: 52.5,
        longitude: 13.4,
        openingHours: 'Mon-Fri: 8:00 - 18:00',
      ),
      MedicalFacility(
        id: '2',
        name: 'University Hospital Blood Center',
        address: 'Universitätsplatz 1, 10117 Berlin',
        distance: 3.8,
        phone: '+49 30 87654321',
        latitude: 52.51,
        longitude: 13.41,
        openingHours: 'Mon-Sun: 7:00 - 20:00',
      ),
    ];
  }
}

void main() {
  late MockUserProvider mockUserProvider;
  late MockMedicalPlacesService mockMedicalPlacesService;

  setUp(() {
    mockUserProvider = MockUserProvider();
    mockMedicalPlacesService = MockMedicalPlacesService();
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        Provider<MedicalPlacesService>.value(value: mockMedicalPlacesService),
      ],
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
