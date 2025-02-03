import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CheckUser/CheckUserData.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/app_constants.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/register/register_view_model.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
final regiController= Get.put(RegisterController());
  int activeStep = 0;
  int activeStep2 = 0;
  int reachedStep = 0;
  int upperBound = 5;
  double progress = 0.2;

  TextEditingController lmCodeCOntroller=TextEditingController();
  TextEditingController otpCOntroller=TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    regiController.getGender();
    regiController.getMaritalStatus();
    regiController.getBloodGroup();
   regiController.getOccupationData();
   regiController.getQualification();
   regiController.getDocumentType();
   regiController.getMemberShip();

  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        bottomNavigationBar: Container(
          margin: EdgeInsets.only(bottom: 20,left: 20,right: 20),
          height: 50,
          child:  SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 6.0,right: 6),
              child:Obx((){
                return  ElevatedButton(
                  onPressed: regiController.isButtonEnabled.value?(){
                    Navigator.pushNamed(context!, RouteNames.personalinfo);
                  }:null,
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
                );
              }),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 50),
            child: Column(
              children: [
                SizedBox(height: 20,),
                Text(AppConstants.welcome_mpm,
                    style: TextStyleClass.black20style
                ),
                Container(

                  margin: EdgeInsets.zero
                  ,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: EasyStepper(
                      activeStep: activeStep2,
                      stepShape: StepShape.circle,
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
                      borderThickness: 1,
                      internalPadding: 0,
                      showLoadingAnimation: false,
                      steps: [
                        EasyStep(
                          icon: const Icon(CupertinoIcons.add),
                          title: 'Proposer',
                          lineText: '',


                        ),
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
                ),
                Container(
                  padding: EdgeInsets.only(left: 20,right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(height: 50),
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
                              // Space between the flag and text field
                              Expanded(
                                child: TextFormField(
                                  controller: lmCodeCOntroller,

                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    hintText: 'LM Code/ Name',
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
                                        print("lm"+lmCodeCOntroller.text.toString());
                                        if(lmCodeCOntroller.text.toString()!="") {
                                          regiController.checkLMcode(lmCodeCOntroller.text.toString());
                                        }
                                        else
                                          {
                                            Get.snackbar(
                                              'Error', // Title
                                              "Enter lm code Or Name", // Message
                                              snackPosition: SnackPosition.BOTTOM,
                                              backgroundColor: Colors.pink,
                                              colorText: Colors.white,
                                              duration: Duration(seconds: 3),
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
                      SizedBox(height: 16),
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
                                child: Image.asset(Images.user, // Replace with your flag asset
                                  height: 20, // Adjust height as needed
                                  width: 20,
                                  fit: BoxFit.cover,
                                  color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                ),
                              ),
                              Obx(() {
                                if (regiController.rxStatusMemberLoading.value == Status.LOADING) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 22),
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                        height:24,width:24,child: CircularProgressIndicator(color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),)),
                                  );
                                } else if (regiController.rxStatusMemberLoading.value == Status.ERROR) {
                                  return Center(child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Text('Select Member'),
                                  ));
                                }
                                else if (regiController.rxStatusMemberLoading.value == Status.IDLE) {
                                  return Center(child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Text('Select Member'),
                                  ));
                                }
                                else if (regiController.memberList.isEmpty) {
                                  return Center(child: Padding(
                                    padding: const EdgeInsets.all(14.0),

                                    child: Text('No member  available',style: TextStyleClass.black12style,),
                                  ));
                                } else {
                                  return Expanded(
                                    child: DropdownButton<CheckUserData>(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      isExpanded: true,
                                      underline: Container(),
                                      hint: Text('Select Mamber',style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      ),), // Hint to show when nothing is selected
                                      value:  regiController.memberList.contains(regiController.selectMember.value)
                                          ? regiController.selectMember.value
                                          : null,
                                      items: regiController.memberList.map((CheckUserData marital) {
                                        return DropdownMenuItem<CheckUserData>(
                                          value: marital,
                                          child: Text(""+marital.lMCode.toString()+"-"+marital.name.toString()),
                                        );
                                      }).toList(),
                                      onChanged: (CheckUserData? newValue) {
                                        if (newValue != null) {
                                          print("ghgbh"+newValue.mobile.toString());
                                          regiController.selectMember(newValue);
                                          regiController.generateRandomOTP();
                                          regiController.lmCodeValue.value=newValue.lMCode.toString();
                                          print("ghgbh"+regiController.lmCodeValue.value.toString());

                                         regiController.sendOtp(newValue.mobile.toString(), regiController.otp.value);

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
                      SizedBox(height: 16),

                      // OTP Validation
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
                                  height: 25, // Adjust height as needed
                                  width: 25,
                                  fit: BoxFit.cover,
                                  color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                ),
                              ),
                              // Space between the flag and text field
                              Expanded(
                                child: TextFormField(
                                  controller: otpCOntroller,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: AppConstants.enterotppro,
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
                                   if(otpCOntroller.text.toString()!=null && otpCOntroller.text.toString().trim().length==4)
                                     {
                                       var otps=otpCOntroller.text.toString();
                                       print("gfhghgjht"+otps+"gfhgfjhjjt"+regiController.otp.value);
                                       if(otps==regiController.otp.value)
                                       {
                                         regiController.isButtonEnabled.value=true;
                                         Get.snackbar(
                                           'Success', // Title
                                           'OTP matched', // Message
                                           snackPosition: SnackPosition.BOTTOM,
                                           backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                           colorText: Colors.white,
                                           duration: Duration(seconds: 3),
                                         );
                                       }
                                       else
                                       {
                                         regiController.isButtonEnabled.value=false;
                                         print("OTP not matched");
                                         Get.snackbar(
                                           'Error', // Title
                                           'OTP not matched', // Message
                                           snackPosition: SnackPosition.BOTTOM,
                                           backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                           colorText: Colors.white,
                                           duration: Duration(seconds: 3),
                                         );

                                       }
                                     }
                                   else
                                     {
                                       Get.snackbar(
                                         'Error', // Title
                                         "Enter OTP Or 4 digit OTP", // Message
                                         snackPosition: SnackPosition.BOTTOM,
                                         backgroundColor: Colors.pink,
                                         colorText: Colors.white,
                                         duration: Duration(seconds: 3),
                                       );
                                     }
                                   },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child:  Text(AppConstants.validate,
                                      style: TextStyleClass.white14style
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),



                    ],
                  ),
                ),
              ],
            ),
          ),
        ),),
    );
  }
}
