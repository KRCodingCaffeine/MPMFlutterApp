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
  final String? relatedEndDate; // Event/trip last date used to drop past unread

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
    this.relatedEndDate,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'body': body,
      'image': image,
      'timestamp': timestamp,
      'isRead': isRead ? 1 : 0,
      'type': type,
      'actionUrl': actionUrl,
      'serverId': serverId,
      'eventOfferId': eventOfferId,
      'relatedEndDate': relatedEndDate,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory NotificationDataModel.fromMap(Map<String, dynamic> map) {
    return NotificationDataModel(
      id: map['id'],
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      image: map['image'] ?? '',
      timestamp: map['timestamp'] ?? '',
      isRead: map['isRead'] == 1,
      type: map['type'],
      actionUrl: map['actionUrl'],
      serverId: map['serverId'],
      eventOfferId: map['eventOfferId'],
      relatedEndDate: map['relatedEndDate'],
    );
  }
}


