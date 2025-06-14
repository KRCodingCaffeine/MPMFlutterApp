import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CheckPinCode/Building.dart';
import 'package:mpm/model/CountryModel/CountryData.dart';
import 'package:mpm/model/State/StateData.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/model/documenttype/DocumentTypeModel.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
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
  NewMemberController regiController = Get.put(NewMemberController());
  GlobalKey<FormState>? formKeyLogin = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Residential Info',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0), // Outer padding for the Card
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
                    Obx(() {
                      return _buildInfoBox(
                        'Building Name:',
                        subtitle: controller
                                .getUserData.value.address?.buildingNameId
                                ?.toString() ??
                            "N/A",
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      return _buildInfoBox(
                        'Flat No:',
                        subtitle: controller.getUserData.value.address?.flatNo
                                ?.toString() ??
                            "N/A",
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      return _buildInfoBox(
                        'Zone:',
                        subtitle: controller.getUserData.value.address?.zoneName
                                ?.toString() ??
                            "N/A",
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      return _buildInfoBox(
                        'Address:',
                        subtitle: controller.getUserData.value.address?.address
                                ?.toString() ??
                            "N/A",
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      return _buildInfoBox(
                        'Area:',
                        subtitle: controller.getUserData.value.address?.areaName
                                ?.toString() ??
                            "N/A",
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      return _buildInfoBox(
                        'State:',
                        subtitle: controller
                                .getUserData.value.address?.stateName
                                ?.toString() ??
                            "N/A",
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      return _buildInfoBox(
                        'City:',
                        subtitle: controller.getUserData.value.address?.cityName
                                ?.toString() ??
                            "N/A",
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      return _buildInfoBox(
                        'Country:',
                        subtitle: controller
                                .getUserData.value.address?.countryName
                                ?.toString() ??
                            "N/A",
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      return _buildInfoBox(
                        'Pincode:',
                        subtitle: controller.getUserData.value.address?.pincode
                                ?.toString() ??
                            "N/A",
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      return _buildInfoBox(
                        'Address Proof:',
                        subtitle: controller.getUserData.value.documentType
                                .toString() ??
                            "N/A",
                      );
                    }),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Obx(() {
                          final imagePath = controller.documentDynamicImage.value;
                          final isImageAvailable = imagePath != null && imagePath.isNotEmpty;

                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isImageAvailable
                                  ? () {
                                _showImagePreviewDialog(context);
                              }
                                  : null, // Disables button if image is not available
                              icon: const Icon(Icons.visibility),
                              label: const Text("View Image"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color,
                                ),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade400, // Disabled color
                                disabledForegroundColor: Colors.white70,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
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
          child: Obx(() {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: controller.documentDynamicImage.value != null
                  ? Image.network(controller.documentDynamicImage.value,
                      fit: BoxFit.contain) // Display the image
                  : const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No image uploaded",
                          textAlign: TextAlign.center),
                    ),
            );
          }),
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
        if (controller.getUserData.value.address != null) {
          //   print("ggghhg"+getUserData.value.address!.city_id.toString());
          NewMemberController memberController = Get.put(NewMemberController());
          memberController.area_name.value =
              controller.getUserData.value.address!.areaName.toString();
          memberController.zone_id.value =
              controller.getUserData.value.address!.zoneId.toString();
          regiController.areaController.value.text =
              controller.getUserData.value.address!.areaName.toString();
          // zone_id.value = getUserData.value.address!.zoneId.toString();
          //
          // address.value = getUserData.value.address!.address.toString();
          // flatNo.value = getUserData.value.address!.flatNo.toString();
          // zone_name.value = controller.getUserData.value.address!.zoneName.toString();
          regiController.state_id.value =
              controller.getUserData.value.address!.stateId.toString();
          regiController.city_id.value =
              controller.getUserData.value.address!.city_id.toString();
          regiController.country_id.value =
              controller.getUserData.value.address!.countryId.toString();
          controller.pincodeController.value.text =
              controller.getUserData.value.address!.pincode.toString();
          regiController.selectDocumentType.value =
              controller.getUserData.value.addressProofTypeId.toString();
          // countryController.value.text = getUserData.value.address!.countryName.toString();
          // buildingController.value.text =
          //     getUserData.value.address!.buildingNameId.toString();
          // if(getUserData.value.address!.pincode.toString()!="" && getUserData.value.address!.pincode.toString()!="null") {
          //   pincodeController.value.text =
          //       getUserData.value.address!.pincode.toString();
          // }
          // if(getUserData.value.address!.buildingNameId.toString()!="" && getUserData.value.address!.buildingNameId.toString()!="null") {
          //   memberController.buildingController.value.text =
          //       getUserData.value.address!.buildingNameId.toString();
          // }
          controller.flatNoController.value.text =
              controller.getUserData.value.address!.flatNo.toString();
          controller.updateresidentalAddressController.value.text =
              controller.getUserData.value.address!.address!.toString()!;
          // memberController. zoneController.value.text= getUserData.value.address!.zoneName.toString();
          // if(getUserData.value.address!.areaName.toString()!="" && getUserData.value.address!.areaName.toString()!="null" ) {
          //   memberController.areaController.value.text = getUserData.value.address!.areaName.toString();
          // }
          // memberController.country_id.value=getUserData.value.address!.countryId.toString();
          // memberController.state_id.value=getUserData.value.address!.stateId.toString();
          // if((getUserData.value.address!.city_id.toString()!="null") && (getUserData.value.address!.city_id.toString()!="")) {
          //   memberController.city_id.value = getUserData.value.address!.city_id.toString();
          // }
        }

        return FractionallySizedBox(
          heightFactor: 0.8,
          child: SafeArea(
            child: Column(
              children: [
                // Fixed Buttons Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                          side: BorderSide(
                              color: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKeyLogin!.currentState!.validate()) {
                            // Validate required fields
                            void showErrorSnackbar(String message) {
                              Get.snackbar(
                                "Error",
                                message,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                              );
                            }

                            if (regiController.country_id.value.isEmpty) {
                              showErrorSnackbar("Select Country");
                              return;
                            }
                            if (regiController.state_id.value.isEmpty) {
                              showErrorSnackbar("Select State");
                              return;
                            }
                            if (regiController.city_id.value.isEmpty) {
                              showErrorSnackbar("Select City");
                              return;
                            }
                            if (controller.pincodeController.value.text.isEmpty) {
                              showErrorSnackbar("Enter PinCode");
                              return;
                            }
                            if (regiController.selectDocumentType.value.isEmpty) {
                              showErrorSnackbar("Please select an address proof type");
                              return;
                            }

                            // Call the update method
                            await controller.userResidentalProfile(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Scrollable Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
                    ),
                    child: Form(
                      key: formKeyLogin,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
                          // Pincode Field with Search Button
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.phone,
                                      controller:
                                          controller.pincodeController.value,
                                      decoration: const InputDecoration(
                                        hintText: 'Pin Code *',
                                        border: InputBorder
                                            .none, // Remove the internal border
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 22), // Adjust padding
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        print("fghjjhjjh" +
                                            controller
                                                .pincodeController.value.text);
                                        if (controller
                                                .pincodeController.value.text !=
                                            '') {
                                          var pincode = controller
                                              .pincodeController.value.text;
                                          controller.zoneController.value.text =
                                              "";
                                          regiController
                                              .getCheckPinCode(pincode);
                                        } else {
                                          Get.snackbar(
                                            "Error",
                                            "Select Pin Code",
                                            backgroundColor: ColorHelperClass
                                                .getColorFromHex(
                                                    ColorResources.red_color),
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.TOP,
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ColorHelperClass.getColorFromHex(
                                                ColorResources.red_color),
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
                          const SizedBox(height: 30),

                          // Building Name Dropdown and Input
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                margin:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Obx(() {
                                  if (regiController.rxStatusBuilding.value ==
                                      Status.LOADING) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 22),
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.redAccent),
                                      ),
                                    );
                                  } else if (regiController
                                          .rxStatusBuilding.value ==
                                      Status.ERROR) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                            'Failed to load Building Name'),
                                      ),
                                    );
                                  } else {
                                    return InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Building Name *',
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black)),
                                        enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black)),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black38,
                                                width: 1)),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20),
                                        labelStyle: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        underline: Container(),
                                        dropdownColor: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        hint: const Text('Select Building *',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        value: regiController
                                                .selectBuilding.value.isNotEmpty
                                            ? regiController
                                                .selectBuilding.value
                                            : null,
                                        items: [
                                          if (regiController
                                              .checkPinCodeList.isEmpty)
                                            const DropdownMenuItem<String>(
                                              value: 'other',
                                              child: Text(
                                                  'Can\'t find your building'),
                                            )
                                          else
                                            ...regiController.checkPinCodeList
                                                .map((building) {
                                              return DropdownMenuItem<String>(
                                                value: building.id.toString(),
                                                child: Text(
                                                    building.buildingName ??
                                                        'Unknown'),
                                              );
                                            }).toList()
                                        ],
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            regiController
                                                .selectBuilding(newValue);
                                            regiController.isBuilding.value =
                                                regiController.checkPinCodeList
                                                        .isEmpty ||
                                                    newValue == 'other';
                                          }
                                        },
                                      ),
                                    );
                                  }
                                }),
                              ),

                              // Building Name Input Field
                              Obx(() {
                                return Visibility(
                                  visible: regiController.isBuilding.value,
                                  child: Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 5, top: 20),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: TextFormField(
                                        controller: regiController
                                            .buildingController.value,
                                        keyboardType: TextInputType.text,
                                        validator: (value) {
                                          if (regiController.isBuilding.value &&
                                              (value == null ||
                                                  value.isEmpty)) {
                                            return 'Please enter building name';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'Enter Building Name *',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 30),

                          _buildTextField(
                              label: "Mandal Zone *",
                              controller:  regiController.zoneController,
                              text: TextInputType.text,
                              empty:   "Mandal Zone *",
                              readOnly: true
                          ),
                          const SizedBox(height: 30),

                          // Flat No
                          _buildTextField(
                              label: "Flat No",
                              controller: controller.flatNoController,
                              text: TextInputType.text,
                              empty: "Flat No is required !!"
                          ),
                          const SizedBox(height: 30),

                          // Address
                          _buildTextField(
                              label: "Address",
                              controller: controller.updateresidentalAddressController,
                              text: TextInputType.text,
                              empty: "Address is required !!"
                          ),
                          const SizedBox(height: 30),

                          // Area
                          Obx((){
                            return _buildTextField(
                                label: "Area",
                                controller: regiController.areaController,
                                text: TextInputType.text,
                                empty: 'Area Name is required !!',
                                readOnly: regiController.countryNotFound.value?true: false
                            );
                          }),
                          const SizedBox(height: 30),

                          Obx(() {
                            return Visibility(
                                visible: regiController.countryNotFound.value,
                                child: Column(
                                  children: [
                                    // City
                                    _buildTextField(
                                        label:  'City *',
                                        controller:  regiController.cityController,
                                        empty:  'Enter City Name',
                                        text: TextInputType.text,
                                        readOnly: true),
                                    const SizedBox(height: 30),

                                    //State
                                    SizedBox(
                                      width: double.infinity,
                                      child: _buildTextField(
                                          label:   'State *',
                                          controller:   regiController.stateController,
                                          empty:   'Enter State Name',
                                          text: TextInputType.text,
                                          readOnly: true),
                                    ),
                                    const SizedBox(height: 30),

                                    // Country
                                    SizedBox(
                                      width: double.infinity,
                                      child: _buildTextField(
                                          label:   'Country *',
                                          controller: regiController.countryController,
                                          empty:   'Enter Country Name',
                                          text: TextInputType.text,
                                          readOnly: true),
                                    ),
                                  ],
                                ));
                          }),

                          Obx(() {
                            return Visibility(
                              visible: regiController.countryNotFound.value == false,
                              child: Column(
                                children: [

                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(left: 5, right: 5),
                                    child: Row(
                                      children: [
                                        Obx(() {
                                          if (regiController.rxStatusCityLoading.value == Status.LOADING) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                                              child: SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            );
                                          } else if (regiController.rxStatusCityLoading.value == Status.ERROR) {
                                            return const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Failed to load city'),
                                              ),
                                            );
                                          } else if (regiController.cityList.isEmpty) {
                                            return const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('No City available'),
                                              ),
                                            );
                                          } else {
                                            final selectedCity = regiController.city_id.value;
                                            return Expanded(
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  labelText: selectedCity.isNotEmpty ? 'City *' : null,
                                                  border: const OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.black),
                                                  ),
                                                  enabledBorder: const OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.black),
                                                  ),
                                                  focusedBorder: const OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.black38, width: 1),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 20, vertical: 0),
                                                  labelStyle: const TextStyle(color: Colors.black),
                                                ),
                                                child: DropdownButton<String>(
                                                  dropdownColor: Colors.white,
                                                  borderRadius: BorderRadius.circular(10),
                                                  isExpanded: true,
                                                  underline: Container(),
                                                  hint: const Text(
                                                    'Select City *',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  value: selectedCity.isNotEmpty ? selectedCity : null,
                                                  items: regiController.cityList.map((CityData city) {
                                                    return DropdownMenuItem<String>(
                                                      value: city.id.toString(),
                                                      child: Text(city.cityName ?? 'Unknown'),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? newValue) {
                                                    if (newValue != null) {
                                                      regiController.setSelectedCity(newValue);
                                                    }
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        }),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(left: 5, right: 5),
                                    child: Row(
                                      children: [
                                        Obx(() {
                                          if (regiController.rxStatusStateLoading.value == Status.LOADING) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                                              child: SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            );
                                          } else if (regiController.rxStatusStateLoading.value == Status.ERROR) {
                                            return const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Failed to load state'),
                                              ),
                                            );
                                          } else if (regiController.stateList.isEmpty) {
                                            return const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('No State available'),
                                              ),
                                            );
                                          } else {
                                            final selectedState = regiController.state_id.value;
                                            return Expanded(
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  labelText: selectedState.isNotEmpty ? 'State *' : null,
                                                  border: const OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.black),
                                                  ),
                                                  enabledBorder: const OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.black),
                                                  ),
                                                  focusedBorder: const OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.black38, width: 1),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                  labelStyle: const TextStyle(color: Colors.black),
                                                ),
                                                child: DropdownButton<String>(
                                                  dropdownColor: Colors.white,
                                                  borderRadius: BorderRadius.circular(10),
                                                  isExpanded: true,
                                                  underline: Container(),
                                                  hint: const Text(
                                                    'Select State *',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  value: selectedState.isNotEmpty ? selectedState : null,
                                                  items: regiController.stateList.map((StateData state) {
                                                    return DropdownMenuItem<String>(
                                                      value: state.id.toString(),
                                                      child: Text(state.stateName ?? 'Unknown'),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? newValue) {
                                                    if (newValue != null) {
                                                      regiController.setSelectedState(newValue);
                                                    }
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        }),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(left: 5, right: 5),
                                    child: Row(
                                      children: [
                                        Obx(() {
                                          if (regiController.rxStatusCountryLoading.value == Status.LOADING) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                                              child: SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            );
                                          } else if (regiController.rxStatusCountryLoading.value == Status.ERROR) {
                                            return const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Failed to load country'),
                                              ),
                                            );
                                          } else if (regiController.countryList.isEmpty) {
                                            return const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('No Country available'),
                                              ),
                                            );
                                          } else {
                                            final selectedCountry = regiController.country_id.value;
                                            return Expanded(
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  labelText: selectedCountry.isNotEmpty ? 'Country *' : null,
                                                  border: const OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.black),
                                                  ),
                                                  enabledBorder: const OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.black),
                                                  ),
                                                  focusedBorder: const OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.black38, width: 1),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                                  labelStyle: const TextStyle(color: Colors.black),
                                                ),
                                                child: DropdownButton<String>(
                                                  dropdownColor: Colors.white,
                                                  borderRadius: BorderRadius.circular(10),
                                                  isExpanded: true,
                                                  underline: Container(),
                                                  hint: const Text(
                                                    'Select Country *',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  value: selectedCountry.isNotEmpty ? selectedCountry : null,
                                                  items: regiController.countryList.map((CountryData country) {
                                                    return DropdownMenuItem<String>(
                                                      value: country.id.toString(),
                                                      child: Text(country.countryName ?? 'Unknown'),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? newValue) {
                                                    if (newValue != null) {
                                                      regiController.setSelectedCountry(newValue);
                                                    }
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 30),

                          // Address Proof
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            child: Row(
                              children: [
                                Obx(() {
                                  if (regiController.rxStatusDocument.value == Status.LOADING) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    );
                                  } else if (regiController.rxStatusDocument.value == Status.ERROR) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                                      child: Text('No Data'),
                                    );
                                  } else if (regiController.documntTypeList.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('No Address Proof available'),
                                    );
                                  } else {
                                    final selectedProof = regiController.selectDocumentType.value;
                                    return Expanded(
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: selectedProof.isNotEmpty ? 'Address Proof *' : null,
                                          border: const OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black),
                                          ),
                                          enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black),
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black38, width: 1),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                          labelStyle: const TextStyle(color: Colors.black),
                                        ),
                                        child: DropdownButton<String>(
                                          dropdownColor: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          isExpanded: true,
                                          underline: Container(),
                                          hint: const Text(
                                            'Address Proof *',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          value: selectedProof.isNotEmpty ? selectedProof : null,
                                          items: regiController.documntTypeList.map((DocumentTypeData doc) {
                                            return DropdownMenuItem<String>(
                                              value: doc.id.toString(),
                                              child: Text(doc.documentType?.toString() ?? 'Unknown'),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              regiController.setDocumentType(newValue);
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Image Preview & Upload Button
                          Column(
                            children: [
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
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text("Take a Picture"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.redAccent),
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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      controller.userdocumentImage.value = pickedFile!.path.toString();
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      controller.userdocumentImage.value = pickedFile!.path.toString();
    }
  }

  Widget _buildTextField({
    required String label,
    required Rx<TextEditingController> controller,
    bool readOnly = false,
    required TextInputType text,
    required String empty,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: TextFormField(
        controller: controller.value,
        readOnly: readOnly,
        keyboardType: text,
        style: const TextStyle(color: Colors.black), // Text color
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black), // Label text color
          hintText: label,
          hintStyle: const TextStyle(color: Colors.black54), // Hint text color
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black38, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 20,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return empty;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildInfoBox(String title,
      {String? subtitle, Widget? subtitleWidget}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 105,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
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
