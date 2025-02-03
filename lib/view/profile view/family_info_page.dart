import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FamilyInfoPage extends StatefulWidget {
  const FamilyInfoPage({Key? key}) : super(key: key);

  @override
  _FamilyInfoPageState createState() => _FamilyInfoPageState();
}

class _FamilyInfoPageState extends State<FamilyInfoPage> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  String usersName = "Rajesh Mani Nair";
  // Variables to store information
  String relationshipName = 'Husband';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Family Info'),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showEditModalSheet(context);
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.grey[200],
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Profile and Name Section
                  Card(
                    color: Colors
                        .white, // Set the background color of the card to white
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          12), // Optional: Add rounded corners
                    ),
                    elevation: 4, // Optional: Add shadow for a lifted effect
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Profile Image Section
                          Stack(
                            children: [
                              CircleAvatar(
                                radius:
                                    40, // Adjusted size for better visibility
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : const AssetImage("assets/images/logo.png")
                                        as ImageProvider,
                                backgroundColor: Colors.grey[300],
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 16),

                          // User Information Section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      usersName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  relationshipName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Method to show the Modal Bottom Sheet
  void _showEditModalSheet(BuildContext context) {
    double heightFactor = 0.8; // Default height for the modal

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return MediaQuery(
          data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
          child: SafeArea(
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: Column(
                children: [
                  // Top row with Cancel and Save buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Cancel button on the left
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(); // Close the bottom sheet
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 24.0,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        // Save button on the right
                        ElevatedButton(
                          onPressed: () {
                            bool isValid = _validateFields();
                            if (isValid) {
                              setState(() {
                                // Perform save logic if fields are valid
                                _showSuccessMessage();
                              });
                              Navigator.of(context)
                                  .pop(); // Close the bottom sheet
                            } else {
                              _showFailureMessage();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 24.0,
                            ),
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      height: 16), // Add spacing between buttons and fields
                  // Expanded section with editable fields
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEditableField(
                            'User',
                            usersName,
                            (value) => setState(() => usersName = value),
                          ),
                          _buildEditableField(
                            'RelationShip',
                            relationshipName,
                            (value) => setState(() => relationshipName = value),
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
      },
    );
  }

  // Method to validate the fields before saving
  bool _validateFields() {
    // You can implement your validation logic here
    // For example, check if any field is empty
    return relationshipName.isNotEmpty;
  }

  // Method to show success message
  void _showSuccessMessage() {
    final snackBar = SnackBar(
      content: const Text('Family Info updated successfully!'),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Method to show failure message
  void _showFailureMessage() {
    final snackBar = SnackBar(
      content: const Text('Failed to update information. Please check fields.'),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildEditableField(
      String label, String initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInfoBox(String title, {String? subtitle}) {
    return Container(
      height: 100,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(
                        left:
                            8.0), // Add some spacing between title and subtitle
                    child: Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.red[300]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
