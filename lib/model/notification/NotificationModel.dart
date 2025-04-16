class NotificationModel {
  final int? id;
  final String title;
  final String body;
  final String timestamp;

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      timestamp: map['timestamp'],
    );
  }
}
