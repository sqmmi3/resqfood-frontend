import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/menu/help_guide_screen.dart';
import 'package:frontend/screens/menu/household_hub_screen.dart';
import 'package:frontend/screens/menu/impact_stats_screen.dart';
import 'helpers.dart';

Future<void> main() async {
  await initializeTestEnvironment();

  group('Hamburger navigation', () {
    testWidgets('Navigate to Household Hub from hamburger menu', (WidgetTester tester) async {
      await pumpRealApp(tester);

      await loginAs(tester, username: 'admin', password: 'Admin123%');
      await tester.pumpAndSettle();

      final menuButton = find.byIcon(Icons.menu);
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      final householdHubItem = find.text('Household Hub');
      expect(householdHubItem, findsOneWidget);
      await tester.tap(householdHubItem);
      await tester.pumpAndSettle();

      expect(find.byType(HouseholdHubScreen), findsOneWidget);
    });

    testWidgets('Navigate to Home from hamburger menu', (WidgetTester tester) async {
      await pumpRealApp(tester);

      await loginAs(tester, username: 'admin', password: 'Admin123%');
      await tester.pumpAndSettle();

      final menuButton = find.byIcon(Icons.menu);
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      final drawer = find.byType(Drawer);
      final homeItem = find.descendant(of: drawer, matching: find.text('Home'));
      expect(homeItem, findsOneWidget);
      await tester.tap(homeItem);
      await tester.pumpAndSettle();

      expect(find.byType(MainScreen), findsOneWidget);
    });

    testWidgets('Navigate to My Impact Stats from hamburger menu', (WidgetTester tester) async {
      await pumpRealApp(tester);

      await loginAs(tester, username: 'admin', password: 'Admin123%');
      await tester.pumpAndSettle();

      final menuButton = find.byIcon(Icons.menu);
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      final impactStatsItem = find.text('My Impact Stats');
      expect(impactStatsItem, findsOneWidget);
      await tester.tap(impactStatsItem);
      await tester.pumpAndSettle();

      expect(find.byType(ImpactStatsScreen), findsOneWidget);
    });

    testWidgets('Navigate to Help & Guide from hamburger menu', (WidgetTester tester) async {
      await pumpRealApp(tester);

      await loginAs(tester, username: 'admin', password: 'Admin123%');
      await tester.pumpAndSettle();

      final menuButton = find.byIcon(Icons.menu);
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      final helpGuideItem = find.text('Help & Guide');
      expect(helpGuideItem, findsOneWidget);
      await tester.tap(helpGuideItem);
      await tester.pumpAndSettle();

      expect(find.byType(HelpGuideScreen), findsOneWidget);
    });
  });
}
