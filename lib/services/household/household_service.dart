import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class HouseholdService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<String> createHousehold() async {
    final token = await AuthService.getStoredToken();

    if (token == null) {
      throw Exception("No authentication token found.");
    }

    final response = await http.post(
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
    final token = await AuthService.getStoredToken();

    if (token == null) {
      throw Exception("No authentication token found.");
    }

    final response = await http.post(
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
    final token = await AuthService.getStoredToken();

    if (token == null) {
      throw Exception("No authentication token found.");
    }

    final response = await http.post(
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
}