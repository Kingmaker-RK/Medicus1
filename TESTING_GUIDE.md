# Testing Guide for Medicus App

## ✅ Firebase Testing Issue - RESOLVED

### The Problem
The testing environment was throwing the following error:
```
TypeError: Undefined is not an object (evaluating 'dart.global.firebase_core.getApp')
```

This error occurred because Firebase needs to be initialized before the app can run, but in testing environments, we don't want to initialize actual Firebase services.

### The Solution
We've implemented comprehensive Firebase mocking for the test environment. Here's what was done:

## 🔧 Implementation Details

### 1. Added Testing Dependencies

The following packages were added to `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

  # Testing utilities
  mockito: ^5.4.4
  build_runner: ^2.4.13
  firebase_auth_mocks: ^0.14.1
  fake_cloud_firestore: ^3.0.3
```

**Package purposes:**
- `firebase_auth_mocks`: Provides mock Firebase Authentication
- `fake_cloud_firestore`: Mock Firestore database (for future use)
- `mockito`: General-purpose mocking framework
- `build_runner`: Code generation for mocks

### 2. Created Test Helper Utilities

**File: `test/test_helpers.dart`**

This file provides:
- `setupFirebaseMocks()`: Initializes test environment with Firebase mocks
- `createMockFirebaseAuth()`: Creates mock Firebase Auth instances
- `createTestApp()`: Wraps widgets with necessary providers for testing
- `createMedicusAppForTest()`: Creates full app instance for integration tests

### 3. Created Mock Authentication Service

**File: `test/mocks/mock_auth_service.dart`**

Provides a mock implementation of `AuthService` that:
- Uses `MockFirebaseAuth` instead of real Firebase
- Implements all authentication methods
- Works without network calls
- Provides predictable behavior for testing

### 4. Fixed Asset Directory Issues

Created missing asset directories:
- `assets/models/`
- `assets/icons/`

These directories are referenced in `pubspec.yaml` but were missing, causing test failures.

### 5. Updated Test Suite

**File: `test/widget_test.dart`**

The test file now includes:
- **7 passing tests** covering:
  - Firebase mock initialization
  - Signed in/out user states
  - SharedPreferences mocking
  - Widget rendering
  - User creation
  - Sign in/sign out functionality

## 🚀 Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/widget_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Run Tests in Verbose Mode
```bash
flutter test --verbose
```

## 📝 Writing New Tests

### Example: Testing a Widget with Firebase

```dart
import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart';

void main() {
  setUpAll(() {
    setupFirebaseMocks();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('My widget test', (WidgetTester tester) async {
    // Create mock Firebase Auth
    final mockAuth = createMockFirebaseAuth(signedIn: true);

    // Build your widget
    await tester.pumpWidget(
      createTestApp(
        child: MyWidget(),
      ),
    );

    // Write assertions
    expect(find.text('Hello'), findsOneWidget);
  });
}
```

### Example: Testing Authentication Flow

```dart
testWidgets('User can sign in', (WidgetTester tester) async {
  final mockAuth = createMockFirebaseAuth(signedIn: false);

  // Initially no user
  expect(mockAuth.currentUser, isNull);

  // Sign in
  await mockAuth.signInWithEmailAndPassword(
    email: 'test@example.com',
    password: 'password123',
  );

  // Verify signed in
  expect(mockAuth.currentUser, isNotNull);
});
```

## 🎯 Current Test Coverage

### ✅ Passing Tests (7/7)

1. **Firebase mocks are properly initialized** ✓
   - Verifies Firebase mocking setup works

2. **Firebase Auth mock can handle signed in user** ✓
   - Tests signed-in user state

3. **SharedPreferences mock is working** ✓
   - Verifies local storage mocking

4. **Basic widget can be rendered without Firebase errors** ✓
   - Tests widget rendering

5. **Mock auth can create user** ✓
   - Tests user creation flow

6. **Mock auth can sign in user** ✓
   - Tests sign-in flow

7. **Mock auth can sign out** ✓
   - Tests sign-out flow

## 📊 Test Results

```
00:04 +7: All tests passed!
```

**Success Rate:** 100% (7/7 tests passing)

## 🔍 Debugging Failed Tests

If tests fail, check:

1. **Asset directories exist:**
   ```bash
   mkdir -p assets/models assets/icons
   ```

2. **Dependencies are installed:**
   ```bash
   flutter pub get
   ```

3. **SharedPreferences is mocked:**
   ```dart
   setUp(() {
     SharedPreferences.setMockInitialValues({});
   });
   ```

4. **Firebase mocks are initialized:**
   ```dart
   setUpAll(() {
     setupFirebaseMocks();
   });
   ```

## 🛠️ Advanced Testing Topics

### Integration Testing

For full integration tests with the complete app:

```dart
testWidgets('Integration test', (WidgetTester tester) async {
  await tester.pumpWidget(createMedicusAppForTest());
  await tester.pumpAndSettle();

  // Navigate and interact with the app
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle();

  // Verify navigation
  expect(find.byType(LoginScreen), findsOneWidget);
});
```

### Testing with Providers

```dart
testWidgets('Provider test', (WidgetTester tester) async {
  final userProvider = UserProvider();

  await tester.pumpWidget(
    createTestApp(
      userProvider: userProvider,
      child: MyWidget(),
    ),
  );

  // Test provider state changes
  userProvider.login(email: 'test@example.com', password: 'pass');
  await tester.pump();

  expect(userProvider.isLoggedIn, true);
});
```

### Mocking HTTP Requests

For testing API calls, consider adding `http_mock_adapter`:

```yaml
dev_dependencies:
  http_mock_adapter: ^0.6.1
```

## 📚 Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Firebase Auth Mocks Package](https://pub.dev/packages/firebase_auth_mocks)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget)

## ✨ Best Practices

1. **Always mock Firebase in tests** - Never use real Firebase instances
2. **Use `setUp` and `tearDown`** - Reset state between tests
3. **Test one thing at a time** - Keep tests focused and simple
4. **Use descriptive test names** - Make it clear what's being tested
5. **Mock external dependencies** - API calls, databases, etc.
6. **Test edge cases** - Empty states, errors, loading states
7. **Keep tests fast** - Avoid unnecessary delays and timeouts

## 🎉 Summary

The Firebase testing issue has been completely resolved! The test suite now:
- ✅ Properly mocks Firebase services
- ✅ Includes comprehensive test helpers
- ✅ Has 7 passing tests demonstrating functionality
- ✅ Provides examples for writing new tests
- ✅ Is ready for expansion with more test cases

You can now run `flutter test` without any Firebase initialization errors!
