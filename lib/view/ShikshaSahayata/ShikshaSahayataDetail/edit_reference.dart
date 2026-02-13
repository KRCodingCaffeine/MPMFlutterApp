import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:mpm/model/ShikshaSahayata/ReferredMember/AddReferredMember/AddReferredMemberData.dart';
import 'package:mpm/model/ShikshaSahayata/ReferredMember/UpdateReferredMember/UpdateReferredMemberData.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplicationsByAppliedBy/ShikshaApplicationsByAppliedByData.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ReferredMemberRepo/aadhaar_upload_repository/aadhaar_upload_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ReferredMemberRepo/add_referred_member_repository/add_referred_member_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ReferredMemberRepo/update_referred_member_repository/update_referred_member_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ShikshaApplicationRepo/shiksha_application_repository/shiksha_application_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/shiksha_sahayata_by_parenting_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditReferenceView extends StatefulWidget {
  final ShikshaApplicationsByAppliedByData applicationData;

  const EditReferenceView({
    Key? key,
    required this.applicationData,
  }) : super(key: key);

  @override
  State<EditReferenceView> createState() => _EditReferenceViewState();
}

class _EditReferenceViewState extends State<EditReferenceView> {
  File? referenceAadharFile;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  String hasOtherCharity = '';
  final List<Map<String, dynamic>> charityList = [];

  final AddReferredMemberRepository _addRepo = AddReferredMemberRepository();
  final UpdateReferredMemberRepository _updateRepo =
      UpdateReferredMemberRepository();
  final AadhaarUploadRepository _aadhaarRepo = AadhaarUploadRepository();
  final ShikshaApplicationRepository _shikshaRepo =
      ShikshaApplicationRepository();

  bool isLoading = true;
  bool isSubmitting = false;
  bool isExistingAadhaarRemoved = false;
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
        applicantId: widget.applicationData.shikshaApplicantId!,
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
          "aadhaarDocument": ref.referedMemberMemberAadharCardDocument ?? "",
        });
      }

      setState(() => isLoading = false);

      // ✅ AUTO OPEN FORM IF EMPTY
      if (charityList.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showReferenceSheet(context);
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
                            ElevatedButton.icon(
                              onPressed: () {
                                _showReferenceSheet(
                                  context,
                                  existingData: item,
                                );
                              },
                              icon: const Icon(
                                Icons.edit,
                                size: 16,
                              ),
                              label: const Text(
                                "Edit",
                                style: TextStyle(fontSize: 13),
                              ),
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
                            ),
                          ],
                        ),

                        const Divider(height: 20),

                        _infoRow("Member Code", item["memberCode"] ?? ""),
                        const SizedBox(height: 8),

                        _infoRow("Mobile", item["mobile"] ?? ""),
                        const SizedBox(height: 8),

                        _infoRow("Email", item["email"] ?? ""),
                        const SizedBox(height: 8),

                        _infoRow("Address", item["address"] ?? ""),
                        const SizedBox(height: 12),

                        if (item["aadhaarDocument"] != null &&
                            item["aadhaarDocument"].toString().isNotEmpty)
                          Builder(
                            builder: (context) {
                              final String imagePath =
                                  _getFullImageUrl(item["aadhaarDocument"]);

                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showAadhaarPreviewDialog(
                                        context, imagePath);
                                  },
                                  icon: const Icon(Icons.visibility),
                                  label: const Text("View Aadhaar"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        ColorHelperClass.getColorFromHex(
                                            ColorResources.red_color),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              );
                            },
                          ),
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
    );
  }

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    if (path.startsWith('http')) {
      return path; // already full URL
    }

    return "${Urls.base_url.replaceAll(RegExp(r'/$'), '')}/${path.replaceAll(RegExp(r'^/'), '')}";
  }

  void _showAadhaarPreviewDialog(
    BuildContext context,
    String imageUrl,
  ) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              "Aadhaar Document",
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
                          child: Text(
                            "Unable to load document",
                          ),
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
        shikshaApplicantId: widget.applicationData.shikshaApplicantId,
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

      final String referenceId =
          response.data?.shikshaApplicantReferredMemberId?.toString() ?? '';

      if (referenceId.isEmpty) {
        throw Exception("Reference ID not returned from server");
      }

      if (referenceAadharFile != null) {
        final aadhaarResponse = await _aadhaarRepo.uploadAadhaar(
          shikshaApplicantId: widget.applicationData.shikshaApplicantId!,
          referenceId: referenceId,
          filePath: referenceAadharFile!.path,
        );

        if (aadhaarResponse.status != true) {
          throw Exception(aadhaarResponse.message);
        }
      }

      Navigator.pop(context);
      await _fetchReferredMembers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reference and Aadhaar uploaded successfully"),
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
        shikshaApplicantId: widget.applicationData.shikshaApplicantId,
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

      // 🔥 NEW: Upload Aadhaar if selected during edit
      if (referenceAadharFile != null) {
        final aadhaarResponse = await _aadhaarRepo.uploadAadhaar(
          shikshaApplicantId: widget.applicationData.shikshaApplicantId!,
          referenceId: referenceId,
          filePath: referenceAadharFile!.path,
        );

        if (aadhaarResponse.status != true) {
          throw Exception(aadhaarResponse.message);
        }
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
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
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

    bool isFormValid() {
      final emailRegex = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      );

      return nameCtrl.text.trim().isNotEmpty &&
          addressCtrl.text.trim().isNotEmpty &&
          mobileCtrl.text.trim().length == 10 &&
          emailRegex.hasMatch(emailCtrl.text.trim());
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: (!isFormValid() || isSubmitting)
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }

                                      if (isEditMode) {
                                        await _updateReference(
                                          referenceId:
                                              existingData!["referenceId"],
                                          name: nameCtrl.text.trim(),
                                          address: addressCtrl.text.trim(),
                                          mobile: mobileCtrl.text.trim(),
                                          email: emailCtrl.text.trim(),
                                          memberCode:
                                              memberCodeCtrl.text.trim(),
                                        );
                                      } else {
                                        await _submitReference(
                                          name: nameCtrl.text.trim(),
                                          address: addressCtrl.text.trim(),
                                          mobile: mobileCtrl.text.trim(),
                                          email: emailCtrl.text.trim(),
                                          memberCode:
                                              memberCodeCtrl.text.trim(),
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Reference name is required";
                                  }
                                  return null;
                                },
                                onChanged: (_) => setModalState(() {}),
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
                                keyboard: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Mobile number is required";
                                  }
                                  if (value.length != 10) {
                                    return "Mobile number must be 10 digits";
                                  }
                                  return null;
                                },
                                onChanged: (_) => setModalState(() {}),
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: "Email Address *",
                                controller: emailCtrl,
                                keyboard: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Email address is required";
                                  }

                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );

                                  if (!emailRegex.hasMatch(value)) {
                                    return "Enter a valid email address";
                                  }

                                  return null;
                                },
                                onChanged: (_) => setModalState(() {}),
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: "Address *",
                                controller: addressCtrl,
                              ),
                              const SizedBox(height: 20),
                              _buildImageUploadField(
                                context: context,
                                imageFile: referenceAadharFile,
                                buttonText: "Upload Aadhaar",
                                existingDocumentPath: existingData?["aadhaarDocument"],
                                isExistingRemoved: isExistingAadhaarRemoved,

                                onPick: () {
                                  _showImagePicker(context, (file) {
                                    setModalState(() {
                                      referenceAadharFile = file;
                                    });
                                    setState(() {
                                      referenceAadharFile = file;
                                    });
                                  });
                                },

                                onRemoveExisting: () {
                                  setModalState(() {
                                    isExistingAadhaarRemoved = true;
                                  });
                                  setState(() {
                                    isExistingAadhaarRemoved = true;
                                  });
                                },

                                onRemoveNew: () {
                                  setModalState(() {
                                    referenceAadharFile = null;
                                  });
                                  setState(() {
                                    referenceAadharFile = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===================== HELPERS =====================
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
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
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
    );
  }

  Widget _buildImageUploadField({
    required BuildContext context,
    required File? imageFile,
    required String buttonText,
    required String? existingDocumentPath,
    required bool isExistingRemoved,
    required VoidCallback onPick,
    required VoidCallback onRemoveExisting,
    required VoidCallback onRemoveNew,
  }) {
    final bool hasExisting =
        !isExistingRemoved &&
            (existingDocumentPath ?? "").isNotEmpty;

    final bool isUploaded = imageFile != null || hasExisting;

    bool isPdf(String path) =>
        path.toLowerCase().endsWith(".pdf");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔥 NEW FILE PREVIEW
        if (imageFile != null)
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageFile.path.endsWith(".pdf")
                      ? const Center(
                    child: Icon(Icons.picture_as_pdf,
                        size: 80, color: Colors.red),
                  )
                      : Image.file(imageFile, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: onRemoveNew,
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close,
                        size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

        /// 🔥 EXISTING NETWORK FILE
        if (imageFile == null && hasExisting)
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: isPdf(existingDocumentPath!)
                      ? const Center(
                    child: Icon(Icons.picture_as_pdf,
                        size: 80, color: Colors.red),
                  )
                      : Image.network(
                    _getFullImageUrl(existingDocumentPath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: onRemoveExisting,
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close,
                        size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

        /// 🔥 VIEW BUTTON IF PDF
        if (imageFile == null &&
            hasExisting &&
            isPdf(existingDocumentPath!))
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showAadhaarPreviewDialog(
                  context,
                  _getFullImageUrl(existingDocumentPath),
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text("View Document"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
              ),
            ),
          ),

        /// 🔥 UPLOAD BUTTON
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onPick,
            icon: Icon(
              isUploaded ? Icons.check_circle : Icons.upload_file,
            ),
            label: Text(
              isUploaded
                  ? "Aadhaar Uploaded"
                  : "$buttonText *",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded
                  ? Colors.green
                  : ColorHelperClass.getColorFromHex(
                ColorResources.red_color,
              ),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePicker(
    BuildContext context,
    Function(File) onImagePicked,
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
                  onImagePicked(File(picked.path));
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
                  onImagePicked(File(picked.path));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
