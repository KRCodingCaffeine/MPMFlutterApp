import 'package:flutter/material.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class PrivacyPolicyViewPage extends StatefulWidget {
  const PrivacyPolicyViewPage({super.key});

  @override
  State<PrivacyPolicyViewPage> createState() => _PrivacyPolicyViewPageState();
}

class _PrivacyPolicyViewPageState extends State<PrivacyPolicyViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
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
            _sectionTitle("Privacy Policy"),
            _paragraph(
                "Maheshwari Pragati Mandal (MPM) is a non-profit Social Organization of Maheshwari community. MPM is committed to maintaining and protecting your privacy. We respect user privacy and value user trust. This policy is aimed to explain what information we require, how it is protected, how we use it, and with whom it is shared to provide you with an effective and satisfactory service. By using our service, you agree to the terms of this Privacy Policy."),
            _sectionTitle("USE OF INFORMATION"),
            _paragraph(
                "MPM collects only limited information from users required to connect them with other members of the Maheshwari community.\n\nFrom new users, we collect and store name, photo, family details, mobile number, email address, residential and office address, educational details, professional details, KYC documents, etc., as provided by the member in our database. MPM does not control any third-party sites and does not take responsibility for the misuse of personal data or banking information provided by users to third parties."),
            _sectionTitle("USER ACCOUNT PASSWORDS AND REGISTRATION"),
            _paragraph(
                "Users agree that the information provided to MPM during registration and at all other times, including payment, will be true, accurate, current, and complete. Users agree to keep it up-to-date at all times. Users agree to indemnify MPM from any liabilities in case their account is not secured. In such events, users agree to immediately notify MPM."),
            _sectionTitle("SHARING OF INFORMATION"),
            _paragraph(
                "MPM may share information with carefully screened third-party service providers solely to provide users with high-quality services. Examples include Merchants, Banks, and NBFCs. MPM may be required by law to disclose personal information. MPM also keeps users informed about new features, products, and promotions via email or SMS."),
            _sectionTitle("COOKIES"),
            _paragraph(
                "A 'cookie' is information stored on the browser by the web server so that it can be later read back. MPM does not collect personal information through cookies but may use them to enhance user experience."),
            _sectionTitle("LINKS TO OTHER SITES"),
            _paragraph(
                "The Services and/or the Site may include links to other websites solely to provide better products and services. MPM is not responsible for the privacy practices or content of other sites. Users should evaluate the security and trustworthiness of any linked sites before disclosing personal information."),
            _sectionTitle("CHANGES AND MODIFICATIONS"),
            _paragraph(
                "MPM reserves the right to modify the Privacy Policy at any time. The revised policy will be posted on our website whenever changes occur."),
            _sectionTitle("COMMUNICATE TO US"),
            _paragraph(
                "MPM takes all necessary steps to keep your information private. Please contact us if:\n\n• There is any change in your personal information\n• You observe an error in the stored information\n• You feel that we are not abiding by the privacy policy stated above."),
            _sectionTitle("FOR ANY COMMUNICATION, PLEASE WRITE TO US AT:"),
            _paragraph(
                "Maheshwari Pragati Mandal\nMaheshwari Bhavan, Jagannath Shankar Seth Rd, Marine Lines East,\nBhangwadi, Marine Lines, Mumbai, Maharashtra 400002\nPhone: 8850758921 or 022 5026/27/28\nEmail: info@mpmmumbai.in"),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _paragraph(String content) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.justify,
      ),
    );
  }
}