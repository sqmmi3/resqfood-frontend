import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/notification/notification_provider.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/notifications/notifications_screen.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/screens/settings/settings_screen.dart';
import 'package:frontend/widgets/nav/resqfood_appbar.dart';
import 'package:frontend/widgets/nav/resqfood_bottomnavbar.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    SettingsScreen(),
  ];
        
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().checkUnreadStatus();
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (mounted) {
        context.read<NotificationProvider>().setUnread(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final highContrast = context.watch<AuthProvider>().highContrast;
    final isHapticsEnabled = context.watch<AuthProvider>().hapticsEnabled;
    final notificationProvider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: highContrast ? Colors.white : Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: highContrast ? Colors.black : Colors.transparent,
                width: highContrast ? 2.0 : 0,
              ),
            ),
          ),
          child: ResQFoodAppBar(
            hasUnreadNotifications: notificationProvider.hasUnread,
            onMenuTap: () {},
            onNotificationTap: () {
              notificationProvider.setUnread(false);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
            onUserTap: () {},
          ),
        )
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: highContrast ? Colors.black : Colors.grey.shade300,
              width: highContrast ? 3.0 : 1.0,
            ),
          ),
        ),
        child: ResQFoodBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            isHapticsEnabled ? HapticFeedback.lightImpact() : null;
          },
        ),
      )
    );
  }
}
