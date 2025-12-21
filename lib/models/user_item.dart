class UserItem {
  final int id;
  final int itemId;
  final String itemName;
  final String type;
  final DateTime expirationDate;
  final DateTime? openedDate;
  final int? openedRule;

  UserItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.expirationDate,
    this.openedDate,
    this.openedRule,
  });

  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      id: json['id'],
      itemId: json['itemId'],
      itemName: json['itemName'],
      type: json['type'],
      expirationDate: DateTime.parse(json['expirationDate']),
      openedDate: json['openedDate'] != null ? DateTime.parse(json['openedDate']) : null,
      openedRule: json['openedRule'],
    );
  }
}