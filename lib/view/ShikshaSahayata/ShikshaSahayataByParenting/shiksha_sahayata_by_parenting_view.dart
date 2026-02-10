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
import 'package:mpm/view/ShikshaSahayata/shiksha_sahayata_view.dart';
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
  bool referenceCompleted = false;

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

      familyCompleted = prefs.getBool('family_completed') ?? false;
      educationCompleted = prefs.getBool('education_completed') ?? false;
      currentYearCompleted = prefs.getBool('current_year_completed') ?? false;
      previousLoanCompleted = prefs.getBool('previous_loan_completed') ?? false;
      otherLoanCompleted = prefs.getBool('other_loan_completed') ?? false;
      referenceCompleted = prefs.getBool('reference_completed') ?? false;

      isAllCompleted = applicantCompleted &&
          familyCompleted &&
          educationCompleted &&
          currentYearCompleted &&
          previousLoanCompleted &&
          otherLoanCompleted &&
          referenceCompleted;
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
              isCompleted: applicantCompleted,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApplicantDetail()),
                );
                await loadProgress();
              },
            ),
            buildStepButton(
              title: "Family Detail",
              icon: Icons.family_restroom,
              isEnabled: applicantCompleted,
              isCompleted: familyCompleted,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getString(_prefsApplicantIdKey);
                if (id == null || id.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FamilyDetail(shikshaApplicantId: id),
                  ),
                ).then((_) => loadProgress());
              },
            ),
            buildStepButton(
              title: "Education History (Other Than Current Year)",
              icon: Icons.menu_book,
              isEnabled: applicantCompleted,
              isCompleted: educationCompleted,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getString(_prefsApplicantIdKey);
                if (id == null || id.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EducationDetailView(shikshaApplicantId: id),
                  ),
                ).then((_) => loadProgress());
              },
            ),
            buildStepButton(
              title: "Current Year Education & Loan Requested From MPM",
              icon: Icons.school,
              isEnabled: applicantCompleted,
              isCompleted: currentYearCompleted,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getString(_prefsApplicantIdKey);
                if (id == null || id.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CurrentYearEducationView(shikshaApplicantId: id),
                  ),
                ).then((_) => loadProgress());
              },
            ),
            buildStepButton(
              title: "Current Year Loan Applied / Received Elsewhere",
              icon: Icons.handshake,
              isEnabled: applicantCompleted,
              isCompleted: otherLoanCompleted,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getString(_prefsApplicantIdKey);
                if (id == null || id.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CurrentYearAnyOtherLoan(shikshaApplicantId: id),
                  ),
                ).then((_) => loadProgress());
              },
            ),
            buildStepButton(
              title: "Received Loan in Past",
              icon: Icons.volunteer_activism,
              isEnabled: applicantCompleted,
              isCompleted: previousLoanCompleted,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getString(_prefsApplicantIdKey);
                if (id == null || id.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PreviousYearLoanView(shikshaApplicantId: id),
                  ),
                ).then((_) => loadProgress());
              },
            ),
            buildStepButton(
              title: "References",
              icon: Icons.verified,
              isEnabled: applicantCompleted,
              isCompleted: referenceCompleted,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getString(_prefsApplicantIdKey);
                if (id == null || id.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReferenceView(shikshaApplicantId: id),
                  ),
                ).then((_) => loadProgress());
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: isAllCompleted ? _buildSubmitBar() : null,
    );
  }

  Widget buildStepButton({
    required String title,
    required IconData icon,
    required bool isEnabled,
    required bool isCompleted,
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
          trailing: isCompleted
              ? const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                )
              : Icon(
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
                _showFinalConfirmationSheet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  void _showFinalConfirmationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(
                Icons.verified,
                size: 60,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              const Text(
                "Confirm Submission",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Please verify that all details entered are correct.\nOnce submitted, the application will be forwarded for review.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorHelperClass.getColorFromHex(
                            ColorResources.red_color),
                        side: BorderSide(
                          color: ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        final prefs = await SharedPreferences.getInstance();

                        await prefs.clear();

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
                        backgroundColor: ColorHelperClass.getColorFromHex(
                            ColorResources.red_color),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Confirm"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
