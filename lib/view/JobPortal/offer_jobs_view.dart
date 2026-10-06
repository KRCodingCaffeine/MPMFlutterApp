import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/BusinessProfile/BusinessOccupationProfile/BusinessOccupationProfileData.dart';
import 'package:mpm/model/JobPortal/GetJobByMemberId/GetJobByMemberIdData.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class OfferJobsView extends StatefulWidget {
  final List<BusinessOccupationProfileData>? initialBusinessProfiles;
  final List<GetJobByMemberIdData>? initialPostedJobs;
  final Map<String, int>? initialApplicantCountsByJobId;

  const OfferJobsView({
    super.key,
    this.initialBusinessProfiles,
    this.initialPostedJobs,
    this.initialApplicantCountsByJobId,
  });

  @override
  State<OfferJobsView> createState() => _OfferJobsViewState();
}

class _OfferJobsViewState extends State<OfferJobsView> {
  final Color _brandColor =
  ColorHelperClass.getColorFromHex(ColorResources.logo_color);

  // Navigation handlers
  void _openPostNewJob() {
    // TODO: Navigate to Post New Job screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => PostNewJobView()),
    // );
  }

  void _openPostedJobs() {
    // TODO: Navigate to Posted Jobs screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => PostedJobsView()),
    // );
  }

  void _openJobSeekers() {
    // TODO: Navigate to Job Seekers screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => JobSeekersView()),
    // );
  }

  // Button builder for action buttons (same style as SamitiElectionView)
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
                maxLines: 2,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              "Job Seekers",
              Icons.people_alt,
              Colors.orange,
              _openJobSeekers,
            ),
          ],
        ),
      ),
    );
  }
}