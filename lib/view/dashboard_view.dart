import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/CheckUser/CheckUserData.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/SearchView.dart';
import 'package:mpm/view/home_view.dart';
import 'package:mpm/view/login_view.dart';
import 'package:mpm/view/profile%20view/profile_view.dart';
import 'package:mpm/view/samiti%20members/samiti_members_view.dart';

import 'package:mpm/view_model/controller/dashboard/dashboardcontroller.dart';
import 'package:mpm/view_model/controller/login/logincontroller.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {

  DashBoardController controller = Get.put(DashBoardController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserSessionData();
  }

  final List<Widget> pages = [
    const HomeView(),
    const SearchView(),
    const SamitiMembersViewPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor:
          ColorHelperClass.getColorFromHex(ColorResources.logo_color),
          title:  Text(
            'Maheshwari Pragati Manda',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          ),

        drawer: AppDrawer(),
        body: pages[controller.currentIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xFFFFFFFF), // White background
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

  void _showAlertDialog(
      BuildContext context, String title, String msg, String flag) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                if (flag == "1") {
                  SessionManager.clearSession();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                }
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getUserSessionData() async {
    CheckUserData2? userData = await SessionManager.getSession();
    if (userData != null) {
      print('User ID: ${userData.memberId}');
      print('User Name: ${userData.mobile}');
      if(userData?.memberCode!=null)
        {
          controller.lmCode.value=userData!.memberCode.toString();
        }
      if(userData?.mobile!=null)
      {
        controller.mobileNumber.value=userData!.memberCode.toString();
      }
      var firstname = "";
      var middlename = "";
      var lastname = "";
      if(userData?.firstName!=null)
      {
        firstname = userData!.firstName.toString();
      }
      if(userData?.middleName!=null)
      {
        middlename = userData!.middleName.toString();
      }
      if(userData?.lastName!=null)
      {
        lastname = userData!.lastName.toString();
      }
      controller.userName.value = firstname+middlename+lastname;
    } else {
      print('No user session data found!');
    }
  }
}
