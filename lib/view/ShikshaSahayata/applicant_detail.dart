import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ShikshaSahayata/family_detail.dart';

class ApplicantDetail extends StatefulWidget {
  const ApplicantDetail({super.key});

  @override
  State<ApplicantDetail> createState() => _ApplicantDetailState();
}

class _ApplicantDetailState extends State<ApplicantDetail> {
  bool hasApplicant = false;
  File? _aadharFrontImage;
  File? _aadharBackImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController middleNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController aadharCtrl = TextEditingController();
  final TextEditingController dobCtrl = TextEditingController();
  final TextEditingController anniversaryCtrl = TextEditingController();

  String selectedGender = '';
  String maritalStatus = '';

  String fullName = '';
  String mobile = '';
  String email = '';
  String dob = '';
  String age = '';
  String aadhar = '';
  String anniversary = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasApplicant) {
        _showAddApplicantModalSheet(context);
      }
    });
  }

  bool get _canSubmitApplicant {
    if (firstNameCtrl.text.trim().isEmpty) return false;
    if (lastNameCtrl.text.trim().isEmpty) return false;
    if (emailCtrl.text.trim().isEmpty) return false;
    if (mobileCtrl.text.trim().isEmpty) return false;
    if (selectedGender.isEmpty) return false;
    if (dobCtrl.text.trim().isEmpty) return false;
    if (ageCtrl.text.trim().isEmpty) return false;
    if (maritalStatus.isEmpty) return false;

    if (maritalStatus == "Married" &&
        anniversaryCtrl.text.trim().isEmpty) {
      return false;
    }

    if (_aadharFrontImage == null) return false;
    if (_aadharBackImage == null) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          "Applicant Detail",
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: hasApplicant
          ? _buildApplicantCard()
          : const Center(
        child: Text(
          "No applicant details added",
          style: TextStyle(color: Colors.grey),
        ),
      ),

      floatingActionButton: !hasApplicant
          ? FloatingActionButton(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.red_color),
        onPressed: () {
          _showAddApplicantModalSheet(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,

      bottomNavigationBar: hasApplicant ? _buildBottomNextBar() : null,
    );
  }

  Widget _buildApplicantCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _infoRow("Full Name", fullName),
              _infoRow("Email", email),
              _infoRow("Mobile", mobile),
              _infoRow("Gender", selectedGender),
              _infoRow("Date of Birth", dob),
              _infoRow("Age", age),
              _infoRow("Marital Status", maritalStatus),
              if (maritalStatus == "Married")
                _infoRow("Anniversary", anniversary),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 130,
                    child: Text(
                      "Aadhaar :",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 130,
                        child: Text(
                          "Aadhaar :",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAadhaarPreview(
                              title: "Front",
                              image: _aadharFrontImage,
                            ),
                            const SizedBox(height: 8),
                            _buildAadhaarPreview(
                              title: "Back",
                              image: _aadharBackImage,
                            ),
                          ],
                        ),
                      ),
                    ],
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

            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => FamilyDetail()),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Successfully sumbited your applicant detail"),
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

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Text(
                  ':',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          Expanded(
            child: value.isNotEmpty
                ? Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
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

  Widget _buildAadhaarPreview({
    required String title,
    required File? image,
  }) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text("$title:")),
        image == null
            ? const Text("Not Uploaded")
            : GestureDetector(
          onTap: () => _showImagePreview(image),
          child: Image.file(image, height: 60, width: 90),
        ),
      ],
    );
  }

  void _showImagePreview(File image) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Image.file(image),
      ),
    );
  }

  void _showAddApplicantModalSheet(BuildContext context) {
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      Row(
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
                            onPressed: _canSubmitApplicant
                                ? () {
                              setState(() {
                                fullName =
                                "${firstNameCtrl.text} ${middleNameCtrl.text} ${lastNameCtrl.text}";
                                email = emailCtrl.text;
                                mobile = mobileCtrl.text;
                                dob = dobCtrl.text;
                                age = ageCtrl.text;
                                anniversary = anniversaryCtrl.text;
                                hasApplicant = true;
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Applicant details added successfully"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade400,
                              disabledForegroundColor: Colors.white70,
                            ),
                            child: const Text("Submit"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              const Center(
                                child: Text(
                                  "Applicant details",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              _buildTextField("First Name *",
                                  controller: firstNameCtrl),
                              const SizedBox(height: 20),
                              _buildTextField("Middle Name",
                                  controller: middleNameCtrl),
                              const SizedBox(height: 20),
                              _buildTextField("Last Name *",
                                  controller: lastNameCtrl),
                              const SizedBox(height: 20),
                              _buildTextField("Email *", controller: emailCtrl),
                              const SizedBox(height: 20),
                              _buildTextField("Mobile Number *",
                                  controller: mobileCtrl,
                                  keyboard: TextInputType.number),
                              const SizedBox(height: 20),
                              _buildDropdown(
                                label: "Gender *",
                                items: ["Male", "Female"],
                                selectedValue: selectedGender,
                                onChanged: (val) {
                                  setModalState(() {
                                    selectedGender = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              themedDatePickerField(
                                context: context,
                                label: "Date of Birth *",
                                hint: "Select DOB",
                                controller: dobCtrl,
                                calculateAge: true,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                "Age *",
                                controller: ageCtrl,
                                readOnly: true,
                                keyboard: TextInputType.none,
                              ),
                              const SizedBox(height: 20),
                              _buildDropdown(
                                label: "Marital Status *",
                                items: ["Married", "Unmarried"],
                                selectedValue: maritalStatus,
                                onChanged: (val) {
                                  setModalState(() {
                                    maritalStatus = val;

                                    if (val == "Unmarried") {
                                      anniversaryCtrl.clear();
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              if (maritalStatus == "Married") ...[
                                themedDatePickerField(
                                  context: context,
                                  label: "Marriage Anniversary",
                                  hint: "Select Anniversary Date",
                                  controller: anniversaryCtrl,
                                  calculateAge: false,
                                ),
                                const SizedBox(height: 20),
                              ],
                              _buildAadharUploadField(context),
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
      },
    );
  }

  Widget _buildTextField(
    String label, {
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    bool readOnly = false,
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
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return InputDecorator(
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
      isEmpty: selectedValue.isEmpty,
      child: DropdownButton<String>(
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
        isExpanded: true,
        underline: Container(),
        value: selectedValue.isEmpty ? null : selectedValue,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            onChanged(val);
          }
        },
      ),
    );
  }

  void _calculateAgeFromDob(DateTime dob) {
    final DateTime today = DateTime.now();

    int age = today.year - dob.year;

    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }

    ageCtrl.text = age.toString();
  }

  Widget themedDatePickerField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    bool calculateAge = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
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
                      ColorResources.red_color,
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            controller.text = DateFormat('dd/MM/yyyy').format(picked);

            if (calculateAge) {
              _calculateAgeFromDob(picked);
            }
          }
        },
      ),
    );
  }

  Widget _buildAadharUploadField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Self Attached Aadhaar Upload *",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        /// FRONT
        _buildUploadCard(
          context: context,
          title: "Upload Aadhaar Front",
          image: _aadharFrontImage,
          onPick: () => _showImagePicker(context, isFront: true),
        ),

        const SizedBox(height: 16),

        /// BACK
        _buildUploadCard(
          context: context,
          title: "Upload Aadhaar Back",
          image: _aadharBackImage,
          onPick: () => _showImagePicker(context, isFront: false),
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required BuildContext context,
    required String title,
    required File? image,
    required VoidCallback onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (image != null)
          Container(
            height: 180,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(image, fit: BoxFit.cover),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.upload_file),
            label: Text(image == null ? title : "Change $title"),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              ColorHelperClass.getColorFromHex(ColorResources.red_color),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }


  void _showImagePicker(BuildContext context, {required bool isFront}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text("Take a Picture"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, isFront);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.redAccent),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isFront);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, bool isFront) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _aadharFrontImage = File(pickedFile.path);
        } else {
          _aadharBackImage = File(pickedFile.path);
        }
      });
    }
  }

}
