import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/BusinessProfile/BusinessOccupationProfile/BusinessOccupationProfileData.dart';
import 'package:mpm/model/JobPortal/GetJobByMemberId/GetJobByMemberIdData.dart';
import 'package:mpm/repository/JobPortal/GetJobByMemberIdRepo/get_job_by_member_id_repository.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/JobPortal/job_seeker_profile.dart';
import 'package:mpm/view/JobPortal/post_new_job.dart';
import 'package:mpm/view/JobPortal/recruiter_job_view.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class OfferJobsView extends StatefulWidget {
  final List<BusinessOccupationProfileData>? initialBusinessProfiles;
  final List<GetJobByMemberIdData>? initialPostedJobs;
  final Map<String, int>? initialApplicantCountsByJobId;

  const OfferJobsView({
    super.key,
    this.initialBusinessProfiles = const [],
    this.initialPostedJobs = const [],
    this.initialApplicantCountsByJobId = const {},
  });

  @override
  State<OfferJobsView> createState() => _OfferJobsViewState();
}

class _OfferJobsViewState extends State<OfferJobsView> {
  final Color _brandColor =
      ColorHelperClass.getColorFromHex(ColorResources.logo_color);

  final GetJobByMemberIdRepository _jobRepo = GetJobByMemberIdRepository();
  final UdateProfileController profileController =
      Get.find<UdateProfileController>();

  List<BusinessOccupationProfileData> get _businessProfiles =>
      widget.initialBusinessProfiles ?? <BusinessOccupationProfileData>[];

  List<GetJobByMemberIdData> _postedJobs = [];
  bool _isLoadingJobs = false;

  @override
  void initState() {
    super.initState();
    _postedJobs = widget.initialPostedJobs ?? [];

    if (widget.initialPostedJobs == null || widget.initialPostedJobs!.isEmpty) {
      _loadPostedJobs();
    }
  }

  Future<void> _loadPostedJobs() async {
    try {
      setState(() => _isLoadingJobs = true);
      final memberId = profileController.memberId.value.trim();
      if (memberId.isEmpty) return;

      final response = await _jobRepo.getJobs(memberId);
      if (!mounted) return;

      if (response.status == true && response.data != null) {
        setState(() => _postedJobs = response.data!);
      }
    } catch (e) {
      debugPrint("Load Posted Jobs Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingJobs = false);
    }
  }

  bool get _hasPostedJobs => _postedJobs.isNotEmpty;

  Future<void> _openPostNewJob() async {
    final shouldRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PostNewJob(
          initialBusinessProfiles: _businessProfiles,
        ),
      ),
    );

    if (shouldRefresh == true && mounted) {
      // Refresh posted jobs so the layout re-evaluates
      await _loadPostedJobs();
    }
  }

  Future<void> _openPostedJobs() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RecruiterJobView(),
      ),
    );
    // Refresh when returning in case jobs changed
    if (mounted) {
      await _loadPostedJobs();
    }
  }

  void _openJobSeekers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const JobSeekerProfile(),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 130,
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 45),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _brandColor,
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Offer Jobs',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoadingJobs && _postedJobs.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: ColorHelperClass.getColorFromHex(
                  ColorResources.red_color,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Case 1: No jobs → only Post New Jobs
                  if (!_hasPostedJobs) ...[
                    _buildActionButton(
                      context,
                      "Post New Jobs",
                      Icons.post_add,
                      Colors.blue,
                      _openPostNewJob,
                    ),
                  ] else ...[
                    _buildActionButton(
                      context,
                      "Post New Jobs",
                      Icons.post_add,
                      Colors.blue,
                      _openPostNewJob,
                    ),
                    _buildActionButton(
                      context,
                      "Posted Jobs",
                      Icons.work_history,
                      Colors.green,
                      _openPostedJobs,
                    ),
                    _buildActionButton(
                      context,
                      "Canditates Looking For Jobs",
                      Icons.people_alt,
                      Colors.orange,
                      _openJobSeekers,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
