import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/notification/NotificationDataModel.dart';
import 'package:mpm/repository/notification_repository/notification_repo.dart';
import 'package:mpm/utils/NotificationDatabase.dart';
import 'package:mpm/utils/notification_service.dart';
import 'package:mpm/route/route_name.dart';
import 'package:get/get.dart' as getx;

class NotificationApiController extends GetxController with WidgetsBindingObserver {
  final NotificationRepository _repository = NotificationRepository();
  
  // Observable variables
  final RxList<NotificationDataModel> notificationList = <NotificationDataModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<Status> requestStatus = Status.INITIAL.obs;

  // Timer for periodic sync
  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _syncTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncWithServer();
    }
  }

  /// Initialize notifications by loading from local DB first, then syncing with server
  Future<void> _initializeNotifications() async {
    debugPrint('🚀 Initializing notifications...');
    isLoading.value = true;
    try {
      await loadLocalNotifications();
      await _syncWithServer();
      debugPrint('✅ Notifications initialized');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load notifications from local database
  Future<void> loadLocalNotifications() async {
    try {
      notificationList.value = await NotificationDatabase.instance.getAllNotifications();
      unreadCount.value = await NotificationDatabase.instance.getUnreadNotificationCount();
      
      // Sync badge count with local unread count to ensure consistency
      await NotificationService.updateBadgeCount(unreadCount.value);
      debugPrint('🔢 Badge count synced with local unread count: ${unreadCount.value}');
      
      debugPrint('📊 Local notifications loaded: ${notificationList.length}, unread: $unreadCount');
      
      // Debug: Print all notification titles
      for (int i = 0; i < notificationList.length; i++) {
        debugPrint('📋 Notification $i: ${notificationList[i].title}');
      }
    } catch (e) {
      debugPrint('❌ Error loading local notifications: $e');
    }
  }

  /// Add sample notifications for testing
  Future<void> _addSampleNotifications() async {
    final sampleNotifications = [
      NotificationDataModel(
        title: "Welcome to MPM!",
        body: "Thank you for joining Maheshwari Pragati Mandal. Stay connected with our community.",
        image: "",
        timestamp: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        isRead: false,
        type: "welcome",
      ),
      NotificationDataModel(
        title: "New Event: Annual Meeting",
        body: "Join us for the annual meeting on December 15th at 6:00 PM. Don't miss this important gathering.",
        image: "",
        timestamp: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        isRead: false,
        type: "event",
      ),
      NotificationDataModel(
        title: "Special Offer Available",
        body: "Get 20% off on all services from our partner merchants. Valid until month end.",
        image: "",
        timestamp: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        isRead: true,
        type: "offer",
      ),
    ];

    for (final notification in sampleNotifications) {
      await NotificationDatabase.instance.insertNotification(notification);
    }
  }

  /// Sync notifications with server
  Future<void> _syncWithServer() async {
    try {
      debugPrint('🔄 Starting server sync...');
      
      // Try to get notifications from server first
      final response = await _repository.getAllNotifications();
      
      debugPrint('📡 Server response status: ${response.status}');
      debugPrint('📡 Server response message: ${response.message}');
      debugPrint('📡 Server notifications count: ${response.notifications.length}');
      
      if (response.status) {
        debugPrint('✅ Server notifications received: ${response.notifications.length}');
        
        // Clear local database completely
        await NotificationDatabase.instance.deleteAllNotifications();
        debugPrint('🗑️ Local database cleared');
        
        // Insert each notification only once, with deduplication
        final Set<String> insertedKeys = <String>{};
        for (final notification in response.notifications) {
          final localNotification = notification.toLocalModel();
          
          // Create unique key using notification_id and title
          final uniqueKey = '${localNotification.id}_${localNotification.title}';
          if (!insertedKeys.contains(uniqueKey)) {
            debugPrint('📝 Inserting notification: ${localNotification.title} (ID: ${localNotification.id})');
            await NotificationDatabase.instance.insertNotification(localNotification);
            insertedKeys.add(uniqueKey);
          } else {
            debugPrint('⚠️ Skipping duplicate notification: ${localNotification.title} (ID: ${localNotification.id})');
          }
        }
        debugPrint('💾 Server notifications saved to local database (${insertedKeys.length} unique)');
        
        // Update local data
        await loadLocalNotifications();
        
        // Calculate unread count from local data (more reliable than server count)
        final localUnreadCount = notificationList.where((n) => !n.isRead).length;
        unreadCount.value = localUnreadCount;
        await NotificationService.updateBadgeCount(localUnreadCount);
        debugPrint('🔢 Local unread count calculated: $localUnreadCount');
        
        requestStatus.value = Status.COMPLETE;
        debugPrint('✅ Server sync completed successfully');
      } else {
        debugPrint('❌ Server response failed: ${response.message}');
        // Fallback: Just load local notifications
        await loadLocalNotifications();
        requestStatus.value = Status.COMPLETE;
      }
    } catch (e) {
      debugPrint('❌ Error syncing with server: $e');
      // Fallback: Just load local notifications
      await loadLocalNotifications();
      requestStatus.value = Status.COMPLETE;
    }
  }

  /// Refresh notifications (pull-to-refresh)
  Future<void> refreshNotifications() async {
    isRefreshing.value = true;
    try {
      await _syncWithServer();
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Load notifications (for initial load)
  Future<void> loadNotifications() async {
    isLoading.value = true;
    requestStatus.value = Status.LOADING;
    try {
      await _syncWithServer();
    } finally {
      isLoading.value = false;
    }
  }

  /// Mark a notification as read
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      // Update local database first
      await NotificationDatabase.instance.markNotificationAsRead(notificationId);
      
      // Update local list
      final index = notificationList.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notificationList[index].isRead = true;
        notificationList.refresh();
      }
      
      // Update unread count
      unreadCount.value = await NotificationDatabase.instance.getUnreadNotificationCount();
      await NotificationService.syncBadgeWithDatabase();
      
      // Sync with server
      try {
        final response = await _repository.markNotificationAsRead(notificationId);
        if (!response.status) {
          debugPrint('Failed to mark notification as read on server: ${response.message}');
        }
      } catch (e) {
        debugPrint('Error syncing mark as read with server: $e');
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      // Update local database first
      await NotificationDatabase.instance.markAllNotificationsAsRead();
      
      // Update local list
      for (var notification in notificationList) {
        notification.isRead = true;
      }
      notificationList.refresh();
      
      // Update unread count
      unreadCount.value = 0;
      await NotificationService.syncBadgeWithDatabase();
      
      // Sync with server
      try {
        final response = await _repository.markAllNotificationsAsRead();
        if (!response.status) {
          debugPrint('Failed to mark all notifications as read on server: ${response.message}');
        }
      } catch (e) {
        debugPrint('Error syncing mark all as read with server: $e');
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Delete a single notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      // Update local database first
      await NotificationDatabase.instance.deleteNotificationById(notificationId);
      
      // Update local list
      notificationList.removeWhere((n) => n.id == notificationId);
      notificationList.refresh();
      
      // Update unread count
      unreadCount.value = await NotificationDatabase.instance.getUnreadNotificationCount();
      await NotificationService.syncBadgeWithDatabase();
      
      // Sync with server
      try {
        final response = await _repository.deleteNotification(notificationId);
        if (!response.status) {
          debugPrint('Failed to delete notification on server: ${response.message}');
        }
      } catch (e) {
        debugPrint('Error syncing delete with server: $e');
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    try {
      // Update local database first
      await NotificationDatabase.instance.deleteAllNotifications();
      
      // Update local list
      notificationList.clear();
      notificationList.refresh();
      
      // Update unread count
      unreadCount.value = 0;
      await NotificationService.syncBadgeWithDatabase();
      
      // Sync with server
      try {
        final response = await _repository.deleteAllNotifications();
        if (!response.status) {
          debugPrint('Failed to delete all notifications on server: ${response.message}');
        }
      } catch (e) {
        debugPrint('Error syncing delete all with server: $e');
      }
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');
    }
  }

  /// Get unread count from server
  Future<void> updateUnreadCount() async {
    try {
      debugPrint('🔢 Getting unread count from server...');
      
      // Try to get count from server first
      final response = await _repository.getUnreadNotificationCount();
      
      debugPrint('📡 Unread count response status: ${response.status}');
      debugPrint('📡 Unread count response message: ${response.message}');
      debugPrint('📡 Server unread count: ${response.unreadCount}');
      
      if (response.status) {
        debugPrint('✅ Server unread count: ${response.unreadCount}');
        unreadCount.value = response.unreadCount;
        
        // Update badge directly with server count
        await NotificationService.updateBadgeCount(response.unreadCount);
        debugPrint('✅ Badge updated with server count: ${response.unreadCount}');
      } else {
        debugPrint('❌ Server count failed: ${response.message}');
        // Fallback: Get from local database
        unreadCount.value = await NotificationDatabase.instance.getUnreadNotificationCount();
        await NotificationService.syncBadgeWithDatabase();
        debugPrint('⚠️ Using local database count: $unreadCount');
      }
    } catch (e) {
      debugPrint('❌ Error updating unread count: $e');
      // Fallback: Get from local database
      unreadCount.value = await NotificationDatabase.instance.getUnreadNotificationCount();
      await NotificationService.syncBadgeWithDatabase();
      debugPrint('⚠️ Using local database count (fallback): $unreadCount');
    }
  }

  /// Handle notification tap and navigate to relevant screen
  void handleNotificationTap(NotificationDataModel notification) async {
    // Mark as read if not already read
    if (!notification.isRead && notification.id != null) {
      await markNotificationAsRead(notification.id!);
    }

    // Navigate based on notification type or action URL
    if (notification.actionUrl != null && notification.actionUrl!.isNotEmpty) {
      // Handle custom action URL
      _handleCustomAction(notification.actionUrl!);
    } else if (notification.type != null) {
      // Handle based on notification type
      _handleNotificationType(notification.type!);
    } else {
      // Default behavior - show notification detail
      _showNotificationDetail(notification);
    }
  }

  /// Handle custom action URL
  void _handleCustomAction(String actionUrl) {
    // Parse action URL and navigate accordingly
    if (actionUrl.contains('event')) {
      getx.Get.toNamed(RouteNames.event_view);
    } else if (actionUrl.contains('trip')) {
      getx.Get.toNamed(RouteNames.event_trip);
    } else if (actionUrl.contains('offer')) {
      getx.Get.toNamed(RouteNames.discount_offer_view);
    } else if (actionUrl.contains('profile')) {
      getx.Get.toNamed(RouteNames.profile);
    }
    // Add more cases as needed
  }

  /// Handle notification type
  void _handleNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        getx.Get.toNamed(RouteNames.event_view);
        break;
      case 'trip':
        getx.Get.toNamed(RouteNames.event_trip);
        break;
      case 'offer':
      case 'discount':
        getx.Get.toNamed(RouteNames.discount_offer_view);
        break;
      case 'profile':
        getx.Get.toNamed(RouteNames.profile);
        break;
      case 'samiti':
        getx.Get.toNamed(RouteNames.samitimemberview);
        break;
      default:
        // Default to notification detail
        break;
    }
  }

  /// Show notification detail
  void _showNotificationDetail(NotificationDataModel notification) {
    // Navigate to notification detail page
    getx.Get.toNamed(RouteNames.notification_detail, arguments: notification);
  }

  /// Start periodic sync for new notifications
  void _startPeriodicSync() {
    // Start periodic sync every 5 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _syncWithServer();
    });
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
  }

  /// Force sync with server (sync without clearing user data)
  Future<void> forceSyncWithServer() async {
    try {
      debugPrint('🔄 Force syncing with server...');
      
      // Prevent multiple simultaneous syncs
      if (isLoading.value) {
        debugPrint('⚠️ Sync already in progress, skipping...');
        return;
      }
      
      isLoading.value = true;
      try {
        // Just sync with server without clearing data first
        await _syncWithServer();
        debugPrint('✅ Force sync completed');
      } finally {
        isLoading.value = false;
      }
    } catch (e) {
      debugPrint('❌ Error force syncing with server: $e');
      isLoading.value = false;
    }
  }

  /// Restart periodic sync
  void startPeriodicSync() {
    _startPeriodicSync();
  }

  /// Reset notification system completely
  Future<void> resetNotificationSystem() async {
    try {
      debugPrint('🔄 Resetting notification system...');
      
      // Stop periodic sync
      stopPeriodicSync();
      
      // Clear all local data
      await NotificationDatabase.instance.deleteAllNotifications();
      debugPrint('🗑️ All local notifications deleted');
      
      // Reset counts
      unreadCount.value = 0;
      notificationList.clear();
      debugPrint('🔄 Counts reset to 0');
      
      // Clear badge
      await NotificationService.clearBadge();
      debugPrint('🔢 Badge cleared');
      
      // Wait a bit to ensure database is cleared
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Force sync with server
      await forceSyncWithServer();
      
      debugPrint('✅ Notification system reset complete');
    } catch (e) {
      debugPrint('❌ Error resetting notification system: $e');
    }
  }

  /// Force clear duplicates and sync fresh
  Future<void> forceClearAndSync() async {
    try {
      debugPrint('🧹 Clearing duplicates and syncing...');
      
      // Stop all sync operations
      stopPeriodicSync();
      
      // Get current notifications to preserve user data
      final currentNotifications = await NotificationDatabase.instance.getAllNotifications();
      debugPrint('📊 Current notifications: ${currentNotifications.length}');
      
      // Clear local database
      await NotificationDatabase.instance.deleteAllNotifications();
      debugPrint('🗑️ Database cleared');
      
      // Reset local state
      unreadCount.value = 0;
      notificationList.clear();
      requestStatus.value = Status.LOADING;
      debugPrint('🔄 Local state reset');
      
      // Clear badge
      await NotificationService.clearBadge();
      debugPrint('🔢 Badge cleared');
      
      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Now sync with server
      await _syncWithServer();
      
      debugPrint('✅ Force clear and sync complete');
    } catch (e) {
      debugPrint('❌ Error in force clear and sync: $e');
    }
  }

  /// Clear local database completely (for debugging)
  Future<void> clearLocalDatabase() async {
    try {
      debugPrint('🗑️ Clearing local database...');
      await NotificationDatabase.instance.deleteAllNotifications();
      unreadCount.value = 0;
      notificationList.clear();
      await NotificationService.clearBadge();
      debugPrint('✅ Local database cleared');
    } catch (e) {
      debugPrint('❌ Error clearing local database: $e');
    }
  }

  /// Debug method to check current state
  Future<void> debugCurrentState() async {
    try {
      debugPrint('🔍 === DEBUG NOTIFICATION STATE ===');
      debugPrint('📊 Local notification count: ${notificationList.length}');
      debugPrint('📊 Local unread count: ${unreadCount.value}');
      
      final dbCount = await NotificationDatabase.instance.getAllNotifications();
      debugPrint('📊 Database notification count: ${dbCount.length}');
      
      final dbUnreadCount = await NotificationDatabase.instance.getUnreadNotificationCount();
      debugPrint('📊 Database unread count: $dbUnreadCount');
      
      // Try to get server count
      try {
        final response = await _repository.getUnreadNotificationCount();
        debugPrint('📊 Server unread count: ${response.unreadCount}');
        debugPrint('📊 Server response status: ${response.status}');
      } catch (e) {
        debugPrint('❌ Server count error: $e');
      }
      
      debugPrint('🔍 === END DEBUG STATE ===');
    } catch (e) {
      debugPrint('❌ Error debugging state: $e');
    }
  }
}
