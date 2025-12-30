import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/household_details.dart';

void main() {
  group('HouseholdDetails Model Tests', () {
    
    test('fromJson() should correctly parse invite code and member list', () {
      final json = {
        'inviteCode': 'RESQ01',
        'members': ['JohnDoe', 'JaneDoe', 'BobScanner']
      };

      final details = HouseholdDetails.fromJson(json);

      expect(details.inviteCode, 'RESQ01');
      expect(details.members.length, 3);
      expect(details.members, containsAll(['JohnDoe', 'JaneDoe', 'BobScanner']));
      expect(details.members[0], isA<String>());
    });

    test('fromJson() should handle an empty member list', () {
      final json = {
        'inviteCode': 'EMPTY1',
        'members': []
      };

      final details = HouseholdDetails.fromJson(json);

      expect(details.members, isEmpty);
      expect(details.inviteCode, 'EMPTY1');
    });

    test('should throw an error if members is not a list', () {
      final json = {
        'inviteCode': 'ERROR1',
        'members': 'NotAList'
      };

      expect(() => HouseholdDetails.fromJson(json), throwsA(isA<TypeError>()));
    });
  });
}