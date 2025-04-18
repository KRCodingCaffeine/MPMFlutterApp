import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/login_view.dart';

import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:share_plus/share_plus.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UdateProfileController dashBoardController = Get.find();
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
                  Stack(
                    children: [
                      Obx(() {
                        return CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300], // Background color while loading
                          child: ClipOval(
                            child: (dashBoardController.profileImage.value.isNotEmpty)
                                ? FadeInImage(
                              placeholder: const AssetImage("assets/images/user3.png"), // Placeholder while loading
                              image: NetworkImage(Urls.imagePathUrl + dashBoardController.profileImage.value), // Network image
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/male.png", // Fallback image on error
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                );
                              },
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            )
                                : Image.asset(
                              "assets/images/user3.png", // Default image if profileImage is empty
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
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
                          "Member Code : ${(dashBoardController.memberCode.value.trim().isNotEmpty)
                              ? dashBoardController.memberCode.value
                              : " -- "}", // Default text if both are empty
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 4),
                        Text(
                          "Mobile: ${dashBoardController.mobileNumber.value.isNotEmpty ? dashBoardController.mobileNumber.value : "N/A"}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70),
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
              Navigator.pop(context); // Close AppDrawer
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.dashboard,
                (route) => false, // Removes all previous routes
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.profile);
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
            leading: const Icon(Icons.ios_share),
            title: const Text('Share Membership Form'),
            onTap: () {
              Navigator.pop(context);
              _onSharememberForm(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_copy),
            title: const Text('Forms'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.forms);
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.account_balance),
          //   title: const Text('Government Scheme'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.pushNamed(context, RouteNames.gov_scheme);
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.aboutUs);
            },
          ),
          ListTile(
            leading: Icon(Icons.headset_mic),
            title: Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.contactUs);
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.pravacypolicy);
            },
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Terms & Condition'),
            onTap: () {
              Navigator.pop(context);
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
        'https://play.google.com/store/apps/details?id=com.mpm.member';
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

  void _onSharememberForm(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    const String membershipFormLink =
        'https://members.mumbaimaheshwari.com/member/registration';

    String shareText =
        "We invite you to join us! 🎉\n\n"
        "Register now using the following link: \n\n"
        "📲 $membershipFormLink\n\n"
        "We look forward to having you onboard!";

    await Share.share(
      shareText,
      subject: "Join Us - Membership Registration",
      sharePositionOrigin: box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : Rect.zero, // Provide a fallback value
    );
  }

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
