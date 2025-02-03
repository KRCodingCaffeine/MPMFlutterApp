import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactViewPage extends StatefulWidget {
  const ContactViewPage({super.key});

  @override
  State<ContactViewPage> createState() => _ContactViewPageState();
}

class _ContactViewPageState extends State<ContactViewPage> {
  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      throw 'Could not launch $email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white54,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Address',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // First ExpansionTile
            const ExpansionTile(
              title: Text(
                'Maheshwari Bhavan - Girgaon',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                          height:
                              8), // Increased spacing for better readability
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical:
                                8.0), // Add padding above and below the Row
                        child: Row(
                          children: [
                            Icon(Icons.location_pin,
                                color: Colors.black, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '603, Jaganath Shankar Seth Road, Mumbai – 400 002.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height:
                                      1.5, // Improved line height for text readability
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: 8), // Added larger spacing between sections
                      Text(
                        'Contact Numbers:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8), // Consistent spacing
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.phone, color: Colors.black, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '2200 5026 / 27 / 28 / 33 / 36',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 2.5, // Improved line height
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Second ExpansionTile
            const ExpansionTile(
              title: Text(
                'Maheshwari Bhavan - Andheri',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.location_pin,
                                color: Colors.black, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Plot No. R 14/15, Link Road Extension, Oshiwara, Near Tarapur Garden,\n Mumbai – 400 053',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Contact Numbers:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.phone, color: Colors.black, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '2637 4256 / 57',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 2.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.phone_android,
                                color: Colors.black, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '+91 93722 58324',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 2.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Third ExpansionTile
            const ExpansionTile(
              title: Text(
                'Maheshwari Bhavan - Borivali',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.location_pin,
                                color: Colors.black, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Behind Velikeni School, Near Yogi Nagar, Linking Road, Borivali (W)\n Mumbai – 400 091.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Contact Numbers:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.phone, color: Colors.black, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '2637 4253 / 54 / 55 / 33 / 36',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 2.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.phone_android,
                                color: Colors.black, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '+91 85915 28918',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 2.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Email Section with Icon
            const Text(
              'Email',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // Account Related Work
            const SizedBox(height: 10),

            ExpansionTile(
              title: const Text(
                'Account Related Work',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical:
                          8.0), // Increased horizontal padding for more left space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => _launchEmail('accounts@mpmmumbai.in'),
                        child: const Row(
                          children: [
                            Icon(Icons.email, color: Colors.black, size: 15),
                            SizedBox(width: 8),
                            Text(
                              'accounts@mpmmumbai.in',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Matrimony Related Work
            ExpansionTile(
              title: const Text(
                'Matrimony Related Work',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => _launchEmail('matrimonial@mpmmumbai.in'),
                        child: const Row(
                          children: [
                            Icon(Icons.email, color: Colors.black, size: 15),
                            SizedBox(width: 8),
                            Text(
                              'matrimonial@mpmmumbai.in',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Any Type of Enquiry and all Samiti related Work
            ExpansionTile(
              title: const Text(
                'Any Type of Enquiry and all Samiti related Work',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => _launchEmail('info@mpmmumbai.in'),
                        child: const Row(
                          children: [
                            Icon(Icons.email, color: Colors.black, size: 15),
                            SizedBox(width: 8),
                            Text(
                              'info@mpmmumbai.in',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Girgaum Bhavan Booking Related and other Work
            ExpansionTile(
              title: const Text(
                'Girgaum Bhavan Booking Related and other Work',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () =>
                            _launchEmail('booking.girgaum@mpmmumbai.in'),
                        child: const Row(
                          children: [
                            Icon(Icons.email, color: Colors.black, size: 15),
                            SizedBox(width: 8),
                            Text(
                              'booking.girgaum@mpmmumbai.in',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Andheri Bhavan Booking Related and other Work
            ExpansionTile(
              title: const Text(
                'Andheri Bhavan Booking Related and other Work',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () =>
                            _launchEmail('booking.andheri@mpmmumbai.in'),
                        child: const Row(
                          children: [
                            Icon(Icons.email, color: Colors.black, size: 15),
                            SizedBox(width: 8),
                            Text(
                              'booking.andheri@mpmmumbai.in',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
