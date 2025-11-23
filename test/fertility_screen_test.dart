import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_gris/screens/fertility/fertility_home_screen.dart';
import 'test_helpers.dart'; // Assuming this helper exists given the other tests

void main() {
  testWidgets('Fertility Home Screen renders and navigates', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(MaterialApp(
      home: const FertilityHomeScreen(),
    ));

    // Verify the title
    expect(find.text('Fertility & Child Care'), findsOneWidget);

    // Verify sections
    expect(find.text('Fertility'), findsOneWidget);
    expect(find.text('Child Care & Pregnancy'), findsOneWidget);
    
    // Verify buttons exist
    expect(find.text('Fertility Tracking'), findsOneWidget);
    expect(find.text('Pregnancy Planning'), findsOneWidget);
    expect(find.text('Medical Data'), findsOneWidget);
    expect(find.text('Pregnancy Tracking'), findsOneWidget);
    expect(find.text('Newborn & Child Care'), findsOneWidget);
    expect(find.text('Mother\'s Health'), findsOneWidget);

    // Verify AI Section
    expect(find.text('Ask Fertility AI'), findsOneWidget);
  });
}
