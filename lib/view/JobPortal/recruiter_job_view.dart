import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/BusinessProfile/BusinessOccupationProfile/BusinessOccupationProfileData.dart';
import 'package:mpm/model/JobPortal/GetJobAppliedMembers/GetJobAppliedMembersData.dart';
import 'package:mpm/model/JobPortal/GetJobByMemberId/GetJobByMemberIdData.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/repository/BusinessProfileRepo/business_occupation_profile_repository/business_occupation_profile_repo.dart';
import 'package:mpm/repository/JobPortal/CreateJobRepo/create_job_repository.dart';
import 'package:mpm/repository/JobPortal/GetJobAppliedMembersRepo/get_job_applied_members_repository.dart';
import 'package:mpm/repository/JobPortal/GetJobByMemberIdRepo/get_job_by_member_id_repository.dart';
import 'package:mpm/repository/JobPortal/GetOccupationByMemberIdRepo/get_occupation_by_member_id_repository.dart';
import 'package:mpm/repository/JobPortal/UpdateJobRepo/update_job_repository.dart';
import 'package:mpm/repository/JobPortal/UploadJobProfileDocumentRepo/upload_job_profile_document_repository.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/profile%20view/business_info_page.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:share_plus/share_plus.dart';

class RecruiterJobView extends StatefulWidget {
  final bool showOccupationBanner;

  const RecruiterJobView({
    super.key,
    this.showOccupationBanner = false,
  });

  @override
  State<RecruiterJobView> createState() => _RecruiterJobViewState();
}

class _RecruiterJobViewState extends State<RecruiterJobView> {
  String? selectedJobTitleForMembers;
  bool isRecruiter = false;
  late bool showOccupationBanner;
  final GetJobAppliedMembersRepository jobAppliedMembersRepository =
      GetJobAppliedMembersRepository();
  final GetOccupationByMemberIdRepository occupationRepository =
      GetOccupationByMemberIdRepository();
  final UploadJobProfileDocumentRepository uploadJobProfileDocumentRepository =
      UploadJobProfileDocumentRepository();
  final ImagePicker _picker = ImagePicker();
  File? jobSummaryFile;
  List<BusinessOccupationProfileData> businessProfiles = [];
  final UdateProfileController profileController =
      Get.find<UdateProfileController>();
  final NewMemberController regiController = Get.put(NewMemberController());

  String? selectedBusinessId;
  String? selectedBusinessName;

  bool isLoadingBusiness = false;
  bool isLoadingJobs = false;
  bool isLoadingAppliedMembers = false;
  bool isSubmittingJob = false;
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
  String selectedCategoryForPost = 'Publish';
  final List<String> jobTypes = [
    'Full-time',
    'Part-time',
    'Internship',
  ];
  final List<String> workModes = ['On-site', 'Work From Home', 'Hybrid'];
  final List<String> status = ['Publish', 'Draft'];
  List<GetJobByMemberIdData> postedJobs = [];

  String _getBackendJobStatus() {
    return selectedCategoryForPost == "Publish" ? "published" : "draft";
  }

  String _getUiJobStatus(String? backendStatus) {
    return backendStatus?.toLowerCase() == "published" ? "Publish" : "Draft";
  }

  String getBusinessName(String? businessId) {
    if (businessId == null || businessId.isEmpty) return "";

    final business = businessProfiles.firstWhereOrNull(
      (b) => b.memberBusinessOccupationProfileId == businessId,
    );

    return business?.businessName ?? "";
  }

  int selectedTabIndex = 0;

  List<String> jobTabs = [
    "Published",
    "Draft",
    "Closed",
  ];

  List<Map<String, dynamic>> appliedMembers = [];
  Map<String, int> applicantCountsByJobId = {};

  Future<void> loadBusinessProfiles() async {
    try {
      setState(() {
        isLoadingBusiness = true;
      });

      String memberId = profileController.memberId.value;

      final repo = BusinessOccupationProfileRepository();

      final response = await repo.fetchBusinessOccupationProfiles(
        memberId: memberId,
      );

      if (response.status == true && response.data != null) {
        setState(() {
          businessProfiles = response.data!;
        });
      }
    } catch (e) {
      debugPrint("Business Fetch Error: $e");
    } finally {
      setState(() {
        isLoadingBusiness = false;
      });
    }
  }

  List<GetJobByMemberIdData> get filteredJobs {
    switch (selectedTabIndex) {
      case 0:
        return postedJobs.where((e) {
          return (e.status ?? "").toLowerCase() == "published";
        }).toList();

      case 1:
        return postedJobs.where((e) {
          return (e.status ?? "").toLowerCase() == "draft";
        }).toList();

      case 2:
        return postedJobs.where((e) {
          return (e.status ?? "").toLowerCase() == "closed";
        }).toList();

      default:
        return postedJobs;
    }
  }

  Future<void> loadPostedJobs() async {
    try {
      setState(() {
        isLoadingJobs = true;
      });

      String memberId = profileController.memberId.value;

      final repo = GetJobByMemberIdRepository();

      final response = await repo.getJobs(memberId);

      if (response.status == true && response.data != null) {
        setState(() {
          postedJobs = response.data!;
        });
        _loadApplicantCountsForJobs(response.data!);
      }
    } catch (e) {
      debugPrint("❌ Job Fetch Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoadingJobs = false;
        });
      }
    }
  }

  Future<void> _loadApplicantCountsForJobs(
    List<GetJobByMemberIdData> jobs,
  ) async {
    final counts = <String, int>{};

    for (final job in jobs) {
      final jobId = job.jobId?.toString().trim() ?? "";
      if (jobId.isEmpty || (job.status ?? "").toLowerCase() == "draft") {
        continue;
      }

      try {
        final response =
            await jobAppliedMembersRepository.getJobAppliedMembers(jobId);
        counts[jobId] = response.totalCount ?? response.data?.length ?? 0;
      } catch (e) {
        debugPrint("Applicant Count Fetch Error for $jobId: $e");
      }
    }

    if (!mounted) return;

    setState(() {
      applicantCountsByJobId = {
        ...applicantCountsByJobId,
        ...counts,
      };
    });
  }

  Future<void> loadAppliedMembersForJob(GetJobByMemberIdData job) async {
    final jobId = job.jobId?.toString().trim() ?? "";

    if (jobId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Job id not found"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      selectedJobTitleForMembers = job.title ?? "";
      appliedMembers = [];
      isLoadingAppliedMembers = true;
    });

    try {
      final response =
          await jobAppliedMembersRepository.getJobAppliedMembers(jobId);

      if (!mounted) return;

      setState(() {
        appliedMembers = (response.data ?? <GetJobAppliedMembersData>[])
            .map((member) => _mapAppliedMemberToViewData(
                  member,
                  job.title ?? "",
                ))
            .toList();
        applicantCountsByJobId[jobId] =
            response.totalCount ?? appliedMembers.length;
      });
    } catch (e) {
      debugPrint("Get Job Applied Members Fetch Error: $e");

      if (!mounted) return;

      setState(() {
        appliedMembers = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to load applicants: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoadingAppliedMembers = false;
        });
      }
    }
  }

  Map<String, dynamic> _mapAppliedMemberToViewData(
    GetJobAppliedMembersData member,
    String jobTitle,
  ) {
    final fullName = [
      member.firstName,
      member.middleName,
      member.lastName,
    ]
        .where((name) => (name ?? "").trim().isNotEmpty)
        .map((name) => name!.trim())
        .join(" ");

    final displayName = (member.name ?? "").trim().isNotEmpty
        ? member.name!.trim()
        : fullName.isNotEmpty
            ? fullName
            : "Member";
    final status = (member.applicationStatus ?? "pending").trim().toLowerCase();

    return {
      "name": displayName,
      "email": member.email ?? "",
      "mobile": member.mobile ?? "",
      "whatsapp": member.whatsappNumber ?? "",
      "father_name": "",
      "mother_name": "",
      "building": "",
      "flat": "",
      "area": "",
      "city": "",
      "state": "",
      "country": "",
      "pincode": "",
      "education": "",
      "experience": "",
      "occupation": "",
      "job": jobTitle,
      "profile_summary": member.remarks ?? "",
      "resume": "",
      "status": status.isEmpty ? "pending" : status,
      "isShortlisted": status == "shortlisted",
      "image": member.profileImagePath ?? member.profileImage ?? "",
      "appliedDate": member.appliedDate ?? "",
      "memberId": member.memberId ?? "",
      "memberJobAppliedId": member.memberJobAppliedId ?? "",
    };
  }

  String _getProfileImageUrl(String? imagePath) {
    final image = imagePath?.toString().trim() ?? "";
    if (image.isEmpty) return "";
    if (image.startsWith("http://") || image.startsWith("https://")) {
      return image;
    }

    return Urls.imagePathUrl + image;
  }

  Color _getApplicantStatusColor(String? status) {
    switch ((status ?? "").toLowerCase()) {
      case "shortlisted":
        return Colors.orange;
      case "rejected":
        return Colors.red;
      case "recurted":
      case "recruited":
      case "selected":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getApplicantStatusFromLabel(String label) {
    switch (label) {
      case "Shortlist":
        return "shortlisted";
      case "Reject":
        return "rejected";
      case "Recurted":
        return "recurted";
      default:
        return "pending";
    }
  }

  String _getApplicantStatusLabel(String? status) {
    switch ((status ?? "").toLowerCase()) {
      case "shortlisted":
        return "Shortlist";
      case "rejected":
        return "Reject";
      case "recurted":
      case "recruited":
      case "selected":
        return "Recurted";
      default:
        return "Shortlist";
    }
  }

  @override
  void initState() {
    super.initState();
    showOccupationBanner = widget.showOccupationBanner;
    loadBusinessProfiles();
    loadPostedJobs();
    _refreshOccupationBanner();
  }

  String _getSelectedCityName() {
    final selectedCityId = regiController.city_id.value;

    if (selectedCityId.isEmpty) {
      return locationController.text.trim();
    }

    final selectedCity = regiController.cityList.firstWhereOrNull(
      (city) => city.id.toString() == selectedCityId,
    );

    return selectedCity?.cityName?.trim() ?? locationController.text.trim();
  }

  bool _shouldShowCompanyNameInput() {
    if (showOccupationBanner || businessProfiles.isEmpty) return true;

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

    if (sessionMemberId.isNotEmpty) {
      return sessionMemberId;
    }

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

      // FIXED
      "area_name": areaController.text.trim(),

      "salary_min": salaryVisible == "1"
          ? _cleanNumberForApi(salaryMinController.text)
          : "0",

      "salary_max": salaryVisible == "1"
          ? _cleanNumberForApi(salaryMaxController.text)
          : "0",

      "salary_visible": salaryVisible,

      "experience_min_years": _cleanNumberForApi(
        experienceMinController.text,
      ),

      "experience_max_years": _cleanNumberForApi(
        experienceMaxController.text,
      ),

      // FIXED
      "no_of_vacancy": _cleanNumberForApi(vacancyController.text),

      // FIXED
      "last_apply_date": _formatDateForApi(lastDateController.text),

      // FIXED
      "work_type": _getWorkType(),

      // FIXED
      "work_mode": _getWorkMode(),

      "status": _getBackendJobStatus(),

      "created_by": loggedInMemberId,
    };

    setState(() {
      isSubmittingJob = true;
    });

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
            "Job saved, but job id was missing for job description upload",
          );
        } else if (jobSummaryFile != null && loggedInMemberId.isEmpty) {
          throw Exception(
            "Job saved, but member id was missing for job description upload",
          );
        }

        await loadPostedJobs();

        if (!mounted) return;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? "Job saved successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
      if (mounted) {
        setState(() {
          isSubmittingJob = false;
        });
      }
    }
  }

  Future<void> _updateJob({required GetJobByMemberIdData job}) async {
    final backendJobStatus = _getBackendJobStatus();
    final loggedInMemberId = await _getLoggedInMemberId();
    final locationName = _getSelectedCityName();

    final updateBody = {
      "job_id": job.jobId ?? "",
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
      "area_name": areaController.text.trim(),
      "salary_min": salaryVisible == "1"
          ? _cleanNumberForApi(salaryMinController.text)
          : "0",
      "salary_max": salaryVisible == "1"
          ? _cleanNumberForApi(salaryMaxController.text)
          : "0",
      "salary_visible": salaryVisible,
      "experience_min_years": _cleanNumberForApi(
        experienceMinController.text,
      ),
      "experience_max_years": _cleanNumberForApi(
        experienceMaxController.text,
      ),
      "no_of_vacancy": _cleanNumberForApi(vacancyController.text),
      "last_apply_date": _formatDateForApi(lastDateController.text),
      "work_type": _getWorkType(),
      "work_mode": _getWorkMode(),
      "status": backendJobStatus,
      "updated_by": loggedInMemberId,
    };

    setState(() {
      isSubmittingJob = true;
    });

    try {
      final response = await UpdateJobRepository().updateJob(updateBody);

      if (response.status == true) {
        await loadPostedJobs();

        if (!mounted) return;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? "Job updated successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception(response.message ?? "Failed to update job");
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update job: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmittingJob = false;
        });
      }
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

  String _getUiJobType(String? backendJobType) {
    switch ((backendJobType ?? "").toLowerCase()) {
      case "full_time":
        return "Full-time";
      case "part_time":
        return "Part-time";
      case "internship":
        return "Internship";
      default:
        return jobTypes.contains(backendJobType) ? backendJobType! : "Full-time";
    }
  }

  String _getUiWorkMode(String? backendWorkMode) {
    switch ((backendWorkMode ?? "").toLowerCase()) {
      case "onsite":
        return "On-site";
      case "remote":
        return "Work From Home";
      case "hybrid":
        return "Hybrid";
      default:
        return workModes.contains(backendWorkMode)
            ? backendWorkMode!
            : "On-site";
    }
  }

  Future<void> _refreshOccupationBanner() async {
    try {
      final memberId = profileController.memberId.value;
      final response =
          await occupationRepository.getOccupationsByMemberId(memberId);

      final hasOccupation = (response.totalCount ?? 0) > 0;
      var hasCompanyName = false;

      if (response.data != null && response.data!.isNotEmpty) {
        for (final occupation in response.data!) {
          if (occupation.companyName != null &&
              occupation.companyName.toString().trim().isNotEmpty) {
            hasCompanyName = true;
            break;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        showOccupationBanner = !hasOccupation || !hasCompanyName;
      });
    } catch (e) {
      debugPrint("Occupation Banner Check Error: $e");
    }
  }

  Future<void> _openOccupationDetails() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BusinessInformationPage(autoOpenAddSheet: true),
      ),
    );

    await profileController.getUserProfile();
    await loadBusinessProfiles();
    await _refreshOccupationBanner();
  }

  String formatDisplayDate(String? date) {
    if (date == null || date.isEmpty) return "";

    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  Widget _buildOccupationBanner() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: _openOccupationDetails,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade700,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: const [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Click here to update your Occupation and Business Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecruiterBody() {
    return selectedJobTitleForMembers == null
        ? _buildPostedJobs()
        : _buildAppliedMembersForJob();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        leading: selectedJobTitleForMembers == null
            ? null
            : IconButton(
                onPressed: () {
                  setState(() {
                    selectedJobTitleForMembers = null;
                    appliedMembers = [];
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
        title: Text(
          selectedJobTitleForMembers == null ? "Offer Jobs" : "Applicants",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: selectedJobTitleForMembers == null && postedJobs.isNotEmpty
            ? PreferredSize(
                preferredSize: const Size.fromHeight(55),
                child: Container(
                  color: Colors.white,
                  child: Row(
                    children: List.generate(
                      jobTabs.length,
                      (index) {
                        final isSelected = selectedTabIndex == index;

                        return Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedTabIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isSelected
                                        ? Colors.red
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Text(
                                jobTabs[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.red : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: _buildRecruiterBody(),
      floatingActionButton: selectedJobTitleForMembers == null &&
              postedJobs.isNotEmpty
          ? FloatingActionButton(
              backgroundColor:
                  ColorHelperClass.getColorFromHex(ColorResources.red_color),
              onPressed: () {
                _openPostJobBottomSheet();
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildAppliedMembersForJob() {
    final filteredMembers = appliedMembers;

    bool hasShortlisted =
        filteredMembers.any((member) => member["isShortlisted"] == true);

    return Column(
      children: [
        if (hasShortlisted)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _shareShortlistedMembers(context),
                icon: const Icon(Icons.share),
                label: const Text("Share Shortlisted"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Job Name",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                selectedJobTitleForMembers ?? "",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (isLoadingAppliedMembers)
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: ColorHelperClass.getColorFromHex(
                  ColorResources.red_color,
                ),
              ),
            ),
          )
        else if (filteredMembers.isEmpty)
          const Expanded(
            child: Center(child: Text("No applicants for this job")),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: filteredMembers.length,
              itemBuilder: (context, index) {
                final member = filteredMembers[index];
                final profileImageUrl = _getProfileImageUrl(member["image"]);
                final statusColor =
                    _getApplicantStatusColor(member["status"]);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "No. ${index + 1}",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.grey.shade200,
                            child: ClipOval(
                              child: profileImageUrl.isNotEmpty
                                  ? FadeInImage(
                                      placeholder: const AssetImage(
                                        "assets/images/user3.png",
                                      ),
                                      image: NetworkImage(profileImageUrl),
                                      imageErrorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          "assets/images/male.png",
                                          fit: BoxFit.cover,
                                          width: 64,
                                          height: 64,
                                        );
                                      },
                                      fit: BoxFit.cover,
                                      width: 64,
                                      height: 64,
                                    )
                                  : Image.asset(
                                      "assets/images/user3.png",
                                      fit: BoxFit.cover,
                                      width: 64,
                                      height: 64,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        member["name"] ?? "",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        member["status"]
                                            .toString()
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                    )
                                  ],
                                ),

                                const SizedBox(height: 6),

                                /// Email
                                Text(
                                  member["email"] ?? "",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                /// Mobile
                                Text(
                                  member["mobile"] ?? "",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                /// Profile Summary
                                Text(
                                  member["profile_summary"] ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                /// Experience
                                Text(
                                  "Experience: ${member["experience"]}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      /// Divider
                      const Divider(height: 1),

                      /// Bottom button section
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                _showApplicantStatusDialog(member);
                              },
                              child: const Text(
                                "Edit",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                _showProfileBottomSheet(member);
                              },
                              child: const Text(
                                "View Profile",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPostedJobs() {
    if (isLoadingJobs) {
      return Column(
        children: [
          if (showOccupationBanner) _buildOccupationBanner(),
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: ColorHelperClass.getColorFromHex(
                  ColorResources.red_color,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (postedJobs.isEmpty) {
      return Column(
        children: [
          if (showOccupationBanner) _buildOccupationBanner(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.work_outline,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "No Jobs Posted Yet",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Start by posting your first job",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      _openPostJobBottomSheet();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Post Job",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (showOccupationBanner) _buildOccupationBanner(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              16,
              showOccupationBanner ? 0 : 16,
              16,
              20,
            ),
            itemCount: filteredJobs.length,
            itemBuilder: (context, index) {
              final job = filteredJobs[index];

              String salary =
                  "${job.salaryMin ?? "0"} - ${job.salaryMax ?? "0"}";

              String experience =
                  "${job.experienceMinYears ?? "0"} - ${job.experienceMaxYears ?? "0"} Years";
              final jobId = job.jobId?.toString().trim() ?? "";
              final applicantCount = applicantCountsByJobId[jobId] ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade200, blurRadius: 6)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            job.title ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if ((job.status ?? "").toLowerCase() != "draft")
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      loadAppliedMembersForJob(job);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "$applicantCount Applicants",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            PopupMenuButton<String>(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              onSelected: (value) {
                                if (value == "edit") {
                                  _openPostJobBottomSheet(editJob: job);
                                } else if (value == "close") {
                                  _showDeleteDialog(index);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: "edit",
                                  child: Text(
                                    "Edit Job",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "close",
                                  child: Text(
                                    "Close Job",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                              child: const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.more_vert,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 6),
                    const Divider(),
                    const SizedBox(height: 8),
                    _infoRow(
                      "Company",
                      getBusinessName(job.memberBusinessOccupationProfileId),
                    ),
                    const SizedBox(height: 8),
                    _infoRow("Location", job.location ?? ""),
                    const SizedBox(height: 8),
                    _infoRow("Salary", salary),
                    const SizedBox(height: 8),
                    _infoRow("Experience", experience),
                    const SizedBox(height: 8),
                    if ((job.status ?? "").toLowerCase() == "published")
                      _infoRow(
                        "Published On",
                        formatDisplayDate(job.publishedAt),
                      )
                    else if ((job.status ?? "").toLowerCase() == "closed")
                      _infoRow(
                        "Closed On",
                        formatDisplayDate(job.closedAt),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showProfileBottomSheet(Map<String, dynamic> member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int experienceYears = int.tryParse(
              member["experience"]
                      ?.toString()
                      .replaceAll(RegExp(r'[^0-9]'), '') ??
                  "0",
            ) ??
            0;

        String mobile = member["mobile"] ?? "";
        String whatsapp = member["whatsapp"] ?? "";

        String contactValue =
            mobile == whatsapp ? mobile : "$mobile / $whatsapp";

        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.85,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    children: [
                      const Text(
                        "Member Profile",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("Personal Details"),
                          const SizedBox(height: 12),
                          _profileRow("Name", member["name"]),
                          _profileRow("Email", member["email"]),
                          _profileRow("Mobile / WhatsApp", contactValue),
                          const SizedBox(height: 16),
                          _sectionTitle("Profile Summary"),
                          const SizedBox(height: 10),
                          Text(
                            member["profile_summary"] ??
                                "No profile summary available.",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _sectionTitle("Residential Address"),
                          const SizedBox(height: 12),
                          Text(
                            "${member["flat"] ?? ""}, "
                            "${member["building"] ?? ""}, "
                            "${member["area"] ?? ""},\n"
                            "${member["city"] ?? ""}, "
                            "${member["state"] ?? ""}, "
                            "${member["country"] ?? ""} - "
                            "${member["pincode"] ?? ""}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 15),
                          if (experienceYears > 0) ...[
                            _sectionTitle("Occupation"),
                            const SizedBox(height: 12),
                            _profileRow(
                              "Experience",
                              member["experience"] ?? "$experienceYears Years",
                            ),
                            _profileRow(
                                "Current Occupation", member["occupation"]),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 15),
                          ],
                          _sectionTitle("Education"),
                          const SizedBox(height: 12),
                          _profileRow(
                            "Highest Qualification",
                            member["education"],
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 15),
                          _sectionTitle("Family Details"),
                          const SizedBox(height: 12),
                          _profileRow("Father's Name", member["father_name"]),
                          _profileRow("Mother's Name", member["mother_name"]),
                          const SizedBox(height: 30),
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
  }

  void _showApplicantStatusDialog(Map<String, dynamic> member) {
    String selectedStatus = _getApplicantStatusLabel(member["status"]);
    final statusOptions = ["Shortlist", "Reject", "Recurted"];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              actionsPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorHelperClass.getColorFromHex(
                        ColorResources.red_color,
                      ),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      final status =
                          _getApplicantStatusFromLabel(selectedStatus);

                      setState(() {
                        member["status"] = status;
                        member["isShortlisted"] = status == "shortlisted";
                      });

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "${member["name"]} status updated",
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorHelperClass.getColorFromHex(
                        ColorResources.red_color,
                      ),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Submit"),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Applicant Status",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(
                      labelText: "Applicant Status",
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black38, width: 1),
                      ),
                    ),
                    items: statusOptions.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedStatus = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showResumeDialog(
    BuildContext context,
    String filePath,
    String candidateName,
  ) {
    bool isPdf = filePath.toLowerCase().endsWith(".pdf");

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$candidateName Resume",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                width: double.infinity,
                child: isPdf
                    ? const Center(
                        child: Icon(
                          Icons.picture_as_pdf,
                          size: 80,
                          color: Colors.red,
                        ),
                      )
                    : Image.network(filePath, fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Share.share(
                          filePath,
                          subject: "$candidateName Resume",
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text("Share"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(
                            ColorResources.red_color),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareShortlistedMembers(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    final shortlisted = appliedMembers
        .where((member) => member["isShortlisted"] == true)
        .toList();

    if (shortlisted.isEmpty) return;

    String shareText = "Shortlisted Members Details\n\n";

    for (var member in shortlisted) {
      shareText += '''
      Name: ${member["name"]}
      Email: ${member["email"]}
      Mobile: ${member["mobile"]}
      WhatsApp: ${member["whatsapp"]}
      
      Education: ${member["education"]}
      Occupation: ${member["occupation"]}
      
      Address:
      ${member["building"]}, ${member["flat"]}
      ${member["area"]}, ${member["city"]}
      ${member["state"]}, ${member["country"]} - ${member["pincode"]}
      
      ----------------------------------
      ''';
    }

    await Share.share(
      shareText,
      subject: "Shortlisted Members",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Widget _profileRow(String label, dynamic value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        const Text(": "),
        Expanded(
          child: Text(
            value?.toString() ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  void dispose() {
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

  Future<void> _openPostJobBottomSheet({GetJobByMemberIdData? editJob}) async {
    if (editJob != null) {
      final job = editJob;
      titleController.text = job.title ?? "";
      locationController.text = job.location ?? "";
      areaController.clear();
      salaryMinController.text = job.salaryMin ?? "";
      salaryMaxController.text = job.salaryMax ?? "";
      salaryVisible = job.salaryVisible ?? "1";
      descriptionController.text = job.description ?? "";
      experienceMinController.text = job.experienceMinYears ?? "";
      experienceMaxController.text = job.experienceMaxYears ?? "";
      vacancyController.text = job.numberOfVacancies ?? "";
      lastDateController.text = job.lastDateToApply ?? "";
      internshipPeriodController.text = job.internshipTimePeriod ?? "";
      selectedJobType = _getUiJobType(job.jobType);
      selectedWorkMode = _getUiWorkMode(job.workMode);
      selectedCategoryForPost = _getUiJobStatus(job.jobPostStatus);

      selectedBusinessId = job.memberBusinessOccupationProfileId ?? "";

      final business = businessProfiles.firstWhereOrNull(
          (b) => b.memberBusinessOccupationProfileId == selectedBusinessId);

      selectedBusinessName = business?.businessName;
      companyController.text = selectedBusinessName ?? "";

      selectedOccupationId = job.occupationId ?? "";

      await profileController.getOccupationProData(selectedOccupationId);

      selectedProfessionId = job.occupationProfessionId ?? "";

      await profileController.getOccupationSpectData(selectedProfessionId);

      selectedSpecializationId = job.occupationSpecializationId ?? "";

      regiController.setSelectedCity(job.cityId ?? "");
    } else {
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
      selectedCategoryForPost = "Publish";
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
          builder: (context, modalSetState) {
            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.85,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      /// Header Buttons
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
                            onPressed: isSubmittingJob
                                ? null
                                : () async {
                                    if (editJob != null) {
                                      await _updateJob(job: editJob);
                                    } else {
                                      await _submitJob();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
                                : Text(editJob != null
                                    ? "Update Job"
                                    : "Submit"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        editJob != null
                            ? "Update Posted Job"
                            : "Post New Job",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              if (_shouldShowCompanyNameInput())
                                _buildTextField(
                                  "Company Name *",
                                  controller: companyController,
                                )
                              else
                                _buildBusinessDropdown(
                                  label: "Company Name *",
                                  selectedValue: selectedBusinessId ?? "",
                                  modalSetState: modalSetState,
                                ),
                              _buildTextField(
                                "Job Title *",
                                controller: titleController,
                              ),
                              _buildTextField(
                                "Breif Job Description",
                                controller: descriptionController,
                                maxLines: 3,
                              ),
                              // _buildOccupationDropdown(),
                              _buildCityDropdown(label: "Location *"),
                              _buildAreaFieldForSelectedCity(),
                              _buildDropdown(
                                label: "Salary Visible *",
                                items: const ["Yes", "No"],
                                selectedValue:
                                    salaryVisible == "1" ? "Yes" : "No",
                                onChanged: (val) {
                                  modalSetState(() {
                                    salaryVisible = val == "Yes" ? "1" : "0";
                                    if (salaryVisible == "0") {
                                      salaryMinController.clear();
                                      salaryMaxController.clear();
                                    }
                                  });
                                },
                              ),
                              if (salaryVisible == "1") ...[
                                _buildTextField(
                                  "Salary Minimum",
                                  controller: salaryMinController,
                                ),
                                _buildTextField(
                                  "Salary Maximum",
                                  controller: salaryMaxController,
                                ),
                              ],
                              _buildTextField(
                                "Minimum Experience (Years)",
                                controller: experienceMinController,
                              ),
                              _buildTextField(
                                "Maximum Experience (Years)",
                                controller: experienceMaxController,
                              ),
                              _buildTextField(
                                "Number of Vacancies *",
                                controller: vacancyController,
                              ),
                              themedDatePickerField(
                                context: context,
                                label: "Last Date to Apply",
                                hint: "Select last date",
                                controller: lastDateController,
                                onChanged: () {
                                  modalSetState(() {});
                                },
                              ),
                              const SizedBox(height: 10),
                              _buildDropdown(
                                label: "Job Type *",
                                items: jobTypes,
                                selectedValue: selectedJobType,
                                onChanged: (val) {
                                  modalSetState(() {
                                    selectedJobType = val;
                                    if (selectedJobType != "Internship") {
                                      internshipPeriodController.clear();
                                    }
                                  });
                                },
                              ),
                              if (selectedJobType == "Internship")
                                _buildTextField(
                                  "Internship Time Period",
                                  controller: internshipPeriodController,
                                ),
                              _buildDropdown(
                                label: "Work Mode *",
                                items: workModes,
                                selectedValue: selectedWorkMode,
                                onChanged: (val) {
                                  modalSetState(() {
                                    selectedWorkMode = val;
                                  });
                                },
                              ),
                              _buildDropdown(
                                label: "Job Post Status",
                                items: status,
                                selectedValue: selectedCategoryForPost,
                                onChanged: (val) {
                                  modalSetState(() {
                                    selectedCategoryForPost = val;
                                  });
                                },
                              ),
                              buildJobSummaryUploadField(
                                context: context,
                                file: jobSummaryFile,
                                buttonText: "Upload Job Description",
                                onPick: () {
                                  _showImagePicker(context, (file) {
                                    modalSetState(() {
                                      jobSummaryFile = file;
                                    });
                                  });
                                },
                                onRemove: () {
                                  modalSetState(() {
                                    jobSummaryFile = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 30),
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

  Widget _buildTextField(
    String label, {
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelStyle: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildAreaFieldForSelectedCity() {
    return Obx(() {
      if (regiController.city_id.value != "2") {
        return const SizedBox.shrink();
      }

      return _buildTextField(
        "Area",
        controller: areaController,
      );
    });
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InputDecorator(
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                onChanged(val);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessDropdown({
    required String label,
    required String selectedValue,
    required StateSetter modalSetState,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InputDecorator(
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                  modalSetState(() {
                    selectedBusinessId = val;

                    final business = businessProfiles.firstWhere(
                      (b) => b.memberBusinessOccupationProfileId == val,
                    );

                    selectedBusinessName = business.businessName;
                    companyController.text = business.businessName ?? "";

                    if (business.addresses != null &&
                        business.addresses!.isNotEmpty) {
                      final businessCityName =
                          business.addresses!.first.cityName;

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
              }),
        ),
      ),
    );
  }

  Widget _buildCityDropdown({
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Obx(() {
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                }),
          ),
        );
      }),
    );
  }

  Widget _buildOccupationDropdown() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Obx(() {
            if (profileController.rxStatusOccupation.value == Status.LOADING) {
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

            return DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
              value: selectedOccupationId.isEmpty ? null : selectedOccupationId,
              decoration: const InputDecoration(
                labelText: "Occupation (Level 1)",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black38, width: 1),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                labelStyle: TextStyle(color: Colors.black),
              ),
              items: profileController.occuptionList.map((occupation) {
                return DropdownMenuItem<String>(
                  value: occupation.id.toString(),
                  child: Text(occupation.occupation ?? ""),
                );
              }).toList(),
              onChanged: (val) async {
                if (val != null) {
                  setState(() {
                    selectedOccupationId = val;
                    selectedProfessionId = "";
                    selectedSpecializationId = "";
                  });

                  await profileController.getOccupationProData(val);
                }
              },
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Obx(() {
            return DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
              value: selectedProfessionId.isEmpty ? null : selectedProfessionId,
              decoration: const InputDecoration(
                labelText: "Profession (Level 2)",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black38, width: 1),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                labelStyle: TextStyle(color: Colors.black),
              ),
              items: profileController.occuptionProfessionList.map((prof) {
                return DropdownMenuItem<String>(
                  value: prof.id.toString(),
                  child: Text(prof.name ?? ""),
                );
              }).toList(),
              onChanged: (val) async {
                if (val != null) {
                  setState(() {
                    selectedProfessionId = val;
                    selectedSpecializationId = "";
                  });

                  await profileController.getOccupationSpectData(val);
                }
              },
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Obx(() {
            return DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
              value: selectedSpecializationId.isEmpty
                  ? null
                  : selectedSpecializationId,
              decoration: const InputDecoration(
                labelText: "Specialization (Level 3)",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black38, width: 1),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                labelStyle: TextStyle(color: Colors.black),
              ),
              items: profileController.occuptionSpeList.map((spec) {
                return DropdownMenuItem<String>(
                  value: spec.id.toString(),
                  child: Text(spec.name ?? ""),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedSpecializationId = val;
                  });
                }
              },
            );
          }),
        ),
      ],
    );
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

            if (onChanged != null) {
              onChanged();
            }
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          const Text(
            ": ",
            style: TextStyle(color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: label == "Salary" ? Colors.green : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocalDocumentPreviewDialog(
    BuildContext context,
    File file,
    String title,
  ) {
    bool isPdf = file.path.toLowerCase().endsWith(".pdf");

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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: isPdf
                    ? const Center(
                        child: Icon(
                          Icons.picture_as_pdf,
                          size: 80,
                          color: Colors.red,
                        ),
                      )
                    : Image.file(
                        file,
                        fit: BoxFit.contain,
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

  void _showCvPreviewDialog(
    BuildContext context,
    String filePath,
    String title,
  ) {
    bool isPdf = filePath.toLowerCase().endsWith(".pdf");

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
            SizedBox(
              height: 300,
              width: double.infinity,
              child: isPdf
                  ? const Center(
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: 80,
                        color: Colors.red,
                      ),
                    )
                  : filePath.startsWith("http")
                      ? Image.network(filePath, fit: BoxFit.contain)
                      : Image.file(File(filePath), fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
              ),
              child: const Text("Close"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(int index) {
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
                "Close Job",
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
            "Are you sure you want to close this job?",
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
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  postedJobs.removeAt(index);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Job closed successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("close"),
            ),
          ],
        );
      },
    );
  }
}
