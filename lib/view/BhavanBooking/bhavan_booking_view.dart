import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';


class BhavanBookingView extends StatefulWidget {
  const BhavanBookingView({super.key});

  @override
  State<BhavanBookingView> createState() => _BhavanBookingViewState();
}

class _BhavanBookingViewState extends State<BhavanBookingView> {

  final Dio _dio = Dio();
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> onlineForms = [
    {
      'title': 'Girgaon Bhavan',
      'fileName': 'girgoan_bhavan',
      'icon': Icons.account_balance,
      'url': 'https://booking.mpmmumbai.in/',
    },
    {
      'title': 'Andheri Bhavan',
      'fileName': 'andheri_bhavan',
      'icon': Icons.account_balance,
      'url': 'https://bookingandheri.mpmmumbai.in/',
    },
  ];

  final List<Map<String, dynamic>> offlineForms = [
    {
      'title': 'Girgaon Booking Form',
      'fileName': 'girgoan_bhavan',
      'icon': Icons.picture_as_pdf,
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/girgoan_offline.pdf',
    },
    {
      'title': 'Andheri Booking Form',
      'fileName': 'andheri_bhavan',
      'icon': Icons.picture_as_pdf,
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/andheri_bhavan.pdf',
    },
    {
      'title': 'Ghatkopar Booking Form',
      'fileName': 'ghatkopar_bhavan',
      'icon': Icons.picture_as_pdf,
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/ghatkopar_bhavan.pdf',
    },
    {
      'title': 'Borivali Booking Form',
      'fileName': 'borivali_bhavan',
      'icon': Icons.picture_as_pdf,
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/borivali_plot.pdf',
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

      Navigator.of(context, rootNavigator: true).pop();

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

  Future<void> _openWebsite(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open website")),
        );
      }
    }
  }

  Widget buildCard(
      String title,
      IconData icon,
      Color color,
      String url,
      String fileName,
      ) {
    final bool isPdf = url.toLowerCase().endsWith(".pdf");

    return GestureDetector(
      onTap: () {
        if (isPdf) {
          _downloadAndOpenPdf(url, "$fileName.pdf");
        } else {
          _openWebsite(url);
        }
      },
      child: Card(
        color: Colors.white,
        elevation: 6,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: Colors.redAccent,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  isPdf ? "Offline Booking" : "Online Booking",
                  style: TextStyle(
                    fontSize: 11,
                    color: isPdf ? Colors.grey : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            _buildTabButton("Online Booking", 0),
            const SizedBox(width: 8),
            _buildTabButton("Offline Booking", 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.redAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 13,
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
      body: Column(
        children: [
          _buildBookingFilterTabs(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: _selectedTabIndex == 0
                    ? onlineForms.length
                    : offlineForms.length,
                itemBuilder: (context, index) {
                  final form = _selectedTabIndex == 0
                      ? onlineForms[index]
                      : offlineForms[index];

                  return buildCard(
                    form['title'],
                    form['icon'],
                    Colors.redAccent,
                    form['url'],
                    form['fileName'],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
