import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/auth/login_request.dart';
import 'package:frontend/models/auth/login_response.dart';
import 'package:frontend/models/auth/register_response.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  String? _storedJwt;

  void setJWT(String token) {
    _storedJwt = token;
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
      setJWT(loginResponse.token);
      return loginResponse;
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

  Future<void> updateDeviceToken(String token, {String deviceName = 'unknown'}) async {
    if (_storedJwt == null) {
      throw Exception('Cannot update device token: user not logged in');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/users/device-token'),
      headers: {
        'Authorization': 'Bearer $_storedJwt',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'token': token, 'deviceName': deviceName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update device token');
    } else {
      debugPrint('✅ FCM token successfully sent to back-end.');
    }
  }

  Future<void> removeDeviceToken(String token) async {
    if (_storedJwt == null) {
      throw Exception('Cannot remove device token: user not logged in');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/users/device-token'),
      headers: {
        'Authorization': 'Bearer $_storedJwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove device token');
    } else {
      debugPrint('✅ FCM token sucessfully removed from backend.');
    }
  }
}