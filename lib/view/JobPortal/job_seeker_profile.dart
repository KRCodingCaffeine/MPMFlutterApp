import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/JobPortal/GetJobByMemberId/GetJobByMemberIdData.dart';
import 'package:mpm/model/JobPortal/GetListSeekerProfile/GetListSeekerProfilesData.dart';
import 'package:mpm/model/JobPortal/GetListSeekerProfile/SeekerMemberData.dart';
import 'package:mpm/model/JobPortal/GetPostedJobsAppliedMembers/AppliedMemberData.dart';
import 'package:mpm/model/JobPortal/GetPostedJobsAppliedMembers/GetPostedJobsAppliedMembersData.dart';
import 'package:mpm/model/JobPortal/MemberApplyJob/MemberApplyJobData.dart';
import 'package:mpm/model/JobPortal/UpdateMemberApplicationStatus/UpdateMemberApplicationStatusData.dart';
import 'package:mpm/repository/JobPortal/GetJobByMemberIdRepo/get_job_by_member_id_repository.dart';
import 'package:mpm/repository/JobPortal/GetListSeekerProfilesRepository/get_list_seeker_profiles_repo.dart';
import 'package:mpm/repository/JobPortal/GetPostedJobsAppliedMembersRepository/get_posted_jobs_applied_members_repo.dart';
import 'package:mpm/repository/JobPortal/MemberApplyJobRepo/member_apply_job_repository.dart';
import 'package:mpm/repository/JobPortal/UpdateMemberApplicationStatusRepo/update_member_application_status_repository.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:url_launcher/url_launcher.dart';

class _SeekerApplication {
  final GetPostedJobsAppliedMembersData job;
  final AppliedMemberData member;

  const _SeekerApplication({
    required this.job,
    required this.member,
  });
}

class JobSeekerProfile extends StatefulWidget {
  const JobSeekerProfile({super.key});

  @override
  State<JobSeekerProfile> createState() => _JobSeekerProfileState();
}

class _JobSeekerProfileState extends State<JobSeekerProfile> {
  final GetSeekerProfilesRepository _repository = GetSeekerProfilesRepository();
  final GetJobByMemberIdRepository _jobRepo = GetJobByMemberIdRepository();
  final MemberApplyJobRepository _memberApplyJobRepo =
      MemberApplyJobRepository();
  final GetPostedJobsAppliedMembersRepository _appliedMembersRepo =
      GetPostedJobsAppliedMembersRepository();
  final UpdateMemberApplicationStatusRepository _statusRepo =
      UpdateMemberApplicationStatusRepository();
  final UdateProfileController profileController =
      Get.find<UdateProfileController>();

  List<GetListSeekerProfilesData> seekerProfiles = [];
  bool isLoading = true;
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  final Set<String> shortlistedSeekerIds = {};
  final Set<String> contactedSeekerIds = {};
  final Set<String> recruitedSeekerIds = {};

  // Tracks which job each shortlisted seeker was shortlisted for
  // key = seeker key, value = job title
  final Map<String, String> _shortlistJobTitles = {};
  final Map<String, String> _shortlistJobIds = {};
  final Set<String> _recruitingSeekerIds = {};

  // Recruiter's posted jobs (loaded on demand for the picker)
  List<GetJobByMemberIdData> _postedJobs = [];
  bool _isLoadingJobs = false;

  /// Posted jobs with the members who applied, for the logged-in recruiter.
  List<GetPostedJobsAppliedMembersData> _jobsWithApplicants = [];

  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadSeekerProfiles();
    _loadAppliedMemberStatuses();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSeekerProfiles() async {
    try {
      setState(() => isLoading = true);

      final response = await _repository.getSeekerProfiles();

      if (!mounted) return;

      if (response.status == true) {
        setState(() {
          seekerProfiles = response.data ?? [];
        });
      } else {
        setState(() => seekerProfiles = []);
        _showSnack(
          response.message ?? "Failed to load seeker profiles",
          Colors.red,
        );
      }
    } catch (e) {
      debugPrint("Load Seeker Profiles Error: $e");
      if (!mounted) return;
      setState(() => seekerProfiles = []);
      _showSnack("Unable to load seeker profiles", Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _seekerKey(GetListSeekerProfilesData s) {
    return (s.seekerProfileId ?? "").trim().isNotEmpty
        ? s.seekerProfileId!.trim()
        : (s.memberId ?? "").trim();
  }

  String _seekerMemberId(GetListSeekerProfilesData s) {
    final memberId = (s.memberId ?? "").trim();
    if (memberId.isNotEmpty) return memberId;
    return (s.member?.memberId ?? "").trim();
  }

  Future<void> _loadAppliedMemberStatuses() async {
    try {
      final memberId = profileController.memberId.value.trim();
      if (memberId.isEmpty) {
        debugPrint("Applied members: logged in member id empty");
        return;
      }

      final response =
          await _appliedMembersRepo.getPostedJobsAppliedMembers(memberId);

      if (!mounted) return;

      if (response.status == true) {
        setState(() {
          _jobsWithApplicants = response.data ?? [];
        });
      } else {
        debugPrint(
          "Applied members: ${response.message ?? "failed to load"}",
        );
      }
    } catch (e) {
      debugPrint("Load applied member statuses error: $e");
    }
  }

  List<_SeekerApplication> _applicationsFor(GetListSeekerProfilesData seeker) {
    final memberId = _seekerMemberId(seeker);
    if (memberId.isEmpty) return const [];

    final matches = <_SeekerApplication>[];
    for (final job in _jobsWithApplicants) {
      for (final applied in job.appliedMembers ?? const <AppliedMemberData>[]) {
        if ((applied.memberId ?? "").trim() == memberId) {
          matches.add(_SeekerApplication(job: job, member: applied));
        }
      }
    }

    matches.sort((a, b) {
      final byRank = _statusRank(b.member.applicationStatus)
          .compareTo(_statusRank(a.member.applicationStatus));
      if (byRank != 0) return byRank;
      return (b.member.appliedDate ?? "").compareTo(a.member.appliedDate ?? "");
    });
    return matches;
  }

  int _statusRank(String? status) {
    switch ((status ?? "").trim().toLowerCase()) {
      case "recruited":
      case "recurted":
      case "selected":
        return 5;
      case "shortlisted":
        return 4;
      case "interview":
      case "interview_scheduled":
        return 3;
      case "applied":
        return 2;
      case "rejected":
      case "withdrawn":
        return 0;
      default:
        return 1;
    }
  }

  bool _isRecruitedStatus(String? status) {
    switch ((status ?? "").trim().toLowerCase()) {
      case "recruited":
      case "recurted":
      case "selected":
        return true;
      default:
        return false;
    }
  }

  bool _isShortlistedStatus(String? status) {
    return (status ?? "").trim().toLowerCase() == "shortlisted";
  }

  String _applicationStatusText(AppliedMemberData member) {
    if (_isRecruitedStatus(member.applicationStatus)) return "Recruited";

    final label = (member.statusLabel ?? "").trim();
    if (label.isNotEmpty) return label;

    final status = (member.applicationStatus ?? "").trim();
    if (status.isEmpty) return "Applied";

    return status
        .split("_")
        .where((part) => part.trim().isNotEmpty)
        .map((part) {
      final value = part.trim();
      return value[0].toUpperCase() + value.substring(1).toLowerCase();
    }).join(" ");
  }

  Color _applicationStatusColor(String? status) {
    switch ((status ?? "").trim().toLowerCase()) {
      case "shortlisted":
        return Colors.orange;
      case "rejected":
      case "withdrawn":
        return Colors.red;
      case "recruited":
      case "recurted":
      case "selected":
        return Colors.green;
      case "interview":
      case "interview_scheduled":
        return Colors.blue;
      case "applied":
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _applicationStatusIcon(String? status) {
    switch ((status ?? "").trim().toLowerCase()) {
      case "shortlisted":
        return Icons.bookmark;
      case "rejected":
      case "withdrawn":
        return Icons.cancel_outlined;
      case "recruited":
      case "recurted":
      case "selected":
        return Icons.check_circle;
      case "interview":
      case "interview_scheduled":
        return Icons.event_available;
      case "applied":
        return Icons.send;
      default:
        return Icons.info_outline;
    }
  }

  bool _isShortlisted(GetListSeekerProfilesData s) {
    final key = _seekerKey(s);
    if (key.isNotEmpty && shortlistedSeekerIds.contains(key)) return true;
    return _applicationsFor(s)
        .any((app) => _isShortlistedStatus(app.member.applicationStatus));
  }

  bool _isContacted(GetListSeekerProfilesData s) {
    final key = _seekerKey(s);
    return key.isNotEmpty && contactedSeekerIds.contains(key);
  }

  bool _isRecruited(GetListSeekerProfilesData s) {
    final key = _seekerKey(s);
    if (key.isNotEmpty && recruitedSeekerIds.contains(key)) return true;
    return _applicationsFor(s)
        .any((app) => _isRecruitedStatus(app.member.applicationStatus));
  }

  void _toggleShortlisted(GetListSeekerProfilesData s) {
    final key = _seekerKey(s);
    if (key.isEmpty) return;

    setState(() {
      if (shortlistedSeekerIds.contains(key)) {
        shortlistedSeekerIds.remove(key);
        _shortlistJobTitles.remove(key);
        _showSnack("Removed from Shortlisted", Colors.orange);
      } else {
        shortlistedSeekerIds.add(key);
        _showSnack("Added to Shortlisted", Colors.green);
      }
    });
  }

  String _jobIdForStatusUpdate(GetListSeekerProfilesData seeker) {
    final applications = _applicationsFor(seeker);

    for (final app in applications) {
      if (!_isShortlistedStatus(app.member.applicationStatus)) continue;
      final jobId = (app.job.jobId ?? "").trim();
      if (jobId.isNotEmpty) return jobId;
    }

    final storedJobId = (_shortlistJobIds[_seekerKey(seeker)] ?? "").trim();
    if (storedJobId.isNotEmpty) return storedJobId;

    for (final app in applications) {
      final jobId = (app.job.jobId ?? "").trim();
      if (jobId.isNotEmpty) return jobId;
    }
    return "";
  }

  void _setLocalApplicationStatus({
    required String memberId,
    required String jobId,
    required String applicationStatus,
    required String statusLabel,
  }) {
    for (final job in _jobsWithApplicants) {
      if ((job.jobId ?? "").trim() != jobId) continue;
      for (final member in job.appliedMembers ?? const <AppliedMemberData>[]) {
        if ((member.memberId ?? "").trim() != memberId) continue;
        member.applicationStatus = applicationStatus;
        member.statusLabel = statusLabel;
      }
    }
  }

  /// Saves the application as selected. The badge still reads Recruited.
  Future<bool> _markRecruited(GetListSeekerProfilesData s) async {
    final key = _seekerKey(s);
    if (key.isEmpty) return false;
    if (_isRecruited(s) || _recruitingSeekerIds.contains(key)) return false;

    final memberId = _seekerMemberId(s);
    final jobId = _jobIdForStatusUpdate(s);
    if (memberId.isEmpty || jobId.isEmpty) {
      _showSnack("Member id or job id not found", Colors.red);
      return false;
    }

    setState(() => _recruitingSeekerIds.add(key));

    try {
      final body = UpdateMemberApplicationStatusData(
        memberId: memberId,
        jobId: jobId,
        applicationStatus: "selected",
      ).toJson();

      final response = await _statusRepo.updateMemberApplicationStatus(body);
      if (!mounted) return false;

      if (response.status == true) {
        setState(() {
          shortlistedSeekerIds.remove(key);
          recruitedSeekerIds.add(key);
          _setLocalApplicationStatus(
            memberId: memberId,
            jobId: jobId,
            applicationStatus: "selected",
            statusLabel: "Recruited",
          );
          selectedTab = 2;
        });
        _showSnack(response.message ?? "Moved to Recruited", Colors.green);
        await _loadAppliedMemberStatuses();
        return true;
      }

      _showSnack(response.message ?? "Failed to update status", Colors.red);
      return false;
    } catch (e) {
      debugPrint("Recruit status error: $e");
      if (!mounted) return false;
      _showSnack("Failed to update status", Colors.red);
      return false;
    } finally {
      if (mounted) {
        setState(() => _recruitingSeekerIds.remove(key));
      }
    }
  }

  void _markContacted(GetListSeekerProfilesData s) {
    final key = _seekerKey(s);
    if (key.isEmpty) return;
    if (contactedSeekerIds.contains(key)) return;

    setState(() {
      contactedSeekerIds.add(key);
    });
  }

  String _getFullName(SeekerMemberData? member) {
    if (member == null) return "Member";
    final name = [
      member.firstName,
      member.middleName,
      member.lastName,
    ].where((n) => (n ?? "").trim().isNotEmpty).map((n) => n!.trim()).join(" ");
    return name.isNotEmpty ? name : "Member";
  }

  String _getProfileImageUrl(String? imagePath) {
    final image = imagePath?.toString().trim() ?? "";
    if (image.isEmpty) return "";
    if (image.startsWith("http://") || image.startsWith("https://")) {
      return image;
    }
    return Urls.imagePathUrl + image;
  }

  String _formatWorkType(String? value) {
    switch ((value ?? "").toLowerCase()) {
      case "full_time":
        return "Full-time";
      case "part_time":
        return "Part-time";
      case "internship":
        return "Internship";
      default:
        return value?.trim().isNotEmpty == true ? value! : "-";
    }
  }

  String _formatWorkMode(String? value) {
    switch ((value ?? "").toLowerCase()) {
      case "onsite":
        return "On-site";
      case "remote":
        return "Work From Home";
      case "hybrid":
        return "Hybrid";
      default:
        return value?.trim().isNotEmpty == true ? value! : "-";
    }
  }

  String _formatSalary(String? min, String? max) {
    final minS = (min ?? "").trim();
    final maxS = (max ?? "").trim();

    if (minS.isEmpty && maxS.isEmpty) return "Not disclosed";
    if (minS.isNotEmpty && maxS.isNotEmpty) return "₹$minS - $maxS LPA";
    return "₹${minS.isNotEmpty ? minS : maxS} LPA";
  }

  /// ✅ Format timestamp as "YYYY-MM-DD HH:mm:ss" for the API
  String _nowForApi() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return "${n.year}-${two(n.month)}-${two(n.day)} "
        "${two(n.hour)}:${two(n.minute)}:${two(n.second)}";
  }

  // ---------- Filtered lists ----------

  bool _matchesSearch(GetListSeekerProfilesData s, String query) {
    final name = _getFullName(s.member).toLowerCase();
    final headline = (s.headline ?? "").toLowerCase();
    final city = (s.cityName ?? "").toLowerCase();
    final email = (s.member?.email ?? "").toLowerCase();

    return name.contains(query) ||
        headline.contains(query) ||
        city.contains(query) ||
        email.contains(query);
  }

  List<GetListSeekerProfilesData> get _filteredSeekers {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return seekerProfiles;
    return seekerProfiles.where((s) => _matchesSearch(s, query)).toList();
  }

  List<GetListSeekerProfilesData> get _shortlistedSeekers {
    final query = searchQuery.trim().toLowerCase();
    final list = seekerProfiles.where(_isShortlisted).toList();
    if (query.isEmpty) return list;
    return list.where((s) => _matchesSearch(s, query)).toList();
  }

  List<GetListSeekerProfilesData> get _recruitedSeekers {
    final query = searchQuery.trim().toLowerCase();
    final list = seekerProfiles.where(_isRecruited).toList();
    if (query.isEmpty) return list;
    return list.where((s) => _matchesSearch(s, query)).toList();
  }

  // ---------- Posted jobs for shortlist picker ----------

  Future<void> _loadPostedJobsForShortlist() async {
    try {
      setState(() => _isLoadingJobs = true);

      final memberId = profileController.memberId.value.trim();
      if (memberId.isEmpty) {
        debugPrint("Posted Jobs: member id empty");
        return;
      }

      final response = await _jobRepo.getJobs(memberId);
      if (!mounted) return;

      if (response.status == true && response.data != null) {
        setState(() {
          _postedJobs = response.data!.where((j) {
            final s = (j.status ?? "").toLowerCase();
            return s == "published" || s == "draft";
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Load Posted Jobs Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingJobs = false);
    }
  }

  /// Open the shortlist job picker bottom sheet
  Future<void> _showShortlistJobPicker(GetListSeekerProfilesData seeker) async {
    final member = seeker.member;
    final fullName = _getFullName(member);

    if (_postedJobs.isEmpty && !_isLoadingJobs) {
      await _loadPostedJobsForShortlist();
    }

    if (!mounted) return;

    if (_postedJobs.isEmpty) {
      _showSnack("You haven't posted any job yet.", Colors.orange);
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.7,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  // Grab handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Shortlist for Which Job?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Select a job to shortlist $fullName",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Job list
                  Expanded(
                    child: _isLoadingJobs
                        ? Center(
                            child: CircularProgressIndicator(
                              color: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            itemCount: _postedJobs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final job = _postedJobs[index];
                              final isPublished =
                                  (job.status ?? "").toLowerCase() ==
                                      "published";

                              return InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  _confirmShortlistForJob(seeker, job);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isPublished
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.orange.withOpacity(0.3),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 42,
                                        width: 42,
                                        decoration: BoxDecoration(
                                          color: (isPublished
                                                  ? Colors.green
                                                  : Colors.orange)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          isPublished
                                              ? Icons.work
                                              : Icons.edit_note,
                                          color: isPublished
                                              ? Colors.green
                                              : Colors.orange,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              job.title ?? "-",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 13,
                                                  color: Colors.grey.shade600,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    job.location ?? "-",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: (isPublished
                                                        ? Colors.green
                                                        : Colors.orange)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                isPublished
                                                    ? "Published"
                                                    : "Draft",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: isPublished
                                                      ? Colors.green
                                                      : Colors.orange,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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

  /// ✅ Confirm the shortlist for the chosen job — calls the API.
  Future<void> _confirmShortlistForJob(
    GetListSeekerProfilesData seeker,
    GetJobByMemberIdData job,
  ) async {
    final key = _seekerKey(seeker);
    if (key.isEmpty) return;

    final memberId = (seeker.memberId ?? "").trim();
    final jobId = (job.jobId ?? "").trim();

    if (memberId.isEmpty || jobId.isEmpty) {
      _showSnack("Member id or job id missing", Colors.red);
      return;
    }

    // Optimistically update local state first
    setState(() {
      shortlistedSeekerIds.add(key);
      _shortlistJobTitles[key] = job.title ?? "";
      _shortlistJobIds[key] = jobId;
    });

    setState(() => _isLoadingJobs = true);

    try {
      final loggedInMemberId = profileController.memberId.value.trim();
      final now = _nowForApi();

      final body = MemberApplyJobData(
        memberId: memberId,
        jobId: jobId,
        applicationStatus: "shortlisted",
        appliedDate: now,
        appliedBy: "1",
        remarks: "",
        createdBy: loggedInMemberId,
        createdAt: now,
      ).toJson();

      final response = await _memberApplyJobRepo.memberApplyJob(body);

      if (!mounted) return;

      if (response.status == true || response.code == 409) {
        // 409 = already shortlisted/applied for this job — treat as success
        setState(() {
          shortlistedSeekerIds.add(key);
          _shortlistJobTitles[key] = job.title ?? "";
          _shortlistJobIds[key] = jobId;
        });

        _showSnack(
          response.message ?? "Shortlisted for \"${job.title ?? "job"}\"",
          response.code == 409 ? Colors.orange : Colors.green,
        );
        await _loadAppliedMemberStatuses();
      } else {
        // Revert on failure
        setState(() {
          shortlistedSeekerIds.remove(key);
          _shortlistJobTitles.remove(key);
          _shortlistJobIds.remove(key);
        });

        _showSnack(
          response.message ?? "Failed to shortlist",
          Colors.red,
        );
      }
    } catch (e) {
      debugPrint("Shortlist error: $e");

      if (!mounted) return;

      setState(() {
        shortlistedSeekerIds.remove(key);
        _shortlistJobTitles.remove(key);
        _shortlistJobIds.remove(key);
      });

      if (e.toString().contains('"code":409')) {
        setState(() {
          shortlistedSeekerIds.add(key);
          _shortlistJobTitles[key] = job.title ?? "";
          _shortlistJobIds[key] = jobId;
        });
        _showSnack("Already shortlisted for this job", Colors.orange);
      } else {
        _showSnack("Failed to shortlist: $e", Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoadingJobs = false);
    }
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    List<GetListSeekerProfilesData> currentList;
    if (selectedTab == 0) {
      currentList = _filteredSeekers;
    } else if (selectedTab == 1) {
      currentList = _shortlistedSeekers;
    } else {
      currentList = _recruitedSeekers;
    }

    final titles = ["Canditates Looking For Jobs", "Shortlisted", "Recruited"];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          titles[selectedTab],
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (val) {
                  setState(() => searchQuery = val);
                },
                decoration: InputDecoration(
                  hintText: "Search...",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            searchController.clear();
                            setState(() => searchQuery = "");
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: ColorHelperClass.getColorFromHex(
                        ColorResources.red_color,
                      ),
                    ),
                  )
                : currentList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await Future.wait([
                            _loadSeekerProfiles(),
                            _loadAppliedMemberStatuses(),
                          ]);
                        },
                        color: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color,
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          itemCount: currentList.length,
                          itemBuilder: (context, index) {
                            return _buildSeekerCard(currentList[index], index);
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        onTap: (index) {
          setState(() => selectedTab = index);
        },
        selectedItemColor:
            ColorHelperClass.getColorFromHex(ColorResources.red_color),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: "Canditate",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: "Shortlisted",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mark_email_read),
            label: "Recruited",
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = searchQuery.trim().isNotEmpty;
    final isShortlistedTab = selectedTab == 1;
    final isRecruitedTab = selectedTab == 2;

    String title;
    String message;

    if (isSearching) {
      title = "No matching canditate";
      message = "Try a different search term.";
    } else if (isShortlistedTab) {
      title = "No shortlisted canditate";
      message = "Canditate you shortlist will appear here.";
    } else if (isRecruitedTab) {
      title = "No recruited canditate";
      message = "Canditate you mark as recruited will appear here.";
    } else {
      title = "No canditate found";
      message =
          "Canditate you search for profiles will appear here once available.";
    }

    IconData icon;
    if (isSearching) {
      icon = Icons.search_off;
    } else if (isShortlistedTab) {
      icon = Icons.bookmark_border;
    } else if (isRecruitedTab) {
      icon = Icons.mark_email_read;
    } else {
      icon = Icons.people_outline;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeekerCard(GetListSeekerProfilesData seeker, int index) {
    final member = seeker.member;
    final fullName = _getFullName(member);
    final profileImageUrl = _getProfileImageUrl(member?.profileImage);
    final contactValue = (member?.mobile ?? "").trim();
    final isShortlisted = _isShortlisted(seeker);
    final isContacted = _isContacted(seeker);
    final isRecruited = _isRecruited(seeker);

    final key = _seekerKey(seeker);
    final shortlistJobTitle = _shortlistJobTitles[key] ?? "";
    final applications = _applicationsFor(seeker);
    final primary = applications.isNotEmpty ? applications.first : null;
    final primaryStatus = primary?.member.applicationStatus;
    final primaryColor =
        primary == null ? null : _applicationStatusColor(primaryStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isRecruited
            ? Border.all(color: Colors.green.withOpacity(0.6), width: 1.6)
            : isContacted
                ? Border.all(color: Colors.green.withOpacity(0.4), width: 1.4)
                : isShortlisted
                    ? Border.all(
                        color: Colors.orange.withOpacity(0.6),
                        width: 1.6,
                      )
                    : primaryColor == null
                        ? null
                        : Border.all(
                            color: primaryColor.withOpacity(0.45),
                            width: 1.4,
                          ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index badge + status badges
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              const Spacer(),
              if (isRecruited)
                _statusBadge(
                  label: "RECRUITED",
                  color: Colors.green,
                  icon: Icons.check_circle,
                )
              else if (primary != null)
                _statusBadge(
                  label: _applicationStatusText(primary.member).toUpperCase(),
                  color: primaryColor ?? Colors.grey,
                  icon: _applicationStatusIcon(primaryStatus),
                )
              else if (isContacted)
                _statusBadge(
                  label: "CONTACTED",
                  color: Colors.teal,
                  icon: Icons.mark_email_read,
                )
              else if (isShortlisted)
                _statusBadge(
                  label: "SHORTLISTED",
                  color: Colors.orange,
                  icon: Icons.bookmark,
                ),
            ],
          ),

          if (applications.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...applications.map((app) => _applicationJobChip(app)),
          ] else if (isShortlisted && shortlistJobTitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.work_outline,
                      size: 12, color: Colors.orange),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      "Shortlisted for: $shortlistJobTitle",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Avatar + Name + contact
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          imageErrorBuilder: (c, e, s) => Image.asset(
                            "assets/images/male.png",
                            fit: BoxFit.cover,
                            width: 64,
                            height: 64,
                          ),
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
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if ((seeker.headline ?? "").trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        seeker.headline!.trim(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    if ((member?.email ?? "").trim().isNotEmpty)
                      Text(
                        member!.email!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    if (contactValue.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        contactValue,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Actions
          Row(
            children: [
              if (isRecruited) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "Recruited",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (isContacted) ...[
                Expanded(
                  child: _recruitingSeekerIds.contains(key)
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: () => _markRecruited(seeker),
                          icon: const Icon(
                            Icons.person_add_alt_1,
                            color: Colors.green,
                            size: 20,
                          ),
                          label: const Text(
                            "Mark Recruited",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ] else if (isShortlisted) ...[
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _makeCall(seeker),
                    icon: const Icon(
                      Icons.call,
                      color: Colors.green,
                      size: 20,
                    ),
                    label: const Text(
                      "Call",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showSendMessageOptions(seeker),
                    icon: const Icon(
                      Icons.send,
                      color: Colors.blue,
                      size: 20,
                    ),
                    label: const Text(
                      "Send Message",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showSeekerProfileDetails(seeker),
                    icon: const Icon(
                      Icons.visibility_outlined,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    label: const Text(
                      "View Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showShortlistJobPicker(seeker),
                    icon: const Icon(
                      Icons.bookmark_border,
                      color: Colors.orange,
                      size: 20,
                    ),
                    label: const Text(
                      "Shortlist",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _applicationJobChip(_SeekerApplication app) {
    final status = app.member.applicationStatus;
    final color = _applicationStatusColor(status);
    final title = (app.job.title ?? "").trim();
    final company = (app.job.companyName ?? "").trim();
    final jobLabel = [
      if (title.isNotEmpty) title,
      if (company.isNotEmpty) company,
    ].join(" · ");
    final text = jobLabel.isEmpty
        ? _applicationStatusText(app.member)
        : "${_applicationStatusText(app.member)} for: $jobLabel";

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.work_outline, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makeCall(GetListSeekerProfilesData seeker) async {
    final member = seeker.member;
    final rawMobile = (member?.mobile ?? "").trim().isNotEmpty
        ? member!.mobile!.trim()
        : (member?.whatsappNumber ?? "").trim();

    if (rawMobile.isEmpty) {
      _showSnack("Phone number not available", Colors.orange);
      return;
    }

    _markContacted(seeker);

    final uri = Uri(scheme: 'tel', path: rawMobile);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnack("Unable to open dialer", Colors.red);
      }
    } catch (e) {
      debugPrint("Call error: $e");
      _showSnack("Unable to open dialer", Colors.red);
    }
  }

  void _showSendMessageOptions(GetListSeekerProfilesData seeker) {
    final member = seeker.member;
    final fullName = _getFullName(member);

    final rawMobile = (member?.mobile ?? "").trim().isNotEmpty
        ? member!.mobile!.trim()
        : (member?.whatsappNumber ?? "").trim();
    final email = (member?.email ?? "").trim();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Send Message to $fullName",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE6F9ED),
                    child: Icon(Icons.chat, color: Color(0xFF25D366)),
                  ),
                  title: const Text(
                    "WhatsApp",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    rawMobile.isNotEmpty ? rawMobile : "Number not available",
                  ),
                  enabled: rawMobile.isNotEmpty,
                  onTap: rawMobile.isEmpty
                      ? null
                      : () {
                          Navigator.pop(sheetContext);
                          _sendWhatsApp(rawMobile, seeker);
                        },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE3F0FF),
                    child: Icon(Icons.email, color: Colors.blue),
                  ),
                  title: const Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    email.isNotEmpty ? email : "Email not available",
                  ),
                  enabled: email.isNotEmpty,
                  onTap: email.isEmpty
                      ? null
                      : () {
                          Navigator.pop(sheetContext);
                          _sendEmail(email, seeker);
                        },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFDECEA),
                    child: Icon(Icons.mail_outline, color: Color(0xFFEA4335)),
                  ),
                  title: const Text(
                    "Gmail",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    email.isNotEmpty ? email : "Email not available",
                  ),
                  enabled: email.isNotEmpty,
                  onTap: email.isEmpty
                      ? null
                      : () {
                          Navigator.pop(sheetContext);
                          _sendGmail(email, seeker);
                        },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendWhatsApp(
    String phoneNumber,
    GetListSeekerProfilesData seeker,
  ) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.isEmpty) {
      _showSnack("Phone number not available", Colors.orange);
      return;
    }

    _markContacted(seeker);

    final uri = Uri.parse("https://wa.me/$cleanNumber");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnack("WhatsApp not available", Colors.red);
      }
    } catch (e) {
      debugPrint("WhatsApp error: $e");
      _showSnack("Unable to open WhatsApp", Colors.red);
    }
  }

  Future<void> _sendEmail(
    String email,
    GetListSeekerProfilesData seeker,
  ) async {
    final to = email.trim();
    if (to.isEmpty) {
      _showSnack("Email not available", Colors.orange);
      return;
    }

    _markContacted(seeker);

    final uri = _messageMailUri(to);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnack("Email app not available", Colors.red);
      }
    } catch (e) {
      debugPrint("Email error: $e");
      _showSnack("Unable to open email app", Colors.red);
    }
  }

  Future<void> _sendGmail(
    String email,
    GetListSeekerProfilesData seeker,
  ) async {
    final to = email.trim();
    if (to.isEmpty) {
      _showSnack("Email not available", Colors.orange);
      return;
    }

    _markContacted(seeker);

    final gmailAppUri = _gmailAppUri(to);
    final gmailWebUri = _gmailWebUri(to);

    try {
      final openedApp = await launchUrl(
        gmailAppUri,
        mode: LaunchMode.externalApplication,
      );
      if (openedApp) return;

      final openedWeb = await launchUrl(
        gmailWebUri,
        mode: LaunchMode.externalApplication,
      );
      if (!openedWeb && mounted) {
        _showSnack("Gmail not available", Colors.red);
      }
    } catch (e) {
      debugPrint("Gmail error: $e");
      try {
        final openedWeb = await launchUrl(
          gmailWebUri,
          mode: LaunchMode.externalApplication,
        );
        if (!openedWeb && mounted) {
          _showSnack("Gmail not available", Colors.red);
        }
      } catch (webError) {
        debugPrint("Gmail web error: $webError");
        if (mounted) _showSnack("Unable to open Gmail", Colors.red);
      }
    }
  }

  static const String _messageSubject = "Job Opportunity";
  static const String _messageBody =
      "Hello, I came across your profile and would like to discuss a job opportunity.";

  Uri _messageMailUri(String to) {
    return Uri(
      scheme: "mailto",
      path: to,
      queryParameters: {
        "subject": _messageSubject,
        "body": _messageBody,
      },
    );
  }

  Uri _gmailAppUri(String to) {
    return Uri.parse(
      "googlegmail://co?to=${Uri.encodeComponent(to)}"
      "&subject=${Uri.encodeComponent(_messageSubject)}"
      "&body=${Uri.encodeComponent(_messageBody)}",
    );
  }

  Uri _gmailWebUri(String to) {
    return Uri.parse(
      "https://mail.google.com/mail/?view=cm&fs=1"
      "&to=${Uri.encodeComponent(to)}"
      "&su=${Uri.encodeComponent(_messageSubject)}"
      "&body=${Uri.encodeComponent(_messageBody)}",
    );
  }

  void _showSeekerProfileDetails(GetListSeekerProfilesData seeker) {
    final member = seeker.member;
    final fullName = _getFullName(member);
    final profileImageUrl = _getProfileImageUrl(member?.profileImage);

    String contactValue = (member?.mobile ?? "").trim();
    final whatsapp = (member?.whatsappNumber ?? "").trim();
    if (whatsapp.isNotEmpty && whatsapp != contactValue) {
      contactValue =
          contactValue.isNotEmpty ? "$contactValue / $whatsapp" : whatsapp;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final currentlyShortlisted = _isShortlisted(seeker);
            final currentlyRecruited = _isRecruited(seeker);
            final applications = _applicationsFor(seeker);

            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.85,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Profile",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetContext),
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
                              Center(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 44,
                                      backgroundColor: Colors.grey.shade200,
                                      child: ClipOval(
                                        child: profileImageUrl.isNotEmpty
                                            ? FadeInImage(
                                                placeholder: const AssetImage(
                                                  "assets/images/user3.png",
                                                ),
                                                image: NetworkImage(
                                                    profileImageUrl),
                                                imageErrorBuilder: (c, e, s) =>
                                                    Image.asset(
                                                  "assets/images/male.png",
                                                  fit: BoxFit.cover,
                                                  width: 88,
                                                  height: 88,
                                                ),
                                                fit: BoxFit.cover,
                                                width: 88,
                                                height: 88,
                                              )
                                            : Image.asset(
                                                "assets/images/user3.png",
                                                fit: BoxFit.cover,
                                                width: 88,
                                                height: 88,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      fullName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if ((seeker.headline ?? "")
                                        .trim()
                                        .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          seeker.headline!.trim(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Divider(),
                              _sectionTitle("Personal Details"),
                              const SizedBox(height: 12),
                              _detailRow("Name", fullName),
                              _detailRow("Email", member?.email ?? ""),
                              _detailRow("Mobile / WhatsApp", contactValue),
                              _detailRow(
                                  "Member Code", member?.memberCode ?? ""),
                              if (applications.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 15),
                                _sectionTitle("Application Status"),
                                const SizedBox(height: 12),
                                ...applications.map(
                                  (app) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _detailRow(
                                          "Status",
                                          _applicationStatusText(app.member),
                                        ),
                                        _detailRow(
                                          "Job",
                                          (app.job.title ?? "").trim(),
                                        ),
                                        _detailRow(
                                          "Company",
                                          (app.job.companyName ?? "").trim(),
                                        ),
                                        _detailRow(
                                          "Applied On",
                                          (app.member.appliedDate ?? "").trim(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 15),
                              _sectionTitle("Job Preferences"),
                              const SizedBox(height: 12),
                              _detailRow(
                                  "City", (seeker.cityName ?? "").trim()),
                              _detailRow(
                                  "Area", (seeker.areaName ?? "").trim()),
                              _detailRow(
                                "Job Type",
                                _formatWorkType(seeker.workType),
                              ),
                              _detailRow(
                                "Work Mode",
                                _formatWorkMode(seeker.workMode),
                              ),
                              _detailRow(
                                "Expected Salary",
                                _formatSalary(
                                  seeker.expectedSalaryMin,
                                  seeker.expectedSalaryMax,
                                ),
                              ),
                              if ((seeker.noOfInternshipMonth ?? "")
                                  .trim()
                                  .isNotEmpty)
                                _detailRow(
                                  "Internship Months",
                                  seeker.noOfInternshipMonth!,
                                ),
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 15),
                              _sectionTitle("Summary"),
                              const SizedBox(height: 10),
                              Text(
                                (seeker.summary ?? "").trim().isNotEmpty
                                    ? seeker.summary!.trim()
                                    : "No summary added.",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                  color:
                                      (seeker.summary ?? "").trim().isNotEmpty
                                          ? Colors.black87
                                          : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),

                      // Bottom actions
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(sheetContext);
                                _showShortlistJobPicker(seeker);
                              },
                              icon: Icon(
                                currentlyShortlisted
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: Colors.orange,
                                size: 18,
                              ),
                              label: Text(
                                currentlyShortlisted
                                    ? "Shortlisted"
                                    : "Shortlist",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.orange),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: currentlyRecruited
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.green, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          "Recruited",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () async {
                                      final recruited =
                                          await _markRecruited(seeker);
                                      if (!sheetContext.mounted) return;
                                      if (recruited) {
                                        Navigator.pop(sheetContext);
                                      }
                                    },
                                    icon: const Icon(Icons.person_add_alt_1,
                                        size: 18),
                                    label: const Text(
                                      "Mark Recruited",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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
              value.trim().isEmpty ? "-" : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
