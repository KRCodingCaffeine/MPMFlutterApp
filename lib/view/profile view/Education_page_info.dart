import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/GetProfile/Qualification.dart';
import 'package:mpm/model/Qualification/QualificationData.dart';
import 'package:mpm/model/QualificationCategory/QualificationCategoryModel.dart';
import 'package:mpm/model/QualificationMain/QualicationMainData.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class EducationPageInfo extends StatefulWidget {
  const EducationPageInfo({Key? key}) : super(key: key);

  @override
  _EducationPageInfoState createState() => _EducationPageInfoState();
}

class _EducationPageInfoState extends State<EducationPageInfo> {
  // Variables to store information
  UdateProfileController regiController = Get.put(UdateProfileController());

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
              "Education Info",
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              size: 35,
            ),
            onPressed: () {
              regiController.selectQlification.value = "";
              regiController.selectQualicationMain.value = "";
              regiController.selectQualicationCat.value = "";
              _showEditModalSheet(context, "1");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          return regiController.qualificationList.value.isEmpty
              ? const Center(child: Text("No Education added yet."))
              : ListView.builder(
                  itemCount: regiController.qualificationList.value.length,
                  itemBuilder: (context, index) {
                    return educationWidget(
                        regiController.qualificationList.value[index]);
                  },
                );
        }),
      ),
    );
  }

  Future<void> _showEditModalSheet(BuildContext context, String type) async {
    regiController.selectQlification.value = "";
    regiController.selectQualicationMain.value = "";
    regiController.selectQualicationCat.value = "";
    regiController.educationdetailController.value.text = "";
    regiController.isQualicationList.value = false;
    regiController.isQualificationCategoryVisible.value = false;
    regiController.isQualificationDetailVisible.value = false;

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
                      regiController.addQualification();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: regiController.addloading.value
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

              // Qualification Dropdown
              Container(
                margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
                child: Obx(() {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Qualification',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black26),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black26),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.black26, width: 1.5),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      labelStyle: TextStyle(color: Colors.black45),
                    ),
                    isEmpty: regiController.selectQlification.value.isEmpty,
                    child: DropdownButton<String>(
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      isExpanded: true,
                      underline: Container(),
                      value: regiController.selectQlification.value.isEmpty
                          ? null
                          : regiController.selectQlification.value,
                      items: regiController.qulicationList.value
                          .map((QualificationData item) {
                        return DropdownMenuItem<String>(
                          value: item.id.toString(),
                          child: Text(item.qualification ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          regiController.selectQlification.value = newValue;
                          regiController.selectQualicationMain.value = "";
                          regiController.selectQualicationCat.value = "";
                          regiController.educationdetailController.value.text =
                          "";

                          if (newValue == "other") {
                            regiController.isQualicationList.value = false;
                            regiController
                                .isQualificationCategoryVisible.value = false;
                            regiController.isQualificationDetailVisible.value =
                            true;
                          } else {
                            regiController.isQualicationList.value = true;
                            regiController
                                .isQualificationCategoryVisible.value = false;
                            regiController.isQualificationDetailVisible.value =
                            false;
                            regiController.getQualicationMain(newValue);
                          }
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              Obx(() {
                return Visibility(
                  visible: regiController.isQualicationList.value,
                  child: Container(
                    margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Qualification Main',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black26, width: 1.5),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        labelStyle: TextStyle(color: Colors.black45),
                      ),
                      isEmpty:
                      regiController.selectQualicationMain.value.isEmpty,
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        isExpanded: true,
                        underline: Container(),
                        value:
                        regiController.selectQualicationMain.value.isEmpty
                            ? null
                            : regiController.selectQualicationMain.value,
                        items: regiController.qulicationMainList.value
                            .map((QualicationMainData item) {
                          return DropdownMenuItem<String>(
                            value: item.id.toString(),
                            child: Text(item.name ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            regiController.selectQualicationMain.value =
                                newValue;
                            regiController.selectQualicationCat.value = "";
                            regiController
                                .educationdetailController.value.text = "";

                            if (newValue == "other_main") {
                              regiController
                                  .isQualificationCategoryVisible.value = false;
                              regiController
                                  .isQualificationDetailVisible.value = true;
                            } else {
                              regiController
                                  .isQualificationCategoryVisible.value = true;
                              regiController
                                  .isQualificationDetailVisible.value = false;
                              regiController.getQualicationCategory(newValue);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              Obx(() {
                return Visibility(
                  visible: regiController.isQualificationCategoryVisible.value,
                  child: Container(
                    margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Qualification Category',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black26, width: 1.5),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        labelStyle: TextStyle(color: Colors.black45),
                      ),
                      isEmpty:
                      regiController.selectQualicationCat.value.isEmpty,
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        isExpanded: true,
                        underline: Container(),
                        value: regiController.selectQualicationCat.value.isEmpty
                            ? null
                            : regiController.selectQualicationCat.value,
                        items: regiController.qulicationCategoryList.value
                            .map((Qualificationcategorydata item) {
                          return DropdownMenuItem<String>(
                            value: item.id.toString(),
                            child: Text(item.name ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            regiController.selectQualicationCat.value =
                                newValue;
                            if (newValue == "other_category") {
                              regiController
                                  .isQualificationDetailVisible.value = true;
                            } else {
                              regiController
                                  .isQualificationDetailVisible.value = true;
                            }
                          }
                        },
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              Obx(() {
                return Visibility(
                  visible: regiController.isQualificationDetailVisible.value,
                  child: Container(
                    margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller:
                      regiController.educationdetailController.value,
                      decoration: InputDecoration(
                        labelText: "Qualification Detail",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black26, width: 1.5),
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        labelStyle: TextStyle(color: Colors.black45),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter qualification details';
                        }
                        return null;
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showUpdateModalSheet(
      BuildContext context, Qualification qualification) async {

    print("Loading qualification data: ${qualification.toJson()}");

    regiController.selectQlification.value =
        qualification.qualificationId?.toString() ?? "other";

    regiController.selectQualicationMain.value =
    qualification.qualificationMainId == null ||
        qualification.qualificationMainId.toString().isEmpty
        ? "other_main"
        : qualification.qualificationMainId?.toString() ?? "";

    regiController.selectQualicationCat.value =
    qualification.qualificationCategoryId == null ||
        qualification.qualificationCategoryId.toString().isEmpty
        ? "other_category"
        : qualification.qualificationCategoryId?.toString() ?? "";

    regiController.educationdetailController.value.text =
        qualification.qualificationOtherName ?? '';

    if (regiController.selectQlification.value == "other") {
      regiController.isQualicationList.value = false;
      regiController.isQualificationCategoryVisible.value = false;
      regiController.isQualificationDetailVisible.value = true;
    } else {
      regiController.isQualicationList.value = true;

      if (regiController.selectQualicationMain.value.isNotEmpty &&
          regiController.selectQualicationMain.value != "other_main") {
        regiController.isQualificationCategoryVisible.value = true;
      } else {
        regiController.isQualificationCategoryVisible.value = false;
      }

      bool hasDetailText = qualification.qualificationOtherName == null &&
          qualification.qualificationOtherName!.trim().isNotEmpty;

      regiController.isQualificationDetailVisible.value =
          regiController.selectQlification.value == "other" ||
              regiController.selectQualicationMain.value == "other_main" ||
              regiController.selectQualicationCat.value == "other_category";
      hasDetailText;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (qualification.qualificationId != null &&
          qualification.qualificationId != "other") {
        regiController.getQualicationMain(qualification.qualificationId.toString());
      }

      if (qualification.qualificationMainId != null &&
          qualification.qualificationMainId != "0" &&
          qualification.qualificationMainId != "other_main") {
        regiController.getQualicationCategory(
            qualification.qualificationMainId.toString());
      }
    });

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
                    SizedBox(height: 30),

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
                            regiController.updateQualification(
                              qualification.memberQualificationId.toString(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: regiController.addloading.value
                              ? const CircularProgressIndicator(color: Colors.red)
                              : const Text("Save"),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Qualification Dropdown
                    Container(
                      margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
                      child: Obx(() {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Qualification',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.black26, width: 1.5),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            labelStyle: TextStyle(color: Colors.black45),
                          ),
                          isEmpty: regiController.selectQlification.value.isEmpty,
                          child: DropdownButton<String>(
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            isExpanded: true,
                            underline: Container(),
                            value: regiController.selectQlification.value.isEmpty
                                ? null
                                : regiController.selectQlification.value,
                            items: regiController.qulicationList.value
                                .map((QualificationData item) {
                              return DropdownMenuItem<String>(
                                value: item.id.toString(),
                                child: Text(item.qualification ?? 'Unknown'),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setModalState(() {
                                  regiController.selectQlification.value = newValue;
                                  regiController.selectQualicationMain.value = "";
                                  regiController.selectQualicationCat.value = "";
                                  regiController.educationdetailController.value.text = "";

                                  if (newValue == "other") {
                                    regiController.isQualicationList.value = false;
                                    regiController.isQualificationCategoryVisible.value = false;
                                    regiController.isQualificationDetailVisible.value = true;
                                  } else {
                                    regiController.isQualicationList.value = true;
                                    regiController.isQualificationCategoryVisible.value = false;
                                    regiController.isQualificationDetailVisible.value = false;
                                    regiController.getQualicationMain(newValue);
                                  }
                                });
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Qualification Main Dropdown
                    Obx(() {
                      return Visibility(
                        visible: regiController.isQualicationList.value,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Qualification Main',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black26),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black26),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.black26, width: 1.5),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 20),
                              labelStyle: TextStyle(color: Colors.black45),
                            ),
                            isEmpty:
                            regiController.selectQualicationMain.value.isEmpty,
                            child: DropdownButton<String>(
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              isExpanded: true,
                              underline: Container(),
                              value:
                              regiController.selectQualicationMain.value.isEmpty
                                  ? null
                                  : regiController.selectQualicationMain.value,
                              items: regiController.qulicationMainList.value
                                  .map((QualicationMainData item) {
                                return DropdownMenuItem<String>(
                                  value: item.id.toString(),
                                  child: Text(item.name ?? 'Unknown'),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setModalState(() {
                                    regiController.selectQualicationMain.value = newValue;
                                    regiController.selectQualicationCat.value = "";

                                    if (newValue == "other_main") {
                                      regiController.isQualificationCategoryVisible.value = false;
                                      regiController.isQualificationDetailVisible.value = true;
                                    } else {
                                      regiController.isQualificationCategoryVisible.value = true;
                                      regiController.isQualificationDetailVisible.value = false;
                                      regiController.getQualicationCategory(newValue);
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // Qualification Category Dropdown
                    Obx(() {
                      return Visibility(
                        visible: regiController.isQualificationCategoryVisible.value,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Qualification Category',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black26),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black26),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.black26, width: 1.5),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 20),
                              labelStyle: TextStyle(color: Colors.black45),
                            ),
                            isEmpty:
                            regiController.selectQualicationCat.value.isEmpty,
                            child: DropdownButton<String>(
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              isExpanded: true,
                              underline: Container(),
                              value:
                              regiController.selectQualicationCat.value.isEmpty
                                  ? null
                                  : regiController.selectQualicationCat.value,
                              items: regiController.qulicationCategoryList.value
                                  .map((Qualificationcategorydata item) {
                                return DropdownMenuItem<String>(
                                  value: item.id.toString(),
                                  child: Text(item.name ?? 'Unknown'),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setModalState(() {
                                    regiController.selectQualicationCat.value = newValue;
                                    if (newValue == "other_category") {
                                      regiController.isQualificationDetailVisible.value = true;
                                    } else {
                                      regiController.isQualificationDetailVisible.value = true;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    Obx(() {
                      final hasExistingValue = qualification.qualificationOtherName != null &&
                          qualification.qualificationOtherName!.trim().isEmpty;

                      return Visibility(
                        visible: regiController.isQualificationDetailVisible.value || hasExistingValue,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller:
                            regiController.educationdetailController.value,
                            decoration: InputDecoration(
                              labelText: "Qualification Detail",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black26),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black26),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.black26, width: 1.5),
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              labelStyle: TextStyle(color: Colors.black45),
                            ),
                            validator: (value) {
                              if ((regiController.isQualificationDetailVisible.value || hasExistingValue) &&
                                  (value == null || value.isEmpty)) {
                                return 'Please enter qualification details';
                              }
                              return null;
                            },
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      regiController.selectQlification.value = "";
      regiController.selectQualicationMain.value = "";
      regiController.selectQualicationCat.value = "";
      regiController.educationdetailController.value.text = "";
      regiController.isQualicationList.value = false;
      regiController.isQualificationCategoryVisible.value = false;
      regiController.isQualificationDetailVisible.value = false;
    });
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

  Widget educationWidget(Qualification qualification) {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      qualification.qualification ?? "Qualification",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          _showUpdateModalSheet(context, qualification),
                      icon: const Icon(Icons.edit, size: 12, color: Colors.red),
                      label: const Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFDC3545),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.black26),
                const SizedBox(height: 8),

                /// Qualification Details
                _buildInfoBox(
                  'Qualification Main',
                  subtitle: qualification.qualificationMainName ?? 'Other',
                ),
                _buildInfoBox(
                  'Qualification Category',
                  subtitle: qualification.qualificationCategoryName ?? 'Other',
                ),
                qualification.qualificationOtherName != null &&
                    qualification.qualificationOtherName!.trim().isNotEmpty
                    ? _buildInfoBox(
                  'Qualification Details',
                  subtitle: qualification.qualificationOtherName!,
                )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
