import 'package:flutter/material.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class AboutViewPage extends StatefulWidget {
  const AboutViewPage({super.key});

  @override
  State<AboutViewPage> createState() => _AboutViewPageState();
}

class _AboutViewPageState extends State<AboutViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'About',
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
              'ORGANISATION AT A GLANCE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // Text Section
            Padding(
              padding: const EdgeInsets.only(left: 26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• A Socio-Charitable Trust/Organisation established 61 years ago in the city of Mumbai.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Represents more than 4,000 Maheshwari families residing in Mumbai.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• The Mandal family has a current strength of more than 7,500 members.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• 650 active members, including 250 Ladies and 150 Youth, carry out activities through various committees such as:\n'
                    '  - Board of Trustees\n'
                    '  - Managing Committee\n'
                    '  - 8 Central Samitis\n'
                    '  - 8 Regional Samitis\n'
                    '  - 8 Regional Ladies Samitis\n'
                    '  - 8 Regional Yuva Samitis\n'
                    '  - 5 Bhavan Management Samitis\n'
                    '  - Medical Assistance Fund, etc.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Organises nearly 150 programmes every year through various Samitis.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Equipped with modern amenities, Maheshwari Bhavan at Girgaum provides concessional accommodation to outstation Samaj Bandhus visiting for medical treatment.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• A 5-storey Bhavan, measuring 40,000 sq. ft. at Andheri Link Road, is available for weddings, spiritual discourses, and auspicious events.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• An open plot, measuring 36,000 sq. ft., is available at Borivali for social events.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Provides assistance to underprivileged members through the "Radha Krishna Lahoti Smriti Kosh."',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Offers financial assistance for medical purposes through the "Chikitsa Sahayata Kosh."',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Provides support to those affected by natural calamities such as droughts, earthquakes, and floods.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Distributes loans for educational purposes and financial aid for students going abroad through the "Videsh Shiksha Kosh."',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Fully sponsors students’ education under the "Student Adoption Scheme."',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Communicates with its 7,500+ members through the Mandal’s monthly magazine – "Saraswani."',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
