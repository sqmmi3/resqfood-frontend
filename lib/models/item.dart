class Item {
  final String name;
  final String category;
  final String quantity;
  final String expirationDate;
  final String? openedDate;
  final String? openedRule;
  final String? description;

  Item({
    required this.name,
    required this.category,
    required this.quantity,
    required this.expirationDate,
    this.openedDate,
    this.openedRule,
    this.description,
  });
}
