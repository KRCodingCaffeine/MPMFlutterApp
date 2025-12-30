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
      // After completer completes, reset the flag to allow navigation
      // User has either clicked update or dismissed the dialog
      setState(() {
        _updateRequired = false;
      });
    }

    // Step 5: Splash delay (only if no update required)
    if (!_updateRequired) {
      await Future.delayed(const Duration(seconds: 2));
    }

    // Step 6: Session routing
    if (!mounted) return;

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
      debugPrint("Android update check - Availability: ${_updateInfo?.updateAvailability}");
      debugPrint("Android update check - Immediate allowed: ${_updateInfo?.immediateUpdateAllowed}");
      debugPrint("Android update check - Flexible allowed: ${_updateInfo?.flexibleUpdateAllowed}");
      
      // Check if update is available
      if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
        // Get app store URL for Android
        final packageInfo = await PackageInfo.fromPlatform();
        final packageName = packageInfo.packageName;
        final appStoreUrl = "https://play.google.com/store/apps/details?id=$packageName";
        
        debugPrint("✅ Update available! Showing update dialog. Package: $packageName");
        
        setState(() {
          _updateRequired = true;
          _updateCompleter = Completer<void>();
        });
        
        _showUpdateDialog(appStoreUrl);
      } else if (_updateInfo?.updateAvailability == UpdateAvailability.updateNotAvailable) {
        debugPrint("✅ No update available - app is up to date");
      } else if (_updateInfo?.updateAvailability == UpdateAvailability.unknown) {
        debugPrint("⚠️ Update availability unknown - this may happen in debug builds or when Play Store services are unavailable. Proceeding without update check.");
      } else if (_updateInfo == null) {
        debugPrint("⚠️ Update info is null - InAppUpdate.checkForUpdate() returned null. This may happen in debug builds. Proceeding without update check.");
      } else {
        debugPrint("ℹ️ Update status: ${_updateInfo?.updateAvailability}");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Update check failed (Android): $e");
      debugPrint("Stack trace: $stackTrace");
      // Don't block app startup if update check fails
    }
  }

  Future<void> _checkIOSUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final bundleId = packageInfo.packageName;

      debugPrint("iOS update check - Current version: $currentVersion, Bundle ID: $bundleId");

      final url = "https://itunes.apple.com/lookup?bundleId=$bundleId";
      final response = await http.get(Uri.parse(url));

      debugPrint("iOS update check - Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint("iOS update check - Result count: ${jsonData['resultCount']}");
        
        if (jsonData['resultCount'] > 0) {
          final storeVersion = jsonData['results'][0]['version'];
          final appStoreUrl = jsonData['results'][0]['trackViewUrl'];

          debugPrint("iOS update check - Store version: $storeVersion, Current: $currentVersion");

          if (_isVersionNewer(storeVersion, currentVersion)) {
            debugPrint("Update available! Showing update dialog.");
            setState(() {
              _updateRequired = true;
              _updateCompleter = Completer<void>();
            });
            _showUpdateDialog(appStoreUrl);
          } else {
            debugPrint("No update needed - Store version ($storeVersion) is not newer than current ($currentVersion)");
          }
        } else {
          debugPrint("App not found in App Store for bundle ID: $bundleId");
        }
      } else {
        debugPrint("Failed to fetch App Store data. Status code: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      debugPrint("Update check failed (iOS): $e");
      debugPrint("Stack trace: $stackTrace");
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
                        try {
                          if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
                            await launchUrl(
                              Uri.parse(appStoreUrl),
                              mode: LaunchMode.externalApplication,
                            );
                            debugPrint("Launched app store URL: $appStoreUrl");
                          } else {
                            debugPrint("Cannot launch URL: $appStoreUrl");
                          }
                        } catch (e) {
                          debugPrint("Error launching app store: $e");
                        }
                        // Complete the completer after launching app store
                        if (_updateCompleter != null && !_updateCompleter!.isCompleted) {
                          _updateCompleter!.complete();
                          debugPrint("Update completer completed");
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
