import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/any_other_charity_fund.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/mpm.dart';

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
              "Past Year: Loans Avail",
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
          "No Past Year Loans Avail added",
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
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => MPMView(
                      shikshaApplicantId: widget.shikshaApplicantId,
                    ),
                  ),                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Past Year Loans Avail details submitted successfully"),
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
                heightFactor: 0.4,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                              ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              side: BorderSide(
                                color: ColorHelperClass.getColorFromHex(
                                    ColorResources.red_color),
                              ),
                            ),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: hasOtherCharity.isEmpty
                                ? null
                                : (hasOtherCharity == "Yes" && !isYesFormValid)
                                ? null
                                : () {
                              Navigator.pop(context);

                              // 🔹 NO → Navigate
                              if (hasOtherCharity == "No") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Other charity details submitted successfully"),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AnyOtherCharityFundView(
                                      shikshaApplicantId: widget.shikshaApplicantId,
                                    ),
                                  ),
                                );
                                return;
                              }

                              // 🔹 YES → Save as Card
                              setState(() {
                                charityList.add({
                                  "name": charityNameCtrl.text,
                                  "amount": amountCtrl.text,
                                  "date": dateCtrl.text,
                                });

                                hasOtherCharity = "Yes";

                                charityNameCtrl.clear();
                                amountCtrl.clear();
                                dateCtrl.clear();
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Charity details saved successfully"),
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

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(
                              child: Text(
                                "Past Year: Loans Avail",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            InputDecorator(
                              decoration: InputDecoration(
                                labelText:
                                'Do you have any other past loan? *',
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black38, width: 1),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                labelStyle:
                                const TextStyle(color: Colors.black),
                              ),
                              child: DropdownButton<String>(
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                isExpanded: true,
                                underline: Container(),
                                value: hasOtherCharity.isEmpty
                                    ? null
                                    : hasOtherCharity,
                                hint: const Text("Select option"),
                                items: const [
                                  DropdownMenuItem(
                                    value: "Yes",
                                    child: Text("Yes"),
                                  ),
                                  DropdownMenuItem(
                                    value: "No",
                                    child: Text("No"),
                                  ),
                                ],
                                  onChanged: (val) {
                                    if (val == null) return;

                                    setModalState(() {
                                      hasOtherCharity = val;
                                    });
                                    setState(() {});
                                  },

                              ),
                            ),

                            if (hasOtherCharity == "Yes") ...[
                              const SizedBox(height: 20),

                              _buildTextField(
                                label: "Charity Name *",
                                controller: charityNameCtrl,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),

                              _buildTextField(
                                label: "Amount Contributed *",
                                controller: amountCtrl,
                                keyboard: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),

                              _buildDatePickerField(
                                context: context,
                                label: "Date Sanctioned *",
                                controller: dateCtrl,
                              ),
                              const SizedBox(height: 20),

                            ],
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
    String? hint,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    ValueChanged<String>? onChanged,

  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border:
        const OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.black),
        ),
        enabledBorder:
        const OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.black),
        ),
        focusedBorder:
        const OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.black38,
              width: 1),
        ),
        contentPadding:
        const EdgeInsets.symmetric(
            horizontal: 20),
        labelStyle: const TextStyle(
            color: Colors.black),
      ),
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      readOnly: true,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border:
        const OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.black),
        ),
        enabledBorder:
        const OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.black),
        ),
        focusedBorder:
        const OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.black38,
              width: 1),
        ),
        contentPadding:
        const EdgeInsets.symmetric(
            horizontal: 20),
        labelStyle: const TextStyle(
            color: Colors.black),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
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
          controller.text =
          "${picked.day}/${picked.month}/${picked.year}";
          setState(() {});
        }
      },
    );
  }

}