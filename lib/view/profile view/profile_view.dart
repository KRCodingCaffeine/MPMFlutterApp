import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/utils/Session.dart';

import 'package:mpm/view/login_view.dart';
import 'package:mpm/view/profile%20view/Education_page_info.dart';
import 'package:mpm/view/profile%20view/business_info_page.dart';
import 'package:mpm/view/profile%20view/family_info_page.dart';
import 'package:mpm/view/profile%20view/personal_info_page.dart';
import 'package:mpm/view/profile%20view/residence_info_page.dart';


class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  final String userName = "Karthika K Rajesh";
  final String mobileNumber = "8898085105";

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path); // Set the picked image
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.white,
        elevation: 0, // Removes the shadow for a cleaner look
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile Picture Section
            Center(
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Profile Image Section
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40, // Adjusted size for better visibility
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : const AssetImage("assets/images/logo.png")
                                    as ImageProvider,
                            backgroundColor: Colors.grey[300],
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // User Information Section
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  "1001",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.lightBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Mobile: $mobileNumber",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Settings Section Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // Buttons Section
                buildButton(
                  context: context,
                  icon: const Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.black,
                  ),
                  title: 'View/Edit Personal Info',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PersonalInformationPage(),
                      ),
                    );
                  },
                ),
                buildButton(
                  context: context,
                  icon: const Icon(
                    Icons.home,
                    size: 20,
                    color: Colors.black,
                  ),
                  title: 'View/Edit Residential Info',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResidenceInformationPage(),
                      ),
                    );
                  },
                ),
                buildButton(
                  context: context,
                  icon: const Icon(
                    Icons.school,
                    size: 20,
                    color: Colors.black,
                  ),
                  title: 'View/Edit Family Info',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FamilyInfoPage(),
                      ),
                    );
                  },
                ),
                buildButton(
                  context: context,
                  icon: const Icon(
                    Icons.home,
                    size: 20,
                    color: Colors.black,
                  ),
                  title: 'View/Edit Education Info',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EducationPageInfo(),
                      ),
                    );
                  },
                ),
                buildButton(
                  context: context,
                  icon: const Icon(
                    Icons.work,
                    size: 20,
                    color: Colors.black,
                  ),
                  title: 'View/Edit Occupation Info',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BusinessInformationPage(),
                      ),
                    );
                  },
                ),

                // Styled Logout Button
                buildLogoutButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to build regular buttons (Personal Info, Residence Info, etc.)
  Widget buildButton({
    required BuildContext context,
    required Icon icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          title: GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    icon, // Display the icon here
                    const SizedBox(
                        width: 10), // Add some space between icon and text
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ),
      ],
    );
  }

  // Function to build the Logout button with the desired style
  Widget buildLogoutButton(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: GestureDetector(
            onTap: () {
              _showLogoutDialog(context); // Trigger logout dialog on tap
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent, // Background color of the button
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Icon(
                    Icons.exit_to_app,
                    size: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Logout dialog function
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                // Clear session and navigate to login
                SessionManager.clearSession();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
