import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/user_item/user_item_service.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/models/user_item.dart';

import 'user_item_service_test.mocks.dart';

@GenerateMocks([http.Client, AuthService])

void main() {
  late UserItemService service;
  late MockClient mockClient;
  late MockAuthService mockAuth;

  setUp(() {
    mockClient = MockClient();
    mockAuth = MockAuthService();
    service = UserItemService(
      client: mockClient,
      authService: mockAuth,
      baseUrl: 'http://localhost:8080',
    );
  });

  group('UserItemService - Grouping & Expiration Logic', () {
    test('groupUserItems correctly groups items by name', () {
      final items = [
        UserItem(id: 1, itemName: 'Milk', type: 'Dairy', expirationDate: DateTime(2025, 12, 30)),
        UserItem(id: 2, itemName: 'Milk', type: 'Dairy', expirationDate: DateTime(2025, 12, 28)),
        UserItem(id: 3, itemName: 'Eggs', type: 'Dairy', expirationDate: DateTime(2025, 12, 25)),
      ];

      final result = service.groupUserItems(items);

      expect(result.length, 2);
      expect(result.firstWhere((g) => g.itemName == 'Eggs').amount, 1);
      expect(result.firstWhere((g) => g.itemName == 'Milk').amount, 2);
    });

    test('Expiration calculation: Uses Opened Rule if it is sooner than Expiration', () {
      final items = [
        UserItem(
          id: 1,
          itemName: 'Milk',
          type: 'Dairy',
          expirationDate: DateTime(2025, 12, 30),
          openedDate: DateTime(2025, 12, 1),
          openedRule: 7,
        ),
      ];

      final grouped = service.groupUserItems(items);
      
      expect(grouped.first.earliestExpiration, DateTime(2025, 12, 8));
    });

    test('Expiration calculation: Uses original Expiration if Rule is later', () {
      final items = [
        UserItem(
          id: 1,
          itemName: 'Yogurt',
          type: 'Dairy',
          expirationDate: DateTime(2025, 12, 5),
          openedDate: DateTime(2025, 12, 1),
          openedRule: 14,
        ),
      ];

      final grouped = service.groupUserItems(items);
      
      expect(grouped.first.earliestExpiration, DateTime(2025, 12, 5));
    });
  });
}