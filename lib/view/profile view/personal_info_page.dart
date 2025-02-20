import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/bloodgroup/BloodData.dart';
import 'package:mpm/model/gender/DataX.dart';
import 'package:mpm/model/marital/MaritalData.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({Key? key}) : super(key: key);

  @override
  _PersonalInformationPageState createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  UdateProfileController controller=Get.put(UdateProfileController());
NewMemberController newMemberController =Get.put(NewMemberController());
  // Controllers for the text fields to manage user input


  @override
  void initState() {
    super.initState();


  }

  @override
  void dispose() {
    // Dispose of controllers when no longer needed
    controller.firstNameController.value.dispose();
    controller.middleNameController.value.dispose();
    controller.surNameController.value.dispose();
    controller.fathersNameController.value.dispose();
    controller. mothersNameController.value.dispose();
    controller.mobileNumberController.value.dispose();
    controller. whatsAppNumberController.value.dispose();
    controller. emailController.value.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Personal Info'),
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
        body: Container(
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

                      Obx((){
                        return  _buildInfoBox(
                          'Full Name:',
                          subtitle:
                          '${controller.firstName.value} ${controller.middleName.value.isNotEmpty ? "${controller.middleName.value} " : ""}${controller.surName.value}',
                        );
                      }),
                      SizedBox(height: 20),

                      Obx((){
                        return  _buildInfoBox('Father\'s Name:', subtitle: controller.fathersName.value);
                      }),
                      SizedBox(height: 20),
                      Obx((){
                        return  _buildInfoBox('Mother\'s Name:', subtitle: controller.mothersName.value);
                      }),
                      SizedBox(height: 20),
                      Obx((){
                        return  _buildInfoBox('Mobile Number:', subtitle: controller.mobileNumber.value);
                      }),
                      SizedBox(height: 20),
                      Obx((){
                        return  _buildInfoBox('WhatsApp Number:', subtitle: controller.whatsAppNumber.value);
                      }),
                      Obx((){
                        return  _buildInfoBox('Email:', subtitle: controller.email.value);
                      }),
                      SizedBox(height: 20),
                      _buildInfoBox('Date of Birth:', subtitle: controller.dob.value),
                      SizedBox(height: 20),
                      Obx((){
                        return  _buildInfoBox('Gender:', subtitle: controller.gender.value);
                      }),
                      SizedBox(height: 20),
                      Obx((){
                        return  _buildInfoBox('Marital Status:', subtitle: controller.maritalStatus.value);

                      }),
                      SizedBox(height: 20),
                      Obx((){
                        return   _buildInfoBox('Blood Group:', subtitle: controller.bloodGroup.value);
                      })
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
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
                    // Top row with Save button on the right side
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .end, // Move the button to the right
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 8.0, // Reduced bottom padding
                              top: 8.0, // Optionally reduce top padding as well
                            ),
                            child: TextButton(
                              onPressed: () {

                                controller.userUpdateProfile(context,"1");


                                // _showSuccessMessage();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Color(0xFFDC3545), // Red color for text
                              ),
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Expanded section with editable fields
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx((){
                              return _buildEditableField(
                                'First Name',
                                controller.firstNameController.value,

                              );
                            }),
                            Obx((){
                              return _buildEditableField(
                                'Middle Name',
                                controller.middleNameController.value,

                              );
                            }),
                            Obx((){
                              return _buildEditableField(
                                'SurName',
                                controller.surNameController.value);

                            }),


                             Obx((){
                              return  _buildEditableField(
                                  'Fathers Name',
                                  controller.fathersNameController.value);
                            }),

                            Obx((){
                              return  _buildEditableField(
                                'Mother Name',
                                controller.mothersNameController.value
                              );
                            }),
                            Obx((){
                              return  _buildEditableField(
                                'Mobile Number',
                                controller.mobileNumberController.value,

                              );
                            }),
                            Obx((){
                              return  _buildEditableField(
                                  'WhatsApp Number',
                                  controller.whatsAppNumberController.value,

                              );
                            }),
                            Obx((){
                              return _buildEditableField(
                                'Email',
                                controller.emailController.value
                              );
                            }),
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                margin: const EdgeInsets.only(left: 5, right: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  readOnly: true,
                                  controller: newMemberController.dateController,
                                  decoration: const InputDecoration(
                                    hintText:
                                    'Date of Birth *', // Match the hint text
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                      builder:
                                          (BuildContext context, Widget? child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: ColorHelperClass.getColorFromHex(ColorResources.red_color), // Apply red color
                                              onPrimary: Colors
                                                  .white, // Text color on primary button
                                              onSurface: Colors
                                                  .black, // Text color on surface
                                            ),
                                            textButtonTheme: TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor: ColorHelperClass
                                                    .getColorFromHex(ColorResources
                                                    .red_color), // Buttons color
                                              ),
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (pickedDate != null) {
                                      String formattedDate =
                                      DateFormat('dd/MM/yyyy')
                                          .format(pickedDate);
                                      setState(() {
                                        newMemberController.dateController.text =
                                            formattedDate;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            //Gender
                            Container(
                              margin: const EdgeInsets.only(left: 5, right: 5),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Obx(() {
                                    if (newMemberController.rxStatusLoading2.value ==
                                        Status.LOADING) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 22),
                                        child: Container(
                                            alignment: Alignment.centerRight,
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: ColorHelperClass
                                                  .getColorFromHex(
                                                  ColorResources.pink_color),
                                            )),
                                      );
                                    } else if (newMemberController
                                        .rxStatusLoading2.value ==
                                        Status.ERROR) {
                                      return const Center(
                                          child: Text('Failed to load genders'));
                                    } else if (newMemberController
                                        .genderList.isEmpty) {
                                      return const Center(
                                          child: Text('No genders available'));
                                    } else {
                                      return Expanded(
                                        child: DropdownButton<String>(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          underline: Container(),
                                          isExpanded: true,
                                          hint: const Text(
                                            'Select Gender',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          value: newMemberController
                                              .selectedGender.value.isEmpty
                                              ? null
                                              : newMemberController
                                              .selectedGender.value,
                                          items: newMemberController.genderList
                                              .map((DataX gender) {
                                            return DropdownMenuItem<String>(
                                              value: gender.id
                                                  .toString(), // Use unique ID or any unique property.
                                              child: Text(gender.genderName ??
                                                  'Unknown'), // Display name from DataX.
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              newMemberController.setSelectedGender(newValue);
                                            }
                                          },
                                        ),
                                      );
                                    }
                                  })
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            //Blood Group
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(left: 5, right: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Obx(() {
                                    if (newMemberController.rxStatusLoading.value ==
                                        Status.LOADING) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 22),
                                        child: Container(
                                            alignment: Alignment.centerRight,
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: ColorHelperClass
                                                  .getColorFromHex(
                                                  ColorResources.pink_color),
                                            )),
                                      );
                                    } else if (newMemberController
                                        .rxStatusLoading.value ==
                                        Status.ERROR) {
                                      return const Center(
                                          child:
                                          Text('Failed to load blood group'));
                                    } else if (newMemberController
                                        .bloodgroupList.isEmpty) {
                                      return const Center(
                                          child:
                                          Text('No blood gruop available'));
                                    } else {
                                      return Expanded(
                                        child: DropdownButton<String>(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          isExpanded: true,
                                          underline: Container(),
                                          hint: const Text(
                                            'Select Blood Group',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ), // Hint to show when nothing is selected
                                          value: newMemberController
                                              .selectBloodGroup.value.isEmpty
                                              ? null
                                              : newMemberController
                                              .selectBloodGroup.value,

                                          items: newMemberController.bloodgroupList
                                              .map((BloodGroupData marital) {
                                            return DropdownMenuItem<String>(
                                              value: marital.id
                                                  .toString(), // Use unique ID or any unique property.
                                              child: Text(marital.bloodGroup ??
                                                  'Unknown'), // Display name from DataX.
                                            );
                                          }).toList(), // Convert to List.
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              newMemberController.setSelectedBloodGroup(newValue);
                                            }
                                          },
                                        ),
                                      );
                                    }
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                margin: const EdgeInsets.only(left: 5, right: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    Obx(() {
                                      if (newMemberController.rxStatusmarried.value ==
                                          Status.LOADING) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 22),
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: ColorHelperClass
                                                  .getColorFromHex(
                                                  ColorResources.pink_color),
                                            ),
                                          ),
                                        );
                                      } else if (newMemberController
                                          .rxStatusmarried.value ==
                                          Status.ERROR) {
                                        return const Center(
                                            child: Text(
                                                'Failed to load marital status'));
                                      } else if (newMemberController
                                          .maritalList.isEmpty) {
                                        return const Center(
                                            child: Text(
                                                'No marital status available'));
                                      } else {
                                        return Expanded(
                                          child: DropdownButton<String>(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            isExpanded: true,
                                            underline: Container(),
                                            hint: const Text(
                                              'Select marital status',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            value: newMemberController
                                                .selectMarital.value.isEmpty
                                                ? null
                                                : newMemberController
                                                .selectMarital.value,
                                            items: newMemberController.maritalList
                                                .map((MaritalData marital) {
                                              return DropdownMenuItem<String>(
                                                value: marital.id.toString(),
                                                child: Text(
                                                    marital.maritalStatus ??
                                                        'Unknown'),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                newMemberController.setSelectedMarital(newValue);
                                              }
                                            },
                                          ),
                                        );
                                      }
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Obx((){
                              return  Visibility(
                                  visible: newMemberController.MaritalAnnivery.value==true,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Container(
                                          margin:
                                          const EdgeInsets.only(left: 5, right: 5),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: TextFormField(
                                            keyboardType: TextInputType.text,
                                            readOnly: true,
                                            controller: newMemberController.marriagedateController.value,
                                            decoration: InputDecoration(
                                              hintText: 'Marriage Anniversary *',
                                              border: InputBorder.none, // Remove the internal border
                                              contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 20),
                                            ),
                                            onTap: () async{
                                              DateTime? pickedDate = await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime.now(),
                                              );
                                              if (pickedDate != null) {
                                                String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                                                setState(() {
                                                  newMemberController.marriagedateController.value.text = formattedDate;
                                                });
                                              }

                                            },
                                          ),

                                        ),
                                      ),
                                    ],
                                  ));
                            }),
                            const SizedBox(height: 80),



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
    return controller.firstName.value.isNotEmpty && controller.dob.value.isNotEmpty;
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
      String label, TextEditingController controller) {
    return Padding(
      padding:  EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),

      ),
    );
  }

  // Method to build the information boxes
  Widget _buildInfoBox(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0), // Add spacing between boxes
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
        children: [
          // Title and Colon
          Container(
            width: 147, // Adjust width for alignment
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
