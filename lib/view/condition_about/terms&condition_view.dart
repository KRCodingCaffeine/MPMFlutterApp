import 'package:flutter/material.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package

class TermsconditionViewPage extends StatefulWidget {
  const TermsconditionViewPage({super.key});

  @override
  State<TermsconditionViewPage> createState() => _TermsconditionViewPageState();
}

class _TermsconditionViewPageState extends State<TermsconditionViewPage> {
  // Function to launch the email client
  _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'info@mpmmumbai.in',
    );
    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      throw 'Could not launch email client';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title:  Text("Terms and Conditions", style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        // Removed const here
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Section: Terms and Conditions Header and Description
            const Text(
              "Terms and Conditions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                // Removed const here
                "The users of Maheshwari Pragati Mandal (MPM) using this Website and Mobile App by implication, means that users have gone through and agreed & abide by following disclaimer, Terms & Conditions.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify, // Justified text alignment
              ),
            ),
            const SizedBox(height: 16),

            // Second Section: No Warranty
            const Text(
              "No warranty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                // Removed const here
                "It is imperative to note that MPM has taken required efforts to ensure that the information/ statement/ certificate provided on the MPM Web Site is reasonably accurate, however, MPM does not warrant its accuracy, completeness or suitability, correctness, adequacy validity, whatsoever for any purpose. As such database provided is without any warranty, express or implied, as to their legal effect.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 16),

            // Third Section: No Liability to MPM
            const Text(
              "No liability to MPM",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                "• Though, MPM has taken proper care/precaution to make the database reliable, MPM will not be held responsible for any liability that may arise out of any such error in the database. Further, MPM does not represent that MPM’s Web Site and Mobile App are free of viruses or harmful components.\n"
                "• Use of any information/statement/certificate on MPM’s site shall be at your own risk.\n"
                "• All information/statements/certificates should be used in accordance with applicable laws. And MPM does not undertake any kind of liability whatsoever for the same.\n"
                "• In case of transaction/ statement /certificate is not in agreement with your record or with the information that you have, you are requested to write to MPM. You are free to mail your queries on ",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Email: ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap:
                      _launchEmail, // Call the launch email function when clicked
                  child: const Text(
                    "info@mpmmumbai.in",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration:
                          TextDecoration.underline, // Makes it look like a link
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            const SizedBox(height: 16),

            // Fourth Section: Other Terms & Conditions
            const Text(
              "Other terms & conditions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                // Removed const here
                "• It will be the sole responsibility of the User to ensure that the use of password is kept confidential and not disclosed to any third party, including any representative of the MPM, or its agents and shall take all possible care to prevent discovery of the password by any person.\n"
                "• MPM makes no representations about the timeliness of the services contained on the MPM site for any purpose.\n"
                "• MPM makes no representations about the suitability, reliability, availability, of the services contained on the MPM web site for any purpose.\n"
                "• MPM shall not be responsible if any information/ database/ statement/ certificate/ page is printed/ downloaded from MPM's site and after printing/ downloading complete/partial, text/information is altered/ removed/ obscured contained therein.\n"
                "• MPM, at no event, be liable/responsible for any direct, indirect, punitive, incidental, special, consequential damages or any damages whatsoever including, without limitation, damages for loss of use, data or profits, arising out of or in any way connected with the use of the MPM's web sites.\n"
                "• MPM, at no event, be liable/responsible for any direct, indirect, punitive, incidental, special, consequential damages or any damages for the delay or inability to use the MPM web site, or failure to provide services, or for any information, date, statement, certificate, software, and any other services obtained through the MPM web sites, or otherwise arising out of the use of MPM web site.\n"
                "• Certain services, such as payments, depend on continuous connection to the MPM database. MPM makes no assurance, representation, promise whatsoever that such connectivity will always be available.\n"
                "• MPM reserves the right to suspend these services if in MPM’s opinion security of the site or of the data could be compromised.\n"
                "• MPM may also suspend services on the web site for any member at its sole discretion without assigning any reason whatsoever. In such event, user shall contact MPM office for any clarification.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
