import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/model/EventTripModel/TripMemberRegistration/TripMemberRegistrationData.dart';
import 'package:mpm/repository/EventTripRepository/member_register_trip_repository/member_register_trip_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/EventTrip/event_trip.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:open_filex/open_filex.dart';

class TripMembersFormPage extends StatefulWidget {
  final int tripId;
  final int memberId;
  final TripMemberRegistrationData? existingData;

  const TripMembersFormPage({
    super.key,
    required this.tripId,
    required this.memberId,
    this.existingData,
  });

  @override
  _TripMembersFormPageState createState() => _TripMembersFormPageState();
}

class _TripMembersFormPageState extends State<TripMembersFormPage> {
  bool isSpeedDialOpen = false;
  UdateProfileController controller = Get.put(UdateProfileController());

  final Rx<File?> _image = Rx<File?>(null);
  final RxString selectedMemberId = "".obs;
  final RxString selectedAgeGroup = ''.obs;

  final TripMemberRegistrationRepository repo = TripMemberRegistrationRepository();
  final RxList<TripMemberRegistrationData> memberList = <TripMemberRegistrationData>[].obs;

  final TextEditingController memberNameController = TextEditingController();
  final TextEditingController relationController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController specialRequirementsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Add Journey Members',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Obx(() {
        if (memberList.isEmpty) {
          return const Center(child: Text("No members added yet..."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: memberList.length,
          itemBuilder: (context, index) {
            return _buildMemberCard(memberList[index]);
          },
        );
      }),

      floatingActionButton: SpeedDial(
        icon: isSpeedDialOpen ? Icons.close : Icons.add,
        activeIcon: Icons.close,
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
        foregroundColor: Colors.white,
        overlayOpacity: 0.5,
        spacing: 10,
        spaceBetweenChildren: 10,
        onOpen: () => setState(() => isSpeedDialOpen = true),
        onClose: () => setState(() => isSpeedDialOpen = false),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.person_add),
            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
            foregroundColor: Colors.white,
            label: 'Add Member',
            labelStyle: const TextStyle(fontSize: 16),
            onTap: () {
              _showMemberDetailsSheet(context);
            },
          ),
        ],
      ),

      bottomNavigationBar: Obx(() {
        if (memberList.isEmpty) return const SizedBox.shrink();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => EventTripPage()),
                  );
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text(
                  "Back to Trips",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  ColorHelperClass.getColorFromHex(ColorResources.red_color),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _registerTripMember() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData == null || userData.memberId == null) {
        throw Exception('User not logged in');
      }

      final registrationData = TripMemberRegistrationData(
        memberId: widget.memberId.toString(),
        tripId: widget.tripId.toString(),
        addedBy: userData.memberId.toString(),
        travellerNames: [memberNameController.text.trim()],
      );

      debugPrint("Sending Trip Member Registration: ${registrationData.toJson()}");

      final response = await repo.registerForTrip(registrationData);

      if (response['status'] == true) {
        if (response['already_registered'] == true) {
          await _showAlreadyRegisteredDialog(response['message']);
        } else {
          memberList.add(registrationData);

          // Clear form
          memberNameController.clear();
          await _showSuccessDialog('Successfully added member to the trip');
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to register member');
      }
    } catch (e) {
      await _showErrorDialog('Something went wrong please try again');
    }
  }

  Future<void> _showAlreadyRegisteredDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Already Registered",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Success",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Error",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMemberCard(TripMemberRegistrationData member) {
    return Card(
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Traveller(s): ${member.travellerNames?.join(', ') ?? ''}",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[100],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        _registerTripMember();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Obx(() {
                        final familyList = controller.familyDataList;

                        if (familyList.isEmpty) {
                          return const Center(child: Text('No Members available'));
                        } else {
                          final selectedValue = selectedMemberId.value;

                          return Expanded(
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: selectedValue.isNotEmpty ? 'Select Family Member *' : null,
                                border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black38, width: 1)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                labelStyle: const TextStyle(color: Colors.black),
                              ),
                              child: DropdownButton<String>(
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                isExpanded: true,
                                underline: Container(),
                                hint: const Text('Select Family Member *', style: TextStyle(fontWeight: FontWeight.bold)),
                                value: selectedValue.isNotEmpty ? selectedValue : null,
                                items: familyList.map((member) {
                                  return DropdownMenuItem<String>(
                                    value: member.memberId.toString(),
                                    child: Text("${member.firstName} ${member.middleName ?? ''} ${member.lastName}"),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    selectedMemberId.value = newValue;

                                    final selectedMember = controller.familyDataList.firstWhereOrNull(
                                            (m) => m.memberId.toString() == newValue
                                    );

                                    if (selectedMember != null) {
                                      final fullName = [
                                        selectedMember.firstName,
                                        selectedMember.middleName ?? "",
                                        selectedMember.lastName ?? ""
                                      ].where((name) => name.isNotEmpty).join(" ");

                                      memberNameController.text = fullName;
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                _buildTextField(
                    label: "Relation",
                    controller: relationController,
                    type: TextInputType.text,
                    empty: "Enter relation"
                ),
                _buildTextField(
                    label: "Age",
                    controller: ageController,
                    type: TextInputType.number,
                    empty: "Enter age"
                ),
                Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          final ageGroups = ['Child (0-12)', 'Teen (13-19)', 'Adult (20-59)', 'Senior (60+)'];
                          final selectedValue = selectedAgeGroup.value;

                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: selectedValue.isNotEmpty ? 'Age Group *' : null,
                              border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black38, width: 1)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              labelStyle: const TextStyle(color: Colors.black),
                            ),
                            child: DropdownButton<String>(
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              isExpanded: true,
                              underline: Container(),
                              hint: const Text('Age Group *', style: TextStyle(fontWeight: FontWeight.bold)),
                              value: selectedValue.isNotEmpty ? selectedValue : null,
                              items: ageGroups.map((group) {
                                return DropdownMenuItem<String>(
                                  value: group,
                                  child: Text(group),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  selectedAgeGroup.value = newValue;
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                _buildTextField(
                    label: "Special Requirements",
                    controller: specialRequirementsController,
                    type: TextInputType.text,
                    empty: "Enter any special requirements"
                ),
                const SizedBox(height: 25),
                Obx(() {
                  return Column(
                    children: [
                      if (_image.value != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_image.value!, fit: BoxFit.cover),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showImagePicker(context),
                          icon: const Icon(Icons.image),
                          label: const Text("Upload ID Proof"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImagePicker(BuildContext context) async {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text("Take a Picture"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  _image.value = File(pickedFile.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.redAccent),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  _image.value = File(pickedFile.path);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required TextInputType type,
    required String empty,
    bool readOnly = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: type,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          hintStyle: const TextStyle(color: Colors.black54),
          border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black38, width: 1)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return empty;
          return null;
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const Text(" : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDocument(String filePath) async {
    try {
      await OpenFilex.open(filePath);
    } catch (e) {
      Get.snackbar("Error", "Unable to open document");
    }
  }
}