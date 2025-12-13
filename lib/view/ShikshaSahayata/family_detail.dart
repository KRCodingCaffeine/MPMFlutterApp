import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class FamilyDetail extends StatefulWidget {
  const FamilyDetail({super.key});

  @override
  State<FamilyDetail> createState() => _FamilyDetailState();
}

class _FamilyDetailState extends State<FamilyDetail> {

  // Family Member Names
  final List<String> familyMembers = [
    "Kailash Maheshwari",
    "Shanti Maheshwari",
    "Ramesh Maheshwari",
    "Suresh Maheshwari",
    "Neha Maheshwari"
  ];

  // Family Job Details (Demo)
  final List<Map<String, dynamic>> familyJobDetails = [
    {
      "name": "Kailash Maheshwari",
      "job": "Business",
      "income": "₹8,00,000",
      "relation": "Father",
      "certificate": "assets/sample.pdf"
    },
    {
      "name": "Shanti Maheshwari",
      "job": "Housewife",
      "income": "₹0",
      "relation": "Mother",
      "certificate": ""
    },
    {
      "name": "Ramesh Maheshwari",
      "job": "Software Engineer",
      "income": "₹12,50,000",
      "relation": "Self",
      "certificate": "assets/sample.pdf"
    },
    {
      "name": "Suresh Maheshwari",
      "job": "CA",
      "income": "₹9,80,000",
      "relation": "Brother",
      "certificate": ""
    },
    {
      "name": "Neha Maheshwari",
      "job": "Student",
      "income": "₹0",
      "relation": "Sister",
      "certificate": ""
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          "Family Detail",
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [

              // ---------------------- FAMILY COUNT CARD ----------------------
              Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "No. of Family Members: ${familyMembers.length}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Divider(thickness: 1),
                      const SizedBox(height: 10),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: familyMembers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                Text(
                                  "${index + 1}. ",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    familyMembers[index],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------------- FAMILY JOB CARD ----------------------
              Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Family Job Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Divider(thickness: 1),
                      const SizedBox(height: 10),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: familyJobDetails.length,
                        itemBuilder: (context, index) {
                          final member = familyJobDetails[index];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                "${index + 1}. ${member["name"]}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              _buildJobRow("Job", member["job"]),
                              _buildJobRow("Relationship", member["relation"]),
                              _buildJobRow("Yearly Income", member["income"]),

                              // Income Certificate Button
                              Row(
                                children: [
                                  const Text(
                                    "Income Certificate:",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 10),

                                  member["certificate"] != ""
                                      ? ElevatedButton(
                                    onPressed: () {
                                      // TODO: open income certificate
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                    child: const Text("View"),
                                  )
                                      : const Text(
                                    "Not Uploaded",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  )
                                ],
                              ),

                              const SizedBox(height: 14),
                              const Divider(height: 1),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$title:",
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
