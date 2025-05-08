import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
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

    try {
      // First try to launch directly in Gmail app
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(
          emailLaunchUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to any email client
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      print("Error launching email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email: $email'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: email));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> _launchMaps(String address) async {
    final Uri mapsUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      queryParameters: {'api': '1', 'query': address},
    );

    try {
      if (!await launchUrl(
        mapsUri,
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Could not launch $mapsUri';
      }
    } catch (e) {
      print("Error launching maps: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Address: $address'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: address));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
        ),
      );
    }
  }

  Widget _buildAddress(String address) {
    return GestureDetector(
      onTap: () => _launchMaps(address),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.location_pin, color: Colors.black87, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumber(String phoneNumber, String displayText, {bool isMobile = false}) {
    return phoneNumber.trim().isNotEmpty
        ? GestureDetector(
      onTap: () async {
        final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
        final Uri launchUri = Uri(scheme: 'tel', path: cleanedNumber);

        try {
          if (!await launchUrl(launchUri)) {
            throw 'Could not launch $launchUri';
          }
        } catch (e) {
          print("Error launching dialer: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Phone number: $cleanedNumber'),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Copy',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: cleanedNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(isMobile ? Icons.phone_android : Icons.phone,
                color: Colors.black87, size: 20),
            const SizedBox(width: 8),
            Text(
              displayText,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
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

            // First ExpansionTile - Girgaon
            ExpansionTile(
              title: const Text(
                'Maheshwari Pragati Mandal (Main Office)',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Address:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAddress('603, Maheshwari Bhavan, Jagannath Shankar Seth Road, Girgaon, Mumbai – 400 002'),
                      const SizedBox(height: 8),
                      const Text(
                        'Contact Numbers:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPhoneNumber('02222005026', '022 2200 5026 / 27 / 28'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Second ExpansionTile - Andheri
            ExpansionTile(
              title: const Text(
                'Maheshwari Bhavan - Andheri',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Address:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAddress('Maheshwari Bhavan Chowk, Link Road Extension, New Oshiwara Police Station, Andheri (W), Mumbai – 400 053'),
                      const SizedBox(height: 8),
                      const Text(
                        'Contact Numbers:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPhoneNumber('02226374256', '022 2637 4256 / 57'),
                      _buildPhoneNumber('+919372258324', '+91 93722 58324', isMobile: true),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Third ExpansionTile - Borivali
            ExpansionTile(
              title: const Text(
                'Maheshwari Bhavan - Borivali',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Address:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAddress('Near Yogi Nagar, New Link Road, Borivali (W), Mumbai – 400 091'),
                      const SizedBox(height: 8),
                      const Text(
                        'Contact Numbers:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPhoneNumber('02228691564', '022 2869 1564'),
                      _buildPhoneNumber('+918591528918', '+91 85915 28918', isMobile: true),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fourth ExpansionTile - Ghatkopar
            ExpansionTile(
              title: const Text(
                'Maheshwari Bhavan - Ghatkopar',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Address:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAddress('Gadodia Shopping Centre, Gadodia Nagar, Ghatkopar (E), Mumbai – 400 077'),
                      const SizedBox(height: 8),
                      const Text(
                        'Contact Numbers:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPhoneNumber('02225060626', '022 25060626'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fifth ExpansionTile - Goregaon
            ExpansionTile(
              title: const Text(
                'Maheshwari Bhavan - Goregaon',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Address:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAddress('A/3, Flat No.6, Mahesh Nagar, S.V. Road, Goregaon (W), Mumbai - 400062'),
                      const SizedBox(height: 8),
                      const Text(
                        'Contact Numbers:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPhoneNumber('+919324436231', '+91 93244 36231', isMobile: true),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Email Section with Icon
            const Text(
              'Emails',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Any Type of Enquiry and all Samiti related Work
            ExpansionTile(
              title: const Text(
                'Any Type of Enquiry and all Samiti related Work',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _launchEmail('info@mpmmumbai.in'),
                        child: const Row(
                          children: [
                            Icon(Icons.email, color: Colors.black87, size: 15),
                            SizedBox(width: 8),
                            Text(
                              'info@mpmmumbai.in',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
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

            // Account Related Work
            ExpansionTile(
              title: const Text(
                'Account Related Work',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _launchEmail('accounts@mpmmumbai.in'),
                        child: const Row(
                          children: [
                            Icon(Icons.email, color: Colors.black87, size: 15),
                            SizedBox(width: 8),
                            Text(
                              'accounts@mpmmumbai.in',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
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
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _launchEmail('matrimonial@mpmmumbai.in'),
                        child: const Row(
                          children: [
                            Icon(Icons.email, color: Colors.black87, size: 15),
                            SizedBox(width: 8),
                            Text(
                              'matrimonial@mpmmumbai.in',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
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
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _launchEmail('booking.girgaum@mpmmumbai.in'),
                        child: const Row(
                          children: [
                            Icon(Icons.email, color: Colors.black87, size: 15),
                            SizedBox(width: 8),
                            Text(
                              'booking.girgaum@mpmmumbai.in',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
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
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _launchEmail('booking.andheri@mpmmumbai.in'),
                        child: const Row(
                          children: [
                            Icon(Icons.email, color: Colors.black87, size: 15),
                            SizedBox(width: 8),
                            Text(
                              'booking.andheri@mpmmumbai.in',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
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

            // Any Type of Enquiry Related To Shiksha Sahyog Samiti
            ExpansionTile(
              title: const Text(
                'Any Type of Enquiry Related To Shiksha Sahyog Samiti',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _launchEmail('shikshasahyog@mpmmumbai.in'),
                        child: const Row(
                          children: [
                            Icon(Icons.email, color: Colors.black87, size: 15),
                            SizedBox(width: 8),
                            Text(
                              'shikshasahyog@mpmmumbai.in',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
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