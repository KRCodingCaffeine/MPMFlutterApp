import 'dart:io';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/OccuptionProfession/OccuptionProfessionData.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/model/CountryModel/CountryData.dart';
import 'package:mpm/model/Occupation/OccupationData.dart';
import 'package:mpm/model/OccupationSpec/OccuptionSpecData.dart';
import 'package:mpm/model/Qualification/QualificationData.dart';
import 'package:mpm/model/QualificationCategory/QualificationCategoryModel.dart';
import 'package:mpm/model/QualificationMain/QualicationMainData.dart';
import 'package:mpm/model/State/StateData.dart';
import 'package:mpm/model/bloodgroup/BloodData.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/model/gender/DataX.dart';
import 'package:mpm/model/marital/MaritalData.dart';
import 'package:mpm/model/membersalutation/MemberSalutationData.dart';
import 'package:mpm/model/relation/RelationData.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/app_constants.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/register/register_view_model.dart';
import 'package:intl/intl.dart';

class AddNewMemberFirst extends StatefulWidget {
  const AddNewMemberFirst({super.key});
  @override
  State<AddNewMemberFirst> createState() => _AddNewMemberFirstState();
}

class _AddNewMemberFirstState extends State<AddNewMemberFirst> {
  String? _selectedGender;
  final regiController = Get.put(NewMemberController());
  File? _image;

  final ImagePicker _picker = ImagePicker();
  int activeStep2 = 1;
  final GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
    regiController.getGender();
    regiController.getMaritalStatus();
    regiController.getBloodGroup();
    regiController.getMemberShip();
    regiController.getDocumentType();

    regiController.getMemberSalutation();
    regiController.getCountry();
    regiController.getState();
    regiController.getCity();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          height: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 6),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Aligns button to the right
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 130,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKeyLogin!.currentState!.validate()) {
                        // Helper function to show a snackbar
                        void showErrorSnackbar(String message) {
                          Get.snackbar(
                            "Error",
                            message,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        }

                        if (regiController.selectMemberSalutation.value == '') {
                          showErrorSnackbar("Select salutation");
                          return;
                        }
                        // Gender validation
                        if (regiController.selectedGender == '') {
                          showErrorSnackbar("Select Gender");
                          return;
                        }
                        if (regiController.selectBloodGroup == '') {
                          showErrorSnackbar("Select Blood Group");
                          return;
                        }

                        // Marital status validation
                        if (regiController.selectMarital == '') {
                          showErrorSnackbar("Select Marital Status");
                          return;
                        }
                        if (regiController.MaritalAnnivery.value == true) {
                          if (regiController
                                  .marriagedateController.value.text ==
                              '') {
                            showErrorSnackbar("Select Marriage Date");
                            return;
                          }
                        } else {
                          regiController.marriagedateController.value.text = "";
                        }

                        // If all validations pass, proceed with the desired logic
                        print("All validations passed!");
                        print(
                            "Selected Gender: ${regiController.selectedGender}");
                        print(
                            "Selected Marital Status: ${regiController.selectMarital}");

                        Navigator.pushNamed(context!, RouteNames.newMember2);
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
                    child: Text(AppConstants.continues,
                        style: TextStyleClass.white16style),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 5, top: 0),
                            child: Align(
                              alignment: Alignment
                                  .centerLeft, // Align text to the left side
                              child: Text(
                                'Personal Info',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                _showPicker(context: context);
                              },
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[300],
                                backgroundImage:
                                    _image != null ? FileImage(_image!) : null,
                                child: _image == null
                                    ? Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey[700],
                                        size: 40,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                Obx(() {
                                  if (regiController
                                          .rxStatusMemberSalutation.value ==
                                      Status.LOADING) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
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
                                          .rxStatusMemberSalutation.value ==
                                      Status.ERROR) {
                                    return Center(child: Text(' No Data'));
                                  } else if (regiController
                                      .memberSalutationList.isEmpty) {
                                    return Center(
                                        child:
                                            Text('No  salutation available'));
                                  } else {
                                    return Expanded(
                                      child: DropdownButton<String>(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        isExpanded: true,
                                        underline: Container(),
                                        hint: Text(
                                          'Select Saluation *',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ), // Hint to show when nothing is selected
                                        value: regiController
                                                .selectMemberSalutation
                                                .value
                                                .isEmpty
                                            ? null
                                            : regiController
                                                .selectMemberSalutation.value,

                                        items: regiController
                                            .memberSalutationList
                                            .map(
                                                (MemberSalutationData marital) {
                                          return DropdownMenuItem<String>(
                                            value: marital.memberSalutaitonId
                                                .toString(), // Use unique ID or any unique property.
                                            child: Text("" +
                                                marital.salutationName
                                                    .toString()), // Display name from DataX.
                                          );
                                        }).toList(), // Convert to List.
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            regiController
                                                .selectMemberSalutation(
                                                    newValue);
                                          }
                                        },
                                      ),
                                    );
                                  }
                                }),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),

                          //First Name
                          _buildEditableField(
                            'First Name *', // Label
                            regiController
                                .firstNameController.value, // Controller
                            'First Name', // Hint Text
                            '', text: TextInputType.text,
                            isRequired: true
                          ),
                          const SizedBox(height: 20),

                          //Second Name
                          _buildEditableField(
                            "Middle Name", // Label
                            regiController
                                .middleNameController.value, // Controller
                            "Middle Name", // Hint Text
                            "",
                              text: TextInputType.text,
                              isRequired: false
                          ),
                          const SizedBox(height: 20),

                          //Third Name
                          _buildEditableField(
                            "SurName *", // Label
                            regiController
                                .lastNameController.value, // Controller
                            "SurName", // Hint Text
                            "",
                              text: TextInputType.text,
                              isRequired: true
                          ),
                          const SizedBox(height: 20),

                          //Mobile Number
                          _buildEditableField(
                            "Mobile Number *", // Label
                            regiController.mobileController.value, // Controller
                            "Mobile Number", // Hint Text
                            "",
                              text: TextInputType.phone,
                              isRequired: true
                          ),
                          const SizedBox(height: 20),

                          //WhatsApp Number
                          _buildEditableField(
                            "WhatsApp Number *", // Label
                            regiController
                                .whatappmobileController.value, // Controller
                            "WhatsApp Number", // Hint Text
                            "",
                              text: TextInputType.phone,
                              isRequired: true
                          ),
                          const SizedBox(height: 20),

                          //Father's Name
                          _buildEditableField(
                            "Father's Name *", // Label
                            regiController
                                .fathersnameController.value, // Controller
                            "Father's Name", // Hint Text
                            "",
                              text: TextInputType.text,
                              isRequired: true
                          ),
                          const SizedBox(height: 20),

                          //Mother's Name
                          _buildEditableField(
                            "Mother's Name", // Label
                            regiController
                                .mothersnameController.value, // Controller
                            "Mother's Name", // Hint Text
                            "",
                              text: TextInputType.text,
                              isRequired: true
                          ),
                          const SizedBox(height: 20),

                          //Email
                          _buildEditableField(
                            "Email *", // Label
                            regiController.emailController.value,
                            "Email",
                            '',
                            obscureText: false,
                              text: TextInputType.emailAddress,
                              isRequired: true
                          ),
                          const SizedBox(height: 20),

                          //Date of Birth
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              margin: const EdgeInsets.only(left: 5, right: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                readOnly: true,
                                controller: regiController.dateController,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Date of Birth *', // Match the hint text
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                ),
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: ColorHelperClass
                                                .getColorFromHex(ColorResources
                                                    .red_color), // Apply red color
                                            onPrimary: Colors
                                                .white, // Text color on primary button
                                            onSurface: Colors
                                                .black, // Text color on surface
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: ColorHelperClass
                                                  .getColorFromHex(ColorResources
                                                      .red_color), // Buttons color
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    String formattedDate =
                                        DateFormat('dd/MM/yyyy')
                                            .format(pickedDate);
                                    setState(() {
                                      regiController.dateController.text =
                                          formattedDate;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          //Gender
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
                                  if (regiController.rxStatusLoading2.value ==
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
                                          .rxStatusLoading2.value ==
                                      Status.ERROR) {
                                    return const Center(
                                        child: Text('Failed to load genders'));
                                  } else if (regiController
                                      .genderList.isEmpty) {
                                    return const Center(
                                        child: Text('No genders available'));
                                  } else {
                                    return Expanded(
                                      child: DropdownButton<String>(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        underline: Container(),
                                        isExpanded: true,
                                        hint: const Text(
                                          'Select Gender *',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        value: regiController
                                                .selectedGender.value.isEmpty
                                            ? null
                                            : regiController
                                                .selectedGender.value,
                                        items: regiController.genderList
                                            .map((DataX gender) {
                                          return DropdownMenuItem<String>(
                                            value: gender.id
                                                .toString(), // Use unique ID or any unique property.
                                            child: Text(gender.genderName ??
                                                'Unknown'), // Display name from DataX.
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            regiController
                                                .setSelectedGender(newValue);
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

                          //Blood Group
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
                                  if (regiController.rxStatusLoading.value ==
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
                                          .rxStatusLoading.value ==
                                      Status.ERROR) {
                                    return const Center(
                                        child:
                                            Text('Failed to load blood group'));
                                  } else if (regiController
                                      .bloodgroupList.isEmpty) {
                                    return const Center(
                                        child:
                                            Text('No blood gruop available'));
                                  } else {
                                    return Expanded(
                                      child: DropdownButton<String>(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        isExpanded: true,
                                        underline: Container(),
                                        hint: const Text(
                                          'Select Blood Group *',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ), // Hint to show when nothing is selected
                                        value: regiController
                                                .selectBloodGroup.value.isEmpty
                                            ? null
                                            : regiController
                                                .selectBloodGroup.value,

                                        items: regiController.bloodgroupList
                                            .map((BloodGroupData marital) {
                                          return DropdownMenuItem<String>(
                                            value: marital.id
                                                .toString(), // Use unique ID or any unique property.
                                            child: Text(marital.bloodGroup ??
                                                'Unknown'), // Display name from DataX.
                                          );
                                        }).toList(), // Convert to List.
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            regiController
                                                .setSelectedBloodGroup(
                                                    newValue);
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

                          // Marital Status
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
                                    if (regiController.rxStatusmarried.value ==
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
                                          ),
                                        ),
                                      );
                                    } else if (regiController
                                            .rxStatusmarried.value ==
                                        Status.ERROR) {
                                      return const Center(
                                          child: Text(
                                              'Failed to load marital status'));
                                    } else if (regiController
                                        .maritalList.isEmpty) {
                                      return const Center(
                                          child: Text(
                                              'No marital status available'));
                                    } else {
                                      return Expanded(
                                        child: DropdownButton<String>(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          isExpanded: true,
                                          underline: Container(),
                                          hint: const Text(
                                            'Select Marital Status *',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          value: regiController
                                                  .selectMarital.value.isEmpty
                                              ? null
                                              : regiController
                                                  .selectMarital.value,
                                          items: regiController.maritalList
                                              .map((MaritalData marital) {
                                            return DropdownMenuItem<String>(
                                              value: marital.id.toString(),
                                              child: Text(
                                                  marital.maritalStatus ??
                                                      'Unknown'),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              regiController.setSelectedMarital(newValue);
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
                          const SizedBox(height: 20),

                          Obx(() {
                            return Visibility(
                              visible:
                                  regiController.MaritalAnnivery.value == true,
                              child: Column(
                                children: [
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        readOnly: true,
                                        controller: regiController
                                            .marriagedateController.value,
                                        decoration: const InputDecoration(
                                          hintText: 'Marriage Anniversary',
                                          border: InputBorder
                                              .none, // Remove internal border
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 20,
                                          ),
                                        ),
                                        onTap: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime.now(),
                                            builder: (BuildContext context,
                                                Widget? child) {
                                              return Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  colorScheme:
                                                      ColorScheme.light(
                                                    primary: ColorHelperClass
                                                        .getColorFromHex(
                                                            ColorResources
                                                                .red_color), // Apply red color
                                                    onPrimary: Colors
                                                        .white, // Text color on primary button
                                                    onSurface: Colors
                                                        .black, // Text color on surface
                                                  ),
                                                  textButtonTheme:
                                                      TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          ColorHelperClass
                                                              .getColorFromHex(
                                                                  ColorResources
                                                                      .red_color), // Buttons color
                                                    ),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          if (pickedDate != null) {
                                            String formattedDate =
                                                DateFormat('dd/MM/yyyy')
                                                    .format(pickedDate);
                                            setState(() {
                                              regiController
                                                  .marriagedateController
                                                  .value
                                                  .text = formattedDate;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: TextFormField(
        keyboardType: text,
        controller: controller,
        obscureText: obscureText,
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
          if (isRequired && (value == null || value.isEmpty)) {
            return validationMessage;
          }
          return null;
        },
      ),
    );
  }

  void _showPicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () async {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getImage(
    ImageSource img,
  ) async {
    if (ImagePicker().supportsImageSource(img) == true) {
      try {
        final XFile? pickedFile =
            await ImagePicker().pickImage(source: img, imageQuality: 80);
        setState(() {
          _image = File(pickedFile!.path);
        });
        if (pickedFile!.path != null) {
          regiController.userprofile.value = pickedFile!.path;
        }
      } catch (e) {
        print("gggh" + e.toString());
      }
    }
  }

  void getUserData() async {
    CheckUserData2? userData = await SessionManager.getSession();

    print('User ID: ${userData?.memberId}');
    print('User Name: ${userData?.mobile}');
    if (userData?.memberId != null) {
      regiController.memberId.value = userData!.memberId.toString();
    }
  }
}
