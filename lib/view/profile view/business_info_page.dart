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
  NewMemberController regiController =Get.put(NewMemberController());
  UdateProfileController controller =Get.put(UdateProfileController());
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Occupation Info',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
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

            // Business / Employment Details Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row with "Business / Employment Details" and Add Button (conditionally visible)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Business / Employment Details',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddModalSheet(context),
                        icon: const Icon(Icons.add, color: Colors.red),
                        label: const Text(
                          "Add",
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    thickness: 1.0,
                    color:
                        Color(0xFFE0E0E0), // Equivalent to Colors.grey.shade300
                  ),
                ),


                Obx((){
                  if(controller.businessInfoList.value.isEmpty)
                  {
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "No Employment Details, Please add by clicking Add Employment Button.",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),);
                  }
                  return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,

                      itemCount: controller.businessInfoList.value.length,
                      itemBuilder: (context, index) => _buildBusinessInfoCard(bussinessinfo: controller.businessInfoList.value[index])
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
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 24.0,
                                ),
                              ),
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.red)),
                            ),
                            TextButton(
                              onPressed: () {
                                bool isValid = _validateFields();
                                if (isValid) {
                                  controller.userAddBuniessInfo();
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 24.0,
                                ),
                              ),
                              child: const Text('Save',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController, // Make it scrollable
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx((){
                                return _buildEditableField(
                                  'Organisation Name',
                                  controller.organisationName.value,
                                      (value) => controller.organisationName.value = value,
                                );
                              }),
                             Obx((){
                               return  _buildEditableField(
                                 'Office Phone',
                                 controller.officePhone.value,
                                     (value) => controller.officePhone.value = value,
                               );
                             }),
                            Obx((){
                              return   _buildEditableField(
                                'Building Name',
                                controller.buildingName.value,
                                    (value) => controller.buildingName.value = value,
                              );
                            }),
                              Obx((){
                                return _buildEditableField(
                                  'Flat No',
                                  controller.flatNo.value,
                                      (value) =>  controller.flatNo.value = value,
                                );
                              }),
                             Obx((){
                               return  _buildEditableField(
                                 'Area',
                                 controller.areaName.value,
                                     (value) => controller.areaName.value = value,
                               );
                             }),
                                  Container(

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
                                  const SizedBox(height: 20),
                                 Obx((){
                                   return  _buildEditableField(
                                     'Office Pincode',
                                     controller. officePincode.value,
                                         (value) => controller. officePincode.value = value,
                                   );
                                 }),
                                  Obx((){
                                    return _buildEditableField(
                                      'Business Email',
                                      controller.businessEmail.value,
                                          (value) => controller.businessEmail.value = value,
                                    );
                                  }),
                                Obx((){
                                  return   _buildEditableField(
                                    'Website',
                                    controller.website.value,
                                        (value) => controller.website.value = value,
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
      },
    );
  }

  bool _validateFields() {
    return controller.organisationName.isNotEmpty;
  }





  // Editable fields widget
  Widget _buildEditableField(
      String label, String initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: TextEditingController(text: initialValue),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  // Business Info Card widget with white background color
  Widget _buildBusinessInfoCard({
   required BusinessInfo bussinessinfo
  }) {
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
            // Title Header with Organisation Name and Add Button on Right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    bussinessinfo.organisationName.toString(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Prevents overflow
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showEditModalSheet(context,bussinessinfo),
                  icon: const Icon(Icons.edit, color: Colors.red),
                  label: const Text(
                    "Edit",
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Colors.red, // Keep text and icon red when pressed
                  ),
                ),
              ],
            ),

            const Divider(color: Color(0xFFE0E0E0)), // Black divider
            const SizedBox(height: 8),
            Text(
                "${bussinessinfo.flatNo.toString()}, ${bussinessinfo.address.toString()}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Line 2: City, State - Pincode
              Text(
                "${bussinessinfo.cityName.toString()}, ${bussinessinfo.stateName.toString()} - ${bussinessinfo.pincode.toString()}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Line 3: Phone Number
              Text(
                "📞 ${bussinessinfo.officePhone.toString()}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Line 4: Email
              Text(
                "✉ ${bussinessinfo.businessEmail.toString()}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Line 5: Website
              Text(
                "🌐 ${bussinessinfo.website.toString()}",
                style: const TextStyle(fontSize: 14, color: Colors.blue),
              ),
              const SizedBox(height: 10),

          ],
        ),
      ),
    );
  }

  void _showEditModalSheet(BuildContext context, BusinessInfo bussinessinfo) {
    double heightFactor = 0.8;
    controller.organisationName.value=bussinessinfo.organisationName.toString();
    controller.officePhone.value=bussinessinfo.officePhone.toString();
    controller.flatNo.value=bussinessinfo.flatNo.toString();
    controller.buildingName.value=bussinessinfo.buildingNameId.toString();
    controller.areaName.value=bussinessinfo.areaName.toString();
    controller.officePincode.value=bussinessinfo.pincode.toString();
    controller.businessEmail.value=bussinessinfo.businessEmail.toString();
    controller.website.value=bussinessinfo.website.toString();
      regiController.city_id.value=bussinessinfo.cityId.toString();
      regiController.state_id.value=bussinessinfo.stateId.toString();
      regiController.country_id.value=bussinessinfo.countryId.toString();

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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 24.0,
                            ),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () {
                            bool isValid = _validateFields();
                            if (isValid) {
                              controller.userUpdateBuniessInfo(bussinessinfo);
                              Navigator.of(context).pop();
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 24.0,
                            ),
                          ),
                          child: const Text('Update',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         Obx((){
                           return  _buildEditableField(
                               'Organisation Name',
                               controller.organisationName.value,
                                   (value) =>  controller.organisationName.value = value
                           );
                         }),
                          Obx((){
                            return _buildEditableField(
                              'Office Phone',
                              controller.officePhone.value,
                                  (value) => controller.officePhone.value = value,
                            );
                          }),
                         Obx((){
                           return  _buildEditableField(
                             'Building Name',
                               controller.buildingName.value,
                                 (value) =>  controller.buildingName.value = value
                           );


                         }),
                          Obx((){
                            return _buildEditableField(
                                'Flat No',
                                controller.flatNo.value,
                                    (value) => controller.flatNo.value = value
                            );
                          }),
                        Obx((){
                          return   _buildEditableField(
                              'Area',
                              controller.areaName.value,
                                  (value) =>  controller.areaName.value = value
                          );
                        }),
                          Container(

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
                                        value: regiController.city_id.value.isEmpty ? null
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
                          const SizedBox(height: 20),
                         Obx((){
                           return  _buildEditableField(
                               'Office Pincode',
                               controller.officePincode.value,
                                   (value)=>  controller.officePincode.value = value
                           );
                         }),
                          Obx((){
                            return _buildEditableField(
                                'Business Email',
                                controller.businessEmail.value,
                                    (value) => controller.businessEmail.value = value);

                          }),
                          Obx((){
                            return _buildEditableField(
                                'Website',
                                controller.website.value,
                                    (value) => controller.website.value = value
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
            width: 140,
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
                const SizedBox(
                    width: 8),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5, // Start from the middle
            maxChildSize: 0.95, // Can be expanded almost full-screen
            minChildSize: 0.5, // Minimum half-screen height
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController, // Ensures smooth scrolling
                  child: _EditOccInfoContent(
                    occupation: occupation,
                    occupationProfession: occupationProfession,
                    occupationSpecialization: occupationSpecialization,
                    occupationDetails: occupationDetails,
                    onOccInfoChanged: (occ, prof, spec, det) {
                      setState(() {
                        occupation = occ;
                        occupationProfession = prof;
                        occupationSpecialization = spec;
                        occupationDetails = det;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOccInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          controller.occupationData.value?
            Card(
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
                    const SizedBox(
                        height: 8), // Spacing between title and details

                    // Using Row to align info on the left and Edit button on the right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoLine('Occupation', controller.occupationController.value.text),
                              _buildInfoLine('Profession', controller.occupation_profession_nameController.value.text),
                              _buildInfoLine('Specialization', controller.specialization_nameController.value.text),
                              _buildInfoLine('Details', controller.detailsController.value.text),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showEditOccBottomSheet(context),
                          icon: const Icon(Icons.edit,
                              color: Colors.red, size: 16),
                          label: const Text(
                            "Edit",
                            style: TextStyle(fontSize: 14, color: Colors.red),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ):
          Column(
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
            ),
        ],
      ),
    );
  }
}

class _EditOccInfoContent extends StatefulWidget {
  final String occupation;
  final String occupationProfession;
  final String occupationSpecialization;
  final String occupationDetails;
  final Function(String, String, String, String) onOccInfoChanged;

  _EditOccInfoContent({
    required this.occupation,
    required this.occupationProfession,
    required this.occupationSpecialization,
    required this.occupationDetails,
    required this.onOccInfoChanged,
  });

  @override
  _EditOccInfoContentState createState() => _EditOccInfoContentState();
}

class _EditOccInfoContentState extends State<_EditOccInfoContent> {
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();

  UdateProfileController controller =Get.put(UdateProfileController());
  @override
  void initState() {
    super.initState();


    controller.detailsController.value.text = widget.occupationDetails;
  }

  void _saveChanges() {
    // widget.onOccInfoChanged(
    //   _occupationController.text,
    //   _professionController.text,
    //   _specializationController.text,
    //   _detailsController.text,
    // );
    controller.addAndupdateOccuption();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Row for Save & Cancel buttons at the top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel Button (Left)
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context), // Close the BottomSheet
                    style: TextButton.styleFrom(
                      foregroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color), // Grey color for Cancel
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 30),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),

                  // Save Button (Right)
                  TextButton(
                    onPressed: _saveChanges,
                    style: TextButton.styleFrom(
                      foregroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color), // Red color for Save
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 30),
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TextButton.icon(
            //   onPressed: (){
            //
            //   },
            //   icon: const Icon(Icons.edit,
            //       color: Colors.red, size: 16),
            //   label: const Text(
            //     "Edit",
            //     style: TextStyle(fontSize: 14, color: Colors.red),
            //   ),
            //   style: TextButton.styleFrom(
            //     foregroundColor: Colors.red,
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          margin: EdgeInsets.only(left: 5,right: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [

                              Obx(() {
                                if (controller.rxStatusOccupation.value == Status.LOADING) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                    child: Container(
                                        alignment: Alignment.centerRight,
                                        height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                  );
                                } else if (controller.rxStatusOccupation.value == Status.ERROR) {
                                  return Center(child: Text('Failed to load occuption'));
                                } else if (controller.occuptionList.isEmpty) {
                                  return Center(child: Text('No occuption  available'));
                                } else {
                                  return Expanded(
                                    child: DropdownButton<String>(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      isExpanded: true,
                                      underline: Container(),
                                      hint: Text('Select Occuption',style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      ),), // Hint to show when nothing is selected
                                      value: controller.selectOccuption.value.isEmpty
                                          ? null
                                          : controller.selectOccuption.value,

                                      items: controller.occuptionList.map((OccupationData marital) {
                                        return DropdownMenuItem<String>(
                                          value: marital.id.toString(), // Use unique ID or any unique property.
                                          child: Text(marital.occupation ?? 'Unknown'), // Display name from DataX.
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        print("fddfdfff"+newValue.toString());

                                        controller.selectOccuption(newValue);
                                        if (newValue != null) {
                                          controller.selectOccuption(newValue);
                                          if(newValue!="other")
                                          {
                                            controller.isOccutionList.value=true;
                                            controller.getOccupationProData(newValue);
                                          }
                                          else
                                          {
                                            controller.isOccutionList.value=false;


                                          }
                                        }
                                      },
                                    ),
                                  );
                                }
                              }),

                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Obx((){
                        return Visibility(
                            visible: controller.isOccutionList.value,
                            child: Column(
                              children: [
                                Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(left: 5,right: 5),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child:Row(
                                      children: [

                                        Obx(() {
                                          if (controller.rxStatusOccupationData.value == Status.LOADING) {
                                            return Padding(
                                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                              child: Container(
                                                  alignment: Alignment.centerRight,
                                                  height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                            );
                                          } else if (controller.rxStatusOccupationData.value == Status.ERROR) {
                                            return Center(child: Text('Failed to load occuption Profession'));
                                          }
                                          else if (controller.rxStatusOccupationData.value == Status.IDLE) {
                                            return Center(child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Text('Select Occuption Profession'),
                                            ));
                                          }


                                          else if (controller.occuptionProfessionList.isEmpty) {
                                            return Center(child: Text('No occuption Pro available'));
                                          } else {
                                            return Expanded(
                                              child: DropdownButton<String>(
                                                padding: EdgeInsets.symmetric(horizontal: 20,),
                                                isExpanded: true,
                                                underline: Container(),
                                                hint: Text('Select Occuption Profession',style: TextStyle(
                                                    fontWeight: FontWeight.bold
                                                ),), // Hint to show when nothing is selected
                                                value: controller.selectOccuptionPro.value.isEmpty
                                                    ? null
                                                    : controller.selectOccuptionPro.value,

                                                items: controller.occuptionProfessionList.map((OccuptionProfessionData marital) {
                                                  return DropdownMenuItem<String>(
                                                    value: marital.id.toString(), // Use unique ID or any unique property.
                                                    child: Text(marital.name ?? 'Unknown'), // Display name from DataX.
                                                  );
                                                }).toList(), // Convert to List.
                                                onChanged: (String? newValue) {
                                                  if (newValue != null) {
                                                    controller.setSelectOccuptionPro(newValue);
                                                    controller.getOccupationSpectData(newValue);

                                                  }
                                                },
                                              ),
                                            );
                                          }
                                        }),
                                      ],
                                    )),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(left: 5,right: 5),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child:Row(
                                      children: [
                                        Obx(() {
                                          if (controller.rxStatusOccupationSpec.value == Status.LOADING) {
                                            return Padding(
                                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                              child: Container(
                                                  alignment: Alignment.centerRight,
                                                  height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                            );
                                          } else if (controller.rxStatusOccupationSpec.value == Status.ERROR) {
                                            return Center(child: Text('Failed to load occuption specialization',style: TextStyle(
                                                fontWeight: FontWeight.bold
                                            ),), );
                                          }
                                          else if (controller.rxStatusOccupationSpec.value == Status.IDLE) {
                                            return Center(child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Text('Select Occuption specialization,',style: TextStyle(
                                                  fontWeight: FontWeight.bold
                                              ),),
                                            ));
                                          }

                                          else if (controller.occuptionSpeList.isEmpty) {
                                            return Center(child: Text('No occuption specialization available'));
                                          } else {
                                            return Expanded(
                                              child: DropdownButton<String>(
                                                padding: EdgeInsets.symmetric(horizontal: 20),
                                                isExpanded: true,
                                                underline: Container(),
                                                hint: Text('Select Occuption specialization',style: TextStyle(
                                                    fontWeight: FontWeight.bold
                                                ),),
                                                value: controller.selectOccuptionSpec.value.isEmpty
                                                    ? null
                                                    : controller.selectOccuptionSpec.value,

                                                items: controller.occuptionSpeList.map((OccuptionSpecData marital) {
                                                  return DropdownMenuItem<String>(
                                                    value: marital.id.toString(), // Use unique ID or any unique property.
                                                    child: Text(marital.name ?? 'Unknown'), // Display name from DataX.
                                                  );
                                                }).toList(), // Convert to List.
                                                onChanged: (String? newValue) {
                                                  if (newValue != null) {
                                                    controller.selectOccuptionSpec(newValue);

                                                  }
                                                },
                                              ),
                                            );
                                          }
                                        }),
                                      ],
                                    )


                                ),
                              ],
                            ));
                      }),
                      //_buildInfoLine('Details', occupationDetails),
                    ],
                  ),
                ),

              ],
            ),
            SizedBox(
              height: 20,
            ),
            _buildEditableField(
                label: 'Details', controller: controller.detailsController.value),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
      {required String label, required TextEditingController controller}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 5,right: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(

        controller: controller,
        decoration:  InputDecoration(
        hintText: label,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
            vertical: 8,horizontal: 22),
      ),
      ),
    );
  }
}
