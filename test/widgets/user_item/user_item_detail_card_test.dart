import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/user_item.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/widgets/user_item/user_item_detail_card.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'user_item_detail_card_test.mocks.dart';

@GenerateMocks([AuthProvider])
void main() {
  late MockAuthProvider mockAuth;

  setUp(() {
    mockAuth = MockAuthProvider();
    when(mockAuth.highContrast).thenReturn(false);
    when(mockAuth.hapticsEnabled).thenReturn(false);
  });

  Widget createWidgetUnderTest({
    required UserItem userItem,
    required int index,
    required VoidCallback onDelete,
  }) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuth,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: UserItemDetailCard(
              userItem: userItem,
              index: index,
              onDelete: onDelete,
            ),
          ),
        ),
      ),
    );
  }

  group('UserItemDetailCard Widget Tests', () {
    final testDate = DateTime(2025, 12, 30);

    testWidgets('Should display item name with index correctly', (WidgetTester tester) async {
      final item = UserItem(
        id: 1,
        itemName: 'Milk',
        type: 'Dairy',
        expirationDate: testDate,
      );

      await tester.pumpWidget(createWidgetUnderTest(
        userItem: item,
        index: 1,
        onDelete: () {},
      ));

      expect(find.text('Milk #1'), findsOneWidget);
    });

    testWidgets('Should show "Unopened" when openedDate is null', (WidgetTester tester) async {
      final item = UserItem(
        id: 1,
        itemName: 'Milk',
        type: 'Dairy',
        expirationDate: testDate,
        openedDate: null,
      );

      await tester.pumpWidget(createWidgetUnderTest(
        userItem: item,
        index: 1,
        onDelete: () {},
      ));

      expect(find.text('Unopened'), findsOneWidget);
    });

    testWidgets('Should display description and character count correctly', (WidgetTester tester) async {
      final item = UserItem(
        id: 1,
        itemName: 'Milk',
        type: 'Dairy',
        expirationDate: testDate,
        description: 'Store in the back of the fridge',
      );

      await tester.pumpWidget(createWidgetUnderTest(
        userItem: item,
        index: 1,
        onDelete: () {},
      ));

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Store in the back of the fridge'), findsOneWidget);

      expect(find.textContaining('31/128'), findsOneWidget);
    });

    testWidgets('Should trigger onDelete callback when Remove button is pressed', (WidgetTester tester) async {
      bool deleteTriggered = false;
      final item = UserItem(
        id: 1,
        itemName: 'Milk',
        type: 'Dairy',
        expirationDate: testDate,
      );

      await tester.pumpWidget(createWidgetUnderTest(
        userItem: item,
        index: 1,
        onDelete: () => deleteTriggered = true,
      ));

      await tester.tap(find.text('Remove this instance'));
      await tester.pump();

      expect(deleteTriggered, isTrue);
    });

    testWidgets('Should apply high contrast border and bold text', (WidgetTester tester) async {
      when(mockAuth.highContrast).thenReturn(true);

      final item = UserItem(
        id: 1,
        itemName: 'Milk',
        type: 'Dairy',
        expirationDate: testDate,
      );

      await tester.pumpWidget(createWidgetUnderTest(
        userItem: item,
        index: 1,
        onDelete: () {},
      ));

      final containerFinder = find.byType(Container).last;
      final Container container = tester.widget(containerFinder);
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      
      expect(decoration.border?.top.width, 3.0);
      
      final Text titleText = tester.widget(find.text('Milk #1'));
      expect(titleText.style?.fontWeight, FontWeight.bold);
      expect(titleText.style?.fontSize, 20);
    });
  });
}