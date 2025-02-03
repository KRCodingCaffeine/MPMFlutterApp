import 'package:flutter/material.dart';

class CustomClass{
 static Future<void> showOptionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Option"),
          content: Text("Please select one of the following options:"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop('Option 1'); // Close dialog and return "Option 1"
              },
              child: Text("Option 1"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop('Option 2'); // Close dialog and return "Option 2"
              },
              child: Text("Option 2"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // Close dialog without choosing
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
