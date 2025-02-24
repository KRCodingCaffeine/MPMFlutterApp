import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
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
  String occupation = "";
  String occupationProfession = "";
  String occupationSpecialization = "";
  String occupationDetails = "";

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Occupation Info',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Occupation Details Section
            GestureDetector(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      "Occupation Details",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      thickness: 1.0,
                      color: Color(
                          0xFFE0E0E0), // Equivalent to Colors.grey.shade300
                    ),
                  ),
                  _buildOccInfo(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Business / Employment Details Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row with "Business / Employment Details" and Add Button (conditionally visible)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Business / Employment Details',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddModalSheet(context),
                        icon: const Icon(Icons.add, color: Colors.red),
                        label: const Text(
                          "Add",
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    thickness: 1.0,
                    color:
                        Color(0xFFE0E0E0), // Equivalent to Colors.grey.shade300
                  ),
                ),

                // Check if businessCards is empty, display message, otherwise show cards
                businessCards.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "No Employment Details, Please add by clicking Add Employment Button.",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
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
            )
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
        return DraggableScrollableSheet(
          initialChildSize: heightFactor,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom, // Adjust for keyboard
              ),
              child: SafeArea(
                child: FractionallySizedBox(
                  heightFactor: heightFactor,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 24.0,
                                ),
                              ),
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.red)),
                            ),
                            TextButton(
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
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 24.0,
                                ),
                              ),
                              child: const Text('Save',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController, // Make it scrollable
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

    setState(() {
      businessCards.add(newCard); // Add the new card to the list
      print("New Card Added: $newCard"); // Debugging
      print("Total Cards: ${businessCards.length}"); // Debugging
    });
  }

  // Method to validate fields before saving
  bool _validateFields() {
    return organisationName.isNotEmpty;
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
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header with Organisation Name and Add Button on Right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    organisationName.isNotEmpty
                        ? organisationName
                        : 'Business Details',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Prevents overflow
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showEditModalSheet(context),
                  icon: const Icon(Icons.edit, color: Colors.red),
                  label: const Text(
                    "Edit",
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Colors.red, // Keep text and icon red when pressed
                  ),
                ),
              ],
            ),

            const Divider(color: Color(0xFFE0E0E0)), // Black divider

            if (organisationName.isNotEmpty) ...[
              const SizedBox(height: 8),

              // Line 1: Flat No, Address
              Text(
                "$flatNo, $address",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Line 2: City, State - Pincode
              Text(
                "$city, $stateName - $officePincode",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Line 3: Phone Number
              Text(
                "📞 $officePhone",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Line 4: Email
              Text(
                "✉ $businessEmail",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Line 5: Website
              Text(
                "🌐 $website",
                style: const TextStyle(fontSize: 14, color: Colors.blue),
              ),
              const SizedBox(height: 10),
            ]
          ],
        ),
      ),
    );
  }

  void _showEditModalSheet(BuildContext context) {
    double heightFactor = 0.8;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          ),
          child: SafeArea(
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 24.0,
                            ),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () {
                            bool isValid = _validateFields();
                            if (isValid) {
                              setState(() {
                                _updateBusinessCard();
                              });
                              Navigator.of(context).pop();
                            } else {
                              _showFailureMessage();
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 24.0,
                            ),
                          ),
                          child: const Text('Update',
                              style: TextStyle(color: Colors.red)),
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
                            (value) => setState(() => organisationName = value),
                          ),
                          _buildEditableField(
                            'Office Phone',
                            officePhone,
                            (value) => setState(() => officePhone = value),
                          ),
                          _buildEditableField(
                            'Building Name',
                            buildingName,
                            (value) => setState(() => buildingName = value),
                          ),
                          _buildEditableField(
                            'Flat No',
                            flatNo,
                            (value) => setState(() => flatNo = value),
                          ),
                          _buildEditableField(
                            'Area',
                            areaName,
                            (value) => setState(() => areaName = value),
                          ),
                          _buildEditableField(
                            'City',
                            city,
                            (value) => setState(() => city = value),
                          ),
                          _buildEditableField(
                            'State',
                            stateName,
                            (value) => setState(() => stateName = value),
                          ),
                          _buildEditableField(
                            'Country',
                            countryName,
                            (value) => setState(() => countryName = value),
                          ),
                          _buildEditableField(
                            'Office Pincode',
                            officePincode,
                            (value) => setState(() => officePincode = value),
                          ),
                          _buildEditableField(
                            'Business Email',
                            businessEmail,
                            (value) => setState(() => businessEmail = value),
                          ),
                          _buildEditableField(
                            'Website',
                            website,
                            (value) => setState(() => website = value),
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

  void _updateBusinessCard() {
    setState(() {
      // Implement logic to update the business card details
      // For example, you might update a database, API, or local storage
    });

    // Optionally, show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Business details updated successfully!')),
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

  // Method to show the Occupation Info BottomSheet
  void _showEditOccBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5, // Start from the middle
            maxChildSize: 0.95, // Can be expanded almost full-screen
            minChildSize: 0.5, // Minimum half-screen height
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController, // Ensures smooth scrolling
                  child: _EditOccInfoContent(
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
          ),
        );
      },
    );
  }

  Widget _buildOccInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (occupation.isNotEmpty ||
              occupationProfession.isNotEmpty ||
              occupationSpecialization.isNotEmpty ||
              occupationDetails.isNotEmpty)
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                        height: 8), // Spacing between title and details

                    // Using Row to align info on the left and Edit button on the right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoLine('Occupation', occupation),
                              _buildInfoLine(
                                  'Profession', occupationProfession),
                              _buildInfoLine(
                                  'Specialization', occupationSpecialization),
                              _buildInfoLine('Details', occupationDetails),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showEditOccBottomSheet(context),
                          icon: const Icon(Icons.edit,
                              color: Colors.red, size: 16),
                          label: const Text(
                            "Edit",
                            style: TextStyle(fontSize: 14, color: Colors.red),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                const Text(
                  "No Occupation Detail, Please add by clicking Add Occupation Button",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                TextButton.icon(
                  onPressed: () => _showEditOccBottomSheet(context),
                  icon: const Icon(
                    Icons.add,
                    color: Colors.red,
                  ),
                  label: const Text(
                    "Add Occupation",
                    style: TextStyle(color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors
                        .red, // Ensures the text and icon stay red when pressed
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _EditOccInfoContent extends StatefulWidget {
  final String occupation;
  final String occupationProfession;
  final String occupationSpecialization;
  final String occupationDetails;
  final Function(String, String, String, String) onOccInfoChanged;

  _EditOccInfoContent({
    required this.occupation,
    required this.occupationProfession,
    required this.occupationSpecialization,
    required this.occupationDetails,
    required this.onOccInfoChanged,
  });

  @override
  _EditOccInfoContentState createState() => _EditOccInfoContentState();
}

class _EditOccInfoContentState extends State<_EditOccInfoContent> {
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _occupationController.text = widget.occupation;
    _professionController.text = widget.occupationProfession;
    _specializationController.text = widget.occupationSpecialization;
    _detailsController.text = widget.occupationDetails;
  }

  void _saveChanges() {
    widget.onOccInfoChanged(
      _occupationController.text,
      _professionController.text,
      _specializationController.text,
      _detailsController.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Row for Save & Cancel buttons at the top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel Button (Left)
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context), // Close the BottomSheet
                    style: TextButton.styleFrom(
                      foregroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color), // Grey color for Cancel
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 30),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),

                  // Save Button (Right)
                  TextButton(
                    onPressed: _saveChanges,
                    style: TextButton.styleFrom(
                      foregroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color), // Red color for Save
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 30),
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Editable Fields
            _buildEditableField(
                label: 'Occupation', controller: _occupationController),
            _buildEditableField(
                label: 'Profession', controller: _professionController),
            _buildEditableField(
                label: 'Specialization', controller: _specializationController),
            _buildEditableField(
                label: 'Details', controller: _detailsController),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
      {required String label, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
