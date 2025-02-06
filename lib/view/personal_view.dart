import 'dart:io';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/OccuptionProfession/OccuptionProfessionData.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/Occupation/OccupationData.dart';
import 'package:mpm/model/OccupationSpec/OccuptionSpecData.dart';
import 'package:mpm/model/Qualification/QualificationData.dart';
import 'package:mpm/model/QualificationCategory/QualificationCategoryModel.dart';
import 'package:mpm/model/QualificationMain/QualicationMainData.dart';
import 'package:mpm/model/bloodgroup/BloodData.dart';
import 'package:mpm/model/gender/DataX.dart';
import 'package:mpm/model/marital/MaritalData.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/app_constants.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/register/register_view_model.dart';
import 'package:intl/intl.dart';

class PersonalView extends StatefulWidget {
  const PersonalView({super.key});
  @override
  State<PersonalView> createState() => _PersonalViewState();
}

class _PersonalViewState extends State<PersonalView> {
  String? _selectedGender;
  final regiController = Get.put(RegisterController());

  File? _image;
  final ImagePicker _picker = ImagePicker();
  int activeStep2 = 1;
  final GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // regiController.getGender();
    // regiController.getMaritalStatus();
    // regiController.getBloodGroup();
    // regiController.getOccupationData();
    // _formKeyLogin = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
                  width: 130,
                  child: Container(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigator.pushReplacementNamed(context!, RouteNames.registration_screen);
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


                        // If all validations pass, proceed with the desired logic
                        print("All validations passed!");
                        // You can now access the values through regiController
                        print(
                            "Selected Gender: ${regiController.selectedGender}");
                        print(
                            "Selected Marital Status: ${regiController.selectMarital}");
                      Navigator.pushNamed(context!, RouteNames.residentailinfo);
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
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 10,
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
                  Text(AppConstants.welcome_mpm,
                      style: TextStyleClass.black20style),
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
                            padding: EdgeInsets.only(left: 5, top: 20),
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
                                            'Select marital status',
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
                                              regiController
                                                  .selectMarital(newValue);
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
                            if (regiController.selectMarital.value == '1') {
                              // '1' indicates "Married"
                              return SizedBox(
                                width: double.infinity,
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    readOnly: true,
                                    controller: TextEditingController(
                                      text: regiController
                                                  .anniversaryDate.value !=
                                              null
                                          ? DateFormat('dd/MM/yyyy').format(
                                              regiController
                                                  .anniversaryDate.value!)
                                          : 'Select Anniversary Date',
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Marriage Anniversary *',
                                      border: InputBorder.none,
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
                                        regiController.anniversaryDate.value =
                                            pickedDate;
                                      }
                                    },
                                  ),
                                ),
                              );
                            }
                            return SizedBox.shrink(); // Hide if not "Married"
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
