class GroupedUserItem {
  final String itemName;
  final int amount;
  final DateTime earliestExpiration;
  final bool isOpen;

  GroupedUserItem({
    required this.itemName,
    required this.amount,
    required this.earliestExpiration,
    this.isOpen = false,
  });

  @override
  String toString() {
    return 'GroupedUserItem{name: $itemName, count: $amount, earliestExpiration: $earliestExpiration, isOpen: $isOpen}';
  }
}