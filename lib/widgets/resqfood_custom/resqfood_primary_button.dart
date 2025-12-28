import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class ResQFoodPrimaryButton extends StatelessWidget {
  final String text;
  final bool disabled;
  final VoidCallback? onPressed;

  const ResQFoodPrimaryButton({
    super.key,
    required this.text,
    this.disabled = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final highContrast = context.watch<AuthProvider>().highContrast;
    final isHapticsEnabled = context.watch<AuthProvider>().hapticsEnabled;

    return SizedBox(
      height: 58,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () { disabled ? null : onPressed?.call(); isHapticsEnabled ? HapticFeedback.mediumImpact() : null; },
        style: ElevatedButton.styleFrom(
          foregroundColor: _getForegroundColor(disabled, highContrast),
          backgroundColor: _getBackgroundColor(disabled, highContrast),
          side: highContrast && !disabled
            ? const BorderSide(color: Colors.black, width: 3)
            : BorderSide.none,
          padding: EdgeInsets.all(16),
          elevation: highContrast? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(highContrast ? 8 : 15)
          )
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: highContrast ? 18 : 16, letterSpacing: highContrast ? 1.2 : 0.5),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool disabled, bool highContrast) {
    if (disabled) return Colors.grey.shade400;
    if (highContrast) return Colors.white;
    return Colors.green;
  }

  Color _getForegroundColor(bool disabled, bool highContrast) {
    if (disabled) return Colors.white;
    if (highContrast) return Colors.black;
    return Colors.white;
  }
}