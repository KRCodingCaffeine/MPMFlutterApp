import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/UpdateApplicantDetail/UpdateApplicantDetailData.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/ShikshaApplicationData.dart';
import 'package:mpm/model/State/StateData.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/CreateApplicantDetail/CreateApplicantDetailData.dart';
import 'package:mpm/model/ShikshaSahayata/UpdateFatherDetail/UpdateFatherData.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ApplicantDetailRepo/create_shiksha_application_repository/create_shiksha_application_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ApplicantDetailRepo/update_shiksha_application_repository/update_shiksha_application_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ShikshaApplicationRepo/shiksha_application_repository/shiksha_application_repo.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/UpdateFatherRepo/update_father_repository/update_father_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/shiksha_sahayata_by_parenting_view.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/family_detail.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicantDetail extends StatefulWidget {
  const ApplicantDetail({super.key});

  @override
  State<ApplicantDetail> createState() => _ApplicantDetailState();
}

class _ApplicantDetailState extends State<ApplicantDetail> {

  bool hasApplicant = false;
  bool _isSubmitting = false;
  File? applicantAadharFile;
  File? fatherPanFile;
  File? addressProofFile;
  final ImagePicker _picker = ImagePicker();
  UdateProfileController controller = Get.put(UdateProfileController());
  NewMemberController regiController = Get.find<NewMemberController>();
  final CreateShikshaApplicationRepository _createRepo =
      CreateShikshaApplicationRepository();
  final UpdateShikshaApplicationRepository _updateRepo =
  UpdateShikshaApplicationRepository();
  final UpdateFatherRepository _updateFatherRepo = UpdateFatherRepository();
  String? _shikshaApplicantId;
  final ShikshaApplicationRepository _shikshaRepo =
  ShikshaApplicationRepository();

  ShikshaApplicationData? _applicationData;


  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController middleNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController aadharCtrl = TextEditingController();
  final TextEditingController dobCtrl = TextEditingController();
  final TextEditingController anniversaryCtrl = TextEditingController();
  final TextEditingController landlineCtrl = TextEditingController();
  final TextEditingController fatherNameCtrl = TextEditingController();
  final TextEditingController motherNameCtrl = TextEditingController();
  final TextEditingController fatherEmailCtrl = TextEditingController();
  final TextEditingController fatherMobileCtrl = TextEditingController();
  final TextEditingController fatherCityCtrl = TextEditingController();
  final TextEditingController fatherStateCtrl = TextEditingController();

  String selectedGender = '';
  String maritalStatus = '';

  String fullName = '';
  String mobile = '';
  String email = '';
  String dob = '';
  String age = '';
  String aadhar = '';
  String anniversary = '';
  String landline = '';
  String fatherName = '';
  String motherName = '';
  String fatherEmail = '';
  String fatherMobile = '';
  String fatherAddress = '';
  String fatherCityName = '';
  String fatherStateName = '';


  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await controller.getUserProfile();
    await regiController.getState();

    final address = controller.getUserData.value.address;

    if (address != null && address.stateId != null) {
      regiController.setSelectedState(address.stateId.toString());
      await regiController.getCityByState(address.stateId.toString());

      if (address.city_id != null) {
        regiController.setSelectedCity(address.city_id.toString());
      }
    }

    _prefillFatherFromUser();

    /// 🔥 ADD THIS PART
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('shiksha_applicant_id');

    if (savedId != null && savedId.isNotEmpty) {
      _shikshaApplicantId = savedId;
      await _fetchShikshaApplication(savedId);
    } else {
      _showAddApplicantModalSheet(context);
    }
  }

  Future<void> _fetchShikshaApplication(String applicantId) async {
    try {
      final response =
      await _shikshaRepo.fetchShikshaApplicationById(
        applicantId: applicantId,
      );

      if (response.status == true && response.data != null) {
        setState(() {
          _applicationData = response.data;
          hasApplicant = true;
        });
      } else {
        throw Exception(response.message ?? "Failed to fetch application");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _prefillFatherFromUser() {
    fatherNameCtrl.text = controller.userName.value;

    fatherEmailCtrl.text = controller.email.value;

    fatherMobileCtrl.text = controller.mobileNumber.value;

  }


  bool get _canSubmitApplicant {
    if (firstNameCtrl.text.trim().isEmpty) return false;
    if (lastNameCtrl.text.trim().isEmpty) return false;
    if (emailCtrl.text.trim().isEmpty) return false;
    if (mobileCtrl.text.trim().isEmpty) return false;
    if (dobCtrl.text.trim().isEmpty) return false;
    if (ageCtrl.text.trim().isEmpty) return false;
    if (maritalStatus.isEmpty) return false;

    if (fatherNameCtrl.text.trim().isEmpty) return false;
    if (fatherMobileCtrl.text.trim().isEmpty) return false;
    if (regiController.city_id.value.isEmpty) return false;
    if (regiController.state_id.value.isEmpty) return false;

    return true;
  }

  String _getMaritalStatusId() {
    if (maritalStatus == "Married") return "1";
    if (maritalStatus == "Unmarried") return "2";
    return maritalStatus;
  }

  String _safeAddress() {
    return controller.getUserData.value.address?.address?.toString() ?? '';
  }

  String _safeApplicantCityId() {
    return controller.getUserData.value.address?.city_id?.toString() ??
        regiController.city_id.value;
  }

  String _safeApplicantStateId() {
    return controller.getUserData.value.address?.stateId?.toString() ??
        regiController.state_id.value;
  }

  Future<void> _submitApplicantAndFather() async {
    if (!_canSubmitApplicant) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final applicantData = CreateApplicantDetailData(
        applicantFirstName: firstNameCtrl.text.trim(),
        applicantMiddleName: middleNameCtrl.text.trim(),
        applicantLastName: lastNameCtrl.text.trim(),
        mobile: mobileCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        landline: landlineCtrl.text.trim(),
        dateOfBirth: _formatDobForApi(dobCtrl.text.trim()),
        age: ageCtrl.text.trim(),
        maritalStatusId: _getMaritalStatusId(),
        applicantAddress: _safeAddress(),
        applicantCityId: _safeApplicantCityId(),
        applicantStateId: _safeApplicantStateId(),
        appliedBy: controller.memberId.value,
        createdBy: controller.memberId.value,
      );

      final createResponse =
      await _createRepo.createShikshaApplication(
        _stripCreateApplicantIds(applicantData.toJson()),
      );

      if (createResponse.status != true) {
        throw Exception(createResponse.message ?? "Failed to create application");
      }

      final shikshaId =
          createResponse.data?.shikshaApplicantId ??
              createResponse.data?.id;

      if (shikshaId == null || shikshaId.isEmpty) {
        throw Exception("Shiksha application ID not returned");
      }

      _shikshaApplicantId = shikshaId;

      final fatherData = UpdateFatherData(
        shikshaApplicantId: shikshaId,
        applicantFatherName: fatherNameCtrl.text.trim(),
        applicantMotherName: motherNameCtrl.text.trim(),
        fatherEmail: fatherEmailCtrl.text.trim(),
        fatherMobile: fatherMobileCtrl.text.trim(),
        fatherAddress: _safeAddress(),
        fatherCityId: regiController.city_id.value,
        fatherStateId: regiController.state_id.value,
        updatedBy: controller.memberId.value,
      );

      final updateResponse =
      await _updateFatherRepo.updateFatherData(fatherData.toJson());

      if (updateResponse.status != true) {
        throw Exception(updateResponse.message ?? "Failed to update father data");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('shiksha_applicant_id', shikshaId);

      // 🔥 IMPORTANT PART
      await _fetchShikshaApplication(shikshaId);

      setState(() {
        hasApplicant = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Applicant created successfully."),
          backgroundColor: Colors.green,
        ),
      );
      _shikshaApplicantId = shikshaId;

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _updateApplicant() async {
    if (_shikshaApplicantId == null) return;

    try {
      setState(() {
        _isSubmitting = true;
      });

      final updateData = UpdateApplicantDetailData(
        shikshaApplicantId: _shikshaApplicantId,
        applicantFirstName: firstNameCtrl.text.trim(),
        applicantMiddleName: middleNameCtrl.text.trim(),
        applicantLastName: lastNameCtrl.text.trim(),
        mobile: mobileCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        landline: landlineCtrl.text.trim(),
        dateOfBirth: _formatDobForApi(dobCtrl.text.trim()),
        age: ageCtrl.text.trim(),
        maritalStatusId: _getMaritalStatusId(),
        applicantAddress: _safeAddress(),
        applicantCityId: regiController.city_id.value,
        applicantStateId: regiController.state_id.value,
        appliedBy: controller.memberId.value,
        updatedBy: controller.memberId.value,
      );

      final response = await _updateRepo.updateShikshaApplication(
        updateData.toJson(),
      );

      if (response.status != true) {
        throw Exception(response.message ?? "Applicant update failed");
      }

      final fatherData = UpdateFatherData(
        shikshaApplicantId: _shikshaApplicantId,
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
        throw Exception(
            fatherResponse.message ?? "Father update failed");
      }

      await _fetchShikshaApplication(_shikshaApplicantId!);

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
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
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

  String _mapMaritalStatusLabel(String value) {
    if (value == "1") return "Married";
    if (value == "2") return "Unmarried";
    return value;
  }

  Map<String, dynamic> _stripCreateApplicantIds(
      Map<String, dynamic> body) {
    body.remove('shiksha_applicant_id');
    body.remove('id');
    return body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          "Applicant Detail",
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: hasApplicant
          ? _buildApplicantCard()
          : const Center(
        child: Text(
          "No applicant details added",
          style: TextStyle(color: Colors.grey),
        ),
      ),

      floatingActionButton: !hasApplicant
          ? FloatingActionButton(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.red_color),
        onPressed: () {
          _showAddApplicantModalSheet(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,

      bottomNavigationBar: hasApplicant ? _buildBottomNextBar() : null,
    );
  }

  Widget _buildApplicantCard() {
    final data = _applicationData;

    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
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
                  ElevatedButton.icon(
                    onPressed: _openEditApplicant,
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
                      ColorHelperClass.getColorFromHex(ColorResources.red_color),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              _infoRow("Full Name", data.fullName ?? ''),
              _infoRow("Email", data.email ?? ''),
              _infoRow("Mobile", data.mobile ?? ''),
              _infoRow("Date of Birth",
                  _formatDobForUi(data.dateOfBirth ?? '')),
              _infoRow("Age", data.age ?? ''),
              _infoRow("Marital Status",
                  data.maritalStatusName ?? ''),
              const SizedBox(height: 10),

              const Text(
                "Father / Mother Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _infoRow("Father Name",
                  data.applicantFatherName ?? ''),
              _infoRow("Mother Name",
                  data.applicantMotherName ?? ''),
              _infoRow("Father Mobile",
                  data.fatherMobile ?? ''),
              _infoRow("Father Email",
                  data.fatherEmail ?? ''),
              _infoRow("City",
                  data.applicantCityName ?? ''),
              _infoRow("State",
                  data.applicantStateName ?? ''),
            ],
          ),
        ),
      ),
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
            Expanded(
              child: Text(
                "Once you complete the above details, click Next Step to proceed.",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(width: 12),

            ElevatedButton(
              onPressed: () async {
                if (_shikshaApplicantId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please complete applicant details first."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ShikshaSahayataByParentingView(),
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

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          Expanded(
            child: value.isNotEmpty
                ? Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildAadhaarPreview({
    required String title,
    required File? image,
  }) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text("$title:")),
        image == null
            ? const Text("Not Uploaded")
            : GestureDetector(
          onTap: () => _showImagePreview(image),
          child: Image.file(image, height: 60, width: 90),
        ),
      ],
    );
  }


  void _showImagePreview(File image) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Image.file(image),
      ),
    );
  }

  void _showAddApplicantModalSheet(BuildContext context) {
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
                              foregroundColor:
                              ColorHelperClass.getColorFromHex(ColorResources.red_color),
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
                              if (_shikshaApplicantId == null) {
                                await _submitApplicantAndFather();
                              } else {
                                await _updateApplicant();
                              }
                            }
                                : null,
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

                              _buildTextField("Email *",
                                  controller: emailCtrl,
                                  onChanged: (_) => setModalState(() {})),
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
                                margin: const EdgeInsets.only(left: 5, right: 5),
                                child: Row(
                                  children: [
                                    Obx(() {
                                      if (regiController.rxStatusCityLoading.value == Status.LOADING) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                                          child: SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(color: Colors.redAccent),
                                          ),
                                        );
                                      } else if (regiController.rxStatusCityLoading.value == Status.ERROR) {
                                        return const Center(child: Text('Failed to load city'));
                                      } else if (regiController.cityList.isEmpty) {
                                        return const Center(child: Text('No City available'));
                                      } else {
                                        final selectedCity = regiController.city_id.value;
                                        return Expanded(
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: 'Father City *',
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.black),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.black),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.black38, width: 1),
                                              ),
                                              contentPadding:
                                              EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                            ),
                                            child: DropdownButton<String>(
                                              dropdownColor: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              isExpanded: true,
                                              underline: Container(),
                                              hint: const Text('Select Father City *'),
                                              value: selectedCity.isNotEmpty ? selectedCity : null,
                                              items: regiController.cityList.map((CityData city) {
                                                return DropdownMenuItem<String>(
                                                  value: city.id.toString(),
                                                  child: Text(city.cityName ?? 'Unknown'),
                                                );
                                              }).toList(),
                                              onChanged: (val) {
                                                if (val != null) {
                                                  regiController.setSelectedCity(val);
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
                                margin: const EdgeInsets.only(left: 5, right: 5),
                                child: Row(
                                  children: [
                                    Obx(() {
                                      if (regiController.rxStatusStateLoading.value == Status.LOADING) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                                          child: SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(color: Colors.redAccent),
                                          ),
                                        );
                                      } else if (regiController.rxStatusStateLoading.value == Status.ERROR) {
                                        return const Center(child: Text('Failed to load state'));
                                      } else if (regiController.stateList.isEmpty) {
                                        return const Center(child: Text('No State available'));
                                      } else {
                                        final selectedState = regiController.state_id.value;
                                        return Expanded(
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: 'Father State *',
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.black),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.black),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.black38, width: 1),
                                              ),
                                              contentPadding:
                                              EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                            ),
                                            child: DropdownButton<String>(
                                              dropdownColor: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              isExpanded: true,
                                              underline: Container(),
                                              hint: const Text('Select Father State *'),
                                              value: selectedState.isNotEmpty ? selectedState : null,
                                              items: regiController.stateList.map((StateData state) {
                                                return DropdownMenuItem<String>(
                                                  value: state.id.toString(),
                                                  child: Text(state.stateName ?? 'Unknown'),
                                                );
                                              }).toList(),
                                              onChanged: (val) {
                                                if (val != null) {
                                                  regiController.setSelectedState(val);
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
                                buttonText: "Applicant Aadhaar *",
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
                                onRemove: () {
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
                                buttonText: "Father PAN Card *",
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
                                onRemove: () {
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
                                buttonText:
                                "Address Proof (If Aadhaar and current address is not same)",
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
                                onRemove: () {
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

  void _openEditApplicant() {
    if (_applicationData == null) return;

    final data = _applicationData!;

    // Prefill controllers
    firstNameCtrl.text = data.applicantFirstName ?? '';
    middleNameCtrl.text = data.applicantMiddleName ?? '';
    lastNameCtrl.text = data.applicantLastName ?? '';
    emailCtrl.text = data.email ?? '';
    mobileCtrl.text = data.mobile ?? '';
    ageCtrl.text = data.age ?? '';
    dobCtrl.text = _formatDobForUi(data.dateOfBirth ?? '');
    maritalStatus = _mapMaritalStatusLabel(data.maritalStatusId ?? '');

    fatherNameCtrl.text = data.applicantFatherName ?? '';
    fatherEmailCtrl.text = data.fatherEmail ?? '';
    fatherMobileCtrl.text = data.fatherMobile ?? '';

    _showAddApplicantModalSheet(context);
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
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final isUploaded = imageFile != null;

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
                    imageFile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              /// ❌ REMOVE BUTTON
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: onRemove,
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
            onPressed: onPick,
            icon: Icon(
              isUploaded ? Icons.check_circle : Icons.upload,
            ),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded
                  ? Colors.green   // ✅ Change color after upload
                  : ColorHelperClass.getColorFromHex(
                ColorResources.red_color,
              ),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
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
