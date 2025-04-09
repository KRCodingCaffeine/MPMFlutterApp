import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class NotificationDetailPage extends StatelessWidget {
  final String title;
  final String body;

  const NotificationDetailPage(
      {super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
          title: Text(title, style: TextStyle(color: Colors.white),),
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(body, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
