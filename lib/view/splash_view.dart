import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mpm/model/CheckUser/CheckUserData.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/images.dart';
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 40).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

  getData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(Images.logoImage, // Replace with your logo
                  width: 300,
                  height: 240,
                ),
                SizedBox(height: 10),

              ],
            ),
          ),
        ],
      ),
    );
  }

  void getData() async{
    var mobilenumber="";
    Timer(Duration(seconds: 2), () async{
      if(mounted) {
        CheckUserData2? userData = await SessionManager.getSession();
        print('User ID: ${userData?.memberId}');
          print('User Name: ${userData?.mobile}');

          setState(() {
            mobilenumber = userData?.mobile ?? "";
          });

          if (mobilenumber =="") {
            Navigator.pushReplacementNamed(context!, RouteNames.login_screen);
          } else {
            Navigator.pushReplacementNamed(context!, RouteNames.dashboard);
          }

      }
    });
  }
}
