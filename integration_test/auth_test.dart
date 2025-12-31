import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/auth/register_screen.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/settings/settings_screen.dart';
import 'package:frontend/screens/profile/profile_screen.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_primary_button.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_text_field.dart';

import 'helpers.dart';

Future<void> main() async {
  await initializeTestEnvironment();

  group('Auth Flow', () {
    testWidgets('Shows login screen on launch', (WidgetTester tester) async {
      await pumpRealApp(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Login with correct credentials', (WidgetTester tester) async {
      await pumpRealApp(tester);
      await loginAs(tester, username: 'admin', password: 'Admin123%');
      expect(find.byType(MainScreen), findsOneWidget);
    });
  });

  group('Register Validation', () {
    testWidgets('Register with correct values', (WidgetTester tester) async {
      await pumpRealApp(tester);

      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);

      final ts = DateTime.now().millisecondsSinceEpoch;
      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Username'), 'newuser$ts');
      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Email'), 'newuser$ts@example.com');
      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Password'), 'Password123!');
      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Confirm password'), 'Password123!');
      await tester.pump();

      await tester.tap(find.widgetWithText(ResQFoodPrimaryButton, 'REGISTER'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Invalid email shows validation error', (WidgetTester tester) async {
      await pumpRealApp(tester);
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Username'), 'user');
      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Email'), 'invalid');
      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Password'), 'Password123!');
      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Confirm password'), 'Password123!');
      await tester.pump();

      await tester.tap(find.widgetWithText(ResQFoodPrimaryButton, 'REGISTER'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email format.'), findsOneWidget);
    });

    testWidgets('Password mismatch shows validation error', (WidgetTester tester) async {
      await pumpRealApp(tester);
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Username'), 'user');
      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Email'), 'user@example.com');
      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Password'), 'Password123!');
      await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Confirm password'), 'Different123!');
      await tester.pump();

      await tester.tap(find.widgetWithText(ResQFoodPrimaryButton, 'REGISTER'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });
  });

  group('Logout', () {
    testWidgets('User can logout from settings', (WidgetTester tester) async {
      await pumpRealApp(tester);
      await loginAs(tester, username: 'admin', password: 'Admin123%');

      await openSettingsTab(tester);
      expect(find.byType(SettingsScreen), findsOneWidget);
      final logoutTile = find.text('Logout');
      await tester.scrollUntilVisible(
        logoutTile,
        500.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(logoutTile);
      await tester.pumpAndSettle();

      await waitForWidget(tester, find.byType(LoginScreen), const Duration(seconds: 10));
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('User can logout from profile', (WidgetTester tester) async {
      await pumpRealApp(tester);
      await loginAs(tester, username: 'admin', password: 'Admin123%');

      await openProfileFromMenu(tester);
      expect(find.byType(ProfileScreen), findsOneWidget);
      final logoutButton = find.text('Logout of ResQFood');
      await tester.scrollUntilVisible(
        logoutButton,
        500.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      await waitForWidget(tester, find.byType(LoginScreen), const Duration(seconds: 10));
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
