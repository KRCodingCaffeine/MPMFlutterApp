import 'package:flutter/material.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/ShikshaApplicationData.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplicationsByAppliedBy/ShikshaApplicationsByAppliedByData.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ShikshaApplicationRepo/shiksha_application_repository/shiksha_application_repo.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataDetail/edit_applicant_detail.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataDetail/edit_current_year_any_other_loan.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataDetail/edit_current_year_education.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataDetail/edit_education_detail.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataDetail/edit_family_detail.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataDetail/edit_previous_year_loan.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataDetail/edit_reference.dart';
import 'package:mpm/view/ShikshaSahayata/shiksha_sahayata_view.dart';

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

class _ShikshaSahayataDetailViewState extends State<ShikshaSahayataDetailView> {
  final ShikshaApplicationRepository _applicationRepo =
      ShikshaApplicationRepository();

  ShikshaApplicationData? _latestApplicationData;
  bool _isRefreshing = false;
  bool applicantCompleted = false;
  bool familyCompleted = false;
  bool educationCompleted = false;
  bool currentYearCompleted = false;
  bool previousLoanCompleted = false;
  bool otherLoanCompleted = false;
  bool referenceCompleted = false;

  bool get isAllCompleted =>
      applicantCompleted &&
      familyCompleted &&
      educationCompleted &&
      currentYearCompleted &&
      previousLoanCompleted &&
      otherLoanCompleted &&
      referenceCompleted;

  @override
  void initState() {
    super.initState();
    _loadProgressFromApplicationData(widget.applicationData);
    _refreshApplicationStatus();
  }

  bool get canEditAndSubmit {
    String status = '';

    if (widget.applicationData.requestedLoanEducationAppliedBy != null &&
        widget.applicationData.requestedLoanEducationAppliedBy!.isNotEmpty) {
      status = widget
              .applicationData.requestedLoanEducationAppliedBy!.first.loanStatus
              ?.toLowerCase()
              .trim() ??
          '';
    }

    return status.isEmpty;
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  Future<void> _refreshApplicationStatus() async {
    final applicationId = widget.shikshaApplicantId.trim();
    if (applicationId.isEmpty) {
      return;
    }

    setState(() => _isRefreshing = true);

    try {
      final response = await _applicationRepo.fetchShikshaApplicationById(
        applicantId: applicationId,
      );

      if (!mounted) return;

      if (response.status == true && response.data != null) {
        _latestApplicationData = response.data;
        _loadProgressFromFetchedData(response.data!);
      }
    } catch (_) {
      if (!mounted) return;
      _loadProgressFromApplicationData(widget.applicationData);
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _loadProgressFromApplicationData(
    ShikshaApplicationsByAppliedByData data,
  ) {
    setState(() {
      applicantCompleted = _hasText(data.shikshaApplicantId);
      familyCompleted = data.familyMembers?.isNotEmpty ?? false;
      educationCompleted = data.education?.isNotEmpty ?? false;
      currentYearCompleted =
          data.requestedLoanEducationAppliedBy?.isNotEmpty ?? false;
      otherLoanCompleted = data.receivedLoans
              ?.any((loan) => loan.appliedYearOn?.toLowerCase() == 'current') ??
          false;
      previousLoanCompleted = data.receivedLoans?.any(
            (loan) => loan.appliedYearOn?.toLowerCase() == 'previous',
          ) ??
          false;
      referenceCompleted = data.referredMembers?.isNotEmpty ?? false;
    });
  }

  void _loadProgressFromFetchedData(ShikshaApplicationData data) {
    setState(() {
      applicantCompleted = _hasText(data.shikshaApplicantId);
      familyCompleted = data.familyMembers?.isNotEmpty ?? false;
      educationCompleted = data.education?.isNotEmpty ?? false;
      currentYearCompleted = data.requestedLoanEducation?.isNotEmpty ?? false;
      otherLoanCompleted = data.receivedLoans
              ?.any((loan) => loan.appliedYearOn?.toLowerCase() == 'current') ??
          false;
      previousLoanCompleted = data.receivedLoans?.any(
            (loan) => loan.appliedYearOn?.toLowerCase() == 'previous',
          ) ??
          false;
      referenceCompleted = data.referredMembers?.isNotEmpty ?? false;
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
        child: RefreshIndicator(
          onRefresh: _refreshApplicationStatus,
          child: ListView(
            children: [
              if (_isRefreshing)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(),
                ),
              buildStepButton(
                title: "Applicant Detail",
                icon: Icons.person,
                isCompleted: applicantCompleted,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditApplicantDetailView(
                        applicationData: widget.applicationData,
                      ),
                    ),
                  );
                  await _refreshApplicationStatus();
                },
              ),
              buildStepButton(
                title: "Family Detail",
                icon: Icons.family_restroom,
                isCompleted: familyCompleted,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditFamilyDetailView(
                        applicationData: widget.applicationData,
                      ),
                    ),
                  );
                  await _refreshApplicationStatus();
                },
              ),
              buildStepButton(
                title: "Education History (Other Than Current Year)",
                icon: Icons.menu_book,
                isCompleted: educationCompleted,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditEducationDetailView(
                        applicationData: widget.applicationData,
                      ),
                    ),
                  );
                  await _refreshApplicationStatus();
                },
              ),
              buildStepButton(
                title: "Current Year Education which Loan Requested From MPM",
                icon: Icons.school,
                isCompleted: currentYearCompleted,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCurrentYearEducationView(
                        applicationData: widget.applicationData,
                      ),
                    ),
                  );
                  await _refreshApplicationStatus();
                },
              ),
              buildStepButton(
                title: "Current Year Loan Applied Elsewhere",
                icon: Icons.handshake,
                isCompleted: otherLoanCompleted,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCurrentYearAnyOtherLoanView(
                        applicationData: widget.applicationData,
                      ),
                    ),
                  );
                  await _refreshApplicationStatus();
                },
              ),
              buildStepButton(
                title: "Received Loan in Past",
                icon: Icons.volunteer_activism,
                isCompleted: previousLoanCompleted,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPreviousYearLoanView(
                        applicationData: widget.applicationData,
                      ),
                    ),
                  );
                  await _refreshApplicationStatus();
                },
              ),
              buildStepButton(
                title: "References",
                icon: Icons.verified,
                isCompleted: referenceCompleted,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditReferenceView(
                        applicationData: widget.applicationData,
                      ),
                    ),
                  );
                  await _refreshApplicationStatus();
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          (isAllCompleted && canEditAndSubmit) ? _buildSubmitBar() : null,
    );
  }

  Widget buildStepButton({
    required String title,
    required IconData icon,
    required bool isCompleted,
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
          trailing: (isCompleted && canEditAndSubmit)
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
          onTap: onTap,
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
            color: Colors.black.withValues(alpha: 0.08),
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
                "All details are filled. Click Submit to finish your application.",
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _showFinalConfirmationSheet,
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

  Future<void> _showFinalConfirmationSheet() async {
    await _refreshApplicationStatus();

    if (!isAllCompleted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all application details before submit."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.verified, size: 60, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                "Confirm Submission",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Application ID: ${_latestApplicationData?.shikshaApplicantId ?? widget.shikshaApplicantId}\n\nPlease verify that all details entered are correct.\nOnce submitted, the application will be forwarded for review.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Shiksha Application Submitted Successfully"),
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
                ),
                child: const Text("Confirm"),
              ),
            ],
          ),
        );
      },
    );
  }
}
