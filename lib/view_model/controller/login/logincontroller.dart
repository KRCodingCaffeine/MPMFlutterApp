import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:mpm/model/CheckUser/CheckModelClass.dart';
import 'package:mpm/model/CheckUser/CheckUserData.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/repository/login_respository.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'dart:async';

import 'package:mpm/utils/urls.dart';
import 'package:mpm/utils/device_token_service.dart';

class LoginController {
  final api = LoginRepo();
  RxBool loadinng = false.obs;
  RxBool isLoading = false.obs;
  var isMobileValid = false.obs;
  var mobilecon = ''.obs;
  var emailcon = ''.obs;
  var LMCODEDYANMIC = "".obs;
  var validotp = "".obs;
  var isButtonEnabled = false.obs;
  late Timer _timer;
  var lmCodeVisible = false.obs;
  var lmDyanmicMobNo = "".obs;
  var otherMobileNo = "".obs;
  var otherMobVisible = false.obs;
  var flag = "".obs;
  var isNumber = false.obs;
  var memberId = "".obs;
  var dontSaveDataNewMeb = "".obs;
  BuildContext? context = Get.context;
  Rx<SessionManager?> sessionData = Rx<SessionManager?>(null);
  Rx<CheckUserData?> userData = Rx<CheckUserData?>(null);

  void checkUser(String mobile, BuildContext context) async {
    loadinng.value = true;

    var request = http.MultipartRequest('POST', Uri.parse(Urls.check_url));
    request.fields.addAll({
      'LM_code_or_mobile': mobile
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      loadinng.value = false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      CheckModel registerResponse = CheckModel.fromJson(jsonResponse);

      if (registerResponse.status == false) {
        print("" + registerResponse.message.toString());
        if (registerResponse.message.toString() == "Sorry! Data Not Found") {
          mobilecon.value = mobile;
          Navigator.pushNamed(context!, RouteNames.registration_screen);
        }
      } else {
        // ✅ ADD MEMBERSHIP APPROVAL STATUS CHECK
        if (registerResponse.data?.membershipApprovalStatusId != "6") {
          Get.snackbar(
            'Pending Approval',
            'Your membership is still pending approval. Please contact administrator.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );
          return;
        }

        var lmcode = registerResponse.data!.memberCode.toString();
        print("ghhhhhhhhhhh" + lmcode);
        var mob = registerResponse.data!.mobile.toString();

        if (lmcode == mobile) {
          flag.value = "1";
        } else {
          flag.value = "2";
          mobilecon.value = mob;
        }

        if (flag.value == "2") {
          if (lmCodeVisible.value == false) {
            memberId.value = registerResponse.data!.memberId.toString();
            mobile = registerResponse.data!.mobile.toString();
            Navigator.pushNamed(context!, RouteNames.otp_screen, arguments: {
              "memeberId": memberId.value,
              "page_type_direct": "2",
              "mobile": mobile
            });
          } else {
            lmDyanmicMobNo.value = registerResponse.data!.mobile.toString();
            mobilecon.value = registerResponse.data!.mobile.toString();
            memberId.value = registerResponse.data!.memberId.toString();
            _showLoginAlert2(context);
          }
        } else {
          if (otherMobVisible.value == false) {
            lmDyanmicMobNo.value = registerResponse.data!.mobile.toString();
            memberId.value = registerResponse.data!.memberId.toString();
            mobilecon.value = registerResponse.data!.mobile.toString();
            _showLoginAlert2(context);
          }
        }
      }
    } else {
      loadinng.value = false;
      String responseBody = await response.stream.bytesToString();

      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      CheckModel registerResponse = CheckModel.fromJson(jsonResponse);
      if (registerResponse.status == false) {
        print("" + registerResponse.message.toString());
        if (registerResponse.message.toString() == "Sorry! Data Not Found") {
          mobilecon.value = mobile;
          final numberRegExp = RegExp(r'^-?\d+(\.\d+)?$');

          print("fhgefhefh" + mobilecon.value);
          print("fhgefhefh" + lmCodeVisible.value.toString());
          if (lmCodeVisible.value == false) {
            if (otherMobVisible.value == true) {
              Navigator.pushNamed(context!, RouteNames.otp_screen, arguments: {
                "memeberId": memberId.value,
                "page_type_direct": "2",
                "mobile": mobilecon.value
              });
            } else {
              _showLoginAlert(context);
            }
          } else if (otherMobVisible.value == true) {
            Navigator.pushNamed(context!, RouteNames.otp_screen, arguments: {
              "memeberId": memberId.value,
              "page_type_direct": "2",
              "mobile": mobilecon.value
            });
          } else {
            lmCodeVisible.value = false;
            Navigator.pushNamed(context!, RouteNames.registration_screen);
          }
        }
      }
    }
  }

  void updatemobileno(String mobile) async {
    var request = http.MultipartRequest('POST', Uri.parse(Urls.updatemobileno));
    request.fields.addAll({
      'mobile_number': mobile,
      'member_id': memberId.value
    });
    print("ghhjhhj" + memberId.value);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      loadinng.value = false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      CheckModel registerResponse = CheckModel.fromJson(jsonResponse);
      if (registerResponse.status == false) {
        print("" + registerResponse.message.toString());
        if (registerResponse.message.toString() == "Sorry! Data Not Found") {
          mobilecon.value = mobile;
          Navigator.pushNamed(context!, RouteNames.registration_screen);
        }
      } else {
        Navigator.pushNamed(context!, RouteNames.otp_screen, arguments: {
          "memeberId": memberId.value,
          "page_type_direct": "2",
          "mobile": mobile
        });
      }
    }
  }

  var otp = '5555'.obs;

  void sendOtp(var mobile) async {
    print("mobi" + mobile);
    try {
      Map<String, String> map = {
        "mobile_number": mobile
      };
      api.sendOTP(map).then((_value) async {
        if (_value.status == true) {
          // OTP sent successfully
        } else {
          // Handle OTP send failure
        }
      }).onError((error, strack) async {
        Get.snackbar(
          'Error', // Title
          "Something went wrong", // Message
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      // Cleanup if needed
    }
  }

  Future<void> checkOtp(var otps, BuildContext context) async {
    loadinng.value = true;
    try {
      Map map = {
        "member_id": memberId.value,
        "otp": otps,
        "otp_validation_for": "login",
      };
      print("fffh" + map.toString());
      api.verifyOTP(map).then((_value) async {
        loadinng.value = false;
        if (_value.status == true) {
          // ✅ ADD MEMBERSHIP APPROVAL STATUS CHECK BEFORE LOGIN
          if (_value.data?.membershipApprovalStatusId != "6") {
            Get.snackbar(
              'Pending Approval',
              'Your membership is still pending approval. Please contact administrator.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
              colorText: Colors.white,
              duration: Duration(seconds: 4),
            );
            return;
          }

          if (dontSaveDataNewMeb.value == "2") {
            await SessionManager.saveSessionUserData(_value.data!);
            await SessionManager.saveSessionToken(_value.token.toString());

            api.userVerify(_value.token.toString()).then((_value) async {
              print("Session saved successfully!");
              Navigator.pushNamedAndRemoveUntil(
                context!,
                RouteNames.dashboard,
                    (Route<dynamic> route) => false,
              );
            }).onError((error, strack) async {
              print("Session saved successfully!");
              Navigator.pushNamedAndRemoveUntil(
                context!,
                RouteNames.dashboard,
                    (Route<dynamic> route) => false,
              );
            });
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context!,
              RouteNames.dashboard,
                  (Route<dynamic> route) => false,
            );
          }
        }
      }).onError((error, strack) async {
        loadinng.value = false;
        print("fvvf" + error.toString());
        if (error.toString().contains("Sorry! OTP doesn't match")) {
          Get.snackbar(
            'Error',
            "Sorry! OTP doesn't match",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        } else {
          Get.snackbar(
            'Error',
            "Something went wrong",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      });
    } catch (e) {
      loadinng.value = false;
      print('Error: $e');
    }
  }

  void updateToken() async {
    CheckUserData2? userData = await SessionManager.getSession();
    print('User ID: ${userData?.memberId}');
    print('User Name: ${userData?.mobile}');
    memberId.value = userData!.memberId.toString();

    try {
      // Use the new device token service
      await DeviceTokenService().forceUpdateToken();

      Get.snackbar(
        "Success",
        "Login Successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint('Error updating token: $e');
    }
  }

  void validuserlogin(var mobile, BuildContext context) async {
    loadinng.value = true;

    var request = http.MultipartRequest('POST', Uri.parse(Urls.check_url));
    request.fields.addAll({
      'LM_code_or_mobile': mobile
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      loadinng.value = false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      CheckModel registerResponse = CheckModel.fromJson(jsonResponse);
      if (registerResponse.status == false) {
        print("" + registerResponse.message.toString());
        _showLoginAlert(context);
      } else {
        if (registerResponse.data?.membershipApprovalStatusId != "6") {
          Get.snackbar(
            'Pending Approval',
            'Your membership is still pending status under samiti approval. Please contact administrator.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );
          return;
        }

        mobilecon.value = mobile;
        memberId.value = registerResponse.data!.memberId.toString();
        await SessionManager.saveSessionUserData(registerResponse.data!);
        await SessionManager.saveSessionToken(registerResponse.token.toString());

        api.userVerify(registerResponse.token.toString()).then((_value) async {
          print("Session saved successfully!");
          Navigator.pushNamedAndRemoveUntil(
            context!,
            RouteNames.dashboard,
                (Route<dynamic> route) => false,
          );
        }).onError((error, strack) async {
          print("Session saved successfully!");
          Navigator.pushNamedAndRemoveUntil(
            context!,
            RouteNames.dashboard,
                (Route<dynamic> route) => false,
          );
        });
      }
    } else {
      loadinng.value = false;
      if (otherMobVisible == true) {
        var mobiles = mobilecon.value;
        Navigator.pushNamedAndRemoveUntil(
          context!, RouteNames.dashboard, (Route<dynamic> route) => false,);
      } else {
        Get.snackbar(
          'Error',
          "Something went wrong",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
      print(response.reasonPhrase);
    }
  }

  void resendOtp() {
    sendOtp(mobilecon.value);
    print("OTP Resent!");
  }

  String maskMobileNumber(String mobileNumber) {
    if (mobileNumber.length == 10) {
      return 'xxxxxx${mobileNumber.substring(6)}';
    } else {
      return 'Invalid Number';
    }
  }

  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Login Verification",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),
          content: const Text(
            "Are you a member of Maheshwari Pragati Mandal?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, RouteNames.registration_screen);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                final numberRegExp = RegExp(r'^-?\d+(\.\d+)?$');

                if (numberRegExp.hasMatch(mobilecon.value.trim())) {
                  lmCodeVisible.value = true;
                  otherMobVisible.value = false;
                } else {
                  otherMobVisible.value = true;
                  lmCodeVisible.value = false;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _showLoginAlert2(BuildContext context) {
    print("Mobile: ${lmDyanmicMobNo.value}");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String maskedNumber = maskMobileNumber(lmDyanmicMobNo.value);
        print("Masked Mobile: $maskedNumber");

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter OTP sent on mobile $maskedNumber",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                otherMobVisible.value = true;
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Another Number"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(
                  context,
                  RouteNames.otp_screen,
                  arguments: {
                    "memeberId": memberId.value,
                    "page_type_direct": "2",
                    "mobile": lmDyanmicMobNo.value,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}