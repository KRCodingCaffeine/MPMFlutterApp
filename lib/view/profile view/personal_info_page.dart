import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/bloodgroup/BloodData.dart';
import 'package:mpm/model/gender/DataX.dart';
import 'package:mpm/model/marital/MaritalData.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import '../../utils/urls.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({Key? key}) : super(key: key);

  @override
  _PersonalInformationPageState createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  File? _image;

  UdateProfileController controller = Get.put(UdateProfileController());
  NewMemberController newMemberController = Get.put(NewMemberController());
  // Controllers for the text fields to manage user input

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Personal Info',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0), // Padding for spacing
            child: Container(
              decoration: BoxDecoration(
                color: ColorHelperClass.getColorFromHex(
                    ColorResources.logo_color), // Background color
                shape: BoxShape.circle, // Makes it circular
              ),
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white), // Edit icon
                onPressed: () {
                  _showEditModalSheet(context);
                },
              ),
            ),
          ),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Outer Padding
              child: Card(
                color: Colors.white,
                elevation: 4, // Adds shadow to the card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(16.0), // Inner padding of the card
                  child: Column(
                    children: [
                      Obx(() {
                        return _buildInfoBox(
                          'Full Name',
                          subtitle:
                              '${controller.firstName.value} ${controller.middleName.value.isNotEmpty ? "${controller.middleName.value} " : ""}${controller.surName.value}',
                        );
                      }),
                      SizedBox(height: 20),
                      Obx(() {
                        return _buildInfoBox('Father\'s Name',
                            subtitle: controller.fathersName.value);
                      }),
                      SizedBox(height: 20),
                      Obx(() {
                        return _buildInfoBox('Mother\'s Name',
                            subtitle: controller.mothersName.value);
                      }),
                      SizedBox(height: 20),
                      Obx(() {
                        return _buildInfoBox('Mobile Number',
                            subtitle: controller.mobileNumber.value);
                      }),
                      SizedBox(height: 20),
                      Obx(() {
                        return _buildInfoBox('WhatsApp Number',
                            subtitle: controller.whatsAppNumber.value);
                      }),
                      SizedBox(height: 20),
                      Obx(() {
                        return _buildInfoBox('Email',
                            subtitle: controller.email.value);
                      }),
                      SizedBox(height: 20),
                      _buildInfoBox('Date of Birth',
                          subtitle: controller.dob.value),
                      SizedBox(height: 20),
                      Obx(() {
                        return _buildInfoBox('Gender',
                            subtitle: controller.gender.value);
                      }),
                      SizedBox(height: 20),
                      Obx(() {
                        return _buildInfoBox('Marital Status',
                            subtitle: controller.maritalStatus.value);
                      }),
                      SizedBox(height: 20),
                      Obx(() {
                        return controller.maritalStatus.value.toLowerCase() ==
                                'unmarried'
                            ? SizedBox()
                            : Column(
                                children: [
                                  _buildInfoBox('Anniversary Date',
                                      subtitle: controller
                                          .marriageAnniversaryDate.value),
                                  SizedBox(height: 20),
                                ],
                              );
                      }),
                      Obx(() {
                        return _buildInfoBox('Blood Group',
                            subtitle: controller.bloodGroup.value);
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to show the Modal Bottom Sheet for editing
  void _showEditModalSheet(BuildContext context) {
    double heightFactor = 0.8;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return MediaQuery(
          data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
          child: SafeArea(
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFFDC3545),
                            elevation: 4,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            controller.userUpdateProfile(
                                context, controller.memberId.value);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFFDC3545),
                            elevation: 4,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                    // Expanded section with editable fields
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: GestureDetector(onTap: () {
                                _showPicker(context: context);
                              }, child: Obx(() {
                                String networkImageUrl = Urls.imagePathUrl +
                                    controller.profileImage.value;
                                bool hasNewImage =
                                    controller.newProfileImage.value.isNotEmpty;
                                bool hasNetworkImage =
                                    controller.profileImage.value.isNotEmpty;
                                print(
                                    "Current newProfileImage: ${controller.newProfileImage.value}");
                                print(
                                    "Current profileImage: ${controller.profileImage.value}");
                                return CircleAvatar(
                                  radius: 50,
                                  backgroundImage: hasNewImage
                                      ? FileImage(File(
                                          controller.newProfileImage.value))
                                      : (hasNetworkImage
                                              ? NetworkImage(networkImageUrl)
                                              : const AssetImage(
                                                  "assets/default_profile.png"))
                                          as ImageProvider,
                                );
                              })),
                            ),
                            const SizedBox(height: 30),
                            Obx(() {
                              return _buildEditableField(
                                'First Name',
                                controller.firstNameController.value,
                              );
                            }),
                            Obx(() {
                              return _buildEditableField(
                                'Middle Name',
                                controller.middleNameController.value,
                              );
                            }),
                            Obx(() {
                              return _buildEditableField('SurName',
                                  controller.surNameController.value);
                            }),
                            Obx(() {
                              return _buildEditableField('Fathers Name',
                                  controller.fathersNameController.value);
                            }),
                            Obx(() {
                              return _buildEditableField('Mother Name',
                                  controller.mothersNameController.value);
                            }),
                            Obx(() {
                              return _buildEditableField(
                                'Mobile Number',
                                controller.mobileNumberController.value,
                              );
                            }),
                            Obx(() {
                              return _buildEditableField(
                                'WhatsApp Number',
                                controller.whatsAppNumberController.value,
                              );
                            }),
                            Obx(() {
                              return _buildEditableField(
                                  'Email', controller.emailController.value);
                            }),

                            // DoB
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  readOnly: true,
                                  controller: controller.dobController.value,
                                  decoration: InputDecoration(
                                    labelText: 'Date of Birth *',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors
                                              .black26), // Border color set to black
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors
                                              .black26), // Default border color
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black26,
                                          width: 1.5), // Focus border color
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    labelStyle: TextStyle(
                                      color: Colors
                                          .black45, // Label color remains black45
                                    ),
                                    hintText: 'Select DOB', // Hint text
                                  ),
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: controller.dobController
                                              .value.text.isNotEmpty
                                          ? DateFormat('dd/MM/yyyy').parse(
                                              controller
                                                  .dobController.value.text
                                                  .replaceAll('-', '/'))
                                          : DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: ColorHelperClass
                                                  .getColorFromHex(
                                                      ColorResources.red_color),
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
                                      controller.dobController.value.text =
                                          formattedDate;
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Gender
                            Container(
                              child: Row(
                                children: [
                                  Obx(() {
                                    if (newMemberController
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
                                                    ColorResources.pink_color),
                                          ),
                                        ),
                                      );
                                    } else if (newMemberController
                                            .rxStatusLoading2.value ==
                                        Status.ERROR) {
                                      return const Center(
                                          child:
                                              Text('Failed to load genders'));
                                    } else if (newMemberController
                                        .genderList.isEmpty) {
                                      return const Center(
                                          child: Text('No genders available'));
                                    } else {
                                      return Expanded(
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'Gender',
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors
                                                      .black26), // Border color set to black26
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors
                                                      .black26), // Default border
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black26,
                                                  width: 1.5), // Focused border
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            labelStyle: TextStyle(
                                              color: Colors
                                                  .black45, // Label color remains black45
                                            ),
                                          ),
                                          child: DropdownButton<String>(
                                            dropdownColor: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(10),
                                            underline: Container(),
                                            isExpanded: true,
                                            hint: const Text(
                                              'Select Gender',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            value: controller
                                                    .gender_id.value.isNotEmpty
                                                ? controller.gender_id.value
                                                : '',
                                            items: newMemberController
                                                .genderList
                                                .map((DataX gender) {
                                              return DropdownMenuItem<String>(
                                                value: gender.id.toString(),
                                                child: Text(gender.genderName ??
                                                    'Unknown'),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                controller.gender_id.value =
                                                    newValue;
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

                            // Blood Group
                            Container(
                              child: Row(
                                children: [
                                  Obx(() {
                                    if (newMemberController
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
                                                    ColorResources.red_color),
                                          ),
                                        ),
                                      );
                                    } else if (newMemberController
                                            .rxStatusLoading.value ==
                                        Status.ERROR) {
                                      return const Center(
                                          child: Text(
                                              'Failed to load blood group'));
                                    } else if (newMemberController
                                        .bloodgroupList.isEmpty) {
                                      return const Center(
                                          child:
                                              Text('No blood group available'));
                                    } else {
                                      return Expanded(
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'Blood Group',
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors
                                                      .black26), // Default border color
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors
                                                      .black26), // Enabled border color
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black26,
                                                  width:
                                                      1.5), // Focused border color with thickness
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            labelStyle: TextStyle(
                                              color: Colors
                                                  .black45, // Label color remains black45
                                            ),
                                          ),
                                          child: DropdownButton<String>(
                                            dropdownColor: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            isExpanded: true,
                                            underline: Container(),
                                            hint: const Text(
                                              'Select Blood Group',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            value: controller.blood_group_id
                                                    .value.isNotEmpty
                                                ? controller
                                                    .blood_group_id.value
                                                : '',
                                            items: newMemberController
                                                .bloodgroupList
                                                .map((BloodGroupData marital) {
                                              return DropdownMenuItem<String>(
                                                value: marital.id.toString(),
                                                child: Text(
                                                    marital.bloodGroup ??
                                                        'Unknown'),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                controller.blood_group_id
                                                    .value = newValue;
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

                            // Marital Status
                            SizedBox(
                              child: Container(
                                child: Row(
                                  children: [
                                    Obx(() {
                                      if (newMemberController
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
                                      } else if (newMemberController
                                              .rxStatusmarried.value ==
                                          Status.ERROR) {
                                        return const Center(
                                            child: Text(
                                                'Failed to load marital status'));
                                      } else if (newMemberController
                                          .maritalList.isEmpty) {
                                        return const Center(
                                            child: Text(
                                                'No marital status available'));
                                      } else {
                                        return Expanded(
                                          child: InputDecorator(
                                            decoration: InputDecoration(
                                              labelText: 'Marital Status',
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .black26),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .black26),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black26,
                                                    width:
                                                        1.5),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              labelStyle: TextStyle(
                                                color: Colors
                                                    .black45,
                                              ),
                                            ),
                                            child: DropdownButton<String>(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              isExpanded: true,
                                              underline: Container(),
                                              dropdownColor: Colors.white,
                                              hint: const Text(
                                                'Select Marital Status *',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              value: newMemberController
                                                      .selectMarital
                                                      .value
                                                      .isEmpty
                                                  ? null
                                                  : newMemberController
                                                      .selectMarital.value,
                                              items: newMemberController
                                                  .maritalList
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
                                                  newMemberController
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
                            const SizedBox(height: 30),

                            // Marriage Anniversary
                            Obx(() {
                              return Visibility(
                                visible: newMemberController
                                        .MaritalAnnivery.value ==
                                    true, // Show only if marital_status_id is "1"
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          readOnly: true,
                                          controller: controller
                                              .marriageAnniversaryController
                                              .value,
                                          decoration: InputDecoration(
                                            labelText: 'Marriage Anniversary *',
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors
                                                      .black26), // Default border color
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors
                                                      .black26), // Enabled border color
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black26,
                                                  width:
                                                      1.5), // Thicker border when focused
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20),
                                            labelStyle: TextStyle(
                                              color: Colors
                                                  .grey, // Label color remains grey
                                            ),
                                            hintText:
                                                'Select Marriage Anniversary', // Hint text
                                            hintStyle: TextStyle(
                                              color: Colors
                                                  .black38, // Hint text color for better visibility
                                            ),
                                          ),
                                          onTap: () async {
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: controller
                                                      .marriageAnniversaryController
                                                      .value
                                                      .text
                                                      .isNotEmpty
                                                  ? DateFormat('dd/MM/yyyy')
                                                      .parse(controller
                                                          .marriageAnniversaryController
                                                          .value
                                                          .text
                                                          .replaceAll('-', '/'))
                                                  : DateTime.now(),
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
                                                      style:
                                                          TextButton.styleFrom(
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
                                              controller
                                                  .marriageAnniversaryController
                                                  .value
                                                  .text = formattedDate;
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPicker({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose Photo From Gallery'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Picture'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        controller.newProfileImage.value = pickedFile.path;
      });
    }
  }

  Future<void> getImage(ImageSource img) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: img,
        imageQuality: 80,
      );
      print("New Image Picked: ${pickedFile?.path}");
      if (pickedFile != null) {
        print("New Image Picked: ${pickedFile.path}");

        // Ensure the observable variable is updated
        controller.newProfileImage.value = pickedFile.path;
      } else {
        print("No image selected.");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Method to show success message
  void _showSuccessMessage() {
    const snackBar = SnackBar(
      content: Text('Personal Info updated successfully!'),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Method to build editable text fields inside the modal
  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: TextField(
        controller: controller,
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
      ),
    );
  }

  // Method to build the information boxes
  Widget _buildInfoBox(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Text(
                  ':',
                  style: TextStyle(
                    fontSize: 10,
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
            child: subtitle != null
                ? Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
