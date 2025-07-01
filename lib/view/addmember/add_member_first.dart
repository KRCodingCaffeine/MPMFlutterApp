import 'dart:io';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                      final mobile =
                          regiController.mobileController.value.text.trim();
                      final whatsapp = regiController
                          .whatappmobileController.value.text
                          .trim();

                      if (mobile.length != 10 ||
                          !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
                        Get.snackbar(
                          "", // Empty because we use titleText below
                          "",
                          titleText: const Text(
                            "Make New Member",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          messageText: const Text(
                            "Invalid Mobile Number.",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                          backgroundColor: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: Duration(seconds: 2),
                          margin: const EdgeInsets.all(12),
                          borderRadius: 8,
                          boxShadows: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            )
                          ],
                        );
                        return;
                      }

                      if (whatsapp.length != 10 ||
                          !RegExp(r'^[0-9]+$').hasMatch(whatsapp)) {
                        Get.snackbar(
                          "",
                          "",
                          titleText: const Text(
                            "Make New Member",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          messageText: const Text(
                            "Invalid WhatsApp Number.",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                          backgroundColor: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: Duration(seconds: 2),
                          margin: const EdgeInsets.all(12),
                          borderRadius: 8,
                          boxShadows: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            )
                          ],
                        );
                        return;
                      }

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
                              alignment: Alignment.centerLeft,
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
                            child: Row(
                              children: [
                                Obx(() {
                                  if (regiController
                                          .rxStatusMemberSalutation.value ==
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
                                          .rxStatusMemberSalutation.value ==
                                      Status.ERROR) {
                                    return const Center(
                                        child:
                                            Text('Failed to load salutation'));
                                  } else if (regiController
                                      .memberSalutationList.isEmpty) {
                                    return const Center(
                                        child: Text('No salutation available'));
                                  } else {
                                    final selectedValue = regiController
                                        .selectMemberSalutation.value;
                                    return Expanded(
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: selectedValue.isNotEmpty
                                              ? 'Salutation *'
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
                                            'Select Salutation *',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          value: selectedValue.isNotEmpty
                                              ? selectedValue
                                              : null,
                                          items: regiController
                                              .memberSalutationList
                                              .map((MemberSalutationData item) {
                                            return DropdownMenuItem<String>(
                                              value: item.memberSalutaitonId
                                                  .toString(),
                                              child: Text(item.salutationName ??
                                                  'Unknown'),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              regiController
                                                  .selectMemberSalutation(
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
                          SizedBox(height: 20),

                          //First Name
                          _buildEditableField(
                              'First Name *',
                              regiController.firstNameController.value,
                              'First Name',
                              '',
                              text: TextInputType.text,
                              isRequired: true),
                          const SizedBox(height: 20),

                          //Second Name
                          _buildEditableField(
                              "Middle Name",
                              regiController.middleNameController.value,
                              "Middle Name",
                              "",
                              text: TextInputType.text,
                              isRequired: false),
                          const SizedBox(height: 20),

                          //Third Name
                          _buildEditableField(
                              "SurName *",
                              regiController.lastNameController.value,
                              "SurName",
                              "",
                              text: TextInputType.text,
                              isRequired: true),
                          const SizedBox(height: 20),

                          //Mobile Number
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEditableField(
                                "Mobile Number *",
                                regiController.mobileController.value,
                                "Mobile Number",
                                "Mobile number is required",
                                text: TextInputType.phone,
                                isRequired: true,
                                maxLength: 10,
                                onChanged: (value) {
                                  if (value.length == 10) {
                                    regiController.checkMobileExists(value);
                                  } else {
                                    regiController.mobileExistsMessage.value = '';
                                    regiController.isMobileValid.value = false;
                                  }
                                },
                              ),
                              Obx(() {
                                if (regiController.isCheckingMobile.value) {
                                  return const Padding(
                                    padding: EdgeInsets.only(left: 8.0, top: 4),
                                    child: SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  );
                                } else if (regiController.mobileExistsMessage.value.isNotEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8.0, top: 4),
                                    child: Text(
                                      regiController.mobileExistsMessage.value,
                                      style: TextStyle(
                                        color: regiController.isMobileValid.value
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              })
                            ],
                          ),
                          const SizedBox(height: 20),

                          //WhatsApp Number
                          _buildEditableField(
                            "WhatsApp Number *",
                            regiController.whatappmobileController.value,
                            "WhatsApp Number",
                            "WhatsApp number is required",
                            text: TextInputType.phone,
                            isRequired: true,
                            maxLength: 10,
                          ),
                          const SizedBox(height: 20),

                          //Father's Name
                          _buildEditableField(
                              "Father's Name *",
                              regiController.fathersnameController.value,
                              "Father's Name",
                              "",
                              text: TextInputType.text,
                              isRequired: true),
                          const SizedBox(height: 20),

                          //Mother's Name
                          _buildEditableField(
                              "Mother's Name",
                              regiController.mothersnameController.value,
                              "Mother's Name",
                              "",
                              text: TextInputType.text,
                              isRequired: true),
                          const SizedBox(height: 20),

                          //Email
                          _buildEditableField("Email *",
                              regiController.emailController.value, "Email", '',
                              obscureText: false,
                              text: TextInputType.emailAddress,
                              isRequired: true),
                          const SizedBox(height: 20),

                          //Date of Birth
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              margin: const EdgeInsets.only(left: 5, right: 5),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                readOnly: true,
                                controller: regiController.dateController,
                                decoration: InputDecoration(
                                  labelText: regiController
                                          .dateController.text.isNotEmpty
                                      ? 'Date of Birth *'
                                      : null,
                                  hintText: 'Date of Birth *',
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black38, width: 1),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 22),
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
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
                                                .getColorFromHex(
                                                    ColorResources.red_color),
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: ColorHelperClass
                                                  .getColorFromHex(
                                                      ColorResources.red_color),
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
                            child: Row(
                              children: [
                                Obx(() {
                                  if (regiController.rxStatusLoading2.value ==
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
                                          .rxStatusLoading2.value ==
                                      Status.ERROR) {
                                    return const Center(
                                        child: Text('Failed to load genders'));
                                  } else if (regiController
                                      .genderList.isEmpty) {
                                    return const Center(
                                        child: Text('No genders available'));
                                  } else {
                                    final selectedValue =
                                        regiController.selectedGender.value;
                                    return Expanded(
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: selectedValue.isNotEmpty
                                              ? 'Gender *'
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
                                          hint: const Text('Select Gender *'),
                                          value: selectedValue.isNotEmpty
                                              ? selectedValue
                                              : null,
                                          items: regiController.genderList
                                              .map((DataX gender) {
                                            return DropdownMenuItem<String>(
                                              value: gender.id.toString(),
                                              child: Text(gender.genderName ??
                                                  'Unknown'),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              regiController
                                                  .setSelectedGender(newValue);
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

                          //Blood Group
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            child: Row(
                              children: [
                                Obx(() {
                                  if (regiController.rxStatusLoading.value ==
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
                                          .rxStatusLoading.value ==
                                      Status.ERROR) {
                                    return const Center(
                                        child:
                                            Text('Failed to load blood group'));
                                  } else if (regiController
                                      .bloodgroupList.isEmpty) {
                                    return const Center(
                                        child:
                                            Text('No blood group available'));
                                  } else {
                                    final selectedValue =
                                        regiController.selectBloodGroup.value;
                                    return Expanded(
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: selectedValue.isNotEmpty
                                              ? 'Blood Group *'
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
                                            'Select Blood Group *',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          value: selectedValue.isNotEmpty
                                              ? selectedValue
                                              : null,
                                          items: regiController.bloodgroupList
                                              .map((BloodGroupData item) {
                                            return DropdownMenuItem<String>(
                                              value: item.id.toString(),
                                              child: Text(
                                                  item.bloodGroup ?? 'Unknown'),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              regiController
                                                  .setSelectedBloodGroup(
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

                          // Marital Status
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              margin: const EdgeInsets.only(left: 5, right: 5),
                              child: Row(
                                children: [
                                  Obx(() {
                                    if (regiController.rxStatusmarried.value ==
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
                                      final selectedValue =
                                          regiController.selectMarital.value;
                                      return Expanded(
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: selectedValue.isNotEmpty
                                                ? 'Marital Status *'
                                                : null,
                                            border: const OutlineInputBorder(
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
                                              'Select Marital Status *',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            value: selectedValue.isNotEmpty
                                                ? selectedValue
                                                : null,
                                            items: regiController.maritalList
                                                .map((MaritalData item) {
                                              return DropdownMenuItem<String>(
                                                value: item.id.toString(),
                                                child: Text(
                                                    item.maritalStatus ??
                                                        'Unknown'),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                regiController
                                                    .setSelectedMarital(
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
                          ),
                          const SizedBox(height: 20),

                          Obx(() {
                            return Visibility(
                              visible:
                                  regiController.MaritalAnnivery.value == true,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        readOnly: true,
                                        controller: regiController
                                            .marriagedateController.value,
                                        decoration: InputDecoration(
                                          labelText: regiController
                                                  .marriagedateController
                                                  .value
                                                  .text
                                                  .isNotEmpty
                                              ? 'Marriage Anniversary'
                                              : null,
                                          hintText: 'Marriage Anniversary',
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
                                                  vertical: 12, horizontal: 20),
                                          labelStyle: const TextStyle(
                                              color: Colors.black),
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
                                                                .red_color),
                                                    onPrimary: Colors.white,
                                                    onSurface: Colors.black,
                                                  ),
                                                  textButtonTheme:
                                                      TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          ColorHelperClass
                                                              .getColorFromHex(
                                                                  ColorResources
                                                                      .red_color),
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
        int? maxLength,
        ValueChanged<String>? onChanged,
      }) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: TextFormField(
        keyboardType: text,
        controller: controller,
        obscureText: obscureText,
        maxLength: maxLength,
        onChanged: onChanged,
        buildCounter: (BuildContext context,
            {int? currentLength, int? maxLength, bool? isFocused}) =>
        null,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black),
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
          if (isRequired && (value == null || value.isEmpty)) {
            return validationMessage;
          }
          if (value != null &&
              value.length == 10 &&
              regiController.mobileExistsMessage.value.contains('already exists')) {
            return 'Mobile number already exists';
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
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.redAccent),
              title: const Text('Take a Picture'),
              onTap: () {
                getImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.redAccent),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                getImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
          ],
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
