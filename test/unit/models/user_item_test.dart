import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/user_item.dart';

void main() {
  group('UserItem Model Tests', () {
    test('fromJson should parse valid date strings correctly', () {
      final json = {
        'id': 1,
        'itemName': 'Milk',
        'type': 'Dairy',
        'expirationDate': '2025-12-31',
        'openedDate': null,
        'addedBy': 'JohnDoe'
      };

      final item = UserItem.fromJson(json);

      expect(item.itemName, 'Milk');
      expect(item.expirationDate, DateTime(2025, 12, 31));
      expect(item.addedBy, 'JohnDoe');
    });

    test('toJson should format dates as YYYY-MM-DD for the backend', () {
      final item = UserItem(
        itemName: 'Bread',
        type: 'Bakery',
        expirationDate: DateTime(2025, 12, 25, 14, 30),
      );

      final json = item.toJson();

      expect(json['expirationDate'], '2025-12-25');
    });

    test('fromJson should use default "Unknown" if addedBy is missing', () {
      final json = {
        'itemName': 'Apple',
        'type': 'Fruit',
        'expirationDate': '2025-01-01',
      };

      final item = UserItem.fromJson(json);
      expect(item.addedBy, 'Unknown');
    });
  });
}