import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ShikshaSahayata/any_other_charity_fund.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/applicant_detail.dart';
import 'package:mpm/view/ShikshaSahayata/current_year_education.dart';
import 'package:mpm/view/ShikshaSahayata/education_detail.dart';
import 'package:mpm/view/ShikshaSahayata/family_detail.dart';
import 'package:mpm/view/ShikshaSahayata/mpm.dart';
import 'package:mpm/view/ShikshaSahayata/other_charity_fund.dart';

class ShikshaSahayataByParentingView extends StatefulWidget {
  const ShikshaSahayataByParentingView({super.key});

  @override
  State<ShikshaSahayataByParentingView> createState() =>
      _ShikshaSahayataByParentingViewState();
}

class _ShikshaSahayataByParentingViewState
    extends State<ShikshaSahayataByParentingView> {

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

  void loadProgress() {
    setState(() {
      applicantCompleted = false;
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
        title: const Text(
          "Shiksha Sahayata For Children",
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
                  MaterialPageRoute(builder: (_) => const ApplicantDetail()),
                );
                setState(() => applicantCompleted = true);
              },
            ),

            buildStepButton(
              title: "Family Detail",
              icon: Icons.family_restroom,
              isEnabled: applicantCompleted,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FamilyDetail()),
                );
                setState(() => familyCompleted = true);
              },
            ),

            buildStepButton(
              title: "Education Detail",
              icon: Icons.menu_book,
              isEnabled: familyCompleted,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EducationDetailView()),
                );
                setState(() => educationCompleted = true);
              },
            ),

            buildStepButton(
              title: "Current Year Education",
              icon: Icons.school,
              isEnabled: educationCompleted,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CurrentYearEducationView()),
                );
                setState(() => currentYearCompleted = true);
              },
            ),

            buildStepButton(
              title: "Previous Years: Loan Availed",
              icon: Icons.volunteer_activism,
              isEnabled: currentYearCompleted,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const OtherCharityFundView()),
                );
                setState(() => previousLoanCompleted = true);
              },
            ),

            buildStepButton(
              title: "Current Year: Any Other Applied Loan",
              icon: Icons.handshake,
              isEnabled: previousLoanCompleted,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AnyOtherCharityFundView()),
                );
                setState(() => otherLoanCompleted = true);
              },
            ),

            buildStepButton(
              title: "MPM Verification",
              icon: Icons.verified,
              isEnabled: otherLoanCompleted,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MPMView()),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// DISABLED / ENABLED STEP BUTTON
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
