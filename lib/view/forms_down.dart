import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FormsDownloadView extends StatefulWidget {
  const FormsDownloadView({super.key});

  @override
  State<FormsDownloadView> createState() => _FormsDownloadViewState();
}

class _FormsDownloadViewState extends State<FormsDownloadView> {
  final List<Map<String, dynamic>> forms = [
    {
      'title': 'Metropolis',
      'icon': Icons.picture_as_pdf,
      'color': Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/metropolis.pdf'
    },
    {
      'title': 'Bombay Hospital',
      'icon': Icons.picture_as_pdf,
      'color': Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/bombay_hospital.pdf'
    },
    {
      'title': 'Nura',
      'icon': Icons.picture_as_pdf,
      'color': Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/nura.pdf'
    },
    {
      'title': 'Kokilaben Dhirubhai Ambani Hospital',
      'icon': Icons.picture_as_pdf,
      'color': Color(0xFFd6d6d6),
      'url': 'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/kokilaben_dhirubhai_ambai_hospital.pdf'
    },
    {
      'title': 'Karyakarta Form 2022-24',
      'icon': Icons.picture_as_pdf,
      'color': Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/karyakartha_form.pdf'
    },
    {
      'title': 'Scholarship Application Form',
      'icon': Icons.picture_as_pdf,
      'color': Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/application_for_loan_scholarship.pdf'
    },
    // {
    //   'title': 'Radhakrishna Lahoti Sahayata Kosh Form',
    //   'icon': Icons.picture_as_pdf,
    //   'color': Color(0xFFd6d6d6),
    //   'url': 'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/radhakrishna_lahoti_sahayata_kosh_form.pdf'
    // },
    {
      'title': 'Membership Form',
      'icon': Icons.picture_as_pdf,
      'color': Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/membership_form.pdf'
    },
    {
      'title': 'Shiksha Form',
      'icon': Icons.picture_as_pdf,
      'color': Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/shiksha_form.pdf'
    },
    {
      'title': 'Student Prize Application',
      'icon': Icons.picture_as_pdf,
      'color': Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/student_price_application_form.pdf'
    },
    {
      'title': 'Pulse',
      'icon': Icons.picture_as_pdf,
      'color': Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/pulse_hospital.pdf'
    },
    {
      'title': 'Lilavati Hospital & Research Center',
      'icon': Icons.picture_as_pdf,
      'color': Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/lilavati_hospital.pdf'
    },
  ];

  Widget buildCard(String title, IconData icon, Color color, String pdfUrl) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunch(pdfUrl)) {
          await launch(pdfUrl);
        } else {
          throw 'Could not open $pdfUrl';
        }
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 50, color: color),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Forms Download",
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: Color(0xFFcd4e2b),
        iconTheme: const IconThemeData(
            color: Colors.white), // Ensures back icon is white
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cards per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: forms.length,
          itemBuilder: (context, index) {
            final form = forms[index];
            return buildCard(
              form['title'],
              form['icon'],
              form['color'],
              form['url'],
            );
          },
        ),
      ),
    );
  }
}
