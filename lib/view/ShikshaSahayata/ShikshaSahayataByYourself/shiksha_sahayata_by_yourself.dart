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
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByYourself/applicant_detail_yourself.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByYourself/current_year_any_other_loan_yourself.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByYourself/current_year_education_yourself.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByYourself/education_detail_yourself.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByYourself/family_detail_yourself.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByYourself/previous_year_loan_yourself.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByYourself/reference_yourself.dart';
import 'package:mpm/view/ShikshaSahayata/shiksha_sahayata_view.dart';
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
  bool familyCompleted = false;
  bool educationCompleted = false;
  bool currentYearCompleted = false;
  bool previousLoanCompleted = false;
  bool otherLoanCompleted = false;

  bool isAllCompleted = false;

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

      // 🔥 For now we assume all enabled once applicant exists
      familyCompleted = applicantCompleted;
      educationCompleted = applicantCompleted;
      currentYearCompleted = applicantCompleted;
      previousLoanCompleted = applicantCompleted;
      otherLoanCompleted = applicantCompleted;

      isAllCompleted =
          applicantCompleted &&
              familyCompleted &&
              educationCompleted &&
              currentYearCompleted &&
              previousLoanCompleted &&
              otherLoanCompleted;
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
          "Shiksha Sahayata For Yourself",
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
                  MaterialPageRoute(builder: (_) => const ApplicantDetailYourself()),
                );
                await loadProgress();
              },
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
                    builder: (_) => FamilyDetailYourself(shikshaApplicantId: id),
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
                    builder: (_) =>
                        EducationDetailYourselfView(shikshaApplicantId: id),
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
                    builder: (_) =>
                        CurrentYearEducationYourselfView(shikshaApplicantId: id),
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
                    builder: (_) =>
                        CurrentYearAnyOtherLoanYourselfView(shikshaApplicantId: id),
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
                    builder: (_) =>
                        PreviousYearLoanYourselfView(shikshaApplicantId: id),
                  ),
                );
              },
            ),

            buildStepButton(
              title: "References",
              icon: Icons.verified,
              isEnabled: applicantCompleted,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getString(_prefsApplicantIdKey);
                if (id == null || id.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ReferenceYourselfView(shikshaApplicantId: id),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      /// 🔥 SHOW SUBMIT BUTTON ONLY IF ALL COMPLETED
      bottomNavigationBar: isAllCompleted ? _buildSubmitBar() : null,
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

  /// 🔥 FINAL SUBMIT BAR
  Widget _buildSubmitBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Expanded(
              child: Text(
                "All steps completed. Click Submit to finish your application.",
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: const Text("Confirm Submission"),
                    content: const Text(
                      "Before submitting, please verify that all the details entered are correct. Once submitted, the application will be forwarded for review.",
                      style: TextStyle(fontSize: 14),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context); // close dialog

                          // 🔥 REMOVE STORED SESSION ID
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove(_prefsApplicantIdKey);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Shiksha Application Submitted Successfully"),
                              backgroundColor: Colors.green,
                            ),
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ShikshaSahayataView(),
                            ),
                                (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Confirm"),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                ColorHelperClass.getColorFromHex(
                    ColorResources.red_color),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
