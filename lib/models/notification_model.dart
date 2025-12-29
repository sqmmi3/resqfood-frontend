class NotificationModel {
  final int id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final int? relatedItemId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.relatedItemId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      relatedItemId: json['relatedItemId'],
    );
  }
}
