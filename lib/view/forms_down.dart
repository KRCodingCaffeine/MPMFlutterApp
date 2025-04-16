import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';


class FormsDownloadView extends StatefulWidget {
  const FormsDownloadView({super.key});

  @override
  State<FormsDownloadView> createState() => _FormsDownloadViewState();
}

class _FormsDownloadViewState extends State<FormsDownloadView> {
  final Dio dio = Dio();

  final List<Map<String, dynamic>> forms = [
    {
      'title': 'Karyakarta form 2022-24',
      'fileName' : 'karyakarta_form',
      'icon': Icons.picture_as_pdf,
      'color': const Color(0xFFd6d6d6),
      'url': 'https://members.mumbaimaheshwari.com/api/public/assets/forms/karyakartha_form.pdf',
    },
    {
      'title': 'Scholarship Application Form',
      'fileName' : 'scholarship_form',
      'icon': Icons.picture_as_pdf,
      'color': const Color(0xFFd6d6d6),
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/application_for_loan_scholarship.pdf',
    },
    {
      'title': 'Radhakrishna Lahoti Sahayata Kosh Form',
      'fileName' : 'radhakrishna_lahoti_form',
      'icon': Icons.picture_as_pdf,
      'color': const Color(0xFFd6d6d6),
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/radhakrishna_lahoti_sahayata_kosh_form.pdf',
    },
    {
      'title': 'Membership Form',
      'fileName' : 'membership_form',
      'icon': Icons.picture_as_pdf,
      'color': const Color(0xFFd6d6d6),
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/membership_form.pdf',
    },
    {
      'title': 'Shiksha Form',
      'fileName' : 'shiksha_form',
      'icon': Icons.picture_as_pdf,
      'color': const Color(0xFFd6d6d6),
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/shiksha_form.pdf',
    },
    {
      'title': 'Student Prize Application',
      'fileName' : 'student_prize_form',
      'icon': Icons.picture_as_pdf,
      'color': const Color(0xFFd6d6d6),
      'url': 'https://members.mumbaimaheshwari.com/api/public/assets/forms/student_price_application_form.pdf',
    },
  ];

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _downloadFile(String? url, String? fileName) async {
    if (url == null || fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid file URL or file name')),
      );
      return;
    }

    final permissionStatus = await _requestPermission();
    if (!permissionStatus) return;

    try {
      Directory? directory = await getExternalStorageDirectory();
      String newPath = "/storage/emulated/0/Download";
      directory = Directory(newPath);

      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      String filePath = "${directory.path}/$fileName";
      Dio dio = Dio();
      int progress = 0;

      // Show a persistent Snackbar with a StatefulBuilder
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      StateSetter? setSnackbarState;

      final snackBarController = scaffoldMessenger.showSnackBar(
        SnackBar(
          content: StatefulBuilder(
            builder: (context, setState) {
              setSnackbarState = setState; // Capture setState function
              return Text("Downloading $fileName ... $progress%");
            },
          ),
          duration: const Duration(days: 1), // Keep it open
        ),
      );

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            int newProgress = ((received / total) * 100).toInt();
            if (newProgress != progress) {
              progress = newProgress;

              // Update Snackbar text dynamically
              if (setSnackbarState != null) {
                setSnackbarState!(() {}); // Update Snackbar text
              }
            }
          }
        },
      );
      // Hide progress Snackbar
      snackBarController.close();

      // Show success Snackbar
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("$fileName - Downloaded successfully."),
          action: SnackBarAction(
            label: "View",
            onPressed: () {
              OpenFilex.open(filePath);  // Open the downloaded PDF
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }




  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) return true;

      if (await Permission.manageExternalStorage.isGranted) return true;

      var status = await Permission.manageExternalStorage.request();

      if (status.isGranted) {
        return true;
      } else {
        // Open settings manually
        bool opened = await openAppSettings();
        if (!opened) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable storage permission from settings')),
          );
        }
      }
      return false;
    }

    return true; // iOS doesn't need this
  }



  Widget buildCard(String title, IconData icon, Color color, String url, String fileName) {
    return GestureDetector(
      onTap: () {
        _downloadFile(url, "$fileName.pdf");
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: color),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
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
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: forms.length,
          itemBuilder: (context, index) {
            final form = forms[index];
            return Center(
              child: buildCard(
                  form['title'],
                  form['icon'],
                  form['color'],
                  form['url'],
                  form['fileName']
              ),
            );
          },
        ),
      ),
    );
  }
}
