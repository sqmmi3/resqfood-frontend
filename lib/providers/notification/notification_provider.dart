import 'package:flutter/material.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/notification/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  bool _hasUnread = false;
  bool get hasUnread => _hasUnread;

  Future<void> checkUnreadStatus() async {
    final token = await AuthService.getStoredToken();
    if (token != null) {
      final count = await NotificationService.getUnreadCount(token);
      _hasUnread = count > 0;
      notifyListeners();
    }
  }

  void setUnread(bool value) {
    _hasUnread = value;
    notifyListeners();
  }
}
