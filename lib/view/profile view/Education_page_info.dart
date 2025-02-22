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
  UdateProfileController regiController=Get.put(UdateProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Education Info', style: TextStyle(color: Colors.white),),
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditModalSheet(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: regiController.qualificationList.value.isEmpty
            ? const Center(child: Text("No family members added yet."))
            : ListView.builder(
          itemCount: regiController.qualificationList.value.length,
          itemBuilder: (context, index) {
            return educationWidget(regiController.qualificationList.value[index]);
          },
        ),
      ),
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
                // Add "Save" TextButton at the top-right corner with custom color
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Color(
                          0xFFDC3545), // Setting the button color to #DC3545
                    ),
                    onPressed: () async{
                      if(regiController.educationdetailController.value!="") {
                        regiController.addQualification(context);
                      }
                      else
                        {

                        }
                    },
                    child:  regiController.addloading.value?CircularProgressIndicator():Text(
                      "Save",
                    ),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: Container(
                    margin: EdgeInsets.only(left: 5,right: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [

                        Obx(() {
                          if (regiController.rxStatusQualification.value == Status.LOADING) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                            );
                          } else if (regiController.rxStatusQualification.value == Status.ERROR) {
                            return Center(child: Text('Failed to load Qualification'));
                          } else if (regiController.qulicationList.isEmpty) {
                            return Center(child: Text('No Qualification  available'));
                          } else {
                            return Expanded(
                              child: DropdownButton<String>(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                isExpanded: true,
                                underline: Container(),
                                hint: Text('Select Qualification',style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),), // Hint to show when nothing is selected
                                value: regiController.selectQlification.value.isEmpty
                                    ? null
                                    : regiController.selectQlification.value,

                                items: regiController.qulicationList.map((QualificationData marital) {
                                  return DropdownMenuItem<String>(
                                    value: marital.id.toString(), // Use unique ID or any unique property.
                                    child: Text(marital.qualification ?? 'Unknown'), // Display name from DataX.
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  print("fddfdfff"+newValue.toString());


                                  if (newValue != null) {
                                    regiController.selectQlification(newValue);
                                    if(newValue!="other")
                                    {
                                      regiController.isQualicationList.value=true;
                                      regiController.getQualicationMain(newValue);
                                    }
                                    else
                                    {
                                      regiController.isQualicationList.value=false;


                                    }
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

                SizedBox(height: 8),
                Obx((){
                  return Visibility(
                      visible: regiController.isQualicationList.value,
                      child: Column(
                        children: [
                          Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(left: 5,right: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child:Row(
                                children: [

                                  Obx(() {
                                    if (regiController.rxStatusQualificationMain.value == Status.LOADING) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                        child: Container(
                                            alignment: Alignment.centerRight,
                                            height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                      );
                                    } else if (regiController.rxStatusQualificationMain.value == Status.ERROR) {
                                      return Center(child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Text(' No Data ', style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        ),),
                                      ));
                                    }
                                    else if (regiController.rxStatusQualificationMain.value == Status.IDLE) {
                                      return Center(child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text('Select  Qualification Main'),
                                      ));
                                    }

                                    else if (regiController.qulicationMainList.isEmpty) {
                                      return Center(child: Text('No Qualification Main available'));
                                    } else {
                                      return Expanded(
                                        child: DropdownButton<String>(
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          isExpanded: true,
                                          underline: Container(),
                                          hint: Text('Select Qualification Main',style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          ),), // Hint to show when nothing is selected
                                          value: regiController.selectQualicationMain.value.isEmpty
                                              ? null
                                              : regiController.selectQualicationMain.value,

                                          items: regiController.qulicationMainList.map((QualicationMainData marital) {
                                            return DropdownMenuItem<String>(
                                              value: marital.id.toString(), // Use unique ID or any unique property.
                                              child: Text(marital.name ?? 'Unknown'), // Display name from DataX.
                                            );
                                          }).toList(), // Convert to List.
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              regiController.selectQualicationMain(newValue);
                                              regiController.getQualicationCategory(newValue);
                                            }
                                          },
                                        ),
                                      );
                                    }
                                  }),
                                ],
                              )


                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(left: 5,right: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child:Row(
                                children: [

                                  Obx(() {
                                    if (regiController.rxStatusQualificationCat.value == Status.LOADING) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                        child: Container(
                                            alignment: Alignment.centerRight,
                                            height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                      );
                                    } else if (regiController.rxStatusQualificationCat.value == Status.ERROR) {
                                      return Center(child: Text('No Data'));
                                    }
                                    else if (regiController.rxStatusQualificationCat.value == Status.IDLE) {
                                      return Center(child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text('Select Qualification Category',style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        ),),
                                      ));
                                    }


                                    else if (regiController.qulicationCategoryList.isEmpty) {
                                      return Center(child: Text('No qualification Category available'));
                                    } else {
                                      return Expanded(
                                        child: DropdownButton<String>(
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          isExpanded: true,
                                          underline: Container(),
                                          hint: Text('Select Qualification Category',style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          ),), // Hint to show when nothing is selected
                                          value: regiController.selectQualicationCat.value.isEmpty
                                              ? null
                                              : regiController.selectQualicationCat.value,

                                          items: regiController.qulicationCategoryList.map((Qualificationcategorydata marital) {
                                            return DropdownMenuItem<String>(
                                              value: marital.id.toString(), // Use unique ID or any unique property.
                                              child: Text(marital.name ?? 'Unknown'), // Display name from DataX.
                                            );
                                          }).toList(), // Convert to List.
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              regiController.selectQualicationCat(newValue);

                                            }
                                          },
                                        ),
                                      );
                                    }
                                  }),
                                ],
                              )


                          ),
                        ],
                      ));
                }),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    margin: EdgeInsets.only(left: 5,right: 5),

                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: regiController.educationdetailController.value,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Education Detail';
                        }
                        else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.details,color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),),
                        hintText: 'Qualification detail',
                        border: InputBorder.none, // Remove the internal border
                        contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 20), // Adjust padding
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      onChanged: onChanged,
    );
  }


  void _showSuccessMessage() {
    final snackBar = SnackBar(
      content:  Text('Education Info updated successfully!'),
      duration:  Duration(seconds: 2),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showFailureMessage() {
    final snackBar = SnackBar(
      content: const Text('Failed to update information. Please check fields.'),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red,
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
  Widget educationWidget(Qualification qualification){
    return  GestureDetector(
      onTap: () {
        _showEditModalSheet(context);
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
