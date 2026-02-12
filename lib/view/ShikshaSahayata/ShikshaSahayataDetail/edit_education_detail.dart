import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:mpm/model/ShikshaSahayata/EducationDetail/AddEducationDetail/AddEducationDetailData.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/GetShikshaApplicationModelClass.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplicationsByAppliedBy/ShikshaApplicationsByAppliedByData.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/EducationDetailRepo/add_education_detail_repository/add_education_detail_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/EducationDetailRepo/delete_education_detail_repo/delete_education_detail_repository.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/EducationDetailRepo/mark_sheet_upload_repository/mark_sheet_upload_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/EducationDetailRepo/update_education_detail_repository/update_education_detail_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ShikshaApplicationRepo/shiksha_application_repository/shiksha_application_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';

class EditEducationDetailView extends StatefulWidget {
  final ShikshaApplicationsByAppliedByData applicationData;

  const EditEducationDetailView({
    Key? key,
    required this.applicationData,
  }) : super(key: key);

  @override
  State<EditEducationDetailView> createState() => _EditEducationDetailViewState();
}

class _EditEducationDetailViewState extends State<EditEducationDetailView> {
  bool hasEducationData = false;
  final List<Map<String, dynamic>> educationList = [];
  File? _educationDocument;
  final ImagePicker _picker = ImagePicker();
  final AddEducationRepository _educationRepo = AddEducationRepository();
  final UpdateEducationRepository _updateRepo = UpdateEducationRepository();
  final DeleteEducationRepository _deleteRepo = DeleteEducationRepository();
  final MarkSheetUploadRepository _markSheetRepo = MarkSheetUploadRepository();
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

  Future<void> _fetchEducationData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await _shikshaRepo.fetchShikshaApplicationById(
        applicantId: widget.applicationData.shikshaApplicantId!,
      );

      if (response.status == true && response.data != null) {
        educationList.clear();

        final educationFromApi = response.data?.education ?? [];

        for (var edu in educationFromApi) {
          educationList.add({
            "educationId": edu.shikshaApplicantEducationId?.toString(),
            "class": edu.standard ?? '',
            "otherEducationDetails": edu.otherEducationDetails ?? '',
            "school": edu.schoolCollegeName ?? '',
            "board": edu.boardOrUniversity ?? '',
            "passed": edu.yearOfPassing ?? '',
            "marks": edu.marksInPercentage ?? '',
            "markSheetAttachment": edu.markSheetAttachment ?? '',
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
    final String serverDocument = edu["markSheetAttachment"] ?? "";

    final String displayTitle = edu["class"] == "Other" &&
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

            if (serverDocument.toString().isNotEmpty)
              Builder(
                builder: (context) {
                  final String imageUrl = _getFullImageUrl(serverDocument);

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showServerMarksheetPreview(context, imageUrl);
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text("View Marksheet"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(
                            ColorResources.red_color),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteEducationDialog(int index) {
    final edu = educationList[index];
    final String educationId = edu["educationId"]?.toString() ?? '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Delete Education Detail",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey),
            ],
          ),

          content: const Text(
            "Are you sure you want to delete this education detail?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),

          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorHelperClass.getColorFromHex(
                    ColorResources.red_color),
                side: BorderSide(
                  color: ColorHelperClass.getColorFromHex(
                      ColorResources.red_color),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                try {
                  final response =
                  await _deleteRepo.deleteEducation({
                    "shiksha_applicant_education_id": educationId,
                  });

                  if (response.status != true) {
                    throw Exception(response.message);
                  }

                  Navigator.pop(dialogContext);

                  setState(() {
                    educationList.removeAt(index);
                  });

                  await _fetchEducationData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                      Text("Education detail deleted successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(
                    ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
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

    if (_educationDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload Marksheet / Certificate"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final educationData = AddEducationDetailData(
        shikshaApplicantId: widget.applicationData.shikshaApplicantId,
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

      final String educationId =
          response.data?.shikshaApplicantEducationId?.toString() ?? '';

      if (educationId.isEmpty) {
        throw Exception("Education ID not returned from server");
      }

      final uploadResponse = await _markSheetRepo.uploadMarkSheet(
        shikshaApplicantId: widget.applicationData.shikshaApplicantId!,
        educationId: educationId,
        filePath: _educationDocument!.path,
      );

      if (uploadResponse.status != true) {
        throw Exception(uploadResponse.message);
      }

      Navigator.pop(context);

      _educationDocument = null;

      await _fetchEducationData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Education and Marksheet uploaded successfully"),
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

      if (_educationDocument != null) {
        final uploadResponse = await _markSheetRepo.uploadMarkSheet(
          shikshaApplicantId: widget.applicationData.shikshaApplicantId!,
          educationId: educationId,
          filePath: _educationDocument!.path,
        );

        if (uploadResponse.status != true) {
          throw Exception(uploadResponse.message);
        }
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

  void _showEducationForm(BuildContext context,
      {Map<String, dynamic>? existingData, int? index}) {
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
      final existingStandard = existingData["class"] ?? '';
      final existingOther = existingData["otherEducationDetails"] ?? '';

      if (existingStandard == "Other") {
        selectedClass = "Other";
        otherClassCtrl.text = existingOther;
      } else {
        selectedClass = existingStandard;
      }
      schoolCtrl.text = existingData["school"] ?? '';
      boardCtrl.text = existingData["board"] ?? '';
      passedCtrl.text = existingData["passed"] ?? '';
      marksCtrl.text = existingData["marks"] ?? '';
    }

    bool isFormValid() {
      if (selectedClass.isEmpty) return false;
      if (schoolCtrl.text.trim().isEmpty) return false;
      if (boardCtrl.text.trim().isEmpty) return false;
      if (passedCtrl.text.trim().isEmpty) return false;
      if (marksCtrl.text.trim().isEmpty) return false;
      if (selectedClass == "Other" && otherClassCtrl.text.trim().isEmpty) {
        return false;
      }
      return true;
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
                              foregroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              side: BorderSide(
                                color: ColorHelperClass.getColorFromHex(
                                    ColorResources.red_color),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: !isFormValid() || isSubmitting
                                ? null
                                : () async {
                                    if (isEditMode) {
                                      final educationId =
                                          existingData?["educationId"];

                                      if (educationId == null ||
                                          educationId.toString().isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text("Education ID missing"),
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
                              backgroundColor: ColorHelperClass.getColorFromHex(
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
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
                                    .map((c) => DropdownMenuItem<String>(
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
                              onChanged: (_) => setModalState(() {}),
                              decoration:
                                  _inputDecoration('School / College Name *'),
                            ),
                            const SizedBox(height: 20),

                            /// 🔹 NEW FIELD - BOARD / UNIVERSITY
                            TextFormField(
                              controller: boardCtrl,
                              onChanged: (_) => setModalState(() {}),
                              decoration:
                                  _inputDecoration('Board / University *'),
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
                              onChanged: (_) => setModalState(() {}),
                              decoration: _inputDecoration(
                                  'Marks Obtained / Total Marks *'),
                            ),
                            const SizedBox(height: 25),

                            _buildEducationUploadField(
                              context,
                              setModalState,
                            )
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
          controller.text = DateFormat('MM/yyyy').format(selected);
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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

  Widget _buildEducationUploadField(
      BuildContext context,
      StateSetter setModalState,
      ) {
    final bool isUploaded = _educationDocument != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isUploaded)
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _educationDocument!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () {
                    setModalState(() {
                      _educationDocument = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _showEducationImagePicker(context, setModalState);
            },
            icon: Icon(
              isUploaded ? Icons.check_circle : Icons.upload_file,
            ),
            label: Text(
              isUploaded
                  ? "Marksheet Uploaded"
                  : "Upload Marksheet / Certificate",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded
                  ? Colors.green
                  : ColorHelperClass.getColorFromHex(
                  ColorResources.red_color),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    if (path.startsWith('http')) {
      return path;
    }

    return "${Urls.base_url.replaceAll(RegExp(r'/$'), '')}/${path.replaceAll(RegExp(r'^/'), '')}";
  }

  void _showServerMarksheetPreview(
    BuildContext context,
    String imageUrl,
  ) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              "Marksheet Document",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: imageUrl.toLowerCase().endsWith(".pdf")
                    ? const Center(
                        child: Icon(
                          Icons.picture_as_pdf,
                          size: 80,
                          color: Colors.red,
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("Unable to load document"),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("Close"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEducationImagePicker(
      BuildContext context,
      StateSetter setModalState,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text("Take a Picture"),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                await _picker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setModalState(() {
                    _educationDocument = File(picked.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.redAccent),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                await _picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setModalState(() {
                    _educationDocument = File(picked.path);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}
