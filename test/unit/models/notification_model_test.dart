import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/notification_model.dart';

void main() {
  group('NotificationModel Tests', () {
    
    test('fromJson() should correctly parse all fields including DateTime', () {
      final json = {
        'id': 10,
        'title': 'Milk Expiring',
        'message': 'Your milk expires in 2 days!',
        'timestamp': '2025-12-30T10:00:00Z',
        'isRead': false,
        'relatedItemId': 50
      };

      final notification = NotificationModel.fromJson(json);

      expect(notification.id, 10);
      expect(notification.title, 'Milk Expiring');
      expect(notification.isRead, isFalse);
      expect(notification.relatedItemId, 50);
      expect(notification.timestamp.year, 2025);
    });

    test('fromJson() should default isRead to false if missing in JSON', () {
      final json = {
        'id': 11,
        'title': 'New Feature',
        'message': 'Check out the new scanner!',
        'timestamp': '2025-12-30T12:00:00Z',
      };

      final notification = NotificationModel.fromJson(json);

      expect(notification.isRead, isFalse);
    });

    test('should allow toggling the isRead status', () {
      final notification = NotificationModel(
        id: 1,
        title: 'T',
        message: 'M',
        timestamp: DateTime.now(),
        isRead: false,
      );

      notification.isRead = true;

      expect(notification.isRead, isTrue);
    });
  });
}