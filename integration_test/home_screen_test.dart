import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/providers/notification/notification_provider.dart';
import 'package:frontend/providers/theme/theme_provider.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/items/manual_add_item_screen.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_primary_button.dart';
import 'package:provider/provider.dart';

import 'helpers.dart';

// start app en log in, 1 keer voor alle testen
Future<void> pumpAppWithLogin(WidgetTester tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserItemProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const ResQFoodApp(),
    ),
  );
  await tester.pumpAndSettle();
  
  await loginAs(tester, username: 'admin', password: 'Admin123%');
}

Future<void> main() async {
  await initializeTestEnvironment();

  group('Home Screen', () {
    testWidgets('Shows empty state when no items exist', (WidgetTester tester) async {
      await pumpAppWithLogin(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Navigates to manual add item screen', (WidgetTester tester) async {
      await pumpAppWithLogin(tester);

      final homeFab = find.byKey(const Key('home_fab'));
      expect(homeFab, findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(homeFab, warnIfMissed: false);
      await tester.pumpAndSettle();
      
      await waitForWidget(tester, find.byKey(const Key('menu_add_manually')), const Duration(seconds: 2));
      await tester.tap(find.byKey(const Key('menu_add_manually')));
      await tester.pumpAndSettle();

      expect(find.byType(ManualAddItemScreen), findsOneWidget);
    });
  });

  group('Home Menu Interaction', () {
    testWidgets('Backdrop tap closes expansion menu', (WidgetTester tester) async {
      await pumpAppWithLogin(tester);

      final homeFab = find.byKey(const ValueKey('home_fab'));
      expect(homeFab, findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(homeFab, warnIfMissed: false);
      await tester.pumpAndSettle();
      await waitForWidget(tester, find.text('Add Manually'), const Duration(seconds: 2));
      expect(find.text('Add Manually'), findsOneWidget);

      final backdrop = find.byType(GestureDetector).first;
      await tester.tap(backdrop);
      await tester.pumpAndSettle();

      expect(find.text('Add Manually'), findsNothing);
    });

    testWidgets('FAB can be tapped multiple times', (WidgetTester tester) async {
      await pumpAppWithLogin(tester);

      final homeFab = find.byKey(const ValueKey('home_fab'));

      await tester.pump(const Duration(milliseconds: 500));
      
      await tester.tap(homeFab, warnIfMissed: false);
      await tester.pumpAndSettle();
      await waitForWidget(tester, find.text('Add Manually'), const Duration(seconds: 2));
      expect(find.text('Add Manually'), findsOneWidget);
      
    
      await tester.tap(homeFab, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Add Manually'), findsNothing);
      
      await tester.tap(homeFab, warnIfMissed: false);
      await tester.pumpAndSettle();
      await waitForWidget(tester, find.text('Add Manually'), const Duration(seconds: 2));
      expect(find.text('Add Manually'), findsOneWidget);
    });
  });

  group('Manual Add Item', () {
    testWidgets('Missing fields show error snackbars', (WidgetTester tester) async {
      await pumpAppWithLogin(tester);

      final homeFab = find.byKey(const Key('home_fab'));

      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(homeFab, warnIfMissed: false);
      await tester.pumpAndSettle();
      
      await waitForWidget(tester, find.byKey(const Key('menu_add_manually')), const Duration(seconds: 2));
      await tester.tap(find.byKey(const Key('menu_add_manually')));
      await tester.pumpAndSettle();

      await waitForWidget(tester, find.byType(ManualAddItemScreen), const Duration(seconds: 5));

      final addButton = find.widgetWithText(ResQFoodPrimaryButton, 'ADD TO INVENTORY');
      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pump();

      expect(find.text('Product name is required.'), findsOneWidget);
    });
  });
}
