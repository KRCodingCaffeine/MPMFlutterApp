import 'package:get/get.dart';
import 'package:mpm/model/notification/NotificationModel.dart';
import 'package:mpm/utils/NotificationDatabase.dart';

class NotificationController extends GetxController {
  RxList<NotificationModel> notificationList = <NotificationModel>[].obs;

  Future<void> loadNotifications() async {
    final data = await NotificationDatabase.instance.getAllNotifications();
    notificationList.value = data;
  }


  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }
}
