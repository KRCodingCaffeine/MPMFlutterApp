import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/GetProfile/BusinessInfo.dart';
import 'package:mpm/model/GetProfile/Qualification.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class BusinessInformationPage extends StatefulWidget {
  const BusinessInformationPage({
    Key? key,

  }) : super(key: key);

  @override
  State<BusinessInformationPage> createState() => _BusinessInformationPageState();
}

class _BusinessInformationPageState extends State<BusinessInformationPage> {
  UdateProfileController controller=Get.put(UdateProfileController());
  late TextEditingController organisationNameController;
  late TextEditingController officePhoneController;
  late TextEditingController buildingNameController;
  late TextEditingController flatNoController;
  late TextEditingController addressController;
  late TextEditingController areaNameController;
  late TextEditingController cityController;
  late TextEditingController stateNameController;
  late TextEditingController countryNameController;
  late TextEditingController officePincodeController;
  late TextEditingController businessEmailController;
  late TextEditingController websiteController;

  @override
  void initState() {
    super.initState();
    organisationNameController =
        TextEditingController(text: controller.organisationName.value);
    officePhoneController = TextEditingController(text: controller.officePhone.value);
    buildingNameController = TextEditingController(text:  controller.buildingName.value);
    flatNoController = TextEditingController(text: controller.flatNo.value);
    addressController = TextEditingController(text: controller.address.value);
    areaNameController = TextEditingController(text: controller.areaName.value);
    cityController = TextEditingController(text: controller.city.value);
    stateNameController = TextEditingController(text: controller.stateName.value);
    countryNameController = TextEditingController(text: controller.countryName.value);
    officePincodeController = TextEditingController(text: controller.officePincode.value);
    businessEmailController = TextEditingController(text: controller.businessEmail.value);
    websiteController = TextEditingController(text: controller.website.value);
  }

  bool _validateFields() {
    return organisationNameController.text.isNotEmpty &&
        officePhoneController.text.isNotEmpty &&
        buildingNameController.text.isNotEmpty &&
        flatNoController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        areaNameController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        stateNameController.text.isNotEmpty &&
        countryNameController.text.isNotEmpty &&
        officePincodeController.text.isNotEmpty &&
        businessEmailController.text.isNotEmpty &&
        websiteController.text.isNotEmpty;
  }
  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(title: Text('Business Information')),
      body: controller.businessInfoList.value.isEmpty
          ? const Center(child: Text("No Data"))
          : ListView.builder(
        itemCount: controller.businessInfoList.value.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),

              child: educationWidget(controller.businessInfoList.value[index]));
        },
      ),
    );
  }

  Widget educationEditWidget(BusinessInfo value) {
    controller.organisationName.value=value.organisationName.toString();
    organisationNameController =
        TextEditingController(text: controller.organisationName.value);
    officePhoneController = TextEditingController(text: controller.officePhone.value);
    buildingNameController = TextEditingController(text:  controller.buildingName.value);
    flatNoController = TextEditingController(text: controller.flatNo.value);
    addressController = TextEditingController(text: controller.address.value);
    areaNameController = TextEditingController(text: controller.areaName.value);
    cityController = TextEditingController(text: controller.city.value);
    stateNameController = TextEditingController(text: controller.stateName.value);
    countryNameController = TextEditingController(text: controller.countryName.value);
    officePincodeController = TextEditingController(text: controller.officePincode.value);
    businessEmailController = TextEditingController(text: controller.businessEmail.value);
    websiteController = TextEditingController(text: controller.website.value);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTextField(
            label: 'Organisation Name',
            controller: organisationNameController,
          ),
          _buildTextField(
            label: 'Office Phone',
            controller: officePhoneController,
          ),
          _buildTextField(
            label: 'Building Name',
            controller: buildingNameController,
          ),
          _buildTextField(
            label: 'Flat No',
            controller: flatNoController,
          ),
          _buildTextField(
            label: 'Address',
            controller: addressController,
          ),
          _buildTextField(
            label: 'Area',
            controller: areaNameController,
          ),
          _buildTextField(
            label: 'City',
            controller: cityController,
          ),
          _buildTextField(
            label: 'State',
            controller: stateNameController,
          ),
          _buildTextField(
            label: 'Country',
            controller: countryNameController,
          ),
          _buildTextField(
            label: 'Office Pincode',
            controller: officePincodeController,
          ),
          _buildTextField(
            label: 'Business Email',
            controller: businessEmailController,
          ),
          _buildTextField(
            label: 'Website',
            controller: websiteController,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDC3545),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 40.0,
                  ),
                ),
                onPressed: () {
                  if (_validateFields()) {
                    // widget.onBusinessInfoChanged(
                    //   organisationNameController.text,
                    //   officePhoneController.text,
                    //   buildingNameController.text,
                    //   flatNoController.text,
                    //   addressController.text,
                    //   areaNameController.text,
                    //   cityController.text,
                    //   stateNameController.text,
                    //   countryNameController.text,
                    //   officePincodeController.text,
                    //   businessEmailController.text,
                    //   websiteController.text,
                    // );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Changes saved successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Save'),
              ),
            ],
          )
        ],
      ),
    );
  }
  Widget educationWidget(BusinessInfo value){
    controller.organisationName.value=value.organisationName.toString();
    return  GestureDetector(
      onTap: () {

      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        color: Colors.white,
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBox(
                  'Organisation Name',
                  subtitle: value.organisationName.toString(),
                ),
                _buildInfoBox(
                  'Office Phone',
                  subtitle: value.officePhone.toString(),
                ),
                _buildInfoBox(
                  'Building Name',
                  subtitle: value.buildingNameId.toString(),
                ),
                _buildInfoBox(
                  'Flat No',
                  subtitle: value.flatNo.toString(),
                ),

                _buildInfoBox(
                  'Address',
                  subtitle: value.address.toString(),
                ), _buildInfoBox(
                  'Adrea',
                  subtitle: value.areaName.toString(),
                ),
                _buildInfoBox(
                  'City',
                  subtitle: value.cityName.toString(),
                ),
                _buildInfoBox(
                  'State',
                  subtitle: value.stateName.toString(),
                ),
                _buildInfoBox(
                  'Country',
                  subtitle: value.countryName.toString(),
                ),
                _buildInfoBox(
                  'Office Pincode',
                  subtitle: value.pincode.toString(),
                ),
                _buildInfoBox(
                   'Business Email',
                  subtitle: value.businessEmail.toString(),
                ),
                _buildInfoBox(
                  'Website',
                  subtitle: value.website.toString(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
  Widget _buildInfoBox(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
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
                const SizedBox(width: 8),
              ],
            ),
          ),
          if (subtitle != null)
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
}
