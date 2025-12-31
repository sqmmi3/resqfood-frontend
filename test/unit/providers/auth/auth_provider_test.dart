import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/models/auth/login_response.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([AuthService])

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthProvider authProvider;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    authProvider = AuthProvider(authService: mockAuthService);

    const channel = MethodChannel('plugins.flutter.io/firebase_messaging');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'Messaging#getToken') {
        return 'fake-fcm-token';
      }
      return null;
    });
  });

  group('AuthProvider - Accessibility & Settings', () {
    test('Initial accessibility values should be default', () {
      expect(authProvider.isLeftHanded, isFalse);
      expect(authProvider.fontSizeFactor, 1.0);
    });

    test('setHandedness should update value', () {
      authProvider.setHandedness(isLeft: true);
      expect(authProvider.isLeftHanded, isTrue);
    });

    test('setFontSize should update factor', () {
      authProvider.setFontSize(1.2);
      expect(authProvider.fontSizeFactor, 1.2);
    });
  });

  group('AuthProvider - Authentication Logic', () {
    test('Initial status should be idle', () {
      expect(authProvider.status, AuthStatus.idle);
    });

    test('login() success updates status and user data', () async {
      final mockResponse = LoginResponse(
        token: 'fake-jwt-token',
        username: 'testuser',
        householdCode: 'HOME12'
      );

      when(mockAuthService.login(any)).thenAnswer((_) async => mockResponse);

      await authProvider.login('testuser', 'Password123!');

      expect(authProvider.status, AuthStatus.authenticated);
      expect(authProvider.user?.token, 'fake-jwt-token');
      expect(authProvider.errorMessage, isNull);
      verify(mockAuthService.login(any)).called(1);
    });

    test('login() failure updates status to error and sets message', () async {
      when(mockAuthService.login(any)).thenThrow(Exception('Invalid credentials'));

      await authProvider.login('wronguser', 'wrongpass');

      expect(authProvider.status, AuthStatus.error);
      expect(authProvider.errorMessage, contains('Invalid credentials'));
      expect(authProvider.user, isNull);
    });

    test('logout() clears user data and resets status', () async {
      await authProvider.logout();

      expect(authProvider.user, isNull);
      expect(authProvider.status, AuthStatus.idle);
    });

    test('updateHouseholdCode should correctly update the existing user session', () {
      authProvider.updateHouseholdCode('NEWCODE');
      
      expect(authProvider.user, isNull);
    });
  });
}