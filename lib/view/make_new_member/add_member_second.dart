import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CheckPinCode/Building.dart';
import 'package:mpm/model/documenttype/DocumentTypeModel.dart';
import 'package:mpm/model/membership/MemberShipData.dart';
import 'package:mpm/utils/app_constants.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:permission_handler/permission_handler.dart';

class NewMemberResidental extends StatefulWidget {
  const NewMemberResidental({super.key});

  @override
  State<NewMemberResidental> createState() => _NewMemberResidentalState();
}

class _NewMemberResidentalState extends State<NewMemberResidental> {
  String? _selectedDocs;
  final regiController = Get.put(NewMemberController());

  File? _image; // Store the selected image
  final ImagePicker _picker = ImagePicker();
  int activeStep2 = 2;

  List<XFile>? _mediaFileList;
  GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();

  // Function to open the image picker
  Future<void> _showPicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Picture'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
          title: Text(
            AppConstants.new_member,
            style: TextStyleClass.white16style,
          ),
        ),
        backgroundColor: Colors.white,
        bottomNavigationBar: Container(
          margin:
          const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 10),
          height: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  child: Container(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(
                            ColorResources.red_color),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(AppConstants.back,
                          style: TextStyleClass.white16style),
                    ),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: Obx(() => ElevatedButton(
                    onPressed: () {
                      if (_formKeyLogin!.currentState!.validate()) {
                        void showErrorSnackbar(String message) {
                          Get.snackbar(
                            "Error",
                            message,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        }

                        if (regiController.selectBuilding == '') {
                          showErrorSnackbar("Select Building Name");
                          return;
                        }
                        if (regiController.selectDocumentType == '') {
                          showErrorSnackbar("Select Document Type");
                          return;
                        }
                        if (regiController.userdocumentImage.value == '') {
                          showErrorSnackbar("Select Document Image");
                          return;
                        }
                        if (regiController.selectMemberShipType.value ==
                            '') {
                          showErrorSnackbar("Select MemberShip Type");
                          return;
                        }
                        regiController.userRegister(
                          regiController.lmCodeValue.value,
                          context,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: regiController.loading.value
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color:
                        Colors.white, // Loading indicator color
                        strokeWidth: 2, // Thickness of the spinner
                      ),
                    )
                        : Text(
                      AppConstants.continues,
                      style: TextStyleClass.white16style,
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          height: screenHeight,
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Form(
                      key: _formKeyLogin,
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment
                                .start, // Aligns children to the left
                            children: [
                              Text(
                                'Residential Info',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

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
                                  const Padding(
                                    padding: EdgeInsets.only(left: 12.0),
                                  ),
                                  // Space between the flag and text field
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.phone,
                                      controller: regiController
                                          .pincodeController.value,
                                      decoration: const InputDecoration(
                                        hintText: 'Pin Code *',
                                        border: InputBorder
                                            .none, // Remove the internal border
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
                                        print(
                                            "fghjjhjjh${regiController.pincodeController.value.text}");
                                        if (regiController
                                            .pincodeController.value.text !=
                                            '') {
                                          var pincode = regiController
                                              .pincodeController.value.text;
                                          regiController
                                              .getCheckPinCode(pincode);
                                        } else {
                                          Get.snackbar(
                                            "Error",
                                            "Select Pin Code",
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.TOP,
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(5),
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
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 12.0),
                                ),
                                Obx(() {
                                  return Visibility(
                                    visible: regiController.isBuilding.value ==
                                        false,
                                    child: Obx(() {
                                      if (regiController
                                          .rxStatusBuilding.value ==
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
                                                  ColorResources
                                                      .red_color),
                                            ),
                                          ),
                                        );
                                      } else if (regiController
                                          .rxStatusBuilding.value ==
                                          Status.ERROR) {
                                        return const Center(
                                            child: Text(
                                                'Failed to load Building Name'));
                                      } else if (regiController
                                          .rxStatusBuilding.value ==
                                          Status.IDLE) {
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child:
                                            Text('Select Building Name *'),
                                          ),
                                        );
                                      } else if (regiController
                                          .checkPinCodeList.isEmpty) {
                                        return const Center(
                                            child: Text(
                                                'No Building name available'));
                                      } else {
                                        return Expanded(
                                          child: DropdownButton<String>(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            isExpanded: true,
                                            underline: Container(),
                                            hint: const Text(
                                              'Select Building Name *',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ), // Hint to show when nothing is selected
                                            value: regiController.selectBuilding
                                                .value.isEmpty
                                                ? null
                                                : regiController
                                                .selectBuilding.value,
                                            items: regiController
                                                .checkPinCodeList
                                                .map((Building marital) {
                                              return DropdownMenuItem<String>(
                                                value: marital.id
                                                    .toString(), // Use unique ID or any unique property.
                                                child: Text(marital
                                                    .buildingName ??
                                                    'Unknown'), // Display name from DataX.
                                              );
                                            }).toList(), // Convert to List.
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                regiController
                                                    .selectBuilding(newValue);
                                                if (newValue == 'other') {
                                                  regiController
                                                      .isBuilding.value = true;
                                                } else {
                                                  regiController
                                                      .isBuilding.value = false;
                                                }
                                              }
                                            },
                                          ),
                                        );
                                      }
                                    }),
                                  );
                                }),
                                Obx(() {
                                  return Visibility(
                                    visible: regiController.isBuilding.value,
                                    child: Expanded(
                                      child: TextFormField(
                                        controller: regiController
                                            .buildingController.value,
                                        keyboardType: TextInputType.text,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Enter Building';
                                          } else {
                                            return null;
                                          }
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'Building Name',
                                          border: InputBorder
                                              .none, // Remove the internal border
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 22), // Adjust padding
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Mandal Zone
                          _buildEditableField(
                            "Mandal Zone",
                            regiController.zoneController.value,
                            "Mandal Zone *",
                            "Enter Mandal Zone",
                          ),
                          const SizedBox(height: 20),

                          // Flat No
                          _buildEditableField(
                            'Flat No *',
                            regiController.housenoController.value,
                            'Enter House No/Flat',
                            'Enter House No/Flat',
                          ),
                          const SizedBox(height: 20),

                          // Area
                          _buildEditableField(
                            'Area *',
                            regiController.areaController.value,
                            'Enter Area Name',
                            'Enter Area Name',
                          ),
                          const SizedBox(height: 20),

                          // City
                          _buildEditableField(
                            'City *',
                            regiController.cityController.value,
                            'Enter City Name',
                            'Enter City Name',
                          ),
                          const SizedBox(height: 20),

                          //State
                          SizedBox(
                            width: double.infinity,
                            child: _buildEditableField(
                              'State *',
                              regiController.stateController.value,
                              'Enter State Name',
                              'Enter State Name',
                            ),
                          ),
                          const SizedBox(height: 20),

                          // MemberShip
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 12.0),
                                ),
                                Obx(() {
                                  if (regiController
                                      .rxStatusMemberShipTYpe.value ==
                                      Status.LOADING) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 22),
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color:
                                          ColorHelperClass.getColorFromHex(
                                              ColorResources.pink_color),
                                        ),
                                      ),
                                    );
                                  } else if (regiController
                                      .rxStatusMemberShipTYpe.value ==
                                      Status.ERROR) {
                                    return const Center(
                                        child: Text(' No Data'));
                                  } else if (regiController
                                      .memberShipList.isEmpty) {
                                    return const Center(
                                        child: Text(
                                            'No membership Type available'));
                                  } else {
                                    return Expanded(
                                      child: DropdownButton<String>(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        isExpanded: true,
                                        underline: Container(),
                                        hint: const Text(
                                          'Select MemberShip *',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ), // Hint to show when nothing is selected
                                        value: regiController
                                            .selectMemberShipType
                                            .value
                                            .isEmpty
                                            ? null
                                            : regiController
                                            .selectMemberShipType.value,
                                        items: regiController.memberShipList
                                            .map((MemberShipData marital) {
                                          return DropdownMenuItem<String>(
                                            value: marital.id
                                                .toString(), // Use unique ID or any unique property.
                                            child: Text(
                                                "${marital.membershipName}- Rs ${marital.price}"), // Display name from DataX.
                                          );
                                        }).toList(), // Convert to List.
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            regiController
                                                .selectMemberShipType(newValue);
                                          }
                                        },
                                      ),
                                    );
                                  }
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Address Proof
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 12.0),
                                ),
                                Obx(() {
                                  if (regiController.rxStatusDocument.value ==
                                      Status.LOADING) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 22),
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color:
                                          ColorHelperClass.getColorFromHex(
                                              ColorResources.red_color),
                                        ),
                                      ),
                                    );
                                  } else if (regiController
                                      .rxStatusDocument.value ==
                                      Status.ERROR) {
                                    return const Center(
                                        child: Text(' No Data'));
                                  } else if (regiController
                                      .documntTypeList.isEmpty) {
                                    return const Center(
                                        child:
                                        Text('No Document Type available'));
                                  } else {
                                    return Expanded(
                                      child: DropdownButton<String>(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        isExpanded: true,
                                        underline: Container(),
                                        hint: const Text(
                                          'Select Address Proof *',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ), // Hint to show when nothing is selected
                                        value: regiController.selectDocumentType
                                            .value.isEmpty
                                            ? null
                                            : regiController
                                            .selectDocumentType.value,
                                        items: regiController.documntTypeList
                                            .map((DocumentTypeData marital) {
                                          return DropdownMenuItem<String>(
                                            value: marital.name
                                                .toString(), // Use unique ID or any unique property.
                                            child: Text(marital.name ??
                                                'Unknown'), // Display name from DataX.
                                          );
                                        }).toList(), // Convert to List.
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            regiController
                                                .selectDocumentType(newValue);
                                          }
                                        },
                                      ),
                                    );
                                  }
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Upload Button
                          ElevatedButton(
                            onPressed: () async {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext bc) {
                                  return SafeArea(
                                    child: Wrap(
                                      children: <Widget>[
                                        ListTile(
                                          leading:
                                          const Icon(Icons.photo_library),
                                          title:
                                          const Text('Pick from Gallery'),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await _pickImage(
                                                ImageSource.gallery);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt),
                                          title: const Text('Take a Picture'),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await _pickImage(
                                                ImageSource.camera);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: _image != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.file(
                                  _image!,
                                  width: double.infinity,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : const Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Upload File",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Terms and Condition
                          Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Obx(() => Checkbox(
                                  value: regiController.isChecked.value,
                                  onChanged: regiController.toggleCheckbox,
                                )),
                                const Text(
                                  'Accept Terms and Condition ',
                                  style: TextStyle(
                                    color: Color(0xFFe61428), // Updated color
                                    fontSize:
                                    16, // Assuming the original size was 16
                                    // Add other properties if needed (e.g., fontWeight, fontFamily, etc.)
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
      String label,
      TextEditingController controller,
      String hintText,
      String validationMessage,
      {bool obscureText = false}) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: ColorHelperClass.getColorFromHex(ColorResources.red_color)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 20,
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return validationMessage;
          }
          return null;
        },
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
}
