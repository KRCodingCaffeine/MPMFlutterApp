import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/images.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/view/dashboard_view.dart';
import 'package:mpm/view/home_view.dart';
import 'package:mpm/view/login_view.dart';
import 'package:mpm/view/profile%20view/profile_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'color_helper.dart';
import 'color_resources.dart'; // Add this import to handle image picking

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  File? _profileImage;
  final String userName =
      'Karthika K Rajesh'; // Replace with the actual dynamic value
  final String mobileNumber =
      '8898085105'; // Replace with the actual dynamic value
  final String lmCode = 'LM0001'; // Replace with the actual dynamic value

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {}

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white, // Set background color
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
                                userName, // Display logged-in user's name
                                style: const TextStyle(
                                  fontSize:
                                      14, // Adjusted font size for better readability
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                lmCode, // Display Lm code (logged-in member code)
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Mobile: $mobileNumber", // Display mobile number
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
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const DashboardView()), // Navigate to the HomePage widget
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pushNamed(context,
                    RouteNames.profile); // Navigate to the HomePage widget
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_search),
              title: const Text('Search Members'),
              onTap: () {
                Navigator.pushNamed(context, RouteNames.searchmember);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Samiti Members'),
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
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pushNamed(context, RouteNames.aboutUs);
              },
            ),
            ListTile(
              leading: const Icon(Icons.headset_mic),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.pushNamed(context, RouteNames.contactUs);
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pushNamed(context, RouteNames.privacypolicy);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Terms & Condition'),
              onTap: () {
                Navigator.pushNamed(context, RouteNames.termandcondition);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
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
