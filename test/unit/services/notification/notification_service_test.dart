import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/notification/notification_service.dart';
import 'package:frontend/models/notification_model.dart';

import 'notification_service_test.mocks.dart';

@GenerateMocks([http.Client])

void main() {
  late NotificationService service;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    service = NotificationService(
      client: mockClient, 
      baseUrl: 'http://localhost:8080',
    );
  });

  group('NotificationService API Unit Tests', () {
    
    test('fetchNotifications returns a list of models on 200 OK', () async {
      final mockResponse = [
        {
          'id': 1,
          'title': 'Milk Expiring',
          'message': 'Your milk expires tomorrow!',
          'timestamp': '2025-12-30T10:00:00Z',
          'isRead': false,
        }
      ];

      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await service.fetchNotifications('fake_jwt');

      expect(result, isA<List<NotificationModel>>());
      expect(result.length, 1);
      expect(result.first.title, 'Milk Expiring');
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('getUnreadCount returns correct integer on 200 OK', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('5', 200));

      final count = await service.getUnreadCount('fake_jwt');

      expect(count, 5);
    });

    test('markAsRead sends a PUT request to the correct URL', () async {
      when(mockClient.put(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('', 200));

      await service.markAsRead(123, 'fake_jwt');

      verify(mockClient.put(
        Uri.parse('http://localhost:8080/notifications/123/read'),
        headers: anyNamed('headers'),
      )).called(1);
    });
  });
}