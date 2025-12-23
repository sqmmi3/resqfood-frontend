import 'package:flutter/material.dart';
import 'package:frontend/models/user_item.dart';
import 'package:intl/intl.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${userItem.itemName} #$index",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),

        _buildInstanceField("Expiration date", dateformat.format(userItem.expirationDate)),
        _buildInstanceField("Opened date (opt)", userItem.openedDate != null ? dateformat.format(userItem.openedDate!) : "Unopened"),
        _buildInstanceField("Opened rule (opt)", userItem.openedRule != null ? "${userItem.openedRule} days" : "0 days"),

        const Text("Description (opt)", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 1.2),
          ),
          child: Stack(
            children: [
              Text(
                userItem.description ?? "No description available",
                style: const TextStyle(fontSize: 14),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Text(
                  "${userItem.description?.length ?? 0}/128",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              )
            ],
          )
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onDelete,
            child: const Text("Remove this instance", style: TextStyle(color: Colors.red, fontSize: 12))),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInstanceField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const Divider(color: Colors.black, thickness: 1.2),
        ],
      ),
    );
  }
}