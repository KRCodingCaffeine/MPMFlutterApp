import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/images.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
    // Step 1: Ask notification permission
    _requestNotificationPermission();

    // Step 2: Firebase already initialized in main.dart

    // Step 3: App update check (different for Android & iOS)
    await _checkForUpdate();

    // Step 4: Splash delay
    await Future.delayed(const Duration(seconds: 2));

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
    if (Platform.isAndroid) {
      try {
        _updateInfo = await InAppUpdate.checkForUpdate();
        if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
          await InAppUpdate.performImmediateUpdate().catchError((e) {
            debugPrint("Update error (Android): $e");
          });
        }
      } catch (e) {
        debugPrint("Update check failed (Android): $e");
      }
    } else if (Platform.isIOS) {
      await _checkIOSUpdate();
    }
  }

  Future<void> _checkIOSUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final bundleId = packageInfo.packageName;

      final url = "https://itunes.apple.com/lookup?bundleId=$bundleId";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['resultCount'] > 0) {
          final storeVersion = jsonData['results'][0]['version'];
          final appStoreUrl = jsonData['results'][0]['trackViewUrl'];

          if (_isVersionNewer(storeVersion, currentVersion)) {
            _showUpdateDialog(appStoreUrl);
          }
        }
      }
    } catch (e) {
      debugPrint("Update check failed (iOS): $e");
    }
  }

  bool _isVersionNewer(String storeVersion, String currentVersion) {
    List<int> storeParts = storeVersion.split('.').map(int.parse).toList();
    List<int> currentParts = currentVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < storeParts.length; i++) {
      if (i >= currentParts.length || storeParts[i] > currentParts[i]) {
        return true;
      } else if (storeParts[i] < currentParts[i]) {
        return false;
      }
    }
    return false;
  }

  void _showUpdateDialog(String appStoreUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Update Available"),
          content: const Text("A new version of the app is available. Please update to continue."),
          actions: [
            TextButton(
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
                  await launchUrl(Uri.parse(appStoreUrl), mode: LaunchMode.externalApplication);
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
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
