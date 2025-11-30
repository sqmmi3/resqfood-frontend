import 'package:flutter/material.dart';
import 'package:frontend/models/auth/login_request.dart';
import 'package:frontend/models/auth/login_response.dart';
import 'package:frontend/models/auth/register_response.dart';
import 'package:frontend/services/auth/auth_service.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.idle;
  AuthStatus get status => _status;

  LoginResponse? _user;
  LoginResponse? get user => _user;

  RegisterResponse? _newUser;
  RegisterResponse? get newUser => _newUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> login(String username, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final loginRequest = LoginRequest(username: username, password: password);
      _user = await  _authService.login(loginRequest);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
    }

    notifyListeners();
  }

  Future<RegisterResponse?> register(String username, String email, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final response = await _authService.register(username, email, password);

      _newUser = response;
      _status = AuthStatus.idle;
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      return null;
    } finally {
      notifyListeners();
    }
  }

  void logout() {
    _user =  null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}