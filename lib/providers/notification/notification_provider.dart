import 'package:flutter/material.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/notification/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;
  final AuthService _authService;

  bool _hasUnread = false;
  bool get hasUnread => _hasUnread;

  NotificationProvider({
    NotificationService? notificationService,
    AuthService? authService,
  })  : _notificationService = notificationService ?? NotificationService(),
        _authService = authService ?? AuthService();

  Future<void> checkUnreadStatus() async {
    final token = await _authService.getStoredToken();
    if (token != null) {
      try {
        final count = await _notificationService.getUnreadCount(token);
        _hasUnread = count > 0;
        notifyListeners();
      } catch (e) {
        debugPrint("Error checking unread status: $e");
      }
    }
  }

  void setUnread(bool value) {
    _hasUnread = value;
    notifyListeners();
  }
}
