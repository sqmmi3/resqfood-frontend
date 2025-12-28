class UserItem {
  final int? id;
  final int? itemId;
  final String itemName;
  final String type;
  final DateTime expirationDate;
  final DateTime? openedDate;
  final int? openedRule;
  final String? description;
  final String addedBy;

  UserItem({
    this.id,
    this.itemId,
    required this.itemName,
    required this.type,
    required this.expirationDate,
    this.openedDate,
    this.openedRule,
    this.description,
    this.addedBy = "Me",
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
      description: json['description'],
      addedBy: json['addedBy'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'itemName': itemName,
    'type': type,
    'expirationDate': expirationDate.toIso8601String().split('T')[0],
    'openedDate': openedDate?.toIso8601String().split('T')[0],
    'openedRule': openedRule,
    'description': description,
  };
}