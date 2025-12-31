import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/auth/login_request.dart';

void main () {
  group('LoginRequest Model Tests', () {
    test('toJson() should return a valid Map for the API', () {
      final request = LoginRequest(
        username: 'testuser',
        password: 'Password123%'
      );

      final json = request.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['username'], 'testuser');
      expect(json['password'], 'Password123%');
    });

    test('should maintain data integrity when initialized', () {
      final request = LoginRequest(
        username: 'userA',
        password: 'passwordB'
      );

      expect(request.username, 'userA');
      expect(request.password, 'passwordB');
    });
  });
}