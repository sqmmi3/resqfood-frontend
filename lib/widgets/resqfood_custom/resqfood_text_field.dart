import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class ResQFoodTextField extends StatelessWidget{
  final String label;
  final String? defaultValue;
  final bool obscure;
  final bool showToggle;
  final bool obscureValue;
  final VoidCallback? onToggle;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const ResQFoodTextField({
    super.key,
    required this.label,
    this.defaultValue,
    this.obscure = false,
    this.showToggle = false,
    this.obscureValue = false,
    this.onToggle,
    this.controller,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final highContrast = context.watch<AuthProvider>().highContrast;
    final isHapticsEnabled = context.watch<AuthProvider>().hapticsEnabled;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscure && obscureValue,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: () { onTap!(); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
      cursorColor: highContrast ? (theme.brightness == Brightness.dark ? Colors.white : Colors.black) : colorScheme.primary,
      style: TextStyle(
        fontWeight: highContrast ? FontWeight.bold : FontWeight.normal,
        fontSize: 16,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: (defaultValue != null && defaultValue!.isNotEmpty)
          ? defaultValue
          : "Enter $label",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: TextStyle(color: highContrast ? (theme.brightness == Brightness.dark ? Colors.white :Colors.black) : colorScheme.primary, fontWeight: FontWeight.bold, fontSize: highContrast ? 18 : 16),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        labelStyle: TextStyle(color: highContrast ? Colors.black : Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(highContrast ? 8 : 15),
          borderSide: BorderSide(color: highContrast ? Colors.black : Colors.grey, width: highContrast ? 2.0 : 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(highContrast ? 8 : 15),
          borderSide: BorderSide(color: highContrast ? (theme.brightness == Brightness.dark ? Colors.white : Colors.black) : colorScheme.primary, width: highContrast ? 3.0 : 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(highContrast ? 8 : 15),
          borderSide: BorderSide(color: highContrast ? (theme.brightness == Brightness.dark ? Colors.white :Colors.black) : colorScheme.error, width: highContrast ? 2.5 : 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(highContrast ? 8 : 15),
          borderSide: BorderSide(color: highContrast ? Colors.black : Colors.red, width: highContrast ? 3.0 : 2.0),
        ),
        suffixIcon: showToggle
            ? IconButton(
                icon: Icon(
                  obscureValue ? Icons.visibility_off : Icons.visibility,
                  color: highContrast ? Colors.black : null,
                  size: highContrast ? 28 : 24,
                ),
                onPressed: onToggle,
              )
            : (readOnly && onTap != null)
              ? Icon(Icons.calendar_today, color: highContrast ? Colors.black : Colors.black54, size: highContrast ? 18 : 16)
              : null,
      ),
    );
  }
}