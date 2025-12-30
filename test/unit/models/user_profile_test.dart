import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/user_profile.dart';

void main() {
  group('UserProfile Model Tests', () {
    
    test('fromJson() should correctly parse user statistics and info', () {
      final json = {
        'username': 'EcoWarrior',
        'email': 'eco@ucll.be',
        'householdCode': 'RESQ88',
        'memberSince': '2023-05-12',
        'itemsRescued': 150,
        'itemsExpired': 12
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.username, 'EcoWarrior');
      expect(profile.email, 'eco@ucll.be');
      expect(profile.itemsRescued, 150);
      expect(profile.itemsExpired, 12);
      expect(profile.householdCode, 'RESQ88');
    });

    test('should handle zero values for statistics', () {
      final json = {
        'username': 'Newbie',
        'email': 'new@test.com',
        'householdCode': 'NONE',
        'memberSince': '2025-12-30',
        'itemsRescued': 0,
        'itemsExpired': 0
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.itemsRescued, 0);
      expect(profile.itemsExpired, 0);
    });
  });
}