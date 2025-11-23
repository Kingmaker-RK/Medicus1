import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_gris/screens/services_hub_screen.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:ai_gris/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  testWidgets('Services are sorted alphabetically by default', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Mock Auth
    final mockAuth = MockFirebaseAuth();
    final authService = AuthService(auth: mockAuth);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ServicesHubScreen(),
        ),
        // Add dummy routes for navigation
        GoRoute(path: '/translation', builder: (c, s) => Container()),
        GoRoute(path: '/appointments', builder: (c, s) => Container()),
        GoRoute(path: '/services', builder: (c, s) => Container()),
        GoRoute(path: '/health', builder: (c, s) => Container()),
        GoRoute(path: '/reminders', builder: (c, s) => Container()),
        GoRoute(path: '/addiction-recovery', name: 'addictionRecovery', builder: (c, s) => Container()),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider(authService: authService)..initialize()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify default order (Alphabetical)
    // Find the first visible text in the list.
    // Since ListView builds children lazily, the first one should be "Addiction Recovery".
    
    final firstItemFinder = find.text('Addiction Recovery');
    expect(firstItemFinder, findsOneWidget);
    
    // Check that "E-Rezept" is NOT the first item anymore (it was first in the data list)
    // To do this, we can check the vertical position.
    
    final addictionRecoveryPosition = tester.getTopLeft(firstItemFinder).dy;
    
    // Find another item, e.g. "E-Rezept"
    // It might be off-screen or further down.
    // If it's on screen:
    if (find.text('E-Rezept').evaluate().isNotEmpty) {
       final eRezeptPosition = tester.getTopLeft(find.text('E-Rezept')).dy;
       expect(addictionRecoveryPosition < eRezeptPosition, isTrue);
    }
  });

  testWidgets('Toggling sort changes order', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    final mockAuth = MockFirebaseAuth();
    final authService = AuthService(auth: mockAuth);

    final userProvider = UserProvider(authService: authService);
    await userProvider.initialize();

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ServicesHubScreen(),
        ),
        GoRoute(path: '/translation', builder: (c, s) => Container()),
        GoRoute(path: '/appointments', builder: (c, s) => Container()),
        GoRoute(path: '/services', builder: (c, s) => Container()),
        GoRoute(path: '/health', builder: (c, s) => Container()),
        GoRoute(path: '/reminders', builder: (c, s) => Container()),
         GoRoute(path: '/addiction-recovery', name: 'addictionRecovery', builder: (c, s) => Container()),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: userProvider),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find the toggle button
    final sortButton = find.byTooltip('Sort by Most Used');
    expect(sortButton, findsOneWidget);

    // Tap it
    await tester.tap(sortButton);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Sort Alphabetically'), findsOneWidget);
    expect(userProvider.sortServicesByUsage, isTrue);
  });
}