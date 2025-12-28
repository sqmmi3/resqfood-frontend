import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/providers/notification/notification_provider.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/notification/notification_service.dart';
import 'package:frontend/widgets/notification/notification_banner.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationService.initialize();

  final AuthService authService = AuthService();

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await authService.updateDeviceToken(newToken);
  });

  final token = await NotificationService.getDeviceToken();
  debugPrint("FCM TOKEN: $token");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserItemProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const ResQFoodApp(),
    ),
  );
}

class ResQFoodApp extends StatelessWidget {
  const ResQFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQFood',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      builder: (context, child) {
        final isLoading = context.watch<UserItemProvider>().loading;
        return Stack(
          children: [
            child!,
            const NotificationBanner(),
            if (isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              ),
          ],
        );
      },
      home: const LoginScreen(),
    );
  }
}
