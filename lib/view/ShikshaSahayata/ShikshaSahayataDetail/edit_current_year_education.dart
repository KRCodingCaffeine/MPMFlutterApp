import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/model/ShikshaSahayata/CurrentYearEducationDetail/AddRequestedLoanEducation/AddRequestedLoanEducationData.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/RequestedLoanEducation.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplicationsByAppliedBy/ShikshaApplicationsByAppliedByData.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/CurrentYearEducationalDetailRepo/add_requested_loan_education_repository/add_requested_loan_education_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/CurrentYearEducationalDetailRepo/admission_letter_upload_repository/admission_letter_upload_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/CurrentYearEducationalDetailRepo/bonafide_letter_upload_repository/bonafide_letter_upload_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/CurrentYearEducationalDetailRepo/delete_requested_loan_education_repository/delete_requested_loan_education_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/CurrentYearEducationalDetailRepo/update_requested_loan_education_repository/update_requested_loan_education_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ShikshaApplicationRepo/shiksha_application_repository/shiksha_application_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/current_year_any_other_loan.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/previous_year_loan.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/shiksha_sahayata_by_parenting_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditCurrentYearEducationView extends StatefulWidget {
  final ShikshaApplicationsByAppliedByData applicationData;

  const EditCurrentYearEducationView({
    Key? key,
    required this.applicationData,
  }) : super(key: key);

  @override
  State<EditCurrentYearEducationView> createState() =>
      _EditCurrentYearEducationViewState();
}

class _EditCurrentYearEducationViewState extends State<EditCurrentYearEducationView> {
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? currentYearData;
  bool isLoading = false;
  bool isSubmitting = false;
  String? currentMemberId;

  String appliedYear = '';
  String schoolName = '';
  String courseDuration = '';
  String admissionFees = '';
  String yearlyFees = '';
  String examinationFees = '';
  String otherExpenses = '';
  String totalExpenses = '';
  File? _admissionDocument;
  File? _bonafideDocument;

  final AddRequestedLoanEducationRepository _addRepo =
      AddRequestedLoanEducationRepository();
  final UpdateRequestedLoanEducationRepository _updateRepo =
      UpdateRequestedLoanEducationRepository();
  final DeleteRequestedLoanEducationRepository _deleteRepo =
      DeleteRequestedLoanEducationRepository();
  final AdmissionUploadRepository _admissionRepo = AdmissionUploadRepository();
  final BonafideUploadRepository _bonafideRepo = BonafideUploadRepository();

  final ShikshaApplicationRepository _shikshaRepo =
      ShikshaApplicationRepository();

  @override
  void initState() {
    super.initState();
    _loadSessionData();
    _fetchCurrentYearEducation();
  }

  void _loadSessionData() async {
    final userData = await SessionManager.getSession();

    setState(() {
      currentMemberId = userData?.memberId?.toString();
    });
  }

  Future<void> _fetchCurrentYearEducation() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await _shikshaRepo.fetchShikshaApplicationById(
        applicantId: widget.applicationData.shikshaApplicantId!,
      );

      if (response.status == true && response.data != null) {
        final List<RequestedLoanEducation>? eduList =
            response.data?.requestedLoanEducation;

        if (eduList != null && eduList.isNotEmpty) {
          final edu = eduList.first;

          setState(() {
            currentYearData = {
              "educationId": edu.shikshaApplicantRequestedLoanEducationId,
              "standard": edu.standard,
              "school": edu.schoolCollegeName,
              "duration": edu.courseDuration,
              "admissionFees": edu.admissionFees,
              "yearlyFees": edu.yearlyFees,
              "examFees": edu.examinationFees,
              "otherExpenses": edu.otherExpenses,
              "total": edu.totalExpenses,
              "admissionDoc": edu.admissionConfirmationLetterDoc,
              "bonafideDoc": edu.bonafideFeesDocument,
            };
          });
        }

        setState(() {
          isLoading = false;
        });

        /// 🔥 AUTO OPEN ONLY IF NO DATA
        if (currentYearData == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCurrentYearEducationSheet(context);
          });
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
              "Current Year Education",
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
      body: currentYearData == null
          ? const Center(
              child: Text(
                "No current year education details added",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : _buildCurrentYearEducationCard(),
      floatingActionButton: currentYearData == null
          ? FloatingActionButton(
              backgroundColor:
                  ColorHelperClass.getColorFromHex(ColorResources.red_color),
              onPressed: () {
                _showCurrentYearEducationSheet(context);
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildCurrentYearEducationCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔥 HEADER WITH EDIT / DELETE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      currentYearData?["standard"] ?? "",
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
                        _showCurrentYearEducationSheet(
                          context,
                          existingData: currentYearData,
                        );
                      } else if (value == 'delete') {
                        _showDeleteDialog(
                          currentYearData!["educationId"],
                        );
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
                      onPressed: null, // Important
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

              _infoRow("Applied For", currentYearData?["standard"] ?? ""),
              _infoRow("College", currentYearData?["school"] ?? ""),
              _infoRow("Course Duration", currentYearData?["duration"] ?? ""),

              _infoRow("Admission Fees",
                  "₹ ${currentYearData?["admissionFees"] ?? "0"}"),
              _infoRow(
                  "Yearly Fees", "₹ ${currentYearData?["yearlyFees"] ?? "0"}"),
              _infoRow("Examination Fees",
                  "₹ ${currentYearData?["examFees"] ?? "0"}"),
              _infoRow("Other Expenses",
                  "₹ ${currentYearData?["otherExpenses"] ?? "0"}"),
              _infoRow("Total Fees", "₹ ${currentYearData?["total"] ?? "0"}"),

              if ((currentYearData?["admissionDoc"] ?? "")
                  .toString()
                  .isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final url = currentYearData?["admissionDoc"];
                      final fullUrl = _getFullImageUrl(url);

                      _showDocumentPreviewDialog(
                        context,
                        title: "Admission Confirmation Letter",
                        networkUrl: fullUrl,
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text("View Admission Confirmation"),
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
                ),
              const SizedBox(height: 20),

              if ((currentYearData?["bonafideDoc"] ?? "").toString().isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final url = currentYearData?["bonafideDoc"];
                      final fullUrl = _getFullImageUrl(url);

                      _showDocumentPreviewDialog(
                        context,
                        title: "Bonafide / Fees Proof",
                        networkUrl: fullUrl,
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text("View Bonafide / Fees Proof"),
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
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(String educationId) {
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
                foregroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
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
                      await _deleteRepo.deleteRequestedLoanEducation({
                    "shiksha_applicant_requested_loan_education_id":
                        educationId,
                  });

                  if (response.status != true) {
                    throw Exception(response.message);
                  }

                  Navigator.pop(dialogContext);

                  await _fetchCurrentYearEducation();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          " Current Year Education detail deleted successfully"),
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
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
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

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    if (path.startsWith('http')) {
      return path;
    }

    return "${Urls.base_url}/$path";
  }

  Future<void> _submitRequestedLoanEducation({
    required String standard,
    required String school,
    required String courseDuration,
    required String admissionFees,
    required String yearlyFees,
    required String examFees,
    required String otherExpenses,
    required String totalExpenses,
  }) async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    try {
      final model = AddRequestedLoanEducationData(
        shikshaApplicantId: widget.applicationData.shikshaApplicantId,
        standard: standard,
        schoolCollegeName: school,
        courseDuration: courseDuration,
        admissionFees: admissionFees,
        yearlyFees: yearlyFees,
        examinationFees: examFees,
        otherExpenses: otherExpenses,
        totalExpenses: totalExpenses,
        createdBy: currentMemberId,
      );

      final response = await _addRepo.addRequestedLoanEducation(model.toJson());

      if (response.status != true) {
        throw Exception(response.message);
      }

      final String educationId =
          response.data?.shikshaApplicantRequestedLoanEducationId?.toString() ??
              '';

      if (educationId.isEmpty) {
        throw Exception("Education ID not returned from server");
      }

      if (_admissionDocument != null) {
        final uploadResponse = await _admissionRepo.uploadAdmissionLetter(
          shikshaApplicantId: widget.applicationData.shikshaApplicantId!,
          educationId: educationId,
          filePath: _admissionDocument!.path,
        );

        if (uploadResponse.status != true) {
          throw Exception(uploadResponse.message);
        }
      }

      if (_bonafideDocument != null) {
        final bonafideResponse = await _bonafideRepo.uploadBonafideDocument(
          shikshaApplicantId: widget.applicationData.shikshaApplicantId!,
          educationId: educationId,
          filePath: _bonafideDocument!.path,
        );

        if (bonafideResponse.status != true) {
          throw Exception(bonafideResponse.message);
        }
      }

      Navigator.pop(context);
      await _fetchCurrentYearEducation();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Education and documents uploaded successfully"),
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
      setState(() => isSubmitting = false);
    }
  }

  Future<void> _updateRequestedLoanEducation({
    required String educationId,
    required String standard,
    required String school,
    required String courseDuration,
    required String admissionFees,
    required String yearlyFees,
    required String examFees,
    required String otherExpenses,
    required String totalExpenses,
  }) async {
    if (isSubmitting) return;

    setState(() => isSubmitting = true);

    try {
      final response = await _updateRepo.updateRequestedLoanEducation({
        "shiksha_applicant_requested_loan_education_id": educationId,
        "standard" : standard,
        "school_college_name": school,
        "course_duration": courseDuration,
        "admission_fees": admissionFees,
        "yearly_fees": yearlyFees,
        "examination_fees": examFees,
        "other_expenses": otherExpenses,
        "total_expenses": totalExpenses,
        "updated_by": currentMemberId,
      });

      if (response.status != true) {
        throw Exception(response.message);
      }

      if (_admissionDocument != null) {
        final uploadResponse = await _admissionRepo.uploadAdmissionLetter(
          shikshaApplicantId: widget.applicationData.shikshaApplicantId!,
          educationId: educationId,
          filePath: _admissionDocument!.path,
        );

        if (uploadResponse.status != true) {
          throw Exception(uploadResponse.message);
        }
      }

      if (_bonafideDocument != null) {
        final bonafideResponse = await _bonafideRepo.uploadBonafideDocument(
          shikshaApplicantId: widget.applicationData.shikshaApplicantId!,
          educationId: educationId,
          filePath: _bonafideDocument!.path,
        );

        if (bonafideResponse.status != true) {
          throw Exception(bonafideResponse.message);
        }
      }

      Navigator.pop(context);

      await _fetchCurrentYearEducation();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Education details updated successfully"),
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
      setState(() => isSubmitting = false);
    }
  }

  // ===================== BOTTOM SHEET =====================

  void _showCurrentYearEducationSheet(BuildContext context,
      {Map<String, dynamic>? existingData}) {
    bool isEditMode = existingData != null;

    final TextEditingController yearCtrl = TextEditingController();
    final TextEditingController schoolCtrl = TextEditingController();
    final TextEditingController courseDurationCtrl = TextEditingController();
    final TextEditingController admissionFeesCtrl = TextEditingController();
    final TextEditingController yearlyFeesCtrl = TextEditingController();
    final TextEditingController examFeesCtrl = TextEditingController();
    final TextEditingController otherExpensesCtrl = TextEditingController();
    final TextEditingController totalExpensesCtrl = TextEditingController();

    void calculateTotal() {
      double admission = double.tryParse(admissionFeesCtrl.text) ?? 0;
      double yearly = double.tryParse(yearlyFeesCtrl.text) ?? 0;
      double exam = double.tryParse(examFeesCtrl.text) ?? 0;
      double other = double.tryParse(otherExpensesCtrl.text) ?? 0;

      double total = admission + yearly + exam + other;

      totalExpensesCtrl.text = total.toStringAsFixed(0);
    }

    if (isEditMode) {
      yearCtrl.text = existingData["standard"] ?? "";
      schoolCtrl.text = existingData["school"] ?? "";
      courseDurationCtrl.text = existingData["duration"] ?? "";
      admissionFeesCtrl.text = existingData["admissionFees"] ?? "";
      yearlyFeesCtrl.text = existingData["yearlyFees"] ?? "";
      examFeesCtrl.text = existingData["examFees"] ?? "";
      otherExpensesCtrl.text = existingData["otherExpenses"] ?? "";
      totalExpensesCtrl.text = existingData["total"] ?? "";
    }

    admissionFeesCtrl.addListener(calculateTotal);
    yearlyFeesCtrl.addListener(calculateTotal);
    examFeesCtrl.addListener(calculateTotal);
    otherExpensesCtrl.addListener(calculateTotal);

    bool isFormValid() {
      return yearCtrl.text.trim().isNotEmpty &&
          schoolCtrl.text.trim().isNotEmpty &&
          courseDurationCtrl.text.trim().isNotEmpty;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.7,
                child: Column(
                  children: [
                    /// 🔹 TOP ACTION BAR (FIXED)
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
                                      await _updateRequestedLoanEducation(
                                        educationId:
                                            existingData!["educationId"]
                                                .toString(),
                                        standard: yearCtrl.text.trim(),
                                        school: schoolCtrl.text.trim(),
                                        courseDuration:
                                        courseDurationCtrl.text.trim(),
                                        admissionFees: admissionFeesCtrl.text,
                                        yearlyFees: yearlyFeesCtrl.text,
                                        examFees: examFeesCtrl.text,
                                        otherExpenses: otherExpensesCtrl.text,
                                        totalExpenses: totalExpensesCtrl.text,
                                      );
                                    } else {
                                      await _submitRequestedLoanEducation(
                                        standard: yearCtrl.text.trim(),
                                        school: schoolCtrl.text.trim(),
                                        courseDuration:
                                            courseDurationCtrl.text.trim(),
                                        admissionFees: admissionFeesCtrl.text,
                                        yearlyFees: yearlyFeesCtrl.text,
                                        examFees: examFeesCtrl.text,
                                        otherExpenses: otherExpensesCtrl.text,
                                        totalExpenses: totalExpensesCtrl.text,
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
                                    ? "Update Details"
                                    : "Add Details"),
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
                                "Current Year Education Detail",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            /// 🔹 CURRENT YEAR APPLIED FOR
                            _buildTextField(
                              label: "Current Year Applied For *",
                              controller: yearCtrl,
                              hint: "Eg: FY BSc / 1st Year / Class 10",
                              setModalState: setModalState,
                            ),
                            const SizedBox(height: 20),

                            /// 🔹 COLLEGE / SCHOOL NAME
                            _buildTextField(
                              label: "College / School Name *",
                              controller: schoolCtrl,
                              setModalState: setModalState,
                            ),
                            const SizedBox(height: 20),

                            /// 🔹 COURSE DURATION
                            _buildTextField(
                              label: "Course Duration *",
                              controller: courseDurationCtrl,
                              hint: "Eg: 3 Years",
                              setModalState: setModalState,
                            ),

                            const SizedBox(height: 20),

                            /// 🔹 ADMISSION FEES
                            _buildTextField(
                              label: "Admission Fees (₹)",
                              controller: admissionFeesCtrl,
                              keyboard: TextInputType.number,
                              setModalState: setModalState,
                            ),

                            const SizedBox(height: 20),

                            /// 🔹 YEARLY FEES
                            _buildTextField(
                              label: "Yearly Fees (₹)",
                              controller: yearlyFeesCtrl,
                              keyboard: TextInputType.number,
                              setModalState: setModalState,
                            ),

                            const SizedBox(height: 20),

                            /// 🔹 EXAMINATION FEES
                            _buildTextField(
                              label: "Examination Fees (₹)",
                              controller: examFeesCtrl,
                              keyboard: TextInputType.number,
                              setModalState: setModalState,
                            ),

                            const SizedBox(height: 20),

                            /// 🔹 OTHER EXPENSES
                            _buildTextField(
                              label: "Other Expenses (₹)",
                              controller: otherExpensesCtrl,
                              keyboard: TextInputType.number,
                              setModalState: setModalState,
                            ),

                            const SizedBox(height: 20),

                            /// 🔹 TOTAL EXPENSES
                            _buildTextField(
                              label: "Total Expenses (₹)",
                              controller: totalExpensesCtrl,
                              keyboard: TextInputType.number,
                              readOnly: true,
                              setModalState: setModalState,
                            ),
                            const SizedBox(height: 20),

                            _buildAdmissionUploadField(context, setModalState),
                            const SizedBox(height: 20),
                            _buildBonafideUploadField(context, setModalState),
                            const SizedBox(height: 40),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Function(VoidCallback) setModalState,
    String? hint,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      readOnly: readOnly,
      onChanged: (_) => setModalState(() {}),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const Text(": "),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdmissionUploadField(
    BuildContext context,
    StateSetter setModalState,
  ) {
    final bool isUploaded = _admissionDocument != null ||
        (currentYearData?["admissionDoc"] ?? "").toString().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_admissionDocument != null)
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
                    _admissionDocument!,
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
                      _admissionDocument = null;
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
            onPressed: () => _showAdmissionImagePicker(context, setModalState),
            icon: Icon(
              isUploaded ? Icons.check_circle : Icons.upload_file,
            ),
            label: Text(
              isUploaded
                  ? "Admission Letter Uploaded"
                  : "Upload Admission Confirmation Letter",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded
                  ? Colors.green
                  : ColorHelperClass.getColorFromHex(ColorResources.red_color),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBonafideUploadField(
    BuildContext context,
    StateSetter setModalState,
  ) {
    final bool isUploaded = _bonafideDocument != null ||
        (currentYearData?["bonafideDoc"] ?? "").toString().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_bonafideDocument != null)
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
                    _bonafideDocument!,
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
                      _bonafideDocument = null;
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
            onPressed: () => _showBonafideImagePicker(context, setModalState),
            icon: Icon(
              isUploaded ? Icons.check_circle : Icons.upload_file,
            ),
            label: Text(
              isUploaded ? "Bonafide Uploaded" : "Upload Bonafide / Fees Proof",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded
                  ? Colors.green
                  : ColorHelperClass.getColorFromHex(ColorResources.red_color),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _showAdmissionImagePicker(
    BuildContext context,
    StateSetter setModalState,
  ) {
    showModalBottomSheet(
      context: context,
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
                    _admissionDocument = File(picked.path);
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
                    _admissionDocument = File(picked.path);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showBonafideImagePicker(
    BuildContext context,
    StateSetter setModalState,
  ) {
    showModalBottomSheet(
      context: context,
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
                    _bonafideDocument = File(picked.path);
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
                    _bonafideDocument = File(picked.path);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDocumentPreviewDialog(
    BuildContext context, {
    required String title,
    File? localFile,
    String? networkUrl,
  }) {
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            /// 🔥 Preview Area
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: localFile != null
                    ? Image.file(
                        localFile,
                        fit: BoxFit.contain,
                      )
                    : (networkUrl != null && networkUrl.isNotEmpty)
                        ? Image.network(
                            networkUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text("Unable to load document"),
                            ),
                          )
                        : const Center(
                            child: Text("No document available"),
                          ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(
                  ColorResources.red_color,
                ),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Close"),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
