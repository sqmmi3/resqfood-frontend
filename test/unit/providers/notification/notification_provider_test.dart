import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:frontend/providers/notification/notification_provider.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/notification/notification_service.dart';

import 'notification_provider_test.mocks.dart';

@GenerateMocks([NotificationService, AuthService])
void main() {
  late NotificationProvider notificationProvider;
  late MockNotificationService mockNotif;
  late MockAuthService mockAuth;

  setUp(() {
    mockNotif = MockNotificationService();
    mockAuth = MockAuthService();

    notificationProvider = NotificationProvider(
      notificationService: mockNotif,
      authService: mockAuth,
    );
  });

  group('NotificationProvider Tests', () {
    test('Initial unread status should be false', () {
      expect(notificationProvider.hasUnread, isFalse);
    });

    test('setUnread should update the value and notify listeners', () {
      notificationProvider.setUnread(true);

      expect(notificationProvider.hasUnread, isTrue);
    });

    test('checkUnreadStatus sets hasUnread to true if count > 0', () async {
      const fakeToken = 'test_jwt_token';
      when(mockAuth.getStoredToken()).thenAnswer((_) async => fakeToken);
      when(mockNotif.getUnreadCount(fakeToken)).thenAnswer((_) async => 5);

      await notificationProvider.checkUnreadStatus();

      expect(notificationProvider.hasUnread, isTrue);
      verify(mockNotif.getUnreadCount(fakeToken)).called(1);
    });

    test('checkUnreadStatus sets hasUnread to false if count is 0', () async {
      const fakeToken = 'test_jwt_token';
      when(mockAuth.getStoredToken()).thenAnswer((_) async => fakeToken);
      when(mockNotif.getUnreadCount(fakeToken)).thenAnswer((_) async => 0);

      await notificationProvider.checkUnreadStatus();

      expect(notificationProvider.hasUnread, isFalse);
    });
  });
}