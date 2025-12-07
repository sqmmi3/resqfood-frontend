import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/notification/notification_service.dart';

class NotificationBanner extends StatefulWidget {
  const NotificationBanner({super.key});

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner> {
  String? _title;
  String? _body;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    NotificationService.foregroundStream.listen((RemoteMessage message) {
      setState(() {
        _title = message.notification?.title;
        _body = message.notification?.body;
      });

      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 4), () {
        setState(() {
          _title = null;
          _body = null;
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_title == null && _body == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_body != null)
                  Text(
                    _body!,
                    style: const TextStyle(color: Colors.white),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}