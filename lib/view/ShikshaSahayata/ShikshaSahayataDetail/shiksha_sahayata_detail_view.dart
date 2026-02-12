import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplicationsByAppliedBy/ShikshaApplicationsByAppliedByData.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/current_year_any_other_loan.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/current_year_education.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/education_detail.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/family_detail.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/reference.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/previous_year_loan.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataDetail/edit_applicant_detail.dart';

class ShikshaSahayataDetailView extends StatefulWidget {
  final String shikshaApplicantId;
  final ShikshaApplicationsByAppliedByData applicationData;

  const ShikshaSahayataDetailView({
    super.key,
    required this.shikshaApplicantId,
    required this.applicationData,
  });

  @override
  State<ShikshaSahayataDetailView> createState() =>
      _ShikshaSahayataDetailViewState();
}


class _ShikshaSahayataDetailViewState
    extends State<ShikshaSahayataDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          "Application Details",
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditApplicantDetailView(
                      applicationData: widget.applicationData,
                    ),
                  ),
                );
              },
            ),

            buildStepButton(
              title: "Family Detail",
              icon: Icons.family_restroom,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const FamilyDetail(shikshaApplicantId: ""),
                  ),
                );
              },
            ),

            buildStepButton(
              title: "Education History (Other Than Current Year)",
              icon: Icons.menu_book,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const EducationDetailView(shikshaApplicantId: ""),
                  ),
                );
              },
            ),

            buildStepButton(
              title:
              "Current Year Education & Loan Requested From MPM",
              icon: Icons.school,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const CurrentYearEducationView(
                        shikshaApplicantId: ""),
                  ),
                );
              },
            ),

            buildStepButton(
              title:
              "Current Year Loan Applied / Received Elsewhere",
              icon: Icons.handshake,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const CurrentYearAnyOtherLoan(
                        shikshaApplicantId: ""),
                  ),
                );
              },
            ),

            buildStepButton(
              title: "Received Loan in Past",
              icon: Icons.volunteer_activism,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const PreviousYearLoanView(
                        shikshaApplicantId: ""),
                  ),
                );
              },
            ),

            buildStepButton(
              title: "References",
              icon: Icons.verified,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const ReferenceView(shikshaApplicantId: ""),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildStepButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
          ),
          onTap: onTap,
        ),
        const Divider(thickness: 0.5),
      ],
    );
  }
}
