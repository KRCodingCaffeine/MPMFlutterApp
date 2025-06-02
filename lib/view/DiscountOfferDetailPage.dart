import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart' as pw;
import 'package:flutter/cupertino.dart' show Page, TextStyle;
import 'package:flutter/material.dart';
import 'package:mpm/repository/get_offer_claimed_by_offfer_id_repository/get_offer_claimed_by_offer_id_repo.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:mpm/model/AddOfferDiscountData/AddOfferDiscountData.dart';
import 'package:mpm/model/Offer/OfferData.dart';
import 'package:mpm/repository/add_offer_discount_repository/add_offer_discount_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:intl/intl.dart';
import 'package:mpm/view/avail_offer_page.dart';
import 'package:get/get.dart';
import 'package:mpm/view/offer_claimed_view.dart';
import 'package:permission_handler/permission_handler.dart';

class DiscountOfferDetailPage extends StatelessWidget {
  final OfferData offer;
  final Dio _dio = Dio();
  final MemberClaimOfferRepository _memberClaimOfferRepo = MemberClaimOfferRepository();

  DiscountOfferDetailPage({
    super.key,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    // Handle messages from navigation
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          args['success'] ? "Success" : "Error",
          args['message'],
          backgroundColor: args['success'] ? Colors.green : Colors.red,
          colorText: Colors.white,
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          offer.offerDiscountName ?? 'Offer Details',
          style: const TextStyle(color: Colors.white, fontSize: 24),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (offer.offerImage != null && offer.offerImage!.isNotEmpty) ...[
              Center(
                child: GestureDetector(
                  onTap: () => _showFullImage(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                        maxWidth: 400,
                      ),
                      child: Image.network(
                        offer.offerImage!,
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Offer Details:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              offer.offerDescription ?? 'No Offer detail available',
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildValidityInfo(),
            if (offer.orgMobile != null || offer.orgEmail != null) ...[
              const SizedBox(height: 24),
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 16),
              _buildCompanyInfo(),
              const SizedBox(height: 16),
              _buildContactInfo(),
            ],
            const SizedBox(height: 24),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _handleClaimOffer(),
            child: const Text("Claim Offer", style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Future<void> _handleClaimOffer() async {
    if (offer.orgSubcategoryId?.toString() == '1') {
      Get.to(
            () => AvailOfferPage(
          orgDetailsID: offer.orgDetailsID.toString(),
          organisationOfferDiscountId: offer.organisationOfferDiscountId.toString(),
          orgSubcategoryId: offer.orgSubcategoryId.toString(),
        ),
      )?.then((_) {
        if (Get.arguments != null) {
          final args = Get.arguments as Map<String, dynamic>;
          Get.snackbar(
            args['success'] ? "Success" : "Error",
            args['message'],
            backgroundColor: args['success'] ? Colors.green : Colors.red,
            colorText: Colors.white,
          );
        }
      });
    } else {
      await _claimNonMedicalOffer();
    }
  }

  Future<void> _claimNonMedicalOffer() async {
    try {
      final repository = AddOfferDiscountRepository();
      final userData = await SessionManager.getSession();
      final memberClaimOfferId = userData?.memberId.toString() ?? '0';

      String applicantName = '';
      final subcategoryId = int.parse(offer.orgSubcategoryId.toString());

      if (subcategoryId == 2) {
        applicantName = "Pathological Tests at Concessional Charges";
      } else if (subcategoryId == 3) {
        applicantName = "Hospital Services at Concessional Charges";
      } else {
        applicantName = "Concessional Services";
      }

      final medicine = Medicine(
        organisationOfferDiscountId: int.parse(offer.organisationOfferDiscountId.toString()),
        orgDetailsID: int.parse(offer.orgDetailsID.toString()),
        medicineName: applicantName,
        medicineContainerId: null,
        medicineContainerName: null,
        quantity: null,
      );

      final offerData = AddOfferDiscountData(
        memberId: int.parse(userData?.memberId.toString() ?? '0'),
        orgSubcategoryId: int.parse(offer.orgSubcategoryId.toString()),
        orgDetailsID: int.parse(offer.orgDetailsID.toString()),
        organisationOfferDiscountId: int.parse(offer.organisationOfferDiscountId.toString()),
        createdBy: int.parse(userData?.memberId.toString() ?? '0'),
        medicines: [medicine],
      );

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await repository.submitOfferDiscount(offerData, null);

      Get.back();

      if (response['status'] == true) {

        final claimedOffer = await _memberClaimOfferRepo.fetchClaimedOfferByOfferId(
          offer.organisationOfferDiscountId.toString(),
            memberClaimOfferId
        );

        if (claimedOffer.memberClaimDocument != null && claimedOffer.memberClaimDocument!.isNotEmpty) {
          final fileName = 'Offer_${offer.organisationOfferDiscountId}.pdf';
          await _downloadFile(claimedOffer.memberClaimDocument, fileName);
        } else {
          Get.snackbar(
            "Success",
            "Offer claimed successfully, but no document is available for download.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          response['message'] ?? 'Failed to claim offer',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        "Error",
        "Failed to claim offer: ${e.toString().replaceAll('Exception:', '').trim()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _downloadFile(String? url, String? fileName) async {
    if (url == null || fileName == null) {
      Get.snackbar(
        "Error",
        "Invalid file URL or file name",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final permissionStatus = await _requestPermission();
    if (!permissionStatus) return;

    try {
      Directory? directory = await getExternalStorageDirectory();
      String filePath = "${directory!.path}/$fileName";
      int progress = 0;

      final scaffoldMessenger = ScaffoldMessenger.of(Get.context!);
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

      await OpenFilex.open(filePath);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Download failed: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

        ScaffoldMessenger.of(context as pw.BuildContext).showSnackBar(
          const SnackBar(content: Text('Storage permission is needed to download the file.')),
        );
        return false;
      } else {
        // Android 10 or below
        var status = await Permission.storage.request();
        if (status.isGranted) return true;

        ScaffoldMessenger.of(context as pw.BuildContext).showSnackBar(
          const SnackBar(content: Text('Storage permission is needed to download the file.')),
        );
        return false;
      }
    }
    return true;
  }

  Future<bool?> _showSuccessDialog(String message, dynamic responseData) async {
    return await showDialog<bool>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text(
                "Success",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Done"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // Close the dialog
                Get.to(() => ClaimedOfferListPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
              ),
              child: const Text("View Details",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 32),
              SizedBox(width: 12),
              Text(
                "Error",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
              ),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Center(
              child: offer.offerImage != null && offer.offerImage!.isNotEmpty
                  ? Image.network(
                offer.offerImage!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/discounts.jpg',
                  fit: BoxFit.contain,
                ),
              )
                  : Image.asset(
                'assets/images/discounts.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: offer.orgLogo != null && offer.orgLogo!.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              offer.orgLogo!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildDefaultLogo(),
            ),
          )
              : _buildDefaultLogo(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.orgName ?? 'Unknown Company',
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (offer.orgAddress != null)
                Text(
                  offer.orgAddress!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              if (offer.orgArea != null || offer.orgCity != null) ...[
                const SizedBox(height: 4),
                Text(
                  [offer.orgArea, offer.orgCity]
                      .where((e) => e != null)
                      .join(', '),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValidityInfo() {
    String validityText;
    if (offer.validFrom != null && offer.validTo != null) {
      validityText =
      '${_formatDate(offer.validFrom!)} - ${_formatDate(offer.validTo!)}';
    } else if (offer.validTo != null) {
      validityText = 'Valid until ${_formatDate(offer.validTo!)}';
    } else if (offer.validFrom != null) {
      validityText = 'Valid from ${_formatDate(offer.validFrom!)}';
    } else {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Validity Period:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              validityText,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FixedColumnWidth(10),
            2: FlexColumnWidth(),
          },
          children: [
            _buildTableRow('Person Name', offer.offerContactPersonName ?? '--'),
            _buildSpacerRow(),

            _buildTableRow('Person Mobile Number', offer.offerContactPersonMobile ?? '--'),
            _buildSpacerRow(),

            _buildTableRow('Mobile Number', offer.orgMobile ?? '--'),
            _buildSpacerRow(),

            _buildTableRow('WhatsApp', offer.orgWhatsApp ?? '--'),
            _buildSpacerRow(),

            _buildTableRow('Email', offer.orgEmail ?? '--'),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
        const Center(child: Text(':')),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  TableRow _buildSpacerRow() {
    return const TableRow(
      children: [
        SizedBox(height: 8),
        SizedBox(),
        SizedBox(),
      ],
    );
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}