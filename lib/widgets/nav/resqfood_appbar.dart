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
    final isHapticsEnabled = context.watch<AuthProvider>().hapticsEnabled;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black),
        onPressed: () { onMenuTap!(); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
      ),
      title: SizedBox(
        height: 80,
        child: Image.asset(
          "assets/logo/resqfood_logo_notext.png",
          fit: BoxFit.contain,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () { onNotificationTap!(); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.black),
          onPressed: () { onUserTap!(); isHapticsEnabled ? HapticFeedback. lightImpact() : null; },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
