import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mpm/model/GetClaimedOfferByID/GetClaimedOfferByIDModelClass.dart';
import 'package:mpm/repository/claimed_offer_by_id_repository/claimed_offer_by_id_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ClaimedOfferDetailPage.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ClaimedOfferListPage extends StatefulWidget {
  @override
  _ClaimedOfferListPageState createState() => _ClaimedOfferListPageState();
}

class _ClaimedOfferListPageState extends State<ClaimedOfferListPage> {
  late Future<ClaimedOfferModel> _claimedOffersFuture;
  final ClaimOfferRepository _repository = ClaimOfferRepository();
  int? memberId;
  String userName = 'Loading...';
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchOffers();
  }

  Future<void> _loadUserDataAndFetchOffers() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData != null) {
        final id = _parseMemberId(userData.memberId);
        if (id != null) {
          final name = _getUserName(
            userData.firstName,
            userData.middleName,
            userData.lastName,
          );

          setState(() {
            memberId = id;
            userName = name;
            _claimedOffersFuture = _repository.fetchClaimedOffersByMemberId(id);
          });
          return;
        }
      }
      setState(() {
        _claimedOffersFuture = Future.error('User data not available');
      });
    } catch (e) {
      setState(() {
        _claimedOffersFuture = Future.error('Failed to load user data: $e');
      });
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
      String filePath = "${directory!.path}/$fileName";
      int progress = 0;

      final scaffoldMessenger = ScaffoldMessenger.of(context);
      StateSetter? setSnackbarState;

      final snackBarController = scaffoldMessenger.showSnackBar(
        SnackBar(
          content: StatefulBuilder(
            builder: (context, setState) {
              setSnackbarState = setState;
              return Text("Downloading $fileName ... $progress%");
            },
          ),
          duration: const Duration(days: 1),
        ),
      );

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            int newProgress = ((received / total) * 100).toInt();
            if (newProgress != progress) {
              progress = newProgress;
              if (setSnackbarState != null) {
                setSnackbarState!(() {});
              }
            }
          }
        },
      );

      snackBarController.close();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("$fileName - Downloaded successfully."),
          action: SnackBarAction(
            label: "View",
            onPressed: () {
              OpenFilex.open(filePath);
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

  String _getUserName(String? firstName, String? middleName, String? lastName) {
    final fName = firstName ?? '';
    final mName = middleName?.isNotEmpty == true ? ' $middleName ' : ' ';
    final lName = lastName ?? '';
    return '$fName$mName$lName'.trim();
  }

  int? _parseMemberId(dynamic memberId) {
    if (memberId == null) return null;
    if (memberId is int) return memberId;
    if (memberId is String) return int.tryParse(memberId);
    return null;
  }

  Widget _buildDefaultLogo() {
    return Center(
      child: Image.asset(
        'assets/images/med-3.png',
        width: 75,
        height: 75,
      ),
    );
  }

  Widget _buildTag(String text, Color color,
      {Color textColor = Colors.white,
        double fontSize = 12,
        EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4)}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      final hour = dateTime.hour;
      final minute = dateTime.minute;
      final period = hour < 12 ? 'AM' : 'PM';
      final twelveHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;

      return '${dateTime.day}/${dateTime.month}/${dateTime.year} $twelveHour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text(
          'Claimed Offers',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<ClaimedOfferModel>(
        future: _claimedOffersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadUserDataAndFetchOffers,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.data == null || snapshot.data!.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No claimed offers found'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserDataAndFetchOffers,
                    child: Text('Refresh'),
                  ),
                ],
              ),
            );
          } else {
            final offers = snapshot.data!.data!;
            return RefreshIndicator(
              color: Colors.red,
              onRefresh: _loadUserDataAndFetchOffers,
              child: ListView.builder(
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return InkWell(
                    onTap: () {
                      if (offer.organisationSubcategoryId == 1) {
                        // Medical offer - navigate to detail page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClaimedOfferDetailPage(offer: offer),
                          ),
                        );
                      } else {
                        // Non-medical offer - download PDF
                        if (offer.memberClaimDocument != null && offer.memberClaimDocument!.isNotEmpty) {
                          final fileName = 'Offer_${offer.organisationOfferDiscountId}.pdf';
                          _downloadFile(offer.memberClaimDocument, fileName);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('PDF not available for this offer')),
                          );
                        }
                      }
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  (offer.orgLogo != null && offer.orgLogo!.isNotEmpty)
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      offer.orgLogo!,
                                      width: 75,
                                      height: 75,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => _buildDefaultLogo(),
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return SizedBox(
                                          width: 75,
                                          height: 75,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                      : _buildDefaultLogo(),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Container(width: 1, color: Colors.grey[400]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            offer.orgName ?? 'Unknown',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (offer.organisationSubcategoryId == 1 &&
                                              offer.medicines != null &&
                                              offer.medicines!.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              'Medicines:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '• ${offer.medicines!.first.medicineName} '
                                                  '(Container Type: ${offer.medicines!.first.medicineContainerId}, '
                                                  'Qty: ${offer.medicines!.first.quantity})'
                                                  '${offer.medicines!.length > 1 ? ' ...' : ''}',
                                              style: const TextStyle(fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ] else if (offer.organisationSubcategoryId != 1 && offer.medicines != null &&
                                          offer.medicines!.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              '• ${offer.medicines!.first.medicineName} '
                                                  '(Container Type: ${offer.medicines!.first.medicineContainerId}, '
                                                  'Qty: ${offer.medicines!.first.quantity})'
                                                  '${offer.medicines!.length > 1 ? ' ...' : ''}',
                                              style: const TextStyle(fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 4),
                                            if (offer.memberClaimDocument != null && offer.memberClaimDocument!.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Click to Download the Pdf',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                          const SizedBox(height: 8),
                                          Text(
                                            'Claimed on: ${_formatDate(offer.createdAt)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (offer.organisationSubcategoryName != null &&
                                        offer.organisationSubcategoryName!.isNotEmpty)
                                      Positioned(
                                        top: 4,
                                        right: 0,
                                        child: _buildTag(
                                          offer.organisationSubcategoryName!,
                                          ColorHelperClass.getColorFromHex(ColorResources.red_color),
                                          textColor: Colors.white,
                                          fontSize: 10,
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}