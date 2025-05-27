import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/relation/RelationData.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';

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
  bool isSpeedDialOpen = false;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  Rx<File?> selectimage = Rx<File?>(null);
  UdateProfileController controller = Get.put(UdateProfileController());
  String firstName = "Rajesh";
  String middleName = "Mani";
  String surName = "Nair";
  String relationshipName = 'Husband';
  String mobileNumber = '9920113198';
  String whatsAppNumber = '9920113198';

  List<Map<String, dynamic>> familyMembers = [];
  final regiController = Get.put(NewMemberController());

  @override
  void initState() {
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
    print("bvnvn" + controller.familyDataList.value.length.toString());
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Family Info', style: TextStyle(color: Colors.white)),
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    return ListView.builder(
                      itemCount: controller.familyDataList.value.length,
                      itemBuilder: (context, index) =>
                          _buildFamilyMemberCard(context, index),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: isSpeedDialOpen ? Icons.close : Icons.add,
        activeIcon: Icons.close,
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
        foregroundColor: Colors.white,
        overlayOpacity: 0.5,
        spacing: 10,
        spaceBetweenChildren: 10,
        onOpen: () => setState(() => isSpeedDialOpen = true),
        onClose: () => setState(() => isSpeedDialOpen = false),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.person_add),
            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
            foregroundColor: Colors.white,
            label: 'New Member',
            labelStyle: TextStyle(fontSize: 16),
            onTap: () {
              _showAddModalSheet(context);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.person),
            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
            foregroundColor: Colors.white,
            label: 'Existing Member',
            labelStyle: TextStyle(fontSize: 16),
            onTap: () {
              // Handle existing member logic
              print('Existing Member tapped');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberCard(context, int index) {
    final member = controller.familyDataList.value[index];
    print("vbfbbv" + member.toString());
    return Card(
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage:
              (member.profileImage != null && member.profileImage.isNotEmpty)
                  ? NetworkImage(Urls.imagePathUrl + member.profileImage)
                  : const AssetImage("assets/images/user3.png") as ImageProvider,
          backgroundColor: Colors.grey[300],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${member.firstName != null ? member.firstName : ""} ${member.lastName != null ? member.lastName : ""}"
                  .trim(),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              "Member Code : " +
                  (member.memberCode != null
                      ? member.memberCode
                      : member.memberId != null
                          ? member.memberId
                          : ""),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              "Relation : " + member.relationshipName != null
                  ? member.relationshipName
                  : "",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Container(
          child: ElevatedButton(
            onPressed: () {
              controller.selectRelationShipType(member.relationshipTypeId);
              _showEditModalSheet(context, member.memberId);
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
                const Icon(Icons.edit, size: 12),
                const SizedBox(width: 4),
                const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditModalSheet(BuildContext context, String index) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFDC3545),
                      elevation: 4,
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.updateFamilyRelation(context, index);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFDC3545),
                      elevation: 4,
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Save"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
                    child: Row(
                      children: [
                        Obx(() {
                          if (controller.rxStatusRelationType.value ==
                              Status.LOADING) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
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
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'RelationShip',
                                  border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black26),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black26),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black26, width: 1.5),
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 20),
                                  labelStyle: TextStyle(
                                    color: Colors.black45,
                                  ),
                                ),
                                isEmpty: controller
                                    .selectRelationShipType.value.isEmpty,
                                child: DropdownButton<String>(
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  isExpanded: true,
                                  underline: Container(),
                                  hint: const Text(
                                    'Select Relation',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                                      controller
                                          .setSelectRelationShip(newValue);
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
    final GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();
    File? newImage;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[100],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8, // Adjusted height factor
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
                  return Column(
                    children: [
                      // Fixed Buttons (Cancel and Add Member)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Cancel Button
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFe61428),
                              elevation: 4,
                              shadowColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            child: const Text("Cancel"),
                          ),

                          // Add Member Button
                          Obx(() {
                            return ElevatedButton(
                              onPressed: () async{
                                if (_formKeyLogin.currentState!.validate()) {
                                  void showErrorSnackbar(String message) {
                                    Get.snackbar(
                                      "Error",
                                      message,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }

                                  if (regiController
                                          .selectMemberSalutation.value ==
                                      "") {
                                    showErrorSnackbar("Select Salutation");
                                    return;
                                  }
                                  if (controller.selectRelationShipType.value ==
                                      "") {
                                    showErrorSnackbar("Select Member Relation");
                                    return;
                                  }
                                  if (regiController.selectedGender.value ==
                                      "") {
                                    showErrorSnackbar("Select Gender");
                                    return;
                                  }
                                  if (regiController.selectBloodGroup.value ==
                                      "") {
                                    showErrorSnackbar("Select Blood Group");
                                    return;
                                  }
                                  if (regiController.dateController.text ==
                                      "") {
                                    showErrorSnackbar("Enter Date of Birth");
                                    return;
                                  }
                                  if (regiController.selectMarital.value ==
                                      "") {
                                    showErrorSnackbar("Select Marital status");
                                    return;
                                  }
                                  if (regiController.MaritalAnnivery.value ==
                                      true) {
                                    if (regiController.marriagedateController
                                            .value.text ==
                                        '') {
                                      showErrorSnackbar("Select Marriage Date");
                                      return;
                                    }
                                  } else {
                                    regiController
                                        .marriagedateController.value.text = "";
                                  }

                                  if (regiController
                                          .selectMemberShipType.value ==
                                      "") {
                                    showErrorSnackbar("Select membership type");
                                    return;
                                  }
                                  controller.userAddFamily();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFe61428),
                                elevation: 4,
                                shadowColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              child: controller.familyloading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.red,
                                    )
                                  : const Text("Add Member"),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Scrollable Form Fields
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKeyLogin,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      _showPicker();
                                    },
                                    child: Obx(() {
                                      return CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.grey[300],
                                        backgroundImage: selectimage.value != null
                                            ? FileImage(selectimage.value!)
                                            : null,
                                        child: selectimage.value == null
                                            ? Icon(
                                                Icons.camera_alt,
                                                color: Colors.grey[700],
                                                size: 40,
                                              )
                                            : null,
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Salutation Dropdown
                                Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(left: 5, right: 5),
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
                                                          ColorResources
                                                              .pink_color),
                                                )),
                                          );
                                        } else if (regiController
                                                .rxStatusMemberSalutation.value ==
                                            Status.ERROR) {
                                          return Center(child: Text(' No Data'));
                                        } else if (regiController
                                            .memberSalutationList.isEmpty) {
                                          return Center(
                                              child: Text(
                                                  'No salutation available'));
                                        } else {
                                          return Expanded(
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                labelText: 'Salutation *',
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26,
                                                      width: 1.5),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                labelStyle: TextStyle(
                                                    color: Colors.black45),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  dropdownColor: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  isExpanded: true,
                                                  hint: const Text(
                                                    'Select Salutation *',
                                                  ),
                                                  value: regiController
                                                          .selectMemberSalutation
                                                          .value
                                                          .isEmpty
                                                      ? null
                                                      : regiController
                                                          .selectMemberSalutation
                                                          .value,
                                                  items: regiController
                                                      .memberSalutationList
                                                      .map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (MemberSalutationData
                                                              marital) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: marital
                                                          .memberSalutaitonId
                                                          .toString(),
                                                      child: Text(marital
                                                          .salutationName
                                                          .toString()),
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
                                            ),
                                          );
                                        }
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Relationship Dropdown
                                Container(
                                  margin:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Obx(() {
                                        if (controller
                                                .rxStatusRelationType.value ==
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
                                                            .pink_color),
                                              ),
                                            ),
                                          );
                                        } else if (controller
                                                .rxStatusRelationType.value ==
                                            Status.ERROR) {
                                          return const Center(
                                              child: Text(
                                                  'Failed to load relation'));
                                        } else if (controller
                                            .relationShipTypeList.isEmpty) {
                                          return const Center(
                                              child:
                                                  Text('No relation available'));
                                        } else {
                                          return Expanded(
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                labelText: 'Select Relation *',
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26,
                                                      width: 1.5),
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical:
                                                        4), // Adjust padding for a balanced look
                                                labelStyle: TextStyle(
                                                    color: Colors.black45),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  dropdownColor: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  isExpanded: true,
                                                  hint: const Text(
                                                    'Select Relation *',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  value: controller
                                                          .selectRelationShipType
                                                          .value
                                                          .isEmpty
                                                      ? null
                                                      : controller
                                                          .selectRelationShipType
                                                          .value,
                                                  items: controller
                                                      .relationShipTypeList
                                                      .map((RelationData
                                                          relation) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value:
                                                          relation.id.toString(),
                                                      child: Text(relation.name ??
                                                          'Unknown'),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? newValue) {
                                                    if (newValue != null) {
                                                      controller
                                                          .setSelectRelationShip(
                                                              newValue);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // First Name Field
                                _buildEditableField(
                                  'First Name *',
                                  regiController.firstNameController.value,
                                  'First Name',
                                  'Enter First Name',
                                  text: TextInputType.text,
                                  isRequired: true,
                                ),
                                const SizedBox(height: 30),

                                // Middle Name Field
                                _buildEditableField(
                                  "Middle Name",
                                  regiController.middleNameController.value,
                                  "Middle Name",
                                  "",
                                  text: TextInputType.text,
                                ),
                                const SizedBox(height: 30),

                                // Surname Field
                                _buildEditableField(
                                  "SurName *",
                                  regiController.lastNameController.value,
                                  "SurName",
                                  "",
                                  text: TextInputType.text,
                                  isRequired: true,
                                ),
                                const SizedBox(height: 30),

                                // Mobile Number Field
                                _buildEditableField(
                                  "Mobile Number *",
                                  regiController.mobileController.value,
                                  "Mobile Number",
                                  "",
                                  text: TextInputType.phone,
                                ),
                                const SizedBox(height: 30),

                                // WhatsApp Number Field
                                _buildEditableField(
                                  "WhatsApp Number *",
                                  regiController.whatappmobileController.value,
                                  "WhatsApp Number",
                                  "",
                                  text: TextInputType.phone,
                                ),
                                const SizedBox(height: 30),

                                // Father's Name Field
                                _buildEditableField(
                                  "Father's Name *",
                                  regiController.fathersnameController.value,
                                  "Father's Name",
                                  "",
                                  text: TextInputType.text,
                                  isRequired: true,
                                ),
                                const SizedBox(height: 30),

                                // Mother's Name Field
                                _buildEditableField(
                                  "Mother's Name",
                                  regiController.mothersnameController.value,
                                  "Mother's Name",
                                  "",
                                  text: TextInputType.text,
                                ),
                                const SizedBox(height: 30),

                                // Email Field
                                _buildEditableField(
                                  "Email *",
                                  regiController.emailController.value,
                                  "Email",
                                  '',
                                  obscureText: false,
                                  text: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 30),

                                // Date of Birth Field
                                SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    margin:
                                        const EdgeInsets.only(left: 5, right: 5),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      readOnly: true,
                                      controller: regiController.dateController,
                                      decoration: InputDecoration(
                                        labelText: 'Date of Birth *',
                                        border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black26),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black26),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black26, width: 1.5),
                                        ),
                                        contentPadding:
                                            EdgeInsets.symmetric(horizontal: 20),
                                        labelStyle: TextStyle(
                                          color: Colors.black45,
                                        ),
                                        hintText: 'Select DOB',
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
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
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
                                            regiController.dateController.text =
                                                formattedDate;
                                          });
                                          String zoneId =
                                              controller.zone_id.value.trim();
                                          regiController.getFamilyMemberShip(
                                              formattedDate, zoneId);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Gender Dropdown
                                Container(
                                  margin:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Obx(() {
                                        if (regiController
                                                .rxStatusLoading2.value ==
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
                                                            .pink_color),
                                              ),
                                            ),
                                          );
                                        } else if (regiController
                                                .rxStatusLoading2.value ==
                                            Status.ERROR) {
                                          return const Center(
                                              child:
                                                  Text('Failed to load genders'));
                                        } else if (regiController
                                            .genderList.isEmpty) {
                                          return const Center(
                                              child:
                                                  Text('No genders available'));
                                        } else {
                                          return Expanded(
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                labelText: 'Select Gender *',
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26,
                                                      width: 1.5),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical:
                                                            4), // Adjusted padding
                                                labelStyle: TextStyle(
                                                    color: Colors.black45),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  dropdownColor: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  isExpanded: true,
                                                  hint: const Text(
                                                    'Select Gender *',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  value: regiController
                                                          .selectedGender
                                                          .value
                                                          .isEmpty
                                                      ? null
                                                      : regiController
                                                          .selectedGender.value,
                                                  items: regiController.genderList
                                                      .map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (DataX gender) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: gender.id.toString(),
                                                      child: Text(
                                                          gender.genderName ??
                                                              'Unknown'),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? newValue) {
                                                    if (newValue != null) {
                                                      regiController
                                                          .setSelectedGender(
                                                              newValue);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Blood Group Dropdown
                                Container(
                                  width: double.infinity,
                                  margin:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Row(
                                    children: [
                                      Obx(() {
                                        if (regiController
                                                .rxStatusLoading.value ==
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
                                                            .pink_color),
                                              ),
                                            ),
                                          );
                                        } else if (regiController
                                                .rxStatusLoading.value ==
                                            Status.ERROR) {
                                          return const Center(
                                              child: Text(
                                                  'Failed to load blood group'));
                                        } else if (regiController
                                            .bloodgroupList.isEmpty) {
                                          return const Center(
                                              child: Text(
                                                  'No blood group available'));
                                        } else {
                                          return Expanded(
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                labelText: 'Select Blood Group *',
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26,
                                                      width: 1.5),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical:
                                                            4), // Adjusted padding
                                                labelStyle: TextStyle(
                                                    color: Colors.black45),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  dropdownColor: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  isExpanded: true,
                                                  hint: const Text(
                                                    'Select Blood Group *',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  value: regiController
                                                          .selectBloodGroup
                                                          .value
                                                          .isEmpty
                                                      ? null
                                                      : regiController
                                                          .selectBloodGroup.value,
                                                  items: regiController
                                                      .bloodgroupList
                                                      .map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (BloodGroupData
                                                              bloodGroup) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: bloodGroup.id
                                                          .toString(),
                                                      child: Text(
                                                          bloodGroup.bloodGroup ??
                                                              'Unknown'),
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
                                            ),
                                          );
                                        }
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Marital Status Dropdown
                                SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    margin:
                                        const EdgeInsets.only(left: 5, right: 5),
                                    child: Row(
                                      children: [
                                        Obx(() {
                                          if (regiController
                                                  .rxStatusmarried.value ==
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
                                                              .pink_color),
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
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Select Marital Status *',
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black26),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black26),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black26,
                                                        width: 1.5),
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical:
                                                              4), // Adjusted padding
                                                  labelStyle: TextStyle(
                                                      color: Colors.black45),
                                                ),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    dropdownColor: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(10),
                                                    isExpanded: true,
                                                    hint: const Text(
                                                      'Select Marital Status *',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    value: regiController
                                                            .selectMarital
                                                            .value
                                                            .isEmpty
                                                        ? null
                                                        : regiController
                                                            .selectMarital.value,
                                                    items: regiController
                                                        .maritalList
                                                        .map<
                                                                DropdownMenuItem<
                                                                    String>>(
                                                            (MaritalData
                                                                marital) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value:
                                                            marital.id.toString(),
                                                        child: Text(marital
                                                                .maritalStatus ??
                                                            'Unknown'),
                                                      );
                                                    }).toList(),
                                                    onChanged:
                                                        (String? newValue) {
                                                      if (newValue != null) {
                                                        regiController
                                                            .setSelectedMarital(
                                                                newValue);
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Show Marriage Anniversary Date ONLY if Married
                                Obx(() {
                                  return Visibility(
                                    visible:
                                        regiController.MaritalAnnivery.value ==
                                            true,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 8),
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
                                                labelText:
                                                    'Marriage Anniversary *',
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26,
                                                      width: 1.5),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                labelStyle: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                                hintText:
                                                    'Select Marriage Anniversary *',
                                                hintStyle: TextStyle(
                                                  color: Colors.black38,
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
                                                      data: Theme.of(context)
                                                          .copyWith(
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
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor: ColorHelperClass
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
                                                  String zoneId = controller
                                                      .zone_id.value
                                                      .trim();
                                                  regiController
                                                      .getFamilyMemberShip(
                                                          formattedDate, zoneId);
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                      ],
                                    ),
                                  );
                                }),

                                // Membership Type Dropdown
                                Container(
                                  margin:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  width: double.infinity,
                                  child: Row(
                                    children: [
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
                                                color: ColorHelperClass
                                                    .getColorFromHex(
                                                        ColorResources.red_color),
                                              ),
                                            ),
                                          );
                                        } else if (regiController
                                                .rxStatusMemberShipTYpe.value ==
                                            Status.ERROR) {
                                          return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 13, horizontal: 20),
                                              child: Text('Select Membership'),
                                            ),
                                          );
                                        } else if (regiController
                                            .memberShipList.isEmpty) {
                                          return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 13, horizontal: 20),
                                              child:
                                                  Text('No Membership available'),
                                            ),
                                          );
                                        } else {
                                          return Expanded(
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                labelText: 'Membership *',
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black26,
                                                      width: 1.5),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical:
                                                            4), // Adjusted padding
                                                labelStyle: TextStyle(
                                                    color: Colors.black45),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  dropdownColor: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  isExpanded: true,
                                                  hint: const Text(
                                                    'Membership *',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  value: regiController
                                                          .selectMemberShipType
                                                          .value
                                                          .isEmpty
                                                      ? null
                                                      : regiController
                                                          .selectMemberShipType
                                                          .value,
                                                  items: regiController
                                                      .memberShipList
                                                      .map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (MemberShipData
                                                              membership) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: membership.id
                                                          .toString(),
                                                      child: Text(
                                                          "${membership.membershipName} - Rs ${membership.price}"),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? newValue) {
                                                    if (newValue != null) {
                                                      regiController
                                                          .selectMemberShipType(
                                                              newValue);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPicker() {
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

        selectimage.value = File(pickedFile!.path);

        if (pickedFile!.path != null) {
          controller.userdocumentImage.value = pickedFile!.path;
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
    required TextInputType text,
    bool isRequired = false,
  }) {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 5),
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
}
