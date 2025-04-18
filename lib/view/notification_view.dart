import 'package:flutter/material.dart';
import 'package:mpm/model/notification/NotificationModel.dart';
import 'package:mpm/utils/NotificationDatabase.dart';
import 'package:mpm/view/notification_detail.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'MPM Mumbai',
      'body': 'Please verify your Mobile Number!!',
      'time': 'a few seconds ago',
      'isRead': false,
    },
    {
      'title': 'MPM Mumbai',
      'body': 'Your Membership Approval is pending!!',
      'time': '10 min ago',
      'isRead': false,
    },
    {
      'title': 'MPM Mumbai',
      'body': 'Jangana is Completed...',
      'time': '15 hours ago',
      'isRead': true,
    },
    {
      'title': 'MPM Mumbai',
      'body': 'Welcome to MPM Mumbai Maheshwari',
      'time': '1 days ago',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: FutureBuilder<List<NotificationModel>>(
            future: NotificationDatabase.instance.getAllNotifications(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading notifications'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No notifications available'));
              }

              final notifications = snapshot.data!;

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
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.notifications, color: Colors.white),
                        ),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification.body),
                            SizedBox(height: 4),
                            Text(
                              notification.timestamp,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ));
                },
              );
            }));
  }
}
