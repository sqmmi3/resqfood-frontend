class Item {
  final int? id;
  final String name;
  final String? category;
  final int? quantity;
  final String? expirationDate;
  final String? openedDate;
  final String? description;
  final List<dynamic>? userItems;

  Item({
    this.id,
    required this.name,
    this.category,
    this.quantity,
    this.expirationDate,
    this.openedDate,
    this.description,
    this.userItems,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int?,
      name: json['name'] as String,
      category: json['category'] as String?,
      quantity: json['quantity'] as int?,
      expirationDate: json['expirationDate'] as String?,
      openedDate: json['openedDate'] as String?,
      description: json['description'] as String?,
      userItems: json['userItems'] as List<dynamic>?,
    );
  }
}
