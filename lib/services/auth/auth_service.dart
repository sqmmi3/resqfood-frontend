import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/auth/login_request.dart';
import 'package:frontend/models/auth/login_response.dart';
import 'package:frontend/models/auth/register_response.dart';
import 'package:http/http.dart' as http;

class AuthService {
  late final String baseUrl;

  AuthService() {
    // Use default URL for web, or load from .env for mobile/desktop
    if (kIsWeb) {
      baseUrl = 'http://localhost:8080';
    } else {
      baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw response.body;
    }
  }

  Future<RegisterResponse> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return RegisterResponse.fromJson(jsonDecode(response.body));
    } else {
      throw response.body;
    }
  }
}