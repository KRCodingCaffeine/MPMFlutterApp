import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/BusinessProfile/BusinessOccupationProfile/BusinessOccupationProfileData.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/repository/BusinessProfileRepo/business_occupation_profile_repository/business_occupation_profile_repo.dart';
import 'package:mpm/repository/JobPortal/CreateJobRepo/create_job_repository.dart';
import 'package:mpm/repository/JobPortal/UploadJobProfileDocumentRepo/upload_job_profile_document_repository.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class PostNewJob extends StatefulWidget {
  final List<BusinessOccupationProfileData> initialBusinessProfiles;

  const PostNewJob({
    super.key,
    required this.initialBusinessProfiles,
  });

  @override
  State<PostNewJob> createState() => _PostNewJobState();
}

class _PostNewJobState extends State<PostNewJob> {
  final UploadJobProfileDocumentRepository uploadJobProfileDocumentRepository =
      UploadJobProfileDocumentRepository();
  final ImagePicker _picker = ImagePicker();
  final UdateProfileController profileController =
      Get.find<UdateProfileController>();
  final NewMemberController regiController = Get.put(NewMemberController());

  List<BusinessOccupationProfileData> businessProfiles = [];
  File? jobSummaryFile;
  String? selectedBusinessId;
  String? selectedBusinessName;
  bool isSubmittingJob = false;
  bool isLoadingBusiness = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController salaryMinController = TextEditingController();
  final TextEditingController salaryMaxController = TextEditingController();
  String salaryVisible = "1";
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController experienceMinController = TextEditingController();
  final TextEditingController experienceMaxController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController vacancyController = TextEditingController();
  final TextEditingController lastDateController = TextEditingController();
  final TextEditingController internshipPeriodController =
      TextEditingController();

  String selectedOccupationId = "";
  String selectedProfessionId = "";
  String selectedSpecializationId = "";
  String selectedJobType = 'Full-time';
  String selectedWorkMode = 'On-site';
  final List<String> jobTypes = ['Full-time', 'Part-time', 'Internship'];
  final List<String> workModes = ['On-site', 'Work From Home', 'Hybrid'];
  final FocusNode vacancyFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    businessProfiles = widget.initialBusinessProfiles;
    if (businessProfiles.isEmpty) {
      loadBusinessProfiles();
    }
    _initializeForm();
  }

  Future<void> loadBusinessProfiles() async {
    try {
      setState(() => isLoadingBusiness = true);

      final memberId = profileController.memberId.value;
      final response = await BusinessOccupationProfileRepository()
          .fetchBusinessOccupationProfiles(memberId: memberId);

      if (response.status == true && response.data != null && mounted) {
        setState(() => businessProfiles = response.data!);
      }
    } catch (e) {
      debugPrint("Business Fetch Error: $e");
    } finally {
      if (mounted) setState(() => isLoadingBusiness = false);
    }
  }

  bool _isPostJobFormValid() {
    final hasCompany = _shouldShowCompanyNameInput()
        ? companyController.text.trim().isNotEmpty
        : (selectedBusinessId ?? "").trim().isNotEmpty;

    final hasTitle = titleController.text.trim().isNotEmpty;
    final hasCity = regiController.city_id.value.trim().isNotEmpty;
    final hasVacancy = vacancyController.text.trim().isNotEmpty;
    final hasJobType = selectedJobType.trim().isNotEmpty;
    final hasWorkMode = selectedWorkMode.trim().isNotEmpty;

    return hasCompany &&
        hasTitle &&
        hasCity &&
        hasVacancy &&
        hasJobType &&
        hasWorkMode;
  }

  String _getSelectedCityName() {
    final selectedCityId = regiController.city_id.value;

    if (selectedCityId.isEmpty) return locationController.text.trim();

    final selectedCity = regiController.cityList.firstWhereOrNull(
      (city) => city.id.toString() == selectedCityId,
    );

    return selectedCity?.cityName?.trim() ?? locationController.text.trim();
  }

  bool _shouldShowCompanyNameInput() {
    if (businessProfiles.isEmpty) return true;

    if (selectedBusinessId == null || selectedBusinessId!.isEmpty) {
      return !businessProfiles.any(
        (business) => (business.businessName ?? "").trim().isNotEmpty,
      );
    }

    final selectedBusiness = businessProfiles.firstWhereOrNull(
      (business) =>
          business.memberBusinessOccupationProfileId == selectedBusinessId,
    );

    return (selectedBusiness?.businessName ?? "").trim().isEmpty;
  }

  Future<String> _getLoggedInMemberId() async {
    final session = await SessionManager.getSession();
    final sessionMemberId = session?.memberId?.toString().trim() ?? "";

    if (sessionMemberId.isNotEmpty) return sessionMemberId;

    return profileController.memberId.value.trim();
  }

  String _cleanNumberForApi(String value, {String fallback = "0"}) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    return cleaned.isEmpty ? fallback : cleaned;
  }

  Future<void> _submitJob() async {
    final locationName = _getSelectedCityName();
    final loggedInMemberId = await _getLoggedInMemberId();

    final body = {
      "member_id": loggedInMemberId,
      "member_business_occupation_profile_id": selectedBusinessId ?? "0",
      "company_name": companyController.text.trim(),
      "title": titleController.text.trim(),
      "description": descriptionController.text.trim(),
      "occupation_id":
          selectedOccupationId.isEmpty ? "0" : selectedOccupationId,
      "occupation_profession_id":
          selectedProfessionId.isEmpty ? "0" : selectedProfessionId,
      "occupation_specialization_id":
          selectedSpecializationId.isEmpty ? "0" : selectedSpecializationId,
      "location": locationName,
      "city_id": regiController.city_id.value,
      "area_name": areaController.text.trim().isEmpty
          ? null
          : areaController.text.trim(),
      "salary_min": salaryVisible == "1"
          ? _cleanNumberForApi(salaryMinController.text)
          : "0",
      "salary_max": salaryVisible == "1"
          ? _cleanNumberForApi(salaryMaxController.text)
          : "0",
      "salary_visible": salaryVisible,
      "experience_min_years": _cleanNumberForApi(experienceMinController.text),
      "experience_max_years": _cleanNumberForApi(experienceMaxController.text),
      "no_of_vacancy": _cleanNumberForApi(vacancyController.text),
      "last_apply_date": _formatDateForApi(lastDateController.text),
      "work_type": _getWorkType(),
      "work_mode": _getWorkMode(),
      "status": "published",
      "created_by": loggedInMemberId,
    };

    setState(() => isSubmittingJob = true);

    try {
      final response = await CreateJobRepository().createJob(body);

      if (response.status == true) {
        final createdJobId = response.data?.jobId?.trim() ?? "";

        if (jobSummaryFile != null &&
            createdJobId.isNotEmpty &&
            loggedInMemberId.isNotEmpty) {
          final uploadResponse =
              await uploadJobProfileDocumentRepository.uploadJobProfileDocument(
            memberId: loggedInMemberId,
            jobId: createdJobId,
            filePath: jobSummaryFile!.path,
          );

          if (uploadResponse.status != true) {
            throw Exception(uploadResponse.message.isNotEmpty
                ? uploadResponse.message
                : "Job saved, but failed to upload job description");
          }
        } else if (jobSummaryFile != null && createdJobId.isEmpty) {
          throw Exception(
              "Job saved, but job id was missing for job description upload");
        } else if (jobSummaryFile != null && loggedInMemberId.isEmpty) {
          throw Exception(
              "Job saved, but member id was missing for job description upload");
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? "Job saved successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true);
      } else {
        throw Exception(response.message ?? "Failed to save job");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save job: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => isSubmittingJob = false);
    }
  }

  String _formatDateForApi(String date) {
    try {
      if (date.isEmpty) return "";
      final parts = date.split('/');
      if (parts.length == 3) {
        return "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
      }
      return date;
    } catch (e) {
      return date;
    }
  }

  String _getWorkType() {
    switch (selectedJobType) {
      case "Full-time":
        return "full_time";
      case "Part-time":
        return "part_time";
      case "Internship":
        return "internship";
      default:
        return "full_time";
    }
  }

  String _getWorkMode() {
    switch (selectedWorkMode) {
      case "On-site":
        return "onsite";
      case "Work From Home":
        return "remote";
      case "Hybrid":
        return "hybrid";
      default:
        return "onsite";
    }
  }

  void _initializeForm() {
    titleController.clear();
    companyController.clear();
    locationController.clear();
    areaController.clear();
    salaryMinController.clear();
    salaryMaxController.clear();
    descriptionController.clear();
    qualificationController.clear();
    experienceMinController.clear();
    experienceMaxController.clear();
    internshipPeriodController.clear();
    skillsController.clear();
    vacancyController.clear();
    lastDateController.clear();

    selectedOccupationId = "";
    selectedProfessionId = "";
    selectedSpecializationId = "";
    selectedBusinessId = null;
    selectedBusinessName = null;
    jobSummaryFile = null;

    Future.delayed(Duration.zero, () {
      regiController.setSelectedCity("2");
    });
    areaController.clear();
    selectedJobType = "Full-time";
    selectedWorkMode = "On-site";
  }

  Widget _buildForm() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    if (_shouldShowCompanyNameInput())
                      _buildTextField(
                        "Company Name *",
                        controller: companyController,
                        onChanged: (_) => setState(() {}),
                      )
                    else
                      _buildBusinessDropdown(
                        label: "Company Name *",
                        selectedValue: selectedBusinessId ?? "",
                      ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      "Job Title *",
                      controller: titleController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      "Brief Job Description",
                      controller: descriptionController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    _buildCityDropdown(label: "Location *"),
                    _buildAreaFieldForSelectedCity(),
                    _buildDropdown(
                      label: "Salary Visible *",
                      items: const ["Yes", "No"],
                      selectedValue: salaryVisible == "1" ? "Yes" : "No",
                      onChanged: (val) {
                        setState(() {
                          salaryVisible = val == "Yes" ? "1" : "0";
                          if (salaryVisible == "0") {
                            salaryMinController.clear();
                            salaryMaxController.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    if (salaryVisible == "1") ...[
                      _buildTextField(
                        "Salary Minimum",
                        controller: salaryMinController,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        "Salary Maximum",
                        controller: salaryMaxController,
                      ),
                      const SizedBox(height: 20),
                    ],
                    _buildTextField(
                      "Minimum Experience (Years)",
                      controller: experienceMinController,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      "Maximum Experience (Years)",
                      controller: experienceMaxController,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      "Number of Vacancies *",
                      controller: vacancyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      focusNode: vacancyFocusNode,
                      onChanged: (value) {
                        setState(() {});
                        if (value.length == 2) {
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    themedDatePickerField(
                      context: context,
                      label: "Last Date to Apply",
                      hint: "Select last date",
                      controller: lastDateController,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 20),
                    _buildDropdown(
                      label: "Job Type *",
                      items: jobTypes,
                      selectedValue: selectedJobType,
                      onChanged: (val) {
                        setState(() {
                          selectedJobType = val;
                          if (selectedJobType != "Internship") {
                            internshipPeriodController.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    if (selectedJobType == "Internship") ...[
                      _buildTextField(
                        "Internship Time Period",
                        controller: internshipPeriodController,
                      ),
                      const SizedBox(height: 20),
                    ],
                    _buildDropdown(
                      label: "Work Mode *",
                      items: workModes,
                      selectedValue: selectedWorkMode,
                      onChanged: (val) {
                        setState(() => selectedWorkMode = val);
                      },
                    ),
                    const SizedBox(height: 20),
                    buildJobSummaryUploadField(
                      context: context,
                      file: jobSummaryFile,
                      buttonText: "Upload Job Description",
                      onPick: () {
                        _showImagePicker(context, (file) {
                          setState(() => jobSummaryFile = file);
                        });
                      },
                      onRemove: () {
                        setState(() => jobSummaryFile = null);
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
    );
  }

  Widget _buildBottomSubmitBar() {
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
              child: ElevatedButton(
                onPressed: (isSubmittingJob || !_isPostJobFormValid())
                    ? null
                    : () async {
                        await _submitJob();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorHelperClass.getColorFromHex(
                    ColorResources.red_color,
                  ),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSubmittingJob
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    int maxLines = 1,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
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

  Widget _buildAreaFieldForSelectedCity() {
    return Obx(() {
      if (regiController.city_id.value != "2") return const SizedBox.shrink();

      return Column(
        children: [
          _buildTextField("Area", controller: areaController),
          const SizedBox(height: 20),
        ],
      );
    });
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Column(
      children: [
        InputDecorator(
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
              isExpanded: true,
              value: selectedValue.isEmpty ? null : selectedValue,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessDropdown({
    required String label,
    required String selectedValue,
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          isExpanded: true,
          value: selectedValue.isEmpty ? null : selectedValue,
          items: businessProfiles.map((business) {
            return DropdownMenuItem<String>(
              value: business.memberBusinessOccupationProfileId,
              child: Text(
                business.businessName ?? "",
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                selectedBusinessId = val;
                final business = businessProfiles.firstWhere(
                  (b) => b.memberBusinessOccupationProfileId == val,
                );
                selectedBusinessName = business.businessName;
                companyController.text = business.businessName ?? "";

                if (business.addresses != null &&
                    business.addresses!.isNotEmpty) {
                  final businessCityName = business.addresses!.first.cityName;
                  if (businessCityName != null) {
                    final city = regiController.cityList.firstWhereOrNull(
                      (c) =>
                          (c.cityName ?? "").toLowerCase() ==
                          businessCityName.toLowerCase(),
                    );
                    if (city != null) {
                      regiController.setSelectedCity(city.id.toString());
                      areaController.clear();
                    }
                  }
                }
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildCityDropdown({required String label}) {
    return Obx(() {
      if (regiController.rxStatusCityLoading.value == Status.LOADING) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(color: Colors.redAccent),
            ),
          ),
        );
      }

      if (regiController.rxStatusCityLoading.value == Status.ERROR) {
        return const Text("Failed to load city");
      }

      if (regiController.cityList.isEmpty) {
        return const Text("No city available");
      }

      final selectedCity = regiController.city_id.value;

      return Column(
        children: [
          InputDecorator(
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
            isEmpty: selectedCity.isEmpty,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(10),
                isExpanded: true,
                value: selectedCity.isEmpty ? null : selectedCity,
                items: regiController.cityList.map((CityData city) {
                  return DropdownMenuItem<String>(
                    value: city.id.toString(),
                    child: Text(city.cityName ?? "Unknown"),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    regiController.setSelectedCity(val);
                    areaController.clear();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    });
  }

  Widget themedDatePickerField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
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
          DateTime now = DateTime.now();
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: now,
            firstDate: now,
            lastDate: DateTime(now.year + 5),
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
            controller.text = "${picked.day.toString().padLeft(2, '0')}/"
                "${picked.month.toString().padLeft(2, '0')}/"
                "${picked.year}";
            if (onChanged != null) onChanged();
          }
        },
      ),
    );
  }

  Widget buildJobSummaryUploadField({
    required BuildContext context,
    required File? file,
    required String buttonText,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    bool isUploaded = file != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (file != null)
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(file, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: onRemove,
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onPick,
            icon: Icon(isUploaded ? Icons.check_circle : Icons.upload_file),
            label: Text(isUploaded ? "$buttonText Uploaded" : buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded
                  ? Colors.green
                  : ColorHelperClass.getColorFromHex(ColorResources.red_color),
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
    Function(File) onFilePicked,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Upload Job Summary",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading:
                      const Icon(Icons.camera_alt, color: Colors.redAccent),
                  title: const Text("Take a Picture"),
                  onTap: () async {
                    Navigator.pop(context);
                    final picked = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 70,
                    );
                    if (picked != null) {
                      onFilePicked(File(picked.path));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image, color: Colors.redAccent),
                  title: const Text("Choose from Gallery"),
                  onTap: () async {
                    Navigator.pop(context);
                    final picked = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 70,
                    );
                    if (picked != null) {
                      onFilePicked(File(picked.path));
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Post New Job",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _buildForm(),
      bottomNavigationBar: _buildBottomSubmitBar(),
    );
  }

  @override
  void dispose() {
    vacancyFocusNode.dispose();
    titleController.dispose();
    companyController.dispose();
    locationController.dispose();
    areaController.dispose();
    salaryMinController.dispose();
    salaryMaxController.dispose();
    descriptionController.dispose();
    qualificationController.dispose();
    experienceMinController.dispose();
    experienceMaxController.dispose();
    skillsController.dispose();
    vacancyController.dispose();
    lastDateController.dispose();
    internshipPeriodController.dispose();
    super.dispose();
  }
}
