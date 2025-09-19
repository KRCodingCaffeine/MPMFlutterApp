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
  final TextEditingController _mobileOtpController = TextEditingController();
  final TextEditingController _emailOtpController = TextEditingController();

  LoginController controller = Get.put(LoginController());
  final RegOtpRepository _regOtpRepository = RegOtpRepository();

  bool _isLoading = false;
  String _memberId = "";
  String _mobile = "";
  String _email = "";

  void verifyOtp(BuildContext context) async {
    String mobileOtp = _mobileOtpController.text.trim();
    String emailOtp = _emailOtpController.text.trim();

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
        const SnackBar(
          content: Text('Enter Mobile OTP (4 digits) and Email OTP (4 digits)'),
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

  Widget _buildSingleOtpField({
    required TextEditingController controller,
    required String hintText,
    bool isEmail = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: isEmail ? 4 : 4,
      decoration: InputDecoration(
        counterText: "",
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1.5,
          ),
        ),
      ),
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
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                _buildSingleOtpField(
                  controller: _mobileOtpController,
                  hintText: "Enter Mobile OTP",
                ),
                const SizedBox(height: 25),

                Text(
                  "Enter Email OTP ($_email)",
                  style: TextStyleClass.black14style,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                _buildSingleOtpField(
                  controller: _emailOtpController,
                  hintText: "Enter Email OTP",
                  isEmail: true,
                ),
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
                          ? const SizedBox(
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
