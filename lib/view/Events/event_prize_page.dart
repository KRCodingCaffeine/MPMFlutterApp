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
import 'package:mpm/view/Events/event_view.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:open_filex/open_filex.dart';
import 'package:mpm/repository/update_price_distribution_repository/update_price_distribution_repo.dart';
import 'package:mpm/model/UpdatePriceDistribution/UpdatePriceDistributionModelClass.dart';

class StudentPrizeFormPage extends StatefulWidget {
  final int eventId;
  final int attendeeId;
  final int memberId;
  final int addedBy;
  final StudentPrizeRegistrationData? existingData;

  const StudentPrizeFormPage({
    super.key,
    required this.eventId,
    required this.attendeeId,
    required this.memberId,
    required this.addedBy,
    this.existingData,
  });

  @override
  _StudentPrizeFormPageState createState() => _StudentPrizeFormPageState();
}

class _StudentPrizeFormPageState extends State<StudentPrizeFormPage> {
  bool isSpeedDialOpen = false;
  String? currentMemberId;
  UdateProfileController controller = Get.put(UdateProfileController());

  final Rx<File?> _image = Rx<File?>(null);
  final RxString selectedMemberId = "".obs;
  final RxString selectedYear = ''.obs;

  final StudentPrizeRegistrationRepository repo = StudentPrizeRegistrationRepository();
  final UpdatePriceDistributionRepository updateRepo = UpdatePriceDistributionRepository(); // Add this
  final RxList<StudentPrizeRegistrationData> educationList = <StudentPrizeRegistrationData>[].obs;

  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  final TextEditingController standardController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      studentNameController.text = widget.existingData!.studentName ?? "";
      schoolNameController.text = widget.existingData!.schoolName ?? "";
      standardController.text = widget.existingData!.standardPassed ?? "";
      gradeController.text = widget.existingData!.grade ?? "";
      selectedYear.value = widget.existingData!.yearOfPassed ?? "";
      selectedMemberId.value = widget.existingData!.priceMemberId?.toString() ?? "";

      if (widget.existingData!.markSheetAttachment != null && widget.existingData!.markSheetAttachment!.isNotEmpty) {
        _image.value = File(widget.existingData!.markSheetAttachment!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => EventsPage()),
              );
            });
          },
        ),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Student Prize Distribution',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
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
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
        foregroundColor: Colors.white,
        overlayOpacity: 0.5,
        spacing: 10,
        spaceBetweenChildren: 10,
        onOpen: () => setState(() => isSpeedDialOpen = true),
        onClose: () => setState(() => isSpeedDialOpen = false),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.edit),
            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
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

  Future<void> _saveStudentPrize() async {
    if (widget.existingData == null) {
      await _registerForStudentPrize();
    } else {
      await _updateStudentPrize();
    }
  }

  Future<void> _updateStudentPrize() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData == null || userData.memberId == null) {
        throw Exception('User not logged in');
      }

      final updateData = {
        'event_attendees_price_member_id': widget.existingData!.eventAttendeesPriceMemberId,
        'event_attendees_id': widget.attendeeId,
        'event_id': widget.eventId,
        'member_id': widget.memberId,
        'price_member_id': int.tryParse(selectedMemberId.value),
        'student_name': studentNameController.text.trim(),
        'school_name': schoolNameController.text.trim(),
        'standard_passed': standardController.text.trim(),
        'year_of_passed': selectedYear.value,
        'grade': gradeController.text.trim(),
        'mark_sheet_attachment': _image.value?.path,
        'created_by': int.tryParse(userData.memberId.toString()),
      };

      debugPrint("Updating Student Prize: $updateData");

      final response = await updateRepo.updatePriceDistribution(updateData);

      if (response.status == true) {
        final updatedIndex = educationList.indexWhere(
                (item) => item.eventAttendeesPriceMemberId == widget.existingData!.eventAttendeesPriceMemberId
        );

        if (updatedIndex != -1) {
          educationList[updatedIndex] = StudentPrizeRegistrationData(
            eventAttendeesPriceMemberId: widget.existingData!.eventAttendeesPriceMemberId,
            eventId: widget.eventId,
            memberId: widget.memberId,
            eventAttendeesId: widget.attendeeId,
            priceMemberId: int.tryParse(selectedMemberId.value),
            studentName: studentNameController.text.trim(),
            schoolName: schoolNameController.text.trim(),
            standardPassed: standardController.text.trim(),
            yearOfPassed: selectedYear.value,
            grade: gradeController.text.trim(),
            markSheetAttachment: _image.value?.path,
          );
        }

        await _showSuccessDialog('Successfully updated Student Prize Distribution');
      } else {
        throw Exception(response.message ?? 'Failed to update');
      }
    } catch (e) {
      await _showErrorDialog('Something went wrong please try again');
    }
  }

  Future<void> _registerForStudentPrize() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData == null || userData.memberId == null) {
        throw Exception('User not logged in');
      }

      final registrationData = StudentPrizeRegistrationData(
        eventId: widget.eventId,
        memberId: widget.memberId,
        addedBy: widget.addedBy,
        eventAttendeesId: widget.attendeeId,
        priceMemberId: int.tryParse(selectedMemberId.value),
        studentName: studentNameController.text.trim(),
        schoolName: schoolNameController.text.trim(),
        standardPassed: standardController.text.trim(),
        yearOfPassed: selectedYear.value,
        grade: gradeController.text.trim(),
        addBy: int.tryParse(userData.memberId.toString()),
        markSheetAttachment: _image.value?.path,
      );

      debugPrint("Sending Student Prize Registration: ${registrationData.toJson()}");

      final response = await repo.registerForStudentPrize(registrationData);

      if (response['status'] == true) {
        educationList.add(
          StudentPrizeRegistrationData(
            eventId: widget.eventId,
            memberId: widget.memberId,
            addedBy: widget.addedBy,
            eventAttendeesId: widget.attendeeId,
            priceMemberId: int.tryParse(selectedMemberId.value),
            studentName: studentNameController.text.trim(),
            schoolName: schoolNameController.text.trim(),
            standardPassed: standardController.text.trim(),
            yearOfPassed: selectedYear.value,
            grade: gradeController.text.trim(),
            addBy: int.tryParse(userData.memberId.toString()),
            markSheetAttachment: _image.value?.path,
          ),
        );

        studentNameController.clear();
        schoolNameController.clear();
        standardController.clear();
        gradeController.clear();
        _image.value = null;
        selectedMemberId.value = "";

        await _showSuccessDialog('Successfully registered for Student Prize Distribution');
      } else {
        throw Exception(response['message'] ?? 'Failed to register');
      }
    } catch (e) {
      await _showErrorDialog('Something went wrong please try again');
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Success",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Error",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  List<String> getLastTwoFinancialYears() {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;

    int startYear = month >= 4 ? year : year - 1;

    String previousFY1 = "${startYear - 2} - ${startYear - 1}";
    String previousFY2 = "${startYear - 1} - $startYear";

    return [previousFY1, previousFY2];
  }

  Widget _buildEducationCard(StudentPrizeRegistrationData edu) {
    return Card(
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow("Student Name", edu.studentName ?? ""),
            _buildRow("School", edu.schoolName ?? ""),
            _buildRow("Standard", edu.standardPassed ?? ""),
            _buildRow("Grade", edu.grade ?? ""),
            _buildRow("Year", edu.yearOfPassed ?? ""),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Mark Sheet Document: ",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                if (edu.markSheetAttachment != null && edu.markSheetAttachment!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _openDocument(edu.markSheetAttachment!),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text("View Document"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  )
                else
                  const Text("No document uploaded", style: TextStyle(color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showEducationDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[100],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _saveStudentPrize();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text(
                        widget.existingData == null ? "Save" : "Update",
                        style: const TextStyle(color: Colors.white),
                      ),
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
                          return const Center(child: Text('No Members available'));
                        } else {
                          final selectedValue = selectedMemberId.value;

                          return Expanded(
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: selectedValue.isNotEmpty ? 'Select Member *' : null,
                                border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black38, width: 1)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                labelStyle: const TextStyle(color: Colors.black),
                              ),
                              child: DropdownButton<String>(
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                isExpanded: true,
                                underline: Container(),
                                hint: const Text('Select Member *', style: TextStyle(fontWeight: FontWeight.bold)),
                                value: selectedValue.isNotEmpty ? selectedValue : null,
                                items: familyList.map((member) {
                                  return DropdownMenuItem<String>(
                                    value: member.memberId.toString(),
                                    child: Text("${member.firstName} ${member.middleName ?? ''} ${member.lastName}"),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    selectedMemberId.value = newValue;

                                    final selectedMember = controller.familyDataList.firstWhereOrNull(
                                            (m) => m.memberId.toString() == newValue
                                    );

                                    if (selectedMember != null) {
                                      final fullName = [
                                        selectedMember.firstName,
                                        selectedMember.middleName ?? "",
                                        selectedMember.lastName ?? ""
                                      ].where((name) => name.isNotEmpty).join(" ");

                                      studentNameController.text = fullName;
                                    }
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
                    controller: schoolNameController,
                    type: TextInputType.text,
                    empty: "Enter school name"
                ),
                _buildTextField(
                    label: "Standard Passed",
                    controller: standardController,
                    type: TextInputType.text,
                    empty: "Enter standard"
                ),
                _buildTextField(
                    label: "Percentage of Marks or Grade",
                    controller: gradeController,
                    type: TextInputType.text,
                    empty: "Enter marks/grade"
                ),
                Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          final years = getLastTwoFinancialYears();
                          final selectedValue = selectedYear.value;

                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: selectedValue.isNotEmpty ? 'Year of Passing *' : null,
                              border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black38, width: 1)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              labelStyle: const TextStyle(color: Colors.black),
                            ),
                            child: DropdownButton<String>(
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              isExpanded: true,
                              underline: Container(),
                              hint: const Text('Year of Passing *', style: TextStyle(fontWeight: FontWeight.bold)),
                              value: selectedValue.isNotEmpty ? selectedValue : null,
                              items: years.map((year) {
                                return DropdownMenuItem<String>(
                                  value: year,
                                  child: Text(year),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  selectedYear.value = newValue;
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Obx(() {
                  return Column(
                    children: [
                      if (_image.value != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_image.value!, fit: BoxFit.cover),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showImagePicker(context),
                          icon: const Icon(Icons.image),
                          label: const Text("Upload Mark Sheet"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
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
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
          border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black38, width: 1)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return empty;
          return null;
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const Text(" : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDocument(String filePath) async {
    try {
      await OpenFilex.open(filePath);
    } catch (e) {
      Get.snackbar("Error", "Unable to open document");
    }
  }
}