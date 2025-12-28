import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscure && obscureValue,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      cursorColor: colorScheme.primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: (defaultValue != null && defaultValue!.isNotEmpty)
          ? defaultValue
          : "Enter $label",
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorScheme.primary, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        suffixIcon: showToggle
            ? IconButton(
                icon: Icon(
                  obscureValue ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: onToggle,
              )
            : (readOnly && onTap != null)
              ? const Icon(Icons.calendar_today, color: Colors.black54, size: 14)
              : null,
      ),
    );
  }
}