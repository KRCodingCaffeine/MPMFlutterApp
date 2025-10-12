import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/home_view.dart';
import 'package:mpm/view/SearchView.dart';
import 'package:mpm/view/notification_list_view.dart';
import 'package:mpm/view/samiti%20members/samiti_members_view.dart';
import 'package:mpm/view_model/controller/DeviceMapping/DeviceMappingController.dart';
import 'package:mpm/view_model/controller/notification/NotificationApiController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final UdateProfileController controller = Get.put(UdateProfileController());
  final NotificationApiController notificationController =
  Get.find<NotificationApiController>();
  final DeviceMappingController deviceMappingController =
  DeviceMappingController();

  /// Show confirmation dialog for deleting all notifications
  void _showDeleteAllConfirmation(BuildContext context, NotificationApiController notificationController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Notifications'),
          content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                notificationController.deleteAllNotifications(); // Delete all notifications
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await getUserSessionData();
    await _registerDeviceMapping();
  }

  Future<void> getUserSessionData() async {
    final userData = await SessionManager.getSession();
    if (userData != null) {
      controller.memberId.value = userData.memberId ?? "";
    }
  }

  Future<void> _registerDeviceMapping() async {
    final userData = await SessionManager.getSession();
    if (userData != null && userData.memberId != null) {
      await deviceMappingController.registerDeviceMapping(userData.memberId!);
    }
  }

  final List<Widget> pages = [
    const HomeView(),
    const SearchView(),
    const SamitiMembersViewPage(),
    const NotificationListView(),
  ];

  final List<String> appBarTitles = [
    "Maheshwari Pragati Mandal",
    "Search Members",
    "Samiti Members",
    "Notification"
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Scaffold(
        appBar: AppBar(
          backgroundColor:
          ColorHelperClass.getColorFromHex(ColorResources.logo_color),
          title: Text(
            appBarTitles[controller.currentIndex.value],
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.055,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: controller.currentIndex.value == 3 ? [
            // Test controller button
            IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.white),
              onPressed: () => notificationController.testController(),
              tooltip: 'Test controller',
            ),
            // Test local only button
            IconButton(
              icon: const Icon(Icons.storage, color: Colors.white),
              onPressed: () => notificationController.testLocalOnly(),
              tooltip: 'Test local database only',
            ),
            // Test server API button
            IconButton(
              icon: const Icon(Icons.api, color: Colors.white),
              onPressed: () => notificationController.testServerApi(),
              tooltip: 'Test server API',
            ),
            // Test server API formats button
            IconButton(
              icon: const Icon(Icons.compare_arrows, color: Colors.white),
              onPressed: () => notificationController.testServerApiFormats(),
              tooltip: 'Test API formats',
            ),
            // Check server API status button
            IconButton(
              icon: const Icon(Icons.analytics, color: Colors.white),
              onPressed: () => notificationController.checkServerApiStatus(),
              tooltip: 'Check server API status',
            ),
            // Reset to server status button
            IconButton(
              icon: const Icon(Icons.restore, color: Colors.white),
              onPressed: () => notificationController.resetLocalReadStatusToMatchServer(),
              tooltip: 'Reset to server status',
            ),
            // Sync read status button
            IconButton(
              icon: const Icon(Icons.sync, color: Colors.white),
              onPressed: () => notificationController.syncReadStatusWithServer(),
              tooltip: 'Sync read status with server',
            ),
            // Force re-initialize button
            IconButton(
              icon: const Icon(Icons.restart_alt, color: Colors.white),
              onPressed: () => notificationController.forceReinitialize(),
              tooltip: 'Force re-initialize',
            ),
            // Force clear button
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => notificationController.forceSyncWithServer(),
              tooltip: 'Force sync with server',
            ),
            // Force sync read status button
            IconButton(
              icon: const Icon(Icons.sync_problem, color: Colors.white),
              onPressed: () => notificationController.forceSyncReadStatus(),
              tooltip: 'Force sync read status',
            ),
            // Complete reset and sync button
            IconButton(
              icon: const Icon(Icons.refresh_outlined, color: Colors.white),
              onPressed: () => notificationController.completeResetAndSync(),
              tooltip: 'Complete reset and sync',
            ),
            // Mark all as read button
            Obx(() {
              final unreadCount = notificationController.unreadCount.value;
              if (unreadCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.done_all, color: Colors.white),
                  onPressed: () => notificationController.markAllNotificationsAsRead(),
                  tooltip: 'Mark all as read',
                );
              }
              return const SizedBox.shrink();
            }),
            // Clear all button
            Obx(() {
              if (notificationController.notificationList.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.clear_all, color: Colors.white),
                  onPressed: () => _showDeleteAllConfirmation(context, notificationController),
                  tooltip: 'Clear all notifications',
                );
              }
              return const SizedBox.shrink();
            }),
          ] : null,
        ),
        drawer: AppDrawer(),
        backgroundColor: Colors.grey[100],
        body: pages[controller.currentIndex.value],
        bottomNavigationBar: Obx(
              () => BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor:
            ColorHelperClass.getColorFromHex(ColorResources.red_color),
            unselectedItemColor: Colors.grey,
            currentIndex: controller.currentIndex.value,
          onTap: (index) {
            try {
              controller.changeTab(index);
              if (index == 3) {
                // Simple approach: just load local notifications
                notificationController.loadLocalNotifications();
              }
            } catch (e) {
              debugPrint('❌ Error in tab click: $e');
            }
          },
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: "Home"),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: "Search"),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance), label: "Samiti"),
              BottomNavigationBarItem(
                icon: Obx(() {
                  final count =
                      Get.find<NotificationApiController>().unreadCount.value;
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      const Icon(Icons.notifications),
                      if (count > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                                minWidth: 10, minHeight: 10),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
                label: "Notification",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
