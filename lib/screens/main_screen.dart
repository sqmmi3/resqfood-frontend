import 'package:flutter/material.dart';
import 'package:frontend/providers/notification/notification_provider.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/notifications/notifications_screen.dart';
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

  final List<Widget> _screens = [HomeScreen()];

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: ResQFoodAppBar(
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
      body: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: ResQFoodBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
