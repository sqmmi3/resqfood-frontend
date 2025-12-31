import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/household/household_service.dart';
import 'package:frontend/services/auth/auth_service.dart';

import 'household_service_test.mocks.dart';

@GenerateMocks([http.Client, AuthService])

void main() {
  late HouseholdService householdService;
  late MockClient mockClient;
  late MockAuthService mockAuth;

  setUp(() {
    mockClient = MockClient();
    mockAuth = MockAuthService();
    householdService = HouseholdService(
      client: mockClient,
      authService: mockAuth,
      baseUrl: 'http://localhost:8080',
    );
  });

  group('HouseholdService Tests', () {
    test('createHousehold returns inviteCode on 201 success', () async {
      when(mockAuth.getStoredToken()).thenAnswer((_) async => 'fake_token');
      when(mockClient.post(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode({'inviteCode': 'RESQ123'}), 201));

      final result = await householdService.createHousehold();

      expect(result, 'RESQ123');
      verify(mockClient.post(
        Uri.parse('http://localhost:8080/households/create'),
        headers: argThat(containsPair('Authorization', 'Bearer fake_token'), named: 'headers'),
      )).called(1);
    });

    test('joinHousehold throws Exception on non-200 status', () async {
      when(mockAuth.getStoredToken()).thenAnswer((_) async => 'fake_token');
      when(mockClient.post(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Error', 400));

      expect(() => householdService.joinHousehold('ABC'), throwsA(isA<Exception>()));
    });

    test('fetchMyHousehold returns HouseholdDetails on 200 OK', () async {
      final mockJson = {
        'inviteCode': 'TEST01',
        'members': ['Alice', 'Bob']
      };
      
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockJson), 200));

      final details = await householdService.fetchMyHousehold('fake_token');

      expect(details.inviteCode, 'TEST01');
      expect(details.members, contains('Alice'));
    });
  });
}