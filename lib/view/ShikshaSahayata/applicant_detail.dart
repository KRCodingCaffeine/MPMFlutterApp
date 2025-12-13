import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class ApplicantDetail extends StatefulWidget {
  const ApplicantDetail({super.key});

  @override
  State<ApplicantDetail> createState() => _ApplicantDetailState();
}

class _ApplicantDetailState extends State<ApplicantDetail> {
  final String fullName = "Ramesh K. Maheshwari";
  final String mobile = "9876543210";
  final String email = "demo@gmail.com";
  final String dob = "12-08-1995";
  final String age = "23";
  final String gender = "Male";
  final String maritalStatus = "Married";
  final String anniversary = "14-02-2020";
  final String aadhar = "XXXX XXXX 1234";

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
              "Applicant Detail",
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color:
                    ColorHelperClass.getColorFromHex(ColorResources.logo_color),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  _showAddApplicantDetailModalSheet(context);
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoBox("Full Name", subtitle: fullName),
                    const SizedBox(height: 20),
                    _buildInfoBox("Email", subtitle: email),
                    const SizedBox(height: 20),
                    _buildInfoBox("Mobile Number", subtitle: mobile),
                    const SizedBox(height: 20),
                    _buildInfoBox("Gender", subtitle: gender),
                    const SizedBox(height: 20),
                    _buildInfoBox("Date of Birth", subtitle: dob),
                    const SizedBox(height: 20),
                    _buildInfoBox("Age", subtitle: age),
                    const SizedBox(height: 20),
                    _buildInfoBox("Marital Status", subtitle: maritalStatus),
                    const SizedBox(height: 20),
                    maritalStatus.toLowerCase() == "unmarried"
                        ? const SizedBox()
                        : Column(
                            children: [
                              _buildInfoBox("Anniversary Date",
                                  subtitle: anniversary),
                              const SizedBox(height: 20),
                            ],
                          ),
                    _buildInfoBox("Aadhar Number", subtitle: aadhar),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 105,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Text(
                  ':',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          // Subtitle
          Expanded(
            child: subtitle != null
                ? Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showAddApplicantDetailModalSheet(BuildContext context) {
    double heightFactor = 0.85;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: heightFactor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Save"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          _buildTextField("Full Name"),
                          const SizedBox(height: 20),

                          _buildTextField("Email"),
                          const SizedBox(height: 20),

                          _buildTextField("Mobile Number",
                              keyboard: TextInputType.number),
                          const SizedBox(height: 20),

                          _buildDropdown("Gender", ["Male", "Female", "Other"]),
                          const SizedBox(height: 20),

                          _buildDatePicker("Date of Birth"),
                          const SizedBox(height: 20),

                          _buildTextField("Age",
                              keyboard: TextInputType.number),
                          const SizedBox(height: 20),

                          _buildDropdown(
                              "Marital Status", ["Married", "Unmarried"]),
                          const SizedBox(height: 20),

                          // Show anniversary only if married
                          _buildDatePicker("Anniversary Date"),
                          const SizedBox(height: 20),

                          _buildTextField("Aadhar Number",
                              keyboard: TextInputType.number),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label,
      {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    String? selectedValue;

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      value: selectedValue,
      items: items.map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(e),
        );
      }).toList(),
      onChanged: (val) {
        setState(() => selectedValue = val);
      },
    );
  }

  Widget _buildDatePicker(String label) {
    TextEditingController controller = TextEditingController();

    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        suffixIcon: const Icon(Icons.calendar_month),
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (picked != null) {
          controller.text = "${picked.day}/${picked.month}/${picked.year}";
        }
      },
    );
  }
}
