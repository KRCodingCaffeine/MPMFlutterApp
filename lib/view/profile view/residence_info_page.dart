import 'package:flutter/material.dart';

class ResidenceInformationPage extends StatefulWidget {
  const ResidenceInformationPage({Key? key}) : super(key: key);

  @override
  _ResidenceInformationPageState createState() =>
      _ResidenceInformationPageState();
}

class _ResidenceInformationPageState extends State<ResidenceInformationPage> {
  // Variables to store information
  String address = 'Building Name';
  String flatNo = 'Flat No';
  String zone = 'Mandal Zone';
  String area = 'Area';
  String state = 'State';
  String city = 'Location Details';
  String country = 'Country Details';
  String pincode = 'Postal Code';
  String documentType = 'Document Type';
  String document = 'Document';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Residential Info'),
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
                _buildInfoBox('Building Name:', subtitle: 'Building Name'),
                SizedBox(height: 20),
                _buildInfoBox(' Flat No:', subtitle: 'Flat No'),
                SizedBox(height: 20),
                _buildInfoBox('Zone:', subtitle: 'Zone'),
                SizedBox(height: 20),
                _buildInfoBox(
                  'Area:',
                  subtitle: 'Area Details',
                ),
                SizedBox(height: 20),
                _buildInfoBox('State:', subtitle: 'State Details'),
                SizedBox(height: 20),
                _buildInfoBox('City:', subtitle: 'City Details'),
                SizedBox(height: 20),
                _buildInfoBox('Country:', subtitle: 'Country Details'),
                SizedBox(height: 20),
                _buildInfoBox('Pincode:', subtitle: 'Postal Code'),
                SizedBox(height: 20),
                _buildInfoBox(
                  'Document Type:',
                  subtitle: 'Document Type',
                ),
                SizedBox(height: 20),
                _buildInfoBox(
                  'Document:',
                  subtitle: 'Document',
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                            'Building Name',
                            address,
                            (value) => setState(() => address = value),
                          ),
                          _buildEditableField(
                            'Flat No',
                            flatNo,
                            (value) => setState(() => flatNo = value),
                          ),
                          _buildEditableField(
                            'Zone',
                            zone,
                            (value) => setState(() => zone = value),
                          ),
                          _buildEditableField(
                            'Area',
                            area,
                            (value) => setState(() => area = value),
                          ),
                          _buildEditableField(
                            'State',
                            state,
                            (value) => setState(() => state = value),
                          ),
                          _buildEditableField(
                            'City',
                            city,
                            (value) => setState(() => city = value),
                          ),
                          _buildEditableField(
                            'Country',
                            country,
                            (value) => setState(() => country = value),
                          ),
                          _buildEditableField(
                            'Pincode',
                            pincode,
                            (value) => setState(() => pincode = value),
                          ),
                          _buildEditableField(
                            'Document Type',
                            documentType,
                            (value) => setState(() => documentType = value),
                          ),
                          _buildEditableField(
                            'Document',
                            document,
                            (value) => setState(() => document = value),
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
    return pincode.isNotEmpty;
  }

  // Method to show success message
  void _showSuccessMessage() {
    final snackBar = SnackBar(
      content: const Text('Residence Info updated successfully!'),
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
