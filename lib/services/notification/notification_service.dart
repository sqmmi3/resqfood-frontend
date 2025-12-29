import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/models/notification_model.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final StreamController<int?> _navigationStreamController =
      StreamController<int?>.broadcast();
  static Stream<int?> get navigationStream =>
      _navigationStreamController.stream;

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static Stream<RemoteMessage> get foregroundStream =>
      FirebaseMessaging.onMessage;

  static Future<void> initialize() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('ic_notification');

      const DarwinInitializationSettings iOSInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
        iOS: iOSInit,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final int itemId = int.parse(response.payload!);
              _navigationStreamController.add(itemId);
            } catch (e) {
              debugPrint("Error parsing notification payload: $e");
            }
          }
        },
      );

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'default_channel',
        'General Notifications',
        description: 'Notification channel for app alerts',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;

        if (notification != null) {
          String? relatedId = message.data['relatedItemId'];

          _localNotifications.show(
            Random().nextInt(100000),
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'default_channel',
                'General Notification',
                importance: Importance.max,
                priority: Priority.high,
                icon: 'ic_notification',
                largeIcon: DrawableResourceAndroidBitmap('ic_notification'),
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: relatedId,
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint("📬 Notification opened: ${message.notification?.title}");

        if (message.data.containsKey('relatedItemId')) {
          final String? idStr = message.data['relatedItemId'];
          if (idStr != null) {
            _navigationStreamController.add(int.tryParse(idStr));
          }
        }
      });
    } catch (e) {
      debugPrint("Error initializing notifications: $e");
    }
  }

  static Future<String?> getDeviceToken() async {
    // If we are on iOS, return null immediately to avoid the crash.
    // (Since we don't have the Push Notification capability enabled)
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      debugPrint("🍎 Skipped getToken() on iOS (No Push Capability)");
      return null;
    }

    // On Android, this will still work fine
    return await FirebaseMessaging.instance.getToken();
  }

  // Fetch list of saved notifications from backend
  static Future<List<NotificationModel>> fetchNotifications(
    String jwtToken,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/notifications"),
        headers: {
          'Content-Type': "application/json",
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
      rethrow;
    }
  }

  // Mark notification as read
  static Future<void> markAsRead(int notificationId, String jwtToken) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark as read.');
      }
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  static Future<void> deleteNotification(
    int notificationId,
    String jwtToken,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Failed to delete notification: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint("Error deleting notification $e");
      rethrow;
    }
  }

  static Future<void> markAllAsRead(String jwtToken) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all as read');
      }
    } catch (e) {
      debugPrint("Error marking all as read: $e");
    }
  }

  static Future<int> getUnreadCount(String jwtToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: {'Authorization': 'Bearer $jwtToken'},
      );

      if (response.statusCode == 200) {
        return int.parse(response.body);
      }
      return 0;
    } catch (e) {
      debugPrint("Error fetching unread count: $e");
      return 0;
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint("Background message: ${message.notification?.title}");
}
