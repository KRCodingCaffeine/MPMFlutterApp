import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:mpm/model/ShikshaSahayata/ReceivedLoan/AddReceivedLoan/AddReceivedLoanData.dart';
import 'package:mpm/model/ShikshaSahayata/ReceivedLoan/UpdateReceivedLoan/UpdateReceivedLoanData.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ReceivedLoanRepo/add_received_loan_repository/add_received_loan_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ReceivedLoanRepo/delete_received_loan_repository/delete_received_loan_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ReceivedLoanRepo/update_received_loan_repository/update_received_loan_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ShikshaApplicationRepo/shiksha_application_repository/shiksha_application_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/current_year_any_other_loan.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/reference.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/shiksha_sahayata_by_parenting_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreviousYearLoanView extends StatefulWidget {
  final String shikshaApplicantId;

  const PreviousYearLoanView({
    Key? key,
    required this.shikshaApplicantId,
  }) : super(key: key);

  @override
  State<PreviousYearLoanView> createState() => _PreviousYearLoanViewState();
}

class _PreviousYearLoanViewState extends State<PreviousYearLoanView> {
  String hasOtherCharity = '';
  final List<Map<String, dynamic>> charityList = [];

  final AddReceivedLoanRepository _addRepo = AddReceivedLoanRepository();
  final UpdateReceivedLoanRepository _updateRepo = UpdateReceivedLoanRepository();
  final DeleteReceivedLoanRepository _deleteRepo = DeleteReceivedLoanRepository();
  final ShikshaApplicationRepository _shikshaRepo =
  ShikshaApplicationRepository();

  bool isLoading = true;
  bool isSubmitting = false;
  String? currentMemberId;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
    _fetchReceivedLoanData();
  }

  void _loadSessionData() async {
    final userData = await SessionManager.getSession();
    setState(() {
      currentMemberId = userData?.memberId?.toString();
    });
  }

  Future<void> _fetchReceivedLoanData() async {
    try {
      setState(() => isLoading = true);

      final response = await _shikshaRepo.fetchShikshaApplicationById(
        applicantId: widget.shikshaApplicantId,
      );

      charityList.clear();

      final loans = response.data?.receivedLoans ?? [];

      for (var loan in loans) {
        if (loan.appliedYearOn == "previous") {
          charityList.add({
            "loanId": loan.shikshaApplicantReceivedLoanId?.toString(),
            "loanFrom": loan.receivedFrom ?? "",
            "school": loan.schoolCollegeName ?? "",
            "course": loan.courseName ?? "",
            "whichYear": loan.yearOfEducation ?? "",
            "amount": loan.amountReceived ?? "",
            "receivedOn": loan.amountReceivedOn ?? "",
            "otherCharity": loan.otherCharityName ?? "",
          });
        }
      }

      setState(() => isLoading = false);

      if (charityList.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showOtherCharitySheet(context);
          }
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
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
              "Received Loan in Past",
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
      body: charityList.isEmpty
          ? const Center(
              child: Text(
                "No previous year loan has been added yet",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: charityList.length,
          itemBuilder: (context, index) {
            final item = charityList[index];

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

                    /// 🔥 HEADER (Loan From + Popup Menu)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item["loanFrom"] == "mpm"
                                ? "Maheshwari Pragati Mandal (MPM)"
                                : item["loanFrom"] == "other"
                                ? (item["otherCharity"] ?? "")
                                : "",
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
                            if (value == "edit") {
                              _showOtherCharitySheet(
                                context,
                                existingData: item,
                              );
                            } else if (value == "delete") {
                              _showDeleteDialog(item["loanId"]);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: "edit",
                              child: Text(
                                "Edit Loan Detail",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: "delete",
                              child: Text(
                                "Delete Loan Detail",
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

                    _infoRow("School", item["school"] ?? ""),
                    const SizedBox(height: 8),

                    _infoRow("Course", item["course"] ?? ""),
                    const SizedBox(height: 8),

                    _infoRow("Year", item["whichYear"] ?? ""),
                    const SizedBox(height: 8),

                    _infoRow("Amount", "₹ ${item["amount"] ?? ""}"),
                    const SizedBox(height: 8),

                    _infoRow("Received On", item["receivedOn"] ?? ""),
                  ],
                ),
              ),
            );
          }
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.red_color),
        onPressed: () {
          _showOtherCharitySheet(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar:
      charityList.isNotEmpty ? _buildBottomNextBar() : null,
    );
  }

  void _showDeleteDialog(String loanId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                "Delete Loan Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),

          content: const Text(
            "Are you sure you want to delete this loan detail?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),

          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
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
                  await _deleteRepo.deleteReceivedLoan({
                    "shiksha_applicant_received_loan_id": loanId,
                  });

                  if (response.status != true) {
                    throw Exception(response.message);
                  }

                  Navigator.pop(context);
                  await _fetchReceivedLoanData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Previous year loan deleted successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
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
              style: ElevatedButton.styleFrom(
                backgroundColor:
                ColorHelperClass.getColorFromHex(
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

  Future<void> _submitReceivedLoan({
    required String receivedFrom,
    required String school,
    required String course,
    required String year,
    required String amount,
    required String receivedOn,
    required String otherCharity,
  }) async {

    if (isSubmitting) return;

    setState(() => isSubmitting = true);

    try {
      final model = AddReceivedLoanData(
        shikshaApplicantId: widget.shikshaApplicantId,
        schoolCollegeName: school,
        courseName: course,
        yearOfEducation: year,
        amountReceived: amount,
        receivedFrom: receivedFrom,
        amountReceivedOn: receivedOn,
        appliedYearOn: "previous", // 🔥 ONLY CHANGE
        otherCharityName: otherCharity,
        createdBy: currentMemberId,
      );

      final response = await _addRepo.addReceivedLoan(model.toJson());

      if (response.status != true) {
        throw Exception(response.message);
      }

      Navigator.pop(context);
      await _fetchReceivedLoanData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Previous year loan added successfully"),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> _updateReceivedLoan({
    required String loanId,
    required String receivedFrom,
    required String school,
    required String course,
    required String year,
    required String amount,
    required String receivedOn,
    required String otherCharity,
  }) async {

    if (isSubmitting) return;

    setState(() => isSubmitting = true);

    try {
      final model = UpdateReceivedLoanData(
        shikshaApplicantReceivedLoanId: loanId,
        shikshaApplicantId: widget.shikshaApplicantId,
        schoolCollegeName: school,
        courseName: course,
        yearOfEducation: year,
        amountReceived: amount,
        receivedFrom: receivedFrom,
        amountReceivedOn: receivedOn,
        appliedYearOn: "previous",
        otherCharityName: otherCharity,
        updatedBy: currentMemberId,
      );

      final response = await _updateRepo.updateReceivedLoan(model.toJson());

      if (response.status != true) {
        throw Exception(response.message);
      }

      Navigator.pop(context);
      await _fetchReceivedLoanData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Previous year loan updated successfully"),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _showOtherCharitySheet(BuildContext context,
      {Map<String, dynamic>? existingData}) {
    String selectedLoanFrom = '';

    final TextEditingController otherCharityCtrl = TextEditingController();
    final TextEditingController schoolCtrl = TextEditingController();
    final TextEditingController courseCtrl = TextEditingController();
    final TextEditingController whichYearCtrl = TextEditingController();
    final TextEditingController amountCtrl = TextEditingController();
    final TextEditingController receivedOnCtrl = TextEditingController();

    bool isEditMode = existingData != null;

    if (isEditMode) {
      final loanFromText = existingData["loanFrom"] ?? "";

      if (loanFromText == "mpm") {
        selectedLoanFrom = "MPM";
      } else if (loanFromText == "other") {
        selectedLoanFrom = "OTHER";
        otherCharityCtrl.text = existingData["otherCharity"] ?? "";
      }

      schoolCtrl.text = existingData["school"] ?? "";
      courseCtrl.text = existingData["course"] ?? "";
      whichYearCtrl.text = existingData["whichYear"] ?? "";
      amountCtrl.text = existingData["amount"] ?? "";
      receivedOnCtrl.text = existingData["receivedOn"] ?? "";
    }

    bool isFormValid() {
      return selectedLoanFrom.isNotEmpty &&
          schoolCtrl.text.trim().isNotEmpty &&
          courseCtrl.text.trim().isNotEmpty &&
          whichYearCtrl.text.trim().isNotEmpty &&
          amountCtrl.text.trim().isNotEmpty &&
          receivedOnCtrl.text.trim().isNotEmpty &&
          !(selectedLoanFrom == "OTHER" &&
              otherCharityCtrl.text.trim().isEmpty);
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
                heightFactor: 0.8,
                child: Column(
                  children: [
                    /// 🔹 TOP BAR
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
                            onPressed: !isFormValid() || isSubmitting
                                ? null
                                : () async {
                              final receivedFromValue =
                              selectedLoanFrom == "MPM" ? "mpm" : "other";

                              final otherCharityValue =
                              selectedLoanFrom == "OTHER"
                                  ? otherCharityCtrl.text.trim()
                                  : "";

                              if (isEditMode) {
                                await _updateReceivedLoan(
                                  loanId: existingData!["loanId"],
                                  receivedFrom: receivedFromValue,
                                  school: schoolCtrl.text.trim(),
                                  course: courseCtrl.text.trim(),
                                  year: whichYearCtrl.text.trim(),
                                  amount: amountCtrl.text.trim(),
                                  receivedOn: receivedOnCtrl.text.trim(),
                                  otherCharity: otherCharityValue,
                                );
                              } else {
                                await _submitReceivedLoan(
                                  receivedFrom: receivedFromValue,
                                  school: schoolCtrl.text.trim(),
                                  course: courseCtrl.text.trim(),
                                  year: whichYearCtrl.text.trim(),
                                  amount: amountCtrl.text.trim(),
                                  receivedOn: receivedOnCtrl.text.trim(),
                                  otherCharity: otherCharityValue,
                                );
                              }
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
                            child: isSubmitting
                                ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              isEditMode
                                  ? "Update Loan Detail"
                                  : "Add Loan Detail",
                            ),
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
                                "Previous Year Loan Details",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            /// 🔹 LOAN RECEIVED FROM DROPDOWN
                            InputDecorator(
                              decoration: InputDecoration(
                                labelText: "Loan Received From *",
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
                                underline: const SizedBox(),
                                value: selectedLoanFrom.isEmpty
                                    ? null
                                    : selectedLoanFrom,
                                hint: const Text("Select Option"),
                                items: const [
                                  DropdownMenuItem(
                                    value: "MPM",
                                    child:
                                    Text("Maheshwari Pragati Mandal (MPM)"),
                                  ),
                                  DropdownMenuItem(
                                    value: "OTHER",
                                    child: Text("Other Charity Name"),
                                  ),
                                ],
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedLoanFrom = value!;
                                    otherCharityCtrl.clear();
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// 🔹 SHOW TEXT FIELD IF OTHER SELECTED
                            if (selectedLoanFrom == "OTHER") ...[
                              TextFormField(
                                controller: otherCharityCtrl,
                                decoration: _inputDecoration(
                                    "Enter Other Charity Name *"),
                                onChanged: (_) => setModalState(() {}),
                              ),
                              const SizedBox(height: 20),
                            ],

                            _buildTextField(
                              label: "School / College *",
                              controller: schoolCtrl,
                              setModalState: setModalState,
                            ),
                            const SizedBox(height: 20),

                            _buildTextField(
                              label: "Course Name *",
                              controller: courseCtrl,
                              setModalState: setModalState,
                            ),
                            const SizedBox(height: 20),

                            /// 🔥 MONTH / YEAR FIELD
                            themedMonthYearPickerField(
                              context: context,
                              label: "Which Year (Month / Year) *",
                              controller: whichYearCtrl,
                            ),
                            const SizedBox(height: 20),

                            _buildTextField(
                              label: "Amount Received (₹) *",
                              controller: amountCtrl,
                              setModalState: setModalState,
                              keyboard: TextInputType.number,
                            ),
                            const SizedBox(height: 20),

                            /// 🔥 DATE PICKER
                            themedDatePickerField(
                              context: context,
                              label: "Amount Received On *",
                              controller: receivedOnCtrl,
                            ),
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

  // ===================== HELPERS =====================

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
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('previous_loan_completed', true);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReferenceView(
                      shikshaApplicantId: widget.shikshaApplicantId,
                    ),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 14)),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Function(VoidCallback) setModalState,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
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
      onChanged: (_) => setModalState(() {}),
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

  Widget themedDatePickerField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      readOnly: true,
      controller: controller,
      decoration: _inputDecoration(label),
      onTap: () async {
        DateTime? picked = await showDatePicker(
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

        if (picked != null) {
          controller.text =
              DateFormat('yyyy-MM-dd').format(picked);
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
}
