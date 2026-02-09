import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/reference.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/previous_year_loan.dart';

class CurrentYearAnyOtherLoan extends StatefulWidget {
  final String shikshaApplicantId;

  const CurrentYearAnyOtherLoan({
    Key? key,
    required this.shikshaApplicantId,
  }) : super(key: key);

  @override
  State<CurrentYearAnyOtherLoan> createState() =>
      _CurrentYearAnyOtherLoanState();
}

class _CurrentYearAnyOtherLoanState extends State<CurrentYearAnyOtherLoan> {
  final List<Map<String, String>> charityList = [];

  @override
  void initState() {
    super.initState();

    /// 🔹 Auto open add form on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAddCharitySheet(context);
    });
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
              "Current Year Loan Applied / Received Elsewhere",
              maxLines: 2,
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

      /// 🔹 BODY
      body: charityList.isEmpty
          ? const Center(
              child: Text(
                " No Current Year Loan Applied / Received Elsewhere added Yet",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: charityList.length,
              itemBuilder: (context, index) {
                final item = charityList[index];

                return Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow("Charity Name", item["name"]!),
                        _infoRow("Amount", "₹ ${item["amount"]}"),
                        _infoRow("Date", item["date"]!),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            ),

      /// 🔹 BOTTOM NEXT BAR
      bottomNavigationBar:
          charityList.isNotEmpty ? _buildBottomNextBar() : null,
    );
  }

  // ===================== ADD CHARITY BOTTOM SHEET =====================

  void _showAddCharitySheet(BuildContext context) {
    String selectedLoanFrom = '';

    final TextEditingController loanFromCtrl = TextEditingController();
    final TextEditingController otherCharityCtrl = TextEditingController();
    final TextEditingController schoolCtrl = TextEditingController();
    final TextEditingController courseCtrl = TextEditingController();
    final TextEditingController whichYearCtrl = TextEditingController();
    final TextEditingController amountCtrl = TextEditingController();
    final TextEditingController receivedOnCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.8,
                child: Column(
                  children: [
                    /// 🔹 TOP BAR
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              side: BorderSide(
                                color: ColorHelperClass.getColorFromHex(
                                    ColorResources.red_color),
                              ),
                            ),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: selectedLoanFrom.isEmpty ||
                                    schoolCtrl.text.isEmpty ||
                                    courseCtrl.text.isEmpty ||
                                    whichYearCtrl.text.isEmpty ||
                                    amountCtrl.text.isEmpty ||
                                    receivedOnCtrl.text.isEmpty ||
                                    (selectedLoanFrom == "OTHER" &&
                                        otherCharityCtrl.text.isEmpty)
                                ? null
                                : () {
                                    final loanFromValue =
                                        selectedLoanFrom == "MPM"
                                            ? "Maheshwari Pragati Mandal (MPM)"
                                            : otherCharityCtrl.text;

                                    setState(() {
                                      charityList.add({
                                        "loanFrom": loanFromValue,
                                        "school": schoolCtrl.text,
                                        "course": courseCtrl.text,
                                        "whichYear": whichYearCtrl.text,
                                        "amount": amountCtrl.text,
                                        "receivedOn": receivedOnCtrl.text,
                                      });
                                    });

                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Current Year Loan Submitted Successfully"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Submit"),
                          ),
                        ],
                      ),
                    ),

                    /// 🔹 FORM CONTENT
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(
                              child: Text(
                                "Current Year Loan Received",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            /// 🔹 LOAN RECEIVED FROM DROPDOWN
                            InputDecorator(
                              decoration:
                                  _inputDecoration("Loan Received From *"),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                underline: const SizedBox(),
                                value: selectedLoanFrom.isEmpty
                                    ? null
                                    : selectedLoanFrom,
                                hint: const Text("Select Option"),
                                items: const [
                                  DropdownMenuItem(
                                    value: "MPM",
                                    child:
                                        Text("Maheshwari Pragati Mandal (MPM)"),
                                  ),
                                  DropdownMenuItem(
                                    value: "OTHER",
                                    child: Text("Other Charity Name"),
                                  ),
                                ],
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedLoanFrom = value!;
                                    otherCharityCtrl.clear();
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// 🔹 SHOW TEXT FIELD IF OTHER SELECTED
                            if (selectedLoanFrom == "OTHER") ...[
                              TextFormField(
                                controller: otherCharityCtrl,
                                decoration: _inputDecoration(
                                    "Enter Other Charity Name *"),
                              ),
                              const SizedBox(height: 20),
                            ],

                            _buildTextField(
                              label: "School / College *",
                              controller: schoolCtrl,
                            ),
                            const SizedBox(height: 20),

                            _buildTextField(
                              label: "Course Name *",
                              controller: courseCtrl,
                            ),
                            const SizedBox(height: 20),

                            /// 🔥 MONTH / YEAR FIELD
                            themedMonthYearPickerField(
                              context: context,
                              label: "Which Year (Month / Year) *",
                              controller: whichYearCtrl,
                            ),
                            const SizedBox(height: 20),

                            _buildTextField(
                              label: "Amount Received (₹) *",
                              controller: amountCtrl,
                              keyboard: TextInputType.number,
                            ),
                            const SizedBox(height: 20),

                            /// 🔥 DATE PICKER
                            themedDatePickerField(
                              context: context,
                              label: "Amount Received On *",
                              controller: receivedOnCtrl,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===================== HELPERS =====================

  Widget _buildBottomNextBar() {
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
                "Once you complete this detail, click Next to proceed.",
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtherCharityFundView(
                      shikshaApplicantId: widget.shikshaApplicantId,
                    ),
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Current Year Any Other Loan Applied Submitted Successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
              ),
              child: const Text("Submit"),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          const Text(": "),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black38, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        labelStyle: const TextStyle(color: Colors.black),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget themedMonthYearPickerField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      readOnly: true,
      controller: controller,
      decoration: _inputDecoration(label),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          helpText: "Select Month & Year",
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: ColorHelperClass.getColorFromHex(
                      ColorResources.red_color),
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          controller.text =
              "${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        }
      },
    );
  }

  Widget themedDatePickerField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      readOnly: true,
      controller: controller,
      decoration: _inputDecoration(label),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: ColorHelperClass.getColorFromHex(
                      ColorResources.red_color),
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          controller.text = "${picked.day}/${picked.month}/${picked.year}";
        }
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black38, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      labelStyle: const TextStyle(color: Colors.black),
    );
  }
}
