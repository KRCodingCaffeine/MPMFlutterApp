import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class FormsDownloadView extends StatefulWidget {
  const FormsDownloadView({super.key});

  @override
  State<FormsDownloadView> createState() => _FormsDownloadViewState();
}

class _FormsDownloadViewState extends State<FormsDownloadView> {
  ReceivePort _port = ReceivePort();

  final List<Map<String, dynamic>> forms = [
    {
      'title': 'Karyakarta form 2022-24',
      'icon': Icons.picture_as_pdf,
      'color': const Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/karyakartha_form.pdf',
    },
    {
      'title': 'Scholarship Application Form',
      'icon': Icons.picture_as_pdf,
      'color': const Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/application_for_loan_scholarship.pdf',
    },
    {
      'title': 'Radhakrishna Lahoti Sahayata Kosh Form',
      'icon': Icons.picture_as_pdf,
      'color': const Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/radhakrishna_lahoti_sahayata_kosh_form.pdf',
    },
    {
      'title': 'Membership Form',
      'icon': Icons.picture_as_pdf,
      'color': const Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/membership_form.pdf',
    },
    {
      'title': 'Shiksha Form',
      'icon': Icons.picture_as_pdf,
      'color': const Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/shiksha_form.pdf',
    },
    {
      'title': 'Student Prize Application',
      'icon': Icons.picture_as_pdf,
      'color': const Color(0xFFd6d6d6),
      'url':
          'https://krcodingcaffeine.com/pragati-mandal-api/public/assets/forms/student_price_application_form.pdf',
    },
  ];

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      int status = data[1];
      int progress = data[2];

      if (status == DownloadTaskStatus.complete.index) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download completed!')),
        );
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  Future<void> _downloadFile(String? url, String? fileName) async {
    if (url == null || fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid file url or file name')),
      );
      return;
    }

    final status = await Permission.storage.request();
    if (status.isGranted) {
      final taskId = await FlutterDownloader.enqueue(
        url: url, // Now guaranteed to be non-null
        savedDir: '/storage/emulated/0/Download',
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );

      if (taskId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fileName downloading...')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed for $fileName')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied for storage')),
      );
    }
  }

  Future<bool> _requestPermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    }

    var status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    }

    // Additional check for Android 11+ (MANAGE_EXTERNAL_STORAGE)
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permission denied for storage')),
    );

    return false;
  }

  Widget buildCard(String title, IconData icon, Color color, String url) {
    return GestureDetector(
      onTap: () {
        _downloadFile(url, "$title.pdf");
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
              ),
            );
          },
        ),
      ),
    );
  }
}
