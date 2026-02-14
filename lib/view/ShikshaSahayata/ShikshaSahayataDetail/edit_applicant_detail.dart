import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/UpdateApplicantDetail/UpdateApplicantDetailData.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplicationsByAppliedBy/ShikshaApplicationsByAppliedByData.dart';
import 'package:mpm/model/ShikshaSahayata/UpdateFatherDetail/UpdateFatherData.dart';
import 'package:mpm/model/State/StateData.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ApplicantDetailRepo/applicant_aadhaar_upload_repository/applicant_aadhaar_upload_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ApplicantDetailRepo/applicant_ration_upload_repository/applicant_ration_upload_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ApplicantDetailRepo/father_pan_upload_repository/father_pan_upload_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ApplicantDetailRepo/update_shiksha_application_repository/update_shiksha_application_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/UpdateFatherRepo/update_father_repository/update_father_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class EditApplicantDetailView extends StatefulWidget {
  final ShikshaApplicationsByAppliedByData applicationData;

  const EditApplicantDetailView({
    super.key,
    required this.applicationData,
  });

  @override
  State<EditApplicantDetailView> createState() =>
      _EditApplicantDetailViewState();
}

class _EditApplicantDetailViewState extends State<EditApplicantDetailView> {
  final ImagePicker _picker = ImagePicker();
  File? applicantAadharFile;
  File? fatherPanFile;
  File? addressProofFile;

  final UpdateShikshaApplicationRepository _updateRepo =
      UpdateShikshaApplicationRepository();
  final UpdateFatherRepository _updateFatherRepo = UpdateFatherRepository();
  final UdateProfileController controller = Get.put(UdateProfileController());
  NewMemberController regiController = Get.find<NewMemberController>();
  final ApplicantAadhaarUploadRepository _aadhaarRepo =
      ApplicantAadhaarUploadRepository();
  final ApplicantRationUploadRepository _rationRepo =
      ApplicantRationUploadRepository();
  final FatherPanUploadRepository _fatherPanRepo = FatherPanUploadRepository();

  bool _isSubmitting = false;
  bool isExistingAadhaarRemoved = false;
  bool isExistingPanRemoved = false;
  bool isExistingRationRemoved = false;

  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController middleNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController landlineCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController dobCtrl = TextEditingController();
  final TextEditingController fatherNameCtrl = TextEditingController();
  final TextEditingController motherNameCtrl = TextEditingController();
  final TextEditingController fatherEmailCtrl = TextEditingController();
  final TextEditingController fatherMobileCtrl = TextEditingController();

  String maritalStatus = '';

  void _prefillData() {
    final data = widget.applicationData;

    firstNameCtrl.text = data.applicantFirstName ?? '';
    middleNameCtrl.text = data.applicantMiddleName ?? '';
    lastNameCtrl.text = data.applicantLastName ?? '';
    emailCtrl.text = data.email ?? '';
    mobileCtrl.text = data.mobile ?? '';
    ageCtrl.text = data.age ?? '';
    dobCtrl.text = data.dateOfBirth ?? '';

    fatherNameCtrl.text = data.applicantFatherName ?? '';
    motherNameCtrl.text = data.applicantMotherName ?? '';
    fatherEmailCtrl.text = data.fatherEmail ?? '';
    fatherMobileCtrl.text = data.fatherMobile ?? '';

    maritalStatus = data.maritalStatusName ?? '';
  }

  @override
  void initState() {
    super.initState();
    _prefillData();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.applicationData;
    final loanList =
        widget.applicationData.requestedLoanEducationAppliedBy;

    final String loanStatus =
        (loanList != null && loanList.isNotEmpty
            ? loanList.first.loanStatus
            : "")
            ?.toLowerCase() ??
            "";

    final bool isLoanLocked =
        loanStatus == "disbursed" ||
            loanStatus == "partially_repaid" ||
            loanStatus == "fully_repaid";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text(
          "Applicant Detail",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Applicant Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isLoanLocked)
                      ElevatedButton.icon(
                        onPressed: () {
                          _openEditApplicant();
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text(
                          "Edit",
                          style: TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                          foregroundColor: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),

                const Divider(),
                const SizedBox(height: 12),

                /// APPLICANT INFO
                _infoRow("Full Name", data.fullName ?? ''),
                _infoRow("Email", data.email ?? ''),
                _infoRow("Mobile", data.mobile ?? ''),
                _infoRow("Date of Birth", data.dateOfBirth ?? ''),
                _infoRow("Age", data.age ?? ''),
                _infoRow("Marital Status", data.maritalStatusName ?? ''),

                const SizedBox(height: 20),

                const Text(
                  "Father / Mother Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _infoRow("Father Name", data.applicantFatherName ?? ''),
                _infoRow("Mother Name", data.applicantMotherName ?? ''),
                _infoRow("Father Mobile", data.fatherMobile ?? ''),
                _infoRow("Father Email", data.fatherEmail ?? ''),
                _infoRow("City", data.applicantCityName ?? ''),
                _infoRow("State", data.applicantStateName ?? ''),

                const Text(
                  "Documents",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (data.applicantAadharCardDocument != null &&
                    data.applicantAadharCardDocument!.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final imageUrl =
                            _getFullImageUrl(data.applicantAadharCardDocument);
                        _showDocumentPreviewDialog(
                            context, imageUrl, "Applicant Aadhaar");
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text("View Applicant Aadhaar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(
                            ColorResources.red_color),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                if (data.applicantFatherPanCardDocument != null &&
                    data.applicantFatherPanCardDocument!.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final imageUrl = _getFullImageUrl(
                            data.applicantFatherPanCardDocument);
                        _showDocumentPreviewDialog(
                            context, imageUrl, "Father's PAN");
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text("View Father's PAN"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(
                            ColorResources.red_color),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                if (data.applicantRationCardDocument != null &&
                    data.applicantRationCardDocument!.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final imageUrl =
                            _getFullImageUrl(data.applicantRationCardDocument);
                        _showDocumentPreviewDialog(
                          context,
                          imageUrl,
                          "Address Proof",
                        );
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text("View Address Proof"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(
                            ColorResources.red_color),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool get _canSubmitApplicant {
    if (firstNameCtrl.text.trim().isEmpty) return false;
    if (lastNameCtrl.text.trim().isEmpty) return false;
    if (!_isValidEmail(emailCtrl.text.trim())) return false;
    if (mobileCtrl.text.trim().length != 10) return false;
    if (dobCtrl.text.trim().isEmpty) return false;
    if (ageCtrl.text.trim().isEmpty) return false;
    if (maritalStatus.isEmpty) return false;

    if (fatherNameCtrl.text.trim().isEmpty) return false;
    if (!_isValidEmail(fatherEmailCtrl.text.trim())) return false;
    if (fatherMobileCtrl.text.trim().length != 10) return false;

    if (regiController.city_id.value.isEmpty) return false;
    if (regiController.state_id.value.isEmpty) return false;

    if (applicantAadharFile == null &&
        (widget.applicationData.applicantAadharCardDocument ?? "").isEmpty &&
        !isExistingAadhaarRemoved) {
      return false;
    }

    if (fatherPanFile == null &&
        (widget.applicationData.applicantFatherPanCardDocument ?? "").isEmpty &&
        !isExistingPanRemoved) {
      return false;
    }

    return true;
  }

  String _safeAddress() {
    return controller.getUserData.value.address?.address?.toString() ?? '';
  }

  Future<void> _updateApplicant() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final updateData = UpdateApplicantDetailData(
        shikshaApplicantId: widget.applicationData.shikshaApplicantId,
        applicantFirstName: firstNameCtrl.text.trim(),
        applicantMiddleName: middleNameCtrl.text.trim(),
        applicantLastName: lastNameCtrl.text.trim(),
        mobile: mobileCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        landline: landlineCtrl.text.trim(),
        dateOfBirth: _formatDobForApi(dobCtrl.text.trim()),
        age: ageCtrl.text.trim(),
        maritalStatusId: maritalStatus == "Married" ? "1" : "2",

        applicantAddress: _safeAddress(),
        applicantCityId: regiController.city_id.value,
        applicantStateId: regiController.state_id.value,

        appliedBy: controller.memberId.value,
        updatedBy: controller.memberId.value,
      );

      final response =
          await _updateRepo.updateShikshaApplication(updateData.toJson());

      if (response.status != true) {
        throw Exception(response.message);
      }

      final fatherData = UpdateFatherData(
        shikshaApplicantId: widget.applicationData.shikshaApplicantId,
        applicantFatherName: fatherNameCtrl.text.trim(),
        applicantMotherName: motherNameCtrl.text.trim(),
        fatherEmail: fatherEmailCtrl.text.trim(),
        fatherMobile: fatherMobileCtrl.text.trim(),
        fatherAddress: _safeAddress(),
        fatherCityId: regiController.city_id.value,
        fatherStateId: regiController.state_id.value,
        updatedBy: controller.memberId.value,
      );

      final fatherResponse =
          await _updateFatherRepo.updateFatherData(fatherData.toJson());

      if (fatherResponse.status != true) {
        throw Exception(fatherResponse.message);
      }

      if (applicantAadharFile != null) {
        debugPrint("📤 Uploading Aadhaar: ${applicantAadharFile!.path}");

        final aadhaarResponse = await _aadhaarRepo.uploadApplicantAadhaar(
          shikshaApplicantId: widget.applicationData.shikshaApplicantId!,
          filePath: applicantAadharFile!.path,
        );

        debugPrint("🆔 Aadhaar Upload Response: ${aadhaarResponse.toJson()}");

        if (aadhaarResponse.status != true) {
          throw Exception(aadhaarResponse.message);
        }
      }

      // Ration
      if (addressProofFile != null) {
        debugPrint("📤 Uploading Ration: ${addressProofFile!.path}");

        final rationResponse = await _rationRepo.uploadApplicantRationCard(
          shikshaApplicantId: widget.applicationData.shikshaApplicantId!,
          filePath: addressProofFile!.path,
        );

        debugPrint("🏠 Ration Upload Response: ${rationResponse.toJson()}");

        if (rationResponse.status != true) {
          throw Exception(rationResponse.message);
        }
      }

      // Father PAN
      if (fatherPanFile != null) {
        debugPrint("📤 Uploading Father PAN: ${fatherPanFile!.path}");

        final panResponse = await _fatherPanRepo.uploadFatherPanCard(
          shikshaApplicantId: widget.applicationData.shikshaApplicantId!,
          filePath: fatherPanFile!.path,
        );

        debugPrint("🧾 PAN Upload Response: ${panResponse.toJson()}");

        if (panResponse.status != true) {
          throw Exception(panResponse.message);
        }
      }
      if (!mounted) return;

      Navigator.pop(context, true); // 🔥 return true to previous screen

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Applicant updated successfully"),
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
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatDobForApi(String raw) {
    if (raw.isEmpty) return raw;
    try {
      final parsed = DateFormat('dd/MM/yyyy').parseStrict(raw);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      return raw;
    }
  }

  String _formatDobForUi(String raw) {
    if (raw.isEmpty) return raw;
    try {
      final parsed = DateFormat('yyyy-MM-dd').parseStrict(raw);
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return raw;
    }
  }

  void _showEditBottomSheet(BuildContext context) {
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
                heightFactor: 0.9,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: _canSubmitApplicant
                                ? () async {
                                    Navigator.pop(context);
                                    await _updateApplicant();
                                  }
                                : null,
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
                            child: const Text("Submit"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              const Text(
                                "Applicant Details",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 30),
                              _buildTextField("First Name *",
                                  controller: firstNameCtrl,
                                  onChanged: (_) => setModalState(() {})),
                              const SizedBox(height: 20),
                              _buildTextField("Middle Name",
                                  controller: middleNameCtrl,
                                  onChanged: (_) => setModalState(() {})),
                              const SizedBox(height: 20),
                              _buildTextField("Surname *",
                                  controller: lastNameCtrl,
                                  onChanged: (_) => setModalState(() {})),
                              const SizedBox(height: 20),
                              _buildTextField(
                                "Email *",
                                controller: emailCtrl,
                                onChanged: (_) => setModalState(() {}),
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                "Mobile Number *",
                                controller: mobileCtrl,
                                keyboard: TextInputType.number,
                                inputFormatters: number10DigitFormatter,
                                onChanged: (_) => setModalState(() {}),
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                "Landline Number",
                                controller: landlineCtrl,
                                keyboard: TextInputType.number,
                                onChanged: (_) => setModalState(() {}),
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                "Father's Name *",
                                controller: fatherNameCtrl,
                                onChanged: (_) => setModalState(() {}),
                              ),
                              const SizedBox(height: 20),
                              _buildTextField("Mother's Name",
                                  controller: motherNameCtrl,
                                  onChanged: (_) => setModalState(() {})),
                              const SizedBox(height: 20),
                              _buildTextField("Father's Email *",
                                  controller: fatherEmailCtrl,
                                  onChanged: (_) => setModalState(() {})),
                              const SizedBox(height: 20),
                              _buildTextField(
                                "Father's Mobile *",
                                controller: fatherMobileCtrl,
                                keyboard: TextInputType.number,
                                inputFormatters: number10DigitFormatter,
                                onChanged: (_) => setModalState(() {}),
                              ),
                              const SizedBox(height: 20),
                              themedDatePickerField(
                                context: context,
                                label: "Date of Birth *",
                                hint: "Select DOB",
                                controller: dobCtrl,
                                calculateAge: true,
                                onChanged: () => setModalState(() {}),
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                "Age",
                                controller: ageCtrl,
                                readOnly: true,
                                onChanged: (_) => setModalState(() {}),
                              ),
                              const SizedBox(height: 20),
                              _buildDropdown(
                                label: "Marital Status *",
                                items: ["Married", "Unmarried"],
                                selectedValue: maritalStatus,
                                onChanged: (val) {
                                  setModalState(() {
                                    maritalStatus = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                margin:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Row(
                                  children: [
                                    Obx(() {
                                      if (regiController
                                              .rxStatusCityLoading.value ==
                                          Status.LOADING) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 22),
                                          child: SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                                color: Colors.redAccent),
                                          ),
                                        );
                                      } else if (regiController
                                              .rxStatusCityLoading.value ==
                                          Status.ERROR) {
                                        return const Center(
                                            child: Text('Failed to load city'));
                                      } else if (regiController
                                          .cityList.isEmpty) {
                                        return const Center(
                                            child: Text('No City available'));
                                      } else {
                                        final selectedCity =
                                            regiController.city_id.value;
                                        return Expanded(
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: "Father's City *",
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black38,
                                                    width: 1),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 0),
                                            ),
                                            child: DropdownButton<String>(
                                              dropdownColor: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              isExpanded: true,
                                              underline: Container(),
                                              hint: const Text(
                                                  "Select Father's City *"),
                                              value: selectedCity.isNotEmpty
                                                  ? selectedCity
                                                  : null,
                                              items: regiController.cityList
                                                  .map((CityData city) {
                                                return DropdownMenuItem<String>(
                                                  value: city.id.toString(),
                                                  child: Text(city.cityName ??
                                                      'Unknown'),
                                                );
                                              }).toList(),
                                              onChanged: (val) {
                                                if (val != null) {
                                                  regiController
                                                      .setSelectedCity(val);
                                                  setModalState(() {});
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
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                margin:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Row(
                                  children: [
                                    Obx(() {
                                      if (regiController
                                              .rxStatusStateLoading.value ==
                                          Status.LOADING) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 22),
                                          child: SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                                color: Colors.redAccent),
                                          ),
                                        );
                                      } else if (regiController
                                              .rxStatusStateLoading.value ==
                                          Status.ERROR) {
                                        return const Center(
                                            child:
                                                Text('Failed to load state'));
                                      } else if (regiController
                                          .stateList.isEmpty) {
                                        return const Center(
                                            child: Text('No State available'));
                                      } else {
                                        final selectedState =
                                            regiController.state_id.value;
                                        return Expanded(
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: "Father's State *",
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black38,
                                                    width: 1),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 0),
                                            ),
                                            child: DropdownButton<String>(
                                              dropdownColor: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              isExpanded: true,
                                              underline: Container(),
                                              hint: const Text(
                                                  "Select Father's State *"),
                                              value: selectedState.isNotEmpty
                                                  ? selectedState
                                                  : null,
                                              items: regiController.stateList
                                                  .map((StateData state) {
                                                return DropdownMenuItem<String>(
                                                  value: state.id.toString(),
                                                  child: Text(state.stateName ??
                                                      'Unknown'),
                                                );
                                              }).toList(),
                                              onChanged: (val) {
                                                if (val != null) {
                                                  regiController
                                                      .setSelectedState(val);
                                                  setModalState(() {});
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
                              const SizedBox(height: 20),
                              buildImageUploadField(
                                context: context,
                                imageFile: applicantAadharFile,
                                existingDocumentPath: widget.applicationData
                                    .applicantAadharCardDocument,
                                isExistingRemoved: isExistingAadhaarRemoved,
                                buttonText: "Applicant Aadhaar Card",

                                onPick: () {
                                  _showImagePicker(context, (file) {
                                    setModalState(() {
                                      applicantAadharFile = file;
                                    });
                                    setState(() {
                                      applicantAadharFile = file;
                                    });
                                  });
                                },

                                /// ❌ REMOVE EXISTING NETWORK FILE
                                onRemoveExisting: () {
                                  setModalState(() {
                                    isExistingAadhaarRemoved = true;
                                  });
                                  setState(() {
                                    isExistingAadhaarRemoved = true;
                                  });
                                },

                                /// ❌ REMOVE NEWLY SELECTED FILE
                                onRemoveNew: () {
                                  setModalState(() {
                                    applicantAadharFile = null;
                                  });
                                  setState(() {
                                    applicantAadharFile = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              buildImageUploadField(
                                context: context,
                                imageFile: fatherPanFile,
                                existingDocumentPath: widget.applicationData
                                    .applicantFatherPanCardDocument,
                                isExistingRemoved: isExistingPanRemoved,
                                buttonText: "Father's PAN Card",
                                onPick: () {
                                  _showImagePicker(context, (file) {
                                    setModalState(() {
                                      fatherPanFile = file;
                                    });
                                    setState(() {
                                      fatherPanFile = file;
                                    });
                                  });
                                },
                                onRemoveExisting: () {
                                  setModalState(() {
                                    isExistingPanRemoved = true;
                                  });
                                  setState(() {
                                    isExistingPanRemoved = true;
                                  });
                                },
                                onRemoveNew: () {
                                  setModalState(() {
                                    fatherPanFile = null;
                                  });
                                  setState(() {
                                    fatherPanFile = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              buildImageUploadField(
                                context: context,
                                imageFile: addressProofFile,
                                existingDocumentPath: widget.applicationData
                                    .applicantRationCardDocument,
                                isExistingRemoved: isExistingRationRemoved,
                                buttonText:
                                    "Address Proof (if Aadhaar and current address are not the same)",
                                onPick: () {
                                  _showImagePicker(context, (file) {
                                    setModalState(() {
                                      addressProofFile = file;
                                    });
                                    setState(() {
                                      addressProofFile = file;
                                    });
                                  });
                                },
                                onRemoveExisting: () {
                                  setModalState(() {
                                    isExistingRationRemoved = true;
                                  });
                                  setState(() {
                                    isExistingRationRemoved = true;
                                  });
                                },
                                onRemoveNew: () {
                                  setModalState(() {
                                    addressProofFile = null;
                                  });
                                  setState(() {
                                    addressProofFile = null;
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

  void _openEditApplicant() async {
    final data = widget.applicationData;

    // Prefill text fields
    firstNameCtrl.text = data.applicantFirstName ?? '';
    middleNameCtrl.text = data.applicantMiddleName ?? '';
    lastNameCtrl.text = data.applicantLastName ?? '';
    emailCtrl.text = data.email ?? '';
    mobileCtrl.text = data.mobile ?? '';
    ageCtrl.text = data.age ?? '';
    dobCtrl.text = _formatDobForUi(data.dateOfBirth ?? '');
    maritalStatus = data.maritalStatusName ?? '';

    fatherNameCtrl.text = data.applicantFatherName ?? '';
    motherNameCtrl.text = data.applicantMotherName ?? '';
    fatherEmailCtrl.text = data.fatherEmail ?? '';
    fatherMobileCtrl.text = data.fatherMobile ?? '';

    await regiController.getState();

    await regiController.getCity();

    if (data.applicantStateId != null) {
      regiController.setSelectedState(data.applicantStateId.toString());

      await regiController.getCityByState(data.applicantStateId.toString());
    }

    if (data.applicantCityId != null) {
      regiController.setSelectedCity(data.applicantCityId.toString());
    }

    _showEditBottomSheet(context);
  }

  Widget _buildTextField(
    String label, {
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
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

  List<TextInputFormatter> number10DigitFormatter = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ];

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return InputDecorator(
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
      isEmpty: selectedValue.isEmpty,
      child: DropdownButton<String>(
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
        isExpanded: true,
        underline: Container(),
        value: selectedValue.isEmpty ? null : selectedValue,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            onChanged(val);
          }
        },
      ),
    );
  }

  void _calculateAgeFromDob(DateTime dob) {
    final DateTime today = DateTime.now();

    int age = today.year - dob.year;

    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }

    ageCtrl.text = age.toString();
  }

  Widget themedDatePickerField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    bool calculateAge = false,
    VoidCallback? onChanged,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        readOnly: true,
        controller: controller,
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
                      ColorResources.red_color,
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            controller.text = DateFormat('dd/MM/yyyy').format(picked);

            if (calculateAge) {
              _calculateAgeFromDob(picked);
            }
            if (onChanged != null) {
              onChanged();
            }
          }
        },
      ),
    );
  }

  Widget buildImageUploadField({
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
            (existingDocumentPath ?? "").toString().isNotEmpty;

    final bool isUploaded = imageFile != null || hasExisting;

    bool isPdf(String path) {
      return path.toLowerCase().endsWith(".pdf");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageFile != null)
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(imageFile, fit: BoxFit.cover),
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
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

        if (imageFile == null && hasExisting)
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
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
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

        if (imageFile == null && hasExisting && isPdf(existingDocumentPath!))
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showDocumentPreviewDialog(
                  context,
                  _getFullImageUrl(existingDocumentPath),
                  buttonText,
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

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onPick,
            icon: Icon(
              isUploaded ? Icons.check_circle : Icons.upload,
            ),
            label: Text(
              isUploaded ? "$buttonText Uploaded" : "$buttonText *",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded
                  ? Colors.green
                  : ColorHelperClass.getColorFromHex(ColorResources.red_color),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
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

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    if (path.startsWith('http')) {
      return path;
    }

    return "${Urls.base_url.replaceAll(RegExp(r'/$'), '')}/${path.replaceAll(RegExp(r'^/'), '')}";
  }

  void _showDocumentPreviewDialog(
    BuildContext context,
    String imageUrl,
    String title,
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
            Text(
              title,
              style: const TextStyle(
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

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Text(
                  ':',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
