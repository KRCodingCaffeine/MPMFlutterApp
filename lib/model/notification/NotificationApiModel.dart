import 'NotificationDataModel.dart';

class NotificationApiModel {
  final int? id;
  final String title;
  final String body;
  final String? image;
  final String timestamp;
  final bool isRead;
  final String? type;
  final Map<String, dynamic>? data;
  final String? actionUrl;

  NotificationApiModel({
    this.id,
    required this.title,
    required this.body,
    this.image,
    required this.timestamp,
    this.isRead = false,
    this.type,
    this.data,
    this.actionUrl,
  });

  // Helper method to safely parse integer values
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    // Handle different read status formats from server
    bool isRead = false;
    if (json['is_read'] != null) {
      isRead = json['is_read'] == 1 || json['is_read'] == true;
    } else if (json['read_status'] != null) {
      isRead = json['read_status'] == 'read' || json['read_status'] == '1' || json['read_status'] == true;
    }
    
    return NotificationApiModel(
      id: _parseInt(json['notification_id'] ?? json['id']),
      title: json['title'] ?? '',
      body: json['subject'] ?? json['body'] ?? '',
      image: json['notification_image_path'] ?? json['image'],
      timestamp: json['timestamp'] ?? json['created_at'] ?? DateTime.now().toIso8601String(),
      isRead: isRead,
      type: json['type'],
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      actionUrl: json['action_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'image': image,
      'timestamp': timestamp,
      'is_read': isRead ? 1 : 0,
      'type': type,
      'data': data,
      'action_url': actionUrl,
    };
  }

  // Convert to local database model
  NotificationDataModel toLocalModel() {
    return NotificationDataModel(
      id: id,
      title: title,
      body: body,
      image: image ?? '',
      timestamp: timestamp,
      isRead: isRead,
    );
  }
}

class NotificationListResponse {
  final bool status;
  final String message;
  final List<NotificationApiModel> notifications;
  final int unreadCount;

  NotificationListResponse({
    required this.status,
    required this.message,
    required this.notifications,
    this.unreadCount = 0,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      notifications: (json['data'] as List<dynamic>?)
          ?.map((item) => NotificationApiModel.fromJson(item))
          .toList() ?? [],
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class NotificationCountResponse {
  final bool status;
  final String message;
  final int unreadCount;

  NotificationCountResponse({
    required this.status,
    required this.message,
    required this.unreadCount,
  });

  factory NotificationCountResponse.fromJson(Map<String, dynamic> json) {
    return NotificationCountResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class NotificationActionRequest {
  final int? notificationId;
  final String? memberId;

  NotificationActionRequest({
    this.notificationId,
    this.memberId,
  });

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'member_id': memberId,
    };
  }
}

class NotificationActionResponse {
  final bool status;
  final String message;

  NotificationActionResponse({
    required this.status,
    required this.message,
  });

  factory NotificationActionResponse.fromJson(Map<String, dynamic> json) {
    return NotificationActionResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
