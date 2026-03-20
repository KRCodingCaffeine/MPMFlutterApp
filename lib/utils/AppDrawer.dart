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
  /// True when running on tablet/iPad (shortest side >= 600).
  static bool _isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final UdateProfileController dashBoardController = Get.find();
    final isTablet = _isTablet(context);

    // Wider drawer on iPad so menu titles are not cramped or hidden (Guideline 4).
    final double? drawerWidth = isTablet ? 400.0 : null;
    final theme = drawerWidth != null
        ? Theme.of(context).copyWith(
            drawerTheme: Theme.of(context).drawerTheme.copyWith(width: drawerWidth),
          )
        : null;

    // Responsive sizes for header and list items
    final double headerPadding = isTablet ? 20.0 : 10.0;
    final double avatarRadius = isTablet ? 48.0 : 40.0;
    final double nameFontSize = isTablet ? 18.0 : 14.0;
    final double metaFontSize = isTablet ? 14.0 : 12.0;
    final double listTilePaddingH = isTablet ? 24.0 : 16.0;
    final double listTilePaddingV = isTablet ? 16.0 : 8.0;
    final double titleFontSize = isTablet ? 17.0 : 14.0;
    final double iconSize = isTablet ? 28.0 : 24.0;

    Widget drawerChild = ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Color(0xFFcd4e2b),
          ),
          padding: EdgeInsets.all(headerPadding),
          child: Row(
            children: [
              // Profile Image
              Stack(
                children: [
                  Obx(() {
                    return CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.grey[300],
                      child: ClipOval(
                        child: (dashBoardController.profileImage.value.isNotEmpty)
                            ? FadeInImage(
                                placeholder: const AssetImage("assets/images/user3.png"),
                                image: NetworkImage(Urls.imagePathUrl +
                                    dashBoardController.profileImage.value),
                                imageErrorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    "assets/images/male.png",
                                    fit: BoxFit.cover,
                                    width: avatarRadius * 2,
                                    height: avatarRadius * 2,
                                  );
                                },
                                fit: BoxFit.cover,
                                width: avatarRadius * 2,
                                height: avatarRadius * 2,
                              )
                            : Image.asset(
                                "assets/images/user3.png",
                                fit: BoxFit.cover,
                                width: avatarRadius * 2,
                                height: avatarRadius * 2,
                              ),
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(width: isTablet ? 20 : 12),
              Expanded(
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dashBoardController.userName.value.isNotEmpty
                          ? dashBoardController.userName.value
                          : "Guest User",
                      style: TextStyle(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Text(
                      "Membership Code : ${(dashBoardController.memberCode.value.trim().isNotEmpty) ? dashBoardController.memberCode.value : " -- "}",
                      style: TextStyle(
                        fontSize: metaFontSize,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Text(
                      "Mobile: ${dashBoardController.mobileNumber.value.isNotEmpty ? dashBoardController.mobileNumber.value : "N/A"}",
                      style: TextStyle(
                        fontSize: metaFontSize,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                )),
              ),
            ],
          ),
        ),
        _drawerTile(
          context,
          icon: Icons.home,
          title: 'Home',
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          contentPadding: EdgeInsets.symmetric(horizontal: listTilePaddingH, vertical: listTilePaddingV),
          onTap: () {
            Navigator.pop(context);
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        _drawerTile(
          context,
          icon: Icons.person,
          title: 'My Profile',
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          contentPadding: EdgeInsets.symmetric(horizontal: listTilePaddingH, vertical: listTilePaddingV),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, RouteNames.profile);
          },
        ),
        _drawerTile(
          context,
          icon: Icons.share,
          title: 'Share App',
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          contentPadding: EdgeInsets.symmetric(horizontal: listTilePaddingH, vertical: listTilePaddingV),
          onTap: () {
            Navigator.pop(context);
            _onShare(context);
          },
        ),
        _drawerTile(
          context,
          icon: Icons.ios_share,
          title: 'Share Membership Form',
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          contentPadding: EdgeInsets.symmetric(horizontal: listTilePaddingH, vertical: listTilePaddingV),
          onTap: () {
            Navigator.pop(context);
            _onSharememberForm(context);
          },
        ),
        _drawerTile(
          context,
          icon: Icons.file_copy,
          title: 'Forms',
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          contentPadding: EdgeInsets.symmetric(horizontal: listTilePaddingH, vertical: listTilePaddingV),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, RouteNames.forms);
          },
        ),
        _drawerTile(
          context,
          icon: Icons.account_balance,
          title: 'Bhavan Booking',
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          contentPadding: EdgeInsets.symmetric(horizontal: listTilePaddingH, vertical: listTilePaddingV),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, RouteNames.bhavan_booking);
          },
        ),
        _drawerTile(
          context,
          icon: Icons.contact_page,
          title: 'Enquiry Form',
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          contentPadding: EdgeInsets.symmetric(horizontal: listTilePaddingH, vertical: listTilePaddingV),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, RouteNames.add_enquiry_form);
          },
        ),
        _drawerTile(
          context,
          icon: Icons.info,
          title: 'About Us',
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          contentPadding: EdgeInsets.symmetric(horizontal: listTilePaddingH, vertical: listTilePaddingV),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, RouteNames.aboutUs);
          },
        ),
        _drawerTile(
          context,
          icon: Icons.headset_mic,
          title: 'Contact Us',
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          contentPadding: EdgeInsets.symmetric(horizontal: listTilePaddingH, vertical: listTilePaddingV),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, RouteNames.contactUs);
          },
        ),
        _drawerTile(
          context,
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          contentPadding: EdgeInsets.symmetric(horizontal: listTilePaddingH, vertical: listTilePaddingV),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, RouteNames.pravacypolicy);
          },
        ),
        _drawerTile(
          context,
          icon: Icons.description,
          title: 'Terms & Condition',
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          contentPadding: EdgeInsets.symmetric(horizontal: listTilePaddingH, vertical: listTilePaddingV),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, RouteNames.termandcondition);
          },
        ),
        _drawerTile(
          context,
          icon: Icons.exit_to_app,
          title: 'Logout',
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          contentPadding: EdgeInsets.symmetric(horizontal: listTilePaddingH, vertical: listTilePaddingV),
          onTap: () {
            Navigator.pop(context);
            _showLogoutDialog(context);
          },
        ),
        SizedBox(height: isTablet ? 40 : 30),
      ],
    );

    final drawer = Drawer(
      backgroundColor: Colors.white,
      child: drawerChild,
    );

    if (theme != null) {
      return Theme(data: theme, child: drawer);
    }
    return drawer;
  }

  static Widget _drawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required double iconSize,
    required double titleFontSize,
    required EdgeInsets contentPadding,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: contentPadding,
      leading: Icon(icon, size: iconSize),
      title: Text(
        title,
        style: TextStyle(fontSize: titleFontSize),
        overflow: TextOverflow.visible,
        maxLines: 2,
      ),
      onTap: onTap,
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
        'https://members.mumbaimaheshwari.com/user/registration';

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
