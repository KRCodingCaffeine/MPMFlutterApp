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
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Privacy Policy',
              style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w500),
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
            _sectionTitle("Privacy Policy"),
            _paragraph(
                "Maheshwari Pragati Mandal (MPM) is a non-profit Social Organization of Maheshwari community. MPM is committed to maintain and protect your privacy. We respect user privacy and value user trust. This policy is aimed to explain you what information we require, how it is protected, how we use it and with whom it is shared in order to provide you an effective and satisfactory service. By using our service, you agree to the terms of this Privacy Policy"),
            _sectionTitle("USE OF INFORMATION"),
            _paragraph(
                "MPM collect only limited information from users what is required to connect him with other members of Maheshwari community.\n\nFrom new users, we collect and store name, photo, family details, mobile number, e-mail address, residential and office address, educational details, professional details, KYC documents etc as provided by member in our database. MPM does not control any third party sites and does not take the responsibility for the misuse of the personal data or bank account, credit card information provided by the users to the third party."),
            _sectionTitle("USER ACCOUNT PASSWORDS AND REGISTRATION"),
            _paragraph(
                "User agree that the information user provide to MPM on registration and at all other times, including payment, will be true, accurate, current, and complete and user agrees to keep it accurate and up-to-date at all times. User agrees to indemnify MPM from any liabilities in case his user's account is not secured (e.g., in the event of a loss, theft or unauthorized disclosure or use of User account ID, PIN, Password, or any credit, debit or prepaid cash card number or net-banking login/password, if applicable). In such event user agrees to immediately notify MPM. User ID is a username that will identify user account and thereby all of user transactions and account related activity on MPM.\n\nYou are required to use a log in ID and password to login our site in secured mode. You are solely responsible to keep this password confidential and for all activities originated from the misuse of this password. We advise you to change your password on regular intervals and keep it confidential.\n\nMPM never, under any circumstances, asks for user account password."),
            _sectionTitle("SHARING OF INFORMATION"),
            _paragraph(
                "MPM may share information with carefully screened third party service providers for the sole purpose of providing you good quality services you have desired. Examples of such third party services are Merchants, Banks, NBFCs,   MPM may be required by law to disclose your personal information; even if you requested that we don't share your information. This information may be necessary to identify, contact or bring legal action against anyone who committed any offence as per stated laws and regulations. MPM keeps you informed about new features, products and promotions which are of interest to you via email or SMS from time to time."),
            _sectionTitle("COOKIES"),
            _paragraph(
                "A 'cookie' is information stored on the browser by the web server so that it can be later read back from the browser. MPM will not collect any personal information thru Cookies. However, cookies may be tied up with information if you have previously provided such identifiable information on the browser. Aggregate cookie and tracking information may be shared with third parties as per the requirement of the service."),
            _sectionTitle("LINKS TO OTHER SITES"),
            _paragraph(
                "The Services and/or the Site may include links or references to other web sites or services solely to provide better products and services to users. MPM does not endorse any such Reference Sites or the information, materials, products, or services contained on or accessible through Reference Sites. Please be aware that MPM is not responsible for the privacy practices, or content of other sites. When you leave our site, we would encourage our users to read the privacy statements of these sites. You should evaluate the security and trustworthiness of any other site connected or accessed through this site yourself, before disclosing any personal information to them. In addition, user correspondence or business dealings with, or participation in promotions of, advertisers found on or through the Services and/or the Site are solely between User and such entity. Access and use of reference sites, including the information, materials, products, and services on or available through reference sites is solely at user own risk. MPM will not accept any responsibility for any loss or damage in whatever manner, howsoever caused, resulting from your disclosure to third parties of personal information."),
            _sectionTitle("CHANGES AND MODIFICATIONS"),
            _paragraph(
                "MPM reserves the right to modify the Privacy Policy at any time. The revised policy would be posted on our website whenever it undergoes changes."),
            _sectionTitle("COMMUNICATE TO US"),
            _paragraph(
                "MPM will take all necessary steps to keep your information private and guard your privacy. Please contact us in case of following:\n\n• If there is any change in your personal information\n• If you observe a mistake in the information stored on our site\n• If you feel that we are not abiding by the privacy policy stated above."),
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