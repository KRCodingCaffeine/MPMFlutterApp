import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:mpm/model/ShikshaSahayata/ReferredMember/AddReferredMember/AddReferredMemberData.dart';
import 'package:mpm/model/ShikshaSahayata/ReferredMember/UpdateReferredMember/UpdateReferredMemberData.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ReferredMemberRepo/add_referred_member_repository/add_referred_member_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ReferredMemberRepo/update_referred_member_repository/update_referred_member_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ShikshaApplicationRepo/shiksha_application_repository/shiksha_application_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/shiksha_sahayata_by_parenting_view.dart';

class ReferenceYourselfView extends StatefulWidget {
  final String shikshaApplicantId;

  const ReferenceYourselfView({
    Key? key,
    required this.shikshaApplicantId,
  }) : super(key: key);

  @override
  State<ReferenceYourselfView> createState() => _ReferenceYourselfViewState();
}

class _ReferenceYourselfViewState extends State<ReferenceYourselfView> {
  String hasOtherCharity = '';
  final List<Map<String, dynamic>> charityList = [];

  final AddReferredMemberRepository _addRepo = AddReferredMemberRepository();
  final UpdateReferredMemberRepository _updateRepo =
      UpdateReferredMemberRepository();
  final ShikshaApplicationRepository _shikshaRepo =
      ShikshaApplicationRepository();

  bool isLoading = true;
  bool isSubmitting = false;
  String? currentMemberId;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
    _fetchReferredMembers();
  }

  void _loadSessionData() async {
    final userData = await SessionManager.getSession();
    setState(() {
      currentMemberId = userData?.memberId?.toString();
    });
  }

  Future<void> _fetchReferredMembers() async {
    try {
      setState(() => isLoading = true);

      final response = await _shikshaRepo.fetchShikshaApplicationById(
        applicantId: widget.shikshaApplicantId,
      );

      charityList.clear();

      final references = response.data?.referredMembers ?? [];

      for (var ref in references) {
        charityList.add({
          "referenceId": ref.shikshaApplicantReferredMemberId?.toString(),
          "name": ref.referedMemberName ?? "",
          "address": ref.referedMemberAddress ?? "",
          "mobile": ref.referedMemberMobile ?? "",
          "email": ref.referedMemberEmail ?? "",
          "memberCode": ref.referedMemberMemberCode ?? "",
        });
      }

      setState(() => isLoading = false);
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
              "References",
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
                "No reference has been added yet",
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
                        /// 🔥 HEADER (Reference Name)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item["name"] ?? "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showReferenceSheet(
                                  context,
                                  existingData: item,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFDC3545),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              child: const Text(
                                "Edit",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 20),

                        _infoRow("Address", item["address"] ?? ""),
                        const SizedBox(height: 8),

                        _infoRow("Mobile", item["mobile"] ?? ""),
                        const SizedBox(height: 8),

                        _infoRow("Email", item["email"] ?? ""),
                        const SizedBox(height: 8),

                        _infoRow("Member Code", item["memberCode"] ?? ""),
                      ],
                    ),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.red_color),
        onPressed: () {
          _showReferenceSheet(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar:
          charityList.isNotEmpty ? _buildBottomNextBar() : null,
    );
  }

  Future<void> _submitReference({
    required String name,
    required String address,
    required String mobile,
    required String email,
    required String memberCode,
  }) async {
    if (isSubmitting) return;

    setState(() => isSubmitting = true);

    try {
      final model = AddReferredMemberData(
        shikshaApplicantId: widget.shikshaApplicantId,
        referedMemberName: name,
        referedMemberAddress: address,
        referedMemberMobile: mobile,
        referedMemberEmail: email,
        referedMemberMemberCode: memberCode,
        createdBy: currentMemberId,
      );

      final response = await _addRepo.addReferredMember(model.toJson());

      if (response.status != true) {
        throw Exception(response.message);
      }

      Navigator.pop(context);
      await _fetchReferredMembers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reference added successfully"),
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

  Future<void> _updateReference({
    required String referenceId,
    required String name,
    required String address,
    required String mobile,
    required String email,
    required String memberCode,
  }) async {
    if (isSubmitting) return;

    setState(() => isSubmitting = true);

    try {
      final model = UpdateReferredMemberData(
        shikshaApplicantReferredMemberId: referenceId,
        shikshaApplicantId: widget.shikshaApplicantId,
        referedMemberName: name,
        referedMemberAddress: address,
        referedMemberMobile: mobile,
        referedMemberEmail: email,
        referedMemberMemberCode: memberCode,
        updatedBy: currentMemberId,
      );

      final response = await _updateRepo.updateReferredMember(model.toJson());

      if (response.status != true) {
        throw Exception(response.message);
      }

      Navigator.pop(context);
      await _fetchReferredMembers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reference updated successfully"),
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

  void _showReferenceSheet(BuildContext context,
      {Map<String, dynamic>? existingData}) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final memberCodeCtrl = TextEditingController();

    bool isEditMode = existingData != null;

    if (isEditMode) {
      nameCtrl.text = existingData["name"] ?? "";
      addressCtrl.text = existingData["address"] ?? "";
      mobileCtrl.text = existingData["mobile"] ?? "";
      emailCtrl.text = existingData["email"] ?? "";
      memberCodeCtrl.text = existingData["memberCode"] ?? "";
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
                            onPressed: nameCtrl.text.isEmpty ||
                                    addressCtrl.text.isEmpty ||
                                    mobileCtrl.text.isEmpty ||
                                    emailCtrl.text.isEmpty ||
                                    isSubmitting
                                ? null
                                : () async {
                                    if (isEditMode) {
                                      await _updateReference(
                                        referenceId:
                                            existingData!["referenceId"],
                                        name: nameCtrl.text.trim(),
                                        address: addressCtrl.text.trim(),
                                        mobile: mobileCtrl.text.trim(),
                                        email: emailCtrl.text.trim(),
                                        memberCode: memberCodeCtrl.text.trim(),
                                      );
                                    } else {
                                      await _submitReference(
                                        name: nameCtrl.text.trim(),
                                        address: addressCtrl.text.trim(),
                                        mobile: mobileCtrl.text.trim(),
                                        email: emailCtrl.text.trim(),
                                        memberCode: memberCodeCtrl.text.trim(),
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
                                : Text(
                                    isEditMode
                                        ? "Update Reference"
                                        : "Add Reference",
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
                                "Reference Details",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildTextField(
                              label: "Reference Name *",
                              controller: nameCtrl,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              label: "Member Code",
                              controller: memberCodeCtrl,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              label: "Mobile Number *",
                              controller: mobileCtrl,
                              keyboard: TextInputType.phone,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              label: "Email Address *",
                              controller: emailCtrl,
                              keyboard: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              label: "Address *",
                              controller: addressCtrl,
                            ),
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
              onPressed: () {
                Navigator.push(
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
      onChanged: (_) => setState(() {}),
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
          controller.text = DateFormat('yyyy-MM-dd').format(picked);
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
