import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/grouped_user_item.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/widgets/user_item/user_item_bar.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'user_item_bar_test.mocks.dart';

@GenerateMocks([AuthProvider, NavigatorObserver])
void main() {
  late MockAuthProvider mockAuth;
  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockAuth = MockAuthProvider();
    mockObserver = MockNavigatorObserver();
    
    // Default mock behavior
    when(mockAuth.highContrast).thenReturn(false);
    when(mockAuth.isHighVerbosity).thenReturn(false);
    when(mockObserver.navigator).thenReturn(null);
  });

  Widget createWidgetUnderTest(GroupedUserItem item) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: mockAuth,
      child: MaterialApp(
        navigatorObservers: [mockObserver],
        home: Scaffold(
          body: UserItemBar(groupedItem: item),
        ),
      ),
    );
  }

  group('UserItemBar Widget Tests', () {
    final futureDate = DateTime.now().add(const Duration(days: 10));
    final expiredDate = DateTime.now().subtract(const Duration(days: 2));

    testWidgets('Should display item name and quantity correctly', (WidgetTester tester) async {
      final item = GroupedUserItem(
        itemName: 'Organic Bananas',
        amount: 3,
        earliestExpiration: futureDate,
        isOpen: false,
        type: 'Fruit',
        allInstances: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(item));

      expect(find.text('Organic Bananas'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('Should show "Opened" label when item is open', (WidgetTester tester) async {
      final item = GroupedUserItem(
        itemName: 'Milk',
        amount: 1,
        earliestExpiration: futureDate,
        isOpen: true,
        type: 'Dairy',
        allInstances: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(item));

      expect(find.text('Opened'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);
    });

    testWidgets('Should display red text for expired items', (WidgetTester tester) async {
      final item = GroupedUserItem(
        itemName: 'Old Eggs',
        amount: 1,
        earliestExpiration: expiredDate,
        isOpen: false,
        type: 'Dairy',
        allInstances: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(item));

      final Text dateText = tester.widget(find.textContaining('202'));
      expect(dateText.style?.color, Colors.red);
    });

    testWidgets('Should use high verbosity semantic label when enabled', (WidgetTester tester) async {
      when(mockAuth.isHighVerbosity).thenReturn(true);
      
      final item = GroupedUserItem(
        itemName: 'Bread',
        amount: 2,
        earliestExpiration: futureDate,
        isOpen: true,
        type: 'Grain',
        allInstances: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(item));

      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && 
                    widget.properties.label?.contains('Bread') == true
      );

      expect(semanticsFinder, findsOneWidget);

      final Semantics semantics = tester.widget(semanticsFinder);
      
      expect(semantics.properties.label, contains('Food item: Bread.'));
      expect(semantics.properties.label, contains('Status: Expires in'));
      expect(semantics.properties.label, contains('Note: This package is already opened.'));
    });

    testWidgets('Should show status icons in High Contrast mode', (WidgetTester tester) async {
      when(mockAuth.highContrast).thenReturn(true);
      
      final item = GroupedUserItem(
        itemName: 'Yogurt',
        amount: 1,
        earliestExpiration: expiredDate,
        isOpen: false,
        type: 'Dairy',
        allInstances: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(item));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}