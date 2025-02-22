import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/home_view.dart';
import 'package:mpm/view/SearchView.dart';
import 'package:mpm/view/samiti%20members/samiti_members_view.dart';
import 'package:mpm/view/login_view.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/dashboard/dashboardcontroller.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final DashBoardController controller = Get.put(DashBoardController());

  @override
  void initState() {
    super.initState();
    getUserSessionData();
  }

  final List<Widget> pages = [
    const HomeView(),
    const SearchView(),
    const SamitiMembersViewPage(),
  ];

  // Titles for AppBar corresponding to each page
  final List<String> appBarTitles = [
    "Maheshwari Pragati Mandal",
    "Search Members",
    "Samiti Members",
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Scaffold(
        appBar: AppBar(
          backgroundColor:
          ColorHelperClass.getColorFromHex(ColorResources.logo_color),
          title: Text(
            appBarTitles[controller.currentIndex.value], // Dynamic title
            style: const TextStyle(color: Colors.white),
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
          ],
        ),
      ),
    );
  }

  Future<void> getUserSessionData() async {
    CheckUserData2? userData = await SessionManager.getSession();
    if (userData != null) {
      print('User ID: ${userData.memberId}');
      print('User Name: ${userData.mobile}');

      controller.lmCode.value = userData.memberCode ?? "";
      controller.mobileNumber.value = userData.mobile ?? "";

      String firstName = userData.firstName ?? "";
      String middleName = userData.middleName ?? "";
      String lastName = userData.lastName ?? "";

      controller.userName.value = "$firstName $middleName $lastName".trim();

      // Handle profile image URL
      if (userData.profileImage != null && userData.profileImage!.isNotEmpty) {
        controller.profileImage.value = Urls.imagePathUrl + userData.profileImage!;
        /*controller.profileImage.value =
        "https://krcodingcaffeine.com/pragati-mandal-api/public/${userData.profileImage!}";*/
      } else {
        controller.profileImage.value = "assets/images/user3.png"; // Default image
      }
    } else {
      print('No user session data found!');
    }
  }
}
