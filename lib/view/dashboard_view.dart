import
'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/utils/AppDrawer.dart';

import 'package:mpm/view/home_view.dart';
import 'package:mpm/view/SearchView.dart';
import 'package:mpm/view/notification_view.dart';
import 'package:mpm/view/samiti%20members/samiti_members_view.dart';

import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
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
  Get.put(NotificationController());
  @override
  void initState() {
    super.initState();
    getUserSessionData();
    // notificationController.loadUnreadCount();
  }

  final List<Widget> pages = [
    const HomeView(),
    const SearchView(),
    const SamitiMembersViewPage(),
    const NotificationView(),
  ];

  // Titles for AppBar corresponding to each page
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
              fontSize: MediaQuery.of(context).size.width * 0.045,
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
            onTap: controller.changeTab,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Search",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance),
                label: "Samiti Member",
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.notifications),
              //   label: "Notification",
              // ),
              BottomNavigationBarItem(
                icon: Obx(() {
                  final count = Get.find<NotificationController>().unreadCount.value;
                  if (count > 0) {
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        const Icon(Icons.notifications),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Icon(Icons.notifications);
                  }
                }),
                label: "Notification",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getUserSessionData() async {
    // count= await NotificationDatabase.instance.countUnreadNotifications();

    CheckUserData2? userData = await SessionManager.getSession();
    if (userData != null) {
      controller.memberId.value = userData.memberId ?? "";
    }
  }
}