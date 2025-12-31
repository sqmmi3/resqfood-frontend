import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/auth/register_response.dart';

void main() {
  group('RegisterResponse Model Tests', () {
    
    test('fromJson() should correctly map JSON values to model fields', () {
      final json = {
        'id': 42,
        'username': 'GreenHero',
        'email': 'hero@ucll.be'
      };

      final response = RegisterResponse.fromJson(json);

      expect(response.id, 42);
      expect(response.username, 'GreenHero');
      expect(response.email, 'hero@ucll.be');
    });

    test('toJson() should create a Map that matches the original data', () {
      final response = RegisterResponse(
        id: 1, 
        username: 'testuser', 
        email: 'test@test.com'
      );

      final json = response.toJson();

      expect(json['id'], 1);
      expect(json['username'], 'testuser');
      expect(json['email'], 'test@test.com');
    });

    test('should throw an error if JSON types are mismatched (Type Safety)', () {
      final json = {
        'id': 'not-an-int', 
        'username': 'test', 
        'email': 'test@test.com'
      };

      expect(() => RegisterResponse.fromJson(json), throwsA(isA<TypeError>()));
    });
  });
}