import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/view/notification_detail.dart';

import 'package:mpm/view_model/controller/notification/NotificationController.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final NotificationController controller = Get.find<NotificationController>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Obx(() {
          final notifications = controller.notificationList;

          if (notifications.isEmpty) {
            return Center(
              child: Text(
                "No notifications available",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationDetailPage(
                          title: notification.title,
                          body: notification.body,
                          image: notification.image, // pass image here
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: notification.image != ""
                        ? Colors.transparent
                        : Colors.red,
                    child: notification.image != ""
                        ? Image.network(notification.image, fit: BoxFit.fill)
                        : Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body),
                      SizedBox(height: 4),
                      Text(
                        notification.timestamp,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }));
  }
}
