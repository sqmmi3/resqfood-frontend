import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';

class ResQFoodAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onUserTap;
  final bool hasUnreadNotifications;

  const ResQFoodAppBar({
    super.key,
    this.onMenuTap,
    this.onNotificationTap,
    this.onUserTap,
    this.hasUnreadNotifications = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final highContrast = authProvider.highContrast;
    final isHapticsEnabled = context.watch<AuthProvider>().hapticsEnabled;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      elevation: highContrast ? 4 : 2,
      leading: IconButton(
        icon: Icon(Icons.menu, color: highContrast ? (isDarkMode ? Colors.white : Colors.black) : theme.iconTheme.color),
        onPressed: () { onMenuTap!(); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
      ),
      title: SizedBox(
        height: 60,
        child: Image.asset(
          "assets/logo/resqfood_logo_notext.png",
          fit: BoxFit.contain,
          color: highContrast ? (isDarkMode ? Colors.white : Colors.black) : theme.colorScheme.primary,
        ),
      ),
      centerTitle: true,
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.notifications_none, color: highContrast ? (isDarkMode ? Colors.white : Colors.black) : theme.iconTheme.color),
              onPressed: () { onNotificationTap!(); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
            ),
            if (hasUnreadNotifications)
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 10,
                    minHeight: 10,
                  ),
                ),
              ),
          ],
        ),

        PopupMenuButton<String>(
          icon: Icon(
            Icons.account_circle,
            color: highContrast
                ? (isDarkMode ? Colors.white : Colors.black)
                : theme.iconTheme.color,
          ),
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: highContrast 
              ? BorderSide(color: isDarkMode ? Colors.white : Colors.black, width: 2) 
              : BorderSide.none,
          ),
          color: highContrast 
            ? (isDarkMode ? Colors.black : Colors.white) 
            : theme.colorScheme.surface,
          onSelected: (value) async {
            if (isHapticsEnabled) HapticFeedback.mediumImpact();
            
            switch (value) {
              case 'profile':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
                break;
              case 'logout':
                context.read<UserItemProvider>().reset();
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            _buildPopupItem(
              value: 'profile',
              icon: Icons.person_outline,
              text: "My Profile",
              highContrast: highContrast,
              isDarkMode: isDarkMode,
            ),
            const PopupMenuDivider(),
            _buildPopupItem(
              value: 'logout',
              icon: Icons.logout,
              text: "Logout",
              color: Colors.red,
              highContrast: highContrast,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem({
  required String value,
  required IconData icon,
  required String text,
  required bool highContrast,
  required bool isDarkMode,
  Color? color,
  }) {
    final contentColor = color ?? (highContrast ? (isDarkMode ? Colors.white : Colors.black) : null);
    
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: contentColor, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: contentColor,
              fontWeight: highContrast ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
