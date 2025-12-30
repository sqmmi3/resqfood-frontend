import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/user_item.dart';
import 'package:frontend/models/grouped_user_item.dart';

void main() {
  group('GroupedUserItem Model Tests', () {
    
    final mockDate = DateTime(2026, 1, 1);
    final mockItem1 = UserItem(id: 1, itemName: 'Milk', expirationDate: mockDate, type: 'DAIRY');
    final mockItem2 = UserItem(id: 2, itemName: 'Milk', expirationDate: mockDate.add(Duration(days: 5)), type: 'DAIRY');

    test('should initialize with correct aggregated values', () {
      final earliest = mockDate;
      final instances = [mockItem1, mockItem2];

      final groupedItem = GroupedUserItem(
        itemName: 'Milk',
        type: 'DAIRY',
        amount: 2,
        earliestExpiration: earliest,
        allInstances: instances,
        isOpen: true,
      );

      expect(groupedItem.itemName, 'Milk');
      expect(groupedItem.amount, 2);
      expect(groupedItem.earliestExpiration, earliest);
      expect(groupedItem.allInstances.length, 2);
      expect(groupedItem.isOpen, isTrue);
    });

    test('toString() should return expected formatted string', () {
      final groupedItem = GroupedUserItem(
        itemName: 'Banana',
        type: 'FRUIT',
        amount: 5,
        earliestExpiration: mockDate,
        allInstances: [],
      );

      final result = groupedItem.toString();

      expect(result, contains('name: Banana'));
      expect(result, contains('amount: 5'));
      expect(result, contains('earliestExpiration: $mockDate'));
    });

    test('should default isOpen to false when not provided', () {
      final groupedItem = GroupedUserItem(
        itemName: 'Pasta',
        type: 'PANTRY',
        amount: 1,
        earliestExpiration: mockDate,
        allInstances: [],
      );

      expect(groupedItem.isOpen, isFalse);
    });
  });
}