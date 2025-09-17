import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // 1. Init Awesome Notifications
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'mpm_app_channel',
          channelName: 'General Notifications',
          channelDescription: 'This channel is used for app messages',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          playSound: true,
          channelShowBadge: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'mpm_group',
          channelGroupName: 'MPM Notifications',
        )
      ],
      debug: true,
    );

    // 2. Permissions
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // 3. Listeners
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 4. Token setup
    final token = await _messaging.getToken();
    debugPrint("🔥 Current FCM Token: $token");

    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint("🔄 Refreshed Token: $newToken");
      // TODO: Send to your server
    });

    // 5. Awesome Notifications listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceived,
      onNotificationCreatedMethod: onNotificationCreated,
      onNotificationDisplayedMethod: onNotificationDisplayed,
      onDismissActionReceivedMethod: onDismissActionReceived,
    );
  }

  /// Foreground handler
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint("📩 Foreground FCM: ${message.data}");

    // Foreground: suppress OS → show local manually
    if (message.notification != null) {
      _showLocalNotification(message);
    } else {
      _showLocalNotification(message);
    }
  }

  /// Notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint("➡️ Notification tapped: ${message.data}");
    // TODO: Navigate if needed
  }

  /// Show local Awesome notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'] ?? "No Title";
    final body = message.notification?.body ?? message.data['body'] ?? "No Body";
    final image = message.data['image'];

    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'mpm_app_channel',
        title: title,
        body: body,
        bigPicture: image,
        notificationLayout: (image != null && image.isNotEmpty)
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
        autoDismissible: true,
        showWhen: true,
      ),
    );

    // TODO: Save to DB and update badge if required
  }

  // Event callbacks
  static Future<void> onActionReceived(ReceivedAction action) async {
    debugPrint("➡️ User tapped notification: ${action.payload}");
  }

  static Future<void> onNotificationCreated(ReceivedNotification notification) async {
    debugPrint("📌 Notification created");
  }

  static Future<void> onNotificationDisplayed(ReceivedNotification notification) async {
    debugPrint("👀 Notification displayed");
  }

  static Future<void> onDismissActionReceived(ReceivedAction action) async {
    debugPrint("❌ Notification dismissed");
  }
}

/// Background handler must be top-level
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("🌙 Background FCM: ${message.data}");

  final service = NotificationService();
  await service._showLocalNotification(message);
}
