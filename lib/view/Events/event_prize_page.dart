import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/model/StudentPrizeRegistration/StudentPrizeRegistrationData.dart';
import 'package:mpm/repository/student_prize_registration_repository/student_prize_registration_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class StudentPrizeFormPage extends StatefulWidget {
  const StudentPrizeFormPage({super.key});

  @override
  _StudentPrizeFormPageState createState() => _StudentPrizeFormPageState();
}

class _StudentPrizeFormPageState extends State<StudentPrizeFormPage> {
  bool isSpeedDialOpen = false;
  String? currentMemberId;
  UdateProfileController controller = Get.put(UdateProfileController());

  final Rx<File?> _image = Rx<File?>(null);
  final RxString selectedMemberId = "".obs;

  final StudentPrizeRegistrationRepository repo =
      StudentPrizeRegistrationRepository();
  final RxList<StudentPrizeRegistrationData> educationList =
      <StudentPrizeRegistrationData>[].obs;

  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  final TextEditingController standardController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();

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
              'Student Prize Distribution',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (educationList.isEmpty) {
          return const Center(child: Text("Students Detail not added yet..."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: educationList.length,
          itemBuilder: (context, index) {
            return _buildEducationCard(educationList[index]);
          },
        );
      }),
      floatingActionButton: SpeedDial(
        icon: isSpeedDialOpen ? Icons.close : Icons.add,
        activeIcon: Icons.close,
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.red_color),
        foregroundColor: Colors.white,
        overlayOpacity: 0.5,
        spacing: 10,
        spaceBetweenChildren: 10,
        onOpen: () => setState(() => isSpeedDialOpen = true),
        onClose: () => setState(() => isSpeedDialOpen = false),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.edit),
            backgroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
            foregroundColor: Colors.white,
            label: 'Add Students',
            labelStyle: const TextStyle(fontSize: 16),
            onTap: () {
              _showEducationDetailsSheet(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _registerForStudentPrize() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData == null || userData.memberId == null) {
        throw Exception('User not logged in');
      }

      final registrationData = StudentPrizeRegistrationData(
        priceMemberId: int.tryParse(selectedMemberId.value),
        studentName: studentNameController.text.trim(),
        schoolName: schoolNameController.text.trim(),
        standardPassed: standardController.text.trim(),
        yearOfPassed: getLastFinancialYear(),
        grade: gradeController.text.trim(),
        addBy: int.tryParse(userData.memberId.toString()),
        markSheetAttachment: _image.value?.path,
      );

      debugPrint(
          "Sending Student Prize Registration: ${registrationData.toJson()}");

      final response = await repo.registerForStudentPrize(registrationData);

      if (response['status'] == true) {
        await _showSuccessDialog(
            'Successfully registered for Student Prize Distribution');
      } else {
        throw Exception(response['message'] ?? 'Failed to register');
      }
    } catch (e) {
      await _showErrorDialog(
          'Student prize registration failed: ${e.toString()}');
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text("Success",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          content: Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87)),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _redirectToEventsList();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _redirectToEventsList() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          content: Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87)),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
              ),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  String getLastFinancialYear() {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;

    if (month >= 4) {
      return "${year - 1} - $year";
    } else {
      return "${year - 2} - ${year - 1}";
    }
  }

  Widget _buildEducationCard(StudentPrizeRegistrationData edu) {
    return Card(
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          backgroundImage: (edu.markSheetAttachment != null &&
                  edu.markSheetAttachment!.isNotEmpty)
              ? FileImage(File(edu.markSheetAttachment!))
              : const AssetImage("assets/images/document.png") as ImageProvider,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Member ID: ${edu.memberId}",
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text("School: ${edu.schoolName}",
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            Text("Standard: ${edu.standardPassed}",
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            Text("Grade: ${edu.grade}",
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            Text("Year: ${edu.yearOfPassed}",
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  void _showEducationDetailsSheet(BuildContext context) {
    final TextEditingController schoolController = TextEditingController();
    final TextEditingController standardController = TextEditingController();
    final TextEditingController marksController = TextEditingController();

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
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style:
                          OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _registerForStudentPrize();
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Save",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Obx(() {
                        final familyList = controller.familyDataList;

                        if (familyList.isEmpty) {
                          return const Center(
                              child: Text('No Members available'));
                        } else {
                          final selectedValue = selectedMemberId.value;

                          return Expanded(
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: selectedValue.isNotEmpty
                                    ? 'Select Member *'
                                    : null,
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
                                    horizontal: 20, vertical: 4),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                              ),
                              child: DropdownButton<String>(
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                isExpanded: true,
                                underline: Container(),
                                hint: const Text(
                                  'Select Member *',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                value: selectedValue.isNotEmpty
                                    ? selectedValue
                                    : null,
                                items: familyList.map((member) {
                                  return DropdownMenuItem<String>(
                                    value: member.memberId.toString(),
                                    child: Text(
                                      "${member.firstName} "
                                      "${member.middleName ?? ''} "
                                      "${member.lastName}",
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    selectedMemberId.value = newValue;
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
                const SizedBox(height: 25),
                _buildTextField(
                    label: "School Name",
                    controller: schoolController,
                    type: TextInputType.text,
                    empty: "Enter school name"),
                _buildTextField(
                    label: "Standard Passed",
                    controller: standardController,
                    type: TextInputType.text,
                    empty: "Enter standard"),
                _buildTextField(
                    label: "Percentage of Marks or Grade",
                    controller: marksController,
                    type: TextInputType.text,
                    empty: "Enter marks/grade"),
                _buildTextField(
                  label: "Year",
                  controller:
                      TextEditingController(text: getLastFinancialYear()),
                  type: TextInputType.text,
                  empty: "Enter year",
                  readOnly: true,
                ),
                Obx(() {
                  return Column(
                    children: [
                      if (_image.value != null)
                        Container(
                          height: 200, // Preview height
                          width: double.infinity, // Full width
                          margin: const EdgeInsets.only(bottom: 10), // Space between preview & button
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _image.value!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity, // Button full width
                        child: ElevatedButton.icon(
                          onPressed: () => _showImagePicker(context),
                          icon: const Icon(Icons.image),
                          label: const Text("Upload Mark Sheet"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            ColorHelperClass.getColorFromHex(ColorResources.red_color),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Match container corners
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12), // Consistent height
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImagePicker(BuildContext context) async {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text("Take a Picture"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  _image.value = File(pickedFile.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.redAccent),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  _image.value = File(pickedFile.path);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required TextInputType type,
    required String empty,
    bool readOnly = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: type,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          hintStyle: const TextStyle(color: Colors.black54),
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
          if (value == null || value.isEmpty) return empty;
          return null;
        },
      ),
    );
  }
}
