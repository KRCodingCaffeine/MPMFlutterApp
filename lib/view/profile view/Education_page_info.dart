import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/data/response/status.dart';
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
        title: const Text(
          'Education Info',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add,size: 35,),
            onPressed: () {
              regiController.selectQlification.value="";
              regiController.selectQualicationMain.value="";
              regiController.selectQualicationCat.value="";
              _showEditModalSheet(context,"1");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx((){
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
                SizedBox(height: 30),
                /// **Top Buttons: Cancel & Save**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFDC3545),
                        elevation: 4,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (regiController.educationdetailController.value.text.isNotEmpty) {
                          regiController.addQualification();
                        } else {
                          Get.snackbar(
                            'Error', // Title
                            "Sorry, no data", // Message
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 3),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFDC3545),
                        elevation: 4,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: regiController.addloading.value
                          ? const CircularProgressIndicator(color: Color(0xFFDC3545))
                          : const Text("Save"),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                Obx(() {
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Qualification",
                      border: OutlineInputBorder(),
                    ),
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
                        regiController.selectQlification.value=newValue;

                        if (newValue == "other") {
                          regiController.isQualicationList.value = false;
                          regiController.isQualificationDetailVisible.value = true;
                        } else {
                          regiController.isQualicationList.value = true;
                          regiController.isQualificationDetailVisible.value = false;
                          regiController.getQualicationMain(newValue);
                        }
                      }
                    },
                  );
                }),
                SizedBox(height: 30),

                /// **Qualification Main Dropdown**
                Obx(() {
                  return Visibility(
                    visible: regiController.isQualicationList.value,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Select Qualification Main",
                        border: OutlineInputBorder(),
                      ),
                      value: regiController.selectQualicationMain.value.isEmpty
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
                          regiController.setSelectQualificationMain(newValue);

                          // regiController.setSelectQualificationMain(newValue);
                          if (newValue == "other") {
                            regiController.isQualificationCategoryVisible.value = false;
                            regiController.isQualificationDetailVisible.value =
                            true;
                          } else {
                            regiController.isQualificationCategoryVisible.value = true;
                            regiController.isQualificationDetailVisible.value = false;
                            regiController.getQualicationCategory(newValue);
                          }
                        }
                      },
                    ),
                  );
                }),
                SizedBox(height: 30),

                /// **Qualification Category Dropdown**
                Obx(() {
                  return Visibility(
                    visible:
                    regiController.isQualificationCategoryVisible.value,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Select Qualification Category",
                        border: OutlineInputBorder(),
                      ),
                      value: regiController.selectQualicationCat.value.isEmpty
                          ? null
                          : regiController.selectQualicationCat.value,
                      items: regiController.qulicationCategoryList
                          .map((Qualificationcategorydata item) {
                        return DropdownMenuItem<String>(
                          value: item.id.toString(),
                          child: Text(item.name ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          regiController.setSelectQualificationCat(newValue);
                          regiController.isQualificationDetailVisible.value = true;
                        }
                      },
                    ),
                  );
                }),
                SizedBox(height: 30),


                Obx(() {
                  return Visibility(
                    visible: regiController.isQualificationDetailVisible.value,
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller:
                      regiController.educationdetailController.value,
                      decoration: InputDecoration(
                        labelText: "Qualification Detail",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 30),            ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showUpdateModalSheet(BuildContext context, Qualification qualification) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        regiController.selectQlification.value=qualification.qualificationId.toString();
        print("fhggh"+regiController.selectQlification.value.toString());
        if (regiController.selectQualicationMain.value=="") {
          regiController.isQualicationList.value = true;
          regiController.getQualicationMain(
              qualification.qualificationId.toString());
          regiController.selectQualicationMain.value =
              qualification.qualificationMainId.toString();
          regiController.isQualificationCategoryVisible.value = true;
          regiController.getQualicationCategory(qualification.qualificationCategoryId.toString());
          regiController.selectQualicationCat.value = qualification.qualificationCategoryId.toString();
        }

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
                /// **Top Buttons: Cancel & Save**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFDC3545),
                        elevation: 4,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (regiController.educationdetailController.value.text.isNotEmpty) {
                          regiController.updateQualification(qualification.memberQualificationId.toString());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFDC3545),
                        elevation: 4,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: regiController.addloading.value
                          ? const CircularProgressIndicator(color: Colors.red)
                          : const Text("Save"),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Obx(() {
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Qualification",
                      border: OutlineInputBorder(),
                    ),
                    value: regiController.selectQlification.value.isEmpty
                        ? null
                        : regiController.selectQlification.value,
                    items: regiController.qulicationList
                        .map((QualificationData item) {
                      return DropdownMenuItem<String>(
                        value: item.id.toString(),
                        child: Text(item.qualification ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        regiController.setSelectQualification(newValue);
                        if (newValue == "other") {
                          regiController.isQualicationList.value = false;
                          regiController.isQualificationDetailVisible.value = true;
                        } else {
                          regiController.isQualicationList.value = true;
                          regiController.isQualificationDetailVisible.value = false;
                          regiController.getQualicationMain(newValue);
                          regiController.qulicationMainList.refresh();
                        }
                      }
                    },
                  );
                }),
                SizedBox(height: 20),

                /// **Qualification Main Dropdown**
                Obx(() {
                  return Visibility(
                    visible: regiController.isQualicationList.value,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Select Qualification Main",
                        border: OutlineInputBorder(),
                      ),
                      value: regiController.qulicationMainList.any((item) =>
                      item.id.toString() == regiController.selectQualicationMain.value)
                          ? regiController.selectQualicationMain.value
                          : null,
                      items: regiController.qulicationMainList.value
                          .map((QualicationMainData item) {
                        return DropdownMenuItem<String>(
                          value: item.id.toString(),
                          child: Text(item.name ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          // regiController.setSelectQualificationMain(newValue);
                          regiController.setSelectQualificationMain(newValue);

                          if (newValue == "other") {
                            regiController.isQualificationCategoryVisible.value = false;
                            regiController.isQualificationDetailVisible.value = true;
                          } else {
                            regiController.isQualificationCategoryVisible.value = true;
                            regiController.isQualificationDetailVisible.value = false;
                            regiController.getQualicationCategory(newValue);

                          }
                        }
                      },

                    ),
                  );
                }),
                SizedBox(height: 20),

                /// **Qualification Category Dropdown**
                Obx(() {
                  return Visibility(
                    visible: regiController.isQualificationCategoryVisible.value,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Select Qualification Category",
                        border: OutlineInputBorder(),
                      ),
                      value: regiController.qulicationCategoryList.value.any((item) =>
                      item.id.toString() == regiController.selectQualicationCat.value)
                          ? regiController.selectQualicationCat.value
                          : null,

                      items: regiController.qulicationCategoryList.value
                          .map((Qualificationcategorydata item) {
                        return DropdownMenuItem<String>(
                          value: item.id.toString(),
                          child: Text(item.name ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          regiController.setSelectQualificationCat(newValue);
                          regiController.isQualificationDetailVisible.value = true;
                        }
                      },
                    ),
                  );
                }),
                SizedBox(height: 20),

                /// **Qualification Detail TextField**
                Obx(() {
                  return Visibility(
                    visible: regiController.isQualificationDetailVisible.value,
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller:
                      regiController.educationdetailController.value,
                      decoration: InputDecoration(
                        labelText: "Qualification Detail",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 20),


              ],
            ),
          ),
        );
      },
    );
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
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Added margin
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Increased padding for better spacing
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header Row with Dynamic Title & Edit Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      qualification.qualification ?? "Qualification", // Dynamic Title
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showUpdateModalSheet(context, qualification),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.black26), // Thin separator line
                const SizedBox(height: 8), // Small spacing

                /// Qualification Details
                _buildInfoBox(
                  'Qualification',
                  subtitle: qualification.qualification,
                ),
                _buildInfoBox(
                  'Qualification Main',
                  subtitle: qualification.qualificationMainName,
                ),
                _buildInfoBox(
                  'Qualification Category',
                  subtitle: qualification.qualificationCategoryName,
                ),
                _buildInfoBox(
                  'Qualification Details',
                  subtitle: qualification.qualificationOtherName,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20), // Added spacing between each card
      ],
    );
  }
}
