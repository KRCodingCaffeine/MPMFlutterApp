import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/home_view.dart';
import 'package:mpm/view/SearchView.dart';
import 'package:mpm/view/notification_view.dart';
import 'package:mpm/view/samiti%20members/samiti_members_view.dart';
import 'package:mpm/view_model/controller/DeviceMapping/DeviceMappingController.dart';
import 'package:mpm/view_model/controller/notification/NotificationController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final UdateProfileController controller = Get.put(UdateProfileController());
  final NotificationController notificationController =
  Get.find<NotificationController>();
  final DeviceMappingController deviceMappingController =
  DeviceMappingController();

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
    const NotificationView(),
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
              controller.changeTab(index);
              if (index == 3) notificationController.loadNotifications();
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
                      Get.find<NotificationController>().unreadCount.value;
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
