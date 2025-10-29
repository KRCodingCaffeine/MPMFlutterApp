import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class NetworkView extends StatefulWidget {
  const NetworkView({super.key});

  @override
  State<NetworkView> createState() => _NetworkViewState();
}

class _NetworkViewState extends State<NetworkView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor:
          ColorHelperClass.getColorFromHex(ColorResources.logo_color),
          title: Builder(
            builder: (context) {
              double fontSize = MediaQuery.of(context).size.width * 0.045;
              return Text(
                'Networking',
                style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w500),
              );
            },
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
    );
  }
}
