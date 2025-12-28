import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/user_item.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserItemDetailCard extends StatelessWidget {
  final UserItem userItem;
  final int index;
  final VoidCallback onDelete;

  const UserItemDetailCard({
    super.key,
    required this.userItem,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateformat = DateFormat('dd-MM-yyyy');
    final highContrast = context.watch<AuthProvider>().highContrast;
    final isHapticsEnabled = context.watch<AuthProvider>().hapticsEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${userItem.itemName} #$index",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: highContrast ? 20 : 18),
        ),
        const SizedBox(height: 10),

        _buildInstanceField(context, "Expiration date", dateformat.format(userItem.expirationDate), highContrast),
        _buildInstanceField(context, "Opened date (opt)", userItem.openedDate != null ? dateformat.format(userItem.openedDate!) : "Unopened", highContrast),
        _buildInstanceField(context, "Opened rule (opt)", userItem.openedRule != null ? "${userItem.openedRule} days" : "0 days", highContrast),

        Text("Description (opt)", style: TextStyle(fontSize: highContrast ? 18 : 16, fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(highContrast ? 8 : 15),
            border: Border.all(color: Theme.of(context).dividerColor, width: highContrast ? 3.0 : 1.2),
          ),
          child: Stack(
            children: [
              Text(
                userItem.description ?? "No description available",
                style: TextStyle(fontSize: highContrast ? 16 : 14),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Text(
                  "${userItem.description?.length ?? 0}/128",
                  style: TextStyle(fontSize: highContrast ? 14 : 10, color: highContrast ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black) : Theme.of(context).hintColor,
                ),
              )
            ],
          )
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () { onDelete(); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
            child: Text("Remove this instance", style: TextStyle(color: highContrast ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black : Theme.of(context).colorScheme.error, fontSize: highContrast ? 14 : 12))),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInstanceField(BuildContext context, String label, String value, bool highContrast) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: highContrast ? 18 : 16, fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: highContrast ? 16 : 14, fontWeight: highContrast ? FontWeight.w700 : FontWeight.w500)),
          const Divider(color: Theme.of(context).dividerColor, thickness: 1.2),
        ],
      ),
    );
  }
}