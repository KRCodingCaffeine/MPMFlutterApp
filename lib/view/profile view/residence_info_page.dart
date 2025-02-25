import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CountryModel/CountryData.dart';
import 'package:mpm/model/State/StateData.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class ResidenceInformationPage extends StatefulWidget {
  const ResidenceInformationPage({Key? key}) : super(key: key);

  @override
  _ResidenceInformationPageState createState() =>
      _ResidenceInformationPageState();
}

class _ResidenceInformationPageState extends State<ResidenceInformationPage> {
  File? _image; // Add this field to store the selected image
  UdateProfileController controller = Get.put(UdateProfileController());
  NewMemberController regiController =Get.put(NewMemberController());
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
                    'Address Proof:',
                    subtitle: controller.getUserData.value.address?.addressType?.toString() ?? "N/A",
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoBox(
                        'Document:',
                        subtitle: controller.getUserData.value.address?.addressType?.toString() ?? "N/A",
                      ),
                      const SizedBox(height: 10),
                      // **Show "View Image" button if an image is uploaded**
                      if (_image != null)
                        SizedBox(
                          width: double.infinity, // Full width button
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showImagePreviewDialog(context);
                            },
                            icon: const Icon(Icons.visibility),
                            label: const Text("View Image"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color), // Different color for better UI
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _image != null
                ? Image.file(_image!, fit: BoxFit.contain) // Display the image
                : const Padding(
              padding: EdgeInsets.all(20),
              child: Text("No image uploaded", textAlign: TextAlign.center),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditModalSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // Allow the bottom sheet to adjust for keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9, // Adjust height factor (0.9 means 90% of screen height)
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the modal sheet
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Color(0xFFDC3545),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            bool isValid = _validateFields();
                            if (isValid) {
                              controller.userUpdateProfile(context, controller.memberId.value);
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
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Pincode
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.phone,
                                controller: controller.pincodeController.value,
                                decoration: const InputDecoration(
                                  hintText: 'Pin Code *',
                                  border: InputBorder.none, // Remove the internal border
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 20), // Adjust padding
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  print("fghjjhjjh" + controller.pincodeController.value.text);
                                  if (controller.pincodeController.value.text != '') {
                                    var pincode = controller.pincodeController.value.text;
                                    controller.zoneController.value.text = "";
                                    regiController.getCheckPinCode(pincode);
                                  } else {
                                    Get.snackbar(
                                      "Error",
                                      "Select Pin Code",
                                      backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.TOP,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Building Name
                    _buildTextField(
                      label: "Building Name",
                      controller: regiController.buildingController,
                    ),
                    const SizedBox(height: 20),
                    // Flat No
                    _buildTextField(
                      label: "Flat No",
                      controller: controller.flatNoController,
                    ),
                    const SizedBox(height: 20),
                    // Zone
                    _buildTextField(
                      label: "Zone",
                      controller: regiController.zoneController,
                    ),
                    const SizedBox(height: 20),
                    // Area
                    _buildTextField(
                      label: "Area",
                      controller: regiController.areaController,
                    ),
                    const SizedBox(height: 20),
                    // City
                    Obx((){
                      return Visibility(
                          visible: regiController.countryNotFound.value,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),

                              // City
                              _buildTextField(label:
                              'City *',
                                  controller: regiController.cityController,

                                  readOnly: true
                              ),
                              const SizedBox(height: 20),

                              //State
                              SizedBox(
                                width: double.infinity,
                                child: _buildTextField(label:
                                'State *',
                                    controller: regiController.stateController,

                                    readOnly: true
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Country
                              SizedBox(
                                width: double.infinity,
                                child: _buildTextField(label:
                                'Country *',
                                    controller:  regiController.countryController,

                                    readOnly: true
                                ),
                              ),

                            ],
                          ));
                    }),
                    Obx((){
                      return Visibility(
                          visible: regiController.countryNotFound.value==false,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Container(
                                margin: const EdgeInsets.only(left: 5, right: 5),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    Obx(() {
                                      if (regiController.rxStatusCountryLoading.value ==
                                          Status.LOADING) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 22),
                                          child: Container(
                                              alignment: Alignment.centerRight,
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: ColorHelperClass
                                                    .getColorFromHex(
                                                    ColorResources.pink_color),
                                              )),
                                        );
                                      } else if (regiController
                                          .rxStatusCountryLoading.value ==
                                          Status.ERROR) {
                                        return const Center(
                                            child: Text('Failed to load country'));
                                      } else if (regiController
                                          .countryList.isEmpty) {
                                        return const Center(
                                            child: Text('No Country available'));
                                      } else {
                                        return Expanded(
                                          child: DropdownButton<String>(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            underline: Container(),
                                            isExpanded: true,
                                            hint: const Text(
                                              'Select Country',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            value: regiController
                                                .country_id.value.isEmpty
                                                ? null
                                                : regiController
                                                .country_id.value,
                                            items: regiController.countryList
                                                .map((CountryData gender) {
                                              return DropdownMenuItem<String>(
                                                value: gender.id
                                                    .toString(),
                                                child: Text(gender.countryName ??
                                                    'Unknown'),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                regiController.setSelectedCountry(newValue);
                                              }
                                            },
                                          ),
                                        );
                                      }
                                    })
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                margin: const EdgeInsets.only(left: 5, right: 5),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    Obx(() {
                                      if (regiController.rxStatusStateLoading.value ==
                                          Status.LOADING) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 22),
                                          child: Container(
                                              alignment: Alignment.centerRight,
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: ColorHelperClass
                                                    .getColorFromHex(
                                                    ColorResources.pink_color),
                                              )),
                                        );
                                      } else if (regiController
                                          .rxStatusStateLoading.value ==
                                          Status.ERROR) {
                                        return const Center(
                                            child: Text('Failed to load state'));
                                      } else if (regiController
                                          .stateList.isEmpty) {
                                        return const Center(
                                            child: Text('No State available'));
                                      } else {
                                        return Expanded(
                                          child: DropdownButton<String>(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            underline: Container(),
                                            isExpanded: true,
                                            hint: const Text(
                                              'Select State',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            value: regiController
                                                .state_id.value.isEmpty
                                                ? null
                                                : regiController
                                                .state_id.value,
                                            items: regiController.stateList
                                                .map((StateData gender) {
                                              return DropdownMenuItem<String>(
                                                value: gender.id
                                                    .toString(),
                                                child: Text(gender.stateName ??
                                                    'Unknown'),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                regiController.setSelectedState(newValue);
                                              }
                                            },
                                          ),
                                        );
                                      }
                                    })
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                margin: const EdgeInsets.only(left: 5, right: 5),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    Obx(() {
                                      if (regiController.rxStatusCityLoading.value ==
                                          Status.LOADING) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 22),
                                          child: Container(
                                              alignment: Alignment.centerRight,
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: ColorHelperClass
                                                    .getColorFromHex(
                                                    ColorResources.pink_color),
                                              )),
                                        );
                                      } else if (regiController
                                          .rxStatusCityLoading.value ==
                                          Status.ERROR) {
                                        return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Failed to load city'),
                                            ));
                                      } else if (regiController
                                          .cityList.isEmpty) {
                                        return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('No City available'),
                                            ));
                                      } else {
                                        return Expanded(
                                          child: DropdownButton<String>(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            underline: Container(),
                                            isExpanded: true,
                                            hint: const Text(
                                              'Select City',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            value: regiController
                                                .city_id.value.isEmpty
                                                ? null
                                                : regiController
                                                .city_id.value,
                                            items: regiController.cityList
                                                .map((CityData gender) {
                                              return DropdownMenuItem<String>(
                                                value: gender.id
                                                    .toString(),
                                                child: Text(gender.cityName ??
                                                    'Unknown'),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                regiController.setSelectedCity(newValue);
                                              }
                                            },
                                          ),
                                        );
                                      }
                                    })
                                  ],
                                ),
                              ),
                            ],
                          ));
                    }),
                    const SizedBox(height: 20),
                    // Address Proof
                    _buildTextField(
                      label: "Address Proof",
                      controller: controller.documentTypeController,
                    ),
                    const SizedBox(height: 20),
                    // Image Preview & Upload Button
                    Column(
                      children: [
                        // **Show Image Preview if an image is selected**
                        if (_image != null)
                          Container(
                            height: 200, // Set preview height
                            width: double.infinity, // Full width
                            margin: const EdgeInsets.only(bottom: 10), // Space between preview & button
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey), // Border for better UI
                              borderRadius: BorderRadius.circular(8), // Rounded corners
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        // **Upload Button**
                        SizedBox(
                          width: double.infinity, // Matches text field width
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showImagePicker(context);
                            },
                            icon: const Icon(Icons.image),
                            label: const Text("Upload Image"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color), // Button color
                              foregroundColor: Colors.white, // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // Match text field border
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12), // Match height with text fields
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.black),
              title: const Text("Take a Picture"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.black),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }


  Widget _buildTextField({
    required String label,
    required Rx<TextEditingController> controller,
    bool readOnly=false
  }) {
    return TextField(
      controller: controller.value,
      readOnly: readOnly,
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

  Widget _buildInfoBox(String title, {String? subtitle, Widget? subtitleWidget}) {
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
            child: subtitleWidget ??
                (subtitle != null
                    ? Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )
                    : const SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}