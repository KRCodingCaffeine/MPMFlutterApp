import 'package:flutter/material.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsconditionViewPage extends StatefulWidget {
  const TermsconditionViewPage({super.key});

  @override
  State<TermsconditionViewPage> createState() => _TermsconditionViewPageState();
}

class _TermsconditionViewPageState extends State<TermsconditionViewPage> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_loadHtmlContent());
  }

  String _loadHtmlContent() {
    return '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 10px;
            background-color: #f4f4f4;
        }
        h2 {
            color: black;
            font-size: 1.4rem;
            margin-top: 20px;
        }
        p {
            margin-left: 20px;
           }
        ul {
            padding-left: 20px;
        }
        li {
            font-size: 0.9em;
            margin: 8px 0;
            list-style-type: none;
            position: relative;
            padding-left: 10px;
        }
        li::before {
            content: "•";
            position: absolute;
            left: 0;
            color: #2c3e50;
            font-size: 1.2e
            textAlign: TextAlign.justify,
        a {
            text-decoration: none;
            color: #3498db;
            font-size: 0.9rem;
        }
        b {
            font-size: 1rem;
            color: #333;
        }
      </style>
    </head>
    <body>
      <h2>Terms and Conditions</h2>
      <p>The users of <b> Maheshwari Pragati Mandal (MPM) </b> using this Website and Mobile App by implication, means that users have gone through and agreed & abide by following disclaimer, Terms & Conditions.</p>
      
      <h2>No Warranty</h2>
      <p>It is imperative to note that MPM has taken required efforts to ensure that the information/ statement/ certificate provided on the MPM Web Site is reasonably accurate, however, MPM does not warrant its accuracy, completeness or suitability, correctness, adequacy validity, whatsoever for any purpose. As such database provided is without any warranty, express or implied, as to their legal effect.</p>
      
      <h2>No Liability to MPM</h2>
      <ul>
        <li>Though, MPM has taken proper care/precaution to make the database reliable, MPM will not be held responsible for any liability that may arise out of any such error in the data base. Further, MPM does not represent that MPM’s Web Site and Mobile App are free of viruses or harmful components.</li>
        <li>Use of any information/statement/certificate on MPM’s site shall be at your own risk.</li>
        <li>All information/statements/certificates should be used in accordance with applicable laws. And MPM does not undertake any kind of liability whatsoever for the same.</li>
        <li>In case of transaction/ statement /certificate is not in agreement with your record or with the information that you have, you are requested to write to MPM. You are free to mail your queries on <a href="mailto:info@mpmmumbai.in">info@mpmmumbai.in</a>.</li>
        <li>MPM has provided information/data base on the Web Site on an "as is where is " basis. MPM expressly disclaims to the maximum limit permissible by law, all warranties, express or implied, including, but not limiting to implied warranties of merchantability, fitness for a particular purpose and non-infringement.</li>
        <li>MPM disclaims all responsibility for any loss, injury, liability or damage of any kind resulting from and arising out of, your use of the site.</li>
      </ul>
      
      <h2>Membership Fee Refund Policy</h2>
        <ul>
          <li>The applicant has to pay the membership fee plus the payment gateway charges, as per the prevailing policy of the MPM.</li>
          <li>If the membership application is accepted, the lifetime fee paid shall not be refunded.</li>
          <li>If MPM management committee finds that data given in the membership application form and additional documents submitted are not in order, then MPM has the rights to disapprove the application and refund the fee paid by the applicant.</li>
        </ul>
              
      <h2>Other Terms & Conditions</h2>
      <ul>
        <li>It will be the sole responsibility of the User to ensure that the use of password is kept confidential and not disclosed to any third party, including any representative of the MPM, or its agents and shall take all possible care to prevent discovery of the password by any person.</li>
        <li>MPM makes no representations about the timeliness of the services contained on the MPM site for any purpose.</li>
        <li>MPM makes no representations about the suitability, reliability, availability, of the services contained on the MPM web site for any purpose.</li>
        <li>MPM shall not be responsible if any information/ database/ statement/ certificate/ page is printed/ downloaded from MPM's site and after printing/ downloading complete/partial, text/information is altered/ removed/ obscured contained therein.</li>
        <li>MPM, at no event, be liable/ responsible for any direct, indirect, punitive, incidental, special, consequential damages or any damages whatsoever including, without limitation, damages for loss of use, data or profits, arising out of or in any way connected with the use of the MPM's web sites.</li>
        <li>MPM, at no event, be liable/ responsible for any direct, indirect, punitive, incidental, special, consequential damages or any damages for the delay or inability to use the MPM web site, or failure to provide services, or for any information, date, statement, certificate, software, and any other services obtained through the MPM web sites, or otherwise arising out of the use of MPM web site.</li>
        <li>Certain services, such as payments depend on continuous connection to the MPM database. MPM makes no assurance, representation, promise whatsoever that such connectivity will always be available.</li>
        <li>MPM reserves the right to suspend these services if in MPM’s opinion security of the site or of the data could be compromised.</li>
        <li>MPM may also suspend services on the web site for any member at its sole discretion without assigning any reason whatsoever. In such event user shall contact MPM office for any clarification.</li>
      </ul>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Terms and Conditions',
              style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w500),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: WebViewWidget(controller: _controller),
    );
  }
}
