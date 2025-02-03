import 'dart:io';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CheckPinCode/Building.dart';
import 'package:mpm/model/documenttype/DocumentTypeModel.dart';
import 'package:mpm/model/membership/MemberShipData.dart';

import 'package:mpm/utils/app_constants.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/register/register_view_model.dart';
import 'package:permission_handler/permission_handler.dart';


class NewMemberResidental extends StatefulWidget {
  const NewMemberResidental({super.key});

  @override
  State<NewMemberResidental> createState() => _NewMemberResidentalState();
}

class _NewMemberResidentalState extends State<NewMemberResidental> {
  String? _selectedDocs;
  final regiController= Get.put(NewMemberController());

  File? _image;
  int activeStep2 = 2;

  List<XFile>? _mediaFileList;
  GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();


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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
          margin: EdgeInsets.only(bottom: 20,left: 20,right: 20,top: 10),
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
                  child: Obx(() => ElevatedButton(
                    onPressed: () {
                      if (_formKeyLogin!.currentState!.validate()) {
                        void showErrorSnackbar(String message) {
                          Get.snackbar(
                            "Error",
                            message,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                        if (regiController.selectBuilding == '') {
                          showErrorSnackbar("Select Building Name");
                          return;
                        }
                        if (regiController.selectDocumentType == '') {
                          showErrorSnackbar("Select Document Type");
                          return;
                        }
                        if(regiController.userdocumentImage.value=='')
                          {
                            showErrorSnackbar("Select Document Image");
                            return;
                          }
                        if(regiController.selectMemberShipType.value=='')
                        {
                          showErrorSnackbar("Select MemberShip Type");
                          return;
                        }
                        regiController.userRegister(
                          regiController.lmCodeValue.value,
                          context,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: regiController.loading.value
                        ? SizedBox(
                        width: 24,
                        height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white, // Loading indicator color
                        strokeWidth: 2, // Thickness of the spinner
                      ),
                    )
                        : Text(
                      AppConstants.continues,
                      style: TextStyleClass.white16style,
                    ),
                  )),
                ),

              ],
            ),
          ),
        ),
        body: Container(
          height: screenHeight,
          padding: EdgeInsets.only(top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Column(
                  children: [
                    SizedBox(height: 20,),
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
                    child: Container(
                      padding: EdgeInsets.only(left: 20,right: 20,),
                      child: Form(
                        key: _formKeyLogin,
                          child: Column(
                        children: [
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
                                    child: Image.asset(Images.pin, // Replace with your flag asset
                                      height: 29, // Adjust height as needed
                                      width: 29,
                                      fit: BoxFit.cover,
                                      color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                    ),
                                  ),
                                  // Space between the flag and text field
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.phone,
                                      controller: regiController.pincodeController.value,
                                      decoration: InputDecoration(
                                        hintText: 'Pin Code',
                                        border: InputBorder.none, // Remove the internal border
                                        contentPadding: EdgeInsets.symmetric(vertical: 8,horizontal: 20), // Adjust padding
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 18),
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        print("fghjjhjjh"+regiController.pincodeController.value.text);
                                        if(regiController.pincodeController.value.text!='') {
                                          var pincode=regiController.pincodeController.value.text;
                                          regiController.getCheckPinCode(pincode);
                                        }
                                        else
                                        {
                                          Get.snackbar(
                                            "Error",
                                            "Select Pin Code",
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.TOP,
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      child: Icon(Icons.search,color: Colors.white,),
                                    ),
                                  ),
                                ],
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
                                  child: Image.asset(Images.house, // Replace with your flag asset
                                    height: 29, // Adjust height as needed
                                    width: 29,
                                    fit: BoxFit.cover,
                                    color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                  ),
                                ),
                               Obx((){
                                 return Visibility(
                                   visible: regiController.isBuilding.value==false,
                                   child:  Obx(() {
                                   if (regiController.rxStatusBuilding.value == Status.LOADING) {
                                     return Padding(
                                       padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                       child: Container(
                                           alignment: Alignment.centerRight,
                                           height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                     );
                                   } else if (regiController.rxStatusBuilding.value == Status.ERROR) {
                                     return Center(child: Text('Failed to load  Building Name'));
                                   }
                                   else if (regiController.rxStatusBuilding.value == Status.IDLE) {
                                     return Center(child: Padding(
                                       padding: const EdgeInsets.all(12.0),
                                       child: Text('Select Building Name'),
                                     ));
                                   }

                                   else if (regiController.checkPinCodeList.isEmpty) {
                                     return Center(child: Text('No  Building name available'));
                                   } else {
                                     return Expanded(
                                       child: DropdownButton<String>(
                                         padding: EdgeInsets.symmetric(horizontal: 20),
                                         isExpanded: true,
                                         underline: Container(),
                                         hint: Text('Select Building Name',style: TextStyle(
                                             fontWeight: FontWeight.bold
                                         ),), // Hint to show when nothing is selected
                                         value: regiController.selectBuilding.value.isEmpty
                                             ? null
                                             : regiController.selectBuilding.value,

                                         items: regiController.checkPinCodeList.map((Building marital) {
                                           return DropdownMenuItem<String>(
                                             value: marital.id.toString(), // Use unique ID or any unique property.
                                             child: Text(marital.buildingName ?? 'Unknown'), // Display name from DataX.
                                           );
                                         }).toList(), // Convert to List.
                                         onChanged: (String? newValue) {
                                           if (newValue != null) {
                                             regiController.selectBuilding(newValue);
                                             if(newValue=='other')
                                               {
                                                 regiController.isBuilding.value=true;
                                               }
                                             else
                                               {
                                                 regiController.isBuilding.value=false;
                                               }


                                           }
                                         },
                                       ),
                                     );
                                   }
                                 }),);
                               }),
                                Obx((){
                                  return Visibility(
                                    visible: regiController.isBuilding.value,
                                    child: Expanded(
                                    child: TextFormField(
                                      controller: regiController.buildingController.value,
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Enter Building';
                                        }

                                        else {
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(

                                        hintText: 'Building Name',
                                        border: InputBorder.none, // Remove the internal border
                                        contentPadding: EdgeInsets.symmetric(vertical: 8,horizontal: 22), // Adjust padding
                                      ),
                                    ),
                                  ),);
                                })

                              ],
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
                                    child: Image.asset(Images.house, // Replace with your flag asset
                                      height: 29, // Adjust height as needed
                                      width: 29,
                                      fit: BoxFit.cover,
                                      color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                    ),
                                  ),
                                  Expanded(
                                    child: Obx((){
                                      return TextFormField(
                                        keyboardType: TextInputType.text,
                                        controller: regiController.housenoController.value,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Enter House No/Flat';
                                          }
                                          else {
                                            return null;
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Flat / House No',
                                          border: InputBorder.none, // Remove the internal border
                                          contentPadding: EdgeInsets.symmetric(vertical: 8,horizontal: 20), // Adjust padding
                                        ),
                                      );
                                    }),
                                  ),
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
                                    child: Image.asset(Images.area, // Replace with your flag asset
                                      height: 29, // Adjust height as needed
                                      width: 29,
                                      fit: BoxFit.cover,
                                      color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                    ),
                                  ),
                                  Expanded(
                                    child: Obx((){
                                      return TextFormField(
                                        readOnly: true,
                                        keyboardType: TextInputType.text,
                                        controller: regiController.areaController.value,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Enter Area Name';
                                          }
                                          else {
                                            return null;
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Area',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(vertical: 8,horizontal: 20), // Adjust padding
                                        ),
                                      );
                                    }),
                                  ),
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
                                    child: Image.asset(Images.city, // Replace with your flag asset
                                      height: 29, // Adjust height as needed
                                      width: 29,
                                      fit: BoxFit.cover,
                                      color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                    ),
                                  ),
                                  Expanded(
                                    child: Obx((){
                                      return TextFormField(
                                        readOnly: true,
                                        keyboardType: TextInputType.text,
                                        controller: regiController.cityController.value,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Enter City Name';
                                          }
                                          else {
                                            return null;
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'City',
                                          border: InputBorder.none, // Remove the internal border
                                          contentPadding: EdgeInsets.symmetric(vertical: 8,horizontal: 20), // Adjust padding
                                        ),
                                      );
                                    }),
                                  ),
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
                                    child: Image.asset(Images.zone, // Replace with your flag asset
                                      height: 29, // Adjust height as needed
                                      width: 29,
                                      fit: BoxFit.cover,
                                      color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                    ),
                                  ),
                                  Expanded(
                                    child: Obx((){
                                      return  TextFormField(
                                        readOnly: true,
                                        keyboardType: TextInputType.text,
                                        controller: regiController.zoneController.value,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Enter Region';
                                          }
                                          else {
                                            return null;
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Region',
                                          border: InputBorder.none, // Remove the internal border
                                          contentPadding: EdgeInsets.symmetric(vertical: 8,horizontal: 20), // Adjust padding
                                        ),
                                      );
                                    }),
                                  ),
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
                                    child: Image.asset(Images.state, // Replace with your flag asset
                                      height: 29, // Adjust height as needed
                                      width: 29,
                                      fit: BoxFit.cover,
                                      color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                    ),
                                  ),

                                  Expanded(
                                    child: TextFormField(
                                      readOnly: true,
                                      keyboardType: TextInputType.text,
                                      controller: regiController.stateController.value ,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Enter State Name';
                                        }
                                        else {
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'State',
                                        border: InputBorder.none, // Remove the internal border
                                        contentPadding: EdgeInsets.symmetric(vertical: 8,horizontal: 20), // Adjust padding
                                      ),
                                    ),
                                  ),
                                ],
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
                                  child: Image.asset(Images.docs, // Replace with your flag asset
                                    height: 29, // Adjust height as needed
                                    width: 29,
                                    fit: BoxFit.cover,
                                    color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                  ),
                                ),
                                Obx(() {
                                  if (regiController.rxStatusDocument.value == Status.LOADING) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                      child: Container(
                                          alignment: Alignment.centerRight,
                                          height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                    );
                                  } else if (regiController.rxStatusDocument.value == Status.ERROR) {
                                    return Center(child: Text(' No Data'));
                                  } else if (regiController.documntTypeList.isEmpty) {
                                    return Center(child: Text('No  Document Type available'));
                                  } else {
                                    return Expanded(
                                      child: DropdownButton<String>(
                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                        isExpanded: true,
                                        underline: Container(),
                                        hint: Text('Select Document Type',style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        ),), // Hint to show when nothing is selected
                                        value: regiController.selectDocumentType.value.isEmpty
                                            ? null
                                            : regiController.selectDocumentType.value,

                                        items: regiController.documntTypeList.map((DocumentTypeData marital) {
                                          return DropdownMenuItem<String>(
                                            value: marital.name.toString(), // Use unique ID or any unique property.
                                            child: Text(marital.name ?? 'Unknown'), // Display name from DataX.
                                          );
                                        }).toList(), // Convert to List.
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            regiController.selectDocumentType(newValue);


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
                          GestureDetector(
                            onTap: () {
                              _showPicker(context: context);
                            },
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              margin: EdgeInsets.only(left: 5,right: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: _image != null
                                  ? Image.file(_image!, width: 200, height: 200, fit: BoxFit.cover)
                                  : Center(child: Icon(Icons.camera_alt_outlined)),
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
                                  child: Image.asset(Images.docs, // Replace with your flag asset
                                    height: 29, // Adjust height as needed
                                    width: 29,
                                    fit: BoxFit.cover,
                                    color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                  ),
                                ),
                                Obx(() {
                                  if (regiController.rxStatusMemberShipTYpe.value == Status.LOADING) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                      child: Container(
                                          alignment: Alignment.centerRight,
                                          height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                    );
                                  } else if (regiController.rxStatusMemberShipTYpe.value == Status.ERROR) {
                                    return Center(child: Text(' No Data'));
                                  } else if (regiController.memberShipList.isEmpty) {
                                    return Center(child: Text('No  membership Type available'));
                                  } else {
                                    return Expanded(
                                      child: DropdownButton<String>(
                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                        isExpanded: true,
                                        underline: Container(),
                                        hint: Text('Select MemberShip Type',style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        ),), // Hint to show when nothing is selected
                                        value: regiController.selectMemberShipType.value.isEmpty
                                            ? null
                                            : regiController.selectMemberShipType.value,

                                        items: regiController.memberShipList.map((MemberShipData marital) {
                                          return DropdownMenuItem<String>(
                                            value: marital.id.toString(), // Use unique ID or any unique property.
                                            child: Text(""+marital.membershipName.toString()+"- "+"Rs "+ marital.price.toString()), // Display name from DataX.
                                          );
                                        }).toList(), // Convert to List.
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            regiController.selectMemberShipType(newValue);
                                          }
                                        },
                                      ),
                                    );
                                  }
                                }),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Obx(() => Checkbox(
                                  value: regiController.isChecked.value,
                                  onChanged: regiController.toggleCheckbox,
                                )),
                                Text(
                                  'Accept Terms and Condition ',
                                  style: TextStyleClass.pink16style,
                                ),
                              ],
                            ),
                          ),






                          SizedBox(height: 40),


                        ],
                      )),
                    ),
                  )
              )



            ],
          ),
        ),




      ),
    );
  }

  Future<void> getImage(ImageSource img,) async {
    if (ImagePicker().supportsImageSource(img) == true) {
      try {
     final  XFile? pickedFile = await ImagePicker().pickImage(
          source: img,
     );
      setState(() {
           _image = File(pickedFile!.path);
         });
      regiController.userdocumentImage.value=pickedFile!.path.toString();
      } catch (e) {
        print("gggh" + e.toString());
      }
    }
  }
  Future<void> pickImageWithPermission() async {
    PermissionStatus cameraPermissionStatus = await Permission.camera.status;
    PermissionStatus storagePermissionStatus = await Permission.storage.status;

    if (cameraPermissionStatus.isGranted && storagePermissionStatus.isGranted) {
      // Permissions are already granted, proceed to pick file

    } else {
      Map<Permission, PermissionStatus> permissionStatuses = await [
        Permission.camera,
        Permission.storage,
      ].request();

      if (permissionStatuses[Permission.camera]!.isGranted &&
          permissionStatuses[Permission.storage]!.isGranted) {
        // Permissions granted, proceed to pick file
        getImage(ImageSource.camera);
      } else {

      }
    }
  }





  }
