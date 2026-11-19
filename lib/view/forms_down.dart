import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
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
  late final List<double?> _progress;
  late final List<String?> _filePaths;
  late final List<String?> _downloadErrors;
  late final List<VoidCallback?> _dialogRefresh;
  final Map<int, Future<Uint8List>> _downloads = {};
  final List<CancelToken> _cancelTokens = [];

  final List<Map<String, dynamic>> forms = [
    // {
    //   'title': 'Karyakarta form 2022-24',
    //   'fileName' : 'karyakarta_form',
    //   'icon': Icons.picture_as_pdf,
    //   'color': const Color(0xFFd6d6d6),
    //   'url': 'https://members.mumbaimaheshwari.com/api/public/assets/forms/karyakartha_form.pdf',
    // },
    {
      'title': 'Scholarship Application Form',
      'fileName' : 'scholarship_form',
      'thumbnail': 'assets/images/forms/scholarship_form.png',
      'color': const Color(0xFFd6d6d6),
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/application_for_loan_scholarship.pdf',
    },
    {
      'title': 'Radhakrishna Lahoti Sahayata Kosh Form',
      'fileName' : 'radhakrishna_lahoti_form',
      'thumbnail': 'assets/images/forms/radhakrishna_lahoti_form.png',
      'color': const Color(0xFFd6d6d6),
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/radhakrishna_lahoti_sahayata_kosh_form.pdf',
    },
    {
      'title': 'Membership Form',
      'fileName' : 'membership_form',
      'thumbnail': 'assets/images/forms/membership_form.png',
      'color': const Color(0xFFd6d6d6),
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/membership_form.pdf',
    },
    {
      'title': 'Shiksha Form',
      'fileName' : 'shiksha_form',
      'thumbnail': 'assets/images/forms/shiksha_form.png',
      'color': const Color(0xFFd6d6d6),
      'url':
      'https://members.mumbaimaheshwari.com/api/public/assets/forms/shiksha_form.pdf',
    },
    {
      'title': 'Student Prize Application',
      'fileName' : 'student_prize_form',
      'thumbnail': 'assets/images/forms/student_prize_form.png',
      'color': const Color(0xFFd6d6d6),
      'url': 'https://members.mumbaimaheshwari.com/api/public/assets/forms/student_price_application_form.pdf',
    },
  ];

  @override
  void initState() {
    super.initState();
    _progress = List<double?>.filled(forms.length, null);
    _filePaths = List<String?>.filled(forms.length, null);
    _downloadErrors = List<String?>.filled(forms.length, null);
    _dialogRefresh = List<VoidCallback?>.filled(forms.length, null);
    _requestPermission();
  }

  @override
  void dispose() {
    for (final token in _cancelTokens) {
      if (!token.isCancelled) {
        token.cancel();
      }
    }
    super.dispose();
  }

  Future<Directory> _storageDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        return directory;
      }
    }
    return getApplicationDocumentsDirectory();
  }

  Future<File> _pdfFile(int index) async {
    final directory = await _storageDirectory();
    final fileName = forms[index]['fileName'] as String;
    return File('${directory.path}/$fileName.pdf');
  }

  void _refreshDownload(int index) {
    if (mounted) setState(() {});
    _dialogRefresh[index]?.call();
  }

  Future<void> _onFormTap(int index) async {
    final pdf = await _pdfFile(index);
    if (!mounted) return;

    final alreadySaved = await pdf.exists() && await pdf.length() > 0;
    _downloadErrors[index] = null;
    _progress[index] = alreadySaved ? 0.04 : 0;
    if (alreadySaved) {
      _filePaths[index] = pdf.path;
    }

    var dialogAlive = true;
    var allowAutoOpen = true;
    var openingForm = false;
    BuildContext? dialogContextRef;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        dialogContextRef = dialogContext;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            _dialogRefresh[index] = () {
              if (!dialogAlive || !dialogContext.mounted) return;
              setDialogState(() {});
            };
            return _buildDownloadDialog(dialogContext, index);
          },
        );
      },
    ).whenComplete(() {
      dialogAlive = false;
      _dialogRefresh[index] = null;
      if (!openingForm) allowAutoOpen = false;
    });

    Future<void> openFinishedForm() async {
      final path = _filePaths[index];
      if (path == null) return;
      await Future.delayed(const Duration(milliseconds: 400));
      if (!allowAutoOpen || !mounted) return;
      openingForm = true;
      final dialog = dialogContextRef;
      if (dialog != null && dialog.mounted) {
        Navigator.of(dialog).pop();
      }
      await OpenFilex.open(path);
    }

    if (alreadySaved) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted || !allowAutoOpen) return;
      _progress[index] = 1;
      _refreshDownload(index);
      await openFinishedForm();
      return;
    }

    try {
      await _downloadForm(index, pdf);
      if (_progress[index] == 1 && _filePaths[index] != null) {
        await openFinishedForm();
      }
    } catch (e) {
      if (!mounted) return;
      _downloadErrors[index] = 'Download failed: $e';
      _progress[index] = null;
      _refreshDownload(index);
    }
  }

  Future<Uint8List> _downloadForm(int index, File pdf) {
    return _downloads[index] ??= _downloadFormImpl(index, pdf);
  }

  Future<Uint8List> _downloadFormImpl(int index, File pdf) async {
    final url = forms[index]['url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Invalid file URL');
    }

    final permissionStatus = await _requestPermission();
    if (!permissionStatus) {
      throw Exception('Storage permission is required');
    }

    final cancelToken = CancelToken();
    _cancelTokens.add(cancelToken);

    try {
      if (mounted) {
        _progress[index] = 0;
        _refreshDownload(index);
      }

      final response = await dio.get<List<int>>(
        url,
        cancelToken: cancelToken,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (!mounted || total <= 0) return;
          _progress[index] = received / total;
          _refreshDownload(index);
        },
      );

      final bytes = Uint8List.fromList(response.data ?? []);
      if (bytes.isEmpty) {
        throw Exception('Downloaded file is empty');
      }

      await pdf.writeAsBytes(bytes, flush: true);
      if (mounted) {
        _progress[index] = 1;
        _filePaths[index] = pdf.path;
        _downloadErrors[index] = null;
        _refreshDownload(index);
      }
      return bytes;
    } catch (e) {
      _downloads.remove(index);
      if (e is DioException && CancelToken.isCancel(e)) {
        return Uint8List(0);
      }
      if (mounted) {
        _progress[index] = null;
        _refreshDownload(index);
      }
      rethrow;
    }
  }





  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ (use READ_MEDIA_* permissions if needed)
        return true; // No need to ask if downloading to app-private or using DownloadManager
      } else if (sdkInt >= 30) {
        // Android 11 or 12
        var status = await Permission.storage.request();
        if (status.isGranted) return true;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is needed to download the file.')),
        );
        return false;
      } else {
        // Android 10 or below
        var status = await Permission.storage.request();
        if (status.isGranted) return true;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is needed to download the file.')),
        );
        return false;
      }
    }
    return true;
  }

  Widget _buildThumbnail(int index) {
    final thumbnail = forms[index]['thumbnail'] as String;
    return Image.asset(
      thumbnail,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.description_outlined, size: 48, color: Colors.grey),
    );
  }

  Widget _buildDownloadProgressBar(double value, {required bool showLabel}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 28,
          width: double.infinity,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 1.6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.04, 1),
              heightFactor: 1,
              child: const ColoredBox(color: Color(0xFF2F6FE8)),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 10),
          const Text(
            'Downloading...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDownloadDialog(BuildContext dialogContext, int index) {
    final title = forms[index]['title'] as String;
    final progress = _progress[index];
    final filePath = _filePaths[index];
    final error = _downloadErrors[index];
    final ready = progress == 1 && filePath != null;
    final percent = ready
        ? 100
        : (((progress ?? 0) * 100).round()).clamp(1, 99);
    final accent = ColorHelperClass.getColorFromHex(ColorResources.logo_color);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error != null)
            Text(error, textAlign: TextAlign.center)
          else
            _buildDownloadProgressBar(percent / 100, showLabel: !ready),
          if (ready) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: BorderSide(color: accent),
                      minimumSize: const Size(0, 42),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 42),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      OpenFilex.open(filePath);
                    },
                    child: const Text('Open'),
                  ),
                ),
              ],
            ),
          ] else if (error != null) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildCard(int index) {
    final title = forms[index]['title'] as String;
    return GestureDetector(
      onTap: () => _onFormTap(index),
      child: Card(
        color: Colors.white,
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Expanded(
              child: ColoredBox(
                color: Colors.white,
                child: _buildThumbnail(index),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black),
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
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Forms Download',
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
            childAspectRatio: 0.72,
          ),
          itemCount: forms.length,
          itemBuilder: (context, index) {
            return buildCard(index);
          },
        ),
      ),
    );
  }
}
