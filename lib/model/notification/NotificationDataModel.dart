class NotificationDataModel {
  final int? id;
  final String title;
  final String body;
  final String image;
  final String timestamp;
  bool isRead;
  final String? type;
  final String? actionUrl;
  final String? serverId; // To track server notification ID
  final String? eventOfferId; // To link notifications to events/offers

  NotificationDataModel({
    this.id,
    required this.title,
    required this.body,
    required this.image,
    required this.timestamp,
    this.isRead = false,
    this.type,
    this.actionUrl,
    this.serverId,
    this.eventOfferId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'image': image,
      'timestamp': timestamp,
      'isRead': isRead ? 1 : 0,
      'type': type,
      'actionUrl': actionUrl,
      'serverId': serverId,
      'eventOfferId': eventOfferId,
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
      type: map['type'],
      actionUrl: map['actionUrl'],
      serverId: map['serverId'],
      eventOfferId: map['eventOfferId'],
    );
  }
}


