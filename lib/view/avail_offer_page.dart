import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mpm/model/AddOfferDiscountData/AddOfferDiscountData.dart';
import 'package:mpm/repository/add_offer_discount_repository/add_offer_discount_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class AvailOfferPage extends StatefulWidget {
  const AvailOfferPage({super.key});

  @override
  State<AvailOfferPage> createState() => _AvailOfferPageState();
}

class _AvailOfferPageState extends State<AvailOfferPage> {
  final List<Map<String, dynamic>> offerList = [];
  XFile? selectedImage;

  final String memberId = '123';
  final String orgSubcategoryId = "456";
  final String createdBy = "789";
  String orgDetailsID = '1';

  final AddOfferDiscountRepository _repository = AddOfferDiscountRepository();

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
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    setState(() {
                      orgDetailsID = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Applicant Name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> submitOffer() async {
    try {
      // Prepare model data
      final offerModel = AddOfferDiscountData(
        memberId: int.tryParse(memberId),
        orgSubcategoryId: int.tryParse(orgSubcategoryId),
        orgDetailsID: int.tryParse(orgDetailsID),
        createdBy: int.tryParse(createdBy),
        medicines: offerList
            .map((e) => Medicine(
                  medicineName: e['medicine_name'],
                  medicineContainerId: int.tryParse(e['medicine_container_id']),
                  quantity: e['quantity'],
                ))
            .toList(),
        prescriptionImage: null,
      );

      final response = await _repository.submitOfferDiscount(
        offerModel,
        selectedImage != null ? File(selectedImage!.path) : null,
      );

      if (response['status'] == true) {
        Get.snackbar(
          "",
          "",
          messageText: const Text(
            "Offer Claimed and Order Placed successfully.",
            style: TextStyle(color: Colors.green, fontSize: 14),
          ),
          backgroundColor: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
        );

        setState(() {
          offerList.clear();
          selectedImage = null;
        });
      } else {
        Get.snackbar(
          "",
          "",
          messageText: Text(
            response['message'] ?? "Something went wrong",
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
          backgroundColor: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
        );
      }
    } catch (e) {
      Get.snackbar(
        "",
        "",
        messageText: Text(
          "Something went wrong: $e",
          style: const TextStyle(color: Colors.red, fontSize: 14),
        ),
        backgroundColor: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
    }
  }

  Widget _buildUploadSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Ensures left alignment
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
                onPressed: offerList.isNotEmpty ? submitOffer : null,
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
