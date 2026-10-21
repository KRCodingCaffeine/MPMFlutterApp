import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class SeekerInstructionView extends StatefulWidget {
  const SeekerInstructionView({super.key});

  @override
  State<SeekerInstructionView> createState() => _SeekerInstructionViewState();
}

class _SeekerInstructionViewState extends State<SeekerInstructionView> {
  final Color _brandColor =
      ColorHelperClass.getColorFromHex(ColorResources.logo_color);

  final List<_InstructionStep> _steps = const [
    _InstructionStep(
      icon: Icons.tune,
      color: Colors.blue,
      title: "Set Your Preferences",
      description:
          "When you open the Job screen, fill in your preferences: job type "
          "(Full-time, Part-time, or Internship), work mode (On-site, Work From "
          "Home, or Hybrid), field of work, expected annual salary, preferred "
          "city, and area. For an internship, also enter the number of months. "
          "Upload your resume and tap Submit.",
    ),
    _InstructionStep(
      icon: Icons.work_outline,
      color: Colors.green,
      title: "Browse Matching Jobs",
      description:
          "The Job tab lists openings from Samaj employers. Jobs that match "
          "your preferences appear under \"From Your Preferences\" with a green "
          "highlight. Use the search bar to find roles such as developer or "
          "accountant.",
    ),
    _InstructionStep(
      icon: Icons.visibility_outlined,
      color: Colors.deepPurple,
      title: "View Job Details",
      description:
          "Tap \"View Detail\" on a job card to open the full listing: company, "
          "title, description, location, salary, experience, job type, work "
          "mode, and the last date to apply.",
    ),
    _InstructionStep(
      icon: Icons.send,
      color: Colors.red,
      title: "Apply for a Job",
      description:
          "On the job detail screen, tap \"Apply Now\". Confirm your resume "
          "and submit the application. The job card then shows an Applied "
          "badge so you know it was sent.",
    ),
    _InstructionStep(
      icon: Icons.bookmark,
      color: Colors.orange,
      title: "Save a Job",
      description:
          "Tap the bookmark icon on a job card to save it for later. Saved "
          "jobs appear in the Saved tab. Tap the bookmark again to remove "
          "the job from your saved list.",
    ),
    _InstructionStep(
      icon: Icons.assignment_turned_in,
      color: Colors.teal,
      title: "Track Applied Jobs",
      description:
          "Open the Applied tab to see every job you have applied for, along "
          "with the date you applied. Jobs you have already applied to stay "
          "marked as Applied on the Job tab as well.",
    ),
    _InstructionStep(
      icon: Icons.edit_note,
      color: Colors.purple,
      title: "Update Your Preferences",
      description:
          "Tap \"Preferences\" in the top bar any time to change job type, "
          "work mode, field of work, expected salary, city, area, or resume. "
          "Updated preferences change which jobs are highlighted for you.",
    ),
    _InstructionStep(
      icon: Icons.swap_horiz,
      color: Colors.blueGrey,
      title: "Switch Between Tabs",
      description:
          "Use the bottom navigation bar to move between Job, Saved, and "
          "Applied. Each tab shows only the jobs that belong there, and the "
          "search bar filters the list you are viewing.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _brandColor,
        title: Builder(
          builder: (context) {
            final fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              "How Looking for Jobs Works",
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: _brandColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.assignment_outlined,
                          color: _brandColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Guide to Finding a Job",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Follow the steps below to set your preferences, browse "
                    "openings from Samaj employers, save jobs, and apply. "
                    "Each step helps you find the right opportunity quickly.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.format_list_numbered,
                  size: 20,
                  color: _brandColor,
                ),
                const SizedBox(width: 8),
                Text(
                  "Step-by-Step Instructions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return _buildStepCard(_steps[index], index + 1);
              },
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber.shade800,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Tip: Complete your preferences and upload a resume "
                      "before applying. Matching jobs are highlighted first, "
                      "and you can update preferences later from the top bar.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber.shade900,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "I Understand, Confirm",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(_InstructionStep step, int stepNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: step.color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: step.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "$stepNumber",
              style: TextStyle(
                color: step.color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
                    Icon(step.icon, color: step.color, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionStep {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _InstructionStep({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}
