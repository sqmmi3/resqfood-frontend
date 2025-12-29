import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/screens/menu/help_guide_screen.dart';
import 'package:frontend/screens/menu/household_hub_screen.dart';
import 'package:provider/provider.dart';

class ResQFoodDrawer extends StatelessWidget {
  const ResQFoodDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final highContrast = authProvider.highContrast;
    final isHapticsEnabled = authProvider.hapticsEnabled;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color contrastColor = isDark ? Colors.white : Colors.black;
    
    TextStyle menuTextStyle = TextStyle(
      fontWeight: highContrast ? FontWeight.bold : FontWeight.w500,
      fontSize: 16,
      color: highContrast ? contrastColor : null,
    );

    return Drawer(
      backgroundColor: highContrast 
          ? (isDark ? Colors.black : Colors.white) 
          : theme.colorScheme.surface,
      shape: highContrast 
          ? Border(right: BorderSide(color: contrastColor, width: 3)) 
          : const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          _buildHeader(context, highContrast, isDark),

          _buildDrawerTile(
            context,
            icon: Icons.home_work_rounded,
            title: "Household Hub",
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const HouseholdHubScreen()),
              );
            },
            style: menuTextStyle,
            isHapticsEnabled: isHapticsEnabled,
          ),

          _buildDrawerTile(
            context,
            icon: Icons.bar_chart_rounded,
            title: "My Impact Stats",
            onTap: () {
            },
            style: menuTextStyle,
            isHapticsEnabled: isHapticsEnabled,
          ),

          const Divider(),

          _buildDrawerTile(
            context,
            icon: Icons.help_outline_rounded,
            title: "Help & Guide",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpGuideScreen()),
              );
            },
            style: menuTextStyle,
            isHapticsEnabled: isHapticsEnabled,
          ),

          const Spacer(),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "ResQFood v0.0.1",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool highContrast, bool isDark) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: highContrast ? (isDark ? Colors.black : Colors.white) : Colors.green.shade600,
        border: highContrast 
          ? Border(bottom: BorderSide(color: isDark ? Colors.white : Colors.black, width: 2)) 
          : null,
      ),
      child: Center(
        child: Image.asset(
          "assets/logo/resqfood_logo_notext.png",
          color: highContrast ? (isDark ? Colors.white : Colors.black) : Colors.white,
          height: 80,
        ),
      ),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required TextStyle style,
    required bool isHapticsEnabled,
  }) {
    return ListTile(
      leading: Icon(icon, color: style.color),
      title: Text(title, style: style),
      onTap: () {
        if (isHapticsEnabled) HapticFeedback.lightImpact();
        Navigator.pop(context);
        onTap();
      },
    );
  }
}