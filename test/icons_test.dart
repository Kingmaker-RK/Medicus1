import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicus/widgets/benzene_icon.dart';
import 'package:medicus/widgets/medicus_logo.dart';

void main() {
  group('Icon Widgets Tests', () {
    testWidgets('BenzeneIcon renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BenzeneIcon(size: 100),
            ),
          ),
        ),
      );

      expect(find.byType(BenzeneIcon), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BenzeneIcon),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('MedicusLogo renders correctly without text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MedicusLogo(size: 100, showText: false),
            ),
          ),
        ),
      );

      expect(find.byType(MedicusLogo), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MedicusLogo),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
      expect(find.text('MEDICUS'), findsNothing);
    });

    testWidgets('MedicusLogo renders correctly with text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MedicusLogo(size: 100, showText: true),
            ),
          ),
        ),
      );

      expect(find.byType(MedicusLogo), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MedicusLogo),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
      expect(find.text('MEDICUS'), findsOneWidget);
    });
  });
}
