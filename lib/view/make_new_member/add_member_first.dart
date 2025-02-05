import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/bloodgroup/BloodData.dart';
import 'package:mpm/model/gender/DataX.dart';
import 'package:mpm/model/marital/MaritalData.dart';
import 'package:mpm/model/relation/RelationData.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/app_constants.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:intl/intl.dart';

class NewMemberView extends StatefulWidget {
  const NewMemberView({super.key});
  @override
  State<NewMemberView> createState() => _NewMemberViewState();
}

class _NewMemberViewState extends State<NewMemberView> {
  String? _selectedGender;
  final regiController = Get.put(NewMemberController());

  File? _image;
  ImagePicker _picker = ImagePicker();
  int activeStep2 = 1;
  GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    regiController.getGender();
    regiController.getMaritalStatus();
    regiController.getBloodGroup();
    regiController.getOccupationData();
    regiController.getQualification();
    regiController.getMemberShip();
    regiController.getDocumentType();
    regiController.getRelation();
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
    final double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
          title: Text(
            AppConstants.new_member,
            style: TextStyleClass.white16style,
          ),
        ),
        backgroundColor: Colors.grey[100],
        bottomNavigationBar: Container(
          margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          height: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  child: Container(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigator.pushReplacementNamed(context!, RouteNames.registration_screen);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(
                            ColorResources.red_color),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKeyLogin!.currentState!.validate()) {
                        // Helper function to show a snackbar
                        void showErrorSnackbar(String message) {
                          Get.snackbar(
                            "Error",
                            message,
                            backgroundColor: Color(0xFFDC3545),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
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

                        if (regiController.isRelation.value == true) {
                          if (regiController.selectRelationShipType.value ==
                              '') {
                            showErrorSnackbar("Select Relation");
                            return;
                          }
                        }
                        Navigator.pushNamed(context!, RouteNames.newMember2);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // "Personal Info" Text
                          const Padding(
                            padding: EdgeInsets.only(left: 5, top: 20),
                            child: Text(
                              'Personal Info',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Square Container for Image Picker
                          Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                _showPicker(context: context);
                              },
                              child: Container(
                                width: 80, // Set the desired width
                                height: 80, // Set the desired height
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  image: _image != null
                                      ? DecorationImage(
                                    image: FileImage(_image!),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                  borderRadius: BorderRadius.circular(8), // Optional: Rounded corners for the square
                                ),
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

                          // First Name Field
                          _buildEditableField(
                            'First Name *',
                            regiController.firstNameController.value,
                            'Enter First Name',
                            'Enter First Name',
                          ),
                          const SizedBox(height: 20),

                          // Middle Name Field
                          _buildEditableField(
                            'Middle Name',
                            regiController.middleNameController.value,
                            'Enter Middle Name',
                            '',
                          ),
                          const SizedBox(height: 20),

                          // Last Name Field
                          _buildEditableField(
                            'SurName *',
                            regiController.lastNameController.value,
                            'Enter SurName',
                            'Enter SurName',
                          ),
                          const SizedBox(height: 20),

                          // Mobile Number Field
                          _buildEditableField(
                            'Mobile Number *',
                            regiController.mobileController.value,
                            'Enter Mobile Number',
                            'Enter Mobile Number',
                          ),
                          const SizedBox(height: 20),

                          // WhatsApp Mobile Number Field
                          _buildEditableField(
                            'WhatsApp Number *',
                            regiController.whatappmobileController.value,
                            'Enter WhatsApp Number',
                            'Enter WhatsApp Number',
                          ),
                          const SizedBox(height: 20),

                          // Father's Name Field
                          _buildEditableField(
                            "Father's Name *",
                            regiController.fatherNameController.value,
                            "Enter Father's Name",
                            "Please enter Father's Name",
                          ),
                          const SizedBox(height: 20),

                          // Mother's Name Field
                          _buildEditableField(
                            "Mother's Name",
                            regiController.motherNameController.value,
                            "Enter Mother's Name",
                            "Please enter Mother's Name",
                          ),
                          const SizedBox(height: 20),

                          // Email Field
                          _buildEditableField(
                            'Email *',
                            regiController.emailController.value,
                            'Enter Email ID',
                            'Enter Email ID',
                          ),
                          const SizedBox(height: 20),

                          // Date of Birth Field
                          Container(
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
                                hintText: 'Date of Birth *',
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
                                  builder: (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: ColorHelperClass.getColorFromHex(ColorResources.red_color), // Apply red color
                                          onPrimary: Colors.white, // Text color on primary button
                                          onSurface: Colors.black, // Text color on surface
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color), // Buttons color
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (pickedDate != null) {
                                  String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                                  setState(() {
                                    regiController.dateController.text = formattedDate;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Gender Dropdown
                          Container(
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                Obx(() {
                                  if (regiController.rxStatusLoading2.value == Status.LOADING) {
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
                                  } else if (regiController.rxStatusLoading2.value == Status.ERROR) {
                                    return const Center(child: Text('Failed to load genders'));
                                  } else if (regiController.genderList.isEmpty) {
                                    return const Center(child: Text('No genders available'));
                                  } else {
                                    return Expanded(
                                      child: DropdownButton<String>(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        isExpanded: true,
                                        underline: Container(),
                                        hint: const Text(
                                          'Select Gender *',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        value: regiController.selectedGender.value.isEmpty ? null : regiController.selectedGender.value,
                                        items: regiController.genderList.map((DataX gender) {
                                          return DropdownMenuItem<String>(
                                            value: gender.id.toString(),
                                            child: Text(gender.genderName ?? 'Unknown'),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            regiController.setSelectedGender(newValue);
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

                          // Blood Group Dropdown
                          Container(
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                Obx(() {
                                  if (regiController.rxStatusLoading.value == Status.LOADING) {
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
                                  } else if (regiController.rxStatusLoading.value == Status.ERROR) {
                                    return const Center(child: Text('Failed to load blood group'));
                                  } else if (regiController.bloodgroupList.isEmpty) {
                                    return const Center(child: Text('No blood group available'));
                                  } else {
                                    return Expanded(
                                      child: DropdownButton<String>(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        isExpanded: true,
                                        underline: Container(),
                                        hint: const Text(
                                          'Select Blood Group',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        value: regiController.selectBloodGroup.value.isEmpty ? null : regiController.selectBloodGroup.value,
                                        items: regiController.bloodgroupList.map((BloodGroupData marital) {
                                          return DropdownMenuItem<String>(
                                            value: marital.id.toString(),
                                            child: Text(marital.bloodGroup ?? 'Unknown'),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            regiController.setSelectedBloodGroup(newValue);
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
                          // Relation Dropdown (Conditional)
                          Obx(() {
                            return Visibility(
                              visible: regiController.isRelation.value,
                              child: Container(
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
                                      if (regiController.rxStatusRelationType.value == Status.LOADING) {
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
                                      } else if (regiController.rxStatusRelationType.value == Status.ERROR) {
                                        return const Center(child: Text('Failed to load relation'));
                                      } else if (regiController.relationShipTypeList.isEmpty) {
                                        return const Center(child: Text('No relation available'));
                                      } else {
                                        return Expanded(
                                          child: DropdownButton<String>(
                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                            isExpanded: true,
                                            underline: Container(),
                                            hint: const Text(
                                              'Select Relation',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            value: regiController.selectRelationShipType.value.isEmpty ? null : regiController.selectRelationShipType.value,
                                            items: regiController.relationShipTypeList.map((RelationData gender) {
                                              return DropdownMenuItem<String>(
                                                value: gender.id.toString(),
                                                child: Text(gender.name ?? 'Unknown'),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                regiController.selectRelationShipType(newValue);
                                              }
                                            },
                                          ),
                                        );
                                      }
                                    }),
                                  ],
                                ),
                              ),
                            );
                          }),
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
                                          items: regiController.maritalList.map((MaritalData marital) {
                                            return DropdownMenuItem<String>(
                                              value: marital.id.toString(),
                                              child: Text(marital.maritalStatus ?? 'Unknown'),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              regiController.selectMarital(newValue);
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

                          // Marriage Anniversary Date Picker (Only visible if "Married" is selected)
                          Obx(() {
                            if (regiController.selectMarital.value == '1') { // Assuming '1' is the value for "Married"
                              return SizedBox(
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
                                    controller: TextEditingController(
                                      text: regiController.anniversaryDate.value == null
                                          ? 'Select Anniversary Date'
                                          : '${regiController.anniversaryDate.value?.day}/${regiController.anniversaryDate.value?.month}/${regiController.anniversaryDate.value?.year}',
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Marriage Anniversary',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                    ),
                                    onTap: () async {
                                      DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                        builder: (BuildContext context, Widget? child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: ColorHelperClass.getColorFromHex(ColorResources.red_color), // Apply red color
                                                onPrimary: Colors.white, // Text color on primary button
                                                onSurface: Colors.black, // Text color on surface
                                              ),
                                              textButtonTheme: TextButtonThemeData(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color), // Buttons color
                                                ),
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (pickedDate != null) {
                                        String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                                        setState(() {
                                          regiController.anniversaryDate.value = pickedDate;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              );
                            }
                            return SizedBox.shrink(); // If not "Married", return an empty widget
                          }),
                          const SizedBox(height: 80),
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
          labelStyle: const TextStyle(color: Colors.black), // Label text color set to black
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54), // Slightly dimmed black for hint text
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey), // Border color set to black
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey), // Border when field is not focused
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 0.5), // Thicker border when focused
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

  void _showPicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
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
}
