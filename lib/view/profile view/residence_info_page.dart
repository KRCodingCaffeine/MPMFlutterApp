import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class ResidenceInformationPage extends StatefulWidget {
  const ResidenceInformationPage({Key? key}) : super(key: key);

  @override
  _ResidenceInformationPageState createState() =>
      _ResidenceInformationPageState();
}

class _ResidenceInformationPageState extends State<ResidenceInformationPage> {
  // Variables to store information

  UdateProfileController controller=Get.put(UdateProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Residential Info'),
        backgroundColor: Colors.white54,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditModalSheet(context);
            },
          ),
        ],
      ),
      body: controller.getUserData.value.address!=null?Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Card(
              color: Colors.white,
              elevation: 4, // Adds shadow to the card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(16.0), // Inner padding of the card
                child: Column(
                  children: [
                    _buildInfoBox('Building Name:', subtitle: controller.getUserData.value.address!.buildingNameId.toString()),
                    SizedBox(height: 20),
                    _buildInfoBox(' Flat No:', subtitle: controller.getUserData.value.address!.flatNo.toString()),
                    SizedBox(height: 20),
                    _buildInfoBox('Zone:', subtitle: controller.getUserData.value.address!.zoneName.toString()),
                    SizedBox(height: 20),
                    _buildInfoBox(
                      'Area:',
                      subtitle: controller.getUserData.value.address!.areaName.toString(),
                    ),
                    SizedBox(height: 20),
                    _buildInfoBox('State:', subtitle: controller.getUserData.value.address!.stateName.toString()),
                    SizedBox(height: 20),
                    _buildInfoBox('City:', subtitle: controller.getUserData.value.address!.cityName.toString()),
                    SizedBox(height: 20),
                    _buildInfoBox('Country:', subtitle: controller.getUserData.value.address!.countryName.toString()),
                    SizedBox(height: 20),
                    _buildInfoBox('Pincode:', subtitle: controller.getUserData.value.address!.pincode.toString()),
                    SizedBox(height: 20),
                    _buildInfoBox(
                      'Document Type:',
                      subtitle: controller.getUserData.value.addressProofTypeId.toString(),
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
        ),
      ):Center(child: Text("No Data Found..."),),
    );
  }


  Future<void> _showEditModalSheet(BuildContext context) async {


    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    // child: TextButton(
                    //   onPressed: () {
                    //     bool isValid = _validateFields();
                    //     if (isValid) {
                    //       setState(() {
                    //         _showSuccessMessage();
                    //       });
                    //       Navigator.pop(context);
                    //     } else {
                    //       _showFailureMessage();
                    //     }
                    //   },
                    //   child: const Text(
                    //     "Save",
                    //     style: TextStyle(
                    //       color: Color(0xFFDC3545), // Red text color
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                  ),
                ),
                // Main content of the modal with editable fields
                // _buildTextField(
                //   label: "Building Name",
                //   controller: ,
                // ),
                // const SizedBox(height: 10),
                // _buildTextField(
                //   label: "Flat No",
                //   controller:
                // ),
                // const SizedBox(height: 10),
                // _buildTextField(
                //   label: "Zone",
                //   onChanged: (value) => zone = value,
                // ),
                // const SizedBox(height: 10),
                // _buildTextField(
                //   label: "Area",
                //   onChanged: (value) => area = value,
                // ),
                // const SizedBox(height: 10),
                // _buildTextField(
                //   label: "State",
                //   onChanged: (value) => state = value,
                // ),
                // const SizedBox(height: 10),
                // _buildTextField(
                //   label: "City",
                //   onChanged: (value) => city = value,
                // ),
                // const SizedBox(height: 10),
                // _buildTextField(
                //   label: "Country",
                //   onChanged: (value) => country = value,
                // ),
                // const SizedBox(height: 10),
                // _buildTextField(
                //   label: "Pincode",
                //   onChanged: (value) => pincode = value,
                // ),
                const SizedBox(height: 10),
                // _buildTextField(
                //   label: "Document Type",
                //   onChanged: (value) => documentType = value,
                // ),
                // const SizedBox(height: 10),
                // _buildTextField(
                //   label: "Document",
                //   onChanged: (value) => document = value,
                // ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label, required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),

    );
  }


  // bool _validateFields() {
  //   return pincode.isNotEmpty;
  // }


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
      backgroundColor: Color(0xFFDC3545),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0), // Add spacing between boxes
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
        children: [
          // Title and Colon
          Container(
            width: 147,
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
                    width: 8),
              ],
            ),
          ),
          // Subtitle
          Expanded(
            child: subtitle != null
                ? Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )
                : const SizedBox.shrink(), // If no subtitle, show nothing
          ),
        ],
      ),
    );
  }
}
