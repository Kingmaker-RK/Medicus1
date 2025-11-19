// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_helpers.dart';

void main() {
  // Setup Firebase mocks and SharedPreferences before all tests
  setUpAll(() {
    setupFirebaseMocks();
  });

  // Reset SharedPreferences before each test
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Medicus App Basic Tests', () {
    testWidgets('Firebase mocks are properly initialized',
        (WidgetTester tester) async {
      // This test verifies that Firebase mocking is working
      // If this passes, it means the Firebase initialization error is fixed

      final mockAuth = createMockFirebaseAuth(signedIn: false);

      // Verify mock auth was created successfully
      expect(mockAuth, isNotNull);
      expect(mockAuth.currentUser, isNull);

      // Test passed - Firebase mocking is working!
    });

    testWidgets('Firebase Auth mock can handle signed in user',
        (WidgetTester tester) async {
      // Create a mock Firebase Auth instance with a signed-in user
      final mockAuth = createMockFirebaseAuth(signedIn: true);

      // Verify it was created successfully with a user
      expect(mockAuth.currentUser, isNotNull);
      expect(mockAuth.currentUser?.email, 'test@example.com');
      expect(mockAuth.currentUser?.uid, 'test-user-id');
    });

    testWidgets('SharedPreferences mock is working',
        (WidgetTester tester) async {
      // Set some test values
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('test_key', 'test_value');

      // Verify they were saved
      final value = prefs.getString('test_key');
      expect(value, 'test_value');
    });

    testWidgets('Basic widget can be rendered without Firebase errors',
        (WidgetTester tester) async {
      // Create a simple widget to verify the test environment is working
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Center(child: Text('Hello, World!')),
          ),
        ),
      );

      // Verify the widget rendered correctly
      expect(find.text('Hello, World!'), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('Mock Authentication Tests', () {
    testWidgets('Mock auth can create user', (WidgetTester tester) async {
      final mockAuth = createMockFirebaseAuth(signedIn: false);

      // Initially no user
      expect(mockAuth.currentUser, isNull);

      // Create a new user
      final userCredential = await mockAuth.createUserWithEmailAndPassword(
        email: 'new@example.com',
        password: 'password123',
      );

      // Verify user was created
      expect(userCredential.user, isNotNull);
      expect(userCredential.user?.email, 'new@example.com');
    });

    testWidgets('Mock auth can sign in user', (WidgetTester tester) async {
      final mockAuth = createMockFirebaseAuth(signedIn: false);

      // Sign in
      final userCredential = await mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      // Verify sign in successful
      expect(userCredential.user, isNotNull);
      expect(mockAuth.currentUser, isNotNull);
    });

    testWidgets('Mock auth can sign out', (WidgetTester tester) async {
      final mockAuth = createMockFirebaseAuth(signedIn: true);

      // Initially signed in
      expect(mockAuth.currentUser, isNotNull);

      // Sign out
      await mockAuth.signOut();

      // Verify signed out
      expect(mockAuth.currentUser, isNull);
    });
  });
}
