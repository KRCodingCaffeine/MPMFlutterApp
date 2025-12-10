import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/OccuptionProfession/OccuptionProfessionData.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/GetProfile/BusinessInfo.dart';
import 'package:mpm/model/GetProfile/Occupation.dart';
import 'package:mpm/model/Occupation/OccupationData.dart';
import 'package:mpm/model/OccupationSpec/OccuptionSpecData.dart';
import 'package:mpm/model/OccuptionSpecSubCategory/OccuptionSpecSubCategoryData.dart';
import 'package:mpm/model/OccuptionSpecSubSubCategory/OccuptionSpecSubSubCategoryData.dart';
import 'package:mpm/repository/update_occupation_repository/update_occupation_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/profile%20view/occupation_detail_view.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class BusinessInformationPage extends StatefulWidget {
  final String? successMessage;
  final String? failureMessage;

  const BusinessInformationPage({
    Key? key,
    this.successMessage,
    this.failureMessage,
  }) : super(key: key);

  @override
  _BusinessInformationPageState createState() =>
      _BusinessInformationPageState();
}

class _BusinessInformationPageState extends State<BusinessInformationPage> {
  NewMemberController regiController = Get.put(NewMemberController());
  UdateProfileController controller = Get.put(UdateProfileController());
  final updateOccupationRepo = UpdateOccupationRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              "Occupation Info",
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 35),
            onPressed: () {
              controller.selectedOccupation.value = "";
              controller.selectedProfession.value = "";
              controller.selectedSpecialization.value = "";
              controller.selectedSubCategory.value = "";
              controller.detailsController.value.text = "";
              controller.showDetailsField.value = false;
              _showAddModalSheet(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          // Use the existing occupation data list from controller
          final occupationList = controller.allOccupations;

          return occupationList.isEmpty
              ? const Center(
                  child: Text(
                    "No Occupation added yet.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: occupationList.length,
                  itemBuilder: (context, index) {
                    return occupationWidget(occupationList[index]!);
                  },
                );
        }),
      ),
    );
  }

  Widget occupationWidget(Occupation occupation) {
    // print('Occupation Data:');
    // print('Level 1: ${occupation.occupation}');
    // print('Level 2: ${occupation.occupationProfessionName}');
    // print('Level 3: ${occupation.specializationName}');
    // print('Level 4: ${occupation.specializationSubCategoryName}');
    // print('Level 5: ${occupation.specializationSubSubCategoryName}');
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      occupation.occupation ?? "Occupation",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // VIEW / EDIT POPUP BUTTON
                    ElevatedButton.icon(
                      onPressed: () {
                        _showUpdateModalSheet(context, occupation);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC3545),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )

                  ],
                ),

                const Divider(color: Colors.black26),
                const SizedBox(height: 8),

                // LEVELS
                _buildInfoBox(
                  'Level 1',
                  subtitle: occupation.occupation ?? 'Other',
                ),
                _buildInfoBox(
                  'Level 2',
                  subtitle: occupation.occupationProfessionName ?? 'Other',
                ),
                _buildInfoBox(
                  'Level 3',
                  subtitle: occupation.specializationName ?? 'Other',
                ),
                // _buildInfoBox(
                //   'Level 4',
                //   subtitle: occupation.specializationSubCategoryName ?? 'Other',
                // ),
                // _buildInfoBox(
                //   'Level 5',
                //   subtitle: occupation.specializationSubSubCategoryName ?? 'Other',
                // ),

                // OTHER DETAILS (If exists)
                if (occupation.occupationOtherName != null &&
                    occupation.occupationOtherName!.isNotEmpty)
                  _buildInfoBox(
                    'Details',
                    subtitle: occupation.occupationOtherName!,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _goToProductPage(Occupation occupation) {
    final memberId = occupation.memberId;
    final memberOccupationId = occupation.memberOccupationId;

    if (memberId == null || memberOccupationId == null) {
      Get.snackbar("Error", "Invalid Occupation Data");
      return;
    }

    Get.to(() => OccupationDetailViewPage(
          memberId: memberId.toString(),
          memberOccupationId: memberOccupationId.toString(),
        ));
  }

  Widget _buildInfoBox(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 130,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
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

  Future<void> _showAddModalSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
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
                    onPressed: () async {
                      await controller.addOccupation();
                      if (mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: controller.isOccupationLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Save"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildOccupationForm(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showUpdateModalSheet(
      BuildContext context, Occupation occupation) async {
    // Initialize the form with existing occupation data
    _initOccupationDataForEdit(occupation);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                          onPressed: () async {
                            await _updateOccupation(occupation);
                            if (mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: controller.isOccupationLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Update"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildOccupationForm(),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // Reset fields when modal is closed
      controller.selectedOccupation.value = "";
      controller.selectedProfession.value = "";
      controller.selectedSpecialization.value = "";
      controller.selectedSubCategory.value = "";
      controller.detailsController.value.text = "";
      controller.showDetailsField.value = false;
    });
  }

  void _initOccupationDataForEdit(Occupation occupation) async {
    controller.selectedOccupation.value =
        occupation.occupationId?.toString() ?? "";

    controller.selectedProfession.value =
        occupation.occupationProfessionId?.toString() ?? "";

    controller.selectedSpecialization.value =
        occupation.occupationSpecializationId?.toString() ?? "";

    controller.selectedSubCategory.value =
        occupation.occupationSpecializationSubCategoryId?.toString() ?? "";

    controller.selectedSubSubCategory.value =
        occupation.occupationSpecializationSubSubCategoryId?.toString() ?? "";

    controller.detailsController.value.text =
        occupation.occupationOtherName ?? "";

    controller.currentOccupation.value = occupation;

    if (controller.selectedOccupation.value.isNotEmpty &&
        controller.selectedOccupation.value != "0") {
      await controller.getOccupationProData(
          controller.selectedOccupation.value);
    }

    if (controller.selectedProfession.value.isNotEmpty &&
        controller.selectedProfession.value != "Other") {
      await controller.getOccupationSpectData(
          controller.selectedProfession.value);
    }

    if (controller.selectedSpecialization.value.isNotEmpty &&
        controller.selectedSpecialization.value != "Other") {
      await controller.getOccupationSpecializationSubCategoryData(
          controller.selectedSpecialization.value);
    }

    if (controller.selectedSubCategory.value.isNotEmpty &&
        controller.selectedSubCategory.value != "Other") {
      await controller.getOccupationSubSubCategoryData(
          controller.selectedSubCategory.value);
    }
  }

  Future<void> _updateOccupation(Occupation oldData) async {
    if (controller.selectedOccupation.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select Level 1",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    controller.isOccupationLoading.value = true;

    try {
      final payload = {
        "member_occupation_id": oldData.memberOccupationId ?? "",
        "member_id": oldData.memberId ?? "",
        "occupation_id": controller.selectedOccupation.value,
        "occupation_profession_id": controller.selectedProfession.value,
        "occupation_specialization_id": controller.selectedSpecialization.value,
        "occupation_specialization_sub_category_id":
        controller.selectedSubCategory.value,
        "occupation_specialization_sub_sub_category_id":
        controller.selectedSubSubCategory.value,
        "occupation_other_name": controller.detailsController.value.text,
        "updated_by": oldData.memberId ?? "",
      };

      print("📤 UPDATE PAYLOAD: $payload");

      final res = await updateOccupationRepo.updateOccupation(payload);

      if (res == true) {
        final updateCtrl = Get.find<UdateProfileController>();
        await updateCtrl.getUserProfile();

        Get.snackbar(
          "Success",
          "Occupation updated successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to update occupation!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Unexpected error: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    controller.isOccupationLoading.value = false;
  }

  Widget
  _buildOccupationForm() {
    return Column(
      children: [
        // Occupation Dropdown
        Container(
          margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
          child: Obx(() {
            if (controller.rxStatusOccupation.value == Status.LOADING) {
              return _buildLoadingIndicator();
            } else if (controller.rxStatusOccupation.value == Status.ERROR) {
              return const Center(child: Text('Failed to load occupation'));
            } else {
              return InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Level 1 *',
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  labelStyle: const TextStyle(color: Colors.black45),
                ),
                isEmpty: controller.selectedOccupation.value.isEmpty,
                child: DropdownButton<String>(
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  isExpanded: true,
                  underline: Container(),
                  value: controller.selectedOccupation.value.isEmpty
                      ? null
                      : controller.selectedOccupation.value,
                  items:
                      controller.occuptionList.map((OccupationData occupation) {
                    return DropdownMenuItem<String>(
                      value: occupation.id.toString(),
                      child: Text(occupation.occupation ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.selectedOccupation.value = newValue;
                      controller.selectedProfession.value = "";
                      controller.selectedSpecialization.value = "";
                      controller.selectedSubCategory.value = "";
                      controller.detailsController.value.text = "";

                      if (newValue == "0") {
                        controller.showDetailsField.value = true;
                      } else {
                        controller.showDetailsField.value = false;
                        controller.getOccupationProData(newValue);
                      }
                    }
                  },
                ),
              );
            }
          }),
        ),
        const SizedBox(height: 20),

        // Profession Dropdown
        Obx(() {
          if (controller.selectedOccupation.value.isEmpty ||
              controller.selectedOccupation.value == "0") {
            return const SizedBox();
          }
          return Container(
            margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
            child: Obx(() {
              if (controller.rxStatusOccupationData.value == Status.LOADING) {
                return _buildLoadingIndicator();
              } else if (controller.rxStatusOccupationData.value ==
                  Status.ERROR) {
                return const Center(child: Text('Failed to load profession'));
              } else {
                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Level 2',
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    labelStyle: const TextStyle(color: Colors.black45),
                  ),
                  isEmpty: controller.selectedProfession.value.isEmpty,
                  child: DropdownButton<String>(
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    isExpanded: true,
                    underline: Container(),
                    value: controller.selectedProfession.value.isEmpty
                        ? null
                        : controller.selectedProfession.value,
                    items: [
                      ...controller.occuptionProfessionList
                          .map((OccuptionProfessionData profession) {
                        return DropdownMenuItem<String>(
                          value: profession.id.toString(),
                          child: Text(profession.name ?? 'Unknown'),
                        );
                      }).toList(),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedProfession.value = newValue;
                        controller.selectedSpecialization.value = "";
                        controller.selectedSubCategory.value = "";
                        controller.detailsController.value.text = "";

                        if (newValue == "Other") {
                          controller.showDetailsField.value = true;
                        } else if (newValue.isNotEmpty) {
                          controller.showDetailsField.value = false;
                          controller.getOccupationSpectData(newValue);
                        }
                      }
                    },
                  ),
                );
              }
            }),
          );
        }),
        const SizedBox(height: 20),

        // Specialization Dropdown
        Obx(() {
          if (controller.selectedProfession.value.isEmpty ||
              controller.selectedProfession.value == "Other") {
            return const SizedBox();
          }
          return Container(
            margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
            child: Obx(() {
              if (controller.rxStatusOccupationSpec.value == Status.LOADING) {
                return _buildLoadingIndicator();
              } else if (controller.rxStatusOccupationSpec.value ==
                  Status.ERROR) {
                return const Center(
                    child: Text('Failed to load specialization'));
              } else {
                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Level 3',
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    labelStyle: const TextStyle(color: Colors.black45),
                  ),
                  isEmpty: controller.selectedSpecialization.value.isEmpty,
                  child: DropdownButton<String>(
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    isExpanded: true,
                    underline: Container(),
                    value: controller.selectedSpecialization.value.isEmpty
                        ? null
                        : controller.selectedSpecialization.value,
                    items: [
                      ...controller.occuptionSpeList
                          .map((OccuptionSpecData specialization) {
                        return DropdownMenuItem<String>(
                          value: specialization.id?.toString(),
                          child: Text(specialization.name ?? 'Unknown'),
                        );
                      }).toList(),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedSpecialization.value = newValue;
                        controller.selectedSubCategory.value = "";
                        controller.detailsController.value.text = "";

                        if (newValue == "Other") {
                          controller.showDetailsField.value = true;
                        } else if (newValue.isNotEmpty) {
                          controller.showDetailsField.value = false;
                          controller.getOccupationSpecializationSubCategoryData(
                              newValue);
                        }
                      }
                    },
                  ),
                );
              }
            }),
          );
        }),
        const SizedBox(height: 20),

        // Sub Category Dropdown
        // Obx(() {
        //   if (controller.selectedSpecialization.value.isEmpty ||
        //       controller.selectedSpecialization.value == "Other") {
        //     return const SizedBox();
        //   }
        //   return Container(
        //     margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
        //     child: Obx(() {
        //       if (controller.rxStatusOccupationSpec.value == Status.LOADING) {
        //         return _buildLoadingIndicator();
        //       } else if (controller.rxStatusOccupationSpec.value ==
        //           Status.ERROR) {
        //         return const Center(child: Text('Failed to load subcategory'));
        //       } else if (controller.occuptionSubCategoryList.isEmpty) {
        //         return const SizedBox();
        //       } else {
        //         return InputDecorator(
        //           decoration: InputDecoration(
        //             labelText: 'Level 4',
        //             border: const OutlineInputBorder(
        //               borderSide: BorderSide(color: Colors.black26),
        //             ),
        //             enabledBorder: const OutlineInputBorder(
        //               borderSide: BorderSide(color: Colors.black26),
        //             ),
        //             focusedBorder: const OutlineInputBorder(
        //               borderSide: BorderSide(color: Colors.black26, width: 1.5),
        //             ),
        //             contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        //             labelStyle: const TextStyle(color: Colors.black45),
        //           ),
        //           isEmpty: controller.selectedSubCategory.value.isEmpty,
        //           child: DropdownButton<String>(
        //             dropdownColor: Colors.white,
        //             borderRadius: BorderRadius.circular(10),
        //             isExpanded: true,
        //             underline: Container(),
        //             value: controller.selectedSubCategory.value.isEmpty
        //                 ? null
        //                 : controller.selectedSubCategory.value,
        //             items: [
        //               ...controller.occuptionSubCategoryList
        //                   .map((OccuptionSpecSubCategoryData sub) {
        //                 return DropdownMenuItem<String>(
        //                   value: sub.specializationSubCategoryId.toString(),
        //                   child: Text(
        //                       sub.specializationSubCategoryName ?? 'Unknown'),
        //                 );
        //               }).toList(),
        //             ],
        //             onChanged: (String? newValue) {
        //               if (newValue != null) {
        //                 controller.selectedSubCategory.value = newValue;
        //                 controller.selectedSubSubCategory.value = "";
        //
        //                 if (newValue == "Other") {
        //                   controller.showDetailsField.value = true;
        //                 } else {
        //                   controller.showDetailsField.value = false;
        //                   controller.getOccupationSubSubCategoryData(newValue);
        //                 }
        //               }
        //             },
        //           ),
        //         );
        //       }
        //     }),
        //   );
        // }),
        // const SizedBox(height: 20),

        // Level 5 – Sub-Sub-Category
        // Obx(() {
        //   if (controller.selectedSubCategory.value.isEmpty ||
        //       controller.selectedSubCategory.value == "Other") {
        //     return const SizedBox();
        //   }
        //
        //   return Container(
        //     margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
        //     child: Obx(() {
        //       if (controller.rxStatusOccupationSpec.value == Status.LOADING) {
        //         return _buildLoadingIndicator();
        //       } else if (controller.rxStatusOccupationSpec.value ==
        //           Status.ERROR) {
        //         return const Center(child: Text('Failed to load level 5'));
        //       } else if (controller.occuptionSubSubCategoryList.isEmpty) {
        //         return const SizedBox();
        //       } else {
        //         return InputDecorator(
        //           decoration: const InputDecoration(
        //             labelText: 'Level 5',
        //             border: OutlineInputBorder(
        //                 borderSide: BorderSide(color: Colors.black26)),
        //             enabledBorder: OutlineInputBorder(
        //                 borderSide: BorderSide(color: Colors.black26)),
        //             focusedBorder: OutlineInputBorder(
        //                 borderSide:
        //                     BorderSide(color: Colors.black26, width: 1.5)),
        //             contentPadding: EdgeInsets.symmetric(horizontal: 20),
        //           ),
        //           isEmpty: controller.selectedSubSubCategory.value.isEmpty,
        //           child: DropdownButton<String>(
        //             dropdownColor: Colors.white,
        //             isExpanded: true,
        //             underline: Container(),
        //             value: controller.selectedSubSubCategory.value.isEmpty
        //                 ? null
        //                 : controller.selectedSubSubCategory.value,
        //             items: controller.occuptionSubSubCategoryList
        //                 .map((OccuptionSpecSubSubCategoryData item) {
        //               return DropdownMenuItem<String>(
        //                 value: item.subSubCategoryId.toString(),
        //                 child: Text(item.subSubCategoryName ?? 'Unknown'),
        //               );
        //             }).toList(),
        //             onChanged: (String? newValue) {
        //               if (newValue != null) {
        //                 controller.selectedSubSubCategory.value = newValue;
        //
        //                 if (newValue == "Other") {
        //                   controller.showDetailsField.value = true;
        //                 } else {
        //                   controller.showDetailsField.value = false;
        //                 }
        //               }
        //             },
        //           ),
        //         );
        //       }
        //     }),
        //   );
        // }),
        // const SizedBox(height: 20),

        // Details Field
        Obx(() {
          final showDetails = controller.selectedOccupation.value == "0" ||
              controller.selectedProfession.value == "Other" ||
              controller.selectedSpecialization.value == "Other" ||
              controller.selectedSubCategory.value == "Other" ||
              controller.showDetailsField.value;

          if (!showDetails) return const SizedBox();

          return Container(
            margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: controller.detailsController.value,
              decoration: InputDecoration(
                labelText: "Occupation Details",
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                labelStyle: const TextStyle(color: Colors.black45),
              ),
              validator: (value) {
                if (showDetails && (value == null || value.isEmpty)) {
                  return 'Please enter occupation details';
                }
                return null;
              },
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Container(
        alignment: Alignment.centerRight,
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
        ),
      ),
    );
  }
}
