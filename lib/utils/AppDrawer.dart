import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/login_view.dart';

import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:path_provider/path_provider.dart';
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
                          backgroundColor: Colors.grey[300],
                          child: ClipOval(
                            child: (dashBoardController
                                    .profileImage.value.isNotEmpty)
                                ? FadeInImage(
                                    placeholder: const AssetImage(
                                        "assets/images/user3.png"),
                                    image: NetworkImage(Urls.imagePathUrl +
                                        dashBoardController.profileImage.value),
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return Image.asset(
                                        "assets/images/male.png",
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
                                    "assets/images/user3.png",
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
                          "Membership Code : ${(dashBoardController.memberCode.value.trim().isNotEmpty) ? dashBoardController.memberCode.value : " -- "}",
                          style: const TextStyle(
                            fontSize: 12,
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
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.dashboard,
                (route) => false,
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
            leading: const Icon(Icons.contact_page),
            title: const Text('Enquiry Form'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, RouteNames.add_enquiry_form);
            },
          ),
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
        'https://apps.apple.com/in/app/mpm-mumbai/id6748281499';

    String shareText = '''
    🌟 Welcome to MPM App! 
    
    📲 🚀 Check out this amazing app! 
    
    📲 Download Now: 
    👉 Android: $playStoreLink
    👉 iOS: $appStoreLink
    ''';

    await Share.share(
      shareText,
      subject: "Download Our App!",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  void _onSharememberForm(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    const String membershipFormLink =
        'https://members.mumbaimaheshwari.com/staging/member/registration';

    String shareText = "We invite you to join us! 🎉\n\n"
        "Register now using the following link: \n\n"
        "📲 $membershipFormLink\n\n"
        "We look forward to having you onboard!";

    await Share.share(
      shareText,
      subject: "Join Us - Membership Registration",
      sharePositionOrigin: box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : Rect.zero,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Logout",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () async {
                await SessionManager.clearSession();

                Get.delete<
                    UdateProfileController>();

                try {
                  final tempDir = await getTemporaryDirectory();
                  if (tempDir.existsSync()) {
                    tempDir.deleteSync(recursive: true);
                  }
                } catch (e) {
                  debugPrint("Error clearing cache: $e");
                }

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Yes"),
            )
          ],
        );
      },
    );
  }
}
