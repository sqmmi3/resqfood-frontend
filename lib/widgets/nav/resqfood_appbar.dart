import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
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
        IconButton(
          icon: Icon(Icons.account_circle, color: highContrast ? (isDarkMode ? Colors.white : Colors.black) : theme.iconTheme.color),
          onPressed: () { onUserTap!(); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
