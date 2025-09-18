import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/repository/reg_otp_repository/reg_otp_repo.dart';
import 'package:mpm/utils/app_constants.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/login/logincontroller.dart';
import 'package:mpm/model/RegOtp/RegOtpModelClass.dart';

class RegOTPScreen extends StatefulWidget {
  const RegOTPScreen({Key? key}) : super(key: key);

  @override
  State<RegOTPScreen> createState() => _RegOTPScreenState();
}

class _RegOTPScreenState extends State<RegOTPScreen> {
  final List<FocusNode> _phoneFocusNodes =
  List.generate(4, (index) => FocusNode());
  final List<TextEditingController> _phoneControllers =
  List.generate(4, (index) => TextEditingController());

  final List<FocusNode> _emailFocusNodes =
  List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _emailControllers =
  List.generate(6, (index) => TextEditingController());

  LoginController controller = Get.put(LoginController());
  final RegOtpRepository _regOtpRepository = RegOtpRepository();
  bool _isLoading = false;
  String _memberId = "";
  String _mobile = "";
  String _email = "";

  /// Collect OTP from controllers
  String getOtpFromControllers(bool isEmailOtp) {
    String otp = '';
    final controllers = isEmailOtp ? _emailControllers : _phoneControllers;
    for (var controller in controllers) {
      otp += controller.text;
    }
    return otp;
  }

  /// Verify both Mobile & Email OTP
  void verifyOtp(BuildContext context) async {
    String mobileOtp = getOtpFromControllers(false);
    String emailOtp = getOtpFromControllers(true);

    if (mobileOtp.length == 4 && emailOtp.length == 4) {
      setState(() {
        _isLoading = true;
      });

      try {
        RegOtpModelClass response = await _regOtpRepository.checkRegOtp(
          mobileOtp: mobileOtp,
          memberId: _memberId,
          emailOtp: emailOtp,
        );

        setState(() {
          _isLoading = false;
        });

        if (response.status == true) {
          Get.snackbar(
            "Success",
            response.data?.message ?? "OTP verified successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          Get.snackbar(
            "Error",
            response.data?.message ?? "Invalid OTP",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        Get.snackbar(
          "Error",
          "Failed to verify OTP. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text('Enter both Mobile (4 digits) and Email (4 digits) OTP'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Dummy Resend OTP
  void resendOtp() async {
    try {
      Get.snackbar(
        "Success",
        "OTP resent successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to resend OTP. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    for (var focusNode in _phoneFocusNodes) {
      focusNode.dispose();
    }
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    for (var focusNode in _emailFocusNodes) {
      focusNode.dispose();
    }
    for (var controller in _emailControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index, bool isEmailOtp) {
    if (value.isNotEmpty) {
      final focusNodes = isEmailOtp ? _emailFocusNodes : _phoneFocusNodes;
      if (index < focusNodes.length - 1) {
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
      }
    }
  }

  /// Reusable OTP input field
  Widget _buildOtpInputField(bool isEmailOtp) {
    final itemCount = isEmailOtp ? 4 : 4;
    final focusNodes = isEmailOtp ? _emailFocusNodes : _phoneFocusNodes;
    final controllers = isEmailOtp ? _emailControllers : _phoneControllers;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(itemCount, (index) {
        return SizedBox(
          width: 55, // slightly wider for padding
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey), // Grey border
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none, // remove default border
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) => _onChanged(value, index, isEmailOtp),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? rcvdData =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (rcvdData != null) {
      _memberId = rcvdData['memeberId']?.toString() ?? "";
      _mobile = rcvdData['mobile']?.toString() ?? "";
      _email = rcvdData['email']?.toString() ?? "";
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Image.asset(Images.logoImage, height: 150),
                const SizedBox(height: 30),
                Text(
                  AppConstants.enter_otp,
                  style: TextStyleClass.black20style,
                ),
                const SizedBox(height: 25),

                Text(
                  "Enter Mobile OTP ($_mobile)",
                  style: TextStyleClass.black14style,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                _buildOtpInputField(false),
                const SizedBox(height: 25),

                Text(
                  "Enter Email OTP ($_email)",
                  style: TextStyleClass.black14style,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                _buildOtpInputField(true),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => verifyOtp(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(
                            ColorResources.red_color),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        AppConstants.continues,
                        style: TextStyleClass.white16style,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Resend OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppConstants.dontreceive,
                      style: TextStyleClass.black14style,
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: resendOtp,
                      child: Text(
                        AppConstants.resentotp,
                        style: TextStyleClass.red12style.copyWith(
                          color: ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
