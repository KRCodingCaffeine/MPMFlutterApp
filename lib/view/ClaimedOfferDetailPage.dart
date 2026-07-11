import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/AddOfferDiscountData/AddOfferDiscountData.dart';
import 'package:mpm/model/GetClaimedOfferByID/GetClaimedOfferData.dart';
import 'package:mpm/repository/add_offer_discount_repository/add_offer_discount_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/offer_claimed_view.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class ClaimedOfferDetailPage extends StatefulWidget {
  final GetClaimedOfferData offer;

  ClaimedOfferDetailPage({required this.offer});

  @override
  State<ClaimedOfferDetailPage> createState() => _ClaimedOfferDetailPageState();
}

class _ClaimedOfferDetailPageState extends State<ClaimedOfferDetailPage> {
  final UdateProfileController _profileController =
      Get.isRegistered<UdateProfileController>()
          ? Get.find<UdateProfileController>()
          : Get.put(UdateProfileController());
  XFile? selectedImage;
  final ImagePicker _picker = ImagePicker();
  final AddOfferDiscountRepository _repository = AddOfferDiscountRepository();
  List<Medicine> editableMedicines = [];
  StateSetter? _reorderSheetSetState;

  late final Future<void> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileIfNeeded();

    editableMedicines = widget.offer.medicines
        ?.map(
          (e) => Medicine(
            organisationOfferDiscountId:
                widget.offer.organisationOfferDiscountId,
            orgDetailsID: widget.offer.orgDetailsId,
            medicineName: e.medicineName,
            medicineContainerId: e.medicineContainerId,
            medicineContainerName: getContainerName(e.medicineContainerId),
            quantity: e.quantity,
          ),
        )
        .toList() ??
        [];
  }

  Future<void> _submitReorder() async {
    try {
      if (editableMedicines.isEmpty) {
        await _showErrorDialog("Please add at least one medicine");
        return;
      }

      File? imageFile;

      if (selectedImage != null) {
        imageFile = File(selectedImage!.path);

        if (!imageFile.existsSync()) {
          await _showErrorDialog("Selected image not found");
          return;
        }
      }

      final offerModel = AddOfferDiscountData(
        memberId: widget.offer.memberId,
        orgSubcategoryId: widget.offer.organisationSubcategoryId,
        orgDetailsID: widget.offer.orgDetailsId,
        organisationOfferDiscountId:
            widget.offer.organisationOfferDiscountId,
        createdBy: widget.offer.memberId,
        medicines: editableMedicines,
      );

      debugPrint("Reorder Request : ${offerModel.toJson()}");

      final response = await _repository.submitOfferDiscount(
        offerModel,
        imageFile,
      );

      if (response != null && response is Map<String, dynamic>) {
        if (response['status'] == true) {
          Navigator.pop(context); // BottomSheet

          final success = await _showSuccessDialog(
            "Order placed successfully!",
            response['data'] ?? {},
          );

          if (success == true && mounted) {
            Navigator.pop(context, true);
          }
        } else {
          await _showErrorDialog(
            response['message'] ?? "Unable to place order",
          );
        }
      } else {
        await _showErrorDialog(
          "Invalid response from server",
        );
      }
    } catch (e) {
      debugPrint(e.toString());

      await _showErrorDialog(
        e.toString().replaceAll(
          "Exception:",
          "",
        ),
      );
    }
  }

  Future<bool?> _showSuccessDialog(String message, dynamic responseData) async {
    return await showDialog<bool>(
      context: context,
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
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
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
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Close the dialog first
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClaimedOfferListPage(),
                    ),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
              ),
              child: const Text("View Details", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
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
                backgroundColor: Colors.red,
              ),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }


  String getContainerName(dynamic id) {
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

  Future<void> _loadProfileIfNeeded() async {
    if (_profileController.getUserData.value.address != null) {
      return;
    }

    await _profileController.getUserProfile();
  }

  String _buildMemberAddress() {
    final address = _profileController.getUserData.value.address;

    final lines = <String>[
      _joinParts([
        address?.flatNo?.toString(),
        address?.buildingName?.toString(),
      ]),
      _joinParts([
        address?.address?.toString(),
        address?.areaName?.toString(),
      ]),
      _joinParts([
        address?.cityName?.toString(),
        address?.stateName?.toString(),
        address?.pincode?.toString(),
      ]),
    ].where((line) => line.isNotEmpty).toList();

    if (lines.isEmpty) {
      return '--';
    }

    return lines.join(', \n');
  }

  String _joinParts(List<String?> parts) {
    return parts
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .join(', ');
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
              widget.offer.orgName ?? 'Offer Details',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prescription Document
            if (widget.offer.medicinePrescriptionDocument != null &&
                widget.offer.medicinePrescriptionDocument!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prescription:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.offer.medicinePrescriptionDocument!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Text('Image not available'),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes!)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Medicines List
            if (widget.offer.medicines != null &&
                widget.offer.medicines!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medicines:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  ...widget.offer.medicines!.map((medicine) => Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '• ${medicine.medicineName} (${medicine.quantity} ${getContainerName(medicine.medicineContainerId)})',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ))
                ],
              ),
            const SizedBox(height: 20),

            Text(
              'Ordered on: ${_formatDate(widget.offer.createdAt)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 16),

            const Text(
              'Address:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            FutureBuilder<void>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(left: 12.0, top: 8),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    _buildMemberAddress(),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 16),

            const Text(
              'Contact Info:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                _buildTableRow('Email', widget.offer.orgEmail ?? '--'),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                _showReorderBottomSheet();
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Reorder',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.logo_color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showReorderBottomSheet() {
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
                      // Fixed Header
                      _buildHeader(),

                      // Scrollable Body
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              _buildPrescription(),
                              _buildMedicineList(),
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

  void _updatePageAndReorderSheet(VoidCallback update) {
    if (!mounted) return;

    setState(update);
    _reorderSheetSetState?.call(() {});
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
                  onPressed: () async {
                    await _submitReorder();
                  },
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

  Widget _buildPrescription() {
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
            child: selectedImage != null
                ? Image.file(
                    File(selectedImage!.path),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : widget.offer.medicinePrescriptionDocument != null &&
                        widget.offer.medicinePrescriptionDocument!.isNotEmpty
                    ? Image.network(
                        widget.offer.medicinePrescriptionDocument!,
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
              onPressed: () async {
                showImagePickerOptions();
              },
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
          Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildMedicineList() {
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showAddMedicineDialog,
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
          if (editableMedicines.isEmpty) ...[
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
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: editableMedicines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final medicine = editableMedicines[index];

              return Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              "Qty : ${medicine.quantity} ${getContainerName(medicine.medicineContainerId)}",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          _showEditMedicineDialog(index);
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 16,
                        ),
                        label: const Text("Edit"),
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

  String getContainerId(String name) {
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

  void _showAddMedicineDialog() {
    final TextEditingController medicineController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    String? selectedContainer;

    final List<String> containerOptions = [
      'Strip',
      'Tube',
      'Bottle',
      'Box',
      'Pouch'
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Add Medicine",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedContainer,
                      decoration: InputDecoration(
                        labelText: "Pack Type",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: containerOptions.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedContainer = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Quantity",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
                    final quantity =
                        int.tryParse(quantityController.text.trim());

                    if (medicineController.text.trim().isEmpty ||
                        quantity == null ||
                        quantity <= 0 ||
                        selectedContainer == null) {
                      Get.snackbar(
                        "Error",
                        "Please fill all fields",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    _updatePageAndReorderSheet(() {
                      editableMedicines.add(
                        Medicine(
                          organisationOfferDiscountId:
                              widget.offer.organisationOfferDiscountId,
                          orgDetailsID: widget.offer.orgDetailsId,
                          medicineName: medicineController.text.trim(),
                          medicineContainerId: int.parse(
                            getContainerId(selectedContainer!),
                          ),
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
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditMedicineDialog(int index) {
    final medicine = editableMedicines[index];

    final TextEditingController medicineController =
        TextEditingController(text: medicine.medicineName ?? "");

    final TextEditingController quantityController =
        TextEditingController(text: medicine.quantity?.toString() ?? "");

    String? selectedContainer = getContainerName(medicine.medicineContainerId);

    final List<String> containerOptions = [
      'Strip',
      'Tube',
      'Bottle',
      'Box',
      'Pouch'
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Edit Medicine",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedContainer,
                      decoration: InputDecoration(
                        labelText: "Pack Type",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: containerOptions.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedContainer = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Quantity",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
                      Get.snackbar(
                        "Error",
                        "Please fill all fields",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    _updatePageAndReorderSheet(() {
                      editableMedicines[index] = Medicine(
                        organisationOfferDiscountId:
                            widget.offer.organisationOfferDiscountId,
                        orgDetailsID: widget.offer.orgDetailsId,
                        medicineName: medicineController.text.trim(),
                        medicineContainerId: int.parse(
                          getContainerId(selectedContainer!),
                        ),
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
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image == null) return;

    if (!mounted) return;

    _updatePageAndReorderSheet(() {
      selectedImage = image;
    });

    debugPrint("Selected Image : ${selectedImage?.path}");
  }

  void showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom + 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Title + Close Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Select Prescription",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                /// Camera
                ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFEBEE),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.redAccent,
                      ),
                    ),
                    title: const Text(
                      "Take a Picture",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text("Capture using camera"),
                    onTap: () async {
                      Navigator.pop(context);
                      await pickImage(ImageSource.camera);
                    }),

                /// Gallery
                ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFF3E0),
                      child: Icon(
                        Icons.photo_library,
                        color: Colors.orange,
                      ),
                    ),
                    title: const Text(
                      "Choose from Gallery",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text("Select an existing image"),
                    onTap: () async {
                      Navigator.pop(context);
                      await pickImage(ImageSource.gallery);
                    }),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
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

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, dd-MM-yy').format(date);
    } catch (e) {
      return '';
    }
  }
}
