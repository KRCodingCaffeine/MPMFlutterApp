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
  final RxInt unreadEventCount = 0.obs; // Unread notifications with type "event"
  final RxInt unreadOfferCount = 0.obs; // Unread notifications with type "offer"
  final RxInt unreadDefaultCount = 0.obs; // Unread notifications with type "default"
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
      
      // Ensure notifications are sorted by timestamp (latest first)
      notifications.sort((a, b) {
        try {
          final aTime = DateTime.parse(a.timestamp);
          final bTime = DateTime.parse(b.timestamp);
          return bTime.compareTo(aTime); // Latest first (DESC)
        } catch (e) {
          debugPrint('❌ Error parsing timestamp: $e');
          return 0;
        }
      });
      
      notificationList.value = notifications;
      
      final unreadCountValue = await NotificationDatabase.instance.getUnreadNotificationCount();
      unreadCount.value = unreadCountValue;
      
      // Update type-specific unread counts
      unreadEventCount.value = await NotificationDatabase.instance.getUnreadNotificationCountByType('event');
      unreadOfferCount.value = await NotificationDatabase.instance.getUnreadNotificationCountByType('offer');
      unreadDefaultCount.value = await NotificationDatabase.instance.getUnreadNotificationCountByType('default');
      
      // Update badge count (use default count for bottom navigation badge)
      await NotificationService.updateBadgeCount(unreadDefaultCount.value);
      
      debugPrint('📊 Local notifications loaded: ${notificationList.length}, unread: $unreadCount, events: $unreadEventCount, offers: $unreadOfferCount, default: $unreadDefaultCount');
      
      // Debug: Print each notification's read status, type, and timestamp
      debugPrint('📋 === NOTIFICATION DETAILS ===');
      for (int i = 0; i < notificationList.length; i++) {
        final notification = notificationList[i];
        debugPrint('📋 Notification $i: ${notification.title} (ID: ${notification.id}, ServerID: ${notification.serverId}, Type: ${notification.type}, Read: ${notification.isRead}, Time: ${notification.timestamp})');
      }
      debugPrint('📋 === END NOTIFICATION DETAILS ===');
      
      // Debug: Count by type
      final eventNotifications = notificationList.where((n) => n.type == 'event').toList();
      final unreadEventNotifications = eventNotifications.where((n) => !n.isRead).toList();
      debugPrint('📊 Event notifications: Total=${eventNotifications.length}, Unread=${unreadEventNotifications.length}');
      for (final event in unreadEventNotifications) {
        debugPrint('  - Unread Event: ${event.title} (ServerID: ${event.serverId}, Read: ${event.isRead})');
      }
    } catch (e) {
      debugPrint('❌ Error loading local notifications: $e');
      notificationList.value = [];
      unreadCount.value = 0;
      unreadEventCount.value = 0;
      unreadOfferCount.value = 0;
      unreadDefaultCount.value = 0;
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

        // Sort server notifications by timestamp (latest first) before inserting
        final sortedNotifications = response.notifications.toList();
        sortedNotifications.sort((a, b) {
          try {
            final aTime = DateTime.parse(a.timestamp);
            final bTime = DateTime.parse(b.timestamp);
            return bTime.compareTo(aTime); // Latest first (DESC)
          } catch (e) {
            debugPrint('❌ Error parsing server notification timestamp: $e');
            return 0;
          }
        });

        // Insert server notifications in sorted order
        for (final serverNotification in sortedNotifications) {
          final localNotification = serverNotification.toLocalModel();
          debugPrint('📝 Inserting notification: ${localNotification.title} (ID: ${localNotification.id}, ServerID: ${localNotification.serverId}, Type: ${localNotification.type}, Read: ${localNotification.isRead}, Time: ${localNotification.timestamp})');
          await NotificationDatabase.instance.insertNotification(localNotification);
        }
        
        // Debug: Count event notifications after insert
        final allAfterInsert = await NotificationDatabase.instance.getAllNotifications();
        final eventAfterInsert = allAfterInsert.where((n) => n.type == 'event').toList();
        final unreadEventAfterInsert = eventAfterInsert.where((n) => !n.isRead).toList();
        debugPrint('📊 After insert - Event notifications: Total=${eventAfterInsert.length}, Unread=${unreadEventAfterInsert.length}');

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

  /// Mark notifications as read by event_offer_id
  Future<void> markNotificationsAsReadByEventOfferId(String eventOfferId) async {
    try {
      debugPrint('📖 Marking notifications as read for eventOfferId: $eventOfferId...');
      
      // Get all unread notifications with this event_offer_id from database
      final allNotifications = await NotificationDatabase.instance.getAllNotifications();
      final unreadNotifications = allNotifications.where((n) => !n.isRead && n.eventOfferId == eventOfferId).toList();
      
      if (unreadNotifications.isEmpty) {
        debugPrint('ℹ️ No unread notifications found for eventOfferId: $eventOfferId');
        return;
      }
      
      debugPrint('📋 Found ${unreadNotifications.length} unread notifications for eventOfferId: $eventOfferId');
      
      // Update server for each notification
      final List<Future<void>> serverUpdates = [];
      for (final notification in unreadNotifications) {
        if (notification.serverId != null) {
          final serverId = int.tryParse(notification.serverId!);
          if (serverId != null) {
            serverUpdates.add(
              _repository.markNotificationAsRead(serverId).then((response) {
                if (response.status) {
                  debugPrint('✅ Marked notification ${notification.serverId} as read on server');
                } else {
                  debugPrint('❌ Server returned error for notification ${notification.serverId}: ${response.message}');
                }
              }).catchError((e) {
                debugPrint('❌ Error marking notification ${notification.serverId} as read on server: $e');
              })
            );
          }
        }
      }
      
      // Wait for all server updates to complete
      await Future.wait(serverUpdates, eagerError: false);
      debugPrint('📡 Completed ${serverUpdates.length} server update requests');
      
      // Update local database
      final updatedCount = await NotificationDatabase.instance.markNotificationsAsReadByEventOfferId(eventOfferId);
      debugPrint('✅ Updated local database: marked $updatedCount notifications as read');
      
      // Reload local notifications to update UI
      await loadLocalNotifications();
      
      debugPrint('✅ Notifications for eventOfferId $eventOfferId marked as read');
    } catch (e) {
      debugPrint('❌ Error marking notifications as read by eventOfferId: $e');
      // Even if there's an error, try to update local database
      try {
        await NotificationDatabase.instance.markNotificationsAsReadByEventOfferId(eventOfferId);
        await loadLocalNotifications();
      } catch (localError) {
        debugPrint('❌ Error updating local database: $localError');
      }
    }
  }

  /// Check if a specific event_offer_id has unread notifications
  Future<bool> hasUnreadNotificationsByEventOfferId(String eventOfferId) async {
    try {
      return await NotificationDatabase.instance.hasUnreadNotificationsByEventOfferId(eventOfferId);
    } catch (e) {
      debugPrint('❌ Error checking unread notifications by eventOfferId: $e');
      return false;
    }
  }

  /// Mark all notifications as read by type (e.g., "event", "offer")
  Future<void> markNotificationsAsReadByType(String type) async {
    try {
      debugPrint('📖 Marking all $type notifications as read...');
      
      // Get all unread notifications of this type from database (more reliable than notificationList)
      final allNotifications = await NotificationDatabase.instance.getAllNotifications();
      final unreadNotifications = allNotifications.where((n) => !n.isRead && n.type == type).toList();
      
      if (unreadNotifications.isEmpty) {
        debugPrint('ℹ️ No unread $type notifications to mark as read');
        return;
      }
      
      debugPrint('📋 Found ${unreadNotifications.length} unread $type notifications to mark as read');
      
      // Update server for each notification - use Future.wait to ensure all are processed
      final List<Future<void>> serverUpdates = [];
      for (final notification in unreadNotifications) {
        if (notification.serverId != null) {
          final serverId = int.tryParse(notification.serverId!);
          if (serverId != null) {
            serverUpdates.add(
              _repository.markNotificationAsRead(serverId).then((response) {
                if (response.status) {
                  debugPrint('✅ Marked $type notification ${notification.serverId} as read on server');
                } else {
                  debugPrint('❌ Server returned error for notification ${notification.serverId}: ${response.message}');
                }
              }).catchError((e) {
                debugPrint('❌ Error marking $type notification ${notification.serverId} as read on server: $e');
              })
            );
          } else {
            debugPrint('⚠️ Invalid serverId for notification: ${notification.serverId}');
          }
        } else {
          debugPrint('⚠️ Notification ${notification.id} has no serverId');
        }
      }
      
      // Wait for all server updates to complete (don't fail if some fail)
      await Future.wait(serverUpdates, eagerError: false);
      debugPrint('📡 Completed ${serverUpdates.length} server update requests');
      
      // Update local database - mark all unread notifications of this type as read
      final updatedCount = await NotificationDatabase.instance.markNotificationsAsReadByType(type);
      debugPrint('✅ Updated local database: marked $updatedCount $type notifications as read');
      
      // Force sync with server to get updated read status
      debugPrint('🔄 Syncing with server to get updated read status...');
      await _simpleSyncWithServer();
      
      debugPrint('✅ All $type notifications marked as read');
    } catch (e) {
      debugPrint('❌ Error marking $type notifications as read: $e');
      // Even if there's an error, try to update local database
      try {
        await NotificationDatabase.instance.markNotificationsAsReadByType(type);
        await loadLocalNotifications();
      } catch (localError) {
        debugPrint('❌ Error updating local database: $localError');
      }
    }
  }

  /// Mark all notifications as read - Update server first, then sync
  Future<void> markAllNotificationsAsRead() async {
    try {
      debugPrint('📖 Marking all notifications as read...');

      // Get all unread notifications from database
      final allNotifications = await NotificationDatabase.instance.getAllNotifications();
      final unreadNotifications = allNotifications.where((n) => !n.isRead).toList();
      
      if (unreadNotifications.isEmpty) {
        debugPrint('ℹ️ No unread notifications to mark as read');
        return;
      }
      
      debugPrint('📋 Found ${unreadNotifications.length} unread notifications to mark as read');
      debugPrint('📋 Unread notifications breakdown:');
      for (final notification in unreadNotifications) {
        debugPrint('  - ${notification.title} (ServerID: ${notification.serverId}, Type: ${notification.type}, LocalID: ${notification.id})');
      }
      
      // Update server for each notification - use Future.wait to ensure all are processed
      final List<Future<void>> serverUpdates = [];
      for (final notification in unreadNotifications) {
        if (notification.serverId != null) {
          final serverId = int.tryParse(notification.serverId!);
          if (serverId != null) {
            serverUpdates.add(
              _repository.markNotificationAsRead(serverId).then((response) {
                if (response.status) {
                  debugPrint('✅ Marked notification ${notification.serverId} as read on server');
                } else {
                  debugPrint('❌ Server returned error for notification ${notification.serverId}: ${response.message}');
                }
              }).catchError((e) {
                debugPrint('❌ Error marking notification ${notification.serverId} as read on server: $e');
              })
            );
          } else {
            debugPrint('⚠️ Invalid serverId for notification: ${notification.serverId}');
          }
        } else {
          debugPrint('⚠️ Notification ${notification.id} has no serverId');
        }
      }
      
      // Wait for all server updates to complete (don't fail if some fail)
      await Future.wait(serverUpdates, eagerError: false);
      debugPrint('📡 Completed ${serverUpdates.length} server update requests');
      
      // Update local database - mark all unread notifications as read
      await NotificationDatabase.instance.markAllNotificationsAsRead();
      debugPrint('✅ Updated local database: marked all notifications as read');
      
      // Force sync with server to get updated read status
      debugPrint('🔄 Syncing with server to get updated read status...');
      await _simpleSyncWithServer();
      
      debugPrint('✅ All notifications marked as read');
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
      // Even if there's an error, try to update local database
      try {
        await NotificationDatabase.instance.markAllNotificationsAsRead();
        await loadLocalNotifications();
      } catch (localError) {
        debugPrint('❌ Error updating local database: $localError');
      }
    }
  }

  /// Delete notification - Update both local and server
  Future<void> deleteNotification(NotificationDataModel notification) async {
    try {
      debugPrint('🗑️ Deleting notification: ${notification.title} (Local ID: ${notification.id}, Server ID: ${notification.serverId})');
      
      // Update local database using local ID
      if (notification.id != null) {
        await NotificationDatabase.instance.deleteNotificationById(notification.id!);
        debugPrint('✅ Local database updated for notification ${notification.id}');
      }
      
      // Update server using server ID (notification_queue_id)
      if (notification.serverId != null) {
        try {
          final serverId = int.tryParse(notification.serverId!);
          if (serverId != null) {
            await _repository.deleteNotification(serverId);
            debugPrint('✅ Server updated for notification with server ID $serverId');
          } else {
            debugPrint('❌ Invalid server ID: ${notification.serverId}');
          }
        } catch (e) {
          debugPrint('❌ Error updating server for notification ${notification.serverId}: $e');
        }
      } else {
        debugPrint('⚠️ No server ID available for notification ${notification.id}');
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