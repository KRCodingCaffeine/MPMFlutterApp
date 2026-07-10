import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/BusinessProfile/BusinessOccupationProfile/BusinessOccupationProfileData.dart';
import 'package:mpm/model/JobPortal/GetJobByMemberId/GetJobByMemberIdData.dart';
import 'package:mpm/model/JobPortal/GetSeekerProfile/GetSeekerProfileData.dart';
import 'package:mpm/model/JobPortal/JobsForSeekerJob/JobsForSeekerJobData.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/repository/BusinessProfileRepo/business_occupation_profile_repository/business_occupation_profile_repo.dart';
import 'package:mpm/repository/JobPortal/AddSeekerProfileRepo/add_seeker_profile_repository.dart';
import 'package:mpm/repository/JobPortal/GetSeekerProfileRepo/get_seeker_profile_repository.dart';
import 'package:mpm/repository/JobPortal/GetJobByMemberIdRepo/get_job_by_member_id_repository.dart';
import 'package:mpm/repository/JobPortal/JobsForSeekerRepo/jobs_for_seeker_repository.dart';
import 'package:mpm/repository/JobPortal/UpdateSeekerProfileRepo/update_seeker_profile_repository.dart';
import 'package:mpm/repository/JobPortal/UploadResumeRepo/upload_resume_repository.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/JobPortal/job_detail.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class JobSeekerView extends StatefulWidget {
  const JobSeekerView({super.key});

  @override
  State<JobSeekerView> createState() => _JobSeekerViewState();
}

class _JobSeekerViewState extends State<JobSeekerView> {
  int selectedTab = 0;
  final GetJobByMemberIdRepository jobRepository = GetJobByMemberIdRepository();
  final JobsForSeekerRepository jobsForSeekerRepository =
      JobsForSeekerRepository();
  final UdateProfileController profileController =
      Get.find<UdateProfileController>();
  final NewMemberController regiController = Get.put(NewMemberController());
  final AddSeekerProfileRepository seekerRepository =
      AddSeekerProfileRepository();
  final GetSeekerProfileRepository getSeekerProfileRepository =
      GetSeekerProfileRepository();
  final UpdateSeekerProfileRepository updateSeekerProfileRepository =
      UpdateSeekerProfileRepository();
  final UploadResumeRepository uploadResumeRepository =
      UploadResumeRepository();

  String selectedCategory = "All";
  String selectedLocation = "All";
  File? selectedResume;
  String? selectedResumeName;
  bool isLoadingJobs = false;
  bool hasOpenedPreferredSheet = false;
  bool? hasSeekerProfile;
  bool isCheckingSeekerProfile = false;
  GetSeekerProfileData? seekerProfileData;
  RangeValues selectedSalaryRange = const RangeValues(0, 50);
  TextEditingController searchController = TextEditingController();
  TextEditingController preferredNameController = TextEditingController();
  TextEditingController preferredEmailController = TextEditingController();
  TextEditingController preferredMobileController = TextEditingController();
  TextEditingController preferredWhatsappController = TextEditingController();
  TextEditingController fieldToWorkController = TextEditingController();
  TextEditingController expectedSalaryController = TextEditingController();
  TextEditingController preferredAreaController = TextEditingController();
  TextEditingController internshipMonthController = TextEditingController();
  String selectedPreferredCityId = "";
  String selectedPreferredWorkMode = "On-site";
  String selectedPreferredJobType = "Full-time";
  final List<String> preferredWorkModes = [
    "On-site",
    "Work From Home",
    "Hybrid",
  ];
  final List<String> preferredJobTypes = [
    "Full-time",
    "Part-time",
    "Internship",
  ];

  double _getSalaryValue(String salary) {
    try {
      final cleanedForFilter =
          salary.replaceAll(RegExp(r'[^0-9.\-]'), '').trim();
      final parts = cleanedForFilter.split("-");
      return _normalizeSalaryForFilter(double.parse(parts.first.trim()));
    } catch (e) {
      return 0;
    }
  }

  double _normalizeSalaryForFilter(double salary) {
    if (salary > 1000) {
      return salary / 100000;
    }

    return salary;
  }

  List<Map<String, dynamic>> appliedJobs = [];

  final List<String> categories = ["IT", "Finance", "Marketing", "Design"];

  List<BusinessOccupationProfileData> businessProfiles = [];
  List<Map<String, dynamic>> jobs = [];

  @override
  void initState() {
    super.initState();

    if (regiController.cityList.isEmpty) {
      regiController.getCity();
    }

    loadJobs();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndOpenPreferredDetails();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    preferredNameController.dispose();
    preferredEmailController.dispose();
    preferredMobileController.dispose();
    preferredWhatsappController.dispose();
    fieldToWorkController.dispose();
    expectedSalaryController.dispose();
    preferredAreaController.dispose();
    internshipMonthController.dispose();
    super.dispose();
  }

  Future<void> loadJobs() async {
    try {
      setState(() {
        isLoadingJobs = true;
      });

      final memberId = await _getLoggedInMemberId();

      if (memberId.isEmpty) {
        debugPrint("Job List Fetch Error: member id is empty");
        if (mounted) {
          setState(() {
            jobs = [];
          });
        }
        return;
      }

      await _loadSeekerProfileForJobs(memberId);
      await loadBusinessProfiles(memberId: memberId);

      final jobsForSeeker = await _loadJobsForSeeker(memberId);
      final getJobs = await _loadGetJobs(
        seekerProfileData?.memberId?.trim().isNotEmpty == true
            ? seekerProfileData!.memberId!.trim()
            : memberId,
      );

      if (!mounted) return;

      final seenJobIds = <String>{};

      final mappedJobsForSeeker = jobsForSeeker
          .where((job) => (job.status ?? "").toLowerCase() == "published")
          .map(_mapSeekerJobToViewData)
          .where((job) => seenJobIds.add(job["jobId"]?.toString() ?? ""))
          .toList();

      final mappedGetJobs = getJobs
          .where((job) => (job.status ?? "").toLowerCase() == "published")
          .map(_mapJobToViewData)
          .where((job) => seenJobIds.add(job["jobId"]?.toString() ?? ""))
          .toList();

      setState(() {
        jobs = [
          ...mappedJobsForSeeker,
          ...mappedGetJobs,
        ];
      });
    } catch (e) {
      debugPrint("Job List Fetch Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoadingJobs = false;
        });
      }
    }
  }

  Future<List<JobsForSeekerJobData>> _loadJobsForSeeker(
    String memberId,
  ) async {
    try {
      final response = await jobsForSeekerRepository.getJobsForSeeker(memberId);
      if (response.status == true) {
        return response.data?.jobs ?? <JobsForSeekerJobData>[];
      }
    } catch (e) {
      debugPrint("Jobs For Seeker Fetch Error: $e");
    }

    return <JobsForSeekerJobData>[];
  }

  Future<List<GetJobByMemberIdData>> _loadGetJobs(String memberId) async {
    try {
      final response = await jobRepository.getJobs(
        memberId,
        status: "published",
      );
      if (response.status == true) {
        return response.data ?? <GetJobByMemberIdData>[];
      }
    } catch (e) {
      debugPrint("Get Jobs Fetch Error: $e");
    }

    return <GetJobByMemberIdData>[];
  }

  Future<void> _loadSeekerProfileForJobs(String memberId) async {
    try {
      final response =
          await getSeekerProfileRepository.getSeekerProfile(memberId);
      final data = response.data;
      final exists = response.status == true &&
          data != null &&
          ((data.seekerProfileId ?? "").trim().isNotEmpty ||
              (data.memberId ?? "").trim().isNotEmpty);

      hasSeekerProfile = exists;
      seekerProfileData = exists ? data : null;
    } catch (e) {
      debugPrint("Get Seeker Profile Before Jobs Error: $e");
    }
  }

  Future<void> _checkAndOpenPreferredDetails() async {
    if (hasOpenedPreferredSheet) return;

    await Future.delayed(const Duration(milliseconds: 500));

    final seekerProfileExists = await _seekerProfileExists();
    if (seekerProfileExists || !mounted) return;

    // First-time user check
    bool isFirstTimeUser = preferredNameController.text.isEmpty &&
        preferredEmailController.text.isEmpty &&
        preferredMobileController.text.isEmpty &&
        fieldToWorkController.text.isEmpty;

    if (isFirstTimeUser && mounted) {
      hasOpenedPreferredSheet = true;
      _openPreferredCitySheet();
    }
  }

  Future<String> _getLoggedInMemberId() async {
    final session = await SessionManager.getSession();
    final sessionMemberId = session?.memberId?.toString().trim() ?? "";

    if (sessionMemberId.isNotEmpty) {
      return sessionMemberId;
    }

    return profileController.memberId.value.trim();
  }

  Future<bool> _seekerProfileExists({bool forceRefresh = false}) async {
    if (!forceRefresh && hasSeekerProfile == true) {
      return true;
    }

    if (isCheckingSeekerProfile) {
      return hasSeekerProfile == true;
    }

    try {
      isCheckingSeekerProfile = true;
      final memberId = await _getLoggedInMemberId();

      if (memberId.isEmpty) {
        return false;
      }

      final response =
          await getSeekerProfileRepository.getSeekerProfile(memberId);
      final data = response.data;
      final exists = response.status == true &&
          data != null &&
          ((data.seekerProfileId ?? "").trim().isNotEmpty ||
              (data.memberId ?? "").trim().isNotEmpty);

      hasSeekerProfile = exists;
      seekerProfileData = exists ? data : null;
      return exists;
    } catch (e) {
      debugPrint("Get Seeker Profile Check Error: $e");
      return false;
    } finally {
      isCheckingSeekerProfile = false;
    }
  }

  Future<void> _handlePreferredDetailsPressed() async {
    final seekerProfileExists = await _seekerProfileExists(forceRefresh: true);

    if (seekerProfileExists) {
      if (!mounted) return;

      _openPreferredCitySheet(prefillExistingProfile: true);
      return;
    }

    if (mounted) {
      _openPreferredCitySheet();
    }
  }

  Future<void> loadBusinessProfiles({String? memberId}) async {
    try {
      final businessMemberId = memberId ?? await _getLoggedInMemberId();
      if (businessMemberId.isEmpty) return;

      final response = await BusinessOccupationProfileRepository()
          .fetchBusinessOccupationProfiles(
        memberId: businessMemberId,
      );

      if (response.status == true && response.data != null) {
        businessProfiles = response.data!;
      }
    } catch (e) {
      debugPrint("Business Fetch Error: $e");
    }
  }

  String getBusinessName(String? businessId) {
    if (businessId == null || businessId.isEmpty) return "";

    final business = businessProfiles.firstWhereOrNull(
      (b) => b.memberBusinessOccupationProfileId == businessId,
    );

    return business?.businessName ?? "";
  }

  Map<String, dynamic> _mapJobToViewData(GetJobByMemberIdData job) {
    final companyName = (job.companyName ?? "").trim();
    final businessName =
        getBusinessName(job.memberBusinessOccupationProfileId).trim();

    return {
      "jobId": job.jobId ?? "",
      "title": job.title ?? "",
      "company": companyName.isNotEmpty
          ? companyName
          : businessName.isNotEmpty
              ? businessName
              : "Company",
      "location": job.location ?? "",
      "salary": _formatSalaryFromValues(
        salaryVisible: job.salaryVisible,
        salaryMin: job.salaryMin,
        salaryMax: job.salaryMax,
      ),
      "experience": _formatExperienceFromValues(
        job.experienceMinYears,
        job.experienceMaxYears,
      ),
      "postedDate": _formatDate(job.publishedAt ?? job.createdAt ?? ""),
      "category": "IT",
      "isBookmarked": false,
      "isPreferredJob": false,
      "jobData": job,
    };
  }

  Map<String, dynamic> _mapSeekerJobToViewData(JobsForSeekerJobData job) {
    final businessName =
        getBusinessName(job.memberBusinessOccupationProfileId).trim();

    return {
      "jobId": job.jobId ?? "",
      "title": job.title ?? "",
      "company": businessName.isNotEmpty ? businessName : "Company",
      "location": job.location ?? "",
      "salary": _formatSalaryFromValues(
        salaryVisible: job.salaryVisible,
        salaryMin: job.salaryMin,
        salaryMax: job.salaryMax,
        salaryRange: job.salaryRange,
      ),
      "experience": _formatExperienceFromValues(
        job.experienceMinYears,
        job.experienceMaxYears,
      ),
      "postedDate": _formatDate(job.publishedAt ?? job.createdAt ?? ""),
      "category": "IT",
      "isBookmarked": false,
      "isPreferredJob": true,
      "jobData": job,
    };
  }

  String _formatSalaryFromValues({
    String? salaryVisible,
    String? salaryMin,
    String? salaryMax,
    String? salaryRange,
  }) {
    if (salaryVisible == "0") return "Not disclosed";

    final range = salaryRange?.toString().trim() ?? "";
    if (range.isNotEmpty && range != "null") return range;

    final min = salaryMin?.toString().trim() ?? "";
    final max = salaryMax?.toString().trim() ?? "";

    if (min.isEmpty && max.isEmpty) return "Not disclosed";
    if (min.isNotEmpty && max.isNotEmpty) return "Rs. $min - $max LPA";
    return "Rs. ${min.isNotEmpty ? min : max} LPA";
  }

  String _formatExperienceFromValues(String? minValue, String? maxValue) {
    final min = minValue?.toString().trim() ?? "";
    final max = maxValue?.toString().trim() ?? "";

    if (min.isEmpty && max.isEmpty) return "Not specified";
    if (min.isNotEmpty && max.isNotEmpty) return "$min-$max Years";
    return "${min.isNotEmpty ? min : max} Years";
  }

  String _formatDate(String date) {
    if (date.length >= 10) return date.substring(0, 10);
    return date;
  }

  String _formatSalary(GetJobByMemberIdData job) {
    if (job.salaryVisible == "0") return "Not disclosed";

    final min = job.salaryMin?.toString().trim() ?? "";
    final max = job.salaryMax?.toString().trim() ?? "";

    if (min.isEmpty && max.isEmpty) return "Not disclosed";
    if (min.isNotEmpty && max.isNotEmpty) return "₹$min - $max LPA";
    return "₹${min.isNotEmpty ? min : max} LPA";
  }

  String _formatExperience(GetJobByMemberIdData job) {
    final min = job.experienceMinYears?.toString().trim() ?? "";
    final max = job.experienceMaxYears?.toString().trim() ?? "";

    if (min.isEmpty && max.isEmpty) return "Not specified";
    if (min.isNotEmpty && max.isNotEmpty) return "$min-$max Years";
    return "${min.isNotEmpty ? min : max} Years";
  }

  String _formatPostedDate(GetJobByMemberIdData job) {
    final date = job.publishedAt ?? job.createdAt ?? "";
    if (date.length >= 10) return date.substring(0, 10);
    return date;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredJobs = jobs.where((job) {
      final matchesCategory =
          selectedCategory == "All" || job["category"] == selectedCategory;

      final matchesSearch = job["title"]
          .toLowerCase()
          .contains(searchController.text.toLowerCase());

      final matchesLocation =
          selectedLocation == "All" || job["location"] == selectedLocation;

      final jobSalary = _getSalaryValue(job["salary"]);

      final matchesSalary = jobSalary >= selectedSalaryRange.start &&
          jobSalary <= selectedSalaryRange.end;

      return matchesCategory &&
          matchesSearch &&
          matchesLocation &&
          matchesSalary;
    }).toList();
    List<Map<String, dynamic>> displayJobs;

    if (selectedTab == 1) {
      displayJobs = jobs.where((job) => job["isBookmarked"] == true).toList();
    } else if (selectedTab == 2) {
      displayJobs = appliedJobs;
    } else {
      displayJobs = filteredJobs;
    }
    final hasPreferredJobs = selectedTab == 0 &&
        displayJobs.any((job) => job["isPreferredJob"] == true);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text(
          "Job",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _handlePreferredDetailsPressed,
            child: const Text(
              "Preferrence",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Search jobs eg: developer, accountant...",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),

                // const SizedBox(width: 12),
                //
                // /// FILTER BUTTON
                // GestureDetector(
                //   onTap: _openFilterSheet,
                //   child: Container(
                //     padding: const EdgeInsets.all(12),
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(12),
                //       border: Border.all(color: Colors.grey[300]!),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.grey.withOpacity(0.1),
                //           blurRadius: 4,
                //           offset: const Offset(0, 2),
                //         ),
                //       ],
                //     ),
                //     child: Icon(
                //       Icons.filter_alt,
                //       color: ColorHelperClass.getColorFromHex(
                //           ColorResources.red_color),
                //       size: 24,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          Expanded(
            child: isLoadingJobs
                ? Center(
                    child: CircularProgressIndicator(
                      color: ColorHelperClass.getColorFromHex(
                        ColorResources.red_color,
                      ),
                    ),
                  )
                : displayJobs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount:
                            displayJobs.length + (hasPreferredJobs ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (hasPreferredJobs && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                              child: Text(
                                "Your Preferred Job",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ColorHelperClass.getColorFromHex(
                                    ColorResources.red_color,
                                  ),
                                ),
                              ),
                            );
                          }

                          final jobIndex = hasPreferredJobs ? index - 1 : index;
                          final job = displayJobs[jobIndex];
                          final isPreferredJob = job["isPreferredJob"] == true;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: isPreferredJob
                                  ? Border.all(
                                      color: Colors.green,
                                      width: 1.6,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: isPreferredJob
                                      ? Colors.greenAccent.withOpacity(0.28)
                                      : Colors.grey.shade200,
                                  blurRadius: isPreferredJob ? 18 : 8,
                                  spreadRadius: isPreferredJob ? 1.5 : 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// LEFT SIDE DETAILS
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        job["title"],
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        job["company"],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 13, color: Colors.grey),
                                          Text(
                                            job["location"],
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            job["salary"],
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Experience: ${job["experience"]}",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Posted: ${job["postedDate"]}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// RIGHT SIDE ACTIONS
                                Column(
                                  children: [
                                    /// SAVE BUTTON
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          job["isBookmarked"] =
                                              !(job["isBookmarked"] ?? false);
                                        });
                                      },
                                      child: Icon(
                                        (job["isBookmarked"] ?? false)
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        size: 24,
                                        color: (job["isBookmarked"] ?? false)
                                            ? Colors.orange
                                            : Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(height: 50),

                                    /// APPLY BUTTON
                                    selectedTab != 2
                                        ? SizedBox(
                                            height: 36,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (!appliedJobs
                                                    .contains(job)) {
                                                  setState(() {
                                                    appliedJobs.add(job);
                                                  });
                                                }

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        JobDetailView(job: job),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text(
                                                "Apply",
                                                style: TextStyle(fontSize: 13),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.green.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              "Applied",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
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
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        onTap: (index) {
          setState(() {
            selectedTab = index;
          });
        },
        selectedItemColor:
            ColorHelperClass.getColorFromHex(ColorResources.red_color),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Job",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: "Saved",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: "Applied",
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String title = "";
    String message = "";

    if (selectedTab == 1) {
      title = "No Saved Jobs";
      message = "Jobs you bookmark will appear here.";
    } else if (selectedTab == 2) {
      title = "No Applied Jobs";
      message = "Jobs you apply for will appear here.";
    } else {
      title = "No Jobs Found";
      message = "Try changing filters or search keywords.";
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cleanProfileValue(String value) {
    return value == "null" ? "" : value.trim();
  }

  void _prefillPreferredDetails() {
    selectedResume = null;
    selectedResumeName = null;
    fieldToWorkController.clear();
    expectedSalaryController.clear();
    internshipMonthController.clear();
    preferredAreaController.text = _cleanProfileValue(
      profileController.areaName.value,
    );
    selectedPreferredWorkMode = "On-site";
    selectedPreferredJobType = "Full-time";

    preferredNameController.text = _cleanProfileValue(
      profileController.userName.value,
    );
    preferredEmailController.text = _cleanProfileValue(
      profileController.email.value,
    );
    preferredMobileController.text = _cleanProfileValue(
      profileController.mobileNumber.value,
    );
    preferredWhatsappController.text = _cleanProfileValue(
      profileController.whatsAppNumber.value,
    );

    // Default Mumbai
    selectedPreferredCityId = "2";

    // If profile city exists and is 2,3,4 use it
    final cityId = _cleanProfileValue(profileController.city_id.value);

    if (cityId == "2" || cityId == "3" || cityId == "4") {
      selectedPreferredCityId = cityId;
    }
  }

  void _prefillExistingSeekerProfileDetails() {
    final data = seekerProfileData;
    if (data == null) return;

    fieldToWorkController.text = _cleanProfileValue(data.headline ?? "");
    final expectedSalaryMax = _cleanProfileValue(data.expectedSalaryMax ?? "");
    final expectedSalaryMin = _cleanProfileValue(data.expectedSalaryMin ?? "");
    expectedSalaryController.text =
        expectedSalaryMax.isNotEmpty ? expectedSalaryMax : expectedSalaryMin;

    final workMode = _cleanProfileValue(data.workMode ?? "").toLowerCase();
    if (workMode == "onsite" || workMode == "on-site") {
      selectedPreferredWorkMode = "On-site";
    } else if (workMode == "remote" || workMode == "work from home") {
      selectedPreferredWorkMode = "Work From Home";
    } else if (workMode == "hybrid") {
      selectedPreferredWorkMode = "Hybrid";
    }

    final workType = _cleanProfileValue(data.workType ?? "").toLowerCase();
    if (workType == "full_time" || workType == "full-time") {
      selectedPreferredJobType = "Full-time";
    } else if (workType == "part_time" || workType == "part-time") {
      selectedPreferredJobType = "Part-time";
    } else if (workType == "internship") {
      selectedPreferredJobType = "Internship";
    }

    internshipMonthController.text = _cleanProfileValue(
      data.noOfInternshipMonth ?? "",
    );

    final resumePath = _cleanProfileValue(data.resumePath ?? "");
    if (resumePath.isNotEmpty) {
      selectedResumeName = resumePath.split(RegExp(r'[\\/]')).last;
    }

    final cityId = _cleanProfileValue(data.cityId ?? "");
    if (cityId == "2" || cityId == "3" || cityId == "4") {
      selectedPreferredCityId = cityId;
    }

    preferredAreaController.text = _cleanProfileValue(data.areaName ?? "");
  }

  Future<void> _openPreferredCitySheet({
    bool prefillExistingProfile = false,
  }) async {
    _prefillPreferredDetails();
    if (prefillExistingProfile) {
      _prefillExistingSeekerProfileDetails();
    }
    final loggedInMemberId = await _getLoggedInMemberId();

    if (loggedInMemberId.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Member ID is missing. Please login again"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool isFormValid() {
      return preferredNameController.text.trim().isNotEmpty &&
          preferredEmailController.text.trim().isNotEmpty &&
          preferredMobileController.text.trim().isNotEmpty &&
          fieldToWorkController.text.trim().isNotEmpty &&
          expectedSalaryController.text.trim().isNotEmpty &&
          (selectedPreferredJobType != "Internship" ||
              internshipMonthController.text.trim().isNotEmpty) &&
          selectedPreferredCityId.isNotEmpty &&
          preferredAreaController.text.trim().isNotEmpty;
    }

    if (regiController.cityList.isEmpty) {
      await regiController.getCity();
    }

    if (!mounted) return;

    final existingSeekerProfileId =
        seekerProfileData?.seekerProfileId?.trim() ?? "";
    final shouldUpdateProfile =
        prefillExistingProfile && existingSeekerProfileId.isNotEmpty;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.85,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    children: [
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
                            onPressed: isFormValid()
                                ? () async {
                                    try {
                                      String resumePath =
                                          seekerProfileData?.resumePath ?? "";

                                      if (selectedResume != null) {
                                        final uploadResponse =
                                            await uploadResumeRepository
                                                .uploadResume(
                                          memberId: loggedInMemberId,
                                          filePath: selectedResume!.path,
                                        );

                                        if (uploadResponse.status != true) {
                                          ScaffoldMessenger.of(this.context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                uploadResponse.message
                                                        .isNotEmpty
                                                    ? uploadResponse.message
                                                    : "Unable to upload resume",
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        resumePath = uploadResponse
                                                .data?.resumePath ??
                                            resumePath;
                                      }

                                      final workMode =
                                          selectedPreferredWorkMode == "On-site"
                                              ? "onsite"
                                              : selectedPreferredWorkMode ==
                                                      "Work From Home"
                                                  ? "remote"
                                                  : "hybrid";
                                      final workType =
                                          selectedPreferredJobType ==
                                                  "Full-time"
                                              ? "full_time"
                                              : selectedPreferredJobType ==
                                                      "Part-time"
                                                  ? "part_time"
                                                  : "internship";
                                      final body = {
                                        "member_id": loggedInMemberId,
                                        "headline":
                                            fieldToWorkController.text.trim(),
                                        "summary": "",
                                        "expected_salary_max":
                                            expectedSalaryController.text
                                                .trim(),
                                        "expected_salary_min": "",
                                        "work_mode": workMode,
                                        "work_type": workType,
                                        "no_of_internship_month":
                                            selectedPreferredJobType ==
                                                    "Internship"
                                                ? internshipMonthController.text
                                                    .trim()
                                                : "",
                                        "city_id": selectedPreferredCityId,
                                        "area_name":
                                            preferredAreaController.text.trim(),
                                        "is_visible": "1",
                                      };

                                      if (shouldUpdateProfile) {
                                        final updateBody = {
                                          ...body,
                                          "seeker_profile_id":
                                              existingSeekerProfileId,
                                          "updated_by": loggedInMemberId,
                                        };

                                        final response =
                                            await updateSeekerProfileRepository
                                                .updateSeekerProfile(
                                                    updateBody);

                                        if (response.status == true) {
                                          hasSeekerProfile = true;
                                          seekerProfileData =
                                              GetSeekerProfileData(
                                            seekerProfileId: response
                                                    .data?.seekerProfileId ??
                                                existingSeekerProfileId,
                                            memberId: response.data?.memberId ??
                                                loggedInMemberId,
                                            resumePath: resumePath,
                                            headline: response.data?.headline ??
                                                fieldToWorkController.text
                                                    .trim(),
                                            summary:
                                                response.data?.summary ?? "",
                                            expectedSalaryMin: response
                                                    .data?.expectedSalaryMin ??
                                                "",
                                            expectedSalaryMax: response
                                                    .data?.expectedSalaryMax ??
                                                expectedSalaryController.text
                                                    .trim(),
                                            workMode: response.data?.workMode ??
                                                workMode,
                                            workType: response.data?.workType ??
                                                workType,
                                            noOfInternshipMonth: response.data
                                                    ?.noOFInternshipMonth ??
                                                (selectedPreferredJobType ==
                                                        "Internship"
                                                    ? internshipMonthController
                                                        .text
                                                        .trim()
                                                    : ""),
                                            cityId: response.data?.cityId ??
                                                selectedPreferredCityId,
                                            areaName: response.data?.areaName ??
                                                preferredAreaController.text
                                                    .trim(),
                                            isVisible:
                                                response.data?.isVisible ?? "1",
                                            updatedBy:
                                                response.data?.updatedBy ??
                                                    loggedInMemberId,
                                          );

                                          if (mounted) {
                                            Navigator.pop(context);

                                            ScaffoldMessenger.of(this.context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  response.message ??
                                                      "Preferred details updated successfully",
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(this.context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                response.message ??
                                                    "Unable to update details",
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      final createBody = {
                                        ...body,
                                        "created_by": loggedInMemberId,
                                        "resume_path": resumePath,
                                      };

                                      final response = await seekerRepository
                                          .addSeekerProfile(createBody);

                                      /// SUCCESS
                                      if (response.status == true) {
                                        hasSeekerProfile = true;
                                        seekerProfileData =
                                            GetSeekerProfileData(
                                          seekerProfileId: seekerProfileData
                                              ?.seekerProfileId,
                                          memberId:
                                              response.data?.memberId ??
                                                  loggedInMemberId,
                                          resumePath:
                                              response.data?.resumePath ??
                                                  resumePath,
                                          headline:
                                              response.data?.headline ??
                                                  fieldToWorkController.text
                                                      .trim(),
                                          summary:
                                              response.data?.summary ?? "",
                                          expectedSalaryMin: response.data
                                                  ?.expectedSalaryMin ??
                                              "",
                                          expectedSalaryMax: response.data
                                                  ?.expectedSalaryMax ??
                                              expectedSalaryController.text
                                                  .trim(),
                                          workMode:
                                              response.data?.workMode ??
                                                  workMode,
                                          workType:
                                              response.data?.workType ??
                                                  workType,
                                          noOfInternshipMonth: response.data
                                                  ?.noOfInternshipMonth ??
                                              (selectedPreferredJobType ==
                                                      "Internship"
                                                  ? internshipMonthController
                                                      .text
                                                      .trim()
                                                  : ""),
                                          cityId: response.data?.cityId ??
                                              selectedPreferredCityId,
                                          areaName:
                                              response.data?.areaName ??
                                                  preferredAreaController.text
                                                      .trim(),
                                          isVisible:
                                              response.data?.isVisible ??
                                                  "1",
                                          createdBy:
                                              response.data?.createdBy ??
                                                  loggedInMemberId,
                                        );
                                        if (mounted) {
                                          Navigator.pop(context);

                                          ScaffoldMessenger.of(this.context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                response.message ??
                                                    "Preferred details saved successfully",
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      }

                                      /// PROFILE ALREADY EXISTS
                                      else if (response.code == 409) {
                                        hasSeekerProfile = true;
                                        if (mounted) {
                                          Navigator.pop(context);

                                          ScaffoldMessenger.of(this.context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Preferred detail already exists for this member",
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      }

                                      /// OTHER FAILURE
                                      else {
                                        ScaffoldMessenger.of(this.context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              response.message ??
                                                  "Unable to save details",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      final errorText = e.toString();
                                      if (!shouldUpdateProfile &&
                                          errorText.contains('"code":409')) {
                                        hasSeekerProfile = true;
                                        if (mounted) {
                                          Navigator.pop(context);

                                          ScaffoldMessenger.of(this.context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Preferred detail already exists for this member",
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(this.context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(errorText),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                : null,
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
                            child:
                                Text(shouldUpdateProfile ? "Update" : "Submit"),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Preferrence",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              _buildPreferredDropdown(
                                label: "Job Type *",
                                items: preferredJobTypes,
                                selectedValue: selectedPreferredJobType,
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedPreferredJobType = value;
                                    if (selectedPreferredJobType !=
                                        "Internship") {
                                      internshipMonthController.clear();
                                    }
                                  });
                                },
                              ),
                              if (selectedPreferredJobType == "Internship")
                                _buildPreferredTextField(
                                  label: "No. of Internship Month *",
                                  controller: internshipMonthController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setModalState(() {}),
                                ),
                              _buildPreferredDropdown(
                                label: "Work Mode *",
                                items: preferredWorkModes,
                                selectedValue: selectedPreferredWorkMode,
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedPreferredWorkMode = value;
                                  });
                                },
                              ),
                              _buildPreferredTextField(
                                label: "Field to Work *",
                                controller: fieldToWorkController,
                                onChanged: (_) => setModalState(() {}),
                              ),
                              _buildPreferredTextField(
                                label: "Expected Salary *",
                                controller: expectedSalaryController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setModalState(() {}),
                              ),
                              _buildPreferredCityDropdown(
                                modalSetState: setModalState,
                              ),
                              if (selectedPreferredCityId.isNotEmpty)
                                _buildPreferredTextField(
                                  label: "Area Name *",
                                  controller: preferredAreaController,
                                  onChanged: (_) => setModalState(() {}),
                                ),
                              const SizedBox(height: 10),
                              _buildResumeUploadField(
                                modalSetState: setModalState,
                              ),
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

  Widget _buildPreferredTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
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

  Widget _buildPreferredDropdown({
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
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black38, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelStyle: const TextStyle(color: Colors.black),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(10),
            isExpanded: true,
            value: selectedValue,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPreferredCityDropdown({
    required StateSetter modalSetState,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Obx(() {
        final filteredCities = regiController.cityList.where((city) {
          return city.id == "2" || city.id == "3" || city.id == "4";
        }).toList();

        if (filteredCities.isEmpty) {
          return const Text("No city available");
        }

        final hasSelectedCity = filteredCities.any(
          (city) => city.id.toString() == selectedPreferredCityId,
        );

        return InputDecorator(
          decoration: InputDecoration(
            labelText: "Select Preferred City *",
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black38, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            labelStyle: const TextStyle(color: Colors.black),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: hasSelectedCity ? selectedPreferredCityId : null,
              items: filteredCities.map((CityData city) {
                return DropdownMenuItem<String>(
                  value: city.id.toString(),
                  child: Text(city.cityName ?? "Unknown"),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  modalSetState(() {
                    selectedPreferredCityId = value;
                    preferredAreaController.clear();
                  });
                }
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResumeUploadField({
    required StateSetter modalSetState,
  }) {
    final bool isUploaded =
        selectedResume != null || (selectedResumeName ?? "").trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isUploaded)
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedResumeName?.toLowerCase().endsWith(".pdf") == true
                          ? Icons.picture_as_pdf
                          : Icons.description,
                      color:
                          selectedResumeName?.toLowerCase().endsWith(".pdf") ==
                                  true
                              ? Colors.red
                              : Colors.blue,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedResumeName ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () {
                    modalSetState(() {
                      selectedResume = null;
                      selectedResumeName = null;
                    });
                  },
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
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
              _showResumePicker(
                context,
                modalSetState,
              );
            },
            icon: Icon(
              isUploaded ? Icons.check_circle : Icons.upload_file,
            ),
            label: Text(
              isUploaded ? "Resume Uploaded" : "Upload Resume",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded
                  ? Colors.green
                  : ColorHelperClass.getColorFromHex(ColorResources.red_color),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showResumePicker(
    BuildContext context,
    StateSetter modalSetState,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Upload Resume",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Divider(),

                /// PDF
                ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                  ),
                  title: const Text("Choose PDF"),
                  onTap: () async {
                    Navigator.pop(context);

                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );

                    if (result != null && result.files.single.path != null) {
                      modalSetState(() {
                        selectedResume = File(result.files.single.path!);

                        selectedResumeName = result.files.single.name;
                      });

                      // await uploadResume(selectedResume!);
                    }
                  },
                ),

                /// DOC / DOCX
                ListTile(
                  leading: const Icon(
                    Icons.description,
                    color: Colors.blue,
                  ),
                  title: const Text("Choose Word Document"),
                  onTap: () async {
                    Navigator.pop(context);

                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['doc', 'docx'],
                    );

                    if (result != null && result.files.single.path != null) {
                      modalSetState(() {
                        selectedResume = File(result.files.single.path!);

                        selectedResumeName = result.files.single.name;
                      });

                      // await uploadResume(selectedResume!);
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

  void _openFilterSheet() {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          String tempLocation = selectedLocation;
          RangeValues tempSalary = selectedSalaryRange;

          return StatefulBuilder(
            builder: (context, setModalState) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      /// HEADER (FIXED)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Filter Jobs",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),

                      const Divider(),

                      /// SCROLLABLE CONTENT
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// LOCATION
                              const Text(
                                "Location",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),

                              const SizedBox(height: 10),

                              Column(
                                children: ["All", "Mumbai", "Ahmedabad"]
                                    .map((location) {
                                  return RadioListTile(
                                    value: location,
                                    groupValue: tempLocation,
                                    title: Text(location),
                                    activeColor:
                                        ColorHelperClass.getColorFromHex(
                                            ColorResources.red_color),
                                    onChanged: (value) {
                                      setModalState(() {
                                        tempLocation = value.toString();
                                      });
                                    },
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 20),

                              /// SALARY RANGE
                              const Text(
                                "Salary Range (LPA)",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),

                              const SizedBox(height: 10),

                              RangeSlider(
                                values: tempSalary,
                                min: 0,
                                max: 50,
                                divisions: 50,
                                labels: RangeLabels(
                                  "${tempSalary.start.round()} LPA",
                                  "${tempSalary.end.round()} LPA",
                                ),
                                activeColor: ColorHelperClass.getColorFromHex(
                                    ColorResources.red_color),
                                onChanged: (values) {
                                  setModalState(() {
                                    tempSalary = values;
                                  });
                                },
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${tempSalary.start.round()} LPA"),
                                  Text("${tempSalary.end.round()} LPA"),
                                ],
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),

                      /// BUTTONS (ALSO FIXED)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  tempLocation = "All";
                                  tempSalary = const RangeValues(0, 50);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    ColorHelperClass.getColorFromHex(
                                        ColorResources.red_color),
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Clear"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedLocation = tempLocation;
                                  selectedSalaryRange = tempSalary;
                                });

                                Navigator.pop(context);
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
                              child: const Text("Apply"),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}
