class UserItem {
  final int id;
  final String itemName;
  final DateTime expirationDate;
  final DateTime? openedDate;
  final int? openedRule;

  UserItem({
    required this.id,
    required this.itemName,
    required this.expirationDate,
    this.openedDate,
    this.openedRule,
  });

  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      id: json['id'],
      itemName: json['item']['name'],
      expirationDate: DateTime.parse(json['expirationDate']),
      openedDate: json['openedDate'] != null ? DateTime.parse(json['openedDate']) : null,
      openedRule: json['openedRule'],
    );
  }
}