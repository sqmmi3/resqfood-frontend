import 'package:frontend/models/user_item.dart';

class GroupedUserItem {
  final String itemName;
  final String type;
  final int amount;
  final DateTime earliestExpiration;
  final bool isOpen;
  final List<UserItem> allInstances;

  GroupedUserItem({
    required this.itemName,
    required this.type,
    required this.amount,
    required this.earliestExpiration,
    required this.allInstances,
    this.isOpen = false,
  });

  @override
  String toString() {
    return 'GroupedUserItem{name: $itemName, type: $type, amount: $amount, earliestExpiration: $earliestExpiration, isOpen: $isOpen}';
  }
}