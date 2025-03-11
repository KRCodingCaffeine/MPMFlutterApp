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
              _showEditModalSheet(context,"1");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: regiController.qualificationList.value.isEmpty
            ? const Center(child: Text("No Education added yet."))
            : ListView.builder(
                itemCount: regiController.qualificationList.value.length,
                itemBuilder: (context, index) {
                  return educationWidget(
                      regiController.qualificationList.value[index]);
                },
              ),
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
                /// **Top Buttons: Cancel & Save**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel", style: TextStyle(color: Colors.red)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () async {
                        if (regiController.educationdetailController.value.text.isNotEmpty) {
                            regiController.addQualification();
                        }
                        else
                          {
                            Get.snackbar(
                              'Error', // Title
                              "Sorry no data", // Message
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              duration: Duration(seconds: 3),
                            );
                          }
                      },
                      child: regiController.addloading.value
                          ? CircularProgressIndicator()
                          : Text("Save"),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                /// **Qualification Dropdown**
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
                        regiController.selectQlification(newValue);
                        if (newValue == "other") {
                          regiController.isQualicationList.value = false;
                          regiController.isQualificationDetailVisible.value =
                              true;
                        } else {
                          regiController.isQualicationList.value = true;
                          regiController.isQualificationDetailVisible.value =
                              false;
                          regiController.getQualicationMain(newValue);
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
                      value: regiController.selectQualicationMain.value.isEmpty
                          ? null
                          : regiController.selectQualicationMain.value,
                      items: regiController.qulicationMainList
                          .map((QualicationMainData item) {
                        return DropdownMenuItem<String>(
                          value: item.id.toString(),
                          child: Text(item.name ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          regiController.selectQualicationMain(newValue);
                          if (newValue == "other") {
                            regiController
                                .isQualificationCategoryVisible.value = false;
                            regiController.isQualificationDetailVisible.value =
                                true;
                          } else {
                            regiController
                                .isQualificationCategoryVisible.value = true;
                            regiController.isQualificationDetailVisible.value =
                                false;
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
                          regiController.selectQualicationCat(newValue);
                          regiController.isQualificationDetailVisible.value =
                              true;
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
  Future<void> _showUpdateModalSheet(BuildContext context, Qualification qualification) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        regiController.selectQlification.value=qualification.memberQualificationId.toString();
        if(qualification.qualificationMainId.toString()!="") {
          regiController.isQualicationList.value=true;
          regiController.getQualicationMain(qualification.memberQualificationId.toString());
          regiController.selectQualicationMain.value = qualification.qualificationMainId.toString();
          regiController.isQualificationCategoryVisible.value=true;
          regiController.getQualicationCategory(qualification.qualificationCategoryId.toString());
          regiController.selectQualicationCat.value = qualification.qualificationCategoryId.toString();


        }
        else
          {
            regiController.isQualicationList.value=false;
            regiController.isQualificationCategoryVisible.value=false;
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
                /// **Top Buttons: Cancel & Save**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context),
                      child:
                          Text("Cancel", style: TextStyle(color: Colors.red)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () async {
                        if (regiController.educationdetailController.value.text.isNotEmpty) {
                          regiController.updateQualification();

                        }
                      },
                      child: regiController.addloading.value
                          ? CircularProgressIndicator()
                          : Text("Save"),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                /// **Qualification Dropdown**
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
                        regiController.selectQlification(newValue);
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
                      value: regiController.selectQualicationMain.value.isEmpty
                          ? null
                          : regiController.selectQualicationMain.value,
                      items: regiController.qulicationMainList
                          .map((QualicationMainData item) {
                        return DropdownMenuItem<String>(
                          value: item.id.toString(),
                          child: Text(item.name ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          regiController.selectQualicationMain(newValue);
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
                          regiController.selectQualicationCat(newValue);
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

  Widget educationWidget(Qualification qualification) {
    return GestureDetector(
      onTap: () {
        _showUpdateModalSheet(context,qualification);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
    );
  }
}
