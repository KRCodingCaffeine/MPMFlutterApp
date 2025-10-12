import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/notification/NotificationApiModel.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/utils/Session.dart';

class NotificationRepository {
  final NetWorkApiService _api = NetWorkApiService();

  /// Get all notifications for the current member
  Future<NotificationListResponse> getAllNotifications() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData?.memberId == null) {
        throw Exception('User not logged in');
      }

      final requestBody = {
        'member_id': userData!.memberId,
      };

      final response = await _api.postApi(
        requestBody,
        Urls.get_all_notifications_url,
        "",
        "2",
      );

      debugPrint("Get All Notifications Response: $response");
      return NotificationListResponse.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
      rethrow;
    }
  }

  /// Mark a single notification as read
  Future<NotificationActionResponse> markNotificationAsRead(int notificationId) async {
    try {
      final userData = await SessionManager.getSession();
      if (userData?.memberId == null) {
        throw Exception('User not logged in');
      }

      final requestBody = {
        'notification_id': notificationId,
        'member_id': userData!.memberId,
      };

      final response = await _api.postApi(
        requestBody,
        Urls.mark_notification_read_url,
        "",
        "2",
      );

      debugPrint("Mark Notification Read Response: $response");
      return NotificationActionResponse.fromJson(response);
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<NotificationActionResponse> markAllNotificationsAsRead() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData?.memberId == null) {
        throw Exception('User not logged in');
      }

      final requestBody = {
        'member_id': userData!.memberId,
      };

      final response = await _api.postApi(
        requestBody,
        Urls.mark_all_notifications_read_url,
        "",
        "2",
      );

      debugPrint("Mark All Notifications Read Response: $response");
      return NotificationActionResponse.fromJson(response);
    } catch (e) {
      debugPrint("Error marking all notifications as read: $e");
      rethrow;
    }
  }

  /// Delete a single notification
  Future<NotificationActionResponse> deleteNotification(int notificationId) async {
    try {
      final userData = await SessionManager.getSession();
      if (userData?.memberId == null) {
        throw Exception('User not logged in');
      }

      final requestBody = {
        'notification_id': notificationId,
        'member_id': userData!.memberId,
      };

      final response = await _api.postApi(
        requestBody,
        Urls.delete_notification_url,
        "",
        "2",
      );

      debugPrint("Delete Notification Response: $response");
      return NotificationActionResponse.fromJson(response);
    } catch (e) {
      debugPrint("Error deleting notification: $e");
      rethrow;
    }
  }

  /// Delete all notifications
  Future<NotificationActionResponse> deleteAllNotifications() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData?.memberId == null) {
        throw Exception('User not logged in');
      }

      final requestBody = {
        'member_id': userData!.memberId,
      };

      final response = await _api.postApi(
        requestBody,
        Urls.delete_all_notifications_url,
        "",
        "2",
      );

      debugPrint("Delete All Notifications Response: $response");
      return NotificationActionResponse.fromJson(response);
    } catch (e) {
      debugPrint("Error deleting all notifications: $e");
      rethrow;
    }
  }

  /// Get unread notification count
  Future<NotificationCountResponse> getUnreadNotificationCount() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData?.memberId == null) {
        throw Exception('User not logged in');
      }

      final requestBody = {
        'member_id': userData!.memberId,
      };

      final response = await _api.postApi(
        requestBody,
        Urls.unread_notification_count_url,
        "",
        "2",
      );

      debugPrint("Unread Notification Count Response: $response");
      return NotificationCountResponse.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching unread notification count: $e");
      rethrow;
    }
  }
}
