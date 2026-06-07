import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_gris/screens/addiction_recovery_centers_screen.dart';
import 'package:ai_gris/services/addiction_recovery_service.dart';
import 'test_helpers.dart';

class MockAddictionRecoveryService extends AddictionRecoveryService {
  @override
  Future<List<Map<String, dynamic>>> findCenters(String addictionType) async {
    return [
      {
        'name': 'Hope Center',
        'type': 'Clinic',
        'specialty': 'Rehab',
        'location': 'Main St, Berlin',
        'pincode': '10115',
        'rating': 4.5,
        'reviews': 50,
        'distance': '2.0 km',
        'available': true,
        'phone': '+49 123',
        'website': 'hope.com',
        'opening_hours': '09:00 - 18:00',
      },
      {
        'name': 'Recovery Hub',
        'type': 'Support Center',
        'specialty': 'Counseling',
        'location': 'Side St, Potsdam',
        'pincode': '14467',
        'rating': 4.0,
        'reviews': 30,
        'distance': '25.0 km',
        'available': true,
        'phone': '+49 456',
        'website': 'recovery.com',
        'opening_hours': '10:00 - 16:00',
      },
    ];
  }
}

void main() {
  setupFirebaseMocks();

  testWidgets('Search functionality works for Name, Location, and Pincode', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(
      child: AddictionRecoveryCentersScreen(
        addictionType: 'Alcohol',
        service: MockAddictionRecoveryService(),
      ),
    ));

    // Wait for load
    await tester.pumpAndSettle();

    // Verify initial list
    expect(find.text('Hope Center'), findsOneWidget);
    expect(find.text('Recovery Hub'), findsOneWidget);

    // 1. Search by Name
    // Ensure "Name" chip is selected (default)
    expect(find.text('Name'), findsOneWidget);
    
    // Enter search text
    await tester.enterText(find.byType(TextField), 'Hope');
    await tester.pumpAndSettle();

    // Verify filter
    expect(find.text('Hope Center'), findsOneWidget);
    expect(find.text('Recovery Hub'), findsNothing);

    // Clear search
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('Recovery Hub'), findsOneWidget);

    // 2. Search by Location
    // Tap "Location" chip
    await tester.tap(find.text('Location'));
    await tester.pumpAndSettle();

    // Enter search text "Potsdam"
    await tester.enterText(find.byType(TextField), 'Potsdam');
    await tester.pumpAndSettle();

    // Verify filter
    expect(find.text('Recovery Hub'), findsOneWidget);
    expect(find.text('Hope Center'), findsNothing);

    // 3. Search by Pincode
    // Tap "Pincode" chip
    await tester.tap(find.text('Pincode'));
    await tester.pumpAndSettle();

    // Enter search text "10115"
    await tester.enterText(find.byType(TextField), '10115');
    await tester.pumpAndSettle();

    // Verify filter
    expect(find.text('Hope Center'), findsOneWidget); // 10115 matches Hope Center
    expect(find.text('Recovery Hub'), findsNothing);
  });
}