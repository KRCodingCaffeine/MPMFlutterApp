import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class FamilyDetail extends StatefulWidget {
  const FamilyDetail({super.key});

  @override
  State<FamilyDetail> createState() => _FamilyDetailState();
}

class _FamilyDetailState extends State<FamilyDetail> {
  int familyCount = 0;
  bool countSubmitted = false;
  bool jobDetailsSubmitted = false;
  final List<String> familyMembers = [];

  String selectedFamilyMember = '';
  final List<String> availableFamilyMembers = [
    "Rajesh Nair",
    "Karthika Rajesh",
    "Manoj Kumar Murugan",
    "Jeshwanth Karthick",
  ];

  String selectedRelation = '';
  final List<String> relationOptions = [
    "Father",
    "Mother",
    "Self",
    "Spouse",
    "Brother",
    "Sister",
    "Son",
    "Daughter",
    "Other",
  ];

  final TextEditingController familyCountCtrl = TextEditingController();

  final List<Map<String, String>> familyJobs = [];

  @override
  void initState() {
    super.initState();

    /// Auto open family count form for new application
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!countSubmitted) {
        _showFamilyCountSheet(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text(
          "Family Detail",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: countSubmitted
          ? _buildFamilySummary()
          : const Center(
        child: Text(
          "No family details added",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  // ================= FAMILY SUMMARY =================

  Widget _buildFamilySummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// Family Count Card
          buildFamilyMembersCard(familyMembers),
          const SizedBox(height: 20),

          /// Job Details Card
            buildFamilyJobDetailCard(familyJobs),
        ],
      ),
    );
  }

  Widget buildFamilyMembersCard(List<String> familyMembers) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "No. of Family Members: ${familyMembers.length}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    _showFamilyCountSheet(context);
                  },
                  label: const Text("Add Member"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorHelperClass.getColorFromHex(
                        ColorResources.red_color),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 12),
            const Divider(thickness: 1),
            const SizedBox(height: 10),

            familyMembers.isEmpty
                ? const Text(
              "No family members added",
              style: TextStyle(color: Colors.grey),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: familyMembers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
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
    );
  }

  Widget buildFamilyJobDetailCard(
      List<Map<String, dynamic>> familyJobDetails,
      ) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                  "Family Job Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    _showFamilyJobSheet(context);
                  },
                  label: const Text(
                    "Add Job Detail",
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    ColorHelperClass.getColorFromHex(
                        ColorResources.red_color),
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(thickness: 1),
            const SizedBox(height: 10),

            familyJobDetails.isEmpty
                ? const Text(
              "No family members job details added yet!",
              style: TextStyle(color: Colors.grey),
            )
                : ListView.builder(
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

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Text(
                          "Income Certificate:",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),

                        member["certificate"] != null &&
                            member["certificate"]
                                .toString()
                                .isNotEmpty
                            ? ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            "View",
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                            : const Text(
                          "Not Uploaded",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
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
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FAMILY COUNT SHEET =================

  void _showFamilyCountSheet(BuildContext context) {
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  children: [
                    Row(
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
                          onPressed: selectedFamilyMember.isEmpty
                              ? null
                              : () {
                            setState(() {
                              familyMembers.add(selectedFamilyMember);
                              countSubmitted = true;
                            });

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Family member added successfully"),
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
                          child: const Text("Add"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        "Add Family Member",
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 50),

                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Select Family Member",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .black26),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black26,
                              width: 1.5),
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(
                            horizontal: 20),
                        labelStyle: TextStyle(
                          color: Colors
                              .black45,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          value: selectedFamilyMember.isEmpty
                              ? null
                              : selectedFamilyMember,
                          hint: const Text(
                            'Select Member',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          items: availableFamilyMembers.map((member) {
                            return DropdownMenuItem<String>(
                              value: member,
                              child: Text(member),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setModalState(() {
                              selectedFamilyMember = value ?? '';
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= FAMILY JOB SHEET =================

  void _showFamilyJobSheet(BuildContext context) {
    final jobCtrl = TextEditingController();
    final incomeCtrl = TextEditingController();

    File? incomeCertificate;

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
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column (
                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [
                      const SizedBox(height: 20),
                      /// 🔹 TOP ACTION ROW
                      Row(
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
                            onPressed: () {
                              setState(() {
                                familyJobs.add({
                                  "name": selectedFamilyMember,
                                  "relation": selectedRelation,
                                  "job": jobCtrl.text,
                                  "income": incomeCtrl.text,
                                  "certificate": incomeCertificate != null ? "uploaded" : "",
                                });
                                jobDetailsSubmitted = true;
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Family job detail added successfully"),
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
                            child: const Text("Add Job Detail"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// 🔹 TITLE
                      const Center(
                        child: Text(
                          "Add Family Job Detail",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// 🔹 FORM FIELDS
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Select Family Member",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26, width: 1.5),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          labelStyle: TextStyle(color: Colors.black45),
                        ),
                        isEmpty: selectedFamilyMember.isEmpty,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            value: selectedFamilyMember.isEmpty
                                ? null
                                : selectedFamilyMember,
                            hint: const Text(
                              'Select Member',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            items: familyMembers.map((member) {
                              return DropdownMenuItem<String>(
                                value: member,
                                child: Text(member),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setModalState(() {
                                selectedFamilyMember = value ?? '';
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Relationship",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26, width: 1.5),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          labelStyle: TextStyle(color: Colors.black45),
                        ),
                        isEmpty: selectedRelation.isEmpty,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            value: selectedRelation.isEmpty ? null : selectedRelation,
                            hint: const Text(
                              'Select Relationship',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            items: relationOptions.map((relation) {
                              return DropdownMenuItem<String>(
                                value: relation,
                                child: Text(relation),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setModalState(() {
                                selectedRelation = value ?? '';
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _textField("Job", jobCtrl),
                      const SizedBox(height: 16),

                      _textField("Yearly Income", incomeCtrl,
                          keyboard: TextInputType.number),
                      const SizedBox(height: 16),

                      /// 🔹 UPLOAD INCOME CERTIFICATE
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (incomeCertificate != null)
                            Container(
                              height: 160,
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                border:
                                Border.all(color: Colors.black26),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.picture_as_pdf,
                                  size: 60,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // UI only – file picker later
                                setModalState(() {
                                  incomeCertificate = File("dummy_path");
                                });
                              },
                              icon: const Icon(Icons.upload_file),
                              label: Text(
                                incomeCertificate == null
                                    ? "Upload Income Certificate"
                                    : "Change Income Certificate",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                ColorHelperClass.getColorFromHex(
                                    ColorResources.red_color),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _textField(
      String label,
      TextEditingController ctrl, {
        TextInputType keyboard = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

}
