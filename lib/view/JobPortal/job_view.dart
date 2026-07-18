import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/BusinessProfile/BusinessOccupationProfile/BusinessOccupationProfileData.dart';
import 'package:mpm/model/JobPortal/GetJobByMemberId/GetJobByMemberIdData.dart';
import 'package:mpm/model/JobPortal/JobsForSeekerJob/JobsForSeekerJobData.dart';
import 'package:mpm/repository/BusinessProfileRepo/business_occupation_profile_repository/business_occupation_profile_repo.dart';
import 'package:mpm/repository/JobPortal/GetJobAppliedMembersRepo/get_job_applied_members_repository.dart';
import 'package:mpm/repository/JobPortal/GetJobByMemberIdRepo/get_job_by_member_id_repository.dart';
import 'package:mpm/repository/JobPortal/GetOccupationByMemberIdRepo/get_occupation_by_member_id_repository.dart';
import 'package:mpm/repository/JobPortal/GetQualificationByMemberIdRepo/get_qualification_by_member_id_repository.dart';
import 'package:mpm/repository/JobPortal/GetSeekerProfileRepo/get_seeker_profile_repository.dart';
import 'package:mpm/repository/JobPortal/JobPortalRoleRepo/update_job_portal_role_repository.dart';
import 'package:mpm/repository/JobPortal/JobsForSeekerRepo/jobs_for_seeker_repository.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/JobPortal/job_seeker_view.dart';
import 'package:mpm/view/JobPortal/recruiter_job_view.dart';
import 'package:mpm/view/profile%20view/Education_page_info.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class JobView extends StatefulWidget {
  const JobView({super.key});

  @override
  State<JobView> createState() => _JobViewState();
}

class _JobViewState extends State<JobView> {
  final UpdateJobPortalRoleRepository repository =
      UpdateJobPortalRoleRepository();

  final GetOccupationByMemberIdRepository occupationRepository =
      GetOccupationByMemberIdRepository();

  final GetQualificationByMemberIdRepository qualificationRepository =
      GetQualificationByMemberIdRepository();
  final BusinessOccupationProfileRepository businessProfileRepository =
      BusinessOccupationProfileRepository();
  final GetJobByMemberIdRepository jobRepository = GetJobByMemberIdRepository();
  final JobsForSeekerRepository jobsForSeekerRepository =
      JobsForSeekerRepository();
  final GetSeekerProfileRepository seekerProfileRepository =
      GetSeekerProfileRepository();
  final GetJobAppliedMembersRepository jobAppliedMembersRepository =
      GetJobAppliedMembersRepository();

  final UdateProfileController profileController =
      Get.find<UdateProfileController>();

  bool isLoading = false;
  bool showEducationBanner = false;
  String selectedRole = "";
  UdateProfileController controller = Get.put(UdateProfileController());
  NewMemberController newMemberController = Get.put(NewMemberController());

  final Color selectedColor =
      ColorHelperClass.getColorFromHex(ColorResources.secondary_color);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.getUserProfile();
    controller.getQualification();
    controller.getRelation();
    controller.getOccupationData();
    newMemberController.getGender();
    newMemberController.getBloodGroup();
    newMemberController.getMaritalStatus();
    newMemberController.getCountry();
    newMemberController.getCity();
    newMemberController.getState();
    newMemberController.getDocumentType();
  }

  Future<void> updateRole(String role) async {
    try {
      String memberId = await _getLoggedInMemberId();

      final body = {
        "member_id": memberId,
        "job_portal_role": role,
      };

      final response = await repository.updateJobPortalRole(body);

      if (response.status == true) {
        debugPrint("✅ Role Updated: ${response.message}");
      } else {
        debugPrint("❌ Failed: ${response.message}");
      }
    } catch (e) {
      debugPrint("API Error: $e");
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

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Future<void> checkEducationAndProceed() async {
    try {
      setState(() {
        isLoading = true;
        showEducationBanner = false;
      });

      String memberId = await _getLoggedInMemberId();
      if (memberId.isEmpty) {
        _showSnackBar("Member ID is missing. Please login again", Colors.red);
        return;
      }

      final eduResponse =
          await qualificationRepository.getQualificationsByMemberId(memberId);

      bool hasEducation = (eduResponse.totalCount ?? 0) > 0;

      /// 🔹 Check institute name also
      bool hasInstitute = false;

      if (eduResponse.data != null && eduResponse.data!.isNotEmpty) {
        for (var edu in eduResponse.data!) {
          if (edu.instituteName != null &&
              edu.instituteName.toString().trim().isNotEmpty) {
            hasInstitute = true;
            break;
          }
        }
      }

      /// 🔹 If education OR institute missing → show banner
      if (!hasEducation || !hasInstitute) {
        setState(() {
          showEducationBanner = true;
        });
        return;
      }

      await updateRole("job_seeker");

      final seekerProfileResponse =
          await seekerProfileRepository.getSeekerProfile(memberId);
      final seekerProfileData = seekerProfileResponse.data;
      final hasSeekerProfile = seekerProfileResponse.status == true &&
          seekerProfileData != null &&
          ((seekerProfileData.seekerProfileId ?? "").trim().isNotEmpty ||
              (seekerProfileData.memberId ?? "").trim().isNotEmpty);

      final businessResponse =
          await businessProfileRepository.fetchBusinessOccupationProfiles(
        memberId: memberId,
      );
      final businessProfiles =
          businessResponse.data ?? <BusinessOccupationProfileData>[];

      final jobsForSeekerResponse =
          await jobsForSeekerRepository.getJobsForSeeker(memberId);
      final jobsForSeeker =
          jobsForSeekerResponse.data?.jobs ?? <JobsForSeekerJobData>[];

      final getJobsMemberId =
          (hasSeekerProfile && (seekerProfileData.memberId ?? "").isNotEmpty)
              ? seekerProfileData.memberId!.trim()
              : memberId;
      final getJobsResponse = await jobRepository.getJobs(
        getJobsMemberId,
        status: "published",
      );
      final getJobs = getJobsResponse.data ?? <GetJobByMemberIdData>[];

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JobSeekerView(
            initialJobsForSeeker: jobsForSeeker,
            initialGetJobs: getJobs,
            initialBusinessProfiles: businessProfiles,
            initialSeekerProfileData:
                hasSeekerProfile ? seekerProfileData : null,
            initialHasSeekerProfile: hasSeekerProfile,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Education Check Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> checkOccupationAndProceed() async {
    try {
      setState(() {
        isLoading = true;
        showEducationBanner = false;
      });

      String memberId = await _getLoggedInMemberId();
      if (memberId.isEmpty) {
        _showSnackBar("Member ID is missing. Please login again", Colors.red);
        return;
      }

      final occResponse =
          await occupationRepository.getOccupationsByMemberId(memberId);

      bool hasOccupation = (occResponse.totalCount ?? 0) > 0;

      /// 🔹 Check company name also
      bool hasCompanyName = false;

      if (occResponse.data != null && occResponse.data!.isNotEmpty) {
        for (var occ in occResponse.data!) {
          if (occ.companyName != null &&
              occ.companyName.toString().trim().isNotEmpty) {
            hasCompanyName = true;
            break;
          }
        }
      }

      await updateRole("recruiter");

      final businessResponse =
          await businessProfileRepository.fetchBusinessOccupationProfiles(
        memberId: memberId,
      );
      final businessProfiles =
          businessResponse.data ?? <BusinessOccupationProfileData>[];

      final jobsResponse = await jobRepository.getJobs(memberId);
      final postedJobs = jobsResponse.data ?? <GetJobByMemberIdData>[];
      final applicantCountsByJobId =
          await _loadApplicantCountsForJobs(postedJobs);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecruiterJobView(
            showOccupationBanner: !hasOccupation || !hasCompanyName,
            initialBusinessProfiles: businessProfiles,
            initialPostedJobs: postedJobs,
            initialApplicantCountsByJobId: applicantCountsByJobId,
            skipInitialOccupationBannerRefresh: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Occupation Check Error: $e");
      _showSnackBar("Unable to load job portal. Please try again.", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<Map<String, int>> _loadApplicantCountsForJobs(
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

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          "Jobs",
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    if (showEducationBanner)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EducationPageInfo(
                                    autoOpenAddSheet: true),
                              ),
                            );

                            checkEducationAndProceed();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade700,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.white),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Click here to update your Education details",
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
                      ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.work_outline,
                                  size: 35,
                                  color: Colors.redAccent,
                                ),
                              ),

                              const SizedBox(height: 30),

                              const Text(
                                "Choose Your Role",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 30),

                              /// RECRUITER CARD
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    selectedRole = "recruiter";
                                  });

                                  await checkOccupationAndProceed();
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: selectedRole == "recruiter"
                                        ? Colors.redAccent.withOpacity(0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.redAccent,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.business_center,
                                        size: 32,
                                        color: selectedRole == "recruiter"
                                            ? selectedColor
                                            : Colors.redAccent,
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Offer Jobs (Employer)",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    selectedRole == "recruiter"
                                                        ? Colors.black
                                                        : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              "Hire talented candidates From Samaj Member",
                                              style: TextStyle(
                                                color:
                                                    selectedRole == "recruiter"
                                                        ? Colors.black38
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              /// JOB SEEKER CARD
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    selectedRole = "job_seeker";
                                  });

                                  await checkEducationAndProceed();
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: selectedRole == "job_seeker"
                                        ? Colors.redAccent.withOpacity(0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.redAccent,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search,
                                        size: 32,
                                        color: selectedRole == "job_seeker"
                                            ? selectedColor
                                            : Colors.redAccent,
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Looking for Job",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    selectedRole == "job_seeker"
                                                        ? Colors.black
                                                        : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              "Find opportunities and apply for jobs",
                                              style: TextStyle(
                                                color:
                                                    selectedRole == "job_seeker"
                                                        ? Colors.black38
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
