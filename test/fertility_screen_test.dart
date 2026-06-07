import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_gris/screens/fertility/fertility_home_screen.dart';

void main() {
  testWidgets('Fertility Home Screen renders advanced UI components', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: FertilityHomeScreen(),
    ));

    // Verify the main title
    expect(find.text('Fertility & Child Care'), findsOneWidget);

    // Verify new section headers
    expect(find.text('Fertility Journey'), findsOneWidget);
    expect(find.text('Mother & Child'), findsOneWidget);
    
    // Verify grid menu items exist
    expect(find.text('Cycle Tracking'), findsOneWidget);
    expect(find.text('Pregnancy Planning'), findsOneWidget);
    expect(find.text('Medical Data'), findsOneWidget);
    expect(find.text('Pregnancy Tracking'), findsOneWidget);
    expect(find.text('Baby Care'), findsOneWidget);
    expect(find.text('Mother\'s Health'), findsOneWidget);

    // Verify AI Section
    expect(find.text('Ask Fertility AI'), findsOneWidget);
    expect(find.text('Instant medical insights & support'), findsOneWidget);

    // Verify Daily Insight Card
    expect(find.text('Daily Insight'), findsOneWidget);
  });
}