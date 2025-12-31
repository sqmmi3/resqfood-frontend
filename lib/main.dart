import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/providers/notification/notification_provider.dart';
import 'package:frontend/providers/theme/theme_provider.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/notification/notification_service.dart';
import 'package:frontend/services/user_item/product_service.dart';
import 'package:frontend/theme/app_theme.dart';
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

  final geminiModel = FirebaseAI
      .googleAI()
      .generativeModel(
        model: 'gemini-2.5-flash',
        systemInstruction: Content.system(
          "You are a professional food inventory system. Your only job is to categorize grocery items into a specific 13-category taxonomy. You never provide explanations, only the single-word category name."
        ),
      );

  runApp(
    MultiProvider(
      providers: [
        Provider<ProductService>(create: (_) => ProductService(geminiModel)),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserItemProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const ResQFoodApp(),
    ),
  );
}

class ResQFoodApp extends StatelessWidget {
  const ResQFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeMode = context.watch<ThemeProvider>().themeMode;

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) {
          return Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.user == null) {
                return const LoginScreen();
              }
              return const MainScreen();
            },
          );
        },
      },
      showSemanticsDebugger: false,
      title: 'ResQFood',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      navigatorKey: navigatorKey,
      builder: (context, child) {
        final isLoading = context.watch<UserItemProvider>().loading;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(authProvider.fontSizeFactor),
          ),
          child: Stack(
            children: [
              child!,
              const NotificationBanner(),
              if (isLoading)
                Container(
                  color: authProvider.highContrast 
                      ? Colors.black.withValues(alpha: 0.7) 
                      : Colors.black26,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: authProvider.highContrast ? Colors.white : Colors.green, 
                      strokeWidth: authProvider.highContrast ? 6 : 4
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}