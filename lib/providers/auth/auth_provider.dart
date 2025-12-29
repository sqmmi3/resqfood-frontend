import 'package:flutter/material.dart';
import 'package:frontend/models/auth/login_request.dart';
import 'package:frontend/models/auth/login_response.dart';
import 'package:frontend/models/auth/register_response.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/notification/notification_service.dart';

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

  bool _isLeftHanded = false;
  bool get isLeftHanded => _isLeftHanded;

  bool _highContrast = false;
  bool get highContrast => _highContrast;

  bool _isHighVerbosity = false;
  bool get isHighVerbosity => _isHighVerbosity;

  bool _hapticsEnabled = false;
  bool get hapticsEnabled => _hapticsEnabled;

  double _fontSizeFactor = 1.0;
  double get fontSizeFactor => _fontSizeFactor;

  String? get token => _user?.token;

  void setHandedness({required bool isLeft}) {
    _isLeftHanded = isLeft;
    notifyListeners();
  }

  void setHighContrast(bool value) {
    _highContrast = value;
    notifyListeners();
  }

  void setHighVerbosity(bool value) {
    _isHighVerbosity = value;
    notifyListeners();
  }


  void setHaptics(bool value) {
    _hapticsEnabled = value;
    notifyListeners();
  }

  void setFontSize(double value) {
    _fontSizeFactor = value;
    notifyListeners();
  }

  Future<void> login(String username, String password, {VoidCallback? onSuccess}) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final loginRequest = LoginRequest(username: username, password: password);
      _user = await  _authService.login(loginRequest);
      _status = AuthStatus.authenticated;

      final fcmToken = await NotificationService.getDeviceToken();
      if (fcmToken != null) {
        try {
          await _authService.updateDeviceToken(fcmToken);
        } catch (e) {
          debugPrint("Firebase not configured on backend, skipping token sync.");
        }

        if (onSuccess != null) {
          onSuccess();
        }
      }
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

  Future<void> logout() async {
    final fcmToken = await NotificationService.getDeviceToken();
    try {
      if (fcmToken != null) {
        await _authService.removeDeviceToken(fcmToken);
      }
      await _authService.logout();
    } catch (e) {
        debugPrint("Failed to remove FCM token from backend: $e");
    }

    _user =  null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  void updateHouseholdCode(String? code) {
    if (_user != null) {
      _user = LoginResponse(
        token: _user!.token,
        username: _user!.username,
        householdCode: code,
      );
      notifyListeners();
    }
  }
}