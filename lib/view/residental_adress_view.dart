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

import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/register/register_view_model.dart';


class PesidentalAdressView extends StatefulWidget {
  const PesidentalAdressView({super.key});

  @override
  State<PesidentalAdressView> createState() => _PesidentalAdressViewState();
}

class _PesidentalAdressViewState extends State<PesidentalAdressView> {
  String? _selectedDocs;
  final regiController = Get.put(RegisterController());

  File? _image; // Store the selected image
  final ImagePicker _picker = ImagePicker();
  int activeStep2 = 2;
  var fal=false.obs;
  List<XFile>? _mediaFileList;
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
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.zero, // No margin applied
                      child: Align(
                        alignment: Alignment
                            .topCenter, // Align the child to the top-left corner
                        child: Image.asset(
                          'assets/images/logo.png', // Replace with your actual image path
                          width: 100, // Set the image width to 100
                          height: 100, // Set the image height to 100
                          fit: BoxFit
                              .cover, // Ensure the image covers the container area
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(AppConstants.welcome_mpm,
                          style: TextStyleClass.black20style),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      'New Membership',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold, // Change this to your desired size
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
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
                                            print("fghjjhjjh" +
                                                regiController
                                                    .pincodeController.value.text);
                                            if (regiController.pincodeController.value.text !=
                                                '') {
                                              var pincode = regiController.pincodeController.value.text;
                                              regiController.zoneController.value.text="";
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
                              Obx((){
                                return Visibility(
                                    visible: regiController.MandalZoneFlag.value,
                                    child:  Column(
                                      children: [
                                        const SizedBox(height: 20),
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
                                                Obx(() {
                                                  if (regiController.rxStatusBuilding.value ==
                                                      Status.LOADING) {
                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                          vertical: 8, horizontal: 20),
                                                      child: Container(
                                                        alignment: Alignment.centerRight,
                                                        height: 20,
                                                        width: 20,
                                                        child: CircularProgressIndicator(
                                                          color: ColorHelperClass
                                                              .getColorFromHex(
                                                              ColorResources.pink_color),
                                                        ),
                                                      ),
                                                    );
                                                  } else if (regiController
                                                      .rxStatusBuilding.value ==
                                                      Status.ERROR) {
                                                    return const Center(
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              vertical: 13, horizontal: 20),
                                                          child: Text(
                                                              'Failed to load Building Name'),
                                                        ));
                                                  } else if (regiController
                                                      .rxStatusBuilding.value ==
                                                      Status.IDLE) {
                                                    return const Center(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(12.0),
                                                        child: Text('Building Name *'),
                                                      ),
                                                    );
                                                  } else if (regiController
                                                      .checkPinCodeList.isEmpty) {
                                                    return const Center(
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              vertical: 13, horizontal: 24),
                                                          child:
                                                          Text('No Building Name available'),
                                                        ));
                                                  } else {
                                                    return Expanded(
                                                      child: DropdownButton<String>(
                                                        padding: const EdgeInsets.symmetric(
                                                            vertical: 8, horizontal: 20),
                                                        isExpanded: true,
                                                        underline: Container(),
                                                        hint: const Text(
                                                          'Select Building Name',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                        value: regiController
                                                            .selectBuilding.value.isEmpty
                                                            ? null
                                                            : regiController
                                                            .selectBuilding.value,
                                                        items: regiController.checkPinCodeList
                                                            .map((Building marital) {
                                                          return DropdownMenuItem<String>(
                                                            value: marital.id.toString(),
                                                            child: Text(
                                                                marital.buildingName ??
                                                                    'Unknown'),
                                                          );
                                                        }).toList(),
                                                        onChanged: (String? newValue) {
                                                          if (newValue != null) {
                                                            regiController
                                                                .selectBuilding(newValue);
                                                            regiController.isBuilding.value =
                                                                newValue == 'other';
                                                          }
                                                        },
                                                      ),
                                                    );
                                                  }
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
                                                          }
                                                          return null;
                                                        },
                                                        decoration: InputDecoration(
                                                          hintText: 'Building Name',
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(5),
                                                            borderSide: BorderSide(
                                                                color: Colors.grey),
                                                          ),
                                                          contentPadding:
                                                          const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                              horizontal: 20),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        _buildEditableField(
                                            "Mandal Zone *",
                                            regiController.zoneController.value,
                                            "Mandal Zone *",
                                            "",
                                            readonly: true
                                        ),
                                      ],
                                    ));
                              }),
                              const SizedBox(height: 20),

                              // Flat No
                              _buildEditableField(
                                'Flat No *',
                                regiController.housenoController.value,
                                'Enter Flat No',
                                '',
                              ),

                              const SizedBox(height: 20),
                              _buildEditableField(
                                'Address *',
                                regiController.addressMemberController.value,
                                'Enter Address',
                                '',
                              ),
                              const SizedBox(height: 20),

                              // Area
                              _buildEditableField(
                                'Area *',
                                regiController.areaController.value,
                                'Enter Area Name',
                                '',
                              ),
                              Obx((){
                                return Visibility(
                                    visible: regiController.countryNotFound.value,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        _buildEditableField(
                                            'City *',
                                            regiController.cityController.value,
                                            'Enter City Name',

                                            '',
                                            readonly: true
                                        ),
                                        const SizedBox(height: 20),

                                        //State
                                        SizedBox(
                                          width: double.infinity,
                                          child: _buildEditableField(
                                              'State *',
                                              regiController.stateController.value,
                                              'Enter State Name',
                                              '',
                                              readonly: true
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Country
                                        SizedBox(
                                          width: double.infinity,
                                          child: _buildEditableField(
                                              'Country *',
                                              regiController.countryController.value,
                                              'Enter Country Name',
                                              '',
                                              readonly: true
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

                              //MemberShip
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(left: 5, right: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    Obx(() {
                                      if(regiController.withoutcheckotp.value==false)
                                      {

                                      }
                                      else
                                      {
                                        if(fal.value==false)
                                        {
                                          regiController.getMemberShip();
                                          fal.value=true;
                                        }

                                      }
                                      if (regiController.rxStatusMemberShipTYpe.value ==
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
                                                    ColorResources.red_color),
                                              )),
                                        );
                                      } else if (regiController
                                          .rxStatusMemberShipTYpe.value ==
                                          Status.ERROR) {
                                        return const Center(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 13, horizontal: 20),
                                              child: Text(' No Data'),
                                            ));
                                      } else if (regiController
                                          .memberShipList.isEmpty) {
                                        return const Center(
                                            child:
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 13, horizontal: 20),
                                              child: Text('No  Membership available'),
                                            ));
                                      } else {
                                        return Expanded(
                                          child: DropdownButton<String>(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            isExpanded: true,
                                            underline: Container(),
                                            hint: const Text(
                                              'MemberShip *',
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
                                                child: Text("" +
                                                    marital.membershipName
                                                        .toString() +
                                                    "- " +
                                                    "Rs " +
                                                    marital.price
                                                        .toString()), // Display name from DataX.
                                              );
                                            }).toList(), // Convert to List.
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                regiController.selectMemberShipType(newValue);
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

                              //Address Proof
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(left: 5, right: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
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
                                                color: ColorHelperClass
                                                    .getColorFromHex(
                                                    ColorResources.red_color),
                                              )),
                                        );
                                      } else if (regiController
                                          .rxStatusDocument.value ==
                                          Status.ERROR) {
                                        return const Center(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 22),
                                              child: Text(' No Data'),
                                            ));
                                      } else if (regiController
                                          .documntTypeList.isEmpty) {
                                        return const Center(
                                            child: Text(
                                                'No  Address Proof available'));
                                      } else {
                                        return Expanded(
                                          child: DropdownButton<String>(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            isExpanded: true,
                                            underline: Container(),
                                            hint: const Text(
                                              'Address Proof *',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ), // Hint to show when nothing is selected
                                            value: regiController.selectDocumentType.value.isEmpty ? null
                                                : regiController.selectDocumentType.value,

                                            items: regiController.documntTypeList
                                                .map((DocumentTypeData marital) {
                                              return DropdownMenuItem<String>(
                                                value: marital.id
                                                    .toString(), // Use unique ID or any unique property.
                                                child: Text(marital.documentType.toString() ??
                                                    'Unknown'), // Display name from DataX.
                                              );
                                            }).toList(), // Convert to List.
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                regiController.setDocumentType(newValue);

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
                              const SizedBox(height: 40),
                            ],
                          )),
                    ),
                  ))
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
      String validationMessage, {
        bool obscureText = false,
        bool readonly= false
      }) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: controller,
        obscureText: obscureText,
        readOnly: readonly,
        style: const TextStyle(color: Colors.black), // Text color set to black
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: Colors.black), // Label text color set to black
          hintText: hintText,
          hintStyle: const TextStyle(
              color: Colors.black54), // Slightly dimmed black for hint text
          border: const OutlineInputBorder(
            borderSide:
            BorderSide(color: Colors.grey), // Border color set to black
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.grey), // Border when field is not focused
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.grey, width: 0.5), // Thicker border when focused
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
      regiController.userdocumentImage.value=pickedFile!.path.toString();
    }
  }

}
