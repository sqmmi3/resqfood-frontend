import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/notification/notification_banner.dart';

void main() {
  group('NotificationBanner Widget Tests', () {
    late StreamController<RemoteMessage> controller;

    setUp(() {
      controller = StreamController<RemoteMessage>();
    });

    tearDown(() {
      controller.close();
    });

    testWidgets('Should show banner when stream receives a message and hide after 4s', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationBanner(streamOverride: controller.stream),
          ),
        ),
      );

      expect(find.text('Hello ResQ!'), findsNothing);

      controller.add(RemoteMessage(
        notification: const RemoteNotification(
          title: 'Hello ResQ!',
          body: 'This is a test notification',
        ),
      ));

      await tester.pump(); 
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Hello ResQ!'), findsOneWidget);
      expect(find.text('This is a test notification'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(find.text('Hello ResQ!'), findsNothing);
    });
  });
}