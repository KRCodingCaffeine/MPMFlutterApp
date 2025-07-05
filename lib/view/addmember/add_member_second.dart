import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CheckPinCode/Building.dart';
import 'package:mpm/model/CountryModel/CountryData.dart';
import 'package:mpm/model/State/StateData.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/model/documenttype/DocumentTypeModel.dart';
import 'package:mpm/model/membership/MemberShipData.dart';

import 'package:mpm/utils/app_constants.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/register/register_view_model.dart';
import 'package:permission_handler/permission_handler.dart';

class NewMemberResidental extends StatefulWidget {
  const NewMemberResidental({super.key});

  @override
  State<NewMemberResidental> createState() => _NewMemberResidentalState();
}

class _NewMemberResidentalState extends State<NewMemberResidental> {
  String? _selectedDocs;
  final regiController = Get.put(NewMemberController());

  File? _image;
  final ImagePicker _picker = ImagePicker();
  int activeStep2 = 2;
  var fal = false.obs;

  GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();

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
          title: const Text(
            "Make New Member",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor:
              ColorHelperClass.getColorFromHex(ColorResources.logo_color),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: Colors.grey[100],
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
                  width: 130,
                  child: Container(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(
                            ColorResources.red_color),
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                  width: 130,
                  child: Obx(() => ElevatedButton(
                        onPressed: () {
                          if (_formKeyLogin!.currentState!.validate()) {
                            void showErrorSnackbar(String message) {
                              Get.snackbar(
                                "Error",
                                message,
                                backgroundColor:
                                    ColorHelperClass.getColorFromHex(
                                        ColorResources.red_color),
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
                          padding: const EdgeInsets.symmetric(vertical: 10),
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
                          const Padding(
                            padding: EdgeInsets.only(left: 5, top: 20),
                            child: Align(
                              alignment: Alignment
                                  .centerLeft, // Align text to the left side
                              child: Text(
                                'Residential Info',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          //Pincode
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              margin: const EdgeInsets.only(left: 5, right: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.phone,
                                      controller: regiController.pincodeController.value,
                                      decoration: const InputDecoration(
                                        hintText: 'Pin Code *',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (regiController.pincodeController.value.text != '') {
                                          var pincode = regiController.pincodeController.value.text;
                                          regiController.zoneController.value.text = "";
                                          regiController.getCheckPinCode(pincode);
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
                                        backgroundColor: ColorHelperClass.getColorFromHex(
                                            ColorResources.red_color),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Building Name Dropdown
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(left: 5, right: 5),
                                child: Obx(() {
                                  if (regiController.rxStatusBuilding.value == Status.LOADING) {
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
                                  } else if (regiController.rxStatusBuilding.value == Status.ERROR) {
                                    return const Center(
                                      child: Text('Failed to load Building Name'),
                                    );
                                  } else {
                                    return InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Building Name *',
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
                                        isExpanded: true,
                                        underline: Container(),
                                        dropdownColor: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        hint: const Text(
                                          'Select Building *',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        value: regiController.selectBuilding.value.isNotEmpty
                                            ? regiController.selectBuilding.value
                                            : null,
                                        items: [
                                          // Show only "Can't find" option when no buildings exist
                                          if (regiController.checkPinCodeList.isEmpty)
                                            const DropdownMenuItem<String>(
                                              value: 'other',
                                              child: Text('Can\'t find your building'),
                                            )
                                          // Otherwise show only the actual buildings
                                          else
                                            ...regiController.checkPinCodeList.map((building) {
                                              return DropdownMenuItem<String>(
                                                value: building.id.toString(),
                                                child: Text(building.buildingName ?? 'Unknown'),
                                              );
                                            }).toList(),
                                        ],
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            regiController.selectBuilding(newValue);
                                            // Show input field only when pincode doesn't exist
                                            regiController.isBuilding.value =
                                                regiController.checkPinCodeList.isEmpty;
                                          }
                                        },
                                      ),
                                    );
                                  }
                                }),
                              ),

                              // Building Name Input Field (shown only when pincode doesn't exist)
                              Obx(() {
                                return Visibility(
                                  visible: regiController.isBuilding.value,
                                  child: Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(left: 5, right: 5, top: 20),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: TextFormField(
                                        controller: regiController.buildingController.value,
                                        keyboardType: TextInputType.text,
                                        validator: (value) {
                                          if (regiController.isBuilding.value &&
                                              (value == null || value.isEmpty)) {
                                            return 'Please enter building name';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'Enter Building Name *',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _buildEditableField(
                              "Mandal Zone *",
                              regiController.zoneController.value,
                              "Mandal Zone *",
                              "",
                              readOnly: true),
                          const SizedBox(height: 20),

                          // Address
                          _buildEditableField(
                            'Address *',
                            regiController.addressMemberController.value,
                            'Enter Address',
                            '',
                          ),
                          const SizedBox(height: 20),

                          // Flat No
                          _buildEditableField(
                            'Flat No *',
                            regiController.housenoController.value,
                            'Enter Flat No',
                            '',
                          ),
                          const SizedBox(height: 20),

                          // Area
                          Obx(() {
                            return _buildEditableField(
                                'Area *',
                                regiController.areaController.value,
                                'Enter Area Name',
                                '',
                                readOnly: regiController.countryNotFound.value
                                    ? true
                                    : false);
                          }),
                          Obx(() {
                            return Visibility(
                                visible: regiController.countryNotFound.value,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),

                                    // City
                                    _buildEditableField(
                                        'City *',
                                        regiController.cityController.value,
                                        'Enter City Name',
                                        '',
                                        readOnly: true),
                                    const SizedBox(height: 20),

                                    //State
                                    SizedBox(
                                      width: double.infinity,
                                      child: _buildEditableField(
                                          'State *',
                                          regiController.stateController.value,
                                          'Enter State Name',
                                          '',
                                          readOnly: true),
                                    ),
                                    const SizedBox(height: 20),

                                    // Country
                                    SizedBox(
                                      width: double.infinity,
                                      child: _buildEditableField(
                                          'Country *',
                                          regiController
                                              .countryController.value,
                                          'Enter Country Name',
                                          '',
                                          readOnly: true),
                                    ),
                                  ],
                                ));
                          }),
                          Obx(
                            () {
                              return Visibility(
                                visible: regiController.countryNotFound.value ==
                                    false,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      child: Row(
                                        children: [
                                          Obx(() {
                                            if (regiController
                                                    .rxStatusCityLoading
                                                    .value ==
                                                Status.LOADING) {
                                              return const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 22),
                                                child: SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              );
                                            } else if (regiController
                                                    .rxStatusCityLoading
                                                    .value ==
                                                Status.ERROR) {
                                              return const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'Failed to load city'),
                                                ),
                                              );
                                            } else if (regiController
                                                .cityList.isEmpty) {
                                              return const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child:
                                                      Text('No City available'),
                                                ),
                                              );
                                            } else {
                                              final selectedCity =
                                                  regiController.city_id.value;
                                              return Expanded(
                                                child: InputDecorator(
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        selectedCity.isNotEmpty
                                                            ? 'City *'
                                                            : null,
                                                    border:
                                                        const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black),
                                                    ),
                                                    enabledBorder:
                                                        const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black),
                                                    ),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black38,
                                                          width: 1),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 20,
                                                            vertical: 0),
                                                    labelStyle: const TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  child: DropdownButton<String>(
                                                    dropdownColor: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    isExpanded: true,
                                                    underline: Container(),
                                                    hint: const Text(
                                                      'Select City *',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    value:
                                                        selectedCity.isNotEmpty
                                                            ? selectedCity
                                                            : null,
                                                    items: regiController
                                                        .cityList
                                                        .map((CityData city) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value:
                                                            city.id.toString(),
                                                        child: Text(
                                                            city.cityName ??
                                                                'Unknown'),
                                                      );
                                                    }).toList(),
                                                    onChanged:
                                                        (String? newValue) {
                                                      if (newValue != null) {
                                                        regiController
                                                            .setSelectedCity(
                                                                newValue);
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
                                    const SizedBox(height: 20),

                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      child: Row(
                                        children: [
                                          Obx(() {
                                            if (regiController
                                                    .rxStatusStateLoading
                                                    .value ==
                                                Status.LOADING) {
                                              return const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 22),
                                                child: SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              );
                                            } else if (regiController
                                                    .rxStatusStateLoading
                                                    .value ==
                                                Status.ERROR) {
                                              return const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'Failed to load state'),
                                                ),
                                              );
                                            } else if (regiController
                                                .stateList.isEmpty) {
                                              return const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'No State available'),
                                                ),
                                              );
                                            } else {
                                              final selectedState =
                                                  regiController.state_id.value;
                                              return Expanded(
                                                child: InputDecorator(
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        selectedState.isNotEmpty
                                                            ? 'State *'
                                                            : null,
                                                    border:
                                                        const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black),
                                                    ),
                                                    enabledBorder:
                                                        const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black),
                                                    ),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black38,
                                                          width: 1),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 20,
                                                            vertical: 0),
                                                    labelStyle: const TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  child: DropdownButton<String>(
                                                    dropdownColor: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    isExpanded: true,
                                                    underline: Container(),
                                                    hint: const Text(
                                                      'Select State *',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    value:
                                                        selectedState.isNotEmpty
                                                            ? selectedState
                                                            : null,
                                                    items: regiController
                                                        .stateList
                                                        .map((StateData state) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value:
                                                            state.id.toString(),
                                                        child: Text(
                                                            state.stateName ??
                                                                'Unknown'),
                                                      );
                                                    }).toList(),
                                                    onChanged:
                                                        (String? newValue) {
                                                      if (newValue != null) {
                                                        regiController
                                                            .setSelectedState(
                                                                newValue);
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
                                    const SizedBox(height: 20),

                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      child: Row(
                                        children: [
                                          Obx(() {
                                            if (regiController
                                                    .rxStatusCountryLoading
                                                    .value ==
                                                Status.LOADING) {
                                              return const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 22),
                                                child: SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              );
                                            } else if (regiController
                                                    .rxStatusCountryLoading
                                                    .value ==
                                                Status.ERROR) {
                                              return const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'Failed to load country'),
                                                ),
                                              );
                                            } else if (regiController
                                                .countryList.isEmpty) {
                                              return const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'No Country available'),
                                                ),
                                              );
                                            } else {
                                              final selectedCountry =
                                                  regiController
                                                      .country_id.value;
                                              return Expanded(
                                                child: InputDecorator(
                                                  decoration: InputDecoration(
                                                    labelText: selectedCountry
                                                            .isNotEmpty
                                                        ? 'Country *'
                                                        : null,
                                                    border:
                                                        const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black),
                                                    ),
                                                    enabledBorder:
                                                        const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black),
                                                    ),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black38,
                                                          width: 1),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 20),
                                                    labelStyle: const TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  child: DropdownButton<String>(
                                                    dropdownColor: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    isExpanded: true,
                                                    underline: Container(),
                                                    hint: const Text(
                                                      'Select Country *',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    value: selectedCountry
                                                            .isNotEmpty
                                                        ? selectedCountry
                                                        : null,
                                                    items: regiController
                                                        .countryList
                                                        .map((CountryData
                                                            country) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: country.id
                                                            .toString(),
                                                        child: Text(country
                                                                .countryName ??
                                                            'Unknown'),
                                                      );
                                                    }).toList(),
                                                    onChanged:
                                                        (String? newValue) {
                                                      if (newValue != null) {
                                                        regiController
                                                            .setSelectedCountry(
                                                                newValue);
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
                            },
                          ),
                          const SizedBox(height: 20),

                          //MemberShip
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            child: Row(
                              children: [
                                Obx(() {
                                  if (!fal.value) {
                                    regiController.getMemberShip();
                                    fal.value = true;
                                  }

                                  final status = regiController.rxStatusMemberShipTYpe.value;

                                  if (status == Status.LOADING) {
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
                                  }

                                  String? message;
                                  if (status == Status.ERROR) {
                                    message = 'No Data';
                                  } else if (regiController.memberShipList.isEmpty) {
                                    message = 'No Membership available under 18';
                                  }

                                  if (message != null) {
                                    return Expanded(
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'Membership *',
                                          border: OutlineInputBorder(),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black38, width: 1),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                          labelStyle: TextStyle(color: Colors.black),
                                        ),
                                        child: Text(
                                          message,
                                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    );
                                  }

                                  // Normal Dropdown UI
                                  final selectedMember = regiController.selectMemberShipType.value;
                                  return Expanded(
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: selectedMember.isNotEmpty ? 'Membership *' : null,
                                        border: const OutlineInputBorder(),
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
                                          'Membership *',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        value: selectedMember.isNotEmpty ? selectedMember : null,
                                        items: regiController.memberShipList.map((MemberShipData ms) {
                                          return DropdownMenuItem<String>(
                                            value: ms.id.toString(),
                                            child: Text("${ms.membershipName ?? 'Unknown'} - Rs ${ms.price ?? '0'}"),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            regiController.selectMemberShipType(newValue);
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Saraswani Option
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            child: Row(
                              children: [
                                Obx(() {
                                  if (regiController.rxStatusLoading.value == Status.LOADING) {
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
                                  } else if (regiController.rxStatusLoading.value == Status.ERROR) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                                      child: Text('Failed to load Saraswani options'),
                                    );
                                  } else if (regiController.saraswaniOptionList.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('No Saraswani option available'),
                                    );
                                  } else {
                                    // Check if selected membership is "Non Member"
                                    bool isNonMember = false;
                                    if (regiController.selectMemberShipType.value.isNotEmpty) {
                                      final selectedMembership = regiController.memberShipList.firstWhere(
                                            (ms) => ms.id.toString() == regiController.selectMemberShipType.value,
                                        orElse: () => MemberShipData(),
                                      );
                                      isNonMember = (selectedMembership.membershipName?.toLowerCase() ?? '') == 'non member';
                                    }

                                    // Filter options based on membership type
                                    final filteredOptions = isNonMember
                                        ? regiController.saraswaniOptionList.where(
                                            (option) => (option.saraswaniOption?.toLowerCase() ?? '').contains('soft'))
                                        : regiController.saraswaniOptionList;

                                    final selectedOption = regiController.saraswaniOptionId.value;
                                    return Expanded(
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: selectedOption.isNotEmpty ? 'Saraswani Option *' : null,
                                          border: const OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black),
                                          ),
                                          enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black),
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black38, width: 1),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                          labelStyle: const TextStyle(color: Colors.black),
                                        ),
                                        child: DropdownButton<String>(
                                          dropdownColor: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          isExpanded: true,
                                          underline: Container(),
                                          hint: const Text(
                                            'Saraswani Option *',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          value: selectedOption.isNotEmpty ? selectedOption : null,
                                          items: filteredOptions.map((option) {
                                            return DropdownMenuItem<String>(
                                              value: option.id.toString(),
                                              child: Text(option.saraswaniOption?.toString() ?? 'Unknown'),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              regiController.saraswaniOptionId.value = newValue;
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
                          const SizedBox(height: 20),

                          //Address Proof
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            child: Row(
                              children: [
                                Obx(() {
                                  if (regiController.rxStatusDocument.value ==
                                      Status.LOADING) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 22),
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    );
                                  } else if (regiController
                                          .rxStatusDocument.value ==
                                      Status.ERROR) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 22),
                                      child: Text('No Data'),
                                    );
                                  } else if (regiController
                                      .documntTypeList.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('No Address Proof available'),
                                    );
                                  } else {
                                    final selectedProof =
                                        regiController.selectDocumentType.value;
                                    return Expanded(
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: selectedProof.isNotEmpty
                                              ? 'Address Proof *'
                                              : null,
                                          border: const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.black),
                                          ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.black),
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black38,
                                                width: 1),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 20),
                                          labelStyle: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        child: DropdownButton<String>(
                                          dropdownColor: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          isExpanded: true,
                                          underline: Container(),
                                          hint: const Text(
                                            'Address Proof *',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          value: selectedProof.isNotEmpty
                                              ? selectedProof
                                              : null,
                                          items: regiController.documntTypeList
                                              .map((DocumentTypeData doc) {
                                            return DropdownMenuItem<String>(
                                              value: doc.id.toString(),
                                              child: Text(doc.documentType
                                                      ?.toString() ??
                                                  'Unknown'),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              regiController
                                                  .setDocumentType(newValue);
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
                          const SizedBox(height: 20),

                          //Upload Address Proof
                          ElevatedButton(
                            onPressed: () async {
                              showModalBottomSheet(
                                backgroundColor: Colors.white,
                                context: context,
                                builder: (BuildContext bc) {
                                  return SafeArea(
                                    child: Wrap(
                                      children: <Widget>[
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
                                          title: const Text('Take a Picture'),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await _pickImage(
                                                ImageSource.camera);
                                          },
                                        ),
                                        ListTile(
                                          leading:
                                              const Icon(Icons.photo_library, color: Colors.redAccent),
                                          title:
                                              const Text('Choose from Gallery'),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await _pickImage(
                                                ImageSource.gallery);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
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
                                          "Upload File *",
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

                          //Terms and Condition
                          Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Obx(() => Checkbox(
                                      value: regiController.isChecked.value,
                                      onChanged: regiController.toggleCheckbox,
                                    )),
                                Text(
                                  'Accept Terms and Condition ',
                                  style: TextStyleClass.red12style,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      String hintText, String validationMessage,
      {bool obscureText = false, bool readOnly = false}) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        style: const TextStyle(color: Colors.black), // Text color set to black
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: Colors.black), // Label text color set to black
          hintText: hintText,
          hintStyle: const TextStyle(
              color: Colors.black54), // Slightly dimmed black for hint text
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
      regiController.userdocumentImage.value = pickedFile!.path.toString();
    }
  }
}
