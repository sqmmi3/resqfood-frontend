import 'package:flutter/material.dart';

class MessageDialog extends StatelessWidget {
  final String message;

  const MessageDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, {required String message}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 1), () {
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        });
        return MessageDialog(message: message);
      },
    );
  }
}
