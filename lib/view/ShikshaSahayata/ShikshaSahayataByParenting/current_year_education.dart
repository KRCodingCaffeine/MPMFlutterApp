import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/any_other_charity_fund.dart';
import 'package:mpm/view/ShikshaSahayata/ShikshaSahayataByParenting/other_charity_fund.dart';

class CurrentYearEducationView extends StatefulWidget {
  final String shikshaApplicantId;

  const CurrentYearEducationView({
    Key? key,
    required this.shikshaApplicantId,
  }) : super(key: key);

  @override
  State<CurrentYearEducationView> createState() =>
      _CurrentYearEducationViewState();
}

class _CurrentYearEducationViewState extends State<CurrentYearEducationView> {
  File? _bonafideDocument;
  final ImagePicker _picker = ImagePicker();
  bool hasCurrentYearEducation = false;

  String appliedYear = '';
  String schoolName = '';
  String schoolAddress = '';
  String feesAmount = '';
  File? bonafideFile;

  @override
  void initState() {
    super.initState();

    /// 🔹 Auto open bottom sheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCurrentYearEducationSheet(context);
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
              "Current Year Education",
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
            onPressed: () => _showCurrentYearEducationSheet(context),
          )
        ],
      ),
      body: hasCurrentYearEducation
          ? _buildCurrentYearEducationCard()
          : const Center(
        child: Text(
          "No current year education details added",
          style: TextStyle(color: Colors.grey),
        ),
      ),
      bottomNavigationBar:
      hasCurrentYearEducation ? _buildBottomNextBar() : null,
    );
  }

  Widget _buildCurrentYearEducationCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow("Applied For", appliedYear),
              _infoRow("College / School", schoolName),
              _infoRow("Address", schoolAddress),
              _infoRow("Fees Amount", feesAmount),

              const SizedBox(height: 12),

              /// 🔹 BONAFIDE DOCUMENT
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: bonafideFile == null
                        ? const Text(
                      "Bonafide Document Not Uploaded",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                        : ElevatedButton.icon(
                      onPressed: () =>
                          _showBonafidePreview(context, bonafideFile!),
                      icon: const Icon(Icons.visibility),
                      label: const Text("View Bonafide Document"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        ColorHelperClass.getColorFromHex(
                            ColorResources.red_color),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
            /// 🔹 MESSAGE
            Expanded(
              child: Text(
                "Once you complete this detail, click Submit to proceed.",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// 🔹 NEXT BUTTON
            ElevatedButton(
              onPressed: () {
                // 👉 Navigate to next screen / step
                // Example:
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => AnyOtherCharityFundView(
                      shikshaApplicantId: widget.shikshaApplicantId,
                    ),
                  ),                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Successfully sumbited your current year edication detail"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== BOTTOM SHEET =====================

  void _showCurrentYearEducationSheet(BuildContext context) {
    final TextEditingController yearCtrl = TextEditingController();
    final TextEditingController schoolCtrl = TextEditingController();
    final TextEditingController addressCtrl = TextEditingController();
    final TextEditingController feesCtrl = TextEditingController();

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
                heightFactor: 0.7,
                child: Column(
                  children: [
                    /// 🔹 TOP ACTION BAR (FIXED)
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
                            onPressed: () {
                              setState(() {
                                appliedYear = yearCtrl.text;
                                schoolName = schoolCtrl.text;
                                schoolAddress = addressCtrl.text;
                                feesAmount = feesCtrl.text;
                                bonafideFile = _bonafideDocument;
                                hasCurrentYearEducation = true;
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Current year education saved successfully"),
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
                            child: const Text("Add Details"),
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
                                "Current Year Education Detail",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            /// 🔹 CURRENT YEAR APPLIED FOR
                            _buildTextField(
                              label: "Current Year Applied For *",
                              controller: yearCtrl,
                              hint: "Eg: FY BSc / 1st Year / Class 10",
                            ),

                            const SizedBox(height: 20),

                            /// 🔹 COLLEGE / SCHOOL NAME
                            _buildTextField(
                              label: "College / School Name *",
                              controller: schoolCtrl,
                            ),

                            const SizedBox(height: 20),

                            /// 🔹 COLLEGE / SCHOOL ADDRESS
                            _buildTextField(
                              label: "College / School Address *",
                              controller: addressCtrl,
                              maxLines: 2,
                            ),

                            const SizedBox(height: 20),

                            /// 🔹 FEES AMOUNT
                            _buildTextField(
                              label: "Fees Amount *",
                              controller: feesCtrl,
                              keyboard: TextInputType.number,
                              hint: "Enter total fees",
                            ),
                            const SizedBox(height: 25),

                            /// 🔹 UPLOAD BONAFIDE CERTIFICATE
                            _buildBonafideUploadField(context),

                            const SizedBox(height: 40),
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
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

  void _showBonafidePreview(BuildContext context, File file) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Padding(
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
                  child: Image.file(file, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBonafideUploadField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_bonafideDocument != null)
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
              child: _bonafideDocument!.path.endsWith(".pdf")
                  ? const Center(
                child: Icon(
                  Icons.picture_as_pdf,
                  size: 70,
                  color: Colors.redAccent,
                ),
              )
                  : Image.file(
                _bonafideDocument!,
                fit: BoxFit.cover,
              ),
            ),
          ),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showBonafidePicker(context),
            icon: const Icon(Icons.upload_file),
            label: Text(
              _bonafideDocument == null
                  ? "Upload Bonafide Certificate"
                  : "Change Bonafide Certificate",
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

  void _showBonafidePicker(BuildContext context) {
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
                _pickBonafideFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.redAccent),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickBonafideFromGallery();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickBonafideFromCamera() async {
    final pickedFile =
    await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _bonafideDocument = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickBonafideFromGallery() async {
    final pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _bonafideDocument = File(pickedFile.path);
      });
    }
  }
}
