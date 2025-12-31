import 'package:flutter/material.dart';
import 'package:frontend/models/notification_model.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/screens/items/item_details_screen.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/notification/notification_service.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final token = await _authService.getStoredToken();
      if (token == null) throw Exception("Not authenticated");

      final data = await _notificationService.fetchNotifications(token);

      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _markAllReadOnExit() async {
    if (_notifications.any((n) => !n.isRead)) {
      try {
        final token = await _authService.getStoredToken();
        if (token == null) throw Exception("Not authenticated");

        _notificationService.markAllAsRead(token);
      } catch (e) {
        debugPrint("Failed to mark all read on exit: $e");
      }
    }
  }

  Future<void> _handleDelete(int index) async {
    final token = await _authService.getStoredToken();
    if (token == null) throw Exception("Not authenticated");

    final notificationToDelete = _notifications[index];

    setState(() {
      _notifications.removeAt(index);
    });

    try {
      final token = await _authService.getStoredToken();
      if (token != null) {
        await _notificationService.deleteNotification(
          notificationToDelete.id,
          token,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _notifications.insert(index, notificationToDelete);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete notification")),
        );
      }
    }
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    if (!notification.isRead) {
      setState(() {
        notification.isRead = true;
      });

      try {
        final token = await _authService.getStoredToken();
        if (token != null) {
          await _notificationService.markAsRead(notification.id, token);
        }
      } catch (e) {
        debugPrint("Failed to mark as read $e");
      }
    }
    if (notification.relatedItemId != null && mounted) {
      final int targetId = notification.relatedItemId!;

      final provider = Provider.of<UserItemProvider>(context, listen: false);

      String? foundItemName;

      try {
        for (var group in provider.items) {
          bool instanceExists = group.allInstances.any(
            (instance) => instance.id == targetId,
          );

          if (instanceExists) {
            foundItemName = group.itemName;
            break;
          }
        }
      } catch (e) {
        debugPrint("Error searching for item: $e");
      }
      if (foundItemName != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(itemName: foundItemName!),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Item not found. It may have been deleted."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _markAllReadOnExit();
        }
      },

      child: Scaffold(
        appBar: AppBar(title: const Text("Notifications"), centerTitle: true),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text("Error loading notifications"),
            TextButton(
              onPressed: _loadNotifications,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No notifications yet", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Dismissible(
            key: Key(notification.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _handleDelete(index);
            },
            child: _buildNotificationTile(notification),
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    final bool isRead = notification.isRead;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final highContrast = authProvider.highContrast;

    final Color bgColor = isRead
        ? (isDark ? theme.colorScheme.surface : Colors.grey[100]!)
        : (isDark ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15) : Colors.green[50]!);

    final FontWeight fontWeight = isRead ? FontWeight.normal : FontWeight.bold;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highContrast
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? Colors.white10 : Colors.grey[300]!),
          width: highContrast ? 2.0 : 1.0,
        ),
        boxShadow: highContrast ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => _handleNotificationTap(notification),
        leading: CircleAvatar(
          backgroundColor: isRead 
              ? (isDark ? Colors.white10 : Colors.grey[200]) 
              : theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.notifications,
            color: isRead 
                ? (isDark ? Colors.white38 : Colors.grey) 
                : theme.colorScheme.primary,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: fontWeight,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: highContrast 
                  ? (isDark ? Colors.white : Colors.black) 
                  : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(notification.timestamp),
              style: TextStyle(
                fontSize: 11, 
                color: isDark ? Colors.white38 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
