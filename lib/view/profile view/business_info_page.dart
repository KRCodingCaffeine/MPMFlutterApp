import 'package:flutter/material.dart';
import 'business_info_view.dart';
import 'occupation_info_view.dart';

class BusinessInformationPage extends StatefulWidget {
  final String? successMessage;
  final String? failureMessage;

  const BusinessInformationPage(
      {Key? key, this.successMessage, this.failureMessage})
      : super(key: key);

  @override
  _BusinessInformationPageState createState() =>
      _BusinessInformationPageState();
}

class _BusinessInformationPageState extends State<BusinessInformationPage> {
  // Variables to store occupation-related information
  String occupation = "Software Developer";
  String occupationProfession = "Technology";
  String occupationSpecialization = "Mobile App Development";
  String occupationDetails =
      "Specialized in Flutter and Dart for mobile applications.";

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

  // List to store business card details
  List<Map<String, String>> businessCards = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Occupation & Business Info'),
        backgroundColor: Colors.white54,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddModalSheet(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditOccInfoPage(
                      occupation: occupation,
                      occupationProfession: occupationProfession,
                      occupationSpecialization: occupationSpecialization,
                      occupationDetails: occupationDetails,
                      onOccInfoChanged: (occ, prof, spec, det) {
                        setState(() {
                          occupation = occ;
                          occupationProfession = prof;
                          occupationSpecialization = spec;
                          occupationDetails = det;
                        });
                      },
                    ),
                  ),
                );
              },
              child: _buildOccCard(),
            ),
            const SizedBox(height: 20),
            Column(
              children: businessCards.map((card) {
                return _buildBusinessInfoCard(
                  organisationName: card['organisationName']!,
                  officePhone: card['officePhone']!,
                  buildingName: card['buildingName']!,
                  flatNo: card['flatNo']!,
                  address: card['address']!,
                  areaName: card['areaName']!,
                  city: card['city']!,
                  stateName: card['stateName']!,
                  countryName: card['countryName']!,
                  officePincode: card['officePincode']!,
                  businessEmail: card['businessEmail']!,
                  website: card['website']!,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Method to show the Modal Bottom Sheet for editing
  void _showAddModalSheet(BuildContext context) {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Move button to the right
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            bool isValid = _validateFields();
                            if (isValid) {
                              setState(() {

                                _addNewBusinessCard();
                              });
                              Navigator.of(context).pop();
                            } else {
                              _showFailureMessage();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFDC3545),
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

  // Method to add a new business card to the list
  void _addNewBusinessCard() {
    final newCard = {
      'organisationName': organisationName,
      'officePhone': officePhone,
      'buildingName': buildingName,
      'flatNo': flatNo,
      'address': address,
      'areaName': areaName,
      'city': city,
      'stateName': stateName,
      'countryName': countryName,
      'officePincode': officePincode,
      'businessEmail': businessEmail,
      'website': website,
    };

    businessCards.add(newCard); // Add the new card to the list
  }

  // Method to validate fields before saving
  bool _validateFields() {
    return organisationName.isNotEmpty && officePhone.isNotEmpty;
  }

  // Method to show success message
  void _showSuccessMessage() {
    final snackBar = SnackBar(
      content: const Text('Information updated successfully!'),
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

  // Editable fields widget
  Widget _buildEditableField(
      String label, String initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: TextEditingController(text: initialValue),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  // Business Info Card widget with white background color
  Widget _buildBusinessInfoCard({
    required String organisationName,
    required String officePhone,
    required String buildingName,
    required String flatNo,
    required String address,
    required String areaName,
    required String city,
    required String stateName,
    required String countryName,
    required String officePincode,
    required String businessEmail,
    required String website,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      color: Colors.white, // Set the background color to white
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoLine('Name of Organisation', organisationName),
            _buildInfoLine('Office Phone', officePhone),
            _buildInfoLine('Building Name', buildingName),
            _buildInfoLine('Flat No', flatNo),
            _buildInfoLine('Address', address),
            _buildInfoLine('Area', areaName),
            _buildInfoLine('City', city),
            _buildInfoLine('State', stateName),
            _buildInfoLine('Country', countryName),
            _buildInfoLine('Office Pincode', officePincode),
            _buildInfoLine('Business Email', businessEmail),
            _buildInfoLine('Website', website),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLine(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
        children: [
          // Title and Colon
          Container(
            width: 140, // Adjust width for alignment
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
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
                const SizedBox(
                    width: 8), // Add space between colon and subtitle
              ],
            ),
          ),
          // Subtitle
          Expanded(
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Occupation Card widget with white background color
  Widget _buildOccCard() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white, // Set the background color to white
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoLine('Occupation:', occupation),
            _buildInfoLine('Profession:', occupationProfession),
            _buildInfoLine('Specialization:', occupationSpecialization),
            _buildInfoLine('Details:', occupationDetails),
          ],
        ),
      ),
    );
  }
}
