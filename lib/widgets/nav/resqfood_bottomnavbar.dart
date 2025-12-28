import 'package:flutter/material.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class ResQFoodBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ResQFoodBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final highContrast = context.watch<AuthProvider>().highContrast;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      selectedItemColor: highContrast ? Colors.black : Colors.green,
      unselectedItemColor: Colors.grey.shade500,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings'
        ),
      ],
    );
  }
}
