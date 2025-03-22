import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'business_info_page.dart';

class EditOccInfoPage extends StatefulWidget {
  final String occupation;
  final String occupationProfession;
  final String occupationSpecialization;
  final String occupationDetails;
  final Function(String, String, String, String) onOccInfoChanged;

  const EditOccInfoPage({
    Key? key,
    required this.occupation,
    required this.occupationProfession,
    required this.occupationSpecialization,
    required this.occupationDetails,
    required this.onOccInfoChanged,
  }) : super(key: key);

  @override
  _EditOccInfoPageState createState() => _EditOccInfoPageState();
}

class _EditOccInfoPageState extends State<EditOccInfoPage> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
UdateProfileController controller=Get.put(UdateProfileController());

  TextEditingController _occupationController = TextEditingController();
  TextEditingController _professionController = TextEditingController();
  TextEditingController _specializationController = TextEditingController();
  TextEditingController _detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _occupationController.text = widget.occupation;
    _professionController.text = widget.occupationProfession;
    _specializationController.text = widget.occupationSpecialization;
    _detailsController.text = widget.occupationDetails;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _saveChanges() {
    bool isSuccess = _validateFields();


  }

  bool _validateFields() {
    // Add actual validation if needed
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Edit Occupation Info'),
        backgroundColor: Colors.white54,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildEditableField(
                label: 'Occupation',
                controller: _occupationController,
                onChanged: (value) {
                  widget.onOccInfoChanged(value, _professionController.text,
                      _specializationController.text, _detailsController.text);
                },
              ),
              const SizedBox(height: 16),
              _buildEditableField(
                label: 'Profession',
                controller: _professionController,
                onChanged: (value) {
                  widget.onOccInfoChanged(_occupationController.text, value,
                      _specializationController.text, _detailsController.text);
                },
              ),
              const SizedBox(height: 16),
              _buildEditableField(
                label: 'Specialization',
                controller: _specializationController,
                onChanged: (value) {
                  widget.onOccInfoChanged(
                      _occupationController.text,
                      _professionController.text,
                      value,
                      _detailsController.text);
                },
              ),
              const SizedBox(height: 16),
              _buildEditableField(
                label: 'Details',
                controller: _detailsController,
                onChanged: (value) {
                  widget.onOccInfoChanged(
                      _occupationController.text,
                      _professionController.text,
                      _specializationController.text,
                      value);
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFDC3545),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 40.0,
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
