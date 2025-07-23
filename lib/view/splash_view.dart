import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/FirebaseFCMApi.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/images.dart';
import 'package:permission_handler/permission_handler.dart';
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  AppUpdateInfo? _updateInfo;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 40).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleStartupLogic();
    });
  }

  void _handleStartupLogic() async {
    // Step 1: Ask notification permission first
    _requestNotificationPermission();

    // Step 2: Start Firebase init non-blocking
    PushNotificationService().initialise(); // Do NOT await

    // Step 3: App update check
    await _checkForUpdate();

    // Step 4: Splash delay
    await Future.delayed(Duration(seconds: 2));

    // Step 5: Session routing
    final userData = await SessionManager.getSession();
    final mobile = userData?.mobile ?? "";

    if (!mounted) return;

    if (mobile.isEmpty) {
      Navigator.pushReplacementNamed(context, RouteNames.login_screen);
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.dashboard);
    }
  }


  void _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      _updateInfo = await InAppUpdate.checkForUpdate();
      if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate().catchError((e) {
          print("Update error: $e");
        });
      }
    } catch (e) {
      print("Update check failed: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Images.logoImage, width: 300, height: 240),
            const SizedBox(height: 10),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}


