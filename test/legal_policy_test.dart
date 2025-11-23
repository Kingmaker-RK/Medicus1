import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_gris/screens/legal_policy_screen.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:ai_gris/models/user_model.dart';
import 'test_helpers.dart';

class MockUserProvider extends ChangeNotifier implements UserProvider {
  bool _isLoading = false;
  @override
  bool get isLoading => _isLoading;
  @override
  bool get isLoggedIn => false;
  @override
  UserModel? get currentUser => null;
  @override
  String get selectedLanguage => 'en';
  @override
  Future<void> login({required String email, required String password, required String role, bool rememberMe = false}) async {}
  @override
  Future<void> signUp({required String email, required String password, required String role, bool rememberMe = false}) async {}
  @override
  Future<void> continueAsGuest(String role) async {}
  @override
  Future<void> changeLanguage(String languageCode) async {}
  @override
  Future<void> logout() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    setupFirebaseMocks();
  });

  testWidgets('LegalPolicyScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(
      child: const LegalPolicyScreen(),
      userProvider: MockUserProvider(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy & Terms'), findsOneWidget);
    expect(find.byIcon(Icons.download), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    
    // Verify some content is present
    expect(find.textContaining('Comprehensive Global Privacy'), findsOneWidget);
  });
}
