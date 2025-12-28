import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class ResQFoodSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ResQFoodSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final highContrast = context.watch<AuthProvider>().highContrast;
    final isHapticsEnabled = context.watch<AuthProvider>().hapticsEnabled;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 58,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          onPressed();
          if (isHapticsEnabled) HapticFeedback.mediumImpact();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: highContrast ? (isDark ? Colors.white : Colors.black) : theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(highContrast ? 8 : 15),
          ),
          side: BorderSide(
            color: highContrast ? (isDark ? Colors.white : Colors.black) : theme.colorScheme.primary, 
            width: highContrast ? 3.0 : 2.0
          ),
          padding: const EdgeInsets.all(16),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: highContrast ? 18 : 16,
            letterSpacing: highContrast ? 1.2 : 0.5,
          ),
        ),
      ),
    );
  }
}