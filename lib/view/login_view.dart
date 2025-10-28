import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/app_constants.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/login/logincontroller.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController controller = Get.put(LoginController());

  GlobalKey<FormState>? _formKeyLogin;
  TextEditingController? mobileController;
  TextEditingController? mobile6666Controller;
  TextEditingController? lmController;
  TextEditingController? otherMobileontroller;

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    mobileController = TextEditingController();
    lmController = TextEditingController();
    mobile6666Controller = TextEditingController();
    otherMobileontroller = TextEditingController();
    getToken();
  }

  @override
  void dispose() {
    mobileController!.dispose();
    lmController!.dispose();
    mobile6666Controller!.dispose();
    otherMobileontroller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKeyLogin,
                child: Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 190),
                      Image.asset(
                        Images.logoImage,
                        height: 240,
                        width: 300,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppConstants.enter_mobile,
                        style: TextStyleClass.black20style,
                      ),
                      Text(
                        AppConstants.logincon,
                        style: TextStyleClass.black14style,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppConstants.login_message,
                        style: TextStyleClass.black14style,
                      ),

                      // Static Info Message Box
                      // Container(
                      //   margin: const EdgeInsets.symmetric(horizontal: 20),
                      //   padding: const EdgeInsets.all(12),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(color: Colors.black26),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: Colors.black.withOpacity(0.05),
                      //         blurRadius: 6,
                      //         offset: const Offset(0, 3),
                      //       ),
                      //     ],
                      //   ),
                      //   child: Row(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Container(
                      //         decoration: BoxDecoration(
                      //           color: Colors.grey.shade100,
                      //           shape: BoxShape.circle,
                      //         ),
                      //         padding: const EdgeInsets.all(6),
                      //         child: const Icon(
                      //           Icons.info_outline,
                      //           color: Colors.redAccent,
                      //           size: 18,
                      //         ),
                      //       ),
                      //       const SizedBox(width: 12),
                      //       const Expanded(
                      //         child: Text(
                      //           'Enter your Membership Code — must begin with LM, NM, SW etc., followed by numbers (e.g., LM000, SW1023).',
                      //           style: TextStyle(
                      //             color: Colors.black,
                      //             fontSize: 12,
                      //             fontWeight: FontWeight.w500,
                      //             height: 1.3,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(height: 20),

                      // Mobile Number Field
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6.0, right: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: TextFormField(
                              controller: mobileController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                hintText:
                                'Enter Your Mobile / Membership Code',
                                border: InputBorder.none,
                                contentPadding:
                                EdgeInsets.symmetric(vertical: 8),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter Membership code / Mobile number';
                                } else if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  controller.isNumber.value = true;
                                } else if (RegExp(r'^[a-zA-Z]+$')
                                    .hasMatch(value)) {
                                  controller.isNumber.value = false;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // LM Code Field (Visible conditionally)
                      Obx(() {
                        return Visibility(
                          visible: controller.lmCodeVisible.value,
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 6.0, right: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: TextFormField(
                                      controller: lmController,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter Membership Code',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8),
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Enter Membership code';
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      }),

                      // Other Mobile Number Field (Visible conditionally)
                      Obx(() {
                        return Visibility(
                          visible: controller.otherMobVisible.value,
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 6.0, right: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: TextFormField(
                                      controller: otherMobileontroller,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        hintText: 'Mobile Number',
                                        border: InputBorder.none,
                                        contentPadding:
                                        EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Enter mobile number';
                                        } else if (value.length != 10) {
                                          return "Enter 10 digit mobile number";
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      }),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6.0, right: 6),
                          child: Obx(
                                () => ElevatedButton(
                              onPressed: () async {
                                if (_formKeyLogin!.currentState!.validate()) {
                                  if (controller.lmCodeVisible.value == false) {
                                    if (controller.otherMobVisible.value ==
                                        true) {
                                      controller.checkUser(
                                          otherMobileontroller!.text, context);
                                    } else {
                                      controller.checkUser(
                                          mobileController!.text, context);
                                    }
                                  } else {
                                    if (controller.otherMobVisible.value ==
                                        false) {
                                      controller.checkUser(
                                          lmController!.text, context);
                                    } else {
                                      controller.checkUser(
                                          otherMobileontroller!.text, context);
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                ColorHelperClass.getColorFromHex(
                                    ColorResources.red_color),
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: controller.loadinng.value
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : Text(
                                AppConstants.continues,
                                style: TextStyleClass.white16style,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // OutSide Mumbai Login
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(horizontal: 6),
                      //     child: ElevatedButton(
                      //       onPressed: () {
                      //         Navigator.pushNamed(
                      //             context, RouteNames.outside_mumbai_login);
                      //       },
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: Colors.white,
                      //         side: BorderSide(
                      //           color: ColorHelperClass.getColorFromHex(
                      //               ColorResources.red_color),
                      //         ),
                      //         padding: const EdgeInsets.symmetric(vertical: 14),
                      //         shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(12),
                      //         ),
                      //       ),
                      //       child: Text(
                      //         "Out Side Mumbai Login",
                      //         style: TextStyle(
                      //           color: ColorHelperClass.getColorFromHex(
                      //               ColorResources.red_color),
                      //           fontSize: 14,
                      //           fontWeight: FontWeight.w600,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // Top Right "Register Here!" Button
            Positioned(
              top: 70,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.registration_screen);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorHelperClass.getColorFromHex(
                      ColorResources.red_color),
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Register Here!",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getToken() async {
    // final token = await FirebaseMessaging.instance.getToken();
    // await PushNotificationService().initialise();
    // if (token != null) {
    //   print('firebase device token >>>>> $token');
    //   // sharedPreference.saveDeviceToken(token);
    // }
  }
}
