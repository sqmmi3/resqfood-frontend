import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/auth/login_response.dart';

void main() {
  group('LoginResponse Model Tests', () {
    
    test('fromJson() should create a valid LoginResponse with all fields', () {
      final json = {
        'token': 'eyJhbGciOiJIUzI1NiJ9...',
        'username': 'ResQUser',
        'householdCode': 'JOIN12'
      };

      final response = LoginResponse.fromJson(json);

      expect(response.token, 'eyJhbGciOiJIUzI1NiJ9...');
      expect(response.username, 'ResQUser');
      expect(response.householdCode, 'JOIN12');
    });

    test('fromJson() should handle a null householdCode gracefully', () {
      final json = {
        'token': 'abc-123',
        'username': 'SoloUser',
        'householdCode': null
      };

      final response = LoginResponse.fromJson(json);

      expect(response.householdCode, isNull);
      expect(response.username, 'SoloUser');
    });

    test('fromJson() should provide empty string default if username is missing', () {
      final json = {
        'token': 'abc-123',
        'username': null,
        'householdCode': null
      };

      final response = LoginResponse.fromJson(json);

      expect(response.username, '');
    });
  });
}