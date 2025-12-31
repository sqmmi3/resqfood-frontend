import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/household_details.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class HouseholdService {
  final String baseUrl;
  final http.Client _client;
  final AuthService _authService;

  HouseholdService({
    http.Client? client,
    AuthService? authService,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _authService = authService ?? AuthService(),
        baseUrl = baseUrl ?? dotenv.env['API_BASE_URL'] ?? '';

  Future<String> createHousehold() async {
    final token = await _authService.getStoredToken();

    if (token == null) {
      throw Exception("No authentication token found.");
    }

    final response = await _client.post(
      Uri.parse("$baseUrl/households/create"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['inviteCode'];
    } else {
      final error = jsonDecode(response.body)['message'] ?? "Failed to create";
      throw Exception(error);
    }
  }

  Future<void> joinHousehold(String inviteCode) async {
    final token = await _authService.getStoredToken();

    if (token == null) {
      throw Exception("No authentication token found.");
    }

    final response = await _client.post(
      Uri.parse("$baseUrl/households/join/$inviteCode"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to join household for user.");
    } else if (response.statusCode == 403 || response.statusCode == 401) {
      throw Exception("Unautorized. Please login again.");
    }
  }

  Future<void> leaveHousehold() async {
    final token = await _authService.getStoredToken();

    if (token == null) {
      throw Exception("No authentication token found.");
    }

    final response = await _client.post(
      Uri.parse("$baseUrl/households/leave"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode != 200) {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Failed to leave household");
      } catch (e) {
        throw Exception("Server Error (${response.statusCode}): could not process request.");
      }
    }
  }

  Future<HouseholdDetails> fetchMyHousehold(String token) async {
    final response = await _client.get(
      Uri.parse("$baseUrl/households/my-household"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return HouseholdDetails.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('No household joined yet.');
    } else {
      throw Exception('Failed to load household details.');
    }
  }
}