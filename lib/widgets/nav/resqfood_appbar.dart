import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class ResQFoodAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onUserTap;

  const ResQFoodAppBar({
    super.key,
    this.onMenuTap,
    this.onNotificationTap,
    this.onUserTap,
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
      elevation: highContrast ? 4 : 2,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: highContrast ? (isDarkMode ? Colors.white : Colors.black) : theme.iconTheme.color,
        onPressed: () { onMenuTap!(); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
      ),
      title: SizedBox(
        height: 60,
        child: Image.asset(
          "assets/logo/resqfood_logo_notext.png",
          fit: BoxFit.contain,
          color: isDarkMode ? null : Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () { onNotificationTap!(); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () { onUserTap!(); isHapticsEnabled ? HapticFeedback. lightImpact() : null; },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
