import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/notification/NotificationModel.dart';
import 'package:mpm/utils/NotificationDatabase.dart';

class NotificationController extends GetxController with WidgetsBindingObserver {
  RxList<NotificationModel> notificationList = <NotificationModel>[].obs;



  var unreadCount = 0.obs;

  void loadNotifications() async {
    notificationList.value = await NotificationDatabase.instance.getAllNotifications();
    unreadCount.value = await NotificationDatabase.instance.getUnreadNotificationCount();
  }
  void markAsRead(String id) {
    final notif = notificationList.firstWhere((n) => n.id == id);
    notif.isRead = true;
    notificationList.refresh(); // Update the UI
  }


  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadNotifications();
  }
  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadNotifications(); // refresh when resumed
    }
  }
  void markAllAsRead() async {
    await NotificationDatabase.instance.markAllNotificationsAsRead();
    loadNotifications2();
  }
  void loadNotifications2() async {
    final notifications = await NotificationDatabase.instance.getAllNotifications();
    unreadCount.value = notifications.where((n) => !n.isRead).length;
    // update your list too if needed
  }
  void deleteNotification(int id) async {
    await NotificationDatabase.instance.deleteNotificationById(id);
    notificationList.removeWhere((n) => n.id == id);
    notificationList.refresh();
  }

}
