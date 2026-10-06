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
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: email);
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      print("Error launching email: $e");
      _showCopySnackBar('Email', email);
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
      if (!await launchUrl(mapsUri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $mapsUri';
      }
    } catch (e) {
      print("Error launching maps: $e");
      _showCopySnackBar('Address', address);
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanedNumber);
    try {
      if (!await launchUrl(launchUri)) {
        throw 'Could not launch $launchUri';
      }
    } catch (e) {
      print("Error launching dialer: $e");
      _showCopySnackBar('Phone number', cleanedNumber);
    }
  }

  void _showCopySnackBar(String label, String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label: $value'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Copied to clipboard'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: ColorHelperClass.getColorFromHex(
                ColorResources.logo_color,
              ).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              icon,
              color: ColorHelperClass.getColorFromHex(
                ColorResources.logo_color,
              ),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernExpansionTile({
    required String title,
    required List<Widget> children,
    IconData icon = Icons.location_on_outlined,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.0,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          childrenPadding:
              const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
          iconColor: ColorHelperClass.getColorFromHex(
            ColorResources.logo_color,
          ),
          collapsedIconColor: Colors.grey.shade600,
          leading: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: ColorHelperClass.getColorFromHex(
                ColorResources.logo_color,
              ).withOpacity(0.10),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              icon,
              color: ColorHelperClass.getColorFromHex(
                ColorResources.logo_color,
              ),
              size: 18,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildAddress(String address) {
    return GestureDetector(
      onTap: () => _launchMaps(address),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_pin, color: Colors.redAccent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                address,
                style: const TextStyle(
                  fontSize: 13.5,
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

  Widget _buildPhoneNumber(String phoneNumber, String displayText,
      {bool isMobile = false}) {
    if (phoneNumber.trim().isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _launchPhone(phoneNumber),
      child: Container(
        margin: const EdgeInsets.only(top: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              isMobile ? Icons.phone_android : Icons.phone,
              color: Colors.green.shade600,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayText,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailRow(String email) {
    return GestureDetector(
      onTap: () => _launchEmail(email),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.email_outlined,
              color: ColorHelperClass.getColorFromHex(
                ColorResources.logo_color,
              ),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                email,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipHighlightCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Membership Related Query, Email To',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildContactTile(
              name: 'Satya Narayan Somani',
              email: 'sn.somani15@gmail.com',
            ),
            const SizedBox(height: 10),
            _buildContactTile(
              name: 'Ramavtar Satyanarayan Chandak',
              email: 'gssbpl101@gmail.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({required String name, required String email}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: ColorHelperClass.getColorFromHex(
                  ColorResources.logo_color,
                ).withOpacity(0.12),
                child: Icon(
                  Icons.person,
                  color: ColorHelperClass.getColorFromHex(
                    ColorResources.logo_color,
                  ),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _launchEmail(email),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.email,
                    color: ColorHelperClass.getColorFromHex(
                      ColorResources.logo_color,
                    ),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoColor =
        ColorHelperClass.getColorFromHex(ColorResources.logo_color);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: logoColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                logoColor,
                logoColor.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Contact Us',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMembershipHighlightCard(),
            _sectionHeader('Addresses', Icons.location_city),
            _modernExpansionTile(
              title: 'Maheshwari Pragati Mandal (Main Office)',
              children: [
                _buildAddress(
                    '603, Maheshwari Bhavan, Jagannath Shankar Seth Road, Girgaon, Mumbai – 400 002'),
                const SizedBox(height: 10),
                _buildPhoneNumber('02222005026', '022 2200 5026 / 27 / 28'),
              ],
            ),
            _modernExpansionTile(
              title: 'Maheshwari Bhavan - Andheri',
              children: [
                _buildAddress(
                    'Maheshwari Bhavan Chowk, New Link Road Extn, Shreeram Taparia Marg, New Oshiwara Police Station, Andheri (W), Mumbai – 400 053'),
                const SizedBox(height: 10),
                _buildPhoneNumber('02226374256', '022 2637 4256 / 57'),
                _buildPhoneNumber('+919372258324', '+91 93722 58324',
                    isMobile: true),
              ],
            ),
            _modernExpansionTile(
              title: 'Maheshwari Bhavan - Borivali',
              children: [
                _buildAddress(
                    'Behind Velniken School, Near Yogi Nagar, Linking Road, Borivali (W), Mumbai – 400 091'),
                const SizedBox(height: 10),
                _buildPhoneNumber(
                    '02226374253', '022 2637 4253 / 54 / 55 / 33 / 36'),
                _buildPhoneNumber('+918591528918', '+91 85915 28918',
                    isMobile: true),
              ],
            ),
            _modernExpansionTile(
              title: 'Maheshwari Bhavan - Ghatkopar',
              children: [
                _buildAddress(
                    'Gadodia Shopping Centre, Gadodia Nagar, Ghatkopar (E), Mumbai – 400 077'),
                const SizedBox(height: 10),
                _buildPhoneNumber('+919969188396', '+91 99691 88396',
                    isMobile: true),
              ],
            ),
            _modernExpansionTile(
              title: 'Maheshwari Bhavan - Goregaon',
              children: [
                _buildAddress(
                    'A3/6, Ground Floor, Shiv Mandir compound , SV Road , Mahesh Nagar, Goregaon (West), Mumbai - 400062'),
                const SizedBox(height: 10),
                _buildPhoneNumber('+918779111565', '+91 87791 11565',
                    isMobile: true),
              ],
            ),
            const SizedBox(height: 8),
            _sectionHeader('Emails', Icons.mail_outline),
            _modernExpansionTile(
              title: 'General Enquiry',
              icon: Icons.support_agent,
              children: [_buildEmailRow('info@mpmmumbai.in')],
            ),
            _modernExpansionTile(
              title: 'Account Related',
              icon: Icons.account_balance_wallet_outlined,
              children: [_buildEmailRow('accounts@mpmmumbai.in')],
            ),
            _modernExpansionTile(
              title: 'Girgaon Bhavan Booking & Related Work',
              icon: Icons.event_available_outlined,
              children: [_buildEmailRow('booking.girgaum@mpmmumbai.in')],
            ),
            _modernExpansionTile(
              title: 'Andheri Bhavan Booking & Related Work',
              icon: Icons.event_available_outlined,
              children: [_buildEmailRow('booking.andheri@mpmmumbai.in')],
            ),
            _modernExpansionTile(
              title: 'Matrimony Related Work',
              icon: Icons.favorite_border,
              children: [_buildEmailRow('matrimonial@mpmmumbai.in')],
            ),
            _modernExpansionTile(
              title: 'Enquiry Related To Shiksha Sahyog Samiti',
              icon: Icons.school_outlined,
              children: [_buildEmailRow('shikshasahyog@mpmmumbai.in')],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
