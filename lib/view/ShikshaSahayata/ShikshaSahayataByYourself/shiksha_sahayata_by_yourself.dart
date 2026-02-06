import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/any_other_charity_fund.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/current_year_education.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/education_detail.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/family_detail.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/mpm.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/other_charity_fund.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByYourself/applicant_detail_yourself.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShikshaSahayataByYourself extends StatefulWidget {
  const ShikshaSahayataByYourself({super.key});

  @override
  State<ShikshaSahayataByYourself> createState() =>
      _ShikshaSahayataByYourselfState();
}

class _ShikshaSahayataByYourselfState
    extends State<ShikshaSahayataByYourself> {

  static const String _prefsApplicantIdKey = 'shiksha_applicant_id';

  bool applicantCompleted = false;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final applicantId = prefs.getString(_prefsApplicantIdKey);

    setState(() {
      applicantCompleted = applicantId != null && applicantId.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text(
          "Shiksha Sahayata For Yourself",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            buildStepButton(
              title: "Applicant Detail",
              icon: Icons.person,
              isEnabled: true,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ApplicantDetailYourself()),
                );
                await loadProgress();
              },
            ),

            buildStepButton(
              title: "Family Detail",
              icon: Icons.family_restroom,
              isEnabled: applicantCompleted,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const FamilyDetail()),
                // );
              },
            ),

            buildStepButton(
              title: "Education History (Other Than Current Year)",
              icon: Icons.menu_book,
              isEnabled: applicantCompleted,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (_) => const EducationDetailView()),
                // );
              },
            ),

            buildStepButton(
              title: "Current Year Education & Loan Requested From MPM",
              icon: Icons.school,
              isEnabled: applicantCompleted,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (_) => const CurrentYearEducationView()),
                // );
              },
            ),

            buildStepButton(
              title: "Current Year Loan Applied / Received Elsewhere",
              icon: Icons.handshake,
              isEnabled: applicantCompleted,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (_) => const AnyOtherCharityFundView()),
                // );
              },
            ),

            buildStepButton(
              title: "Received Loan in Past",
              icon: Icons.volunteer_activism,
              isEnabled: applicantCompleted,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (_) => const OtherCharityFundView()),
                // );
              },
            ),

            buildStepButton(
              title: "References",
              icon: Icons.verified,
              isEnabled: applicantCompleted,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const MPMView()),
                // );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildStepButton({
    required String title,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    final color = isEnabled ? Colors.black : Colors.black54;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            title,
            style: TextStyle(fontSize: 16, color: color),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: color,
          ),
          onTap: isEnabled ? onTap : null,
        ),
        const Divider(thickness: 0.5),
      ],
    );
  }
}
