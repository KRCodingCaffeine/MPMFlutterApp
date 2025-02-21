import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/view/login_view.dart';
import 'package:mpm/view_model/controller/dashboard/dashboardcontroller.dart';
import 'package:share_plus/share_plus.dart';


class AppDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final DashBoardController dashBoardController = Get.find();
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFcd4e2b),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  // Profile Image
                  Obx(() => CircleAvatar(
                    radius: 30,
                    backgroundImage: dashBoardController.profileImage.value.isNotEmpty
                        ? NetworkImage(dashBoardController.profileImage.value)
                        : const AssetImage("assets/images/user3.png") as ImageProvider,
                    backgroundColor: Colors.grey[300],
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dashBoardController.userName.value.isNotEmpty
                              ? dashBoardController.userName.value
                              : "Guest User",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Member Code: ${dashBoardController.lmCode.value.isNotEmpty ? dashBoardController.lmCode.value : "N/A"}",
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Mobile: ${dashBoardController.mobileNumber.value.isNotEmpty ? dashBoardController.mobileNumber.value : "N/A"}",
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),

                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.dashboard);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('My Profile'),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.profile);
            },
          ),
          ListTile(
            leading: Icon(Icons.person_search),
            title: Text('Search Members'),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.searchmember);
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text('Samiti Members'),
            onTap: () async {
              Navigator.pushNamed(context, RouteNames.samitimemberview);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share App'),
            onTap: () {
              Navigator.pop(context);
              _onShare(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_copy),
            title: const Text('Forms'),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.forms);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Government Scheme'),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.gov_scheme);
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About Us'),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.aboutUs);
            },
          ),
          ListTile(
            leading: Icon(Icons.headset_mic),
            title: Text('Contact Us'),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.contactUs);
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.pravacypolicy);
            },
          )
          ,ListTile(
            leading: Icon(Icons.description),
            title: Text('Terms & Condition'),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.termandcondition);
            },
          ),

          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }
  void _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    const String playStoreLink =
        'https://play.google.com/store/apps/details?id=com.example.yourapp';
    const String appStoreLink =
        'https://apps.apple.com/app/id123456789'; // Replace with actual link

    String shareText =
        "🌟 Welcome to MPM App! \n\n📲 🚀 Check out this amazing app! \n\n📲 Download Now: \n👉 Android: $playStoreLink\n👉 iOS: $appStoreLink";

    await Share.share(
      shareText,
      subject: "Download Our App!",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  /// ✅ **Fixed Logout Dialog**
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                SessionManager.clearSession();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
