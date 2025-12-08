import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class ApplicantDetail extends StatefulWidget {
  const ApplicantDetail({super.key});

  @override
  State<ApplicantDetail> createState() => _ApplicantDetailState();
}

class _ApplicantDetailState extends State<ApplicantDetail> {

  // TEMP STATIC DATA (Replace with real controller values later)
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
                color: ColorHelperClass.getColorFromHex(
                    ColorResources.logo_color),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  // _showAddApplicantDetailModalSheet(context);
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
          // Title and Colon
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
}
