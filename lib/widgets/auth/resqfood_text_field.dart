import 'package:flutter/material.dart';

class ResQFoodTextField extends StatelessWidget{
  final String label;
  final bool obscure;
  final bool showToggle;
  final bool obscureValue;
  final VoidCallback? onToggle;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const ResQFoodTextField({
    super.key,
    required this.label,
    this.obscure = false,
    this.showToggle = false,
    this.obscureValue = false,
    this.onToggle,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure && obscureValue,
      validator: validator,
      onChanged: onChanged,
      cursorColor: Colors.green,
      decoration: InputDecoration(
        hintText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        labelStyle: const TextStyle(color: Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.green, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red, width: 1),
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
            : null,
      ),
    );
  }
}