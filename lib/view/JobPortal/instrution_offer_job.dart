import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class InstrutionOfferJob extends StatefulWidget {
  const InstrutionOfferJob({super.key});

  @override
  State<InstrutionOfferJob> createState() => _InstrutionOfferJobState();
}

class _InstrutionOfferJobState extends State<InstrutionOfferJob> {
  final Color _brandColor =
      ColorHelperClass.getColorFromHex(ColorResources.logo_color);

  final List<_InstructionStep> _steps = const [
    _InstructionStep(
      icon: Icons.post_add,
      color: Colors.blue,
      title: "Post a New Job",
      description:
          "Tap \"Post New Jobs\" on the Offer Jobs screen to create a new listing. "
          "Fill in company, job title, description, location, salary, experience, "
          "vacancies, last apply date, job type, and work mode. Upload a job "
          "description document and tap Submit to publish.",
    ),
    _InstructionStep(
      icon: Icons.work_history,
      color: Colors.green,
      title: "Manage Posted Jobs",
      description:
          "Open \"Posted Jobs\" to see all your listings sorted by Published, Draft, "
          "and Closed tabs. Tap the ⋮ menu on any card to Edit, Publish, move to "
          "Draft, or Close the job. Tap the Applicants chip to view applications.",
    ),
    _InstructionStep(
      icon: Icons.people_alt,
      color: Colors.orange,
      title: "Browse Candidates",
      description:
          "In \"Canditate Looking For Jobs\" you'll see all registered candidates "
          "with their profile summary, city, preferred job type, work mode, and "
          "expected salary. Use the search bar to filter by name, Job Role, city",
    ),
    _InstructionStep(
      icon: Icons.visibility_outlined,
      color: Colors.deepPurple,
      title: "View a Candidate's Profile",
      description:
          "Tap \"View Profile\" on a candidate card to open their full profile: "
          "personal details, job preferences, expected salary, internship months, "
          "and summary. This helps you decide whether to shortlist them.",
    ),
    _InstructionStep(
      icon: Icons.bookmark,
      color: Colors.orange,
      title: "Shortlist a Candidate",
      description:
          "Tap \"Shortlist\" on a candidate card to add them to your Shortlisted "
          "list. You can find them later under the \"Shortlisted\" tab in the "
          "bottom navigation. Tapping again removes them from the shortlist.",
    ),
    _InstructionStep(
      icon: Icons.call,
      color: Colors.green,
      title: "Call or Message a Shortlisted Candidate",
      description:
          "From the Shortlisted tab, use the \"Call\" button to open the dialer "
          "or \"Send Message\" to reach out via WhatsApp or Email. As soon as you "
          "reach out, the candidate is automatically marked as Contacted.",
    ),
    _InstructionStep(
      icon: Icons.mark_email_read,
      color: Colors.teal,
      title: "Contacted Candidates",
      description:
          "Candidates you have called or messaged appear with a teal CONTACTED "
          "badge.",
    ),
    _InstructionStep(
      icon: Icons.check_circle,
      color: Colors.green,
      title: "Mark as Recruited",
      description:
          "Tap \"Mark Recruited\" on a contacted candidate to confirm that you have recruited him. The "
          "candidate moves into the \"Recruited\" category.",
    ),
    _InstructionStep(
      icon: Icons.swap_horiz,
      color: Colors.purple,
      title: "Switch Between Tabs",
      description:
          "Use the bottom navigation bar to switch between Candidates, "
          "Shortlisted, and Recruited. Each tab shows only the relevant "
          "candidates, and the search bar filters within the active tab.",
    ),
    _InstructionStep(
      icon: Icons.sync,
      color: Colors.blueGrey,
      title: "Refresh the List",
      description:
          "Pull down on any list to refresh candidate data from the server. This "
          "is useful if new candidates have registered or existing profiles have "
          "been updated.",
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
              "How Offer Jobs Works",
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
            // Header card
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
                          "Guide to Hiring from Samaj",
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
                    "Follow the steps below to post jobs, review candidates, "
                    "and confirm recruits. Each step is designed to help you "
                    "hire the right talent from the Samaj community quickly and "
                    "easily.",
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

            // Section title
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

            // Steps
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return _buildStepCard(_steps[index], index + 1);
              },
            ),

            const SizedBox(height: 20),

            // Footer note
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
                      "Tip: You can review all shortlisted and recruited "
                      "candidates any time from the Offer Jobs screen. Use the "
                      "search bar to quickly find someone by name, city, or "
                      "headline.",
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

      // ✅ Continue button → returns true so caller can redirect
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
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              label: const Text(
                "I Understand & Continue",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
          Column(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: step.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step.icon,
                  color: step.color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
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
