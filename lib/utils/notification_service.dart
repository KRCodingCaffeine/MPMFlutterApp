import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'dart:io' show Platform;
import 'package:mpm/model/notification/NotificationDataModel.dart';
import 'package:mpm/utils/NotificationDatabase.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/view_model/controller/notification/NotificationApiController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static const String _badgeKey = "badge_count";

  Future<void> init() async {
    // Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'mpm_app_channel',
          channelName: 'General Notifications',
          channelDescription: 'App messages',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          playSound: true,
          channelShowBadge: true,
          enableVibration: true,
          enableLights: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelKey: 'mpm_background_channel',
          channelName: 'Background Notifications',
          channelDescription: 'Background app messages',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          channelShowBadge: true,
          enableVibration: true,
          enableLights: true,
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

    // Enhanced permissions for iOS
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      final permission = await AwesomeNotifications().requestPermissionToSendNotifications();
      debugPrint("📱 Notification permission result: $permission");
    }
    
    // Request FCM permissions with more specific options for iOS
    final authStatus = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      sound: true,
    );
    debugPrint("🔥 FCM Permission status: $authStatus");

    // iOS: ensure notifications appear while app is in foreground
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Sync badge count with database
    await syncBadgeWithDatabase();

    // Listeners
    FirebaseMessaging.onMessage.listen(handleIncomingFCMForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationTap);

    // Handle cold-start (app launched by tapping a notification while terminated)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationTap(initialMessage);
    }
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Token
    final token = await _messaging.getToken();
    debugPrint("🔥 FCM Token: $token");

    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint("🔄 Token refreshed: $newToken");
    });

    // Check iOS notification settings
    if (Platform.isIOS) {
      await _checkIOSNotificationSettings();
    }

    // Awesome notification events
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceived,
      onNotificationCreatedMethod: onNotificationCreated,
      onNotificationDisplayedMethod: onNotificationDisplayed,
      onDismissActionReceivedMethod: onDismissActionReceived,
    );
  }

  // Foreground handler: system does NOT show notification. We must show it.
  static Future<void> handleIncomingFCMForeground(RemoteMessage message) async {
    debugPrint("🔥 FCM Message received in FOREGROUND:");
    debugPrint("   Data: ${message.data}");
    debugPrint("   Notification: ${message.notification}");
    debugPrint("   Message ID: ${message.messageId}");
    debugPrint("   From: ${message.from}");
    debugPrint("   Sent Time: ${message.sentTime}");
    debugPrint("   Platform: ${Platform.isIOS ? 'iOS' : 'Android'}");
    debugPrint("   Has notification payload: ${message.notification != null}");
    
    try {
      final service = NotificationService();
      
      // Always persist to database and update badge first
      await service._persistNotificationAndUpdateBadge(message);
      
      // Always create local notification in foreground (iOS doesn't show system notifications)
      debugPrint("📱 Creating local notification for foreground message");
      await service._showLocalNotification(message);
      
    } catch (e) {
      debugPrint("❌ Error in handleIncomingFCM: $e");
      // Try to create a simple notification as fallback
      await _createFallbackNotification(message);
    }
  }

  // Background handler helper: system MAY already show notification if notification payload exists.
  // To avoid duplicates, only create a local notification for data-only messages.
  static Future<void> handleIncomingFCMBackground(RemoteMessage message) async {
    debugPrint("🌙 FCM Message received in BACKGROUND:");
    debugPrint("   Data: ${message.data}");
    debugPrint("   Notification: ${message.notification}");
    debugPrint("   Message ID: ${message.messageId}");
    debugPrint("   From: ${message.from}");
    debugPrint("   Sent Time: ${message.sentTime}");
    debugPrint("   Platform: ${Platform.isIOS ? 'iOS' : 'Android'}");
    debugPrint("   Has notification payload: ${message.notification != null}");
    
    try {
      // Always persist to DB and update badge first
      final service = NotificationService();
      await service._persistNotificationAndUpdateBadge(message);
      debugPrint("✅ Background notification persisted to database");

      // For background notifications, we don't create local notifications
      // The system will handle displaying them
      debugPrint("🛑 Background notification handled by system");
      
    } catch (e) {
      debugPrint("❌ Error in background handling: $e");
    }
  }

  static Future<void> _createFallbackNotification(RemoteMessage message) async {
    try {
      final title = message.notification?.title ?? message.data['title'] ?? "MPM Notification";
      final body = message.notification?.body ?? message.data['body'] ?? "You have a new message";
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'mpm_background_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          autoDismissible: true,
          showWhen: true,
          wakeUpScreen: true,
        ),
      );
      debugPrint("✅ Fallback notification created");
    } catch (e) {
      debugPrint("❌ Fallback notification failed: $e");
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      // Handle both notification payload and data payload
      final title = message.notification?.title ?? 
                   message.data['title'] ?? 
                   "MPM Notification";
      final body = message.notification?.body ?? 
                  message.data['body'] ?? 
                  "You have a new message";
      final image = message.notification?.android?.imageUrl ?? 
                   message.data['image'] ?? 
                   "";

      debugPrint("📱 Creating notification - Title: $title, Body: $body, Image: $image");
      debugPrint("📱 Platform: ${Platform.isIOS ? 'iOS' : 'Android'}");
      debugPrint("📱 Message notification: ${message.notification}");
      debugPrint("📱 Message data: ${message.data}");

      // Get current badge count (don't increment again)
      final int badgeCount = await getCurrentBadgeCount();

      final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      // Use the channel key from payload or default to background channel
      String channelKey = message.data['channelKey'] ?? 'mpm_background_channel';
      
      debugPrint("📺 Creating notification with channel: $channelKey");
      
      // iOS-specific notification content
      final notificationContent = NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        bigPicture: (image.isNotEmpty) ? image : null,
        notificationLayout: (image.isNotEmpty)
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
        autoDismissible: true,
        showWhen: true,
        badge: badgeCount,
        payload: message.data.map((key, value) => MapEntry(key, value?.toString())),
        wakeUpScreen: true,
        fullScreenIntent: Platform.isIOS ? false : true, // Disable on iOS to avoid issues
        displayOnBackground: true,
        displayOnForeground: true,
        // iOS-specific settings
        criticalAlert: false,
        locked: false,
      );
      
      await AwesomeNotifications().createNotification(
        content: notificationContent,
      );
      
      debugPrint("✅ Notification created successfully with badge: $badgeCount");
    } catch (e) {
      debugPrint("❌ Error creating notification: $e");
      // Re-throw to see the full error in logs
      rethrow;
    }
  }

  // Persists notification, increments and syncs badge; returns new badge count
  Future<int> _persistNotificationAndUpdateBadge(
    RemoteMessage message, {
    String? overrideTitle,
    String? overrideBody,
    String? overrideImage,
  }) async {
    final String title = overrideTitle ??
        (message.notification?.title ?? message.data['title'] ?? 'MPM Notification');
    final String body = overrideBody ??
        (message.notification?.body ?? message.data['body'] ?? 'You have a new message');
    final String image = overrideImage ??
        (message.notification?.android?.imageUrl ?? message.data['image'] ?? '');

    final notificationModel = NotificationDataModel(
      title: title,
      body: body,
      image: image,
      timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      isRead: false,
    );

    await NotificationDatabase.instance.insertNotification(notificationModel);
    debugPrint("💾 Notification saved to database");

    int badgeCount = await _getSavedBadgeCount();
    badgeCount++;
    await _saveBadgeCount(badgeCount);
    debugPrint("🔢 Badge count updated to: $badgeCount");

    // Update badge count using multiple methods for iOS compatibility
    await _updateBadgeCount(badgeCount);

    // Update notification controller unread count
    await updateNotificationController();

    return badgeCount;
  }

  // Enhanced badge count update method for iOS compatibility
  Future<void> _updateBadgeCount(int badgeCount) async {
    try {
      debugPrint("🔢 Updating badge count to: $badgeCount");
      
      // Method 1: Awesome Notifications
      try {
        await AwesomeNotifications().setGlobalBadgeCounter(badgeCount);
        debugPrint("✅ Awesome Notifications badge updated to: $badgeCount");
      } catch (e) {
        debugPrint("❌ Awesome Notifications badge update failed: $e");
      }
      
      // Method 2: Flutter App Badger (iOS specific)
      if (Platform.isIOS) {
        try {
          if (badgeCount > 0) {
            await FlutterAppBadger.updateBadgeCount(badgeCount);
            debugPrint("✅ Flutter App Badger updated (iOS) to: $badgeCount");
          } else {
            await FlutterAppBadger.removeBadge();
            debugPrint("✅ Flutter App Badger removed (iOS)");
          }
        } catch (e) {
          debugPrint("❌ Flutter App Badger update failed: $e");
        }
      }
      
      // Method 3: Try setting badge on notification content itself
      if (Platform.isIOS) {
        try {
          // Force badge update by creating a temporary notification
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: 999999, // Use a high ID to avoid conflicts
              channelKey: 'mpm_app_channel',
              title: '',
              body: '',
              badge: badgeCount,
              displayOnBackground: false,
              displayOnForeground: false,
            ),
          );
          // Immediately cancel it
          await AwesomeNotifications().cancel(999999);
          debugPrint("✅ Badge forced update via temporary notification");
        } catch (e) {
          debugPrint("❌ Badge force update failed: $e");
        }
      }
      
    } catch (e) {
      debugPrint("❌ Error updating badge count: $e");
    }
  }

  void handleNotificationTap(RemoteMessage message) {
    debugPrint("Notification tapped: ${message.data}");
    
    try {
      // Navigate to dashboard first
      Get.offAllNamed(RouteNames.dashboard);
      
      // Wait for dashboard to load, then switch to notification tab
      Future.delayed(Duration(milliseconds: 1000), () {
        try {
          if (Get.isRegistered<UdateProfileController>()) {
            final dashboardController = Get.find<UdateProfileController>();
            dashboardController.changeTab(3); // Switch to notification tab (index 3)
            debugPrint("✅ Switched to notification tab");
          }
        } catch (e) {
          debugPrint("❌ Error switching to notification tab: $e");
        }
      });
      
      // Refresh list and sync badge
      refreshNotificationList();
      
      debugPrint("✅ Notification tap handled - navigated to dashboard");
    } catch (e) {
      debugPrint("❌ Error handling notification tap: $e");
    }
  }

  // Badge helpers
  static Future<int> _getSavedBadgeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_badgeKey) ?? 0;
    } catch (e) {
      debugPrint("Error getting badge count: $e");
      return 0;
    }
  }

  static Future<void> _saveBadgeCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_badgeKey, count);
      debugPrint("Badge count saved: $count");
    } catch (e) {
      debugPrint("Error saving badge count: $e");
    }
  }

  static Future<void> clearBadge() async {
    try {
      await _saveBadgeCount(0);
      
      // Use the enhanced badge update method
      final service = NotificationService();
      await service._updateBadgeCount(0);
      
      // Also mark all notifications as read in database
      await NotificationDatabase.instance.markAllNotificationsAsRead();
      
      // Update notification controller
      await updateNotificationController();
      
      debugPrint("✅ Badge cleared and all notifications marked as read");
    } catch (e) {
      debugPrint("❌ Error clearing badge: $e");
    }
  }

  // Method to get current badge count
  static Future<int> getCurrentBadgeCount() async {
    return await _getSavedBadgeCount();
  }

  // Method to sync badge count with database
  static Future<void> syncBadgeWithDatabase() async {
    try {
      final dbCount = await NotificationDatabase.instance.getUnreadNotificationCount();
      await _saveBadgeCount(dbCount);
      
      // Use the enhanced badge update method
      final service = NotificationService();
      await service._updateBadgeCount(dbCount);
      
      // Update notification controller
      await updateNotificationController();
      
      debugPrint("✅ Badge synced with database: $dbCount");
    } catch (e) {
      debugPrint("❌ Error syncing badge with database: $e");
    }
  }

  // Method to update badge with specific count (public)
  static Future<void> updateBadgeCount(int count) async {
    try {
      await _saveBadgeCount(count);
      await _updateBadgeCountStatic(count);
      debugPrint("✅ Badge updated to: $count");
    } catch (e) {
      debugPrint("❌ Error updating badge count: $e");
    }
  }

  // Check iOS notification settings
  Future<void> _checkIOSNotificationSettings() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      debugPrint("🍎 iOS Notification Settings:");
      debugPrint("   Authorization Status: ${settings.authorizationStatus}");
      debugPrint("   Alert Setting: ${settings.alert}");
      debugPrint("   Badge Setting: ${settings.badge}");
      debugPrint("   Sound Setting: ${settings.sound}");
      debugPrint("   Announcement Setting: ${settings.announcement}");
      debugPrint("   Car Play Setting: ${settings.carPlay}");
      debugPrint("   Critical Alert Setting: ${settings.criticalAlert}");
      debugPrint("   Notification Center Setting: ${settings.notificationCenter}");
      debugPrint("   Lock Screen Setting: ${settings.lockScreen}");
      
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint("❌ iOS notifications are denied!");
      } else if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        debugPrint("⚠️ iOS notification permission not determined!");
      } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint("✅ iOS notifications are authorized!");
      }
    } catch (e) {
      debugPrint("❌ Error checking iOS notification settings: $e");
    }
  }

  // Test method to create a notification manually
  static Future<void> testNotification() async {
    try {
      int badgeCount = await _getSavedBadgeCount();
      badgeCount++;
      await _saveBadgeCount(badgeCount);
      await AwesomeNotifications().setGlobalBadgeCounter(badgeCount);

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'mpm_background_channel',
          title: 'Test Notification',
          body: 'This is a test notification to verify the system works',
          notificationLayout: NotificationLayout.Default,
          autoDismissible: true,
          showWhen: true,
          badge: badgeCount,
          wakeUpScreen: true,
          displayOnBackground: true,
          displayOnForeground: true,
        ),
      );
      debugPrint("✅ Test notification created with badge: $badgeCount");
    } catch (e) {
      debugPrint("❌ Test notification failed: $e");
    }
  }

  // Method to test iOS-specific notification
  static Future<void> testIOSNotification() async {
    try {
      debugPrint("🍎 Testing iOS notification...");
      
      // Check if notifications are allowed
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      debugPrint("📱 Notifications allowed: $isAllowed");
      
      if (!isAllowed) {
        debugPrint("❌ Notifications not allowed! Requesting permission...");
        final permission = await AwesomeNotifications().requestPermissionToSendNotifications();
        debugPrint("📱 Permission result: $permission");
      }
      
      // Create a simple test notification
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 999,
          channelKey: 'mpm_app_channel',
          title: 'iOS Test',
          body: 'Testing iOS notification delivery',
          notificationLayout: NotificationLayout.Default,
          autoDismissible: true,
          showWhen: true,
          wakeUpScreen: true,
          displayOnBackground: true,
          displayOnForeground: true,
        ),
      );
      
      debugPrint("✅ iOS test notification created");
    } catch (e) {
      debugPrint("❌ iOS test notification failed: $e");
    }
  }

  // Method to debug notification permissions and settings
  static Future<void> debugNotificationSettings() async {
    try {
      debugPrint("🔍 === NOTIFICATION DEBUG INFO ===");
      
      // Check Awesome Notifications permission
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      debugPrint("📱 Awesome Notifications allowed: $isAllowed");
      
      // Check FCM settings
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      debugPrint("🔥 FCM Authorization Status: ${settings.authorizationStatus}");
      debugPrint("🔥 FCM Alert Setting: ${settings.alert}");
      debugPrint("🔥 FCM Badge Setting: ${settings.badge}");
      debugPrint("🔥 FCM Sound Setting: ${settings.sound}");
      
      // Get FCM token
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint("🔥 FCM Token: $token");
      
      // Check platform
      debugPrint("📱 Platform: ${Platform.isIOS ? 'iOS' : 'Android'}");
      
      // Check current badge count
      final currentBadge = await getCurrentBadgeCount();
      debugPrint("🔢 Current badge count: $currentBadge");
      
      // Check database count
      final dbCount = await NotificationDatabase.instance.getUnreadNotificationCount();
      debugPrint("💾 Database unread count: $dbCount");
      
      debugPrint("🔍 === END DEBUG INFO ===");
    } catch (e) {
      debugPrint("❌ Error in debug settings: $e");
    }
  }

  // Method to manually refresh notification list and badge
  static Future<void> refreshNotificationList() async {
    try {
      debugPrint("🔄 Refreshing notification list and badge...");
      
      // Sync badge with database
      await syncBadgeWithDatabase();
      
      // Refresh notification controller if it exists
      if (Get.isRegistered<NotificationApiController>()) {
        final controller = Get.find<NotificationApiController>();
        controller.loadLocalNotifications();
        debugPrint("✅ Notification controller refreshed");
      }
      
      debugPrint("✅ Notification list and badge refreshed");
    } catch (e) {
      debugPrint("❌ Error refreshing notification list: $e");
    }
  }

  // Method to update notification controller unread count
  static Future<void> updateNotificationController() async {
    try {
      if (Get.isRegistered<NotificationApiController>()) {
        final controller = Get.find<NotificationApiController>();
        // Update the unread count directly
        controller.unreadCount.value = await NotificationDatabase.instance.getUnreadNotificationCount();
        debugPrint("✅ Notification controller unread count updated to: ${controller.unreadCount.value}");
      }
    } catch (e) {
      debugPrint("❌ Error updating notification controller: $e");
    }
  }

  // Method to test foreground notification handling
  static Future<void> testForegroundNotification() async {
    try {
      debugPrint("🧪 Testing foreground notification...");
      
      // Create a mock RemoteMessage for testing
      final mockMessage = RemoteMessage(
        data: {
          'title': 'Test Foreground Notification',
          'body': 'This is a test notification for foreground handling',
          'channelKey': 'mpm_app_channel',
          'image': '',
        },
        notification: RemoteNotification(
          title: 'Test Foreground Notification',
          body: 'This is a test notification for foreground handling',
        ),
        messageId: 'test_${DateTime.now().millisecondsSinceEpoch}',
        from: 'test',
        sentTime: DateTime.now(),
      );
      
      // Test the foreground handler
      await handleIncomingFCMForeground(mockMessage);
      
      debugPrint("✅ Foreground notification test completed");
    } catch (e) {
      debugPrint("❌ Foreground notification test failed: $e");
    }
  }

  // Method to test badge count specifically
  static Future<void> testBadgeCount() async {
    try {
      debugPrint("🔢 Testing badge count...");
      
      // Get current badge count
      final currentBadge = await getCurrentBadgeCount();
      debugPrint("📊 Current badge count: $currentBadge");
      
      // Test incrementing badge
      final newBadge = currentBadge + 1;
      debugPrint("📊 Testing badge count: $newBadge");
      
      // Update badge using the service
      final service = NotificationService();
      await service._updateBadgeCount(newBadge);
      
      // Wait a moment
      await Future.delayed(Duration(seconds: 2));
      
      // Check if badge was updated
      final updatedBadge = await getCurrentBadgeCount();
      debugPrint("📊 Updated badge count: $updatedBadge");
      
      if (updatedBadge == newBadge) {
        debugPrint("✅ Badge count test successful");
      } else {
        debugPrint("❌ Badge count test failed - expected: $newBadge, got: $updatedBadge");
      }
      
    } catch (e) {
      debugPrint("❌ Badge count test failed: $e");
    }
  }

  // Method to check iOS badge permissions and settings
  static Future<void> checkIOSBadgeSettings() async {
    try {
      debugPrint("🍎 === iOS BADGE SETTINGS CHECK ===");
      
      if (!Platform.isIOS) {
        debugPrint("⚠️ Not running on iOS");
        return;
      }
      
      // Check FCM badge permission
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      debugPrint("🔥 FCM Badge Setting: ${settings.badge}");
      
      // Check if badge is supported
      final isSupported = await FlutterAppBadger.isAppBadgeSupported();
      debugPrint("📱 Badge supported: $isSupported");
      
      // Get current badge count
      final currentBadge = await getCurrentBadgeCount();
      debugPrint("🔢 Current badge count: $currentBadge");
      
      // Check database count
      final dbCount = await NotificationDatabase.instance.getUnreadNotificationCount();
      debugPrint("💾 Database unread count: $dbCount");
      
      // Check notification controller count
      if (Get.isRegistered<NotificationApiController>()) {
        final controller = Get.find<NotificationApiController>();
        debugPrint("🎯 Notification controller unread count: ${controller.unreadCount.value}");
      }
      
      debugPrint("🍎 === END BADGE SETTINGS CHECK ===");
      
    } catch (e) {
      debugPrint("❌ Error checking iOS badge settings: $e");
    }
  }

  // Method to test notification controller update
  static Future<void> testNotificationControllerUpdate() async {
    try {
      debugPrint("🎯 Testing notification controller update...");
      
      if (!Get.isRegistered<NotificationApiController>()) {
        debugPrint("❌ NotificationApiController not registered");
        return;
      }
      
      final controller = Get.find<NotificationApiController>();
      final beforeCount = controller.unreadCount.value;
      debugPrint("📊 Before update - Controller count: $beforeCount");
      
      // Update the controller
      await updateNotificationController();
      
      final afterCount = controller.unreadCount.value;
      debugPrint("📊 After update - Controller count: $afterCount");
      
      debugPrint("✅ Notification controller update test completed");
    } catch (e) {
      debugPrint("❌ Notification controller update test failed: $e");
    }
  }

  // Method to handle app startup - load notifications from database
  static Future<void> handleAppStartup() async {
    try {
      debugPrint("🚀 Handling app startup - loading notifications...");
      
      // Sync badge with database
      await syncBadgeWithDatabase();
      
      // Update notification controller if it exists
      await updateNotificationController();
      
      debugPrint("✅ App startup notification loading completed");
    } catch (e) {
      debugPrint("❌ Error handling app startup: $e");
    }
  }

  // Method to test background notification simulation
  static Future<void> testBackgroundNotification() async {
    try {
      debugPrint("🌙 Testing background notification simulation...");
      
      // Create a mock RemoteMessage for testing
      final mockMessage = RemoteMessage(
        data: {
          'title': 'Test Background Notification',
          'body': 'This is a test background notification',
          'channelKey': 'mpm_app_channel',
          'image': '',
        },
        notification: RemoteNotification(
          title: 'Test Background Notification',
          body: 'This is a test background notification',
        ),
        messageId: 'test_bg_${DateTime.now().millisecondsSinceEpoch}',
        from: 'test',
        sentTime: DateTime.now(),
      );
      
      // Test the background handler
      await handleIncomingFCMBackground(mockMessage);
      
      // Also test creating local notification
      await createLocalNotificationFromMessage(mockMessage);
      
      debugPrint("✅ Background notification test completed");
    } catch (e) {
      debugPrint("❌ Background notification test failed: $e");
    }
  }

  // Method to test complete background/closed app notification flow
  static Future<void> testCompleteBackgroundFlow() async {
    try {
      debugPrint("🔄 Testing complete background/closed app notification flow...");
      
      // Create a mock RemoteMessage for testing
      final mockMessage = RemoteMessage(
        data: {
          'title': 'Test Complete Background Flow',
          'body': 'This tests the complete background notification flow',
          'channelKey': 'mpm_app_channel',
          'image': '',
        },
        notification: RemoteNotification(
          title: 'Test Complete Background Flow',
          body: 'This tests the complete background notification flow',
        ),
        messageId: 'test_complete_${DateTime.now().millisecondsSinceEpoch}',
        from: 'test',
        sentTime: DateTime.now(),
      );
      
      // Simulate the complete background handler flow
      debugPrint("1. Simulating background handler...");
      await firebaseMessagingBackgroundHandler(mockMessage);
      
      // Wait a moment
      await Future.delayed(Duration(seconds: 1));
      
      // Check status
      debugPrint("2. Checking final status...");
      await checkDatabaseAndBadgeStatus();
      
      debugPrint("✅ Complete background flow test completed");
    } catch (e) {
      debugPrint("❌ Complete background flow test failed: $e");
    }
  }

  // Method to show correct FCM payload format
  static void showCorrectFCMPayload() {
    debugPrint("📋 === CORRECT FCM PAYLOAD FOR BACKGROUND NOTIFICATIONS ===");
    debugPrint("""
{
    "message": {
        "token": "YOUR_DEVICE_TOKEN_HERE",
        "apns": {
            "headers": {
                "apns-priority": "10",
                "apns-push-type": "alert"
            },
            "payload": {
                "aps": {
                    "alert": {
                        "title": "Test Notification",
                        "body": "New Event"
                    },
                    "badge": 1,
                    "sound": "default",
                    "mutable-content": 1
                }
            }
        },
        "notification": {
            "title": "Test Notification",
            "body": "New Event"
        },
        "data": {
            "title": "Test Notification",
            "body": "New Event",
            "channelKey": "mpm_app_channel",
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "image": "https://members.mumbaimaheshwari.com/api/public/assets/notification/20250813074852_notification.jpeg"
        }
    }
}
    """);
    debugPrint("📋 === END CORRECT FCM PAYLOAD ===");
    debugPrint("❌ ISSUES WITH YOUR CURRENT PAYLOAD:");
    debugPrint("1. 'apns-priority': '5' should be '10' for regular notifications");
    debugPrint("2. 'content-available': 1 makes it silent - remove this");
    debugPrint("3. Missing 'alert' in APNs payload - iOS needs this");
    debugPrint("4. Add 'mutable-content': 1 for image notifications");
  }

  // Method to check database and badge status
  static Future<void> checkDatabaseAndBadgeStatus() async {
    try {
      debugPrint("🔍 === DATABASE AND BADGE STATUS ===");
      
      // Check database count
      final dbCount = await NotificationDatabase.instance.getUnreadNotificationCount();
      debugPrint("💾 Database unread count: $dbCount");
      
      // Check saved badge count
      final savedBadge = await getCurrentBadgeCount();
      debugPrint("🔢 Saved badge count: $savedBadge");
      
      // Check notification controller count
      if (Get.isRegistered<NotificationApiController>()) {
        final controller = Get.find<NotificationApiController>();
        debugPrint("🎯 Controller unread count: ${controller.unreadCount.value}");
      }
      
      // Check if counts match
      if (dbCount == savedBadge) {
        debugPrint("✅ Database and badge counts match");
      } else {
        debugPrint("❌ Database and badge counts don't match!");
      }
      
      debugPrint("🔍 === END STATUS CHECK ===");
    } catch (e) {
      debugPrint("❌ Error checking status: $e");
    }
  }

  // Method to create local notification from FCM message (for background/closed app)
  static Future<void> createLocalNotificationFromMessage(RemoteMessage message) async {
    try {
      debugPrint("📱 Creating local notification from FCM message...");
      
      // Get notification data
      final title = message.notification?.title ?? 
                   message.data['title'] ?? 
                   "MPM Notification";
      final body = message.notification?.body ?? 
                  message.data['body'] ?? 
                  "You have a new message";
      final image = message.notification?.android?.imageUrl ?? 
                   message.data['image'] ?? 
                   "";

      // Get current badge count
      final badgeCount = await getCurrentBadgeCount();
      final newBadgeCount = badgeCount + 1;

      // Create notification
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: message.data['channelKey'] ?? 'mpm_app_channel',
          title: title,
          body: body,
          bigPicture: (image.isNotEmpty) ? image : null,
          notificationLayout: (image.isNotEmpty)
              ? NotificationLayout.BigPicture
              : NotificationLayout.Default,
          autoDismissible: true,
          showWhen: true,
          badge: newBadgeCount,
          payload: message.data.map((key, value) => MapEntry(key, value?.toString())),
          wakeUpScreen: true,
          displayOnBackground: true,
          displayOnForeground: true,
        ),
      );

      // Update badge count
      await _saveBadgeCountStatic(newBadgeCount);
      await _updateBadgeCountStatic(newBadgeCount);

      debugPrint("✅ Local notification created with badge: $newBadgeCount");
    } catch (e) {
      debugPrint("❌ Error creating local notification: $e");
    }
  }

  // Helper method to update badge count (static version)
  static Future<void> _updateBadgeCountStatic(int badgeCount) async {
    try {
      debugPrint("🔢 Updating badge count to: $badgeCount");
      
      // Method 1: Awesome Notifications
      try {
        await AwesomeNotifications().setGlobalBadgeCounter(badgeCount);
        debugPrint("✅ Awesome Notifications badge updated to: $badgeCount");
      } catch (e) {
        debugPrint("❌ Awesome Notifications badge update failed: $e");
      }
      
      // Method 2: Flutter App Badger (iOS specific)
      if (Platform.isIOS) {
        try {
          if (badgeCount > 0) {
            await FlutterAppBadger.updateBadgeCount(badgeCount);
            debugPrint("✅ Flutter App Badger updated (iOS) to: $badgeCount");
          } else {
            await FlutterAppBadger.removeBadge();
            debugPrint("✅ Flutter App Badger removed (iOS)");
          }
        } catch (e) {
          debugPrint("❌ Flutter App Badger update failed: $e");
        }
      }
      
    } catch (e) {
      debugPrint("❌ Error updating badge count: $e");
    }
  }

  // Helper method to save badge count (static version)
  static Future<void> _saveBadgeCountStatic(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_badgeKey, count);
      debugPrint("Badge count saved: $count");
    } catch (e) {
      debugPrint("Error saving badge count: $e");
    }
  }

  // Awesome callbacks
  static Future<void> onActionReceived(ReceivedAction action) async {
    debugPrint("User tapped notification: ${action.payload}");
    
    try {
      // Navigate to dashboard first
      Get.offAllNamed(RouteNames.dashboard);
      
      // Wait for dashboard to load, then switch to notification tab
      Future.delayed(Duration(milliseconds: 1000), () {
        try {
          if (Get.isRegistered<UdateProfileController>()) {
            final dashboardController = Get.find<UdateProfileController>();
            dashboardController.changeTab(3); // Switch to notification tab (index 3)
            debugPrint("✅ Switched to notification tab");
          }
        } catch (e) {
          debugPrint("❌ Error switching to notification tab: $e");
        }
      });
      
      // Refresh notification list and sync badge
      await refreshNotificationList();
      
      debugPrint("✅ Navigated to dashboard and refreshed list");
    } catch (e) {
      debugPrint("❌ Error handling notification tap: $e");
    }
  }

  static Future<void> onNotificationCreated(ReceivedNotification notification) async {}
  static Future<void> onNotificationDisplayed(ReceivedNotification notification) async {}
  static Future<void> onDismissActionReceived(ReceivedAction action) async {
    int count = await _getSavedBadgeCount();
    count = (count > 0) ? count - 1 : 0;
    await _saveBadgeCount(count);
    await AwesomeNotifications().setGlobalBadgeCounter(count);
  }
}

// Top-level background handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("🔥 Background FCM received: ${message.data}");
  try {
    // Initialize Firebase for background context
    await Firebase.initializeApp();
    
    // Initialize SharedPreferences for background context
    await SharedPreferences.getInstance();
    
    // Initialize Awesome Notifications for background context
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'mpm_app_channel',
          channelName: 'General Notifications',
          channelDescription: 'App messages',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          playSound: true,
          channelShowBadge: true,
          enableVibration: true,
          enableLights: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelKey: 'mpm_background_channel',
          channelName: 'Background Notifications',
          channelDescription: 'Background app messages',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          channelShowBadge: true,
          enableVibration: true,
          enableLights: true,
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
    
    // Handle the notification in background-safe way
    await NotificationService.handleIncomingFCMBackground(message);
    
    // Also create a local notification to ensure it shows on device
    await NotificationService.createLocalNotificationFromMessage(message);
    
    debugPrint("✅ Background notification handled successfully");
  } catch (e) {
    debugPrint("❌ Error in background handler: $e");
  }
}
