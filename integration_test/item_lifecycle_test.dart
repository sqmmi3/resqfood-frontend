import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/providers/notification/notification_provider.dart';
import 'package:frontend/providers/theme/theme_provider.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/items/item_details_screen.dart';
import 'package:frontend/screens/items/manual_add_item_screen.dart';
import 'package:frontend/widgets/user_item/user_item_detail_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'helpers.dart';

Future<void> pumpAppWithLogin(WidgetTester tester) async {
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
  await loginAs(tester, username: 'admin', password: 'Admin123%');
}

void main() async {
  await initializeTestEnvironment();

  group('Item Lifecycle Tests', () {
    testWidgets('Verify Add Item screen has necessary fields', (WidgetTester tester) async {
      await pumpAppWithLogin(tester);

      final homeFab = find.byKey(const Key('home_fab'));
      expect(homeFab, findsOneWidget);
      await tester.tap(homeFab);
      await tester.pumpAndSettle();
      
      final addManuallyBtn = find.byKey(const Key('menu_add_manually'));
      await tester.tap(addManuallyBtn);
      await tester.pumpAndSettle();

      expect(find.byType(ManualAddItemScreen), findsOneWidget);

      expect(find.text('Product name'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Expiry date'), findsOneWidget);
      expect(find.text('Opened rule (opt)'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('Create an item', (WidgetTester tester) async {
      await pumpAppWithLogin(tester);

      await tester.tap(find.byKey(const Key('home_fab')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu_add_manually')));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Product name'), 'Chicken Tenders');

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PROTEIN').last);
      await tester.pumpAndSettle();

      final twoWeeksFromNow = DateTime.now().add(const Duration(days: 14));
      final dateStr = DateFormat('dd-MM-yyyy').format(twoWeeksFromNow);

      await tester.tap(find.widgetWithText(TextFormField, 'Product expiry date'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, dateStr);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Product description'), 'Amount: 400');
      
      await tester.tap(find.text('Add to Inventory'));
      await tester.pumpAndSettle();

      expect(find.text('Item successfully added!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2)); 
      await tester.pumpAndSettle();
      
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Verify item details on Home screen', (WidgetTester tester) async {
      await pumpAppWithLogin(tester);

      await tester.tap(find.byKey(const Key('home_fab')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu_add_manually')));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Product name'), 'Chicken Tenders');
      
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PROTEIN').last);
      await tester.pumpAndSettle();

      final twoWeeksFromNow = DateTime.now().add(const Duration(days: 14));
      final dateStr = DateFormat('dd-MM-yyyy').format(twoWeeksFromNow);

      await tester.tap(find.widgetWithText(TextFormField, 'Product expiry date'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, dateStr);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to Inventory'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2)); 
      await tester.pumpAndSettle();

      expect(find.text('Chicken Tenders'), findsOneWidget);

      await tester.tap(find.text('Chicken Tenders'));
      await tester.pumpAndSettle();

      expect(find.byType(ItemDetailsScreen), findsOneWidget);
      expect(find.text('Chicken Tenders'), findsOneWidget);
      expect(find.text('PROTEIN'), findsOneWidget);
      expect(find.byType(UserItemDetailCard), findsOneWidget);
    });
  });
}
