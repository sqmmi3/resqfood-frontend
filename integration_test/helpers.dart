import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/providers/notification/notification_provider.dart';
import 'package:frontend/providers/theme/theme_provider.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_primary_button.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_text_field.dart';
import 'package:frontend/screens/settings/settings_screen.dart';
import 'package:frontend/screens/profile/profile_screen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

/// Initialiseer een test environment, firebase en dotenv
Future<void> initializeTestEnvironment() async {
  try {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    if (!dotenv.isInitialized) {
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        debugPrint('Warning: Failed to load .env file: $e');
      }
    }

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
    
  } catch (e, stack) {
    debugPrint('Error initializing test environment: $e\n$stack');
    rethrow;
  }
}

/// start echte app zonder mock providers
Future<void> pumpRealApp(WidgetTester tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserItemProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: ResQFoodApp(navKey: GlobalKey<NavigatorState>()),
    ),
  );
  await tester.pumpAndSettle();
  
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> loginAs(WidgetTester tester, {required String username, required String password}) async {
  await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Username'), username);
  await tester.enterText(find.widgetWithText(ResQFoodTextField, 'Password'), password);
  await tester.pump();
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ResQFoodPrimaryButton, 'LOGIN'));
  await waitForWidget(tester, find.byType(MainScreen), const Duration(seconds: 20));
}


Future<void> waitForWidget(WidgetTester tester, Finder finder, Duration timeout) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
}

Future<void> openSettingsTab(WidgetTester tester) async {
  await waitForWidget(tester, find.byType(MainScreen), const Duration(seconds: 10));
  await tester.pump(const Duration(milliseconds: 500));

  /// Geef ectra tijd voor eventuele overlays om te verdwijnen
  FocusManager.instance.primaryFocus?.unfocus();

  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.settings), warnIfMissed: false);
  await tester.pumpAndSettle();
  
  await waitForWidget(tester, find.byType(SettingsScreen), const Duration(seconds: 5));
}

/// Opens the profile from the menu
Future<void> openProfileFromMenu(WidgetTester tester) async {
  final profileButton = find.byIcon(Icons.account_circle);
  await waitForWidget(tester, profileButton, const Duration(seconds: 5));
  // Give extra time for any overlays to dismiss
  await tester.pump(const Duration(milliseconds: 500));
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.tap(profileButton, warnIfMissed: false);
  await tester.pumpAndSettle();

  await waitForWidget(tester, find.text('My Profile'), const Duration(seconds: 5));
  await tester.tap(find.text('My Profile'));
  await tester.pumpAndSettle();

  await waitForWidget(tester, find.byType(ProfileScreen), const Duration(seconds: 5));
  await waitForWidget(tester, find.byType(ListView), const Duration(seconds: 10));
}

Future<void> toggleSetting(WidgetTester tester, String label) async {
  final switchFinder = find.widgetWithText(SwitchListTile, label);
  await tester.scrollUntilVisible(switchFinder, 500.0, scrollable: find.byType(Scrollable).last);
  await tester.pumpAndSettle();
  final before = tester.widget<SwitchListTile>(switchFinder).value;
  await tester.tap(switchFinder);
  await tester.pumpAndSettle();
  final after = tester.widget<SwitchListTile>(switchFinder).value;
  expect(after, equals(!before));
}

Future<void> adjustFontSize(WidgetTester tester) async {
  final fontSizeTile = find.text('Font Size');
  await tester.scrollUntilVisible(fontSizeTile, 500.0, scrollable: find.byType(Scrollable).last);
  await tester.tap(fontSizeTile);
  await tester.pumpAndSettle();

  final sliderFinder = find.byType(Slider);
  expect(sliderFinder, findsOneWidget);

  final initial = tester.widget<Slider>(sliderFinder).value;
  final sliderCenter = tester.getCenter(sliderFinder);
  await tester.tapAt(sliderCenter + const Offset(40, 0));
  await tester.pumpAndSettle();

  final updated = tester.widget<Slider>(sliderFinder).value;
  expect(updated, isNot(initial));


  final barrier = find.byType(ModalBarrier);
  if (barrier.evaluate().isNotEmpty) {
    await tester.tap(barrier.last);
    await tester.pumpAndSettle();
  }
}

Future<void> logoutFromProfile(WidgetTester tester) async {
  await openProfileFromMenu(tester);
  final logoutButton = find.byKey(const Key('profile_logout'));
  await tester.scrollUntilVisible(logoutButton, 500.0, scrollable: find.byType(Scrollable).last);
  await tester.tap(logoutButton);
  await tester.pumpAndSettle();
}
