import 'package:flutter/material.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class HelpGuideScreen extends StatelessWidget {
  const HelpGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final highContrast = context.watch<AuthProvider>().highContrast;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Help & Guide", 
          style: TextStyle(color: highContrast ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white70 : Colors.black54))), 
          backgroundColor: highContrast ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.black26 : Colors.white70
        ),
        iconTheme: IconThemeData(
          color: highContrast 
              ? (isDark ? Colors.white : Colors.black) 
              : (isDark ? Colors.white70 : Colors.black54),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpTile("What is the 'Opened Rule'?", 
              "When you open an item, the shelf life changes. ResQFood automatically recalculates the new expiry date based on the rule you set."),
          _buildHelpTile("How do Households work?", 
              "By sharing an invite code, multiple users can manage the same inventory. Everyone sees the same inventory in real-time."),
          _buildHelpTile("Notification Settings", 
              "You will receive push notifications 3, 5, and 7 days before an item expires, and on the day of expiry."),
        ],
      ),
    );
  }

  Widget _buildHelpTile(String title, String description) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(description),
        )
      ],
    );
  }
}