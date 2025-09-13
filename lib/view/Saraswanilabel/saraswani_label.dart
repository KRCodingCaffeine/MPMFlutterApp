import 'dart:io';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/GetSaraswaniPublication/GetSaraswaniPublicationData.dart';
import 'package:mpm/model/GetSaraswaniPublication/GetSaraswaniPublicationModelClass.dart';
import 'package:mpm/repository/get_saraswani_publication_repository/get_saraswani_publication_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// ✅ NEW IMPORTS
import 'package:mpm/model/GetLatestSaraswaniPublication/GetLatestSaraswaniPublicationData.dart';
import 'package:mpm/model/GetLatestSaraswaniPublication/GetLatestSaraswaniPublicationModelClass.dart';
import 'package:mpm/repository/get_latest_saraswani_publication_repository/get_latest_saraswani_publication_repo.dart';

class SaraswanilabelView extends StatefulWidget {
  const SaraswanilabelView({Key? key}) : super(key: key);

  @override
  State<SaraswanilabelView> createState() => _SaraswanilabelViewState();
}

class _SaraswanilabelViewState extends State<SaraswanilabelView> {
  bool isFilterDrawerOpen = false;
  String? selectedMonth;
  String? selectedYear;

  bool _isDownloading = false;
  int _downloadProgress = 0;
  String? _downloadingFileName;
  SaraswaniPublicationData? _publicationData;

  final Dio _dio = Dio();
  final SaraswaniPublicationRepository _repository =
  SaraswaniPublicationRepository();

  final List<String> months = List.generate(12, (index) {
    final date = DateTime(0, index + 1);
    return DateFormat.MMMM().format(date);
  });

  final List<String> years = List.generate(11, (index) {
    return (2025 + index).toString();
  });

  List<GetLatestSaraswaniPublicationData> _allPublications = [];
  bool _isLoadingAllPublications = false;

  Future<void> _fetchSaraswaniPublication() async {
    if (selectedMonth == null || selectedYear == null) {
      setState(() => _publicationData = null);
      return;
    }

    try {
      final SaraswaniPublicationModelClass response =
      await _repository.fetchSaraswaniPublication(
        month: selectedMonth!,
        year: selectedYear!,
      );

      setState(() {
        if (response.status == true && response.data?.documentPath != null) {
          _publicationData = response.data;
        } else {
          _publicationData = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Something went wrong, Please try again later."),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(12),
            ),
          );
        }
      });
    } catch (e) {
      setState(() => _publicationData = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Selected Month and Year publication is not available."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
        ),
      );
    }
  }

  Future<void> _fetchAllSaraswaniPublications() async {
    setState(() => _isLoadingAllPublications = true);
    try {
      final repo = GetLatestSaraswaniPublicationRepo();
      final response = await repo.fetchlatestSaraswaniPublications();

      if (response.status == true && response.data != null) {
        setState(() => _allPublications = response.data!);
      } else {
        setState(() => _allPublications = []);
      }
    } catch (e) {
      setState(() => _allPublications = []);
    } finally {
      setState(() => _isLoadingAllPublications = false);
    }
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) return true;

      var status = await Permission.storage.request();
      if (status.isGranted) return true;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('Storage permission is needed to download the file.')),
      );
      return false;
    }
    return true;
  }

  Future<void> _downloadAndOpenFile(String url, String fileName) async {
    final permissionStatus = await _requestPermission();
    if (!permissionStatus) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      Directory? directory = Platform.isAndroid
          ? (await getExternalStorageDirectory())
          : await getApplicationDocumentsDirectory();

      String filePath = "${directory!.path}/$fileName";

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            int newProgress = ((received / total) * 100).toInt();
            setState(() => _downloadProgress = newProgress);
          }
        },
      );

      setState(() => _isDownloading = false);

      _showDownloadDialog(context, fileName, filePath);
    } catch (e) {
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong, Please try again later."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
        ),
      );
    }
  }

  void _showDownloadDialog(BuildContext context, String fileName, String filePath) {
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

  Widget _buildFilterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        onTap: () => setState(() => isFilterDrawerOpen = true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Filter Saraswani",
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (selectedYear != null)
                          Chip(
                            label: Text(selectedYear!),
                            labelStyle: const TextStyle(
                                fontSize: 12, color: Colors.white),
                            backgroundColor: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                            deleteIcon: const Icon(Icons.close,
                                color: Colors.white, size: 18),
                            onDeleted: () {
                              setState(() {
                                selectedYear = null;
                                _publicationData = null;
                              });
                            },
                          ),
                        if (selectedMonth != null)
                          Chip(
                            label: Text(selectedMonth!),
                            labelStyle: const TextStyle(
                                fontSize: 12, color: Colors.white),
                            backgroundColor: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                            deleteIcon: const Icon(Icons.close,
                                color: Colors.white, size: 18),
                            onDeleted: () {
                              setState(() {
                                selectedMonth = null;
                                _publicationData = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.filter_list),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),

          title: Text(
            "${selectedMonth ?? ''} ${selectedYear ?? ''}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),

          subtitle: const Text("Tap to download & view",
              style: TextStyle(fontSize: 12)),

          trailing: _isDownloading
              ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              value: _downloadProgress / 100,
              strokeWidth: 2,
            ),
          )
              : const Icon(Icons.download, size: 22),

          onTap: () {
            if (_publicationData?.documentPath != null) {
              final fileName = "Saraswani_${selectedMonth}_${selectedYear}.pdf";

              setState(() {
                _isDownloading = true;
                _downloadingFileName = fileName;
              });

              _downloadAndOpenFile(_publicationData!.documentPath!, fileName).then((_) {
                setState(() {
                  _isDownloading = false;
                  _downloadingFileName = null;
                });
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildAllPublications() {
    if (_isLoadingAllPublications) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allPublications.isEmpty) {
      return const Center(child: Text("No publications available"));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _allPublications.length,
      itemBuilder: (context, index) {
        final item = _allPublications[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
              title: Text(
                "${item.month} ${item.year}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: const Text(
                "Tap to download & view",
                style: TextStyle(fontSize: 12),
              ),
              trailing: _isDownloading && _downloadingFileName ==
                  "Saraswani_${item.month}_${item.year}.pdf"
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  value: _downloadProgress / 100,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.download, size: 22),
              onTap: () {
                if (item.documentPath != null) {
                  final fileName = "Saraswani_${item.month}_${item.year}.pdf";

                  setState(() {
                    _isDownloading = true;
                    _downloadingFileName = fileName;
                  });

                  _downloadAndOpenFile(item.documentPath!, fileName).then((_) {
                    setState(() {
                      _isDownloading = false;
                      _downloadingFileName = null;
                    });
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterDrawer() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Material(
        elevation: 16,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Filter Saraswani",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => isFilterDrawerOpen = false),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: "Select Year",
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26, width: 1.5),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  labelStyle: const TextStyle(color: Colors.black45),
                ),
                child: DropdownButton<String>(
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  isExpanded: true,
                  underline: Container(),
                  value: selectedYear,
                  hint: const Text("Select Year"),
                  items: years
                      .map((year) =>
                      DropdownMenuItem(value: year, child: Text(year)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedYear = value),
                ),
              ),
              const SizedBox(height: 20),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: "Select Month",
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26, width: 1.5),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  labelStyle: const TextStyle(color: Colors.black45),
                ),
                child: DropdownButton<String>(
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  isExpanded: true,
                  underline: Container(),
                  value: selectedMonth,
                  hint: const Text("Select Month"),
                  items: months
                      .map((month) =>
                      DropdownMenuItem(value: month, child: Text(month)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedMonth = value),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    setState(() => isFilterDrawerOpen = false);
                    await _fetchSaraswaniPublication();
                  },
                  child:
                  const Text("Apply Filter", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchAllSaraswaniPublications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          "Saraswani",
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
        body: Stack(
          children: [
            Column(
              children: [
                _buildFilterButton(),
                Expanded(
                  child: RefreshIndicator(
                    color: Colors.redAccent,
                    onRefresh: () async => _fetchSaraswaniPublication(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          if (_publicationData != null)
                            _buildBody(),

                          if (_publicationData == null)
                            _buildAllPublications(),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            if (isFilterDrawerOpen) _buildFilterDrawer(),
          ],
        ),
    );
  }
}
