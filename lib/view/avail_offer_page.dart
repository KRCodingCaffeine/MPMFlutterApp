import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/model/AddOfferDiscountData/AddOfferDiscountData.dart';
import 'package:mpm/repository/add_offer_discount_repository/add_offer_discount_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/offer_claimed_view.dart';

class AvailOfferPage extends StatefulWidget {
  final String organisationOfferDiscountId;
  final String orgSubcategoryId;
  final String orgDetailsID;

  const AvailOfferPage({
    super.key,
    required this.organisationOfferDiscountId,
    required this.orgSubcategoryId,
    required this.orgDetailsID,
  });

  @override
  State<AvailOfferPage> createState() => _AvailOfferPageState();
}

class _AvailOfferPageState extends State<AvailOfferPage> {
  final List<Map<String, dynamic>> offerList = [];
  XFile? selectedImage;
  String? memberId;
  bool isLoading = true;

  final AddOfferDiscountRepository _repository = AddOfferDiscountRepository();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await SessionManager.getSession();
      setState(() {
        memberId = userData?.memberId.toString();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        "Error",
        "Failed to load user data",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String get orgSubcategoryId => widget.orgSubcategoryId;
  String get organisationOfferDiscountId => widget.organisationOfferDiscountId;
  String get orgDetailsID => widget.orgDetailsID;
  String get createdBy => memberId ?? '';

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  void showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text('Take a Picture'),
              onTap: () {
                Navigator.of(context).pop();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.redAccent),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  String getContainerId(String name) {
    switch (name) {
      case 'Strips':
        return '1';
      case 'Box':
        return '2';
      case 'Bottle':
        return '3';
      default:
        return '0';
    }
  }

  void _showInputDialog() {
    String medicineName = '';
    String? selectedContainer;
    String offerQuantity = '';
    final List<String> containerOptions = ['Strips', 'Box', 'Bottle'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Enter Medicine Name'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => medicineName = value,
                  decoration: InputDecoration(
                    labelText: 'Medicine Name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Container Type',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: selectedContainer,
                  items: containerOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedContainer = value;
                  },
                  dropdownColor: Colors.white,
                ),
                const SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    offerQuantity = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
              onPressed: () {
                if (medicineName.trim().isNotEmpty &&
                    selectedContainer != null &&
                    offerQuantity.trim().isNotEmpty) {
                  setState(() {
                    offerList.add({
                      'medicine_name': medicineName.trim(),
                      'medicine_container_id':
                          getContainerId(selectedContainer!).toString(),
                      'medicine_container_name': selectedContainer,
                      'quantity': int.tryParse(offerQuantity.trim()) ?? 0,
                    });
                  });
                  Navigator.of(context).pop();
                } else {
                  Get.snackbar(
                    "Error",
                    "Please fill all fields",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitOffer() async {
    if (memberId == null || memberId!.isEmpty) {
      await _showErrorDialog("User session not available");
      return;
    }

    if (offerList.isEmpty) {
      await _showErrorDialog("Please add at least one medicine");
      return;
    }

    try {
      // Verify image file exists if selected
      File? imageFile;
      if (selectedImage != null) {
        imageFile = File(selectedImage!.path);
        if (!imageFile.existsSync()) {
          await _showErrorDialog("Selected image file not found");
          return;
        }
      }

      // Prepare medicines list
      final medicines = offerList.map((e) => Medicine(
        organisationOfferDiscountId: int.tryParse(organisationOfferDiscountId) ?? 0,
        orgDetailsID: int.tryParse(orgDetailsID) ?? 0,
        medicineName: e['medicine_name']?.toString() ?? '',
        medicineContainerId: int.tryParse(e['medicine_container_id']?.toString() ?? '0') ?? 0,
        medicineContainerName: e['medicine_container_name']?.toString(),
        quantity: (e['quantity'] as int?) ?? 1,
      )).toList();

      // Prepare offer model
      final offerModel = AddOfferDiscountData(
        memberId: int.tryParse(memberId!) ?? 0,
        orgSubcategoryId: int.tryParse(orgSubcategoryId) ?? 0,
        orgDetailsID: int.tryParse(orgDetailsID) ?? 0,
        organisationOfferDiscountId: int.tryParse(organisationOfferDiscountId) ?? 0,
        createdBy: int.tryParse(memberId!) ?? 0,
        medicines: medicines,
      );

      // Debug print the data being sent
      debugPrint('Submitting offer with data: ${offerModel.toJson()}');
      if (imageFile != null) {
        debugPrint('Image file path: ${imageFile.path}');
        debugPrint('Image file exists: ${imageFile.existsSync()}');
      }

      // Submit the offer
      final response = await _repository.submitOfferDiscount(offerModel, imageFile);

      // Handle response
      if (response != null && response is Map<String, dynamic>) {
        if (response['status'] == true) {
          final success = await _showSuccessDialog(
            "Offer claimed successfully!",
            response['data'] ?? {},
          );

          if (success == true) {
            setState(() {
              offerList.clear();
              selectedImage = null;
            });
            if (mounted) {
              Navigator.pop(context, {
                'success': true,
                'message': 'Offer claimed successfully',
                'org_details_id': orgDetailsID,
              });
            }
          }
        } else {
          await _showErrorDialog(
            response['message']?.toString() ?? "Failed to submit offer",
          );
        }
      } else {
        await _showErrorDialog("Invalid response from server");
      }
    } catch (e) {
      debugPrint('Error submitting offer: $e');
      await _showErrorDialog(
        "Error: ${e.toString().replaceAll('Exception:', '').trim()}",
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
                foregroundColor: Colors.redAccent,
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
                backgroundColor: Colors.redAccent,
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

  Widget _buildUploadSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedImage != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Prescription',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(selectedImage!.path),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => showImagePickerOptions(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ] else ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => showImagePickerOptions(context),
              child: const Text(
                "Add Prescription",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (memberId == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor:
              ColorHelperClass.getColorFromHex(ColorResources.logo_color),
          title: const Text("Medicine Details",
              style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text("Failed to load user data. Please try again."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text("Medicine Details",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUploadSection(),
          const SizedBox(height: 16),
          if (selectedImage != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Medicine List',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: _showInputDialog,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    backgroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  child: const Text("Add Medicine"),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (offerList.isNotEmpty)
            ...offerList.asMap().entries.map((entry) {
              final index = entry.key;
              final offer = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. Medicine Name: ${offer['medicine_name']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '     Container Type Name: ${offer['medicine_container_name']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '     Quantity: ${offer['quantity'].toString()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                    height: 20,
                  ),
                ],
              );
            }),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: selectedImage != null
          ? Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: offerList.isNotEmpty
                    ? () {
                        _submitOffer();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white.withOpacity(0.6),
                  disabledBackgroundColor: Colors.redAccent.withOpacity(0.6),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Place Order",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          : null,
    );
  }
}
