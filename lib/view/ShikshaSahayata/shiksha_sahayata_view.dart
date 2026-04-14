import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/LoanRepayment.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplicationsByAppliedBy/ShikshaApplicationsByAppliedByData.dart';
import 'package:mpm/repository/ShikshaSahayataRepo/ShikshaApplicationsAppliedByRepo/shiksha_applications_applied_by_repository/shiksha_application_applied_by_repository.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataDetail/shiksha_sahayata_detail_view.dart';
import 'package:mpm/view/payment/ShikshaPaymentScreen.dart';

class ShikshaSahayataView extends StatefulWidget {
  const ShikshaSahayataView({super.key});

  @override
  State<ShikshaSahayataView> createState() => _ShikshaSahayataViewState();
}

class _ShikshaSahayataViewState extends State<ShikshaSahayataView> {
  final ShikshaApplicationsByAppliedByRepository _repo =
      ShikshaApplicationsByAppliedByRepository();

  bool isLoading = true;
  bool hasApplied = false;

  List<ShikshaApplicationsByAppliedByData> applicationList = [];

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

      final response = await _repo.fetchShikshaApplicationsByAppliedBy(
        appliedBy: memberId,
      );

      if (response.status == true &&
          response.data != null &&
          response.data!.isNotEmpty) {
        setState(() {
          hasApplied = true;
          applicationList = response.data!;
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
        actions: hasApplied
            ? [
                TextButton.icon(
                  onPressed: _showInstructionDialog,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    "Apply",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: Colors.redAccent,
              onRefresh: _handleRefresh,
              child: hasApplied
                  ? _buildAppliedView()
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: _buildApplyCard(),
                      ),
                    ),
            ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isLoading = true;
    });

    await _checkApplicationStatus();
  }

  Widget _buildAppliedView() {
    if (applicationList.isEmpty) {
      return const Center(
        child: Text("No applications found"),
      );
    }

    final firstLoan = applicationList.first.requestedLoanEducationAppliedBy !=
                null &&
            applicationList.first.requestedLoanEducationAppliedBy!.isNotEmpty
        ? applicationList.first.requestedLoanEducationAppliedBy!.first
        : null;

    final isDisbursed = firstLoan?.loanStatus?.toLowerCase() == "disbursed";

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!isDisbursed) _applicationInfoCard(false),
        if (!isDisbursed) const SizedBox(height: 16),
        ...applicationList.map((data) {
          final loan = data.requestedLoanEducationAppliedBy != null &&
                  data.requestedLoanEducationAppliedBy!.isNotEmpty
              ? data.requestedLoanEducationAppliedBy!.first
              : null;
          final loanStatus = loan?.loanStatus?.toLowerCase() ?? "";
          final shouldShowPayNow = (loanStatus == "disbursed" ||
                  loanStatus == "partially_repaid") &&
              loanStatus != "fully_repaid";

          final repayment =
              data.loanRepayments != null && data.loanRepayments!.isNotEmpty
                  ? data.loanRepayments!.first
                  : null;
          final payableAmount = _getPayableAmount(
            loanAmount: repayment?.loanAmount,
            disbursedAmount: loan?.disbursedAmount,
            repayments: data.loanRepayments,
          );

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShikshaSahayataDetailView(
                    shikshaApplicantId: data.shikshaApplicantId ?? "",
                    applicationData: data,
                  ),
                ),
              );
            },
            child: Card(
              color: Colors.white,
              elevation: 6,
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Loan Summary",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (loan != null)
                          _buildLoanStatusBadge(loan.loanStatus),
                      ],
                    ),
                    const Divider(height: 20),
                    _infoRow("Applicant ID", data.shikshaApplicantId ?? "-"),
                    _infoRow("Applicant Name", data.fullName ?? "-"),
                    _infoRow("Applicant Mobile", data.mobile ?? "-"),
                    _infoRow("Applicant Town", data.applicantCityName ?? "-"),
                    _infoRow("Applicant State", data.applicantStateName ?? "-"),
                    _infoRow("Applied Education", loan?.standard ?? "-"),
                    _infoRow(
                      "Applied By",
                      data.appliedByFullName ?? "-",
                    ),
                    _infoRow(
                      "Applied On",
                      data.createdAt != null && data.createdAt!.isNotEmpty
                          ? _formatDateTime(data.createdAt!)
                          : "-",
                    ),
                    if (loan?.sanctionedAmount != null &&
                        loan!.sanctionedAmount!.isNotEmpty &&
                        loan.sanctionedAmount != "0")
                      _infoRow(
                        "Loan Sanctioned",
                        "₹ ${loan.sanctionedAmount}",
                      ),
                    if (loan?.disbursedAmount != null &&
                        loan!.disbursedAmount!.isNotEmpty &&
                        loan.disbursedAmount != "0")
                      _infoRow(
                        "Loan Disbursed",
                        "₹ ${loan.disbursedAmount}",
                      ),
                    if (loan?.disbursedOn != null &&
                        loan!.disbursedOn!.isNotEmpty)
                      _infoRow(
                        "Disbursed on",
                        _formatDateTime(loan.disbursedOn!),
                      ),
                    if (shouldShowPayNow ||
                        (data.loanRepayments != null &&
                            data.loanRepayments!.isNotEmpty))
                      Builder(
                        builder: (_) {
                          final themeColor = ColorHelperClass.getColorFromHex(
                              ColorResources.logo_color);
                          final sortedRepayments = data.loanRepayments != null
                              ? [...data.loanRepayments!]
                              : <LoanRepayment>[];
                          sortedRepayments.sort((a, b) {
                            final dateA =
                                DateTime.tryParse(a.createdAt ?? '') ??
                                    DateTime(1900);
                            final dateB =
                                DateTime.tryParse(b.createdAt ?? '') ??
                                    DateTime(1900);

                            return dateB.compareTo(dateA); // latest first
                          });

                          final hasRepayments = sortedRepayments.isNotEmpty;
                          if (!hasRepayments) {
                            sortedRepayments.add(
                              LoanRepayment(
                                loanRepaymentAmount: "0",
                                loanRepaymentDate: null,
                                loanRepaymentRemarks: "",
                              ),
                            );
                          }

                          final latestRepayment = sortedRepayments.first;

                          final totalRepaid =
                              _calculateTotalRepaid(data.loanRepayments);

                          final remaining = _calculateRemainingAmount(
                              repayment?.loanAmount, data.loanRepayments);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Repayment Details",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _infoRow("Total Repaid",
                                  "₹ ${totalRepaid.toStringAsFixed(0)}"),
                              _infoRow("Remaining Amount",
                                  "₹ ${remaining.toStringAsFixed(0)}"),
                              if (shouldShowPayNow && payableAmount != null) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          ColorHelperClass.getColorFromHex(
                                        ColorResources.red_color,
                                      ),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      _showRepaymentAmountDialog(
                                        context,
                                        maxAmount: payableAmount,
                                      );
                                    },
                                    icon: const Icon(Icons.payments_outlined),
                                    label: const Text(
                                      "Pay Now",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade50,
                                      Colors.green.shade100,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: Colors.green.shade300),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: const [
                                            Icon(Icons.payments,
                                                color: Colors.green, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              "Latest Repayment",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (hasRepayments)
                                          GestureDetector(
                                            onTap: () {
                                              _showRepaymentBottomSheet(
                                                context,
                                                data.loanRepayments!,
                                                repayment?.loanAmount,
                                              );
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: themeColor
                                                    .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                border: Border.all(
                                                  color: themeColor
                                                      .withOpacity(0.4),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "View All",
                                                    style: TextStyle(
                                                      color: themeColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 12,
                                                    color: themeColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        else
                                          const SizedBox.shrink(),
                                      ],
                                    ),
                                    const Divider(height: 18),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Paid Amount",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          "₹ ${latestRepayment.loanRepaymentAmount}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Payment Date",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          latestRepayment.loanRepaymentDate !=
                                                  null
                                              ? _formatDateTime(latestRepayment
                                                  .loanRepaymentDate!)
                                              : "-",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (latestRepayment.loanRepaymentRemarks !=
                                            null &&
                                        latestRepayment
                                            .loanRepaymentRemarks!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          "Remarks: ${latestRepayment.loanRepaymentRemarks}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  String _formatDateTime(String rawDate) {
    try {
      final parsed = DateTime.parse(rawDate);
      // return DateFormat("dd MMM yyyy, hh:mm a").format(parsed);
      return DateFormat("dd MMM yyyy").format(parsed);
    } catch (e) {
      return rawDate;
    }
  }

  double _calculateTotalRepaid(List<LoanRepayment>? repayments) {
    if (repayments == null || repayments.isEmpty) return 0;

    return repayments.fold(0, (sum, item) {
      final amount = double.tryParse(item.loanRepaymentAmount ?? "0") ?? 0;
      return sum + amount;
    });
  }

  double _calculateRemainingAmount(
      String? loanAmount, List<LoanRepayment>? repayments) {
    final totalLoan = double.tryParse(loanAmount ?? "0") ?? 0;
    final totalRepaid = _calculateTotalRepaid(repayments);
    return totalLoan - totalRepaid;
  }

  String? _getPayableAmount({
    String? loanAmount,
    String? disbursedAmount,
    List<LoanRepayment>? repayments,
  }) {
    final remainingAmount = _calculateRemainingAmount(loanAmount, repayments);
    if (remainingAmount > 0) {
      return remainingAmount.toStringAsFixed(0);
    }

    final disbursed = double.tryParse(disbursedAmount ?? "0") ?? 0;
    if (disbursed > 0) {
      return disbursed.toStringAsFixed(0);
    }

    return null;
  }

  void _showRepaymentAmountDialog(
    BuildContext context, {
    required String maxAmount,
  }) {
    String enteredAmount = "";

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Repayment",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter repayment amount",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  onChanged: (value) {
                    enteredAmount = value.trim();
                  },
                  decoration: InputDecoration(
                    hintText: "Enter amount",
                    helperText: "Maximum: Rs. $maxAmount",
                    prefixText: "Rs. ",
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(enteredAmount);
                final maximum = double.tryParse(maxAmount);

                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid repayment amount."),
                    ),
                  );
                  return;
                }

                if (maximum != null && amount > maximum) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Repayment amount cannot be more than Rs. $maxAmount.",
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShikshaPaymentScreen(
                      paymentAmount: enteredAmount,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Pay"),
            ),
          ],
        );
      },
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

  void _showRepaymentBottomSheet(
      BuildContext context,
      List<LoanRepayment> repayments,
      String? loanAmount,
      ) {
    // Sort latest first
    repayments.sort((a, b) {
      final dateA =
          DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1900);
      final dateB =
          DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1900);
      return dateB.compareTo(dateA);
    });

    final totalRepaid = _calculateTotalRepaid(repayments);
    final remaining = _calculateRemainingAmount(loanAmount, repayments);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade400,
                      Colors.green.shade600,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Repayment History",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.close,
                            size: 18,
                            color: Colors.black87),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        title: "Total Repaid",
                        amount:
                        "₹ ${totalRepaid.toStringAsFixed(0)}",
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        title: "Remaining",
                        amount:
                        "₹ ${remaining.toStringAsFixed(0)}",
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: repayments.length,
                    itemBuilder: (context, index) {
                      final repayment = repayments[index];

                      return Container(
                        margin:
                        const EdgeInsets.only(bottom: 14),
                        padding:
                        const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius:
                          BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05),
                              blurRadius: 6,
                              offset:
                              const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  repayment.loanRepaymentDate !=
                                      null
                                      ? _formatDateTime(
                                      repayment
                                          .loanRepaymentDate!)
                                      : "-",
                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                    height: 4),
                                const Text(
                                  "Repayment Date",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                    Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "₹ ${repayment.loanRepaymentAmount}",
                              style:
                              const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.bold,
                                color:
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCard({
    required String title,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _applicationInfoCard(bool isDisbursed) {
    return Card(
      color: isDisbursed ? Colors.red.shade50 : Colors.orange.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDisbursed ? Colors.red.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isDisbursed ? Icons.lock : Icons.edit_note,
              size: 18,
              color: isDisbursed ? Colors.red : Colors.orange,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isDisbursed
                    ? "This application has been disbursed. You can no longer edit or upload documents."
                    : "If you want to edit or upload your details, please complete it before disbursal. Once disbursed, editing will not be allowed.",
                style: TextStyle(
                  fontSize: 13,
                  color: isDisbursed ? Colors.red : Colors.orange.shade800,
                  fontWeight: FontWeight.w500,
                ),
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
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
    showDialog(
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

          // 🔹 TITLE
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mandatory Documents Required",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Divider(color: Colors.grey),
                  ],
                ),
              ),

              // ❌ Close Icon
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          // 🔹 CONTENT
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Please ensure that soft copies of following documents are ready before proceeding further:",
                  style: TextStyle(fontSize: 15, height: 1.4),
                ),

                const SizedBox(height: 16),

                // ✅ DOMESTIC
                const Text(
                  "Domestic Application",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 10),

                _bulletRichText(text: "Applicant Aadhar Card"),
                _bulletRichText(
                    text:
                    "Address Proof (If Aadhar and current address are not the same)"),
                _bulletRichText(text: "Marksheet starting from Class X"),
                _bulletRichText(text: "Father's Annual Income Proof"),
                _bulletRichText(text: "Bonafide Certificate / Fees Structure"),
                _bulletRichText(text: "Father's PAN Card"),
                _bulletRichText(text: "Admission Letter"),

                const SizedBox(height: 16),

                // ✅ DIVIDER
                const Center(
                  child: Text(
                    "---------------- OR ----------------",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ OVERSEAS
                const Text(
                  "Overseas Application",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 10),

                _bulletRichText(text: "Passport"),
                _bulletRichText(text: "Visa"),
                _bulletRichText(text: "Flight Ticket"),
                _bulletRichText(text: "Applicant Annual Income Proof (Last 3 years of ITR Returns)"),
                _bulletRichText(text: "Applicant Father's Annual Income Proof (Last 3 years of ITR Returns)"),
              ],
            ),
          ),

          // 🔹 BUTTON
          actions: [
            Center(
              child: SizedBox(
                width: 240,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    // clear storage
                    // (if using shared prefs instead of localStorage in Flutter)

                    Navigator.pushNamed(
                      context,
                      RouteNames.shiksha_sahayata_by_yourself,
                    );
                  },
                  child: const Text(
                    "I Understand & Continue",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // void _showShikshaDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(15),
  //         ),
  //         titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
  //         contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
  //         actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
  //         title: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: const [
  //             Text(
  //               "Shiksha Sahayata",
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             SizedBox(height: 8),
  //             Divider(color: Colors.grey),
  //           ],
  //         ),
  //         content: const Text(
  //           "Do you want to apply Shiksha Sahayata for?",
  //           style: TextStyle(fontSize: 16, color: Colors.black87),
  //         ),
  //         actions: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               OutlinedButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   Navigator.pushNamed(
  //                       context, RouteNames.shiksha_sahayata_by_yourself);
  //                 },
  //                 style: OutlinedButton.styleFrom(
  //                   side: const BorderSide(color: Colors.red),
  //                   foregroundColor: Colors.red,
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 22, vertical: 12),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                 ),
  //                 child: const Text("Your Self"),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   Navigator.pushNamed(
  //                       context, RouteNames.shiksha_sahayata_by_parenting);
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.red,
  //                   foregroundColor: Colors.white,
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 22, vertical: 12),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                 ),
  //                 child: const Text("Your Children"),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 12),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _bulletRichText({required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16, height: 1.4)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

