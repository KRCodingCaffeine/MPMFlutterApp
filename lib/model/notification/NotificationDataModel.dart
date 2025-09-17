class NotificationDataModel {
  final int? id;
  final String title;
  final String body;
  final String image;
  final String timestamp;
   bool isRead;

  NotificationDataModel({
    this.id,
    required this.title,
    required this.body,
    required this.image,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'image': image,
      'timestamp': timestamp,
      'isRead': isRead ? 1 : 0,
    };
  }

  factory NotificationDataModel.fromMap(Map<String, dynamic> map) {
    return NotificationDataModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      image: map['image'],
      timestamp: map['timestamp'],
      isRead: map['isRead'] == 1,
    );
  }
}


