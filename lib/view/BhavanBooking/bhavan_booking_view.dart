import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';


class BhavanBookingView extends StatefulWidget {
  const BhavanBookingView({super.key});

  @override
  State<BhavanBookingView> createState() => _BhavanBookingViewState();
}

class _BhavanBookingViewState extends State<BhavanBookingView> {
  bool _isDownloading = false;
  int _downloadProgress = 0;

  final Dio _dio = Dio();
  final List<Map<String, dynamic>> forms = [
    {
      'title': 'Girgoan Bhavan',
      'fileName': 'girgoan_bhavan',
      'icon': Icons.account_balance,
      'color': const Color(0xFFd6d6d6),
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/girgoan_offline.pdf',
    },
    {
      'title': 'Andheri Bhavan',
      'fileName': 'andheri_bhavan',
      'icon': Icons.account_balance,
      'color': const Color(0xFFd6d6d6),
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/andheri_bhavan.pdf',
    },
    {
      'title': 'Ghatkopar Bhavan',
      'fileName': 'ghatkopar_bhavan',
      'icon': Icons.account_balance,
      'color': const Color(0xFFd6d6d6),
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/ghatkopar_bhavan.pdf',
    },
    {
      'title': 'Borivali Bhavan',
      'fileName': 'borivali_bhavan',
      'icon': Icons.account_balance,
      'color': const Color(0xFFd6d6d6),
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/borivali_plot.pdf',
    },
    {
      'title': 'Shiksha Form',
      'fileName' : 'shiksha_form',
      'icon': Icons.account_balance,
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


  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ doesn't require storage permission for app-specific files
        return true;
      }

      if (await Permission.storage.request().isGranted) {
        return true;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission is required to download the file.'),
        ),
      );

      return false;
    }
    return true;
  }

  Future<void> _downloadAndOpenPdf(String url, String fileName) async {
    final permissionStatus = await _requestPermission();
    if (!permissionStatus || !mounted) return;

    try {
      Directory directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      String filePath = "${directory.path}/$fileName";

      int progress = 0;
      late StateSetter setStateDialog;

      // 🔹 SHOW PROGRESS DIALOG
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              setStateDialog = setState;

              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: const Text(
                  "Downloading...",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 8,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    Text("$progress%"),
                  ],
                ),
              );
            },
          );
        },
      );

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            progress = ((received / total) * 100).toInt();
            setStateDialog(() {});
          }
        },
      );

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop(); // close progress

      _showDownloadDialog(context, fileName, filePath);

    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).maybePop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e")),
        );
      }
    }
  }
  void _showDownloadDialog(
      BuildContext context, String fileName, String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Download Complete",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),
          content: Text(
            "$fileName has been downloaded successfully.",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Close"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                OpenFilex.open(filePath);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("View"),
            ),
          ],
        );
      },
    );
  }

  Widget buildCard(String title, IconData icon, Color color, String url, String fileName) {
    return GestureDetector(
      onTap: () {
        _downloadAndOpenPdf(url, "$fileName.pdf");
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 6),

                // 🔹 Subtitle
                const Text(
                  "Offline Booking",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
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
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Bhavan Booking',
              style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w500),
            );
          },
        ),
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
