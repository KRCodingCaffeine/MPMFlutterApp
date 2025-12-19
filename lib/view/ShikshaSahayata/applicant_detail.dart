import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class ApplicantDetail extends StatefulWidget {
  const ApplicantDetail({super.key});

  @override
  State<ApplicantDetail> createState() => _ApplicantDetailState();
}

class _ApplicantDetailState extends State<ApplicantDetail> {
  bool hasApplicant = false;
  File? _aadharImage;
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
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddApplicantModalSheet(context),
          )
        ],
      ),
      body: hasApplicant
          ? _buildApplicantCard()
          : const Center(
              child: Text(
                "No applicant details added",
                style: TextStyle(color: Colors.grey),
              ),
            ),
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
                  Expanded(
                    child: _aadharImage == null
                        ? const Text(
                            "Not Uploaded",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : GestureDetector(
                            onTap: () => _showAadhaarPreview(context),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _aadharImage!,
                                height: 80,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
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

  void _showAadhaarPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.file(
                  _aadharImage!,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
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
                            onPressed: () {
                              setState(() {
                                fullName =
                                    "${firstNameCtrl.text} ${middleNameCtrl.text} ${lastNameCtrl.text}";
                                email = emailCtrl.text;
                                mobile = mobileCtrl.text;
                                dob = dobCtrl.text;
                                age = ageCtrl.text;
                                aadhar = aadharCtrl.text;
                                anniversary = anniversaryCtrl.text;
                                hasApplicant = true;
                              });

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Applicant details added successfully"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Add Details"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              _buildTextField("First Name",
                                  controller: firstNameCtrl),
                              const SizedBox(height: 20),
                              _buildTextField("Middle Name",
                                  controller: middleNameCtrl),
                              const SizedBox(height: 20),
                              _buildTextField("Last Name",
                                  controller: lastNameCtrl),
                              const SizedBox(height: 20),
                              _buildTextField("Email", controller: emailCtrl),
                              const SizedBox(height: 20),
                              _buildTextField("Mobile Number",
                                  controller: mobileCtrl,
                                  keyboard: TextInputType.number),
                              const SizedBox(height: 20),
                              _buildDropdown(
                                label: "Gender",
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
                                "Age",
                                controller: ageCtrl,
                                readOnly: true,
                                keyboard: TextInputType.none,
                              ),
                              const SizedBox(height: 20),
                              _buildDropdown(
                                label: "Marital Status",
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
                              const SizedBox(height: 20),
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
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black26)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black26, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black26),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black26),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black26, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 4,
        ),
        labelStyle: const TextStyle(color: Colors.black45),
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
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
        if (_aadharImage != null)
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
              child: Image.file(
                _aadharImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showImagePicker(context),
            icon: const Icon(Icons.upload_file),
            label: Text(
              _aadharImage == null ? "Upload Aadhaar" : "Change Aadhaar Image",
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

  void _showImagePicker(BuildContext context) {
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
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.redAccent),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _aadharImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _aadharImage = File(pickedFile.path);
      });
    }
  }
}
