import 'package:flutter/material.dart';
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final isRead = notification['isRead'];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isRead ? Colors.grey[200] : Colors.deepPurple[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                isRead ? Colors.grey[700] : Colors.red,
                child: Icon(Icons.notifications, color: Colors.white),
              ),
              title: Text(
                notification['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isRead ? Colors.black54 : Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification['body']),
                  SizedBox(height: 4),
                  Text(
                    notification['time'],
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationDetailPage(
                      title: notification['title'],
                      body: notification['body'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
