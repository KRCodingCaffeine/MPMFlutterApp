import 'package:flutter/material.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({Key? key}) : super(key: key);

  @override
  _PersonalInformationPageState createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  // Variables to store personal information
  String firstName = 'Karthika';
  String middleName = 'K';
  String surName = 'Rajesh';
  String fathersName = 'Doe';
  String mothersName = 'Doees';
  String mobileNumber = 'Mobile Number';
  String whatsAppNumber = 'WhatsApp Number';
  String email = 'Email Address';
  String dob = 'YYYY-MM-DD';
  String gender = 'Male/Female/Other';
  String maritalStatus = 'Married/Single';
  String bloodGroup = 'O+ / A-';

  // Controllers for the text fields to manage user input
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController surNameController = TextEditingController();

  final TextEditingController fathersNameController = TextEditingController();
  final TextEditingController mothersNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController whatsAppNumberController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController maritalStatusController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the current values
    firstNameController.text = firstName;
    middleNameController.text = middleName;
    surNameController.text = surName;
    fathersNameController.text = fathersName;
    mothersNameController.text = mothersName;
    mobileNumberController.text = mobileNumber;
    whatsAppNumberController.text = whatsAppNumber;
    emailController.text = email;
    dobController.text = dob;
    genderController.text = gender;
    maritalStatusController.text = maritalStatus;
    bloodGroupController.text = bloodGroup;
  }

  @override
  void dispose() {
    // Dispose of controllers when no longer needed
    firstNameController.dispose();
    middleNameController.dispose();
    surNameController.dispose();
    fathersNameController.dispose();
    mothersNameController.dispose();
    mobileNumberController.dispose();
    whatsAppNumberController.dispose();
    emailController.dispose();
    dobController.dispose();
    genderController.dispose();
    maritalStatusController.dispose();
    bloodGroupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Info'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
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
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                _buildInfoBox(
                  'Full Name:',
                  subtitle:
                      '$firstName ${middleName.isNotEmpty ? "$middleName " : ""}$surName',
                ),
                SizedBox(height: 20),
                _buildInfoBox('Father\'s Name:', subtitle: fathersName),
                SizedBox(height: 20),
                _buildInfoBox('Mother\'s Name:', subtitle: mothersName),
                SizedBox(height: 20),
                _buildInfoBox('Mobile Number:', subtitle: mobileNumber),
                SizedBox(height: 20),
                _buildInfoBox('WhatsApp Number:', subtitle: whatsAppNumber),
                SizedBox(height: 20),
                _buildInfoBox('Email:', subtitle: email),
                SizedBox(height: 20),
                _buildInfoBox('Date of Birth:', subtitle: dob),
                SizedBox(height: 20),
                _buildInfoBox('Gender:', subtitle: gender),
                SizedBox(height: 20),
                _buildInfoBox('Marital Status:', subtitle: maritalStatus),
                SizedBox(height: 20),
                _buildInfoBox('Blood Group:', subtitle: bloodGroup),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to show the Modal Bottom Sheet for editing
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
              child: Container(
                child: Column(
                  children: [
                    // Top row with Cancel and Save buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // Save the updated values
                                firstName = firstNameController.text;
                                middleName = middleNameController.text;
                                surName = surNameController.text;
                                fathersName = fathersNameController.text;
                                mothersName = mothersNameController.text;
                                mobileNumber = mobileNumberController.text;
                                whatsAppNumber = whatsAppNumberController.text;
                                email = emailController.text;
                                dob = dobController.text;
                                gender = genderController.text;
                                maritalStatus = maritalStatusController.text;
                                bloodGroup = bloodGroupController.text;
                              });
                              Navigator.of(context)
                                  .pop(); // Close the bottom sheet
                              _showSuccessMessage();
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
                    const SizedBox(height: 16),
                    // Expanded section with editable fields
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEditableField(
                              'First Name',
                              firstNameController.text,
                              (value) => firstNameController.text = value,
                            ),
                            _buildEditableField(
                              'Middle Name',
                              middleNameController.text,
                              (value) => middleNameController.text = value,
                            ),
                            _buildEditableField(
                              'SurName',
                              surNameController.text,
                              (value) => surNameController.text = value,
                            ),
                            _buildEditableField(
                              'Fathers Name',
                              fathersName,
                              (value) => setState(() => fathersName = value),
                            ),
                            _buildEditableField(
                              'Mother Name',
                              mothersName,
                              (value) => setState(() => mothersName = value),
                            ),
                            _buildEditableField(
                              'Mobile Number',
                              mobileNumber,
                              (value) => setState(() => mobileNumber = value),
                            ),
                            _buildEditableField(
                              'WhatsApp Number',
                              whatsAppNumber,
                              (value) => setState(() => whatsAppNumber = value),
                            ),
                            _buildEditableField(
                              'Email',
                              email,
                              (value) => setState(() => email = value),
                            ),
                            _buildEditableField(
                              'Date of Birth',
                              dobController.text,
                              (value) => dobController.text = value,
                            ),
                            _buildEditableField(
                              'Gender',
                              genderController.text,
                              (value) => genderController.text = value,
                            ),
                            _buildEditableField(
                              'Marital Status',
                              maritalStatusController.text,
                              (value) => maritalStatusController.text = value,
                            ),
                            _buildEditableField(
                              'Blood Group',
                              bloodGroupController.text,
                              (value) => bloodGroupController.text = value,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Method to validate the fields before saving (optional)
  bool _validateFields() {
    // You can add your validation logic here, for example:
    return firstName.isNotEmpty && dob.isNotEmpty;
  }

  // Method to show success message
  void _showSuccessMessage() {
    final snackBar = SnackBar(
      content: const Text('Personal Info updated successfully!'),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Method to build editable text fields inside the modal
  Widget _buildEditableField(
      String label, String initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  // Method to build the information boxes
  Widget _buildInfoBox(String title, {String? subtitle}) {
    return Container(
      height: 70,
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
