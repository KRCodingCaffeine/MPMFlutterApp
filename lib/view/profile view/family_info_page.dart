import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/relation/RelationData.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/profile%20view/profile_view.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

import '../../model/bloodgroup/BloodData.dart';
import '../../model/gender/DataX.dart';
import '../../model/marital/MaritalData.dart';
import '../../model/membersalutation/MemberSalutationData.dart';
import '../../model/membership/MemberShipData.dart';
import '../../view_model/controller/dashboard/NewMemberController.dart';

class FamilyInfoPage extends StatefulWidget {
  final String? successMessage;
  final String? failureMessage;

  const FamilyInfoPage({Key? key, this.successMessage, this.failureMessage})
      : super(key: key);

  @override
  _FamilyInfoPageState createState() => _FamilyInfoPageState();
}

class _FamilyInfoPageState extends State<FamilyInfoPage> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  File? _image;
  UdateProfileController controller = Get.put(UdateProfileController());
  String firstName = "Rajesh";
  String middleName = "Mani";
  String surName = "Nair";
  String relationshipName = 'Husband';
  String mobileNumber = '9920113198';
  String whatsAppNumber = '9920113198';

  List<Map<String, dynamic>> familyMembers = [];
  final regiController = Get.put(NewMemberController());
  final GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Family Info', style: TextStyle(color: Colors.white)),
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.familyDataList.value.length,
                    itemBuilder: (context, index) => _buildFamilyMemberCard(context, index),
                  ),
                ),
              ],
            ),
          ),
          // Add Button at the bottom right
          Positioned(
            bottom: 20, // Distance from the bottom
            right: 20,  // Distance from the right
            child: FloatingActionButton(
              onPressed: () => _showAddModalSheet(context),
              backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color), // Button color
              child: const Icon(Icons.add, color: Colors.white), // Add icon
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberCard(context, int index) {
    final member = controller.familyDataList.value[index];
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage:
              (member.profileImage != null && member.profileImage.isNotEmpty)
                  ? NetworkImage(Urls.imagePathUrl + member.profileImage)
                  : const AssetImage("assets/images/male.png") as ImageProvider,
          backgroundColor: Colors.grey[300],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevent unnecessary space
          children: [
            Text(
              "${member.firstName} ${member.lastName}".trim(),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              "Member Code : " + (member.memberCode ?? member.memberId),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              "Relation : " + member.relationshipName,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.grey),
          onPressed: ()  {
            controller.selectRelationShipType(member.relationshipTypeId);
            _showEditModalSheet(context, member.memberId);
          },
        ),
      ),
    );
  }

  void _showEditModalSheet(BuildContext context, String index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel",
                        style: TextStyle(color: Color(0xFFe61428))),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.updateFamilyRelation(context, index);
                    },
                    child: const Text("Save",
                        style: TextStyle(color: Color(0xFFe61428))),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
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
                          if (controller.rxStatusRelationType.value ==
                              Status.LOADING) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 22),
                              child: Container(
                                alignment: Alignment.centerRight,
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: ColorHelperClass.getColorFromHex(
                                      ColorResources.pink_color),
                                ),
                              ),
                            );
                          } else if (controller.rxStatusRelationType.value ==
                              Status.ERROR) {
                            return const Center(
                                child: Text('Failed to load relation'));
                          } else if (controller.relationShipTypeList.isEmpty) {
                            return const Center(
                                child: Text('No relation available'));
                          } else {
                            return Expanded(
                              child: DropdownButton<String>(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                isExpanded: true,
                                underline: Container(),
                                hint: const Text(
                                  'Select Relation',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: controller
                                        .selectRelationShipType.value.isEmpty
                                    ? null
                                    : controller.selectRelationShipType.value,
                                items: controller.relationShipTypeList
                                    .map((RelationData gender) {
                                  return DropdownMenuItem<String>(
                                    value: gender.id.toString(),
                                    child: Text(gender.name ?? 'Unknown'),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    controller.setSelectRelationShip(newValue);
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
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _showAddModalSheet(BuildContext context) {
    String newSalutation = "";
    String newFirstName = "";
    String newMiddleName = "";
    String newSurName = "";
    String newRelationship = "";
    String newMobileNumber = "";
    String newWhatsAppNumber = "";
    String newFathersName = "";
    String newMothersName = "";
    String newEmail = "";
    String newDob = "";
    String newGender = "";
    String newBloodGroup = "";
    String newMaritalStatus = "";
    String newMembership = "";

    File? newImage;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          // Adjust this value to control the starting position
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 6.0,
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        Container(
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
                              Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Color(0xFFe61428)),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Validate the form
                                    if (_formKeyLogin.currentState!.validate()) {
                                      // Add the member to the list
                                      familyMembers.add({
                                        'salutation': newSalutation,
                                        'relationship': newRelationship,
                                        'firstName': newFirstName,
                                        'middleName': newMiddleName,
                                        'surName': newSurName,
                                        'mobileNumber': newMobileNumber,
                                        'whatsAppNumber': newWhatsAppNumber,
                                        'fathersName': newFathersName,
                                        'mothersName': newMothersName,
                                        'email': newEmail,
                                        'dob': newDob,
                                        'gender': newGender,
                                        'bloodGroup': newBloodGroup,
                                        'maritalStatus': newMaritalStatus,
                                        'membership': newMembership,
                                        'image': newImage,
                                      });

                                      // Close the current bottom sheet
                                      Navigator.pop(context);

                                      // Show the OTP bottom sheet
                                      _showOtpBottomSheet(context);
                                    }
                                  },
                                  child: const Text(
                                    "Add Member",
                                    style: TextStyle(color: Color(0xFFe61428)),
                                  ),
                                ),                              ],
                            ),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      _showPicker(context: context);
                                    },
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.grey[300],
                                      backgroundImage: _image != null ? FileImage(_image!) : null,
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
                                const SizedBox(height: 30),
                                Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(left: 5,right: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),

                                  child: Row(
                                    children: [
                                      Obx(() {
                                        if (regiController.rxStatusMemberSalutation.value == Status.LOADING) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                            child: Container(
                                                alignment: Alignment.centerRight,
                                                height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                          );
                                        } else if (regiController.rxStatusMemberSalutation.value == Status.ERROR) {
                                          return Center(child: Text(' No Data'));
                                        } else if (regiController.memberSalutationList.isEmpty) {
                                          return Center(child: Text('No  salutation available'));
                                        } else {
                                          return Expanded(
                                            child: DropdownButton<String>(
                                              padding: EdgeInsets.symmetric(horizontal: 20),
                                              isExpanded: true,
                                              underline: Container(),
                                              hint: const Text('Select Saluatation',style: TextStyle(
                                                  fontWeight: FontWeight.bold
                                              ),), // Hint to show when nothing is selected
                                              value: regiController.selectMemberSalutation.value.isEmpty
                                                  ? null
                                                  : regiController.selectMemberSalutation.value,

                                              items: regiController.memberSalutationList.map<DropdownMenuItem<String>>((MemberSalutationData marital) {
                                                return DropdownMenuItem<String>(
                                                  value: marital.memberSalutaitonId.toString(), // Use unique ID or any unique property.
                                                  child: Text(""+marital.salutationName.toString()), // Display name from DataX.
                                                );
                                              }).toList(), // Convert to List.
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  regiController.selectMemberSalutation(newValue);
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

                                //Relationship type
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
                                        if (controller.rxStatusRelationType.value ==
                                            Status.LOADING) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 22),
                                            child: Container(
                                              alignment: Alignment.centerRight,
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: ColorHelperClass.getColorFromHex(
                                                    ColorResources.pink_color),
                                              ),
                                            ),
                                          );
                                        } else if (controller.rxStatusRelationType.value ==
                                            Status.ERROR) {
                                          return const Center(
                                              child: Text('Failed to load relation'));
                                        } else if (controller.relationShipTypeList.isEmpty) {
                                          return const Center(
                                              child: Text('No relation available'));
                                        } else {
                                          return Expanded(
                                            child: DropdownButton<String>(
                                              padding:
                                              const EdgeInsets.symmetric(horizontal: 20),
                                              isExpanded: true,
                                              underline: Container(),
                                              hint: const Text(
                                                'Select Relation',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              value: controller
                                                  .selectRelationShipType.value.isEmpty
                                                  ? null
                                                  : controller.selectRelationShipType.value,
                                              items: controller.relationShipTypeList
                                                  .map((RelationData gender) {
                                                return DropdownMenuItem<String>(
                                                  value: gender.id.toString(),
                                                  child: Text(gender.name ?? 'Unknown'),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  controller.setSelectRelationShip(newValue);
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

                                //First Name
                                _buildEditableField(
                                  'First Name *', // Label
                                  regiController
                                      .firstNameController.value, // Controller
                                  'First Name', // Hint Text
                                  '',
                                ),
                                const SizedBox(height: 20),

                                //Second Name
                                _buildEditableField(
                                  "Middle Name", // Label
                                  regiController
                                      .middleNameController.value, // Controller
                                  "Middle Name", // Hint Text
                                  "",
                                ),
                                const SizedBox(height: 20),

                                //Third Name
                                _buildEditableField(
                                  "SurName *", // Label
                                  regiController
                                      .lastNameController.value, // Controller
                                  "SurName", // Hint Text
                                  "",
                                ),
                                const SizedBox(height: 20),

                                //Mobile Number
                                _buildEditableField(
                                  "Mobile Number *", // Label
                                  regiController.mobileController.value, // Controller
                                  "Mobile Number", // Hint Text
                                  "",
                                ),
                                const SizedBox(height: 20),

                                //WhatsApp Number
                                _buildEditableField(
                                  "WhatsApp Number *", // Label
                                  regiController
                                      .whatappmobileController.value, // Controller
                                  "WhatsApp Number", // Hint Text
                                  "",
                                ),
                                const SizedBox(height: 20),

                                //Father's Name
                                _buildEditableField(
                                  "Father's Name *", // Label
                                  regiController
                                      .fathersnameController.value, // Controller
                                  "Father's Name", // Hint Text
                                  "",
                                ),
                                const SizedBox(height: 20),

                                //Mother's Name
                                _buildEditableField(
                                  "Mother's Name", // Label
                                  regiController
                                      .mothersnameController.value, // Controller
                                  "Mother's Name", // Hint Text
                                  "",
                                ),
                                const SizedBox(height: 20),

                                //Email
                                _buildEditableField(
                                  "Email *", // Label
                                  regiController.emailController.value,
                                  "Email",
                                  '',
                                  obscureText: false,
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
                                          // Get zoneId from the text field
                                          String zoneId = controller.zone_id.value.trim();

                                          // Call the function with selected date and zone ID
                                          regiController.getFamilyMemberShip(formattedDate, zoneId);
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
                                                'Select Gender',
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
                                                  .map<DropdownMenuItem<String>>((DataX gender) {
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
                                                'Select Blood Group',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                              ), // Hint to show when nothing is selected
                                              value: regiController
                                                  .selectBloodGroup.value.isEmpty
                                                  ? null
                                                  : regiController
                                                  .selectBloodGroup.value,

                                              items: regiController.bloodgroupList
                                                  .map<DropdownMenuItem<String>>((BloodGroupData marital) {
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

                                // Marital Status Dropdown
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
                                          if (regiController.rxStatusmarried.value == Status.LOADING) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                                              child: Container(
                                                alignment: Alignment.centerRight,
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                                ),
                                              ),
                                            );
                                          } else if (regiController.rxStatusmarried.value == Status.ERROR) {
                                            return const Center(child: Text('Failed to load marital status'));
                                          } else if (regiController.maritalList.isEmpty) {
                                            return const Center(child: Text('No marital status available'));
                                          } else {
                                            return Expanded(
                                              child: DropdownButton<String>(
                                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                                isExpanded: true,
                                                underline: Container(),
                                                hint: const Text(
                                                  'Select marital status',
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                value: regiController.selectMarital.value.isEmpty
                                                    ? null
                                                    : regiController.selectMarital.value,
                                                items: regiController.maritalList
                                                    .map<DropdownMenuItem<String>>((MaritalData marital) {
                                                  return DropdownMenuItem<String>(
                                                    value: marital.id.toString(),
                                                    child: Text(marital.maritalStatus ?? 'Unknown'),
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

                                // Show Marriage Anniversary Date ONLY if Married
                                Obx(() {
                                  return Visibility(
                                    visible: regiController.MaritalAnnivery.value == true,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 8), // Space before Marriage Anniversary field
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
                                              controller: regiController.marriagedateController.value,
                                              decoration: const InputDecoration(
                                                hintText: 'Marriage Anniversary *',
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
                                                    regiController.marriagedateController.value.text =
                                                        formattedDate;
                                                  });
                                                  // Get zoneId from the text field
                                                  String zoneId = controller.zone_id.value.trim();

                                                  // Call the function with selected date and zone ID
                                                  regiController.getFamilyMemberShip(formattedDate, zoneId);
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20), // Space only when Married
                                      ],
                                    ),
                                  );
                                }),

                                // Membership Type (Always Visible)
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
                                        if (regiController.rxStatusMemberShipTYpe.value == Status.LOADING) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                                            child: Container(
                                                alignment: Alignment.centerRight,
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  color: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                                                )),
                                          );
                                        } else if (regiController.rxStatusMemberShipTYpe.value == Status.ERROR) {
                                          return const Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                                                child: Text('Select Membership'),
                                              ));
                                        } else if (regiController.memberShipList.isEmpty) {
                                          return const Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                                                child: Text('No Membership available'),
                                              ));
                                        } else {
                                          return Expanded(
                                            child: DropdownButton<String>(
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              isExpanded: true,
                                              underline: Container(),
                                              hint: const Text(
                                                'Membership *',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              value: regiController.selectMemberShipType.value.isEmpty
                                                  ? null
                                                  : regiController.selectMemberShipType.value,
                                              items: regiController.memberShipList.map<DropdownMenuItem<String>>(
                                                      (MemberShipData marital) {
                                                    return DropdownMenuItem<String>(
                                                      value: marital.id.toString(),
                                                      child: Text("${marital.membershipName}- Rs ${marital.price}"),
                                                    );
                                                  }).toList(),
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showOtpBottomSheet(BuildContext context) {
    final TextEditingController otpController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // Ensure the bottom sheet is scrollable
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard height
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use minimum height
            children: [
              const SizedBox(height: 20),
              const Text(
                "Enter OTP",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter OTP",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Resend OTP logic
                        _resendOtp(context);
                      },
                      child: const Text(
                        "Resend OTP",
                        style: TextStyle(color: Color(0xFFe61428)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Submit OTP logic
                        _submitOtp(context, otpController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                      ),
                      child: const Text(
                        "Submit OTP",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Add extra space at the bottom
            ],
          ),
        );
      },
    );
  }
  
  void _resendOtp(BuildContext context) {
    // Call your API to resend OTP
    // Example:
    // apiService.resendOtp().then((response) {
    //   if (response.success) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("OTP Resent Successfully")),
    //     );
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("Failed to Resend OTP")),
    //     );
    //   }
    // });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP Resent Successfully")),
    );
  }

  void _submitOtp(BuildContext context, String otp) {
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter OTP")),
      );
      return;
    }

    // Call your API to validate OTP
    // Example:
    // apiService.validateOtp(otp).then((response) {
    //   if (response.success) {
    //     Navigator.pop(context); // Close OTP bottom sheet
    //     _refreshData(); // Refresh data on the current screen
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("Invalid OTP")),
    //     );
    //   }
    // });

    // Simulate OTP validation
    if (otp == "123456") { // Replace with actual OTP validation logic
      Navigator.pop(context); // Close OTP bottom sheet
      _refreshData(); // Refresh data on the current screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP")),
      );
    }
  }

  void _refreshData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data Refreshed Successfully")),
    );
  }

  void _submitRegistrationForm(BuildContext context) {
    // Validate and submit registration form
    // Example:
    // if (_formKeyLogin.currentState!.validate()) {
    //   apiService.registerUser().then((response) {
    //     if (response.success) {
    //       _showOtpBottomSheet(context); // Show OTP bottom sheet
    //     } else {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text("Registration Failed")),
    //       );
    //     }
    //   });
    // }

    // Simulate registration success
    _showOtpBottomSheet(context); // Show OTP bottom sheet
  }

  void _showPicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose Photo From Gallery'),
                onTap: () async {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Picture'),
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

  Widget _buildEditableField(
      String label,
      TextEditingController controller,
      String hintText,
      String validationMessage, {
        bool obscureText = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: TextFormField(
        keyboardType: TextInputType.text,
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
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          return null;
        },
      ),
    );
  }
}
