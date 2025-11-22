import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_gris/widgets/benzene_icon.dart';
import 'package:ai_gris/widgets/ai_gris_logo.dart';

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

    testWidgets('AiGrisLogo renders correctly without text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AiGrisLogo(size: 100, showText: false),
            ),
          ),
        ),
      );

      expect(find.byType(AiGrisLogo), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AiGrisLogo),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
      expect(find.text('MEDICUS'), findsNothing);
    });

    testWidgets('AiGrisLogo renders correctly with text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AiGrisLogo(size: 100, showText: true),
            ),
          ),
        ),
      );

      expect(find.byType(AiGrisLogo), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AiGrisLogo),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
      expect(find.text('MEDICUS'), findsOneWidget);
    });
  });
}
