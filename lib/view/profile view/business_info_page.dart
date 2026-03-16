import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  final bool autoOpenAddSheet;

  const BusinessInformationPage({
    Key? key,
    this.successMessage,
    this.failureMessage,
    this.autoOpenAddSheet = false,
  }) : super(key: key);

  @override
  _BusinessInformationPageState createState() =>
      _BusinessInformationPageState();
}

class _BusinessInformationPageState extends State<BusinessInformationPage> {
  NewMemberController regiController = Get.put(NewMemberController());
  UdateProfileController controller = Get.put(UdateProfileController());
  final updateOccupationRepo = UpdateOccupationRepository();
  final GlobalKey<FormState> _occupationFormKey = GlobalKey<FormState>();
  bool _didAutoOpenSheet = false;
  bool showOccupationBanner = false;

  void _showOccupationSnackBar(String message, {required bool isSuccess}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final occupationList = controller.allOccupations;

      /// CASE 1 — No occupation → open add sheet
      if (occupationList.isEmpty && widget.autoOpenAddSheet) {
        _showAddModalSheet(context);
        return;
      }

      /// CASE 2 — Company name missing
      bool companyMissing = occupationList.any((occ) =>
          occ.companyName == null || occ.companyName.toString().trim().isEmpty);

      if (companyMissing) {
        setState(() {
          showOccupationBanner = true;
        });
      }
    });
  }

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
        child: Column(
          children: [
            /// 🔴 OCCUPATION WARNING BANNER
            if (showOccupationBanner)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Click Edit button to update more occupation detail",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            /// OCCUPATION LIST
            Expanded(
              child: Obx(() {
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
          ],
        ),
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
    final bool isStudent = occupation.occupationId == 6 ||
        occupation.occupationId?.toString() == "6";
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
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
                // LEVEL 2 & 3 (HIDDEN for Student)
                if (!isStudent) ...[
                  _buildInfoBox(
                    'Level 2',
                    subtitle: occupation.occupationProfessionName ?? 'Other',
                  ),
                  _buildInfoBox(
                    'Level 3',
                    subtitle: occupation.specializationName ?? 'Other',
                  ),
                ],

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

                // NEW DATA
                if (occupation.companyName != null &&
                    occupation.companyName!.isNotEmpty)
                  _buildInfoBox(
                    'Company Name',
                    subtitle: occupation.companyName!,
                  ),

                if (occupation.designation != null &&
                    occupation.designation!.isNotEmpty)
                  _buildInfoBox(
                    'Designation',
                    subtitle: occupation.designation!,
                  ),

                if (occupation.startDate != null &&
                    occupation.startDate!.isNotEmpty)
                  _buildInfoBox(
                    'Start Date',
                    subtitle: occupation.startDate!,
                  ),

                if (occupation.endDate != null &&
                    occupation.endDate!.isNotEmpty)
                  _buildInfoBox(
                    'End Date',
                    subtitle: occupation.endDate!,
                  ),

                if (occupation.isCurrentEmployment != "0")
                  _buildInfoBox(
                    'Currently Employed',
                    subtitle:
                        occupation.isCurrentEmployment == "1" ? "Yes" : "No",
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
                      if (!_occupationFormKey.currentState!.validate()) {
                        return;
                      }

                      await controller.addOccupation(context);
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
                        : const Text("Submit"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _occupationFormKey,
                child: _buildOccupationForm(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showUpdateModalSheet(
      BuildContext context, Occupation occupation) async {
    _initOccupationDataForEdit(occupation);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (modalContext) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: SafeArea(
            top: false,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 16,
              ),
              child: Column(
                children: [
                  /// HEADER BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(modalContext),
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
                          if (!_occupationFormKey.currentState!.validate()) {
                            return;
                          }

                          await controller.updateFullOccupation(
                              occupation, context);
                          if (mounted) Navigator.pop(modalContext);
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

                  const SizedBox(height: 15),

                  /// TITLE
                  const Text(
                    "Update Occupation Detail",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// SCROLLABLE FORM
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _occupationFormKey,
                        child: _buildOccupationForm(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      controller.selectedOccupation.value = "";
      controller.selectedProfession.value = "";
      controller.selectedSpecialization.value = "";
      controller.selectedSubCategory.value = "";
      controller.detailsController.value.text = "";
      controller.showDetailsField.value = false;
    });
  }

  void _initOccupationDataForEdit(Occupation occupation) async {
    controller.selectedOccupation.value = (occupation.occupationId == null ||
            occupation.occupationId.toString().isEmpty)
        ? "0"
        : occupation.occupationId.toString();

    controller.selectedProfession.value =
        occupation.occupationProfessionId?.toString() ?? "Other";

    controller.selectedSpecialization.value =
        occupation.occupationSpecializationId?.toString() ?? "Other";

    controller.detailsController.value.text =
        occupation.occupationOtherName ?? "";

    controller.currentOccupation.value = occupation;

    /// SHOW DETAILS IF OTHER
    if (controller.selectedOccupation.value == "0") {
      controller.showDetailsField.value = true;
    }

    if (controller.selectedOccupation.value.isNotEmpty &&
        controller.selectedOccupation.value != "0") {
      await controller
          .getOccupationProData(controller.selectedOccupation.value);
    }

    if (controller.selectedProfession.value.isNotEmpty &&
        controller.selectedProfession.value != "Other") {
      await controller
          .getOccupationSpectData(controller.selectedProfession.value);
    }
  }

  // Future<void> _updateOccupation(Occupation oldData) async {
  //   if (controller.selectedOccupation.value.isEmpty) {
  //     _showOccupationSnackBar("Please select Level 1", isSuccess: false);
  //     return;
  //   }
  //
  //   controller.isOccupationLoading.value = true;
  //
  //   try {
  //     final payload = {
  //       "member_occupation_id": oldData.memberOccupationId ?? "",
  //       "member_id": oldData.memberId ?? "",
  //       "occupation_id": controller.selectedOccupation.value,
  //       "occupation_profession_id":
  //       controller.selectedProfession.value == "Other" ||
  //           controller.selectedProfession.value.isEmpty
  //           ? ""
  //           : controller.selectedProfession.value,
  //
  //       "occupation_specialization_id":
  //       controller.selectedSpecialization.value == "Other" ||
  //           controller.selectedSpecialization.value.isEmpty
  //           ? ""
  //           : controller.selectedSpecialization.value,
  //
  //       // "occupation_specialization_sub_category_id":
  //       // controller.selectedSubCategory.value,
  //       // "occupation_specialization_sub_sub_category_id":
  //       // controller.selectedSubSubCategory.value,
  //       "occupation_other_name": controller.detailsController.value.text.trim().isEmpty
  //           ? ""
  //           : controller.detailsController.value.text.trim(),
  //       "updated_by": oldData.memberId ?? "",
  //     };
  //
  //     print("UPDATE PAYLOAD: $payload");
  //
  //     final res = await updateOccupationRepo.updateOccupation(payload);
  //
  //     if (res == true) {
  //       final updateCtrl = Get.find<UdateProfileController>();
  //       await updateCtrl.getUserProfile();
  //       _showOccupationSnackBar(
  //         "Occupation updated successfully!",
  //         isSuccess: true,
  //       );
  //     } else {
  //       _showOccupationSnackBar(
  //         "Failed to update occupation!",
  //         isSuccess: false,
  //       );
  //     }
  //   } catch (e) {
  //     _showOccupationSnackBar(
  //       "Unexpected error: $e",
  //       isSuccess: false,
  //     );
  //   }
  //
  //   controller.isOccupationLoading.value = false;
  // }

  Widget _buildOccupationForm() {
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
                      controller.detailsController.value.text = "";

                      const detailOnlyOccupationIds = ["6"];

                      if (newValue == "0" ||
                          detailOnlyOccupationIds.contains(newValue)) {
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
          final occId = controller.selectedOccupation.value;
          const detailOnlyOccupationIds = ["6"];

          if (occId.isEmpty ||
              occId == "0" ||
              detailOnlyOccupationIds.contains(occId)) {
            return const SizedBox();
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
                child: Obx(() {
                  if (controller.rxStatusOccupationData.value ==
                      Status.LOADING) {
                    return _buildLoadingIndicator();
                  } else if (controller.rxStatusOccupationData.value ==
                      Status.ERROR) {
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
                          borderSide:
                              BorderSide(color: Colors.black26, width: 1.5),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        labelStyle: const TextStyle(color: Colors.black45),
                      ),
                      child: const Text(
                        "Other",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    );
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
                          borderSide:
                              BorderSide(color: Colors.black26, width: 1.5),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
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
                        items: controller.occuptionProfessionList
                            .map((OccuptionProfessionData profession) {
                          return DropdownMenuItem<String>(
                            value: profession.id.toString(),
                            child: Text(profession.name ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedProfession.value = newValue;
                            controller.selectedSpecialization.value = "";
                            controller.selectedSubCategory.value = "";
                            controller.detailsController.value.text = "";

                            if (newValue == "Other") {
                              controller.showDetailsField.value = true;
                            } else {
                              controller.showDetailsField.value = false;
                              controller.getOccupationSpectData(newValue);
                            }
                          }
                        },
                      ),
                    );
                  }
                }),
              ),
              const SizedBox(height: 20),
            ],
          );
        }),

        // Specialization Dropdown
        Obx(() {
          // Hide Level 3 if profession is empty or "Other"
          if (controller.selectedProfession.value.isEmpty ||
              controller.selectedProfession.value == "Other") {
            return const SizedBox();
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
                child: Obx(() {
                  if (controller.rxStatusOccupationSpec.value ==
                      Status.LOADING) {
                    return _buildLoadingIndicator();
                  } else if (controller.rxStatusOccupationSpec.value ==
                      Status.ERROR) {
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
                          borderSide:
                              BorderSide(color: Colors.black26, width: 1.5),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        labelStyle: const TextStyle(color: Colors.black45),
                      ),
                      child: const Text(
                        "Other",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    );
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
                          borderSide:
                              BorderSide(color: Colors.black26, width: 1.5),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
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
                        items: controller.occuptionSpeList
                            .map((OccuptionSpecData specialization) {
                          return DropdownMenuItem<String>(
                            value: specialization.id?.toString(),
                            child: Text(specialization.name ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedSpecialization.value = newValue;
                            controller.detailsController.value.text = "";

                            if (newValue == "Other") {
                              controller.showDetailsField.value = true;
                            } else {
                              controller.showDetailsField.value = false;
                            }
                          }
                        },
                      ),
                    );
                  }
                }),
              ),
              const SizedBox(height: 20),
            ],
          );
        }),

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
          const studentOccupationId = "6";

          final selectedOccId = controller.selectedOccupation.value;

          final showDetails = selectedOccId == "0" ||
              selectedOccId == studentOccupationId ||
              controller.selectedProfession.value == "Other" ||
              controller.selectedSpecialization.value == "Other" ||
              controller.showDetailsField.value;

          if (!showDetails) return const SizedBox();

          final isStudent = selectedOccId == studentOccupationId;

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: controller.detailsController.value,
                  decoration: InputDecoration(
                    labelText: isStudent
                        ? "Enter your standard or course details"
                        : "Occupation Details",
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    labelStyle: const TextStyle(color: Colors.black45),
                  ),
                  validator: (value) {
                    if (isStudent && (value == null || value.trim().isEmpty)) {
                      return "Please enter your standard or course details";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        }),

        /// COMPANY NAME
        Container(
          margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
          child: TextFormField(
            controller: controller.companyNameController,
            decoration: const InputDecoration(
              labelText: "Company Name",
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
          ),
        ),
        const SizedBox(height: 20),

        /// DESIGNATION
        Container(
          margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
          child: TextFormField(
            controller: controller.designationController,
            decoration: const InputDecoration(
              labelText: "Designation",
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
          ),
        ),
        const SizedBox(height: 20),

        /// START DATE
        SizedBox(
          width: double.infinity,
          child: Container(
            margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
            child: TextFormField(
              keyboardType: TextInputType.text,
              readOnly: true,
              controller: controller.startDateController,
              decoration: InputDecoration(
                labelText: 'Start Date',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                labelStyle: TextStyle(color: Colors.black45),
                hintText: 'Select Start Date',
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: controller.startDateController.text.isNotEmpty
                      ? DateFormat('dd/MM/yyyy').parse(controller
                          .startDateController.text
                          .replaceAll('-', '/'))
                      : DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime(2100),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('dd/MM/yyyy').format(pickedDate);
                  controller.startDateController.text = formattedDate;
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        /// END DATE
        SizedBox(
          width: double.infinity,
          child: Container(
            margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
            child: TextFormField(
              keyboardType: TextInputType.text,
              readOnly: true,
              controller: controller.endDateController,
              decoration: InputDecoration(
                labelText: 'End Date',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                labelStyle: TextStyle(color: Colors.black45),
                hintText: 'Select End Date',
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: controller.endDateController.text.isNotEmpty
                      ? DateFormat('dd/MM/yyyy').parse(controller
                          .endDateController.text
                          .replaceAll('-', '/'))
                      : DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime(2100),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('dd/MM/yyyy').format(pickedDate);
                  controller.endDateController.text = formattedDate;
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        /// CURRENTLY EMPLOYED DROPDOWN
        Container(
          margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
          child: Obx(() {
            return InputDecorator(
              decoration: const InputDecoration(
                labelText: "Currently Employed",
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
              child: DropdownButton<String>(
                value: controller.isCurrentlyEmployed.value,
                isExpanded: true,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(10),
                underline: Container(),
                items: const [
                  DropdownMenuItem(value: "1", child: Text("Yes")),
                  DropdownMenuItem(value: "0", child: Text("No")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.isCurrentlyEmployed.value = value;
                  }
                },
              ),
            );
          }),
        ),
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
