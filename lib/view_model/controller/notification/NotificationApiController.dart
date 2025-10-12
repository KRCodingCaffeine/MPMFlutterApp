import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mpm/model/notification/NotificationDataModel.dart';
import 'package:mpm/repository/notification_repository/notification_repo.dart';
import 'package:mpm/utils/NotificationDatabase.dart';
import 'package:mpm/utils/notification_service.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/route/route_name.dart';

class NotificationApiController extends GetxController with WidgetsBindingObserver {
  final NotificationRepository _repository = NotificationRepository();
  
  // Observable variables
  final RxList<NotificationDataModel> notificationList = <NotificationDataModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final Rx<Status> requestStatus = Status.LOADING.obs;
  final RxBool isLoading = false.obs;
  
  Timer? _periodicTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _periodicTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _simpleSyncWithServer();
    }
  }

  /// Initialize notifications - Always sync with server first
  Future<void> _initializeNotifications() async {
    debugPrint('🚀 Initializing notifications...');
    isLoading.value = true;
    try {
      // Always sync with server first to get latest data
      debugPrint('🔄 Step 1: Syncing with server...');
      await _simpleSyncWithServer().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏰ Server sync timed out, loading local data');
          // If server times out, load local data
          loadLocalNotifications();
        },
      );

      debugPrint('✅ Notifications initialized - Local: ${notificationList.length}, Unread: ${unreadCount.value}');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
      // Fallback: just load local
      debugPrint('🔄 Fallback: Loading local notifications only...');
      await loadLocalNotifications();
    } finally {
      isLoading.value = false;
      debugPrint('🏁 Initialization completed');
    }
  }

  /// Load notifications from local database
  Future<void> loadLocalNotifications() async {
    try {
      debugPrint('📱 Loading local notifications...');
      
      final notifications = await NotificationDatabase.instance.getAllNotifications();
      notificationList.value = notifications;
      
      final unreadCountValue = await NotificationDatabase.instance.getUnreadNotificationCount();
      unreadCount.value = unreadCountValue;
      
      // Update badge count
      await NotificationService.updateBadgeCount(unreadCount.value);
      
      debugPrint('📊 Local notifications loaded: ${notificationList.length}, unread: $unreadCount');
      
      // Debug: Print each notification's read status
      for (int i = 0; i < notificationList.length; i++) {
        final notification = notificationList[i];
        debugPrint('📋 Notification $i: ${notification.title} (ID: ${notification.id}, Read: ${notification.isRead})');
      }
    } catch (e) {
      debugPrint('❌ Error loading local notifications: $e');
      notificationList.value = [];
      unreadCount.value = 0;
    }
  }

  /// Force sync with server - Always overwrite local with server data
  Future<void> _simpleSyncWithServer() async {
    try {
      debugPrint('🔄 Force syncing with server...');

      // Get notifications from server (with timeout)
      final response = await _repository.getAllNotifications().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          debugPrint('⏰ Server API call timed out');
          throw TimeoutException('Server API timeout', const Duration(seconds: 8));
        },
      );

      if (response.status && response.notifications.isNotEmpty) {
        debugPrint('📡 Server has ${response.notifications.length} notifications');

        // ALWAYS clear local database and replace with server data
        debugPrint('🗑️ Clearing local database...');
        await NotificationDatabase.instance.deleteAllNotifications();

        // Insert server notifications exactly as they are
        for (final serverNotification in response.notifications) {
          final localNotification = serverNotification.toLocalModel();
          debugPrint('📝 Inserting notification: ${localNotification.title} (ID: ${localNotification.id}, Read: ${localNotification.isRead})');
          await NotificationDatabase.instance.insertNotification(localNotification);
        }

        // Reload local notifications
        await loadLocalNotifications();
        debugPrint('✅ Local database force synced with server data');
      } else {
        debugPrint('📡 Server has no notifications or error: ${response.message}');
        // If server has no notifications, clear local too
        await NotificationDatabase.instance.deleteAllNotifications();
        await loadLocalNotifications();
      }
    } catch (e) {
      debugPrint('❌ Error syncing with server: $e');
    }
  }

  /// Mark notification as read - Update server first, then sync
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      debugPrint('📖 Marking notification $notificationId as read...');

      // Update server first
      try {
        final response = await _repository.markNotificationAsRead(notificationId);
        debugPrint('📡 Server response for notification $notificationId: ${response.status} - ${response.message}');
        if (response.status) {
          debugPrint('✅ Server updated for notification $notificationId');
          
          // Force sync with server to get updated data
          debugPrint('🔄 Syncing with server after update...');
          await _simpleSyncWithServer();
        } else {
          debugPrint('❌ Server update failed for notification $notificationId: ${response.message}');
          // If server update fails, still update local
          await NotificationDatabase.instance.markNotificationAsRead(notificationId);
          await loadLocalNotifications();
        }
      } catch (e) {
        debugPrint('❌ Error updating server for notification $notificationId: $e');
        // If server update fails, still update local
        await NotificationDatabase.instance.markNotificationAsRead(notificationId);
        await loadLocalNotifications();
      }

    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read - Update server first, then sync
  Future<void> markAllNotificationsAsRead() async {
    try {
      debugPrint('📖 Marking all notifications as read...');

      // Update server first
      try {
        final response = await _repository.markAllNotificationsAsRead();
        debugPrint('📡 Server response for all notifications: ${response.status} - ${response.message}');
        if (response.status) {
          debugPrint('✅ Server updated for all notifications');
          
          // Force sync with server to get updated data
          debugPrint('🔄 Syncing with server after update...');
          await _simpleSyncWithServer();
        } else {
          debugPrint('❌ Server update failed for all notifications: ${response.message}');
          // If server update fails, still update local
          await NotificationDatabase.instance.markAllNotificationsAsRead();
          await loadLocalNotifications();
        }
      } catch (e) {
        debugPrint('❌ Error updating server for all notifications: $e');
        // If server update fails, still update local
        await NotificationDatabase.instance.markAllNotificationsAsRead();
        await loadLocalNotifications();
      }

    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
    }
  }

  /// Delete notification - Update both local and server
  Future<void> deleteNotification(int notificationId) async {
    try {
      debugPrint('🗑️ Deleting notification $notificationId...');
      
      // Update local database
      await NotificationDatabase.instance.deleteNotificationById(notificationId);
      
      // Update server
      try {
        await _repository.deleteNotification(notificationId);
        debugPrint('✅ Server updated for notification $notificationId');
      } catch (e) {
        debugPrint('❌ Error updating server for notification $notificationId: $e');
      }
      
      // Reload local notifications to update UI
      await loadLocalNotifications();
      
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
    }
  }

  /// Delete all notifications - Update both local and server
  Future<void> deleteAllNotifications() async {
    try {
      debugPrint('🗑️ Deleting all notifications...');
      
      // Update local database
      await NotificationDatabase.instance.deleteAllNotifications();
      
      // Update server
      try {
        await _repository.deleteAllNotifications();
        debugPrint('✅ Server updated for all notifications');
      } catch (e) {
        debugPrint('❌ Error updating server for all notifications: $e');
      }
      
      // Reload local notifications to update UI
      await loadLocalNotifications();
      
    } catch (e) {
      debugPrint('❌ Error deleting all notifications: $e');
    }
  }

  /// Handle notification tap
  void handleNotificationTap(NotificationDataModel notification) {
    try {
      debugPrint('👆 Notification tapped: ${notification.title} (Local ID: ${notification.id}, Server ID: ${notification.serverId}, Read: ${notification.isRead})');
      
      // Mark as read if not already read - use serverId (notification_queue_id) instead of local id
      if (!notification.isRead && notification.serverId != null) {
        final serverId = int.tryParse(notification.serverId!);
        if (serverId != null) {
          debugPrint('📖 Marking notification with server ID ${serverId} as read...');
          markNotificationAsRead(serverId);
        } else {
          debugPrint('❌ Invalid server ID: ${notification.serverId}');
        }
      } else {
        debugPrint('ℹ️ Notification ${notification.id} is already read or has no server ID, skipping mark as read');
      }
      
      // Navigate to detail screen
      debugPrint('🧭 Navigating to notification detail screen...');
      Get.toNamed(RouteNames.notification_detail, arguments: notification);
      
    } catch (e) {
      debugPrint('❌ Error handling notification tap: $e');
    }
  }

  /// Refresh notifications - Simple sync with server
  Future<void> refreshNotifications() async {
    try {
      debugPrint('🔄 Refreshing notifications...');
      isLoading.value = true;
      
      await _simpleSyncWithServer();
      
      debugPrint('✅ Notifications refreshed');
    } catch (e) {
      debugPrint('❌ Error refreshing notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Force sync with server - Clear local and sync
  Future<void> forceSyncWithServer() async {
    try {
      debugPrint('🔄 Force syncing with server...');
      isLoading.value = true;
      
      // Clear local database
      await NotificationDatabase.instance.deleteAllNotifications();
      
      // Sync with server
      await _simpleSyncWithServer();
      
      debugPrint('✅ Force sync completed');
    } catch (e) {
      debugPrint('❌ Error in force sync: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Start periodic sync
  void _startPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _simpleSyncWithServer();
    });
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _periodicTimer?.cancel();
  }

  /// Start periodic sync
  void startPeriodicSync() {
    _startPeriodicSync();
  }

  /// Simple test method to check if controller is working
  void testController() {
    try {
      debugPrint('🧪 Testing notification controller...');
      debugPrint('📊 Current notification count: ${notificationList.length}');
      debugPrint('📊 Current unread count: ${unreadCount.value}');
      debugPrint('📊 Is loading: ${isLoading.value}');
      debugPrint('✅ Controller test completed successfully');
    } catch (e) {
      debugPrint('❌ Controller test failed: $e');
    }
  }

  /// Test local database only (no server calls)
  Future<void> testLocalOnly() async {
    try {
      debugPrint('🧪 Testing local database only...');
      await loadLocalNotifications();
      debugPrint('✅ Local database test completed');
    } catch (e) {
      debugPrint('❌ Local database test failed: $e');
    }
  }

  /// Test server API by trying to mark a notification as read
  Future<void> testServerApi() async {
    try {
      debugPrint('🧪 Testing server API...');
      
      // Get first notification to test with
      final notifications = await NotificationDatabase.instance.getAllNotifications();
      if (notifications.isNotEmpty) {
        final testNotification = notifications.first;
        debugPrint('📝 Testing with notification: ${testNotification.title} (ID: ${testNotification.id})');
        
        // Try to mark it as read
        final response = await _repository.markNotificationAsRead(testNotification.id ?? 0);
        debugPrint('📡 Server API test response: ${response.status} - ${response.message}');
        
        if (response.status) {
          debugPrint('✅ Server API test successful');
        } else {
          debugPrint('❌ Server API test failed: ${response.message}');
        }
      } else {
        debugPrint('❌ No notifications available to test with');
      }
    } catch (e) {
      debugPrint('❌ Server API test failed with error: $e');
    }
  }

  /// Test server API with different formats
  Future<void> testServerApiFormats() async {
    try {
      debugPrint('🧪 Testing server API with different formats...');
      
      // Get first notification to test with
      final notifications = await NotificationDatabase.instance.getAllNotifications();
      if (notifications.isNotEmpty) {
        final testNotification = notifications.first;
        debugPrint('📝 Testing with notification: ${testNotification.title} (ID: ${testNotification.id})');
        
        // Test with current format (type="2" - form data)
        debugPrint('🔄 Testing with current format (type="2" - form data)...');
        try {
          final response1 = await _repository.markNotificationAsRead(testNotification.id ?? 0);
          debugPrint('📡 Form data response: ${response1.status} - ${response1.message}');
        } catch (e) {
          debugPrint('❌ Form data test failed: $e');
        }
        
        // Wait a bit between tests
        await Future.delayed(const Duration(seconds: 2));
        
        // Test with JSON format (type="1" - JSON)
        debugPrint('🔄 Testing with JSON format (type="1" - JSON)...');
        try {
          final response2 = await _repository.markNotificationAsReadJson(testNotification.id ?? 0);
          debugPrint('📡 JSON response: ${response2.status} - ${response2.message}');
        } catch (e) {
          debugPrint('❌ JSON test failed: $e');
        }
      } else {
        debugPrint('❌ No notifications available to test with');
      }
    } catch (e) {
      debugPrint('❌ Server API format test failed with error: $e');
    }
  }

  /// Check server API status
  Future<void> checkServerApiStatus() async {
    try {
      debugPrint('🔍 Checking server API status...');
      
      final response = await _repository.getAllNotifications();
      debugPrint('📡 Server response: ${response.status} - ${response.message}');
      debugPrint('📡 Server notifications: ${response.notifications.length}');
      
      // Debug each server notification
      for (int i = 0; i < response.notifications.length; i++) {
        final notification = response.notifications[i];
        debugPrint('📡 Server notification $i: ${notification.title} (ID: ${notification.id}, Read: ${notification.isRead})');
      }
      
      final localCount = await NotificationDatabase.instance.getAllNotifications();
      debugPrint('📱 Local notifications: ${localCount.length}');
      
      // Debug each local notification
      for (int i = 0; i < localCount.length; i++) {
        final notification = localCount[i];
        debugPrint('📱 Local notification $i: ${notification.title} (ID: ${notification.id}, Read: ${notification.isRead})');
      }
      
    } catch (e) {
      debugPrint('❌ Error checking server status: $e');
    }
  }

  /// Sync read status with server
  Future<void> syncReadStatusWithServer() async {
    try {
      debugPrint('🔄 Syncing read status with server...');
      
      // Get local notifications
      final localNotifications = await NotificationDatabase.instance.getAllNotifications();
      
      // Update server for each read notification
      for (final notification in localNotifications) {
        if (notification.isRead) {
          try {
            await _repository.markNotificationAsRead(notification.id ?? 0);
            debugPrint('✅ Synced read status for notification ${notification.id}');
          } catch (e) {
            debugPrint('❌ Error syncing read status for notification ${notification.id}: $e');
          }
        }
      }
      
      debugPrint('✅ Read status sync completed');
    } catch (e) {
      debugPrint('❌ Error syncing read status: $e');
    }
  }

  /// Reset local read status to match server
  Future<void> resetLocalReadStatusToMatchServer() async {
    try {
      debugPrint('🔄 Resetting local read status to match server...');
      
      // Get server notifications
      final response = await _repository.getAllNotifications();
      
      if (response.status) {
        // Clear local database
        await NotificationDatabase.instance.deleteAllNotifications();
        
        // Insert server notifications with server read status
        for (final serverNotification in response.notifications) {
          final localNotification = serverNotification.toLocalModel();
          await NotificationDatabase.instance.insertNotification(localNotification);
        }
        
        // Reload local notifications
        await loadLocalNotifications();
        
        debugPrint('✅ Local read status reset to match server');
      }
    } catch (e) {
      debugPrint('❌ Error resetting local read status: $e');
    }
  }

  /// Force re-initialization
  Future<void> forceReinitialize() async {
    try {
      debugPrint('🔄 Force re-initializing notifications...');
      isLoading.value = true;
      
      // Clear local state
      notificationList.clear();
      unreadCount.value = 0;
      
      // Re-initialize
      await _initializeNotifications();
      
      debugPrint('✅ Force re-initialization completed');
    } catch (e) {
      debugPrint('❌ Error in force re-initialization: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Force sync read status with server
  Future<void> forceSyncReadStatus() async {
    try {
      debugPrint('🔄 Force syncing read status with server...');
      
      // Get current local notifications
      final localNotifications = await NotificationDatabase.instance.getAllNotifications();
      debugPrint('📱 Found ${localNotifications.length} local notifications');
      
      // Update server for each read notification
      for (final notification in localNotifications) {
        if (notification.isRead && notification.id != null) {
          try {
            debugPrint('📤 Syncing read status for notification ${notification.id}...');
            final response = await _repository.markNotificationAsRead(notification.id!);
            debugPrint('📡 Server response for ${notification.id}: ${response.status} - ${response.message}');
          } catch (e) {
            debugPrint('❌ Error syncing notification ${notification.id}: $e');
          }
        }
      }
      
      // Force sync with server to get updated status
      debugPrint('🔄 Force syncing with server to get updated status...');
      await _simpleSyncWithServer();
      
      debugPrint('✅ Force sync read status completed');
    } catch (e) {
      debugPrint('❌ Error in force sync read status: $e');
    }
  }

  /// Complete reset and sync - Clear everything and sync with server
  Future<void> completeResetAndSync() async {
    try {
      debugPrint('🔄 Complete reset and sync...');
      isLoading.value = true;
      
      // Clear local database completely
      debugPrint('🗑️ Clearing local database...');
      await NotificationDatabase.instance.deleteAllNotifications();
      
      // Clear local state
      notificationList.clear();
      unreadCount.value = 0;
      
      // Force sync with server
      debugPrint('🔄 Syncing with server...');
      await _simpleSyncWithServer();
      
      debugPrint('✅ Complete reset and sync completed');
    } catch (e) {
      debugPrint('❌ Error in complete reset and sync: $e');
    } finally {
      isLoading.value = false;
    }
  }
}