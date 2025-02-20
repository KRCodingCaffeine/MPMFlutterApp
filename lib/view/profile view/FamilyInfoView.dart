import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'family_info_page.dart';

class EditFamilyInfoPage extends StatefulWidget {
  final String firstName;
  final String middleName;
  final String lastName;
  final String relationshipName;
  final File? profileImage;
  final Function(String, String, String) onNameChanged; // Handling all names
  final Function(String) onRelationshipChanged;
  final Function(File?) onImageSelected;

  const EditFamilyInfoPage({
    Key? key,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.relationshipName,
    required this.onNameChanged,
    required this.onRelationshipChanged,
    required this.onImageSelected,
    this.profileImage,
  }) : super(key: key);

  @override
  _EditFamilyInfoPageState createState() => _EditFamilyInfoPageState();
}

class _EditFamilyInfoPageState extends State<EditFamilyInfoPage> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _profileImage = widget.profileImage; // Set the initial image if passed
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      widget.onImageSelected(_profileImage!);
    }
  }

  void _saveChanges() {
    bool isSuccess = _validateFields();

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Changes saved successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FamilyInfoPage(successMessage: 'Changes saved successfully!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to save changes. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FamilyInfoPage(failureMessage: 'Failed to save changes.'),
        ),
      );
    }
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
        title: const Text('Edit Family Info'),
        backgroundColor: Colors.white54,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildEditableField(
                label: 'First Name',
                initialValue: widget.firstName,
                onChanged: (value) => widget.onNameChanged(
                    value, widget.middleName, widget.lastName),
              ),
              const SizedBox(height: 16),
              _buildEditableField(
                label: 'Middle Name',
                initialValue: widget.middleName,
                onChanged: (value) => widget.onNameChanged(
                    widget.firstName, value, widget.lastName),
              ),
              const SizedBox(height: 16),
              _buildEditableField(
                label: 'Last Name',
                initialValue: widget.lastName,
                onChanged: (value) => widget.onNameChanged(
                    widget.firstName, widget.middleName, value),
              ),
              const SizedBox(height: 16),
              _buildEditableField(
                label: 'Relationship',
                initialValue: widget.relationshipName,
                onChanged: widget.onRelationshipChanged,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 100.0,
                  ),
                ),
                child: const Text('Upload Image'),
              ),
              const SizedBox(height: 16),
              _profileImage != null
                  ? Image.file(
                      _profileImage!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : const Text('No image selected'),
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
    required String initialValue,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
