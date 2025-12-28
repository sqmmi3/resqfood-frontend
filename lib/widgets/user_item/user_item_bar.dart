import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/grouped_user_item.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/screens/items/item_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserItemBar extends StatelessWidget {
  final GroupedUserItem groupedItem;

  const UserItemBar({super.key, required this.groupedItem});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd-MM-yyyy');
    final now = DateTime.now();
    final bool isExpired = groupedItem.earliestExpiration.isBefore(now);
    final daysLeft = groupedItem.earliestExpiration.difference(now).inDays;
    final highContrast = context.watch<AuthProvider>().highContrast;
    final bool verbosity = context.watch<AuthProvider>().isHighVerbosity;

    String semanticDescription;
    if (verbosity) {
      semanticDescription = "Food item: ${groupedItem.itemName}. ";
      semanticDescription += isExpired
        ? "Alert: This item is expired! "
        : "Status: Expires in $daysLeft days. ";
      semanticDescription += "Current quantity is ${groupedItem.amount}. ";
      if (groupedItem.isOpen) semanticDescription += "Note: This package is already opened.";
    } else {
      semanticDescription = "${groupedItem.itemName}, ${groupedItem.amount} units.";
    }

    int statusLevel = 0;
    if (isExpired || daysLeft <= 3) {
      statusLevel = 2;
    } else if (daysLeft <= 7) {
      statusLevel = 1;
    }

    return Semantics(
      label: semanticDescription,
      button: true,
      enabled: true,
      container: true,
      explicitChildNodes: false,
      onTapHint: "View details and history for ${groupedItem.itemName}",
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailsScreen(itemName: groupedItem.itemName)
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: highContrast ? Colors.black : Colors.green.withValues(alpha: 0.7),
              width: highContrast ? 2.0 : 1.2,
            ),
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
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: highContrast ? Colors.black : Colors.green.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  groupedItem.amount.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: highContrast ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),

              const SizedBox(width: 10),
              
              Expanded(
                flex: 3,
                child: Text(
                  groupedItem.itemName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: highContrast ? FontWeight.bold : FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (highContrast) ...[
                      _getStatusIcon(statusLevel),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      daysLeft <= 7 && !isExpired
                      ? "$daysLeft days left!"
                      : dateFormat.format(groupedItem.earliestExpiration),
                      style: TextStyle(
                        fontSize: highContrast ? 14 : 12,
                        fontWeight: highContrast || isExpired ? FontWeight.bold : (daysLeft <= 7 ? FontWeight.w600 : FontWeight.w400),
                        color: _getTextColor(isExpired, daysLeft, highContrast),
                      ),
                    ),

                    if (groupedItem.isOpen)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.inventory_2_rounded,
                          size: 10,
                          color: highContrast ? Colors.black : Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Opened",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: highContrast ? FontWeight.bold : FontWeight.normal,
                            fontStyle: highContrast ? null : FontStyle.italic,
                            color: highContrast? Colors.black : Colors.orange.shade700,
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
      ),
    );
  }

  Color _getTextColor(bool isExpired, int daysLeft, bool highContrast) {
    if (highContrast) return Colors.black;
    if (isExpired) return Colors.red;
    if (daysLeft <= 3) return Colors.red.shade700;
    if (daysLeft <= 5) return Colors.orange.shade700;
    if (daysLeft <= 7) return Colors.grey.shade900;
    return Colors.black;
  }

  Widget _getStatusIcon(int level) {
    switch (level) {
      case 2:
        return const Icon(Icons.error_outline, color: Colors.black, size: 18);
      case 1:
        return const Icon(Icons.help_outline, color: Colors.black, size: 18);
      default:
        return const Icon(Icons.check_circle_outline, color: Colors.black, size: 18);
    }
  }
}