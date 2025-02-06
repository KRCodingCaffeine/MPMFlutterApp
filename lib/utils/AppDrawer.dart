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
              decoration: BoxDecoration(
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
                            style: TextStyle(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DashboardView()), // Navigate to the HomePage widget
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('My Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfileView()), // Navigate to the HomePage widget
                );
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
              leading: Icon(Icons.share),
              title: Text('Share App'),
              onTap: () {
                _showShareBottomSheet(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.file_copy),
              title: Text('Forms'),
              onTap: () {
                Navigator.pushNamed(context, RouteNames.forms);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance),
              title: Text('Government Scheme'),
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
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text('Terms & Condition'),
              onTap: () {
                Navigator.pushNamed(context, RouteNames.termandcondition);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Share App",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text("Share this app with your friends on social media!"),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareOnSocialMedia(String platform) {
    const String playStoreLink = 'https://play.google.com/store/apps/details?id=com.example.yourapp';
    const String appStoreLink = 'https://apps.apple.com/app/id123456789'; // Replace with actual link

    String shareText = "🚀 Check out this amazing app! \n\n📲 Download Now: \n👉 Android: $playStoreLink\n👉 iOS: $appStoreLink";

    switch (platform) {
      case "Facebook":
      // Implement Facebook sharing logic
        break;
      case "Twitter":
      // Implement Twitter sharing logic
        break;
      case "Google+":
      // Implement Google+ sharing logic
        break;
      case "LinkedIn":
      // Implement LinkedIn sharing logic
        break;
      case "Dropbox":
      // Implement Dropbox sharing logic
        break;
      case "Reddit":
      // Implement Reddit sharing logic
        break;
      case "Skype":
      // Implement Skype sharing logic
        break;
      case "Pinterest":
      // Implement Pinterest sharing logic
        break;
      default:
        Share.share(
          shareText,
          subject: "Download Our App!",
        );
    }
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
