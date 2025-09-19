import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/data/response/status.dart';

import 'package:mpm/model/search/SearchData.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/app_constants.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/register/register_view_model.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final regiController = Get.put(RegisterController());
  int activeStep = 0;
  int activeStep2 = 0;
  int reachedStep = 0;
  int upperBound = 5;
  double progress = 0.2;

  TextEditingController lmCodeCOntroller = TextEditingController();
  TextEditingController otpCOntroller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    regiController.getGender();
    regiController.getMaritalStatus();
    regiController.getBloodGroup();
    regiController.getDocumentType();
    regiController.getMemberShip();
    regiController.getMemberSalutation();
    regiController.getCountry();
    regiController.getState();
    regiController.getCity();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        bottomNavigationBar: Container(
          margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          height: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button
                SizedBox(
                  width: 130,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Back to Login',
                        style: TextStyleClass.white16style),
                  ),
                ),

                // Continue button with Obx
                Obx(() {
                  return SizedBox(
                    width: 130,
                    child: ElevatedButton(
                      onPressed: regiController.isButtonEnabled.value
                          ? () {
                        Navigator.pushNamed(
                            context!, RouteNames.personalinfo);
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(
                            ColorResources.red_color),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(AppConstants.continues,
                          style: TextStyleClass.white16style),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.zero,
                  child: Align(
                    alignment: Alignment
                        .topCenter,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit
                          .cover,
                    ),
                  ),
                ),
                Text(AppConstants.welcome_mpm,
                    style: TextStyleClass.black20style),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  'New Membership',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.only(left: 5, top: 20),
                        child: Align(
                          alignment: Alignment
                              .centerLeft,
                          child: Text(
                            'Proposer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      //LM Code
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: lmCodeCOntroller,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    hintText: 'Name / LM Code *',
                                    border: InputBorder
                                        .none,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    print("lm" +
                                        lmCodeCOntroller.text.toString());
                                    if (lmCodeCOntroller.text.toString() !=
                                        "") {
                                      regiController.checkLMcode(
                                          lmCodeCOntroller.text.toString());
                                    } else {
                                      Get.snackbar(
                                        'Error',
                                        "Enter lm code Or Name",
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor:
                                        ColorHelperClass.getColorFromHex(
                                            ColorResources.red_color),
                                         colorText: Colors.white,
                                         duration: const Duration(seconds: 3),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    ColorHelperClass.getColorFromHex(
                                        ColorResources.red_color),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      //Proposer
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
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
                                    child: DropdownButton<SearchData>(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      isExpanded: true,
                                      underline: Container(),
                                      hint: Text('Select Mamber',style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      ),),
                                      value:  regiController.memberList.contains(regiController.selectMember.value)
                                          ? regiController.selectMember.value
                                          : null,
                                      items: regiController.memberList.map((SearchData marital) {
                                        return DropdownMenuItem<SearchData>(
                                          value: marital,
                                          child: Text(""+marital.memberCode.toString()+"-"+marital.firstName.toString()),
                                        );
                                      }).toList(),
                                      onChanged: (SearchData? newValue) {
                                        if (newValue != null) {
                                          print("ghgbh"+newValue.mobile.toString());
                                          regiController.selectMember(newValue);

                                          regiController.lmCodeValue.value=newValue.memberCode.toString();
                                          print("ghgbh"+regiController.lmCodeValue.value.toString());

                                          regiController.sendOtp(newValue.mobile.toString(),);

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
                      const SizedBox(height: 20),

                      // OTP Validation
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: otpCOntroller,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    hintText: AppConstants.enterotppro,
                                    border: InputBorder
                                        .none,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if(otpCOntroller.text.toString()!=null && otpCOntroller.text.toString().trim().length==4)
                                    {
                                      var otps=otpCOntroller.text.toString();
                                      regiController.checkOtp(otps, context);
                                    }
                                    else
                                    {
                                      Get.snackbar(
                                        'Error',
                                        "Enter OTP Or 4 digit OTP",
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                                        colorText: Colors.white,
                                        duration: Duration(seconds: 3),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    ColorHelperClass.getColorFromHex(
                                        ColorResources.red_color),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: Text(AppConstants.validate,
                                      style: TextStyleClass.white14style),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
