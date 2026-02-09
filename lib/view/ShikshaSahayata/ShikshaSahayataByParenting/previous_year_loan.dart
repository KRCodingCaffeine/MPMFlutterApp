import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/current_year_any_other_loan.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/reference.dart';

class OtherCharityFundView extends StatefulWidget {
  final String shikshaApplicantId;

  const OtherCharityFundView({
    Key? key,
    required this.shikshaApplicantId,
  }) : super(key: key);

  @override
  State<OtherCharityFundView> createState() => _OtherCharityFundViewState();
}

class _OtherCharityFundViewState extends State<OtherCharityFundView> {
  String hasOtherCharity = '';
  final List<Map<String, dynamic>> charityList = [];

  final TextEditingController charityNameCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController();

  bool get isYesFormValid {
    return charityNameCtrl.text.trim().isNotEmpty &&
        amountCtrl.text.trim().isNotEmpty &&
        dateCtrl.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOtherCharitySheet(context);
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
              "Received Loan in Past",
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
      body: charityList.isEmpty
          ? const Center(
              child: Text(
                "No Received Loan in Past added yet",
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
                        _infoRow("Charity Name", item["name"]),
                        _infoRow("Amount", "₹ ${item["amount"]}"),
                        _infoRow("Date", item["date"]),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar:
          hasOtherCharity.isNotEmpty ? _buildBottomNextBar() : null,
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
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
            Expanded(
              child: Text(
                "Once you complete this detail, click Submit to proceed.",
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MPMView(
                      shikshaApplicantId: widget.shikshaApplicantId,
                    ),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Received Loan in Past details submitted successfully"),
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

  void _showOtherCharitySheet(BuildContext context) {
    String selectedLoanFrom = '';

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
                                            "Previous Year Loan Details Saved Successfully"),
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

                    /// 🔹 FORM
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(
                              child: Text(
                                "Previous Year Loan Details",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            /// 🔹 LOAN RECEIVED FROM
                            InputDecorator(
                              decoration:
                                  _inputDecoration("Loan Received From *"),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                underline: const SizedBox(),
                                value: selectedLoanFrom.isEmpty
                                    ? null
                                    : selectedLoanFrom,
                                hint: const Text("Select"),
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

                            if (selectedLoanFrom == "OTHER") ...[
                              TextFormField(
                                controller: otherCharityCtrl,
                                decoration: _inputDecoration(
                                    "Enter Other Charity Name *"),
                              ),
                              const SizedBox(height: 20),
                            ],

                            /// 🔹 SCHOOL
                            TextFormField(
                              controller: schoolCtrl,
                              decoration:
                                  _inputDecoration("School / College Name *"),
                            ),
                            const SizedBox(height: 20),

                            /// 🔹 COURSE
                            TextFormField(
                              controller: courseCtrl,
                              decoration: _inputDecoration("Course Name *"),
                            ),
                            const SizedBox(height: 20),

                            /// 🔹 WHICH YEAR
                            themedMonthYearPickerField(
                              context: context,
                              label: "Which Year *",
                              controller: whichYearCtrl,
                            ),
                            const SizedBox(height: 20),

                            /// 🔹 AMOUNT
                            TextFormField(
                              controller: amountCtrl,
                              keyboardType: TextInputType.number,
                              decoration:
                                  _inputDecoration("Amount Received (₹) *"),
                            ),
                            const SizedBox(height: 20),

                            /// 🔹 DATE PICKER
                            themedDatePickerField(
                              context: context,
                              label: "Amount Received On *",
                              controller: receivedOnCtrl,
                            ),

                            const SizedBox(height: 30),
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
