import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ai_gris/screens/register_account_screen.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:ai_gris/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Fake UserProvider that throws on signUp
class FakeUserProvider extends ChangeNotifier implements UserProvider {
  @override
  bool get isLoading => false;

  @override
  bool get isLoggedIn => false;
  
  // Implement other required members with dummy values/implementations
  @override
  get currentUser => null;
  @override
  get selectedLanguage => 'en';
  @override
  get serviceUsageCounts => {};
  @override
  get sortServicesByUsage => false;

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String role,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String gender,
    bool rememberMe = false,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 100));
    // Throw specific error to test UI handling
    throw 'Email already in use';
  }

  // Stubs for other methods to satisfy interface
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('RegisterAccountScreen shows specific error message on failure', (WidgetTester tester) async {
    final fakeUserProvider = FakeUserProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: fakeUserProvider),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: RegisterAccountScreen(
            firstName: 'John',
            lastName: 'Doe',
            dob: DateTime(1990, 1, 1),
            gender: 'Male',
            role: 'Patient',
          ),
        ),
      ),
    );

    // Fill in the form
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com'); // Email
    await tester.enterText(find.byType(TextFormField).at(1), 'password123'); // Password
    await tester.enterText(find.byType(TextFormField).at(2), 'password123'); // Confirm Password
    
    // Check Terms
    final termsCheckbox = find.byType(Checkbox).first;
    await tester.ensureVisible(termsCheckbox);
    await tester.tap(termsCheckbox);
    
    // Check Human verification
    final humanCheckbox = find.byType(Checkbox).last;
    await tester.ensureVisible(humanCheckbox);
    await tester.tap(humanCheckbox);
    await tester.pump();

    // Tap Done
    final doneButton = find.text('Done');
    await tester.ensureVisible(doneButton);
    await tester.tap(doneButton);
    await tester.pump(); // Start async op
    await tester.pump(const Duration(seconds: 1)); // Wait for async op and snackbar

    // Verify error message is displayed
    expect(find.text('Email already in use'), findsOneWidget);
  });
}
