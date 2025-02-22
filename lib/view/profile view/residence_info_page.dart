import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class ResidenceInformationPage extends StatefulWidget {
  const ResidenceInformationPage({Key? key}) : super(key: key);

  @override
  _ResidenceInformationPageState createState() =>
      _ResidenceInformationPageState();
}

class _ResidenceInformationPageState extends State<ResidenceInformationPage> {
  UdateProfileController controller = Get.put(UdateProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Residential Info', style: TextStyle(color: Colors.white),),
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditModalSheet(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoBox(
                    'Building Name:',
                    subtitle: controller.getUserData.value.address?.buildingNameId?.toString() ?? "N/A",
                  ),
                  const SizedBox(height: 20),
                  _buildInfoBox(
                    'Flat No:',
                    subtitle: controller.getUserData.value.address?.flatNo?.toString() ?? "N/A",
                  ),
                  const SizedBox(height: 20),
                  _buildInfoBox(
                    'Zone:',
                    subtitle: controller.getUserData.value.address?.zoneName?.toString() ?? "N/A",
                  ),
                  const SizedBox(height: 20),
                  _buildInfoBox(
                    'Area:',
                    subtitle: controller.getUserData.value.address?.areaName?.toString() ?? "N/A",
                  ),
                  const SizedBox(height: 20),
                  _buildInfoBox(
                    'State:',
                    subtitle: controller.getUserData.value.address?.stateName?.toString() ?? "N/A",
                  ),
                  const SizedBox(height: 20),
                  _buildInfoBox(
                    'City:',
                    subtitle: controller.getUserData.value.address?.cityName?.toString() ?? "N/A",
                  ),
                  const SizedBox(height: 20),
                  _buildInfoBox(
                    'Country:',
                    subtitle: controller.getUserData.value.address?.countryName?.toString() ?? "N/A",
                  ),
                  const SizedBox(height: 20),
                  _buildInfoBox(
                    'Pincode:',
                    subtitle: controller.getUserData.value.address?.pincode?.toString() ?? "N/A",
                  ),
                  const SizedBox(height: 20),
                  _buildInfoBox(
                    'Document Type:',
                    subtitle: controller.getUserData.value.addressProofTypeId?.toString() ?? "N/A",
                  ),
                  const SizedBox(height: 20),
                  _buildInfoBox(
                    'Document:',
                    subtitle: 'Document',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditModalSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: TextButton(
                      onPressed: () {
                        bool isValid = _validateFields();
                        if (isValid) {
                          controller.userUpdateProfile(context,controller.memberId.value);
                          Navigator.pop(context);
                          _showSuccessMessage();
                        } else {
                          _showFailureMessage();
                        }
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Color(0xFFDC3545),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildTextField(
                  label: "Building Name",
                  controller: controller.buildingController,
                ),
                const SizedBox(height: 10),
                // _buildTextField(
                //   label: "Flat No",
                //   controller: controller.flatNoController,
                // ),
                const SizedBox(height: 10),
                _buildTextField(
                  label: "Zone",
                  controller: controller.zoneController,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  label: "Area",
                  controller: controller.areaController,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  label: "State",
                  controller: controller.stateController,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  label: "City",
                  controller: controller.cityController,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  label: "Country",
                  controller: controller.countryController,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  label: "Pincode",
                  controller: controller.pincodeController,
                ),
                const SizedBox(height: 10),
                // _buildTextField(
                //   label: "Document Type",
                //   controller: controller.documentTypeController,
                // ),
                // const SizedBox(height: 10),
                // _buildTextField(
                //   label: "Document",
                //   controller: controller.documentController,
                // ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required Rx<TextEditingController> controller,
  }) {
    return TextField(
      controller: controller.value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  bool _validateFields() {
    return controller.pincodeController.value.text.isNotEmpty;
  }

  void _showSuccessMessage() {
    final snackBar = SnackBar(
      content: const Text('Residence Info updated successfully!'),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showFailureMessage() {
    final snackBar = SnackBar(
      content: const Text('Failed to update information. Please check fields.'),
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xFFDC3545),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildInfoBox(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 147,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const Text(
                  ':',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          Expanded(
            child: subtitle != null
                ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}