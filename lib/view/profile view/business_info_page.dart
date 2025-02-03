import 'package:flutter/material.dart';

class BusinessInformationPage extends StatefulWidget {
  const BusinessInformationPage({super.key});

  @override
  _BusinessInformationPageState createState() =>
      _BusinessInformationPageState();
}

class _BusinessInformationPageState extends State<BusinessInformationPage> {
  // Variables to store business-related information
  String organisationName = 'Company Name';
  String officePhone = 'Landline Number';
  String buildingName = 'Building Name';
  String flatNo = 'Flat No';
  String address = 'Address';
  String areaName = 'Area';
  String city = 'Office Location';
  String stateName = 'State';
  String countryName = 'Country';
  String officePincode = 'Postal Code';
  String businessEmail = 'Official Email';
  String website = 'Official URL';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Occupation Info'),
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
                _buildInfoBox('Name of Organisation:',
                    subtitle: organisationName),
                SizedBox(height: 20),
                _buildInfoBox('Office Phone:', subtitle: officePhone),
                SizedBox(height: 20),
                _buildInfoBox('Building Name:', subtitle: buildingName),
                SizedBox(height: 20),
                _buildInfoBox('Flat No:', subtitle: flatNo),
                SizedBox(height: 20),
                _buildInfoBox('Address:', subtitle: address),
                SizedBox(height: 20),
                _buildInfoBox('Area:', subtitle: areaName),
                SizedBox(height: 20),
                _buildInfoBox('City:', subtitle: city),
                SizedBox(height: 20),
                _buildInfoBox('State:', subtitle: stateName),
                SizedBox(height: 20),
                _buildInfoBox('Country:', subtitle: countryName),
                SizedBox(height: 20),
                _buildInfoBox('Office Pincode:', subtitle: officePincode),
                SizedBox(height: 20),
                _buildInfoBox('Business Email:', subtitle: businessEmail),
                SizedBox(height: 20),
                _buildInfoBox('Website:', subtitle: website),
                SizedBox(height: 20),
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
                            'Organisation Name',
                            organisationName,
                            (value) => organisationName = value,
                          ),
                          _buildEditableField(
                            'Office Phone',
                            officePhone,
                            (value) => officePhone = value,
                          ),
                          _buildEditableField(
                            'Building Name',
                            buildingName,
                            (value) => buildingName = value,
                          ),
                          _buildEditableField(
                            'Flat No',
                            flatNo,
                            (value) => flatNo = value,
                          ),
                          _buildEditableField(
                            'Area',
                            areaName,
                            (value) => areaName = value,
                          ),
                          _buildEditableField(
                            'City',
                            city,
                            (value) => city = value,
                          ),
                          _buildEditableField(
                            'State',
                            stateName,
                            (value) => stateName = value,
                          ),
                          _buildEditableField(
                            'Country',
                            countryName,
                            (value) => countryName = value,
                          ),
                          _buildEditableField(
                            'Office Pincode',
                            officePincode,
                            (value) => officePincode = value,
                          ),
                          _buildEditableField(
                            'Business Email',
                            businessEmail,
                            (value) => businessEmail = value,
                          ),
                          _buildEditableField(
                            'Website',
                            website,
                            (value) => website = value,
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

  // Method to validate fields before saving
  bool _validateFields() {
    return organisationName.isNotEmpty && officePhone.isNotEmpty;
  }

  // Method to show success message
  void _showSuccessMessage() {
    final snackBar = SnackBar(
      content: const Text('Occupation info updated successfully!'),
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

  // Editable fields
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

  // Information box widget
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
