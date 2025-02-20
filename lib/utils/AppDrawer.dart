import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/view/login_view.dart';
import 'package:mpm/view_model/controller/dashboard/dashboardcontroller.dart';
import 'package:share_plus/share_plus.dart';


class AppDrawer extends StatelessWidget {
  File? _profileImage;

  @override
  Widget build(BuildContext context) {
    final DashBoardController dashBoardController = Get.find();
    return Drawer(
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
                  // Profile Image Section
                  CircleAvatar(
                    radius: 30, // Adjusted size for better visibility
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage("assets/images/logo.png")
                    as ImageProvider,
                    backgroundColor: Colors.grey[300],
                  ),

                  // User Information Section
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Vertically center content
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .start, // Align userName and ID properly
                          children: [
                            Text(
                              dashBoardController.userName.value,
                              style: const TextStyle(
                                fontSize:
                                14, // Adjusted font size for better readability
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              dashBoardController.lmCode.value, // Display Lm code (logged-in member code)
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Mobile: ${dashBoardController.mobileNumber.value}", // Display mobile number
                          style: const TextStyle(
                            fontSize: 12, // Adjusted font size for mobile
                            color: Colors.white70,
                          ),
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
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('My Profile'),
            onTap: () {
              Navigator.pushReplacementNamed(context,
                  RouteNames.profile);
            },
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: Text('Search Members'),
            onTap: () {
              dashBoardController.showAppBar.value=true;
              Navigator.pushReplacementNamed(context, RouteNames.searchmember);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Samiti Members'),
            onTap: () async {
              Navigator.pushReplacementNamed(context, RouteNames.samitimemberview);
              dashBoardController.showAppBar.value=true;
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Make New Member'),
            onTap: () {

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
              Navigator.pushReplacementNamed(context, RouteNames.forms);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Government Scheme'),
            onTap: () {
              Navigator.pushReplacementNamed(context, RouteNames.gov_scheme);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('About Us'),
            onTap: () {
              Navigator.pushReplacementNamed(context, RouteNames.aboutUs);
            },
          ),
          ListTile(
            leading: Icon(Icons.support_agent_rounded),
            title: Text('Contact Us'),
            onTap: () {
              Navigator.pushReplacementNamed(context, RouteNames.contactUs);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Pravacy Policy'),
            onTap: () {
              Navigator.pushReplacementNamed(context, RouteNames.pravacypolicy);
            },
          )
          ,ListTile(
            leading: Icon(Icons.document_scanner),
            title: Text('Terms & Condition'),
            onTap: () {
              Navigator.pushReplacementNamed(context, RouteNames.termandcondition);
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
