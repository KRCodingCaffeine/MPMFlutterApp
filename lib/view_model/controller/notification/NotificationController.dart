import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/notification/NotificationDataModel.dart';
import 'package:mpm/utils/NotificationDatabase.dart';

import '../../../utils/FirebaseFCMApi.dart';

import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationController extends GetxController with WidgetsBindingObserver {
  RxList<NotificationDataModel> notificationList = <NotificationDataModel>[].obs;
  var unreadCount = 0.obs;

  void loadNotifications() async {
    notificationList.value =
    await NotificationDatabase.instance.getAllNotifications();
    unreadCount.value =
    await NotificationDatabase.instance.getUnreadNotificationCount();

    // Sync badge with DB
    AwesomeNotifications().setGlobalBadgeCounter(unreadCount.value);
  }

  void deleteNotification(int id) async {
    await NotificationDatabase.instance.deleteNotificationById(id);
    notificationList.removeWhere((n) => n.id == id);
    notificationList.refresh();

    unreadCount.value =
    await NotificationDatabase.instance.getUnreadNotificationCount();
    AwesomeNotifications().setGlobalBadgeCounter(unreadCount.value);
  }

  void markAllAsRead() async {
    await NotificationDatabase.instance.markAllNotificationsAsRead();
    loadNotifications();
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
      loadNotifications();
    }
  }
}

