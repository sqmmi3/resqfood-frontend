import 'package:flutter/material.dart';

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
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black),
        onPressed: onMenuTap,
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
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: onNotificationTap,
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
          icon: const Icon(Icons.account_circle, color: Colors.black),
          onPressed: onUserTap,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
