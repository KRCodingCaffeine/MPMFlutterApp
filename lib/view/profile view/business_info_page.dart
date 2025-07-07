import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/OccuptionProfession/OccuptionProfessionData.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CountryModel/CountryData.dart';
import 'package:mpm/model/GetProfile/BusinessInfo.dart';
import 'package:mpm/model/Occupation/OccupationData.dart';
import 'package:mpm/model/OccupationSpec/OccuptionSpecData.dart';
import 'package:mpm/model/State/StateData.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

import 'occupation_info_view.dart';

class BusinessInformationPage extends StatefulWidget {
  final String? successMessage;
  final String? failureMessage;

  const BusinessInformationPage(
      {Key? key, this.successMessage, this.failureMessage})
      : super(key: key);

  @override
  _BusinessInformationPageState createState() =>
      _BusinessInformationPageState();
}

class _BusinessInformationPageState extends State<BusinessInformationPage> {
  // Variables to store occupation-related information
  String occupation = "";
  String occupationProfession = "";
  String occupationSpecialization = "";
  String occupationDetails = "";
  NewMemberController regiController = Get.put(NewMemberController());
  UdateProfileController controller = Get.put(UdateProfileController());
  final GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyLogin2 = GlobalKey<FormState>();
  @override
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
              "Occupation Info",
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Occupation Details Section
            GestureDetector(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      "Occupation Details",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      thickness: 1.0,
                      color: Color(
                          0xFFE0E0E0), // Equivalent to Colors.grey.shade300
                    ),
                  ),
                  _buildOccInfo(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row with "Business / Employment Details" and Add Button (conditionally visible)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Business / Employment Details',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showAddModalSheet(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFDC3545),
                          elevation: 4,
                          shadowColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, size: 12),
                            const SizedBox(width: 4),
                            const Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    thickness: 1.0,
                    color: Color(0xFFE0E0E0), // Equivalent to Colors.grey.shade300
                  ),
                ),

                // Business Info List
                Obx(() {
                  if (controller.businessInfoList.value.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "No Employment Details, Please add by clicking Add Employment Button.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.businessInfoList.value.length,
                    itemBuilder: (context, index) => _buildBusinessInfoCard(
                      bussinessinfo: controller.businessInfoList.value[index],
                    ),
                  );
                }),

                const SizedBox(height: 20),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showAddModalSheet(BuildContext context) {
    double heightFactor = 0.8; // Default height for the modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: heightFactor,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom, // Adjust for keyboard
              ),
              child: SafeArea(
                child: FractionallySizedBox(
                  heightFactor: heightFactor,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFDC3545),
                                elevation: 4,
                                shadowColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Obx(() {
                              return ElevatedButton(
                                onPressed: () {
                                  if (_formKeyLogin.currentState!.validate()) {
                                    if (regiController.city_id.value == "") {
                                      Get.snackbar(
                                        "Error",
                                        "Please Select City",
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.TOP,
                                      );
                                      return;
                                    }
                                    if (regiController.state_id.value == "") {
                                      Get.snackbar(
                                        "Error",
                                        "Please Select State",
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.TOP,
                                      );
                                      return;
                                    }
                                    if (regiController.country_id.value == "") {
                                      Get.snackbar(
                                        "Error",
                                        "Please Select Country",
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.TOP,
                                      );
                                      return;
                                    }

                                    controller.userAddBuniessInfo();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFDC3545),
                                  elevation: 4,
                                  shadowColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                ),
                                child: controller.addBussinessLoading.value
                                    ? const CircularProgressIndicator(
                                  color: Colors.red,
                                )
                                    : const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController, // Make it scrollable
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKeyLogin,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() {
                                  return _buildEditableField(
                                      'Organisation Name',
                                      controller
                                          .organisationNameController.value,
                                      'Organisation Name', // Hint Text
                                      'Enter Organisation Name',
                                      text: TextInputType.text,
                                      isRequired: true);
                                }),
                                Obx(() {
                                  return _buildEditableField(
                                      'Office Phone',
                                      controller.officePhoneController.value,
                                      'Office Phone',
                                      'Enter Office Phone',
                                      text: TextInputType.phone,
                                      isRequired: true);
                                }),
                                Obx(() {
                                  return _buildEditableField(
                                      'Office No',
                                      controller.flatnoController.value,
                                      'Office No',
                                      'Enter Office No',
                                      text: TextInputType.text,
                                      isRequired: true);
                                }),
                                Obx(() {
                                  return _buildEditableField(
                                      'Address',
                                      controller
                                          .addressbusinessinfoNameController
                                          .value,
                                      'Address',
                                      'Enter Address',
                                      text: TextInputType.text,
                                      isRequired: true);
                                }),
                                Obx(() {
                                  return _buildEditableField(
                                      'Area',
                                      controller.areaNameController.value,
                                      'Area',
                                      'Enter Area',
                                      text: TextInputType.text,
                                      isRequired: true);
                                }),

                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Obx(() {
                                        if (regiController
                                                .rxStatusCityLoading.value ==
                                            Status.LOADING) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 22),
                                            child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: ColorHelperClass
                                                      .getColorFromHex(
                                                          ColorResources
                                                              .pink_color),
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
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                labelText: 'City *',
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black26),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black26),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black26, width: 1.5),
                                                ),
                                                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                                labelStyle: TextStyle(
                                                  color: Colors.black45,
                                                ),
                                              ),
                                              isEmpty: regiController.city_id.value.isEmpty,
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  dropdownColor: Colors.white, // White background for dropdown list
                                                  borderRadius: BorderRadius.circular(10),
                                                  isExpanded: true,
                                                  hint: const Text(
                                                    'Select City *',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  value: regiController.city_id.value.isEmpty
                                                      ? null
                                                      : regiController.city_id.value,
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
                                            ),
                                          );
                                        }
                                      })
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),

                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Obx(() {
                                        if (regiController.rxStatusStateLoading.value == Status.LOADING) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 22),
                                            child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: ColorHelperClass
                                                      .getColorFromHex(
                                                          ColorResources
                                                              .pink_color),
                                                )),
                                          );
                                        } else if (regiController.rxStatusStateLoading.value == Status.ERROR) {
                                          return const Center(
                                              child: Text('Failed to load state'));
                                        } else if (regiController
                                            .stateList.isEmpty) {
                                          return const Center(
                                              child: Text('No State available'));
                                        } else {
                                          return Expanded(
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                labelText: 'State *',
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black26),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black26),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black26, width: 1.5),
                                                ),
                                                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                                labelStyle: TextStyle(
                                                  color: Colors.black45,
                                                ),
                                              ),
                                              isEmpty: regiController.state_id.value.isEmpty,
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  dropdownColor: Colors.white, // White background for dropdown list
                                                  borderRadius: BorderRadius.circular(10),
                                                  isExpanded: true,
                                                  hint: const Text(
                                                    'Select State *',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  value: regiController.state_id.value.isEmpty
                                                      ? null
                                                      : regiController.state_id.value,
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
                                            ),
                                          );
                                        }
                                      })
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),

                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Obx(() {
                                        if (regiController.rxStatusCountryLoading.value == Status.LOADING) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 22),
                                            child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: ColorHelperClass
                                                      .getColorFromHex(
                                                          ColorResources
                                                              .pink_color),
                                                )),
                                          );
                                        } else if (regiController.rxStatusCountryLoading.value ==
                                            Status.ERROR) {
                                          return const Center(
                                              child: Text(
                                                  'Failed to load country'));
                                        } else if (regiController.countryList.isEmpty) {
                                          return const Center(
                                              child:
                                                  Text('No Country available'));
                                        } else {
                                          return Expanded(
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                labelText: 'Country *',
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black26),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black26),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black26, width: 1.5),
                                                ),
                                                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                                labelStyle: TextStyle(
                                                  color: Colors.black45,
                                                ),
                                              ),
                                              isEmpty: regiController.country_id.value.isEmpty,
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  dropdownColor: Colors.white, // Ensures white dropdown background
                                                  borderRadius: BorderRadius.circular(10),
                                                  isExpanded: true,
                                                  hint: const Text(
                                                    'Select Country *',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  value: regiController.country_id.value.isEmpty
                                                      ? null
                                                      : regiController.country_id.value,
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
                                            ),
                                          );
                                        }
                                      })
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),

                                Obx(() {
                                  return _buildEditableField(
                                      'Office Pincode',
                                      controller.officePincodeController.value,
                                      'Office Pincode',
                                      'Office Pincode',
                                      text: TextInputType.number,
                                      isRequired: true);
                                }),
                                Obx(() {
                                  return _buildEditableField(
                                      'Business Email',
                                      controller.businessEmailController.value,
                                      'Business Email',
                                      'Enter Business Email',
                                      text: TextInputType.emailAddress,
                                      isRequired: true);
                                }),
                                Obx(() {
                                  return _buildEditableField(
                                    'Website',
                                    controller.websiteController.value,
                                    'Website',
                                    'Enter Website',
                                    text: TextInputType.text,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    String hintText,
    String validationMessage, {
    bool obscureText = false,
    required TextInputType text,
    bool isRequired = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: TextFormField(
        keyboardType: text,
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black45),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black26),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black26),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black26, width: 1.0),
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return validationMessage;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildBusinessInfoCard({required BusinessInfo bussinessinfo}) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    bussinessinfo.organisationName ?? '', // Use null-aware operator
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Prevents overflow
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showEditModalSheet(context, bussinessinfo);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFDC3545),
                    elevation: 4,
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.edit, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(color: Color(0xFFE0E0E0)), // Black divider
            const SizedBox(height: 10),

            // Address
            if ((bussinessinfo.flatNo ?? '').isNotEmpty &&
                (bussinessinfo.address ?? '').isNotEmpty)
              Text(
                "${bussinessinfo.flatNo}, ${bussinessinfo.address}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            if ((bussinessinfo.flatNo ?? '').isNotEmpty &&
                (bussinessinfo.address ?? '').isNotEmpty)
              const SizedBox(height: 10),

            // City, State - Pincode
            if ((bussinessinfo.cityName ?? '').isNotEmpty &&
                (bussinessinfo.stateName ?? '').isNotEmpty &&
                (bussinessinfo.pincode ?? '').isNotEmpty)
              Text(
                "${bussinessinfo.cityName}, ${bussinessinfo.stateName} - ${bussinessinfo.pincode}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            if ((bussinessinfo.cityName ?? '').isNotEmpty &&
                (bussinessinfo.stateName ?? '').isNotEmpty &&
                (bussinessinfo.pincode ?? '').isNotEmpty)
              const SizedBox(height: 10),

            // Phone Number
            if ((bussinessinfo.officePhone ?? '').isNotEmpty)
              Text(
                "📞 ${bussinessinfo.officePhone}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            if ((bussinessinfo.officePhone ?? '').isNotEmpty) const SizedBox(height: 10),

            // Email
            if ((bussinessinfo.businessEmail ?? '').isNotEmpty)
              Text(
                "✉ ${bussinessinfo.businessEmail}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            if ((bussinessinfo.businessEmail ?? '').isNotEmpty) const SizedBox(height: 10),

            // Website
            if ((bussinessinfo.website ?? '').isNotEmpty)
              Text(
                "🌐 ${bussinessinfo.website}",
                style: const TextStyle(fontSize: 14, color: Colors.blue),
              ),
            if ((bussinessinfo.website ?? '').isNotEmpty) const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showEditModalSheet(BuildContext context, BusinessInfo bussinessinfo) {
    double heightFactor = 0.8;
    controller.udorganisationNameController.value.text =
        bussinessinfo.organisationName.toString();
    controller.udofficePhoneController.value.text =
        bussinessinfo.officePhone.toString();
    controller.udflatnoController.value.text = bussinessinfo.flatNo.toString();
    controller.upaddressbusinessinfoNameController.value.text =
        bussinessinfo.address.toString();
    controller.udareaNameController.value.text =
        bussinessinfo.areaName.toString();
    controller.udofficePincodeController.value.text =
        bussinessinfo.pincode.toString();
    controller.udbusinessEmailController.value.text =
        bussinessinfo.businessEmail.toString();
    controller.upwebsiteController.value.text =
        bussinessinfo.website.toString();
    regiController.city_id.value = bussinessinfo.cityId.toString();
    regiController.state_id.value = bussinessinfo.stateId.toString();
    regiController.country_id.value = bussinessinfo.countryId.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          ),
          child: SafeArea(
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0), // Padding at the top
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFDC3545),
                              elevation: 4,
                              shadowColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Obx(() {
                            return ElevatedButton(
                              onPressed: () {
                                controller.userUpdateBuniessInfo(bussinessinfo);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFDC3545),
                                elevation: 4,
                                shadowColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 8),
                              ),
                              child: controller.addloading.value
                                  ? const CircularProgressIndicator(
                                color: Colors.red,
                              )
                                  : const Text(
                                'Update',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            return _buildEditableField(
                              'Organisation Name',
                              controller.udorganisationNameController.value,
                              "Organisation Name",
                              "Enter Organisation Name",
                              text: TextInputType.text,
                            );
                          }),
                          Obx(() {
                            return _buildEditableField(
                              'Office Phone',
                              controller.udofficePhoneController.value,
                              "Office Phone",
                              "Office Phone",
                              text: TextInputType.phone,
                            );
                          }),
                          Obx(() {
                            return _buildEditableField(
                              'Address',
                              controller
                                  .upaddressbusinessinfoNameController.value,
                              "Address Name",
                              "Address Name",
                              text: TextInputType.text,
                            );
                          }),
                          Obx(() {
                            return _buildEditableField(
                              'Office No',
                              controller.udflatnoController.value,
                              'Office No',
                              'Office No',
                              text: TextInputType.text,
                            );
                          }),
                          Obx(() {
                            return _buildEditableField(
                              'Area',
                              controller.udareaNameController.value,
                              'Area',
                              'Area',
                              text: TextInputType.text,
                            );
                          }),

                          // City
                          Container(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Obx(() {
                                  if (regiController
                                      .rxStatusCityLoading.value ==
                                      Status.LOADING) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 22),
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
                                  } else if (regiController.cityList.isEmpty) {
                                    return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('No City available'),
                                        ));
                                  } else {
                                    return Expanded(
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'City',
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black26),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black26),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black26, width: 1.5),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                          labelStyle: TextStyle(
                                            color: Colors.black45,
                                          ),
                                        ),
                                        isEmpty: regiController.city_id.value.isEmpty,
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            dropdownColor: Colors.white, // Ensures dropdown list background is white
                                            borderRadius: BorderRadius.circular(10),
                                            isExpanded: true,

                                            value: regiController.city_id.value.isEmpty
                                                ? null
                                                : regiController.city_id.value,
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
                                      ),
                                    );
                                  }
                                })
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // State
                          Container(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Obx(() {
                                  if (regiController
                                          .rxStatusStateLoading.value ==
                                      Status.LOADING) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 24),
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
                                  } else if (regiController.stateList.isEmpty) {
                                    return const Center(
                                        child: Text('No State available'));
                                  } else {
                                    return Expanded(
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'State *',
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black26),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black26),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black26, width: 1.5),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                          labelStyle: TextStyle(
                                            color: Colors.black45,
                                          ),
                                        ),
                                        isEmpty: regiController.state_id.value.isEmpty,
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            dropdownColor: Colors.white, // Dropdown list background is white
                                            borderRadius: BorderRadius.circular(10),
                                            isExpanded: true,

                                            value: regiController.state_id.value.isEmpty ? null
                                                : regiController.state_id.value,
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
                                      ),
                                    );
                                  }
                                })
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Country
                          Container(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Obx(() {
                                  if (regiController.rxStatusCountryLoading.value == Status.LOADING) {
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
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'Country *',
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black26),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black26),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black26, width: 1.5),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                          labelStyle: TextStyle(
                                            color: Colors.black45,
                                          ),
                                        ),
                                        isEmpty: regiController.country_id.value.isEmpty,
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            dropdownColor: Colors.white, // White background for dropdown list
                                            borderRadius: BorderRadius.circular(10),
                                            isExpanded: true,
                                            hint: const Text(
                                              'Select Country *',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            value: regiController.country_id.value.isEmpty
                                                ? null
                                                : regiController.country_id.value,
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
                                      ),
                                    );
                                  }
                                })
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          Obx(() {
                            return _buildEditableField(
                              'Office Pincode',
                              controller.udofficePincodeController.value,
                              "Office Pincode",
                              "Office Pincode",
                              text: TextInputType.number,
                            );
                          }),
                          Obx(() {
                            return _buildEditableField(
                                'Business Email',
                                controller.udbusinessEmailController.value,
                                "Business Email",
                                "Business Email",
                                text: TextInputType.emailAddress);
                          }),
                          Obx(() {
                            return _buildEditableField(
                              'Website',
                              controller.upwebsiteController.value,
                              "Website",
                              "Website",
                              text: TextInputType.text,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoLine(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
        children: [
          // Title and Colon
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
          // Subtitle
          Expanded(
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditOccBottomSheet(BuildContext context) {

    final hasExistingData = controller.currentOccupation.value != null;

    if (hasExistingData) {
      controller.initOccupationData(controller.currentOccupation.value);
    } else {
      controller.resetDependentFields();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[100],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 30),
              // Buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                      ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.addAndupdateOccuption();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(hasExistingData ? "Save" : "Add"),
                  ),
                ],
              ),
              const SizedBox(height: 30),

          // Occupation Dropdown (always visible)
          _buildOccupationDropdown(context),
          const SizedBox(height: 20),

          // Profession Dropdown (conditionally visible)
          Obx(() {
            if (controller.selectedOccupation.value.isEmpty ||
                controller.selectedOccupation.value == "Other") {
              return const SizedBox();
            }
            return _buildProfessionDropdown(context);
          }),
          const SizedBox(height: 20),

          // Specialization Dropdown (conditionally visible)
          Obx(() {
            if (controller.selectedProfession.value.isEmpty ||
                controller.selectedProfession.value == "Other") {
              return const SizedBox();
            }
            return _buildSpecializationDropdown(context);
          }),
          const SizedBox(height: 20),

          // Details Field (conditionally visible)
          Obx(() {
            if (!controller.showDetailsField.value) return const SizedBox();
            return _buildDetailsField(context);
          }),
          ],
          ),
        );
      },
    );
  }

  Widget _buildOccupationDropdown(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Row(
        children: [
          Obx(() {
            if (controller.rxStatusOccupation.value == Status.LOADING) {
              return _buildLoadingIndicator();
            } else if (controller.rxStatusOccupation.value == Status.ERROR) {
              return const Center(child: Text('Failed to load occupation'));
            } else if (controller.occuptionList.isEmpty) {
              return const Center(child: Text('No occupation available'));
            } else {
              return Expanded(
                child: InputDecorator(
                  decoration: _inputDecoration('Occupation *'),
                  isEmpty: controller.selectedOccupation.isEmpty,
                  child: DropdownButton<String>(
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    isExpanded: true,
                    underline: Container(),
                    value: controller.selectedOccupation.value.isEmpty
                        ? null
                        : controller.selectedOccupation.value,
                    items: controller.occuptionList.map((OccupationData occupation) {
                      return DropdownMenuItem<String>(
                        value: occupation.id.toString(),
                        child: Text(occupation.occupation ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedOccupation.value = newValue;
                        controller.resetDependentFields();

                        if (newValue == "0") {
                          controller.showDetailsField.value = true;
                        } else {
                          controller.showDetailsField.value = false;
                          controller.getOccupationProData(newValue);
                        }
                      }
                    },
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildProfessionDropdown(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Row(
        children: [
          Obx(() {
            if (controller.rxStatusOccupationData.value == Status.LOADING) {
              return _buildLoadingIndicator();
            } else if (controller.rxStatusOccupationData.value == Status.ERROR) {
              return const Center(child: Text('Failed to load profession'));
            } else if (controller.occuptionProfessionList.isEmpty) {
              // If no professions available, show details field
              controller.showDetailsField.value = true;
              return const SizedBox();
            } else {
              return Expanded(
                child: InputDecorator(
                  decoration: _inputDecoration('Occupation Profession *'),
                  isEmpty: controller.selectedProfession.isEmpty,
                  child: DropdownButton<String>(
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    isExpanded: true,
                    underline: Container(),
                    value: controller.selectedProfession.isEmpty ? null : controller.selectedProfession.value,
                    items: controller.occuptionProfessionList.map((OccuptionProfessionData profession) {
                      return DropdownMenuItem<String>(
                        value: profession.id.toString(),
                        child: Text(profession.name ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedProfession.value = newValue;
                        controller.selectedSpecialization.value = '';

                        if (newValue == "Other") {
                          controller.showDetailsField.value = true;
                        } else {
                          controller.showDetailsField.value = false;
                          controller.getOccupationSpectData(newValue);
                        }
                      }
                    },
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSpecializationDropdown(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Row(
        children: [
          Obx(() {
            if (controller.rxStatusOccupationSpec.value == Status.LOADING) {
              return _buildLoadingIndicator();
            } else if (controller.rxStatusOccupationSpec.value == Status.ERROR) {
              return const Center(child: Text('Failed to load specialization'));
            } else if (controller.occuptionSpeList.isEmpty) {
              // If no specializations available, show details field
              controller.showDetailsField.value = true;
              return const SizedBox();
            } else {
              return Expanded(
                child: InputDecorator(
                  decoration: _inputDecoration('Occupation Specialization'),
                  isEmpty: controller.selectedSpecialization.isEmpty,
                  child: DropdownButton<String>(
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    isExpanded: true,
                    underline: Container(),
                    value: controller.selectedSpecialization.isEmpty ? null : controller.selectedSpecialization.value,
                    items: controller.occuptionSpeList.map((OccuptionSpecData specialization) {
                      return DropdownMenuItem<String>(
                        value: specialization.id.toString(),
                        child: Text(specialization.name ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedSpecialization.value = newValue;
                        controller.showDetailsField.value = (newValue == "Other");
                      }
                    },
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildDetailsField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Details',
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black26),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black26),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black26, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          labelStyle: TextStyle(
            color: Colors.black45,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Container(
        alignment: Alignment.centerRight,
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      labelStyle: TextStyle(
        color: Colors.black45,
      ),
    );
  }

  Widget _buildOccInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (controller.hasOccupationData.value)
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() {
                                  return _buildInfoLine(
                                      'Occupation',
                                      controller
                                          .occupationController.value.text);
                                }),
                                Obx(() {
                                  return _buildInfoLine(
                                      'Profession',
                                      controller
                                          .occupation_profession_nameController
                                          .value
                                          .text);
                                }),
                                Obx(() {
                                  return _buildInfoLine(
                                      'Specialization',
                                      controller.specialization_nameController
                                          .value.text);
                                }),
                                Obx(() {
                                  return _buildInfoLine('Details',
                                      controller.detailsController.value.text);
                                }),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showEditOccBottomSheet(context),
                            icon: const Icon(Icons.edit,
                                size: 12, color: Colors.red),
                            label: const Text(
                              "Edit",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFDC3545),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                              shadowColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            else
              return Column(
                children: [
                  const Text(
                    "No Occupation Detail, Please add by clicking Add Occupation Button",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  TextButton.icon(
                    onPressed: () => _showEditOccBottomSheet(context),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.red,
                    ),
                    label: const Text(
                      "Add Occupation",
                      style: TextStyle(color: Colors.red),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors
                          .red, // Ensures the text and icon stay red when pressed
                    ),
                  ),
                ],
              );
          })
        ],
      ),
    );
  }
}

// class _EditOccInfoContent extends StatefulWidget {
//   final String occupation;
//   final String occupationProfession;
//   final String occupationSpecialization;
//   final String occupationDetails;
//   final Function(String, String, String, String) onOccInfoChanged;
//
//   _EditOccInfoContent({
//     required this.occupation,
//     required this.occupationProfession,
//     required this.occupationSpecialization,
//     required this.occupationDetails,
//     required this.onOccInfoChanged,
//   });
//
//   @override
//   _EditOccInfoContentState createState() => _EditOccInfoContentState();
// }
//
// class _EditOccInfoContentState extends State<_EditOccInfoContent> {
//
//
//   UdateProfileController controller = Get.put(UdateProfileController());
//   @override
//   void initState() {
//     super.initState();
//     controller.detailsController.value.text = widget.occupationDetails;
//   }
//
//   void _saveChanges() {
//
//     controller.addAndupdateOccuption();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return SafeArea(
//       child: Container(
//         height: screenHeight * 0.8,
//         child: FractionallySizedBox(
//           widthFactor: 1.0, // Takes full width
//           heightFactor: 1.0, // Takes full height of the Container
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 const SizedBox(height: 30),
//                 // Row for Save & Cancel buttons at the top
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Cancel Button (Left)
//                       TextButton(
//                         onPressed: () => Navigator.pop(context), // Close the BottomSheet
//                         style: TextButton.styleFrom(
//                           backgroundColor: Colors.white, // Matches ElevatedButton
//                           foregroundColor: const Color(0xFFDC3545), // Red text color
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           elevation: 4, // Adds shadow like ElevatedButton
//                           shadowColor: Colors.black,
//                         ),
//                         child: const Text(
//                           'Cancel',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//
//                       // Save Button (Right)
//                       TextButton(
//                         onPressed: _saveChanges,
//                         style: TextButton.styleFrom(
//                           backgroundColor: Colors.white, // Matches ElevatedButton
//                           foregroundColor: const Color(0xFFDC3545), // Red text color
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           elevation: 4, // Adds shadow like ElevatedButton
//                           shadowColor: Colors.black,
//                         ),
//                         child: const Text(
//                           'Save',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             width: double.infinity,
//                             child: Container(
//                               margin: EdgeInsets.only(left: 5, right: 5),
//                               child: Row(
//                                 children: [
//                                   Obx(() {
//                                     if (controller.rxStatusOccupation.value == Status.LOADING) {
//                                       return Padding(
//                                         padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
//                                         child: Container(
//                                           alignment: Alignment.centerRight,
//                                           height: 24,
//                                           width: 24,
//                                           child: CircularProgressIndicator(
//                                             color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
//                                           ),
//                                         ),
//                                       );
//                                     } else if (controller.rxStatusOccupation.value == Status.ERROR) {
//                                       return Center(
//                                           child: Container(
//                                         width: double.infinity,
//                                         decoration: BoxDecoration(
//                                           color: Colors.black26, // Background color
//                                           borderRadius: BorderRadius.circular(20), // Rounded corners
//                                           border: Border.all(
//                                             color: Colors.black26, // Border color
//                                             width: 1.5, // Border width
//                                           ),
//                                         ),
//
//                                         child: Text('Failed to load occupation'),
//                                       ));
//                                     } else if (controller.occuptionList.value.isEmpty) {
//                                       return Center(child: Text('No occupation available'));
//                                     } else {
//                                       return Expanded(
//                                         child: InputDecorator(
//                                           decoration: InputDecoration(
//                                             labelText: 'Occupation *',
//                                             border: OutlineInputBorder(
//                                               borderSide: BorderSide(color: Colors.black26),
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderSide: BorderSide(color: Colors.black26),
//                                             ),
//                                             focusedBorder: OutlineInputBorder(
//                                               borderSide: BorderSide(color: Colors.black26, width: 1.5),
//                                             ),
//                                             contentPadding: EdgeInsets.symmetric(horizontal: 20),
//                                             labelStyle: TextStyle(
//                                               color: Colors.black45,
//                                             ),
//                                           ),
//                                           isEmpty: controller.selectOccuption.value.isEmpty,
//                                           child: DropdownButton<String>(
//                                             dropdownColor: Colors.white,
//                                             borderRadius: BorderRadius.circular(10),
//                                             isExpanded: true,
//                                             underline: Container(), // Removes the default underline
//                                             // hint: const Text(
//                                             //   'Select Occupation',
//                                             //   style: TextStyle(fontWeight: FontWeight.bold),
//                                             // ),
//                                             value: controller.selectOccuption.value.isEmpty ? null : controller.selectOccuption.value,
//                                             items: controller.occuptionList.value.map((OccupationData marital) {
//                                               return DropdownMenuItem<String>(
//                                                 value: marital.id.toString(),
//                                                 child: Text(marital.occupation ?? 'Unknown',),
//                                               );
//                                             }).toList(),
//                                             onChanged: (String? newValue) {
//                                               if (newValue != null) {
//                                                controller.selectOccuption.value=newValue;
//                                                 if (newValue != "other") {
//                                                   controller.occuptionFlag.value=false;
//                                                   controller.occupationProData.value=true;
//                                                   controller.getOccupationProData(newValue);
//                                                 } else {
//                                                   controller.occuptionFlag.value=true;
//                                                   controller.occupationProData.value=false;
//                                                 }
//                                               }
//                                             },
//                                           ),
//                                         ),
//                                       );
//                                     }
//                                   }),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 30),
//                           Obx(() {
//                             return Visibility(
//                               visible: controller.occupationProData.value,
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     width: double.infinity,
//                                     margin: EdgeInsets.only(left: 5, right: 5),
//                                     child: Row(
//                                       children: [
//                                         Obx(() {
//                                           if (controller.rxStatusOccupationData.value == Status.LOADING) {
//                                             return Padding(
//                                               padding: EdgeInsets.symmetric(vertical: 12, horizontal: 22),
//                                               child: Container(
//                                                 alignment: Alignment.centerRight,
//                                                 height: 24,
//                                                 width: 24,
//                                                 child: CircularProgressIndicator(
//                                                   color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
//                                                 ),
//                                               ),
//                                             );
//                                           }
//                                           else if (controller.rxStatusOccupationData.value == Status.ERROR) {
//                                             return Center(
//                                                 child: Container(
//                                                  width: MediaQuery.of(context).size.width*0.88,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius: BorderRadius.circular(10), // Rounded corners
//                                                   border: Border.all(
//                                                     color: Colors.black26, // Border color
//                                                     width: 0.9, // Border width
//                                                   ),
//                                                 ),
//                                                 padding: EdgeInsets.symmetric(horizontal: 28,vertical: 16),
//                                                 child: Text('Failed to load occupation Profession')));
//                                           } else if (controller.rxStatusOccupationData.value == Status.IDLE) {
//                                             return Center(
//                                               child: Padding(
//                                                 padding: const EdgeInsets.all(12.0),
//                                                 child: Text('Select Occupation Profession *'),
//                                               ),
//                                             );
//                                           } else if (controller.occuptionProfessionList.value.isEmpty) {
//                                             return Center(child: Text('No occupation Pro available'));
//                                           } else {
//                                             return Expanded(
//                                               child: InputDecorator(
//                                                 decoration: InputDecoration(
//                                                   labelText: 'Occupation Profession *',
//                                                   border: OutlineInputBorder(
//                                                     borderSide: BorderSide(color: Colors.black26),
//                                                   ),
//                                                   enabledBorder: OutlineInputBorder(
//                                                     borderSide: BorderSide(color: Colors.black26),
//                                                   ),
//                                                   focusedBorder: OutlineInputBorder(
//                                                     borderSide: BorderSide(color: Colors.black26, width: 1.5),
//                                                   ),
//                                                   contentPadding: EdgeInsets.symmetric(horizontal: 20),
//                                                   labelStyle: TextStyle(
//                                                     color: Colors.black45,
//                                                   ),
//                                                 ),
//                                                 isEmpty: controller.selectOccuptionPro.value.isEmpty,
//                                                 child: DropdownButton<String>(
//                                                   dropdownColor: Colors.white,
//                                                   borderRadius: BorderRadius.circular(10),
//                                                   isExpanded: true,
//                                                   underline: Container(), // Removes default underline
//
//
//                                                   value: controller.selectOccuptionPro.value.isEmpty
//                                                       ? null
//                                                       : controller.selectOccuptionPro.value,
//                                                   items: controller.occuptionProfessionList.value.map((OccuptionProfessionData profession) {
//                                                     return DropdownMenuItem<String>(
//                                                       value: profession.id.toString(),
//                                                       child: Text(profession.name ?? 'Unknown'),
//                                                     );
//                                                   }).toList(),
//                                                   onChanged: (String? newValue) {
//                                                     if (newValue != null) {
//                                                       controller.setSelectOccuptionPro(newValue);
//                                                       if (newValue != "other") {
//                                                         controller.occuptionFlag.value=false;
//                                                         controller.isOccuptionProData.value=true;
//                                                         controller.getOccupationSpectData(newValue);
//                                                       } else {
//                                                         controller.occuptionFlag.value=true;
//                                                         controller.isOccuptionProData.value=false;
//                                                       }
//
//                                                     }
//                                                   },
//                                                 ),
//                                               ),
//                                             );
//                                           }
//                                         }),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(height: 30),
//                                  Visibility(
//                                      visible: controller.isOccuptionProData.value,
//                                      child:  Container(
//                                    width: double.infinity,
//                                    margin: EdgeInsets.only(left: 5, right: 5),
//                                    child: Row(
//                                      children: [
//                                        Obx(() {
//                                          if (controller.rxStatusOccupationSpec.value == Status.LOADING) {
//                                            return Padding(
//                                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
//                                              child: Container(
//                                                alignment: Alignment.centerRight,
//                                                height: 24,
//                                                width: 24,
//                                                child: CircularProgressIndicator(
//                                                  color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
//                                                ),
//                                              ),
//                                            );
//                                          }
//                                          else if (controller.rxStatusOccupationSpec.value == Status.ERROR) {
//                                            return Center(
//                                              child: Text(
//                                                'Failed to load occupation specialization',
//                                                style: TextStyle(fontWeight: FontWeight.bold),
//                                              ),
//                                            );
//                                          }
//                                          else if (controller.rxStatusOccupationSpec.value == Status.IDLE) {
//                                            return Center(
//                                              child: Padding(
//                                                padding: const EdgeInsets.all(12.0),
//                                                child: Text(
//                                                  'Select Occupation specialization,',
//                                                  style: TextStyle(fontWeight: FontWeight.bold),
//                                                ),
//                                              ),
//                                            );
//                                          }
//                                          else if (controller.occuptionSpeList.value.isEmpty) {
//                                            return Center(child: Text('No occupation specialization available'));
//                                          } else {
//                                            return Expanded(
//                                              child: InputDecorator(
//                                                decoration: InputDecoration(
//                                                  labelText: 'Occupation Specialization',
//                                                  border: OutlineInputBorder(
//                                                    borderSide: BorderSide(color: Colors.black26),
//                                                  ),
//                                                  enabledBorder: OutlineInputBorder(
//                                                    borderSide: BorderSide(color: Colors.black26),
//                                                  ),
//                                                  focusedBorder: OutlineInputBorder(
//                                                    borderSide: BorderSide(color: Colors.black26, width: 1.5),
//                                                  ),
//                                                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
//                                                  labelStyle: TextStyle(
//                                                    color: Colors.black45,
//                                                  ),
//                                                ),
//                                                isEmpty: controller.selectOccuptionSpec.value.isEmpty,
//                                                child: DropdownButton<String>(
//                                                  dropdownColor: Colors.white,
//                                                  borderRadius: BorderRadius.circular(10),
//                                                  isExpanded: true,
//                                                  underline: Container(), // Removes default underline
//
//                                                  value: controller.selectOccuptionSpec.value.isEmpty ? null : controller.selectOccuptionSpec.value,
//                                                  items: controller.occuptionSpeList.value.map((OccuptionSpecData specialization) {
//                                                    return DropdownMenuItem<String>(
//                                                      value: specialization.id.toString(),
//                                                      child: Text(specialization.name ?? 'Unknown'),
//                                                    );
//                                                  }).toList(),
//                                                  onChanged: (String? newValue) {
//                                                    if (newValue != null) {
//                                                      controller.setSelectOccuptionSpec(newValue);
//
//                                                      if (newValue != "other") {
//                                                        controller.occuptionFlag.value=false;
//
//                                                      } else {
//                                                        controller.occuptionFlag.value=true;
//                                                      }
//                                                    }
//                                                  },
//                                                ),
//                                              ),
//                                            );
//                                          }
//                                        }),
//                                      ],
//                                    ),
//                                  )),
//                                 ],
//                               ),
//                             );
//                           }),
//                           //_buildInfoLine('Details', occupationDetails),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 30),
//                Obx((){
//                  return Visibility(
//                     visible: controller.occuptionFlag.value,
//                      child: _buildEditableField(
//                      label: 'Details',
//                      controller: controller.detailsController.value)
//                  );
//                }),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEditableField(
//       {
//         required String label,
//         required TextEditingController controller
//       }
//       ) {
//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.only(left: 5, right: 5),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: TextStyle(color: Colors.black45),
//           border: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.black26),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.black26),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.black26, width: 1.0),
//           ),
//         ),
//       ),
//     );
//   }
// }
