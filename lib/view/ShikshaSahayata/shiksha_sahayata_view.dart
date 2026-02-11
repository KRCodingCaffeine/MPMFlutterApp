import 'package:flutter/material.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplicationsByAppliedBy/ShikshaApplicationsByAppliedByData.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ShikshaApplicationsAppliedByRepo/shiksha_applications_applied_by_repository/shiksha_application_applied_by_repository.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class ShikshaSahayataView extends StatefulWidget {
  const ShikshaSahayataView({super.key});

  @override
  State<ShikshaSahayataView> createState() =>
      _ShikshaSahayataViewState();
}

class _ShikshaSahayataViewState
    extends State<ShikshaSahayataView> {
  final ShikshaApplicationsByAppliedByRepository _repo =
  ShikshaApplicationsByAppliedByRepository();

  bool isLoading = true;
  bool hasApplied = false;

  ShikshaApplicationsByAppliedByData? applicationData;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    try {
      final session = await SessionManager.getSession();
      final memberId = session?.memberId?.toString();

      if (memberId == null) {
        setState(() => isLoading = false);
        return;
      }

      final response =
      await _repo.fetchShikshaApplicationsByAppliedBy(
        appliedBy: memberId,
      );

      if (response.status == true &&
          response.data != null &&
          response.data!.isNotEmpty) {
        setState(() {
          hasApplied = true;
          applicationData = response.data!.first;
          isLoading = false;
        });
        print("Full Response Data: ${response.data}");

      } else {
        setState(() {
          hasApplied = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              "Shiksha Sahayata",
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasApplied
          ? _buildAppliedView()
          : _buildApplyCard(),
    );
  }

  // ================= APPLICATION SUMMARY =================

  Widget _buildAppliedView() {
    final data = applicationData!;

    // Get first requested education
    final loan = data.requestedLoanEducationAppliedBy != null &&
        data.requestedLoanEducationAppliedBy!.isNotEmpty
        ? data.requestedLoanEducationAppliedBy!.first
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Application Summary",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // 🔥 Animated Status Badge
                      if (loan != null)
                        _buildLoanStatusBadge(loan.loanStatus),
                    ],
                  ),
                  const Divider(height: 20),

                  _infoRow("Applicant ID",
                      data.shikshaApplicantId ?? "-"),
                  _infoRow("Applicant Name",
                      data.fullName ?? "-"),
                  _infoRow("Applicant Mobile",
                      data.mobile ?? "-"),
                  _infoRow("Applicant Town",
                      data.applicantCityName ?? "-"),
                  _infoRow("Applicant State",
                      data.applicantStateName ?? "-"),
                  _infoRow("Applied Education",
                      loan?.standard ?? "-"),
                  // ✅ Sanctioned Amount (only if exists)
                  if (loan?.sanctionedAmount != null &&
                      loan!.sanctionedAmount!.isNotEmpty &&
                      loan.sanctionedAmount != "0")
                    _infoRow(
                      "Sanctioned Amount",
                      "₹ ${loan.sanctionedAmount}",
                    ),

                  if (loan?.disbursedAmount != null &&
                      loan!.disbursedAmount!.isNotEmpty &&
                      loan.disbursedAmount != "0")
                    _infoRow(
                      "Disbursed Amount",
                      "₹ ${loan.disbursedAmount}",
                    ),

                  if (loan?.disbursedOn != null &&
                      loan!.disbursedOn!.isNotEmpty)
                    _infoRow(
                      "Dispersal Date",
                      loan.disbursedOn!,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// Show apply card below summary
          _buildApplyCard(),
        ],
      ),
    );
  }

  Widget _buildLoanStatusBadge(String? status) {
    final loanStatus = (status ?? "pending").toLowerCase();

    Color bgColor;
    Color textColor;
    IconData icon;
    String displayText;

    switch (loanStatus) {

      case "sanctioned":
        bgColor = Colors.blue.withOpacity(0.15);
        textColor = Colors.blue;
        icon = Icons.verified;
        displayText = "SANCTIONED";
        break;

      case "disbursed":
        bgColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green;
        icon = Icons.payments;
        displayText = "DISBURSED";
        break;

      case "partially_repaid":
        bgColor = Colors.deepPurple.withOpacity(0.15);
        textColor = Colors.deepPurple;
        icon = Icons.autorenew;
        displayText = "PARTIALLY REPAID";
        break;

      case "fully_repaid":
        bgColor = Colors.teal.withOpacity(0.15);
        textColor = Colors.teal;
        icon = Icons.check_circle;
        displayText = "FULLY REPAID";
        break;

      case "pending":
      default:
        bgColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange;
        icon = Icons.hourglass_top;
        displayText = "PENDING";
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(loanStatus),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
            Text(
              displayText,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label)),
          const Text(": "),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ================= APPLY CARD =================

  Widget _buildApplyCard() {
    return Center(
      child: SizedBox(
        width: 320,
        child: Card(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ColorHelperClass.getColorFromHex(
                        ColorResources.red_color)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 42,
                    color: ColorHelperClass.getColorFromHex(
                        ColorResources.red_color),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Shiksha Sahayata",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "To apply for Shiksha Sahayata, click the Apply button below.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showInstructionDialog,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text("Apply"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInstructionDialog() {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Documents Required to complete your application",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Divider(color: Colors.grey),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please ensure the following documents are available with you before submit with the application.",
                style:
                TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 12),
              _bulletRichText(
                prefix: "Copy of ",
                bold: "Aadhar card",
              ),
              _bulletRichText(
                prefix: "Copy of ",
                bold:
                "Address proof (If Aadhar and current address are not the same)",
              ),
              _bulletRichText(
                prefix: "Copy of ",
                bold: "Father's PAN card",
              ),
              const SizedBox(height: 8),
              _bulletRichText(
                prefix:
                "Copy of ",
                bold: "Bonafide Certificate & Fees Structure by authority from college",
              ),
              _bulletRichText(
                prefix: "Copy of ",
                bold: "Marksheet starting from Class X",
              ),
              _bulletRichText(
                prefix: "Copy of ",
                bold: "Annual Income Proof",
              ),
              _bulletRichText(
                prefix: "Copy of ",
                bold: "Admission Letter",
              ),
            ],
          ),
          actions: [
            Center(
              child: SizedBox(
                width: 220,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  label: const Text(
                    "OK, Understood, Click to proceed",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    ).then((value) {
      if (!mounted) return;
      if (value == true) {
        _showShikshaDialog();
      }
    });
  }

  void _showShikshaDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Shiksha Sahayata",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Divider(color: Colors.grey),
            ],
          ),
          content: const Text(
            "Do you want to apply Shiksha Sahayata for?",
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                        context, RouteNames.shiksha_sahayata_by_yourself);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Your Self"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                        context, RouteNames.shiksha_sahayata_by_parenting);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Your Children"),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _bulletRichText({required String prefix, String? bold}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16, height: 1.4)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: prefix),
                  if (bold != null)
                    TextSpan(
                      text: bold,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
