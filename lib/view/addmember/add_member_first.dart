import 'dart:io';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/OccuptionProfession/OccuptionProfessionData.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/Occupation/OccupationData.dart';
import 'package:mpm/model/OccupationSpec/OccuptionSpecData.dart';
import 'package:mpm/model/Qualification/QualificationData.dart';
import 'package:mpm/model/QualificationCategory/QualificationCategoryModel.dart';
import 'package:mpm/model/QualificationMain/QualicationMainData.dart';
import 'package:mpm/model/bloodgroup/BloodData.dart';
import 'package:mpm/model/gender/DataX.dart';
import 'package:mpm/model/marital/MaritalData.dart';
import 'package:mpm/model/relation/RelationData.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/app_constants.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/register/register_view_model.dart';
import 'package:intl/intl.dart';

class NewMemberView extends StatefulWidget {
  const NewMemberView({super.key});
  @override
  State<NewMemberView> createState() => _NewMemberViewState();
}

class _NewMemberViewState extends State<NewMemberView> {
  String? _selectedGender;
  final regiController= Get.put(NewMemberController());

  File? _image;
  ImagePicker _picker = ImagePicker();
  int activeStep2 = 1;
  GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     regiController.getGender();
    regiController.getMaritalStatus();
     regiController.getBloodGroup();
    regiController.getOccupationData();
    regiController.getQualification();
    regiController.getMemberShip();
    regiController.getDocumentType();
    regiController.getRelation();



  }
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: Container(
          margin: EdgeInsets.only(bottom: 20,left: 20,right: 20),
          height: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 6.0,right: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  child: Container(

                    child: ElevatedButton(
                      onPressed: () {
                       // Navigator.pushReplacementNamed(context!, RouteNames.registration_screen);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(AppConstants.back,
                          style: TextStyleClass.white16style
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKeyLogin!.currentState!.validate()) {
                        // Helper function to show a snackbar
                        void showErrorSnackbar(String message) {
                          Get.snackbar(
                            "Error",
                            message,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        }

                        // Gender validation
                        if (regiController.selectedGender == '') {
                          showErrorSnackbar("Select Gender");
                          return;
                        }
                        if(regiController.selectBloodGroup=='')
                          {
                            showErrorSnackbar("Select Blood Group");
                            return;
                          }

                        // Marital status validation
                        if (regiController.selectMarital == '') {
                          showErrorSnackbar("Select Marital Status");
                          return;
                        }

                        // Occupation validation
                        if (regiController.selectOccuption == '') {
                          showErrorSnackbar("Select Occupation");
                          return;
                        } else if (regiController.selectOccuption == 'other') {
                          // Specific logic for "Other" case (if any)
                        } else {
                          if (regiController.selectOccuptionPro == '') {
                            showErrorSnackbar("Select Occupation Profession");
                            return;
                          }
                          if (regiController.selectOccuptionSpec == '') {
                            showErrorSnackbar("Select Occupation Specialization");
                            return;
                          }
                        }

                        // Qualification validation
                        if (regiController.selectQlification == '') {
                          showErrorSnackbar("Select Qualification");
                          return;
                        } else if (regiController.selectQlification == 'other') {
                          // Specific logic for "Other" case (if any)
                        } else {
                          if (regiController.selectQualicationMain == '') {
                            showErrorSnackbar("Select Qualification Main");
                            return;
                          }
                          if (regiController.selectQualicationCat == '') {
                            showErrorSnackbar("Select Qualification Category");
                            return;
                          }
                        }
                          if(regiController.isRelation.value==true)
                           {
                            if (regiController.selectRelationShipType.value == '') {
                              showErrorSnackbar("Select Relation");
                              return;
                            }
                          }



                        // If all validations pass, proceed with the desired logic
                        print("All validations passed!");
                        // You can now access the values through regiController
                        print("Selected Gender: ${regiController.selectedGender}");
                        print("Selected Marital Status: ${regiController.selectMarital}");
                        print("Selected Occupation: ${regiController.selectOccuption}");
                        print("Selected Qualification: ${regiController.selectQlification}");
                        Navigator.pushNamed(context!, RouteNames.newMember2);
                      }


                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(AppConstants.continues,
                        style: TextStyleClass.white16style
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Align(
                      alignment: Alignment.center,
                      child: Text(AppConstants.welcome_mpm,
                          style: TextStyleClass.black20style
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: EasyStepper(
                        activeStep: activeStep2,
                        stepShape: StepShape.rRectangle,
                        stepBorderRadius: 30,
                        lineStyle: LineStyle(
                          lineLength: 70,
                          lineSpace: 1,
                          lineType: LineType.normal,
                          unreachedLineColor: Colors.grey.withOpacity(0.5),
                          finishedLineColor: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                          activeLineColor: Colors.grey.withOpacity(0.5),
                        ),
                        activeStepBorderColor:ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                        activeStepIconColor: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                        activeStepTextColor: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                        activeStepBackgroundColor: Colors.white,

                        unreachedStepBorderColor:
                        Colors.grey.withOpacity(0.5),
                        unreachedStepIconColor: Colors.grey,
                        unreachedStepTextColor: Colors.grey.withOpacity(0.5),
                        finishedStepBackgroundColor: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                        finishedStepBorderColor: Colors.grey.withOpacity(0.5),
                        finishedStepIconColor: Colors.white,
                        finishedStepTextColor: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                        borderThickness: 2,
                        internalPadding: 4,
                        showLoadingAnimation: false,
                        steps: [

                          EasyStep(
                            icon: const Icon(CupertinoIcons.info),
                            title: 'Personal Info',
                            lineText: '',

                          ),
                          EasyStep(
                            icon: const Icon(
                              CupertinoIcons.doc,size: 15,),
                            title: 'Residental info',
                            lineText: '',

                          ),

                        ],
                        onStepReached: (index) => setState(() {
                          activeStep2 = index;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                 child:Container(
                   padding: EdgeInsets.only(left: 20,right: 20,),
                   child: Form(
                     key: _formKeyLogin,
                       child:  Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Align(
                         alignment: Alignment.center,
                         child: GestureDetector(
                           onTap:  (){
                             _showPicker(context: context);
                           } , // Trigger image picker on tap
                           child: CircleAvatar(
                             radius: 80, // Circle size
                             backgroundColor: Colors.grey[300],
                             backgroundImage:
                             _image != null ? FileImage(_image!) : null, // Display image
                             child: _image == null
                                 ? Icon(
                               Icons.camera_alt,
                               color: Colors.grey[700],
                               size: 40,
                             )
                                 : null, // Placeholder icon when no image
                           ),
                         ),
                       ),
                       SizedBox(height: 20),
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
                               controller: regiController.firstNameController.value,
                               decoration: InputDecoration(
                                 prefixIcon: Icon(Icons.person,color: ColorHelperClass.getColorFromHex(ColorResources.pink_color)),
                                 hintText: 'First Name',
                                 border: InputBorder.none, // Remove the internal border
                                 contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 20), // Adjust padding
                               ),
                               validator: (value) {
                                 if (value!.isEmpty) {
                                   return 'Enter First Name';
                                 }
                                 else {
                                   return null;
                                 }
                               }
                           ),
                         ),
                       ),
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
                             controller: regiController.middleNameController.value,

                             decoration: InputDecoration(
                               prefixIcon: Icon(Icons.person,color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),),
                               hintText: 'Middle Name (Optional)',
                               border: InputBorder.none, // Remove the internal border
                               contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 20), // Adjust padding
                             ),
                           ),
                         ),
                       ),
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
                             controller: regiController.lastNameController.value,
                             validator: (value) {
                               if (value!.isEmpty) {
                                 return 'Enter Last Name';
                               }
                               else {
                                 return null;
                               }
                             },
                             decoration: InputDecoration(
                               prefixIcon: Icon(Icons.person,color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),),
                               hintText: 'Last Name',
                               border: InputBorder.none, // Remove the internal border
                               contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 20), // Adjust padding
                             ),
                           ),
                         ),
                       ),
                       SizedBox(height: 8),

                       SizedBox(
                         width: double.infinity,
                         child: Padding(
                           padding: const EdgeInsets.only(left: 6.0,right: 6),
                           child: Container(
                             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(12),
                               border: Border.all(color: Colors.grey),
                             ),
                             child: Row(
                               children: [
                                 Image.asset(Images.indiaImage, // Replace with your flag asset
                                   height: 40, // Adjust height as needed
                                   width: 40,
                                   fit: BoxFit.cover,
                                 ),
                                 SizedBox(width: 18), // Space between the flag and text field


                                 Expanded(
                                   child: TextFormField(
                                     controller: regiController.mobileController.value,
                                     keyboardType: TextInputType.phone,
                                     validator: (value) {
                                       if (value!.isEmpty) {
                                         return 'Enter Mobile Number';
                                       }
                                       else if(value.length>10){
                                         return "Enter 10 digit mobile number ";
                                       }
                                       else {
                                         return null;
                                       }
                                     },
                                     decoration: InputDecoration(

                                       hintText: 'Mobile number',
                                       border: InputBorder.none, // Remove the internal border
                                       contentPadding: EdgeInsets.symmetric(vertical: 8), // Adjust padding
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         ),
                       ),
                       SizedBox(height: 8),
                       SizedBox(
                         width: double.infinity,
                         child: Padding(
                           padding: const EdgeInsets.only(left: 6.0,right: 6),
                           child: Container(
                             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(12),
                               border: Border.all(color: Colors.grey),
                             ),
                             child: Row(
                               children: [
                                 Image.asset(Images.indiaImage, // Replace with your flag asset
                                   height: 40, // Adjust height as needed
                                   width: 40,
                                   fit: BoxFit.cover,
                                 ),
                                 SizedBox(width: 18), // Space between the flag and text field
                                 Expanded(
                                   child: TextFormField(
                                     controller: regiController.whatappmobileController.value,
                                     keyboardType: TextInputType.phone,
                                     validator: (value) {
                                       if (value!.isEmpty) {
                                         return 'Enter Whatsapp Mobile Number';
                                       }
                                       else if(value.length>10){
                                         return "Enter 10 digit Whatsapp mobile number ";
                                       }
                                       else {
                                         return null;
                                       }
                                     },
                                     decoration: InputDecoration(
                                       hintText: 'Whatsapp Mobile number',
                                       border: InputBorder.none, // Remove the internal border
                                       contentPadding: EdgeInsets.symmetric(vertical: 8), // Adjust padding
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         ),
                       ),
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
                             keyboardType: TextInputType.emailAddress,
                             controller: regiController.emailController.value,
                             validator: (value) {
                               if (value!.isEmpty) {
                                 return 'Enter Email ID';
                               }
                               else if(!value.contains("@")){
                                 return "Enter valid email";
                               }
                               else {
                                 return null;
                               }
                             },
                             decoration: InputDecoration(
                               prefixIcon: Icon(Icons.alternate_email_outlined,color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),),
                               hintText: 'Email',
                               border: InputBorder.none, // Remove the internal border
                               contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 20), // Adjust padding
                             ),
                           ),
                         ),
                       ),
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
                             readOnly: true,
                             controller: regiController.dateController,
                             decoration: InputDecoration(
                               hintText: 'DOB',
                               prefixIcon: Icon(Icons.date_range_rounded,color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),),
                               border: InputBorder.none, // Remove the internal border
                               contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 20), // Adjust padding
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
                                   regiController.dateController.text = formattedDate;
                                 });
                               }

                             },
                           ),

                         ),
                       ),
                       SizedBox(height: 8),
                       Container(
                         width: double.infinity,
                         margin: EdgeInsets.only(left: 5,right: 5),
                         decoration: BoxDecoration(
                           border: Border.all(color: Colors.grey),
                           borderRadius: BorderRadius.circular(5),
                         ),
                         child: Row(
                           children: [
                             Padding(
                               padding: const EdgeInsets.only(left: 12.0),
                               child: Image.asset(Images.blood, // Replace with your flag asset
                                 height: 29, // Adjust height as needed
                                 width: 29,
                                 fit: BoxFit.cover,
                                 color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                               ),
                             ),
                             Obx(() {
                               if (regiController.rxStatusLoading.value == Status.LOADING) {
                                 return Padding(
                                   padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                   child: Container(
                                       alignment: Alignment.centerRight,
                                       height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                 );
                               } else if (regiController.rxStatusLoading.value == Status.ERROR) {
                                 return Center(child: Text('Failed to load blood group'));
                               } else if (regiController.bloodgroupList.isEmpty) {
                                 return Center(child: Text('No blood gruop available'));
                               } else {
                                 return Expanded(
                                   child: DropdownButton<String>(
                                     padding: EdgeInsets.symmetric(horizontal: 20),
                                     isExpanded: true,
                                     underline: Container(),
                                     hint: Text('Select Blood Group',style: TextStyle(
                                         fontWeight: FontWeight.bold
                                     ),), // Hint to show when nothing is selected
                                     value: regiController.selectBloodGroup.value.isEmpty
                                         ? null
                                         : regiController.selectBloodGroup.value,

                                     items: regiController.bloodgroupList.map((BloodGroupData marital) {
                                       return DropdownMenuItem<String>(
                                         value: marital.id.toString(), // Use unique ID or any unique property.
                                         child: Text(marital.bloodGroup ?? 'Unknown'), // Display name from DataX.
                                       );
                                     }).toList(), // Convert to List.
                                     onChanged: (String? newValue) {
                                       if (newValue != null) {
                                         regiController.setSelectedBloodGroup(newValue);
                                       }
                                     },
                                   ),
                                 );
                               }
                             }),
                           ],
                         ),
                       ),
                       SizedBox(height: 8),

                       Container(
                         margin: EdgeInsets.only(left: 5,right: 5),
                         width: double.infinity,
                         decoration: BoxDecoration(
                           border: Border.all(color: Colors.grey),
                           borderRadius: BorderRadius.circular(5),
                         ),
                         child: Row(
                           children: [
                             Padding(
                               padding: const EdgeInsets.only(left: 12.0),
                               child: Image.asset(Images.gender, // Replace with your flag asset
                                 height: 29, // Adjust height as needed
                                 width: 29,
                                 fit: BoxFit.cover,
                                 color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                               ),
                             ),

                             Obx((){
                               if (regiController.rxStatusLoading2.value == Status.LOADING) {
                                 return Padding(
                                   padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                   child: Container(
                                       alignment: Alignment.centerRight,
                                       height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                 );
                               } else if (regiController.rxStatusLoading2.value == Status.ERROR) {
                                 return Center(child: Text('Failed to load genders'));
                               } else if (regiController.genderList.isEmpty) {
                                 return Center(child: Text('No genders available'));
                               }
                               else
                               {
                                 return Expanded(
                                   child: DropdownButton<String>(
                                     padding: EdgeInsets.symmetric(horizontal: 20),
                                     underline: Container(),
                                     isExpanded: true,
                                     hint: Text('Select Gender',style: TextStyle(
                                       fontWeight: FontWeight.bold,


                                     ),),
                                     value: regiController.selectedGender.value.isEmpty
                                         ? null
                                         : regiController.selectedGender.value,
                                     items: regiController.genderList.map((DataX gender) {
                                       return DropdownMenuItem<String>(
                                         value: gender.id.toString(), // Use unique ID or any unique property.
                                         child: Text(gender.genderName ?? 'Unknown'), // Display name from DataX.
                                       );
                                     }).toList(),
                                     onChanged: (String? newValue) {
                                       if (newValue != null) {
                                         regiController.setSelectedGender(newValue);
                                       }
                                     },

                                   ),
                                 );
                               }
                             })
                           ],
                         ),
                       ),
                       Obx((){
                         return Visibility(
                           visible: regiController.isRelation.value,
                           child: Container(
                             margin: EdgeInsets.only(left: 5,right: 5,top: 8),
                             width: double.infinity,
                             decoration: BoxDecoration(
                               border: Border.all(color: Colors.grey),
                               borderRadius: BorderRadius.circular(5),
                             ),
                             child: Row(
                               children: [
                                 Padding(
                                   padding: const EdgeInsets.only(left: 12.0),
                                   child: Image.asset(Images.user, // Replace with your flag asset
                                     height: 29, // Adjust height as needed
                                     width: 29,
                                     fit: BoxFit.cover,
                                     color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                   ),
                                 ),

                                 Obx((){
                                   if (regiController.rxStatusRelationType.value == Status.LOADING) {
                                     return Padding(
                                       padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                       child: Container(
                                           alignment: Alignment.centerRight,
                                           height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                     );
                                   } else if (regiController.rxStatusRelationType.value == Status.ERROR) {
                                     return Center(child: Text('Failed to load relation'));
                                   } else if (regiController.relationShipTypeList.isEmpty) {
                                     return Center(child: Text('No relation available'));
                                   }
                                   else
                                   {
                                     return Expanded(
                                       child: DropdownButton<String>(
                                         padding: EdgeInsets.symmetric(horizontal: 20),
                                         underline: Container(),
                                         isExpanded: true,
                                         hint: Text('Select Relation',style: TextStyle(
                                           fontWeight: FontWeight.bold,


                                         ),),
                                         value: regiController.selectRelationShipType.value.isEmpty
                                             ? null
                                             : regiController.selectRelationShipType.value,
                                         items: regiController.relationShipTypeList.map((RelationData gender) {
                                           return DropdownMenuItem<String>(
                                             value: gender.id.toString(), // Use unique ID or any unique property.
                                             child: Text(gender.name ?? 'Unknown'), // Display name from DataX.
                                           );
                                         }).toList(),
                                         onChanged: (String? newValue) {
                                           if (newValue != null) {
                                             regiController.selectRelationShipType(newValue);
                                           }
                                         },

                                       ),
                                     );
                                   }
                                 })
                               ],
                             ),
                           ),);
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
                           child: Row(
                             children: [
                               Padding(
                                 padding: const EdgeInsets.only(left: 12.0),
                                 child: Image.asset(Images.marraige, // Replace with your flag asset
                                   height: 29, // Adjust height as needed
                                   width: 29,
                                   fit: BoxFit.cover,
                                   color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                 ),
                               ),
                               Obx(() {
                                 if (regiController.rxStatusmarried.value == Status.LOADING) {
                                   return Padding(
                                     padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                     child: Container(
                                         alignment: Alignment.centerRight,
                                         height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                   );
                                 } else if (regiController.rxStatusmarried.value == Status.ERROR) {
                                   return Center(child: Text('Failed to load marital'));
                                 } else if (regiController.maritalList.isEmpty) {
                                   return Center(child: Text('No merital status available'));
                                 } else {
                                   return Expanded(
                                     child: DropdownButton<String>(
                                       padding: EdgeInsets.symmetric(horizontal: 20),
                                       isExpanded: true,
                                       underline: Container(),
                                       hint: Text('Select marital',style: TextStyle(
                                           fontWeight: FontWeight.bold
                                       ),), // Hint to show when nothing is selected
                                       value: regiController.selectMarital.value.isEmpty
                                           ? null
                                           : regiController.selectMarital.value,

                                       items: regiController.maritalList.map((MaritalData marital) {
                                         return DropdownMenuItem<String>(
                                           value: marital.id.toString(), // Use unique ID or any unique property.
                                           child: Text(marital.maritalStatus ?? 'Unknown'), // Display name from DataX.
                                         );
                                       }).toList(), // Convert to List.
                                       onChanged: (String? newValue) {
                                         if (newValue != null) {
                                           regiController.selectMarital(newValue);
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
                               Padding(
                                 padding: const EdgeInsets.only(left: 12.0),
                                 child: Image.asset(Images.occupation, // Replace with your flag asset
                                   height: 29, // Adjust height as needed
                                   width: 29,
                                   fit: BoxFit.cover,
                                   color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                 ),
                               ),
                               Obx(() {
                                 if (regiController.rxStatusOccupation.value == Status.LOADING) {
                                   return Padding(
                                     padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                     child: Container(
                                         alignment: Alignment.centerRight,
                                         height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                   );
                                 } else if (regiController.rxStatusOccupation.value == Status.ERROR) {
                                   return Center(child: Text('Failed to load occuption'));
                                 } else if (regiController.occuptionList.isEmpty) {
                                   return Center(child: Text('No occuption  available'));
                                 } else {
                                   return Expanded(
                                     child: DropdownButton<String>(
                                       padding: EdgeInsets.symmetric(horizontal: 20),
                                       isExpanded: true,
                                       underline: Container(),
                                       hint: Text('Select Occuption',style: TextStyle(
                                           fontWeight: FontWeight.bold
                                       ),), // Hint to show when nothing is selected
                                       value: regiController.selectOccuption.value.isEmpty
                                           ? null
                                           : regiController.selectOccuption.value,

                                       items: regiController.occuptionList.map((OccupationData marital) {
                                         return DropdownMenuItem<String>(
                                           value: marital.id.toString(), // Use unique ID or any unique property.
                                           child: Text(marital.occupation ?? 'Unknown'), // Display name from DataX.
                                         );
                                       }).toList(),
                                       onChanged: (String? newValue) {
                                         print("fddfdfff"+newValue.toString());

                                         regiController.selectOccuption(newValue);
                                         if (newValue != null) {
                                           regiController.selectOccuption(newValue);
                                           if(newValue!="other")
                                           {
                                             regiController.isOccutionList.value=true;
                                             regiController.getOccupationProData(newValue);
                                           }
                                           else
                                           {
                                             regiController.isOccutionList.value=false;


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
                       SizedBox(
                         height: 8,
                       ),
                       Obx((){
                         return Visibility(
                             visible: regiController.isOccutionList.value,
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
                                         Padding(
                                           padding: const EdgeInsets.only(left: 12.0),
                                           child: Image.asset(Images.occupation, // Replace with your flag asset
                                             height: 29, // Adjust height as needed
                                             width: 29,
                                             fit: BoxFit.cover,
                                             color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                           ),
                                         ),
                                         Obx(() {
                                           if (regiController.rxStatusOccupationData.value == Status.LOADING) {
                                             return Padding(
                                               padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                               child: Container(
                                                   alignment: Alignment.centerRight,
                                                   height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                             );
                                           } else if (regiController.rxStatusOccupationData.value == Status.ERROR) {
                                             return Center(child: Text('Failed to load occuption Profession'));
                                           }
                                           else if (regiController.rxStatusOccupationData.value == Status.IDLE) {
                                             return Center(child: Padding(
                                               padding: const EdgeInsets.all(12.0),
                                               child: Text('Select Occuption Profession'),
                                             ));
                                           }


                                           else if (regiController.occuptionProfessionList.isEmpty) {
                                             return Center(child: Text('No occuption Pro available'));
                                           } else {
                                             return Expanded(
                                               child: DropdownButton<String>(
                                                 padding: EdgeInsets.symmetric(horizontal: 20,),
                                                 isExpanded: true,
                                                 underline: Container(),
                                                 hint: Text('Select Occuption Profession',style: TextStyle(
                                                     fontWeight: FontWeight.bold
                                                 ),), // Hint to show when nothing is selected
                                                 value: regiController.selectOccuptionPro.value.isEmpty
                                                     ? null
                                                     : regiController.selectOccuptionPro.value,

                                                 items: regiController.occuptionProfessionList.map((OccuptionProfessionData marital) {
                                                   return DropdownMenuItem<String>(
                                                     value: marital.id.toString(), // Use unique ID or any unique property.
                                                     child: Text(marital.name ?? 'Unknown'), // Display name from DataX.
                                                   );
                                                 }).toList(), // Convert to List.
                                                 onChanged: (String? newValue) {
                                                   if (newValue != null) {
                                                     regiController.setSelectOccuptionPro(newValue);
                                                     regiController.getOccupationSpectData(newValue);

                                                   }
                                                 },
                                               ),
                                             );
                                           }
                                         }),
                                       ],
                                     )),
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
                                         Padding(
                                           padding: const EdgeInsets.only(left: 12.0),
                                           child: Image.asset(Images.occupation, // Replace with your flag asset
                                             height: 29, // Adjust height as needed
                                             width: 29,
                                             fit: BoxFit.cover,
                                             color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                           ),
                                         ),
                                         Obx(() {
                                           if (regiController.rxStatusOccupationSpec.value == Status.LOADING) {
                                             return Padding(
                                               padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                               child: Container(
                                                   alignment: Alignment.centerRight,
                                                   height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                             );
                                           } else if (regiController.rxStatusOccupationSpec.value == Status.ERROR) {
                                             return Center(child: Text('Failed to load occuption specialization',style: TextStyle(
                                                 fontWeight: FontWeight.bold
                                             ),), );
                                           }
                                           else if (regiController.rxStatusOccupationSpec.value == Status.IDLE) {
                                             return Center(child: Padding(
                                               padding: const EdgeInsets.all(12.0),
                                               child: Text('Select Occuption specialization,',style: TextStyle(
                                                   fontWeight: FontWeight.bold
                                               ),),
                                             ));
                                           }

                                           else if (regiController.occuptionSpeList.isEmpty) {
                                             return Center(child: Text('No occuption specialization available'));
                                           } else {
                                             return Expanded(
                                               child: DropdownButton<String>(
                                                 padding: EdgeInsets.symmetric(horizontal: 20),
                                                 isExpanded: true,
                                                 underline: Container(),
                                                 hint: Text('Select Occuption specialization',style: TextStyle(
                                                     fontWeight: FontWeight.bold
                                                 ),),
                                                 value: regiController.selectOccuptionSpec.value.isEmpty
                                                     ? null
                                                     : regiController.selectOccuptionSpec.value,

                                                 items: regiController.occuptionSpeList.map((OccuptionSpecData marital) {
                                                   return DropdownMenuItem<String>(
                                                     value: marital.id.toString(), // Use unique ID or any unique property.
                                                     child: Text(marital.name ?? 'Unknown'), // Display name from DataX.
                                                   );
                                                 }).toList(), // Convert to List.
                                                 onChanged: (String? newValue) {
                                                   if (newValue != null) {
                                                     regiController.selectOccuptionSpec(newValue);

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
                             controller: regiController.occuptiondetailController.value,
                             validator: (value) {
                               if (value!.isEmpty) {
                                 return 'Enter Occupation Detail';
                               }
                               else {
                                 return null;
                               }
                             },
                             decoration: InputDecoration(
                               prefixIcon: Icon(Icons.details,color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),),
                               hintText: 'Occupation detail',
                               border: InputBorder.none, // Remove the internal border
                               contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 20), // Adjust padding
                             ),
                           ),
                         ),
                       ),
                       SizedBox(height: 8),
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
                               Padding(
                                 padding: const EdgeInsets.only(left: 12.0),
                                 child: Image.asset(Images.qualification, // Replace with your flag asset
                                   height: 29, // Adjust height as needed
                                   width: 29,
                                   fit: BoxFit.cover,
                                   color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                 ),
                               ),
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
                                         Padding(
                                           padding: const EdgeInsets.only(left: 12.0),
                                           child: Image.asset(Images.qualification, // Replace with your flag asset
                                             height: 29, // Adjust height as needed
                                             width: 29,
                                             fit: BoxFit.cover,
                                             color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                           ),
                                         ),
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
                                         Padding(
                                           padding: const EdgeInsets.only(left: 12.0),
                                           child: Image.asset(Images.qualification, // Replace with your flag asset
                                             height: 29, // Adjust height as needed
                                             width: 29,
                                             fit: BoxFit.cover,
                                             color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                           ),
                                         ),
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
                               hintText: 'Education detail',
                               border: InputBorder.none, // Remove the internal border
                               contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 20), // Adjust padding
                             ),
                           ),
                         ),
                       ),
                       SizedBox(height: 80),

                     ],
                   )),
                 ),
                           ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showPicker({required BuildContext context,}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () async {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                   Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> getImage(ImageSource img,) async {
    if (ImagePicker().supportsImageSource(img) == true) {
      try {
        final  XFile? pickedFile = await ImagePicker().pickImage(
          source: img,
          imageQuality: 80
        );
        setState(() {
          _image = File(pickedFile!.path);


        });
        if(pickedFile!.path!=null)
          {
            regiController.userprofile.value=pickedFile!.path;
          }
      } catch (e) {
        print("gggh" + e.toString());
      }
    }
  }

}
