import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/widgets/nav/resqfood_appbar.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'resqfood_appbar_test.mocks.dart';

@GenerateMocks([AuthProvider, UserItemProvider])

void main() {
  late MockAuthProvider mockAuth;
  late MockUserItemProvider mockUserItem;

  setUp(() {
    mockAuth = MockAuthProvider();
    mockUserItem = MockUserItemProvider();

    when(mockAuth.highContrast).thenReturn(false);
    when(mockAuth.hapticsEnabled).thenReturn(false);
  });

  Widget createWidgetUnderTest({bool hasUnread = false}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
        ChangeNotifierProvider<UserItemProvider>.value(value: mockUserItem),
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: ResQFoodAppBar(
            hasUnreadNotifications: hasUnread,
            onMenuTap: () {},
            onNotificationTap: () {},
            onUserTap: () {},
          ),
        ),
      ),
    );
  }

  group('ResQFoodAppBar Widget Tests', () {
    testWidgets('Should display the logo and notification icon', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(Image), findsOneWidget); // The logo
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
      expect(find.byIcon(Icons.account_circle), findsOneWidget);
    });

    testWidgets('Should show red dot when hasUnreadNotifications is true', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(hasUnread: true));

      final badgeFinder = find.byType(Container);
      bool foundRedBadge = false;

      for (var element in tester.widgetList<Container>(badgeFinder)) {
        if (element.decoration is BoxDecoration) {
          final decoration = element.decoration as BoxDecoration;
          if (decoration.color == Colors.red) {
            foundRedBadge = true;
          }
        }
      }

      expect(foundRedBadge, isTrue, reason: "Red notification badge should be visible");
    });

    testWidgets('Should open popup menu and show Logout option when account icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('Should trigger logout sequence when logout is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      verify(mockUserItem.reset()).called(1);
      verify(mockAuth.logout()).called(1);
    });
  });
}