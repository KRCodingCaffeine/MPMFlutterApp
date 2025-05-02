class NotificationModel {
  final int? id;
  final String title;
  final String body;
  final String image;
  final String timestamp;

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.image,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'image':image,
      'timestamp': timestamp,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      image: map['image'],
      timestamp: map['timestamp'],
    );
  }
}
