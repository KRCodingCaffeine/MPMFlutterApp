import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart' as pw;
import 'package:flutter/cupertino.dart' show Page, TextStyle;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/model/GetOfferClaimedByOfferId/getOfferClaimedByOfferIdData.dart';
import 'package:mpm/repository/get_offer_claimed_by_offfer_id_repository/get_offer_claimed_by_offer_id_repo.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:open_filex/open_filex.dart';
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
import 'package:path/path.dart' as p;

class DiscountOfferDetailPage extends StatefulWidget {
  final OfferData offer;

  const DiscountOfferDetailPage({super.key, required this.offer});

  @override
  State<DiscountOfferDetailPage> createState() =>
      _DiscountOfferDetailPageState();
}

class _DiscountOfferDetailPageState extends State<DiscountOfferDetailPage> {
  final Dio _dio = Dio();
  final MemberClaimOfferRepository _memberClaimOfferRepo =
      MemberClaimOfferRepository();
  bool _isDownloading = false;
  double _downloadProgress = 0;

  // ==================== REORDER STATE ====================
  final UdateProfileController _profileController =
      Get.isRegistered<UdateProfileController>()
          ? Get.find<UdateProfileController>()
          : Get.put(UdateProfileController());

  final ImagePicker _reorderPicker = ImagePicker();
  XFile? _reorderSelectedImage;
  List<Medicine> _reorderMedicines = [];
  StateSetter? _reorderSheetSetState;
  final AddOfferDiscountRepository _reorderRepository =
      AddOfferDiscountRepository();

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
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              widget.offer.offerDiscountName ?? 'Offer Details',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.offer.offerImage != null &&
                widget.offer.offerImage!.isNotEmpty) ...[
              Center(
                child: _buildFilePreviewOrButton(context),
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
              widget.offer.offerDescription ?? 'No Offer detail available',
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildValidityInfo(),
            if (widget.offer.orgMobile != null ||
                widget.offer.orgEmail != null) ...[
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
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 👇 REORDER BUTTON (only if offer is a medical offer - subcategoryId 1)
              if (widget.offer.orgSubcategoryId?.toString() == '1') ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _handleReorder,
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'Reorder',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.logo_color),
                      side: BorderSide(
                        color: ColorHelperClass.getColorFromHex(
                            ColorResources.logo_color),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // 👇 CLAIM OFFER BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorHelperClass.getColorFromHex(
                        ColorResources.red_color),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _handleClaimOffer(),
                  child: const Text(
                    "Claim Offer",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreviewOrButton(BuildContext context) {
    final String url = widget.offer.offerImage!;
    final String fileExtension = url.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              backgroundColor: Colors.black,
              insetPadding: const EdgeInsets.all(10),
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.white)),
                ),
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: 500,
              maxWidth: 400,
            ),
            child: FutureBuilder<Size>(
              future: _getImageSize(url),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const SizedBox.shrink();
                } else {
                  final imageSize = snapshot.data!;
                  final isLandscape = imageSize.width > imageSize.height;

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      fit: isLandscape ? BoxFit.fitWidth : BoxFit.cover,
                      width: double.infinity,
                      height: isLandscape ? 250 : null,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 80),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );
    } else if (['pdf', 'docx', 'doc'].contains(fileExtension)) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          icon: Icon(
            fileExtension == 'pdf' ? Icons.picture_as_pdf : Icons.description,
            color: fileExtension == 'pdf' ? Colors.red : Colors.blue,
          ),
          label: _isDownloading
              ? Expanded(
                  child: LinearProgressIndicator(
                    value: _downloadProgress / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                    ),
                  ),
                )
              : Text("Download & View ${fileExtension.toUpperCase()}"),
          onPressed: _isDownloading
              ? null
              : () => _downloadFile(url, "Offer_Document.$fileExtension"),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<Size> _getImageSize(String imageUrl) async {
    final Completer<Size> completer = Completer();

    // 👇 Fallback if image fails to load — prevents infinite hang
    final fallback = const Size(400, 300);

    try {
      final Image image = Image.network(imageUrl);

      image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener(
              (ImageInfo info, bool _) {
            if (!completer.isCompleted) {
              completer.complete(Size(
                info.image.width.toDouble(),
                info.image.height.toDouble(),
              ));
            }
          },
          onError: (exception, stackTrace) {
            // 👇 Complete with fallback on error
            debugPrint("Image size fetch failed for $imageUrl: $exception");
            if (!completer.isCompleted) {
              completer.complete(fallback);
            }
          },
        ),
      );
    } catch (e) {
      debugPrint("Image size fetch exception: $e");
      if (!completer.isCompleted) {
        completer.complete(fallback);
      }
    }

    // 👇 Safety timeout — never wait more than 5 seconds
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        if (!completer.isCompleted) {
          completer.complete(fallback);
        }
        return fallback;
      },
    );
  }

  Future<void> _handleClaimOffer() async {
    if (widget.offer.orgSubcategoryId?.toString() == '1') {
      Get.to(
        () => AvailOfferPage(
          orgDetailsID: widget.offer.orgDetailsID.toString(),
          organisationOfferDiscountId:
              widget.offer.organisationOfferDiscountId.toString(),
          orgSubcategoryId: widget.offer.orgSubcategoryId.toString(),
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
      // For non-medical offers, show confirmation dialog
      final confirmed = await _showConfirmationDialog();
      if (confirmed == true) {
        await _claimNonMedicalOffer();
      }
    }
  }

  Future<bool?> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Avail Offer",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to avail this offer?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _claimNonMedicalOffer() async {
    try {
      final repository = AddOfferDiscountRepository();
      final userData = await SessionManager.getSession();
      final memberClaimOfferId = userData?.memberId.toString() ?? '0';

      String applicantName = '';
      final subcategoryId = int.parse(widget.offer.orgSubcategoryId.toString());

      if (subcategoryId == 2) {
        applicantName = "Pathological Tests at Concessional Charges";
      } else if (subcategoryId == 3) {
        applicantName = "Hospital Services at Concessional Charges";
      } else {
        applicantName = "Concessional Services";
      }

      final medicine = Medicine(
        organisationOfferDiscountId:
            int.parse(widget.offer.organisationOfferDiscountId.toString()),
        orgDetailsID: int.parse(widget.offer.orgDetailsID.toString()),
        medicineName: applicantName,
        medicineContainerId: null,
        medicineContainerName: null,
        quantity: null,
      );

      final offerData = AddOfferDiscountData(
        memberId: int.parse(userData?.memberId.toString() ?? '0'),
        orgSubcategoryId: int.parse(widget.offer.orgSubcategoryId.toString()),
        orgDetailsID: int.parse(widget.offer.orgDetailsID.toString()),
        organisationOfferDiscountId:
            int.parse(widget.offer.organisationOfferDiscountId.toString()),
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
        final memberClaimOfferId =
            response['data']['member_claim_offer_id'].toString();

        final claimedOffer = await _memberClaimOfferRepo
            .fetchClaimedOfferByOfferId(memberClaimOfferId);

        if (claimedOffer.memberClaimDocument != null &&
            claimedOffer.memberClaimDocument!.isNotEmpty) {
          final fileName = 'Claimed_Offer_${memberClaimOfferId}.pdf';
          await _downloadFile(claimedOffer.memberClaimDocument, fileName);
        } else {
          Get.snackbar(
            "Success",
            "Offer claimed successfully! Member Claim ID: $memberClaimOfferId",
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
    if (url == null || fileName == null) return;

    final permissionStatus = await _requestPermission();
    if (!permissionStatus) return;

    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0;
      });

      Directory? directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      String filePath = "${directory!.path}/$fileName";

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            setState(() {
              _downloadProgress = (received / total) * 100;
            });
          }
        },
      );

      setState(() {
        _isDownloading = false;
        _downloadProgress = 0;
      });

      await OpenFilex.open(filePath);
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0;
      });
      Get.snackbar("Error", "Download failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
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
          const SnackBar(
              content:
                  Text('Storage permission is needed to download the file.')),
        );
        return false;
      } else {
        // Android 10 or below
        var status = await Permission.storage.request();
        if (status.isGranted) return true;

        ScaffoldMessenger.of(context as pw.BuildContext).showSnackBar(
          const SnackBar(
              content:
                  Text('Storage permission is needed to download the file.')),
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
                foregroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
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
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
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
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
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
              child: widget.offer.offerImage != null &&
                      widget.offer.offerImage!.isNotEmpty
                  ? Image.network(
                      widget.offer.offerImage!,
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

  // ==================== REORDER FLOW ====================

  /// Loads the latest claimed offer for this offer and opens the reorder sheet
  Future<void> _handleReorder() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final userData = await SessionManager.getSession();
      final memberId = userData?.memberId.toString() ?? '0';

      if (memberId == '0') {
        Get.back();
        Get.snackbar(
          "Error",
          "Member session not found",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final claimedOffer = await _memberClaimOfferRepo
          .fetchClaimedOfferByOfferId(
          widget.offer.organisationOfferDiscountId.toString());

      Get.back();

      if (claimedOffer == null ||
          claimedOffer.medicines == null ||
          claimedOffer.medicines!.isEmpty) {
        Get.snackbar(
          "No Previous Order",
          "You haven't ordered medicines for this offer yet.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // 👇 Safe int converter
      int? _toInt(dynamic v) {
        if (v == null) return null;
        if (v is int) return v;
        return int.tryParse(v.toString());
      }

      _reorderMedicines = claimedOffer.medicines!
          .map(
            (e) => Medicine(
          organisationOfferDiscountId: _toInt(
              claimedOffer.organisationOfferDiscountId) ??
              int.tryParse(
                  widget.offer.organisationOfferDiscountId.toString()),
          // 👇 Use the correct field name from GetofferclaimedbyofferidData
          //    Check your model — it might be `orgDetailsId` or `orgDetailsID`
          orgDetailsID: _toInt(claimedOffer.orgDetailsId) ??
              int.tryParse(widget.offer.orgDetailsID.toString()),
          medicineName: e.medicineName,
          medicineContainerId: _toInt(e.medicineContainerId),
          medicineContainerName: _getContainerName(e.medicineContainerId),
          quantity: _toInt(e.quantity),
        ),
      )
          .toList();

      _reorderSelectedImage = null;
      _showReorderBottomSheet(claimedOffer as GetofferclaimedbyofferidData);
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint("Reorder Fetch Error: $e");
      Get.snackbar(
        "Error",
        "Unable to load previous order: ${e.toString().replaceAll('Exception:', '').trim()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Show the reorder bottom sheet pre-filled with previous medicines
  void _showReorderBottomSheet(GetofferclaimedbyofferidData claimedOffer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[100],
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            _reorderSheetSetState = setBottomSheetState;

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              minChildSize: 0.65,
              maxChildSize: 0.65,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildReorderHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              _buildReorderPrescription(claimedOffer),
                              _buildReorderMedicineList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      _reorderSheetSetState = null;
    });
  }

  void _updateReorderSheet(VoidCallback update) {
    if (!mounted) return;
    setState(update);
    _reorderSheetSetState?.call(() {});
  }

  Widget _buildReorderHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Reorder Medicines",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text("Cancel"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorHelperClass.getColorFromHex(
                      ColorResources.red_color,
                    ),
                    side: BorderSide(
                      color: ColorHelperClass.getColorFromHex(
                        ColorResources.red_color,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submitReorder,
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: const Text("Confirm"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorHelperClass.getColorFromHex(
                      ColorResources.red_color,
                    ),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReorderPrescription(GetofferclaimedbyofferidData claimedOffer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Prescription",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _reorderSelectedImage != null
                ? Image.file(
              File(_reorderSelectedImage!.path),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : (claimedOffer.medicinePrescriptionDocument != null &&
                claimedOffer.medicinePrescriptionDocument!.isNotEmpty)
                ? Image.network(
              claimedOffer.medicinePrescriptionDocument!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text("No Prescription Uploaded"),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showReorderImagePickerOptions,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload New Prescription"),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorHelperClass.getColorFromHex(
                  ColorResources.red_color,
                ),
                side: BorderSide(
                  color: ColorHelperClass.getColorFromHex(
                    ColorResources.red_color,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildReorderMedicineList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Medicines",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showReorderAddMedicineDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Add Medicine"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorHelperClass.getColorFromHex(
                    ColorResources.red_color,
                  ),
                  side: BorderSide(
                    color: ColorHelperClass.getColorFromHex(
                      ColorResources.red_color,
                    ),
                  ),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          if (_reorderMedicines.isEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                "No medicines added",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reorderMedicines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final medicine = _reorderMedicines[index];

              return Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.red.shade50,
                        child: Icon(
                          Icons.medication,
                          color: ColorHelperClass.getColorFromHex(
                            ColorResources.red_color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicine.medicineName ?? "--",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Qty : ${medicine.quantity} ${_getContainerName(medicine.medicineContainerId)}",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        color: Colors.white,
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showReorderEditMedicineDialog(index);
                          } else if (value == 'remove') {
                            _showReorderRemoveMedicineDialog(index);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 10),
                                Text("Edit"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'remove',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 10),
                                Text("Remove",
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _submitReorder() async {
    try {
      if (_reorderMedicines.isEmpty) {
        await _showErrorDialog("Please add at least one medicine");
        return;
      }

      final imageFile = await _getReorderPrescriptionFile();

      final offerModel = AddOfferDiscountData(
        memberId: int.parse((await SessionManager.getSession())
            ?.memberId
            .toString() ??
            '0'),
        orgSubcategoryId: int.parse(widget.offer.orgSubcategoryId.toString()),
        orgDetailsID: int.parse(widget.offer.orgDetailsID.toString()),
        organisationOfferDiscountId:
        int.parse(widget.offer.organisationOfferDiscountId.toString()),
        createdBy: int.parse((await SessionManager.getSession())
            ?.memberId
            .toString() ??
            '0'),
        medicines: _reorderMedicines,
      );

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response =
      await _reorderRepository.submitOfferDiscount(offerModel, imageFile);

      Get.back(); // close loading

      if (response != null &&
          response is Map<String, dynamic> &&
          response['status'] == true) {
        Navigator.pop(context); // close bottom sheet

        final memberClaimOfferId =
        response['data']?['member_claim_offer_id']?.toString();

        if (memberClaimOfferId != null && memberClaimOfferId.isNotEmpty) {
          final claimedOffer = await _memberClaimOfferRepo
              .fetchClaimedOfferByOfferId(memberClaimOfferId);

          if (claimedOffer.memberClaimDocument != null &&
              claimedOffer.memberClaimDocument!.isNotEmpty) {
            final fileName = 'Claimed_Offer_$memberClaimOfferId.pdf';
            await _downloadFile(claimedOffer.memberClaimDocument, fileName);
          }
        }

        Get.snackbar(
          "Success",
          "Reorder placed successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.to(() => ClaimedOfferListPage());
      } else {
        await _showErrorDialog(
          response?['message'] ?? "Unable to place reorder",
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      await _showErrorDialog(
        e.toString().replaceAll("Exception:", "").trim(),
      );
    }
  }

  Future<File?> _getReorderPrescriptionFile() async {
    if (_reorderSelectedImage != null) {
      final imageFile = File(_reorderSelectedImage!.path);
      if (!imageFile.existsSync()) {
        throw Exception("Selected image not found");
      }
      return imageFile;
    }
    return null; // Let the API handle existing prescription
  }

  String _getContainerName(dynamic id) {
    switch (id.toString()) {
      case '1':
        return 'Strip';
      case '2':
        return 'Tube';
      case '3':
        return 'Bottle';
      case '4':
        return 'Box';
      case '5':
        return 'Pouch';
      default:
        return 'Unknown';
    }
  }

  String _getContainerIdFromName(String name) {
    switch (name) {
      case 'Strip':
        return '1';
      case 'Tube':
        return '2';
      case 'Bottle':
        return '3';
      case 'Box':
        return '4';
      case 'Pouch':
        return '5';
      default:
        return '0';
    }
  }

  void _showReorderImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewPadding.bottom + 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Select Prescription",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE),
                  child: Icon(Icons.camera_alt, color: Colors.redAccent),
                ),
                title: const Text("Take a Picture"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickReorderImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFF3E0),
                  child: Icon(Icons.photo_library, color: Colors.orange),
                ),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickReorderImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickReorderImage(ImageSource source) async {
    final picked = await _reorderPicker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (picked == null || !mounted) return;

    _updateReorderSheet(() {
      _reorderSelectedImage = picked;
    });
  }

  void _showReorderAddMedicineDialog() {
    final TextEditingController medicineController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    String? selectedContainer;

    final containerOptions = ['Strip', 'Tube', 'Bottle', 'Box', 'Pouch'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Add Medicine",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Divider(),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: medicineController,
                  decoration: InputDecoration(
                    labelText: "Medicine Name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedContainer,
                  decoration: InputDecoration(
                    labelText: "Pack Type",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: containerOptions
                      .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedContainer = v),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Quantity",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorHelperClass.getColorFromHex(
                  ColorResources.red_color,
                ),
                side: BorderSide(
                  color: ColorHelperClass.getColorFromHex(
                    ColorResources.red_color,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text.trim());
                if (medicineController.text.trim().isEmpty ||
                    quantity == null ||
                    quantity <= 0 ||
                    selectedContainer == null) {
                  Get.snackbar("Error", "Please fill all fields",
                      backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }

                _updateReorderSheet(() {
                  _reorderMedicines.add(
                    Medicine(
                      organisationOfferDiscountId: int.parse(
                          widget.offer.organisationOfferDiscountId.toString()),
                      orgDetailsID:
                      int.parse(widget.offer.orgDetailsID.toString()),
                      medicineName: medicineController.text.trim(),
                      medicineContainerId:
                      int.parse(_getContainerIdFromName(selectedContainer!)),
                      medicineContainerName: selectedContainer,
                      quantity: quantity,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(
                  ColorResources.red_color,
                ),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  void _showReorderEditMedicineDialog(int index) {
    final medicine = _reorderMedicines[index];
    final medicineController =
    TextEditingController(text: medicine.medicineName ?? "");
    final quantityController =
    TextEditingController(text: medicine.quantity?.toString() ?? "");
    String? selectedContainer =
    _getContainerName(medicine.medicineContainerId);

    final containerOptions = ['Strip', 'Tube', 'Bottle', 'Box', 'Pouch'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Edit Medicine",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Divider(),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: medicineController,
                  decoration: InputDecoration(
                    labelText: "Medicine Name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedContainer,
                  decoration: InputDecoration(
                    labelText: "Pack Type",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: containerOptions
                      .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedContainer = v),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Quantity",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorHelperClass.getColorFromHex(
                  ColorResources.red_color,
                ),
                side: BorderSide(
                  color: ColorHelperClass.getColorFromHex(
                    ColorResources.red_color,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (medicineController.text.trim().isEmpty ||
                    quantityController.text.trim().isEmpty ||
                    selectedContainer == null) {
                  Get.snackbar("Error", "Please fill all fields",
                      backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }

                _updateReorderSheet(() {
                  _reorderMedicines[index] = Medicine(
                    organisationOfferDiscountId: int.parse(
                        widget.offer.organisationOfferDiscountId.toString()),
                    orgDetailsID:
                    int.parse(widget.offer.orgDetailsID.toString()),
                    medicineName: medicineController.text.trim(),
                    medicineContainerId:
                    int.parse(_getContainerIdFromName(selectedContainer!)),
                    medicineContainerName: selectedContainer,
                    quantity: int.parse(quantityController.text),
                  );
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(
                  ColorResources.red_color,
                ),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReorderRemoveMedicineDialog(int index) async {
    final medicine = _reorderMedicines[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Remove Medicine",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Divider(thickness: 1, color: Colors.grey),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
                fontSize: 16, color: Colors.black87, height: 1.4),
            children: [
              const TextSpan(text: "Are you sure you want to remove "),
              TextSpan(
                text: medicine.medicineName ?? "this medicine",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: "?"),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Remove"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _updateReorderSheet(() {
        _reorderMedicines.removeAt(index);
      });
    }
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
          child:
              widget.offer.orgLogo != null && widget.offer.orgLogo!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.offer.orgLogo!,
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
                widget.offer.orgName ?? 'Unknown Company',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (widget.offer.orgAddress != null)
                Text(
                  widget.offer.orgAddress!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              if (widget.offer.orgArea != null ||
                  widget.offer.orgCity != null) ...[
                const SizedBox(height: 4),
                Text(
                  [widget.offer.orgArea, widget.offer.orgCity]
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
    if (widget.offer.validFrom != null && widget.offer.validTo != null) {
      validityText =
          '${_formatDate(widget.offer.validFrom!)} - ${_formatDate(widget.offer.validTo!)}';
    } else if (widget.offer.validTo != null) {
      validityText = 'Valid until ${_formatDate(widget.offer.validTo!)}';
    } else if (widget.offer.validFrom != null) {
      validityText = 'Valid from ${_formatDate(widget.offer.validFrom!)}';
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
            _buildTableRow(
                'Person Name', widget.offer.offerContactPersonName ?? '--'),
            _buildSpacerRow(),
            _buildTableRow('Person Mobile Number',
                widget.offer.offerContactPersonMobile ?? '--'),
            _buildSpacerRow(),
            _buildTableRow('Mobile Number', widget.offer.orgMobile ?? '--'),
            _buildSpacerRow(),
            _buildTableRow('Email', widget.offer.orgEmail ?? '--'),
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
