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
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo/resqfood_logo_notext.png',
                  width: 64,
                  height: 64,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _title ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (_body != null)
                        Text(
                          _body!,
                          style: const TextStyle(color: Colors.black),
                        )
                    ],
                  ),
                )
              ],
            ) 
          ),
        ),
      ),
    );
  }
}