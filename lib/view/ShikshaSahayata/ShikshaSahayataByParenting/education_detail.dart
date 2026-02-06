import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class EducationDetailView extends StatefulWidget {
  final String shikshaApplicantId;

  const EducationDetailView({
    Key? key,
    required this.shikshaApplicantId,
  }) : super(key: key);

  @override
  State<EducationDetailView> createState() => _EducationDetailViewState();
}

class _EducationDetailViewState extends State<EducationDetailView> {
  bool hasEducationData = false;
  final List<Map<String, dynamic>> educationList = [];
  File? _educationDocument;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    /// 🔹 Auto open form if no data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasEducationData) {
        _showEducationForm(context);
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
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              "Education Detail",
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
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showEducationForm(context),
          )
        ],
      ),
      body: educationList.isEmpty
          ? const Center(
        child: Text(
          "No Education Details Added Yet",
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: educationList.length + 1, // 👈 important
        itemBuilder: (context, index) {
          if (index == 0) {
            /// 🔹 INFO MESSAGE CARD AT TOP
            return Column(
              children: [
                _educationInfoCard(),
                const SizedBox(height: 12),
              ],
            );
          }

          final edu = educationList[index - 1];
          return _educationCard(edu, index - 1);
        },
      ),
    );
  }

  Widget _educationInfoCard() {
    return Card(
      color: Colors.orange.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                "Please add your 10th, 11th, and 12th education details completed so far, including college or any other course.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _educationCard(Map<String, dynamic> edu, int index) {
    final File? file = edu["file"];

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
            /// 🔹 EDUCATION
            _infoRow("Education", edu["class"]),
            const SizedBox(height: 8),

            /// 🔹 PASSED
            _infoRow("Passed", edu["passed"]),
            const SizedBox(height: 8),

            /// 🔹 MARKS
            _infoRow("Marks", edu["marks"]),
            const SizedBox(height: 12),

            /// 🔹 VIEW DOCUMENT BUTTON
            if (file != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showEducationPreview(context, file),
                  icon: const Icon(Icons.visibility),
                  label: const Text("View Document"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    ColorHelperClass.getColorFromHex(
                        ColorResources.red_color),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ====================== EDUCATION FORM ======================

  void _showEducationForm(BuildContext context) {
    String selectedClass = '';

    final TextEditingController passedCtrl = TextEditingController();
    final TextEditingController marksCtrl = TextEditingController();
    final TextEditingController otherClassCtrl = TextEditingController();

    final List<String> classOptions = [
      "10th Std",
      "11th Std",
      "12th Std",
      "Other",
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
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
                            onPressed: selectedClass.isEmpty
                                ? null
                                : () {
                              final String educationClass =
                              selectedClass == "Other"
                                  ? otherClassCtrl.text
                                  : selectedClass;

                              setState(() {
                                hasEducationData = true;

                                educationList.add({
                                  "class": educationClass,
                                  "passed": passedCtrl.text,
                                  "marks": marksCtrl.text,
                                  "file": _educationDocument,
                                });

                                // clear for next entry
                                _educationDocument = null;
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Education details added successfully"),
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
                            child: const Text("Add Education Details"),
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
                                "Add Education Detail",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            /// 🔹 CLASS DROPDOWN
                            InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'CLass *',
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
                              child: DropdownButton<String>(
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                isExpanded: true,
                                underline: Container(),
                                value: selectedClass.isEmpty
                                    ? null
                                    : selectedClass,
                                hint: const Text(
                                  "Select Class",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold),
                                ),
                                items: classOptions
                                    .map(
                                      (c) => DropdownMenuItem<String>(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                    .toList(),
                                onChanged: (val) {
                                  setModalState(() {
                                    selectedClass = val!;
                                    otherClassCtrl.clear();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 20),

                            if (selectedClass == "Other") ...[
                              TextFormField(
                                controller: otherClassCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Other Education Detail *',
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
                              ),
                              const SizedBox(height: 20),
                            ],

                            /// 🔹 PASSED MONTH / YEAR
                            themedDatePickerField(
                              context: context,
                              label: "Passed Month / Year *",
                              hint: "Select date",
                              controller: passedCtrl,
                            ),
                            const SizedBox(height: 20),

                            /// 🔹 MARKS
                            TextFormField(
                              controller: marksCtrl,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: 'Marks Obtained / Total Marks *',
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
                            ),

                            const SizedBox(height: 25),

                            /// 🔹 UPLOAD DOCUMENT
                            _buildEducationUploadField(context),
                            const SizedBox(height: 20),

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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const Text(
            ": ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget themedDatePickerField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return TextFormField(
      readOnly: true,
      controller: controller,
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
          controller.text = DateFormat('MM/yyyy').format(picked);
        }
      },
    );
  }

  void _showEducationPreview(BuildContext context, File file) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: file.path.endsWith(".pdf")
                    ? const Center(
                  child: Icon(
                    Icons.picture_as_pdf,
                    size: 100,
                    color: Colors.red,
                  ),
                )
                    : InteractiveViewer(
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEducationUploadField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_educationDocument != null)
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _educationDocument!.path.endsWith(".pdf")
                  ? const Center(
                child: Icon(
                  Icons.picture_as_pdf,
                  size: 70,
                  color: Colors.redAccent,
                ),
              )
                  : Image.file(
                _educationDocument!,
                fit: BoxFit.cover,
              ),
            ),
          ),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showEducationImagePicker(context),
            icon: const Icon(Icons.upload_file),
            label: Text(
              _educationDocument == null
                  ? "Upload Marksheet / Certificate"
                  : "Change Document",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              ColorHelperClass.getColorFromHex(ColorResources.red_color),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _showEducationImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text("Take a Picture"),
              onTap: () {
                Navigator.pop(context);
                _pickEducationFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.redAccent),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickEducationFromGallery();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickEducationFromCamera() async {
    final pickedFile =
    await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _educationDocument = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickEducationFromGallery() async {
    final pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _educationDocument = File(pickedFile.path);
      });
    }
  }

}
