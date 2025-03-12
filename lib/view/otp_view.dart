import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mpm/utils/app_constants.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/login/logincontroller.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({Key? key}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  LoginController controller = Get.put(LoginController());
  // Function to get OTP from all controllers
  String getOtpFromControllers() {
    String otp = '';
    for (var controller in _controllers) {
      otp += controller.text;
    }
    return otp;
  }

  void verifyOtp(BuildContext context) {
    controller.validotp.value = getOtpFromControllers();
    print("dfdd" + controller.validotp.value.toString());
    if (controller.validotp.value.length == 4) {
      print('OTP is valid');

      controller.checkOtp(controller.validotp.value, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter 4 digit Otp'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LoginController>().sendOtp(controller.mobilecon.value);
    });
  }

  @override
  void dispose() {
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    for (var controllers in _controllers) {
      controllers.dispose();
    }
    controller.mobilecon.value = "";
    controller.otp.value = "";

    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to the next field
      if (index < _focusNodes.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // If it's the last field, remove focus
        _focusNodes[index].unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? rcvdData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    controller.memberId.value = rcvdData!['memeberId'].toString();
    controller.dontSaveDataNewMeb.value =
        rcvdData!['page_type_direct'].toString();
    controller.mobilecon.value = rcvdData!['mobile'].toString();
    print("mem" + controller.memberId.value);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 190),
                Image.asset(Images.logoImage,
                    height: 240), // Replace with your image
                const SizedBox(height: 20),
                Text(
                  AppConstants.enter_otp,
                  style: TextStyleClass.black20style,
                ),

                Obx(() {
                  return Text(
                    "" +
                        AppConstants.detail_otp +
                        " " +
                        controller.mobilecon.value.toString(),
                    style: TextStyleClass.black14style,
                    textAlign: TextAlign.center,
                  );
                }),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: Colors.grey), // Black border
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                        ),
                        child: TextField(
                          controller:
                              _controllers[0], // Use the first controller
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          decoration: const InputDecoration(
                            hintText: 'Enter OTP',
                            border: InputBorder.none, // Remove default border
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            counterText: '',
                          ),
                          onChanged: (value) => _onChanged(value, 0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // SizedBox(
                //   width: double.infinity,
                //   child: Padding(
                //     padding: const EdgeInsets.only(left: 6.0,right: 6),
                //     child: ElevatedButton(
                //       onPressed:(){ verifyOtp(context);},
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
                //         padding: EdgeInsets.symmetric(vertical: 12),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(12),
                //
                //         ),
                //       ),
                //       child: Text(AppConstants.continues,
                //           style: TextStyleClass.white16style
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Obx(() {
                      return ElevatedButton(
                        onPressed: controller.loadinng.value
                            ? null // Disable button while loading
                            : () => verifyOtp(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.loadinng.value
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: ColorHelperClass.getColorFromHex(
                                      ColorResources.red_color),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppConstants.continues,
                                style: TextStyleClass.white16style,
                              ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  return GestureDetector(
                    onTap: controller.isButtonEnabled.value
                        ? controller.resendOtp
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.isButtonEnabled.value
                              ? AppConstants.dontreceive
                              : "Resend OTP",
                          style: TextStyleClass.black14style,
                        ),
                        Text(
                          AppConstants.resentotp,
                          style: TextStyleClass.red12style,
                        ),
                      ],
                    ),
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
