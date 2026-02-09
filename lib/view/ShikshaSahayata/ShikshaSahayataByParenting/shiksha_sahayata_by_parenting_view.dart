import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/current_year_any_other_loan.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/applicant_detail.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/current_year_education.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/education_detail.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/family_detail.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/reference.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/previous_year_loan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShikshaSahayataByParentingView extends StatefulWidget {
  const ShikshaSahayataByParentingView({super.key});

  @override
  State<ShikshaSahayataByParentingView> createState() =>
      _ShikshaSahayataByParentingViewState();
}

class _ShikshaSahayataByParentingViewState
    extends State<ShikshaSahayataByParentingView> {
  static const String _prefsApplicantIdKey = 'shiksha_applicant_id';

  bool applicantCompleted = false;
  bool familyCompleted = false;
  bool educationCompleted = false;
  bool currentYearCompleted = false;
  bool previousLoanCompleted = false;
  bool otherLoanCompleted = false;

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
      familyCompleted = false;
      educationCompleted = false;
      currentYearCompleted = false;
      previousLoanCompleted = false;
      otherLoanCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          "Shiksha Sahayata For Children",
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
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
                  MaterialPageRoute(builder: (_) => const ApplicantDetail()),
                );
                await loadProgress();              },
            ),

            buildStepButton(
              title: "Family Detail",
              icon: Icons.family_restroom,
              isEnabled: applicantCompleted,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getString(_prefsApplicantIdKey);

                if (id == null || id.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FamilyDetail(
                      shikshaApplicantId: id,
                    ),
                  ),
                );
              },
            ),

            buildStepButton(
              title: "Education History (Other Than Current Year)",
              icon: Icons.menu_book,
              isEnabled: applicantCompleted,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getString(_prefsApplicantIdKey);

                if (id == null || id.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EducationDetailView(
                      shikshaApplicantId: id,
                    ),
                  ),
                );
              },
            ),

            buildStepButton(
              title: "Current Year Education & Loan Requested From MPM",
              icon: Icons.school,
              isEnabled: applicantCompleted,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getString(_prefsApplicantIdKey);

                if (id == null || id.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CurrentYearEducationView(
                      shikshaApplicantId: id,
                    ),
                  ),
                );
              },
            ),

            buildStepButton(
              title: "Current Year Loan Applied / Received Elsewhere",
              icon: Icons.handshake,
              isEnabled: applicantCompleted,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getString(_prefsApplicantIdKey);

                if (id == null || id.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CurrentYearAnyOtherLoan(
                      shikshaApplicantId: id,
                    ),
                  ),
                );
              },
            ),

            buildStepButton(
              title: "Received Loan in Past",
              icon: Icons.volunteer_activism,
              isEnabled: applicantCompleted,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getString(_prefsApplicantIdKey);

                if (id == null || id.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtherCharityFundView(
                      shikshaApplicantId: id,
                    ),
                  ),
                );
              },
            ),

            // buildStepButton(
            //   title: "References",
            //   icon: Icons.verified,
            //   isEnabled: applicantCompleted,
            //   onTap: () async {
            //     final prefs = await SharedPreferences.getInstance();
            //     final id = prefs.getString(_prefsApplicantIdKey);
            //
            //     if (id == null || id.isEmpty) return;
            //
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => MPMView(
            //           shikshaApplicantId: id,
            //         ),
            //       ),
            //     );
            //   },
            // ),
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
    final color = isEnabled ? Colors.black : Colors.black45;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
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
