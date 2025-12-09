import 'package:flutter/material.dart';
import 'package:frontend/models/grouped_user_item.dart';
import 'package:intl/intl.dart';

class UserItemBar extends StatelessWidget {
  final GroupedUserItem groupedItem;

  const UserItemBar({super.key, required this.groupedItem});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy');
    final now = DateTime.now();
    final bool isExpired = groupedItem.earliestExpiration.isBefore(now);
    final daysLeft = groupedItem.earliestExpiration.difference(now).inDays;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // TODO
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.7), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(2, 2),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                groupedItem.amount.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),

            const SizedBox(width: 14),

            Text(
              groupedItem.itemName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    daysLeft <= 7 && !isExpired
                    ? "$daysLeft days left!"
                    : dateFormat.format(groupedItem.earliestExpiration),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isExpired ? FontWeight.bold : (daysLeft <= 7 ? FontWeight.w600 : FontWeight.w400),
                      color: isExpired ? Colors.red : (daysLeft <= 3 ? Colors.red.shade700 : (daysLeft <= 5 ? Colors.orange.shade700 : (daysLeft <= 7 ? Colors.grey.shade900 : Colors.black))),
                    ),
                  ),

                  if (groupedItem.isOpen)
                   Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.inventory_2_rounded,
                        size: 14,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Opened",
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                   )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}