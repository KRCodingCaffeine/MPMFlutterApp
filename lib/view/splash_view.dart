import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
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
  bool _updateRequired = false;
  Completer<void>? _updateCompleter; 

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
    // This will set _updateRequired and show dialog if needed
    await _checkForUpdate();

    // Step 4: If update is required, wait for user to handle it
    if (_updateRequired && _updateCompleter != null) {
      await _updateCompleter!.future;
    }

    // Step 5: Splash delay (only if no update required)
    if (!_updateRequired) {
      await Future.delayed(const Duration(seconds: 2));
    }

    // Step 6: Session routing (only if update not required or user dismissed)
    if (!mounted) return;
    
    if (_updateRequired) {
      // Don't navigate if update is required
      return;
    }

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
      await _checkAndroidUpdate();
    } else if (Platform.isIOS) {
      await _checkIOSUpdate();
    }
  }

  Future<void> _checkAndroidUpdate() async {
    try {
      _updateInfo = await InAppUpdate.checkForUpdate();
      if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
        // Get app store URL for Android
        final packageInfo = await PackageInfo.fromPlatform();
        final packageName = packageInfo.packageName;
        final appStoreUrl = "https://play.google.com/store/apps/details?id=$packageName";
        
        setState(() {
          _updateRequired = true;
          _updateCompleter = Completer<void>();
        });
        
        _showUpdateDialog(appStoreUrl);
      }
    } catch (e) {
      debugPrint("Update check failed (Android): $e");
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
            setState(() {
              _updateRequired = true;
              _updateCompleter = Completer<void>();
            });
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
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return PopScope(
          canPop: false, // Prevent back button from dismissing
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: ColorHelperClass.getColorFromHex(ColorResources.logo_color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.system_update,
                      size: 50,
                      color: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    "Update Available",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Message
                  Text(
                    "A new version of the app is available. Please update to continue.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
                          await launchUrl(
                            Uri.parse(appStoreUrl),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                        // Complete the completer after launching app store
                        if (_updateCompleter != null && !_updateCompleter!.isCompleted) {
                          _updateCompleter!.complete();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Update Now",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
