import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/model/GetProfile/FamilyHeadMemberData.dart';
import 'package:mpm/model/GetProfile/FamilyMembersData.dart';
import 'package:mpm/model/relation/RelationData.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view_model/controller/samiti/SamitiController.dart';

import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

import '../../model/bloodgroup/BloodData.dart';
import '../../model/gender/DataX.dart';
import '../../model/marital/MaritalData.dart';
import '../../model/membersalutation/MemberSalutationData.dart';
import '../../model/membership/MemberShipData.dart';
import '../../view_model/controller/dashboard/NewMemberController.dart';

class FamilyInfoPage extends StatefulWidget {
  final String? successMessage;
  final String? failureMessage;

  const FamilyInfoPage({Key? key, this.successMessage, this.failureMessage})
      : super(key: key);

  @override
  _FamilyInfoPageState createState() => _FamilyInfoPageState();
}

class _FamilyInfoPageState extends State<FamilyInfoPage> {
  bool isSpeedDialOpen = false;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String? currentMemberId;

  Rx<File?> selectimage = Rx<File?>(null);
  UdateProfileController controller = Get.put(UdateProfileController());
  String firstName = "Rajesh";
  String middleName = "Mani";
  String surName = "Nair";
  String relationshipName = 'Husband';
  String mobileNumber = '9920113198';
  String whatsAppNumber = '9920113198';

  List<Map<String, dynamic>> familyMembers = [];
  final regiController = Get.put(NewMemberController());
  final SamitiController samitiController = Get.put(SamitiController());

  @override
  void initState() {
    super.initState();
    regiController.getGender();
    regiController.getMaritalStatus();
    regiController.getBloodGroup();
    regiController.getMemberShip();
    regiController.getDocumentType();
    regiController.getMemberSalutation();
    regiController.getCountry();
    regiController.getState();
    regiController.getCity();
    _loadSessionData();
  }

  void _loadSessionData() async {
    CheckUserData2? userData = await SessionManager.getSession();
    setState(() {
      currentMemberId = userData?.memberId?.toString();
    });
  }

  // Update your build method:
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
              "Family Info",
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Family Head Card
                Obx(() {
                  if (controller.familyHeadData.value != null) {
                    return _buildFamilyHeadCard(
                        context, controller.familyHeadData.value!);
                  }
                  return SizedBox.shrink();
                }),
                const SizedBox(height: 4),
                Expanded(
                  child: Obx(() {
                    // Sort family members by age (oldest first)
                    final List<FamilyMembersData> sortedList = List.of(controller.familyDataList.value)
                      ..sort((a, b) {
                        // Parse dates, handling null and empty cases
                        final aDate = _parseDate(a.dob);
                        final bDate = _parseDate(b.dob);

                        // If both dates are invalid, maintain original order
                        if (aDate == null && bDate == null) return 0;
                        // Put invalid dates at the end
                        if (aDate == null) return 1;
                        if (bDate == null) return -1;

                        // Compare dates (oldest first)
                        return aDate.compareTo(bDate);
                      });

                    return ListView.builder(
                      itemCount: sortedList.length,
                      itemBuilder: (context, index) =>
                          _buildFamilyMemberCard(context, sortedList[index]),
                    );
                  }),
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        // Only show FAB if current user is family head
        if (controller.familyHeadData.value?.memberId == currentMemberId) {
          return SpeedDial(
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
                label: 'New NM Member',
                labelStyle: TextStyle(fontSize: 16),
                onTap: () {
                  _showAddModalSheet(context);
                },
              ),
              SpeedDialChild(
                child: const Icon(Icons.person),
                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                label: 'Existing Member',
                labelStyle: TextStyle(fontSize: 16),
                onTap: () {
                  _showExistingMemberModal(context);
                },
              ),
            ],
          );
        } else {
          return SizedBox.shrink(); // Hide FAB if not family head
        }
      }),
    );
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      // Try common date formats
      final formats = [
        'yyyy-MM-dd',
        'dd-MM-yyyy',
        'dd/MM/yyyy',
        'MM/dd/yyyy',
        'yyyy/MM/dd'
      ];

      for (var format in formats) {
        try {
          return DateFormat(format).parseStrict(dateString);
        } catch (_) {}
      }

      // If none of the formats worked, return null
      return null;
    } catch (e) {
      return null;
    }
  }

  Widget _buildFamilyHeadCard(
      BuildContext context, FamilyHeadMemberData headData) {
    return Card(
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: (headData.profileImage != null &&
                  headData.profileImage.isNotEmpty)
              ? NetworkImage(Urls.imagePathUrl + headData.profileImage)
              : const AssetImage("assets/images/user3.png") as ImageProvider,
          backgroundColor: Colors.grey[300],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${headData.firstName != null ? headData.firstName : ""} ${headData.lastName != null ? headData.lastName : ""}"
                  .trim(),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              "Member Code : " +
                  (headData.memberCode != null
                      ? headData.memberCode
                      : headData.memberId != null
                          ? headData.memberId
                          : ""),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              "Family Head",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: (headData.memberId == currentMemberId)
            ? ElevatedButton(
                onPressed: () {
                  _showChangeHeadDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFDC3545),
                  elevation: 4,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
                child: const Text(
                  'Change Head',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : const SizedBox.shrink(), // Hide button if not the head
      ),
    );
  }

  void _showChangeHeadDialog(BuildContext context) {
    final selectedMember = Rxn<String>();
    final isRelationSelected = false.obs;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              final isChangeEnabled = selectedMember.value != null &&
                  controller.selectRelationShipType.value.isNotEmpty;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Change Family Head",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Divider(thickness: 1, color: Colors.black38),
                  const SizedBox(height: 16),

                  // Current Head Info
                  Obx(() {
                    final headData = controller.familyHeadData.value;
                    if (headData != null) {
                      return Text(
                        "Current Head: ${headData.firstName ?? ''} ${headData.lastName ?? ''}"
                            .trim(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 20),

                  // New Head Dropdown
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: double.infinity,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: selectedMember.value != null
                                ? 'Select New Head *'
                                : null,
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black38, width: 1)),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            labelStyle: const TextStyle(color: Colors.black),
                          ),
                          child: DropdownButton<String>(
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: const Text(
                              'Select New Head *',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            value: selectedMember.value,
                            items: controller.familyDataList.value
                                .where((member) =>
                                    member.memberId !=
                                    controller.familyHeadData.value?.memberId)
                                .map((member) {
                              return DropdownMenuItem<String>(
                                value: member.memberId,
                                child: Text(
                                    "${member.firstName ?? ''} ${member.lastName ?? ''}"
                                        .trim()),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              selectedMember.value = newValue;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),

                  // Relation Dropdown
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: double.infinity,
                        child: Row(
                          children: [
                            Obx(() {
                              if (controller.rxStatusRelationType.value ==
                                  Status.LOADING) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 22),
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                );
                              } else if (controller
                                      .rxStatusRelationType.value ==
                                  Status.ERROR) {
                                return const Expanded(
                                    child:
                                        Text('Failed to load relation types'));
                              } else if (controller
                                  .relationShipTypeList.isEmpty) {
                                return const Expanded(
                                    child: Text('No relation available'));
                              } else {
                                final selectedValue =
                                    controller.selectRelationShipType.value;
                                return Expanded(
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: selectedValue.isNotEmpty
                                          ? 'Select Current Head Relation *'
                                          : null,
                                      border: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      enabledBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black38, width: 1)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20),
                                      labelStyle:
                                          const TextStyle(color: Colors.black),
                                    ),
                                    child: DropdownButton<String>(
                                      dropdownColor: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      isExpanded: true,
                                      underline: Container(),
                                      hint: const Text(
                                        'Select Relation *',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      value: selectedValue.isNotEmpty
                                          ? selectedValue
                                          : null,
                                      items: controller.relationShipTypeList
                                          .map((RelationData relation) {
                                        return DropdownMenuItem<String>(
                                          value: relation.id.toString(),
                                          child:
                                              Text(relation.name ?? 'Unknown'),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          controller
                                              .setSelectRelationShip(newValue);
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
                      const SizedBox(height: 30),
                    ],
                  ),

                  // Footer Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                            side: BorderSide(
                                color: ColorHelperClass.getColorFromHex(
                                    ColorResources.red_color)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isChangeEnabled
                              ? () async {
                                  if (selectedMember.value != null &&
                                      controller.selectRelationShipType.value
                                          .isNotEmpty) {
                                    final success =
                                        await controller.changeFamilyHead(
                                      selectedMember.value!,
                                      controller.selectRelationShipType.value,
                                    );
                                    if (success) {
                                      Navigator.pop(context);
                                    }
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Obx(() {
                            return controller.familyloading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Change Head");
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildFamilyMemberCard(BuildContext context, FamilyMembersData member) {
    return Card(
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: (member.profileImage != null &&
              member.profileImage.isNotEmpty)
              ? NetworkImage(Urls.imagePathUrl + member.profileImage)
              : const AssetImage("assets/images/user3.png") as ImageProvider,
          backgroundColor: Colors.grey[300],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${member.firstName ?? ""} ${member.lastName ?? ""}".trim(),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              "Member Code: " +
                  (member.memberCode ?? member.memberId ?? "N/A"),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              "Relation: ${member.relationshipName ?? "N/A"}",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Container(
          child: ElevatedButton(
            onPressed: () {
              controller.selectRelationShipType(member.relationshipTypeId);
              _showEditModalSheet(context, member.memberId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFDC3545),
              elevation: 4,
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit, size: 12),
                const SizedBox(width: 4),
                const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExistingMemberModal(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final FocusNode searchFocusNode = FocusNode();
    var debounceTimer;

    // Clear previous selections when opening dialog
    samitiController.searchDataList.clear();
    samitiController.selectedMember.value = '';
    controller.selectRelationShipType.value = '';

    showDialog(
      context: context,
      builder: (context) {
        return Obx(() {
          final isAddEnabled =
              samitiController.selectedMember.value.isNotEmpty &&
                  controller.selectRelationShipType.value.isNotEmpty;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            backgroundColor: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Add Existing Member",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Divider(thickness: 1, color: Colors.black38),
                  const SizedBox(height: 16),

                  // Search field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            focusNode: searchFocusNode,
                            decoration: const InputDecoration(
                              hintText: "Search by name or member code",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              if (debounceTimer != null) {
                                debounceTimer.cancel();
                              }
                              if (value.length >= 3) {
                                samitiController.getSearchLPM(value);
                              } else {
                                samitiController.searchDataList.clear();
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            if (searchController.text.isNotEmpty) {
                              samitiController
                                  .getSearchLPM(searchController.text);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Loading or results
                  if (samitiController.loading2.value)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (samitiController.searchDataList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No members found"),
                    )
                  else
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: samitiController.searchDataList.length,
                        itemBuilder: (context, index) {
                          final member = samitiController.searchDataList[index];
                          return Card(
                            color: samitiController.selectedMember.value ==
                                    member.memberId
                                ? Colors.grey[200]
                                : Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                onTap: () {
                                  samitiController.selectedMember.value =
                                      member.memberId!;
                                },
                                leading: CircleAvatar(
                                  radius: 23,
                                  backgroundImage:
                                      member.profileImage != null &&
                                              member.profileImage!.isNotEmpty
                                          ? NetworkImage(Urls.imagePathUrl +
                                              member.profileImage!)
                                          : const AssetImage(
                                                  "assets/images/user3.png")
                                              as ImageProvider,
                                  backgroundColor: Colors.grey[300],
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "${member.firstName ?? ''} ${member.lastName ?? ''}"
                                          .trim(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Member Code: ",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          member.memberCode ?? "--",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (member.mobile != null &&
                                        member.mobile!.isNotEmpty)
                                      Row(
                                        children: [
                                          Text(
                                            "Mobile: ",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            member.mobile!,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),

                  if (samitiController.selectedMember.value.isNotEmpty)
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          width: double.infinity,
                          child: Row(
                            children: [
                              Obx(() {
                                if (controller.rxStatusRelationType.value ==
                                    Status.LOADING) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 22),
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  );
                                } else if (controller
                                        .rxStatusRelationType.value ==
                                    Status.ERROR) {
                                  return const Center(
                                      child: Text('Failed to load relation'));
                                } else if (controller
                                    .relationShipTypeList.isEmpty) {
                                  return const Center(
                                      child: Text('No relation available'));
                                } else {
                                  final selectedValue =
                                      controller.selectRelationShipType.value;
                                  return Expanded(
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: selectedValue.isNotEmpty
                                            ? 'Select Relation *'
                                            : null,
                                        border: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black38, width: 1),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20),
                                        labelStyle: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      child: DropdownButton<String>(
                                        dropdownColor: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        isExpanded: true,
                                        underline: Container(),
                                        hint: const Text(
                                          'Select Relation *',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        value: selectedValue.isNotEmpty
                                            ? selectedValue
                                            : null,
                                        items: controller.relationShipTypeList
                                            .map((RelationData relation) {
                                          return DropdownMenuItem<String>(
                                            value: relation.id.toString(),
                                            child: Text(
                                                relation.name ?? 'Unknown'),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            controller.setSelectRelationShip(
                                                newValue);
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
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Footer buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                          side: BorderSide(
                              color: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: isAddEnabled
                            ? () async {
                                final success =
                                    await controller.addExistingFamilyMember(
                                  samitiController.selectedMember.value,
                                  controller.selectRelationShipType.value,
                                );

                                if (success) {
                                  Navigator.pop(context);
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Obx(() {
                          return controller.familyloading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Add");
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    ).then((_) {
      // Clear selections when dialog is closed
      samitiController.searchDataList.clear();
      samitiController.selectedMember.value = '';
      searchController.clear();
    });
  }

  void _showEditModalSheet(BuildContext context, String index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[100],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.updateFamilyRelation(context, index);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Save"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
                    child: Row(
                      children: [
                        Obx(() {
                          if (controller.rxStatusRelationType.value ==
                              Status.LOADING) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: Container(
                                alignment: Alignment.centerRight,
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: ColorHelperClass.getColorFromHex(
                                      ColorResources.pink_color),
                                ),
                              ),
                            );
                          } else if (controller.rxStatusRelationType.value ==
                              Status.ERROR) {
                            return const Center(
                                child: Text('Failed to load relation'));
                          } else if (controller.relationShipTypeList.isEmpty) {
                            return const Center(
                                child: Text('No relation available'));
                          } else {
                            return Expanded(
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'RelationShip',
                                  border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black26),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black26),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black26, width: 1.5),
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 20),
                                  labelStyle: TextStyle(
                                    color: Colors.black45,
                                  ),
                                ),
                                isEmpty: controller
                                    .selectRelationShipType.value.isEmpty,
                                child: DropdownButton<String>(
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  isExpanded: true,
                                  underline: Container(),
                                  hint: const Text(
                                    'Select Relation',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  value: controller
                                          .selectRelationShipType.value.isEmpty
                                      ? null
                                      : controller.selectRelationShipType.value,
                                  items: controller.relationShipTypeList
                                      .map((RelationData gender) {
                                    return DropdownMenuItem<String>(
                                      value: gender.id.toString(),
                                      child: Text(gender.name ?? 'Unknown'),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      controller
                                          .setSelectRelationShip(newValue);
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
                  const SizedBox(height: 20),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _showAddModalSheet(BuildContext context) {
    String newSalutation = "";
    String newFirstName = "";
    String newMiddleName = "";
    String newSurName = "";
    String newRelationship = "";
    String newMobileNumber = "";
    String newWhatsAppNumber = "";
    String newFathersName = "";
    String newMothersName = "";
    String newEmail = "";
    String newDob = "";
    String newGender = "";
    String newBloodGroup = "";
    String newMaritalStatus = "";
    String newMembership = "";
    final GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();
    File? newImage;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[100],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8, // Adjusted height factor
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 6.0,
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      // Fixed Buttons (Cancel and Add Member)
                      Container(
                        margin: const EdgeInsets.only(
                            top: 20), // Added margin top here
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Cancel Button
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    ColorHelperClass.getColorFromHex(
                                        ColorResources.red_color),
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Cancel"),
                            ),

                            // Add Member Button
                            Obx(() {
                              return ElevatedButton(
                                onPressed: () async {
                                  if (_formKeyLogin.currentState!.validate()) {
                                    void showErrorSnackbar(String message) {
                                      Get.snackbar(
                                        "Error",
                                        message,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }

                                    // Validate required fields
                                    if (regiController.selectMemberSalutation.value == "") {
                                      showErrorSnackbar("Select Salutation");
                                      return;
                                    }
                                    if (controller.selectRelationShipType.value == "") {
                                      showErrorSnackbar("Select Member Relation");
                                      return;
                                    }
                                    if (regiController.firstNameController.value == "") {
                                      showErrorSnackbar("Enter First Name");
                                      return;
                                    }
                                    if (regiController.lastNameController.value == "") {
                                      showErrorSnackbar("Enter Surname");
                                      return;
                                    }
                                    if (regiController.fathersnameController.value == "") {
                                      showErrorSnackbar("Enter Father's Name");
                                      return;
                                    }
                                    if (regiController.selectedGender.value == "") {
                                      showErrorSnackbar("Select Gender");
                                      return;
                                    }
                                    if (regiController.dateController.text == "") {
                                      showErrorSnackbar("Enter Date of Birth");
                                      return;
                                    }
                                    if (regiController.selectMarital.value == "") {
                                      showErrorSnackbar("Select Marital status");
                                      return;
                                    }
                                    if (regiController.MaritalAnnivery.value == true) {
                                      if (regiController.marriagedateController.value.text == '') {
                                        showErrorSnackbar("Select Marriage Date");
                                        return;
                                      }
                                    } else {
                                      regiController.marriagedateController.value.text = "";
                                    }
                                    controller.userAddFamily(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      ColorHelperClass.getColorFromHex(
                                          ColorResources.red_color),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: controller.familyloading.value
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text("Add Member"),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Scrollable Form Fields
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKeyLogin,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      _showPicker();
                                    },
                                    child: Obx(() {
                                      return CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.grey[300],
                                        backgroundImage:
                                            selectimage.value != null
                                                ? FileImage(selectimage.value!)
                                                : null,
                                        child: selectimage.value == null
                                            ? Icon(
                                                Icons.camera_alt,
                                                color: Colors.grey[700],
                                                size: 40,
                                              )
                                            : null,
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Salutation Dropdown
                                Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  child: Row(
                                    children: [
                                      Obx(() {
                                        if (regiController
                                                .rxStatusMemberSalutation
                                                .value ==
                                            Status.LOADING) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 22),
                                            child: SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          );
                                        } else if (regiController
                                                .rxStatusMemberSalutation
                                                .value ==
                                            Status.ERROR) {
                                          return const Center(
                                              child: Text(
                                                  'Failed to load salutation'));
                                        } else if (regiController
                                            .memberSalutationList.isEmpty) {
                                          return const Center(
                                              child: Text(
                                                  'No salutation available'));
                                        } else {
                                          final selectedValue = regiController
                                              .selectMemberSalutation.value;
                                          return Expanded(
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                labelText:
                                                    selectedValue.isNotEmpty
                                                        ? 'Salutation *'
                                                        : null,
                                                border:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black),
                                                ),
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black),
                                                ),
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black38,
                                                      width: 1),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                labelStyle: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              child: DropdownButton<String>(
                                                dropdownColor: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                isExpanded: true,
                                                underline: Container(),
                                                hint: const Text(
                                                  'Select Salutation *',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                value: selectedValue.isNotEmpty
                                                    ? selectedValue
                                                    : null,
                                                items: regiController
                                                    .memberSalutationList
                                                    .map((MemberSalutationData
                                                        item) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: item
                                                        .memberSalutaitonId
                                                        .toString(),
                                                    child: Text(
                                                        item.salutationName ??
                                                            'Unknown'),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  if (newValue != null) {
                                                    regiController
                                                        .selectMemberSalutation(
                                                            newValue);
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
                                const SizedBox(height: 30),

                                // Relationship Dropdown
                                Container(
                                  margin:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Obx(() {
                                        if (controller
                                                .rxStatusRelationType.value ==
                                            Status.LOADING) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 22),
                                            child: SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          );
                                        } else if (controller
                                                .rxStatusRelationType.value ==
                                            Status.ERROR) {
                                          return const Center(
                                              child: Text(
                                                  'Failed to load relation'));
                                        } else if (controller
                                            .relationShipTypeList.isEmpty) {
                                          return const Center(
                                              child: Text(
                                                  'No relation available'));
                                        } else {
                                          final selectedValue = controller
                                              .selectRelationShipType.value;
                                          return Expanded(
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                labelText:
                                                    selectedValue.isNotEmpty
                                                        ? 'Select Relation *'
                                                        : null,
                                                border:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black),
                                                ),
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black),
                                                ),
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black38,
                                                      width: 1),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                labelStyle: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              child: DropdownButton<String>(
                                                dropdownColor: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                isExpanded: true,
                                                underline: Container(),
                                                hint: const Text(
                                                  'Select Relation *',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                value: selectedValue.isNotEmpty
                                                    ? selectedValue
                                                    : null,
                                                items: controller
                                                    .relationShipTypeList
                                                    .map((RelationData
                                                        relation) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value:
                                                        relation.id.toString(),
                                                    child: Text(relation.name ??
                                                        'Unknown'),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  if (newValue != null) {
                                                    controller
                                                        .setSelectRelationShip(
                                                            newValue);
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
                                const SizedBox(height: 30),

                                // First Name Field
                                _buildEditableField(
                                  'First Name *',
                                  regiController.firstNameController.value,
                                  'First Name',
                                  'Enter First Name',
                                  text: TextInputType.text,
                                  isRequired: true,
                                ),
                                const SizedBox(height: 30),

                                // Middle Name Field
                                _buildEditableField(
                                  "Middle Name",
                                  regiController.middleNameController.value,
                                  "Middle Name",
                                  "",
                                  text: TextInputType.text,
                                ),
                                const SizedBox(height: 30),

                                // Surname Field
                                _buildEditableField(
                                  "SurName *",
                                  regiController.lastNameController.value,
                                  "SurName",
                                  "",
                                  text: TextInputType.text,
                                  isRequired: true,
                                ),
                                const SizedBox(height: 30),

                                // Mobile Number Field
                                _buildEditableField(
                                  "Mobile Number",
                                  regiController.mobileController.value,
                                  "Mobile Number",
                                  "",  // Empty validation message
                                  text: TextInputType.phone,
                                  maxLength: 10,
                                ),
                                const SizedBox(height: 30),

                                // WhatsApp Number Field
                                _buildEditableField(
                                  "WhatsApp Number",
                                  regiController.whatappmobileController.value,
                                  "WhatsApp Number",
                                  "",  // Empty validation message
                                  text: TextInputType.phone,
                                  maxLength: 10,
                                ),
                                const SizedBox(height: 30),

                                // Father's Name Field
                                _buildEditableField(
                                  "Father's Name *",
                                  regiController.fathersnameController.value,
                                  "Father's Name",
                                  "",
                                  text: TextInputType.text,
                                  isRequired: true,
                                ),
                                const SizedBox(height: 30),

                                // Mother's Name Field
                                _buildEditableField(
                                  "Mother's Name",
                                  regiController.mothersnameController.value,
                                  "Mother's Name",
                                  "",
                                  text: TextInputType.text,
                                ),
                                const SizedBox(height: 30),

                                // Email Field
                                _buildEditableField(
                                  "Email",
                                  regiController.emailController.value,
                                  "Email",
                                  '',
                                  obscureText: false,
                                  text: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 30),

                                // Date of Birth Field
                                SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      readOnly: true,
                                      controller: regiController.dateController,
                                      decoration: InputDecoration(
                                        labelText: regiController
                                                .dateController.text.isNotEmpty
                                            ? 'Date of Birth *'
                                            : null,
                                        hintText: 'Date of Birth *',
                                        border: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black38, width: 1),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 22,
                                        ),
                                        labelStyle: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      onTap: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                          builder: (BuildContext context,
                                              Widget? child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary: ColorHelperClass
                                                      .getColorFromHex(
                                                          ColorResources
                                                              .red_color),
                                                  onPrimary: Colors.white,
                                                  onSurface: Colors.black,
                                                ),
                                                textButtonTheme:
                                                    TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        ColorHelperClass
                                                            .getColorFromHex(
                                                                ColorResources
                                                                    .red_color),
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
                                            regiController.dateController.text =
                                                formattedDate;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Gender Dropdown
                                Container(
                                  margin:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Obx(() {
                                        if (regiController
                                                .rxStatusLoading2.value ==
                                            Status.LOADING) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 22),
                                            child: SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          );
                                        } else if (regiController
                                                .rxStatusLoading2.value ==
                                            Status.ERROR) {
                                          return const Center(
                                              child: Text(
                                                  'Failed to load genders'));
                                        } else if (regiController
                                            .genderList.isEmpty) {
                                          return const Center(
                                              child:
                                                  Text('No genders available'));
                                        } else {
                                          final selectedValue = regiController
                                              .selectedGender.value;
                                          return Expanded(
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                labelText:
                                                    selectedValue.isNotEmpty
                                                        ? 'Select Gender *'
                                                        : null,
                                                border:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black),
                                                ),
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black),
                                                ),
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black38,
                                                      width: 1),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                labelStyle: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              child: DropdownButton<String>(
                                                dropdownColor: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                isExpanded: true,
                                                underline: Container(),
                                                hint: const Text(
                                                  'Select Gender *',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                value: selectedValue.isNotEmpty
                                                    ? selectedValue
                                                    : null,
                                                items: regiController.genderList
                                                    .map((DataX gender) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: gender.id.toString(),
                                                    child: Text(
                                                        gender.genderName ??
                                                            'Unknown'),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  if (newValue != null) {
                                                    regiController
                                                        .setSelectedGender(
                                                            newValue);
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
                                const SizedBox(height: 30),

                                // Blood Group Dropdown
                                Container(
                                  width: double.infinity,
                                  margin:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Row(
                                    children: [
                                      Obx(() {
                                        if (regiController
                                                .rxStatusLoading.value ==
                                            Status.LOADING) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 22),
                                            child: SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          );
                                        } else if (regiController
                                                .rxStatusLoading.value ==
                                            Status.ERROR) {
                                          return const Center(
                                              child: Text(
                                                  'Failed to load blood group'));
                                        } else if (regiController
                                            .bloodgroupList.isEmpty) {
                                          return const Center(
                                              child: Text(
                                                  'No blood group available'));
                                        } else {
                                          final selectedValue = regiController
                                              .selectBloodGroup.value;
                                          return Expanded(
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                labelText:
                                                    selectedValue.isNotEmpty
                                                        ? 'Select Blood Group'
                                                        : null,
                                                border:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black),
                                                ),
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black),
                                                ),
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black38,
                                                      width: 1),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                labelStyle: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              child: DropdownButton<String>(
                                                dropdownColor: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                isExpanded: true,
                                                underline: Container(),
                                                hint: const Text(
                                                  'Select Blood Group',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                value: selectedValue.isNotEmpty
                                                    ? selectedValue
                                                    : null,
                                                items: regiController
                                                    .bloodgroupList
                                                    .map((BloodGroupData
                                                        bloodGroup) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: bloodGroup.id
                                                        .toString(),
                                                    child: Text(
                                                        bloodGroup.bloodGroup ??
                                                            'Unknown'),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  if (newValue != null) {
                                                    regiController
                                                        .setSelectedBloodGroup(
                                                            newValue);
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
                                const SizedBox(height: 30),

                                // Marital Status Dropdown
                                SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: Row(
                                      children: [
                                        Obx(() {
                                          if (regiController
                                                  .rxStatusmarried.value ==
                                              Status.LOADING) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 22),
                                              child: SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            );
                                          } else if (regiController
                                                  .rxStatusmarried.value ==
                                              Status.ERROR) {
                                            return const Center(
                                                child: Text(
                                                    'Failed to load marital status'));
                                          } else if (regiController
                                              .maritalList.isEmpty) {
                                            return const Center(
                                                child: Text(
                                                    'No marital status available'));
                                          } else {
                                            final selectedValue = regiController
                                                .selectMarital.value;
                                            return Expanded(
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  labelText: selectedValue
                                                          .isNotEmpty
                                                      ? 'Select Marital Status *'
                                                      : null,
                                                  border:
                                                      const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black),
                                                  ),
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black),
                                                  ),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black38,
                                                        width: 1),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20),
                                                  labelStyle: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                                child: DropdownButton<String>(
                                                  dropdownColor: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  isExpanded: true,
                                                  underline: Container(),
                                                  hint: const Text(
                                                    'Select Marital Status *',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  value:
                                                      selectedValue.isNotEmpty
                                                          ? selectedValue
                                                          : null,
                                                  items: regiController
                                                      .maritalList
                                                      .map((MaritalData
                                                          marital) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value:
                                                          marital.id.toString(),
                                                      child: Text(marital
                                                              .maritalStatus ??
                                                          'Unknown'),
                                                    );
                                                  }).toList(),
                                                  onChanged:
                                                      (String? newValue) {
                                                    if (newValue != null) {
                                                      regiController
                                                          .setSelectedMarital(
                                                              newValue);
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
                                ),
                                const SizedBox(height: 30),

                                // Show Marriage Anniversary Date ONLY if Married
                                Obx(() {
                                  return Visibility(
                                    visible:
                                        regiController.MaritalAnnivery.value ==
                                            true,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                left: 5, right: 5),
                                            child: TextFormField(
                                              keyboardType: TextInputType.text,
                                              readOnly: true,
                                              controller: regiController
                                                  .marriagedateController.value,
                                              decoration: InputDecoration(
                                                labelText: regiController
                                                        .marriagedateController
                                                        .value
                                                        .text
                                                        .isNotEmpty
                                                    ? 'Marriage Anniversary *'
                                                    : null,
                                                hintText:
                                                    'Select Marriage Anniversary *',
                                                border:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black),
                                                ),
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black),
                                                ),
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black38,
                                                      width: 1),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                  horizontal: 20,
                                                ),
                                                labelStyle: const TextStyle(
                                                    color: Colors.black),
                                                hintStyle: const TextStyle(
                                                    color: Colors.black38),
                                              ),
                                              onTap: () async {
                                                DateTime? pickedDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(1900),
                                                  lastDate: DateTime.now(),
                                                  builder:
                                                      (BuildContext context,
                                                          Widget? child) {
                                                    return Theme(
                                                      data: Theme.of(context)
                                                          .copyWith(
                                                        colorScheme:
                                                            ColorScheme.light(
                                                          primary: ColorHelperClass
                                                              .getColorFromHex(
                                                                  ColorResources
                                                                      .red_color),
                                                          onPrimary:
                                                              Colors.white,
                                                          onSurface:
                                                              Colors.black,
                                                        ),
                                                        textButtonTheme:
                                                            TextButtonThemeData(
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                ColorHelperClass
                                                                    .getColorFromHex(
                                                                        ColorResources
                                                                            .red_color),
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
                                                    regiController
                                                        .marriagedateController
                                                        .value
                                                        .text = formattedDate;
                                                  });
                                                  String zoneId = controller
                                                      .zone_id.value
                                                      .trim();
                                                  regiController
                                                      .getFamilyMemberShip(
                                                          formattedDate,
                                                          zoneId);
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPicker() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text('Take a Picture'),
              onTap: () {
                Navigator.of(context).pop();
                getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.redAccent),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                getImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getImage(
    ImageSource img,
  ) async {
    if (ImagePicker().supportsImageSource(img) == true) {
      try {
        final XFile? pickedFile =
            await ImagePicker().pickImage(source: img, imageQuality: 80);

        selectimage.value = File(pickedFile!.path);

        if (pickedFile!.path != null) {
          controller.userdocumentImage.value = pickedFile!.path;
        }
      } catch (e) {
        print("gggh" + e.toString());
      }
    }
  }

  Widget _buildEditableField(
      String label,
      TextEditingController controller,
      String hintText,
      String validationMessage, {
        bool obscureText = false,
        required TextInputType text,
        bool isRequired = false,
        int? maxLength,
        ValueChanged<String>? onChanged,
        bool readOnly = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: TextFormField(
        keyboardType: text,
        controller: controller,
        obscureText: obscureText,
        maxLength: maxLength,
        onChanged: onChanged,
        buildCounter: (BuildContext context,
            {int? currentLength, int? maxLength, bool? isFocused}) =>
        null,
        readOnly: readOnly,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black38, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
