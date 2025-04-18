import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/home_view.dart';
import 'package:mpm/view/SearchView.dart';
import 'package:mpm/view/notification_view.dart';
import 'package:mpm/view/samiti%20members/samiti_members_view.dart';
import 'package:mpm/view/login_view.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final UdateProfileController controller = Get.put(UdateProfileController());

  @override
  void initState() {
    super.initState();
    getUserSessionData();
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
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor:
              ColorHelperClass.getColorFromHex(ColorResources.red_color),
          unselectedItemColor: Colors.grey,
          currentIndex: controller.currentIndex.value,
          onTap: (index) {
            if (index < pages.length) {
              controller.currentIndex.value = index;
            }
          },
          items: const [
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
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: "Notification",
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getUserSessionData() async {
    CheckUserData2? userData = await SessionManager.getSession();
    if (userData != null) {
      controller.memberId.value = userData.memberId ?? "";
    }
  }
}
