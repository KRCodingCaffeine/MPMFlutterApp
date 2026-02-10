import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:mpm/model/ShikshaSahayata/EducationDetail/AddEducationDetail/AddEducationDetailData.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/GetShikshaApplicationModelClass.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/EducationDetailRepo/add_education_detail_repository/add_education_detail_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/EducationDetailRepo/delete_education_detail_repo/delete_education_detail_repository.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/EducationDetailRepo/update_education_detail_repository/update_education_detail_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ShikshaApplicationRepo/shiksha_application_repository/shiksha_application_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/shiksha_sahayata_by_parenting_view.dart';

class EducationDetailYourselfView extends StatefulWidget {
  final String shikshaApplicantId;

  const EducationDetailYourselfView({
    Key? key,
    required this.shikshaApplicantId,
  }) : super(key: key);

  @override
  State<EducationDetailYourselfView> createState() => _EducationDetailYourselfViewState();
}

class _EducationDetailYourselfViewState extends State<EducationDetailYourselfView> {
  bool hasEducationData = false;
  final List<Map<String, dynamic>> educationList = [];
  File? _educationDocument;
  final ImagePicker _picker = ImagePicker();
  final AddEducationRepository _educationRepo = AddEducationRepository();
  final UpdateEducationRepository _updateRepo = UpdateEducationRepository();
  final DeleteEducationRepository _deleteRepo = DeleteEducationRepository();
  final ShikshaApplicationRepository _shikshaRepo =
  ShikshaApplicationRepository();

  GetShikshaApplicationModelClass? _applicationData;

  bool isLoading = true;

  String? currentMemberId;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
    _fetchEducationData();
  }

  void _loadSessionData() async {
    final userData = await SessionManager.getSession();
    setState(() {
      currentMemberId = userData?.memberId?.toString();
    });
  }

  bool get _isEducationCompleted {
    return educationList.isNotEmpty;
  }

  Future<void> _fetchEducationData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response =
      await _shikshaRepo.fetchShikshaApplicationById(
        applicantId: widget.shikshaApplicantId,
      );

      if (response.status == true && response.data != null) {
        educationList.clear();

        final educationFromApi =
            response.data?.education ?? [];

        for (var edu in educationFromApi) {
          educationList.add({
            "educationId": edu.shikshaApplicantEducationId?.toString(),
            "class": edu.standard ?? '',
            "otherEducationDetails": edu.otherEducationDetails ?? '',
            "school": edu.schoolCollegeName ?? '',
            "board": edu.boardOrUniversity ?? '',
            "passed": edu.yearOfPassing ?? '',
            "marks": edu.marksInPercentage ?? '',
            "file": null,
          });
        }

        setState(() {
          _applicationData = response;
          hasEducationData = educationList.isNotEmpty;
          isLoading = false;
        });
        if (educationList.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showEducationForm(context);
            }
          });
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
              "Education History (Other Than Current Year)",
              maxLines: 2,
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

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : educationList.isEmpty
          ? const Center(
        child: Text(
          "No Education History Added Yet",
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: educationList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                _educationInfoCard(),
                const SizedBox(height: 12),
              ],
            );
          }

          final edu = educationList[index - 1];
          return _educationCard(edu, index - 1);
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.red_color),
        onPressed: () {
          _showEducationForm(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      // ✅ THIS MUST BE HERE
      bottomNavigationBar:
      _isEducationCompleted ? _buildBottomNextBar() : null,
    );
  }

  Widget _educationInfoCard() {
    return Card(
      color: Colors.orange.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                "Please add your 10th, 11th, and 12th education details completed so far, including college or any other course.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _educationCard(Map<String, dynamic> edu, int index) {
    final File? file = edu["file"];

    final String displayTitle =
    edu["class"] == "Other" &&
        (edu["otherEducationDetails"] ?? '').toString().isNotEmpty
        ? edu["otherEducationDetails"]
        : edu["class"];

    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 HEADER (Title + Popup Menu)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    displayTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                PopupMenuButton<String>(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEducationForm(
                        context,
                        existingData: edu,
                        index: index,
                      );
                    } else if (value == 'delete') {
                      _showDeleteEducationDialog(index);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        'Edit Education Detail',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete Education Detail',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFDC3545),
                      elevation: 2,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                    ),
                    child: const Text(
                      "Edit / Delete",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            _infoRow("School", edu["school"]),
            const SizedBox(height: 8),

            _infoRow("Board", edu["board"]),
            const SizedBox(height: 8),

            _infoRow("Passed", edu["passed"]),
            const SizedBox(height: 8),

            _infoRow("Marks", edu["marks"]),
            const SizedBox(height: 12),

            if (file != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showEducationPreview(context, file),
                  icon: const Icon(Icons.visibility),
                  label: const Text("View Document"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    ColorHelperClass.getColorFromHex(
                        ColorResources.red_color),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteEducationDialog(int index) {
    final edu = educationList[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Education Detail"),
          content: const Text(
              "Are you sure you want to delete this education detail?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final body = {
                    "shiksha_applicant_education_id":
                    edu["educationId"],
                  };

                  final response =
                  await _deleteRepo.deleteEducation(body);

                  if (response.status != true) {
                    throw Exception(response.message);
                  }

                  setState(() {
                    educationList.removeAt(index);
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                      Text("Education detail deleted successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  await _fetchEducationData();
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNextBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Expanded(
              child: Text(
                "Once you complete the above details, click Next Step to proceed.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShikshaSahayataByParentingView(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Next Step"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitEducation({
    required String standard,
    required String? otherEducationDetails,
    required String yearOfPassing,
    required String marks,
    required String school,
    required String board,
  }) async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final educationData = AddEducationDetailData(
        shikshaApplicantId: widget.shikshaApplicantId,
        standard: standard,
        otherEducationDetails: otherEducationDetails,
        yearOfPassing: yearOfPassing,
        marksInPercentage: marks,
        schoolCollegeName: school,
        boardOrUniversity: board,
        createdBy: currentMemberId,
      );

      final response = await _educationRepo.addEducation(
        educationData.toJson(),
      );

      if (response.status != true) {
        throw Exception(response.message ?? "Failed to add education");
      }

      // ✅ Close bottom sheet first
      Navigator.pop(context);

      // ✅ Clear temporary document
      _educationDocument = null;

      // ✅ Refresh from API (SOURCE OF TRUTH)
      await _fetchEducationData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Education details added successfully"),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<void> _updateEducation({
    required String educationId,
    required String standard,
    required String? otherEducationDetails,
    required String yearOfPassing,
    required String marks,
    required String school,
    required String board,
    required int index,
  }) async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final body = {
        "shiksha_applicant_education_id": educationId,
        "standard": standard,
        "other_education_details": otherEducationDetails,
        "year_of_passing": yearOfPassing,
        "marks_in_percentage": marks,
        "updated_by": currentMemberId,
      };

      final response = await _updateRepo.updateEducation(body);

      if (response.status != true) {
        throw Exception(response.message);
      }

      setState(() {
        educationList[index]["class"] = standard;
        educationList[index]["school"] = school;
        educationList[index]["board"] = board;
        educationList[index]["passed"] = yearOfPassing;
        educationList[index]["marks"] = marks;
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Education detail updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
      await _fetchEducationData();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  // ====================== EDUCATION FORM ======================

  void _showEducationForm(BuildContext context, {Map<String, dynamic>? existingData, int? index}) {
    String selectedClass = '';

    final TextEditingController passedCtrl = TextEditingController();
    final TextEditingController marksCtrl = TextEditingController();
    final TextEditingController otherClassCtrl = TextEditingController();
    final TextEditingController schoolCtrl = TextEditingController();
    final TextEditingController boardCtrl = TextEditingController();

    final List<String> classOptions = [
      "10th Std",
      "11th Std",
      "12th Std",
      "Other",
    ];

    bool isEditMode = existingData != null;

    if (isEditMode) {
      selectedClass = existingData["class"] ?? '';
      schoolCtrl.text = existingData["school"] ?? '';
      boardCtrl.text = existingData["board"] ?? '';
      passedCtrl.text = existingData["passed"] ?? '';
      marksCtrl.text = existingData["marks"] ?? '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.75,
                child: Column(
                  children: [
                    /// 🔹 TOP ACTION BAR
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                              ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              side: BorderSide(
                                color: ColorHelperClass.getColorFromHex(
                                    ColorResources.red_color),
                              ),
                              padding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: selectedClass.isEmpty ||
                                schoolCtrl.text.isEmpty ||
                                boardCtrl.text.isEmpty ||
                                passedCtrl.text.isEmpty ||
                                marksCtrl.text.isEmpty ||
                                (selectedClass == "Other" && otherClassCtrl.text.isEmpty) ||
                                isSubmitting
                                ? null
                                : () async {
                              if (isEditMode) {
                                final educationId = existingData?["educationId"];

                                if (educationId == null ||
                                    educationId.toString().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Education ID missing"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                await _updateEducation(
                                  educationId: educationId.toString(),

                                  // ✅ IMPORTANT: Always store dropdown value
                                  standard: selectedClass,

                                  // ✅ Only send other detail when needed
                                  otherEducationDetails:
                                  selectedClass == "Other"
                                      ? otherClassCtrl.text.trim()
                                      : null,

                                  yearOfPassing: passedCtrl.text.trim(),
                                  marks: marksCtrl.text.trim(),
                                  school: schoolCtrl.text.trim(),
                                  board: boardCtrl.text.trim(),
                                  index: index!,
                                );
                              } else {
                                await _submitEducation(
                                  // ✅ Always send dropdown value
                                  standard: selectedClass,

                                  // ✅ Only send other detail if selected
                                  otherEducationDetails:
                                  selectedClass == "Other"
                                      ? otherClassCtrl.text.trim()
                                      : null,

                                  yearOfPassing: passedCtrl.text.trim(),
                                  marks: marksCtrl.text.trim(),
                                  school: schoolCtrl.text.trim(),
                                  board: boardCtrl.text.trim(),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(isEditMode
                                ? "Update Education Details"
                                : "Add Education Details"),
                          ),
                        ],
                      ),
                    ),

                    /// 🔹 FORM CONTENT
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            const Center(
                              child: Text(
                                "Add Education Detail",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            /// 🔹 CLASS
                            InputDecorator(
                              decoration: InputDecoration(
                                labelText: "Class *",
                                border:
                                const OutlineInputBorder(
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
                                borderRadius: BorderRadius.circular(10),
                                isExpanded: true,
                                underline: Container(),
                                value: selectedClass.isEmpty
                                    ? null
                                    : selectedClass,
                                hint: const Text("Select Class"),
                                items: classOptions
                                    .map((c) =>
                                    DropdownMenuItem<String>(
                                      value: c,
                                      child: Text(c),
                                    ))
                                    .toList(),
                                onChanged: (val) {
                                  setModalState(() {
                                    selectedClass = val!;
                                    otherClassCtrl.clear();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 20),

                            if (selectedClass == "Other") ...[
                              TextFormField(
                                controller: otherClassCtrl,
                                decoration: _inputDecoration(
                                    'Other Education Detail *'),
                              ),
                              const SizedBox(height: 20),
                            ],

                            /// 🔹 NEW FIELD - SCHOOL / COLLEGE
                            TextFormField(
                              controller: schoolCtrl,
                              decoration: _inputDecoration(
                                  'School / College Name *'),
                            ),
                            const SizedBox(height: 20),

                            /// 🔹 NEW FIELD - BOARD / UNIVERSITY
                            TextFormField(
                              controller: boardCtrl,
                              decoration: _inputDecoration(
                                  'Board / University *'),
                            ),
                            const SizedBox(height: 20),

                            /// 🔹 PASSED
                            themedMonthYearPickerField(
                              context: context,
                              label: "Passed Month / Year *",
                              controller: passedCtrl,
                            ),
                            const SizedBox(height: 20),

                            /// 🔹 UPDATED LABEL
                            TextFormField(
                              controller: marksCtrl,
                              decoration: _inputDecoration(
                                  'Marks Obtained / Total Marks *'),
                            ),
                            const SizedBox(height: 25),

                            _buildEducationUploadField(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const Text(
            ": ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget themedMonthYearPickerField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      readOnly: true,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black38, width: 1),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20),
        labelStyle: const TextStyle(color: Colors.black),
      ),
      onTap: () async {
        final selected = await showMonthYearPicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: ColorHelperClass.getColorFromHex(
                      ColorResources.red_color),
                ),
              ),
              child: child!,
            );
          },
        );

        if (selected != null) {
          controller.text =
              DateFormat('MM/yyyy').format(selected);
        }
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black38, width: 1),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20),
      labelStyle: const TextStyle(color: Colors.black),
    );
  }

  void _showEducationPreview(BuildContext context, File file) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: file.path.endsWith(".pdf")
                    ? const Center(
                  child: Icon(
                    Icons.picture_as_pdf,
                    size: 100,
                    color: Colors.red,
                  ),
                )
                    : InteractiveViewer(
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEducationUploadField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_educationDocument != null)
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _educationDocument!.path.endsWith(".pdf")
                  ? const Center(
                child: Icon(
                  Icons.picture_as_pdf,
                  size: 70,
                  color: Colors.redAccent,
                ),
              )
                  : Image.file(
                _educationDocument!,
                fit: BoxFit.cover,
              ),
            ),
          ),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showEducationImagePicker(context),
            icon: const Icon(Icons.upload_file),
            label: Text(
              _educationDocument == null
                  ? "Upload Marksheet / Certificate"
                  : "Change Document",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              ColorHelperClass.getColorFromHex(ColorResources.red_color),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _showEducationImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text("Take a Picture"),
              onTap: () {
                Navigator.pop(context);
                _pickEducationFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.redAccent),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickEducationFromGallery();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickEducationFromCamera() async {
    final pickedFile =
    await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _educationDocument = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickEducationFromGallery() async {
    final pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _educationDocument = File(pickedFile.path);
      });
    }
  }

}
