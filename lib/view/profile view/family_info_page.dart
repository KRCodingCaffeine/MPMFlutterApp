import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/relation/RelationData.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/profile%20view/profile_view.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

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

  void _showImagePicker(BuildContext context, Function(File?) onImageSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFFe61428)),
              title: const Text("Pick from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  onImageSelected(File(pickedFile.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFe61428)),
              title: const Text("Take a Picture"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  onImageSelected(File(pickedFile.path));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
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

  Widget _buildUserCard(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : const AssetImage("assets/images/logo.png") as ImageProvider,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$firstName $middleName $surName".trim(),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        relationshipName.isNotEmpty ? relationshipName : "N/A",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
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
          heightFactor: 0.6,
          // Adjust this value to control the starting position
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// **Header Row**
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

                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Add Member",
                                style: TextStyle(color: Color(0xFFe61428)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        /// **Profile Image Picker**
                        GestureDetector(
                          onTap: () {
                            _showImagePicker(context, (file) {
                              setState(() {
                                newImage = file;
                              });
                            });
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              image: newImage != null
                                  ? DecorationImage(
                                      image: FileImage(newImage!),
                                      fit: BoxFit.cover)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: newImage == null
                                ? const Icon(Icons.camera_alt,
                                    color: Colors.grey, size: 40)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),

                        /// **Form Fields**
                        _buildTextField(
                            "Salutation", (value) => newSalutation = value),
                        _buildTextField(
                            "Relationship", (value) => newRelationship = value),
                        _buildTextField(
                            "First Name", (value) => newFirstName = value),
                        _buildTextField(
                            "Middle Name", (value) => newMiddleName = value),
                        _buildTextField(
                            "SurName", (value) => newSurName = value),
                        _buildTextField("Mobile Number",
                            (value) => newMobileNumber = value),
                        _buildTextField("WhatsApp Number",
                            (value) => newWhatsAppNumber = value),
                        _buildTextField(
                            "Father's Name", (value) => newFathersName = value),
                        _buildTextField(
                            "Mother's Name", (value) => newMothersName = value),
                        _buildTextField("Email", (value) => newEmail = value),
                        _buildTextField(
                            "Date Of Birth", (value) => newDob = value),
                        _buildTextField("Gender", (value) => newGender = value),
                        _buildTextField(
                            "Blood Group", (value) => newBloodGroup = value),
                        _buildTextField("Marital Status",
                            (value) => newMaritalStatus = value),
                        _buildTextField(
                            "Membership", (value) => newMembership = value),

                        const SizedBox(height: 20),
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

  Widget _buildTextField(String label, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  void _navigateToProfilePage(
      BuildContext context,
      String firstName,
      String middleName,
      String surName,
      String relationship,
      File? profileImage) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfileView()));
  }
}
