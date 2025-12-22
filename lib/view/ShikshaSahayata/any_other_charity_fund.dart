import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class AnyOtherCharityFundView extends StatefulWidget {
  const AnyOtherCharityFundView({super.key});

  @override
  State<AnyOtherCharityFundView> createState() =>
      _AnyOtherCharityFundViewState();
}

class _AnyOtherCharityFundViewState extends State<AnyOtherCharityFundView> {
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
              "Current Year: Any Other Loan Applied",
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
          "No other charity / loan added",
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: charityList.length,
        itemBuilder: (context, index) {
          final item = charityList[index];

          return Card(
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
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController amountCtrl = TextEditingController();
    final TextEditingController dateCtrl = TextEditingController();

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
                heightFactor: 0.65,
                child: Column(
                  children: [
                    /// 🔹 TOP ACTION BAR
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
                            onPressed: nameCtrl.text.isEmpty ||
                                amountCtrl.text.isEmpty ||
                                dateCtrl.text.isEmpty
                                ? null
                                : () {
                              setState(() {
                                charityList.add({
                                  "name": nameCtrl.text,
                                  "amount": amountCtrl.text,
                                  "date": dateCtrl.text,
                                });
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Other charity added successfully"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              ColorHelperClass.getColorFromHex(
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
                                "Current Year: Any Other Loan Applied",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            _buildTextField(
                              label: "Charity Name *",
                              controller: nameCtrl,
                            ),
                            const SizedBox(height: 20),

                            _buildTextField(
                              label: "Amount *",
                              controller: amountCtrl,
                              keyboard: TextInputType.number,
                            ),
                            const SizedBox(height: 20),

                            _buildDatePickerField(
                              context: context,
                              label: "Date Sanctioned *",
                              controller: dateCtrl,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("All charity details completed"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
              ),
              child: const Text("Next"),
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
      onChanged: (_) => setState(() {}),
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
