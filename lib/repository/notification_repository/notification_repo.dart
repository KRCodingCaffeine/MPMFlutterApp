import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/model/notification/NotificationApiModel.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/utils/Session.dart';

class NotificationRepository {

  /// Get all notifications for the current member
  Future<NotificationListResponse> getAllNotifications() async {
    try {
      final userData = await SessionManager.getSession();
      
      if (userData?.memberId == null) {
        throw Exception('User not logged in');
      }

      debugPrint("🔍 Getting notifications for member: ${userData!.memberId}");

      final uri = Uri.parse(Urls.get_all_notifications_url);
      var request = http.MultipartRequest('POST', uri);

      // Add form data fields (same pattern as device mapping)
      request.fields.addAll({
        'member_id': userData.memberId ?? '',
      });

      _logRequestDetails(request, 'Get All Notifications');

      // Send request
      final response = await _sendRequest(request);

      return _handleNotificationListResponse(response);
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
      rethrow;
    }
  }

  /// Mark a single notification as read (JSON format)
  Future<NotificationActionResponse> markNotificationAsReadJson(int notificationId) async {
    try {
      debugPrint("🔍 Starting markNotificationAsReadJson for ID: $notificationId");
      
      final userData = await SessionManager.getSession();
      
      if (userData?.memberId == null) {
        debugPrint("❌ User not logged in - memberId is null");
        throw Exception('User not logged in');
      }

      debugPrint("👤 User data: memberId=${userData!.memberId}");

      debugPrint("🌐 API URL: ${Urls.mark_notification_read_url}");

      final uri = Uri.parse(Urls.mark_notification_read_url);
      var request = http.MultipartRequest('POST', uri);

      // Add form data fields - only notification_queue_id is needed
      request.fields.addAll({
        'notification_queue_id': notificationId.toString(),
      });

      _logRequestDetails(request, 'Mark Notification Read');

      // Send request
      final response = await _sendRequest(request);
      
      final parsedResponse = _handleNotificationActionResponse(response);
      debugPrint("✅ Parsed response: status=${parsedResponse.status}, message=${parsedResponse.message}");
      
      return parsedResponse;
    } catch (e) {
      debugPrint("❌ Error marking notification as read (JSON): $e");
      debugPrint("❌ Error type: ${e.runtimeType}");
      debugPrint("❌ Stack trace: ${StackTrace.current}");
      rethrow;
    }
  }

  /// Mark a single notification as read (form data format)
  Future<NotificationActionResponse> markNotificationAsRead(int notificationId) async {
    try {
      debugPrint("🔍 Starting markNotificationAsRead for ID: $notificationId");
      
      final userData = await SessionManager.getSession();
      
      if (userData?.memberId == null) {
        debugPrint("❌ User not logged in - memberId is null");
        throw Exception('User not logged in');
      }

      debugPrint("👤 User data: memberId=${userData!.memberId}");

      final requestBody = {
        'notification_queue_id': notificationId.toString(),
        'member_id': userData.memberId ?? '',
      };

      debugPrint("📤 Request body: $requestBody");
      debugPrint("🌐 API URL: ${Urls.mark_notification_read_url}");

      final uri = Uri.parse(Urls.mark_notification_read_url);
      var request = http.MultipartRequest('POST', uri);

      // Add form data fields - only notification_queue_id is needed
      request.fields.addAll({
        'notification_queue_id': notificationId.toString(),
      });

      _logRequestDetails(request, 'Mark Notification Read');

      // Send request
      final response = await _sendRequest(request);
      
      final parsedResponse = _handleNotificationActionResponse(response);
      debugPrint("✅ Parsed response: status=${parsedResponse.status}, message=${parsedResponse.message}");
      
      return parsedResponse;
    } catch (e) {
      debugPrint("❌ Error marking notification as read: $e");
      debugPrint("❌ Error type: ${e.runtimeType}");
      debugPrint("❌ Stack trace: ${StackTrace.current}");
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

      // TODO: Update to use MultipartRequest pattern
      final response = {"status": false, "message": "Method not yet updated to new pattern"};

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
      debugPrint("🔍 Starting deleteNotification for ID: $notificationId");
      debugPrint("🌐 API URL: ${Urls.delete_notification_url}");

      final uri = Uri.parse(Urls.delete_notification_url);
      var request = http.MultipartRequest('POST', uri);

      // Add form data fields - only notification_queue_id is needed
      request.fields.addAll({
        'notification_queue_id': notificationId.toString(),
      });

      _logRequestDetails(request, 'Delete Notification');

      // Send request
      final response = await _sendRequest(request);
      
      final parsedResponse = _handleNotificationActionResponse(response);
      debugPrint("✅ Parsed response: status=${parsedResponse.status}, message=${parsedResponse.message}");
      
      return parsedResponse;
    } catch (e) {
      debugPrint("❌ Error deleting notification: $e");
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

      debugPrint("🔍 Starting deleteAllNotifications for member: ${userData!.memberId}");
      debugPrint("🌐 API URL: ${Urls.delete_all_notifications_url}");

      final uri = Uri.parse(Urls.delete_all_notifications_url);
      var request = http.MultipartRequest('POST', uri);

      // Add form data fields - only member_id is needed
      request.fields.addAll({
        'member_id': userData.memberId ?? '',
      });

      _logRequestDetails(request, 'Delete All Notifications');

      // Send request
      final response = await _sendRequest(request);
      
      final parsedResponse = _handleNotificationActionResponse(response);
      debugPrint("✅ Parsed response: status=${parsedResponse.status}, message=${parsedResponse.message}");
      
      return parsedResponse;
    } catch (e) {
      debugPrint("❌ Error deleting all notifications: $e");
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

      // TODO: Update to use MultipartRequest pattern
      final response = {"status": false, "message": "Method not yet updated to new pattern"};

      debugPrint("Unread Notification Count Response: $response");
      return NotificationCountResponse.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching unread notification count: $e");
      rethrow;
    }
  }

  /// Log API request details for debugging (same pattern as device mapping)
  void _logRequestDetails(http.MultipartRequest request, String apiName) {
    debugPrint('--- 📡 $apiName Request ---');
    debugPrint('Endpoint: ${request.url}');
    debugPrint('Fields: ${request.fields}');
    debugPrint('--------------------------------');
  }

  /// Send HTTP multipart request and return response (same pattern as device mapping)
  Future<http.Response> _sendRequest(http.MultipartRequest request) async {
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('❌ Error sending request: ${e.toString()}');
      rethrow;
    }
  }

  /// Handle notification list API response and parse to model
  NotificationListResponse _handleNotificationListResponse(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return NotificationListResponse.fromJson(decoded);
    }

    throw HttpException(
      'Request failed with status ${response.statusCode}',
      uri: Uri.parse(Urls.get_all_notifications_url),
    );
  }

  /// Handle notification action API response and parse to model
  NotificationActionResponse _handleNotificationActionResponse(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return NotificationActionResponse.fromJson(decoded);
    }

    throw HttpException(
      'Request failed with status ${response.statusCode}',
      uri: Uri.parse(Urls.mark_notification_read_url),
    );
  }

  /// Handle notification count API response and parse to model
  NotificationCountResponse _handleNotificationCountResponse(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return NotificationCountResponse.fromJson(decoded);
    }

    throw HttpException(
      'Request failed with status ${response.statusCode}',
      uri: Uri.parse(Urls.unread_notification_count_url),
    );
  }
}
