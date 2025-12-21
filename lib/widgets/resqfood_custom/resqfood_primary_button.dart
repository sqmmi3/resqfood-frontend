import 'package:flutter/material.dart';

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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: disabled ? Colors.grey : Colors.green,
          padding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          )
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}