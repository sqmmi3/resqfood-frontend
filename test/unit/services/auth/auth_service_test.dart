import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/models/auth/login_request.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])

void main() {
  late AuthService authService;
  late MockClient mockClient;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockClient = MockClient();
    mockStorage = MockFlutterSecureStorage();
    authService = AuthService(client: mockClient, storage: mockStorage, baseUrl: 'http://localhost:8080');
  });

  group('AuthService - Authentication', () {
    test('login success should save token and return response', () async {
      final request = LoginRequest(username: 'test', password: 'password');
      final responseBody = jsonEncode({'token': 'fake_jwt', 'username': 'test'});
      
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await authService.login(request);

      expect(result.token, 'fake_jwt');
      verify(mockStorage.write(key: 'auth_token', value: 'fake_jwt')).called(1);
    });

    test('login failure should throw exception', () async {
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Unauthorized', 401));

      expect(() => authService.login(LoginRequest(username: 'a', password: 'b')), 
             throwsA(isA<Exception>()));
    });

    test('logout should delete token from storage', () async {
      await authService.logout();

      verify(mockStorage.delete(key: 'auth_token')).called(1);
    });
  });

  group('AuthService - Device Tokens', () {
    test('updateDeviceToken should throw error if no JWT is stored', () async {
      expect(() => authService.updateDeviceToken('fcm_123'), 
             throwsA(predicate((e) => e.toString().contains('user not logged in'))));
    });
  });
}