import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frontend/services/user_item/user_item_service.dart';
import 'package:frontend/models/user_item.dart';
import 'package:frontend/models/grouped_user_item.dart';

import 'user_item_provider_test.mocks.dart';

@GenerateMocks([UserItemService])

void main() {
  late UserItemProvider provider;
  late MockUserItemService mockService;

  setUp(() {
    mockService = MockUserItemService();
    provider = UserItemProvider(service: mockService);
  });

  group('UserItemProvider Tests', () {
    test('Initial state should be empty and not loading', () {
      expect(provider.items, isEmpty);
      expect(provider.loading, isFalse);
    });

    test('fetchItems success updates items and handles loading state', () async {
      final rawItems = [
        UserItem(itemName: 'Milk', type: 'Dairy', expirationDate: DateTime(2025, 1, 1)),
      ];
      final groupedItems = [
        GroupedUserItem(itemName: 'Milk', type: 'Dairy', allInstances: rawItems, amount: 1, earliestExpiration: DateTime(2025, 1, 3)),
      ];

      when(mockService.getUserItems()).thenAnswer((_) async => rawItems);
      when(mockService.groupUserItems(rawItems)).thenReturn(groupedItems);

      final future = provider.fetchItems();
      
      expect(provider.loading, isTrue);
      
      await future;

      expect(provider.items.length, 1);
      expect(provider.items[0].itemName, 'Milk');
      expect(provider.loading, isFalse);
      verify(mockService.getUserItems()).called(1);
    });

    test('deleteInstance calls service and refreshes list', () async {
      when(mockService.deleteUserItem(any)).thenAnswer((_) async => true);
      when(mockService.getUserItems()).thenAnswer((_) async => []);
      when(mockService.groupUserItems(any)).thenReturn([]);

      await provider.deleteInstance(101);

      verify(mockService.deleteUserItem(101)).called(1);
      verify(mockService.getUserItems()).called(1);
    });

    test('reset() clears the items list', () {
      provider.reset();
      
      expect(provider.items, isEmpty);
      expect(provider.loading, isFalse);
    });
  });
}