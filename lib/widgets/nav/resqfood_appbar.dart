import 'package:flutter/material.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 2,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuTap,
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
          onPressed: onNotificationTap,
        ),
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: onUserTap,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
