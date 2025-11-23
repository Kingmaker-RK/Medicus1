import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ai_gris/screens/e_rezept_screen.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Fake UserProvider to satisfy Provider requirement
class FakeUserProvider extends ChangeNotifier implements UserProvider {
  @override
  String get selectedLanguage => 'en';
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('ERezeptScreen renders correctly', (WidgetTester tester) async {
    // Initialize SharedPreferences with empty values
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<UserProvider>(
          create: (_) => FakeUserProvider(),
          child: const ERezeptScreen(),
        ),
      ),
    );

    // Verify title
    expect(find.text('E-Rezept'), findsOneWidget);
    
    // Verify Upload cards
    expect(find.text('Upload Prescription'), findsOneWidget);
    expect(find.text('Upload Insurance Card'), findsOneWidget);
    
    // Verify Submit button
    expect(find.text('Submit Prescription'), findsOneWidget);
    
    // Verify History section
    expect(find.text('Previous Uploads'), findsOneWidget);
  });
}