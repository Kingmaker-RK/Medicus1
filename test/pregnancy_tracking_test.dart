import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_gris/screens/fertility/pregnancy_tracking_screen.dart';

void main() {
  testWidgets('Pregnancy Tracking Screen renders key components', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PregnancyTrackingScreen(),
    ));

    // Verify Title
    expect(find.text('Pregnancy Tracker'), findsOneWidget);

    // Verify Week Progress
    expect(find.textContaining('Week'), findsOneWidget);
    expect(find.textContaining('Days to go'), findsOneWidget);

    // Verify Baby Size Card
    expect(find.text('Baby is the size of an'), findsOneWidget);

    // Verify Tools Grid
    expect(find.text('Kick Counter'), findsOneWidget);
    expect(find.text('Contraction Timer'), findsOneWidget);
    expect(find.text('Weight Tracker'), findsOneWidget);
    expect(find.text('Bump Gallery'), findsOneWidget);
  });
}
