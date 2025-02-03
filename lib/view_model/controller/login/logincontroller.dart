import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import 'package:mpm/model/CheckUser/CheckModelClass.dart';
import 'package:mpm/model/CheckUser/CheckUserData.dart';
import 'package:mpm/repository/login_respository.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/images.dart';
import 'dart:async';

import 'package:mpm/utils/urls.dart';
class LoginController {

  final api = LoginRepo();
  RxBool loadinng = false.obs;
  RxBool isLoading = false.obs;
  var isMobileValid = false.obs;
  var mobilecon = ''.obs;
  var LMCODEDYANMIC="".obs;
  var validotp = "".obs;
  var start = 60.obs;
  var isButtonEnabled = false.obs;
  late Timer _timer;
  var lmCodeVisible = false.obs;
  var lmDyanmicMobNo="".obs;
  var otherMobileNo="".obs;
  var otherMobVisible=false.obs;
  var flag="".obs;
  var isNumber=false.obs;

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
      //   print(await response.stream.bytesToString());

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
         var lmcode = registerResponse.data!.memberCode.toString();
         print("ghhhhhhhhhhh"+lmcode);
         var mob=registerResponse.data!.mobile.toString();
         if(lmcode==mobile)
           {
             flag.value="1";
           }
         else
           {
             flag.value="2";
             mobilecon.value = mobile;
           }

        // CheckUserData checkUserData = value['data'];
          if(flag.value=="2")
            {
              if(lmCodeVisible.value==false)
              {
                Navigator.pushNamed(context!, RouteNames.otp_screen);
              }
              else
              {
                lmDyanmicMobNo.value= registerResponse.data!.mobile.toString();
                mobilecon.value=registerResponse.data!.mobile.toString();
                _showLoginAlert2(context);
              }
            }
          else
            {  if(otherMobVisible.value==false)
              {
                lmDyanmicMobNo.value= registerResponse.data!.mobile.toString();
                mobilecon.value=registerResponse.data!.mobile.toString();
                _showLoginAlert2(context);
              }
            }


      }
    }
    else {
      loadinng.value = false;
      String responseBody = await response.stream.bytesToString();
      loadinng.value = false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      CheckModel registerResponse = CheckModel.fromJson(jsonResponse);
      if (registerResponse.status == false) {
        print("" + registerResponse.message.toString());
        if (registerResponse.message.toString() == "Sorry! Data Not Found") {
          mobilecon.value = mobile;
          if(lmCodeVisible.value==false)
            {

                  if(otherMobVisible.value==true)
                    {
                      Navigator.pushNamed(context!, RouteNames.otp_screen);
                    }
                  else
                    {
                      _showLoginAlert(context);
                    }

            }

          else if(otherMobVisible.value==true)
            {
              Navigator.pushNamed(context!, RouteNames.otp_screen);
            }
          else {
            lmCodeVisible.value=false;
            Navigator.pushNamed(context!, RouteNames.registration_screen);
          }
        }
      }

     // print(response.reasonPhrase);
    }
  }

  void startTimer() {
    isButtonEnabled.value = false; // Disable button initially
    start.value = 60; // Reset timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (start.value == 0) {
        isButtonEnabled.value = true;
        _timer.cancel();
      } else {
        start.value--; // Decrement the timer
      }
    });
  }

  // void validateMobileNumber(String mobile) {
  //   if (mobile.length == 10) {
  //     isMobileValid.value = true;
  //   } else {
  //     isMobileValid.value = false;
  //   }
  // }

  var otp = '5555'.obs;

  void generateRandomOTP({int length = 4}) {
    final Random random = Random();
    final StringBuffer otpBuffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      otpBuffer.write(random.nextInt(10)); // Generate a single digit (0-9)
    }
    otp.value = otpBuffer.toString();
    print("fgfggghg" + otp.value);
  }

  void sendOtp(var mobile, var otp) async {
    var url = "https://web.azinfomedia.com/domestic/sendsms/bulksms_v2.php?apikey=TWFoZXNod2FyaTp4em5ESlVPcA==&type=TEXT&sender=ASCTRL&entityId=xznDJUOp&templateId=1707170308164618962&mobile=${mobile}&message=Your%20One%20Time%20Password%20(OTP)%20is:%20${otp}%20Please%20use%20this%20OTP%20to%20complete%20your%20login.%20For%20Any%20Support%20Contact%20-%20Maheshwari%20Pragati%20Mandal%20ASCENT";
    try {
      var response = await http.get(Uri.parse(url));


      if (response.statusCode == 200) {
        // Parse the response if needed
        var data = json.decode(response.body);
        print('OTP Sent Successfully: $data');
      } else {
        print('Failed to send OTP. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      // Set loading state to false

    }
  }

  void checkOtp(var otps, BuildContext context) {
    if (otps == otp.value) {
      validuserlogin(mobilecon.value, context);
    }
    else {
      print("OTP not matched");
      Get.snackbar(
        'Error', // Title
        'OTP not matched', // Message
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.pink,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  void validuserlogin(var mobile, BuildContext context) async {
    loadinng.value = true;
    Map data = {
      "mobile": mobile
    };
    var request = http.MultipartRequest('POST', Uri.parse(Urls.check_url));
    request.fields.addAll({
      'LM_code_or_mobile': mobile
    });
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      //   print(await response.stream.bytesToString());

      String responseBody = await response.stream.bytesToString();
      loadinng.value = false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      CheckModel registerResponse = CheckModel.fromJson(jsonResponse);
      if (registerResponse.status == false) {
        print("" + registerResponse.message.toString());

        _showLoginAlert(context);
      } else {
        mobilecon.value = mobile;
        await SessionManager.saveSessionUserData(registerResponse.data!);
        await SessionManager.saveSessionToken(
            registerResponse.token.toString());

        api.userVerify(registerResponse.token.toString()).then((_value) async {
          print("Session saved successfully!");
          Navigator.pushReplacementNamed(context!, RouteNames.dashboard);
        }).onError((error, strack) async {
          print("Session saved successfully!");
          Navigator.pushReplacementNamed(context!, RouteNames.dashboard);
        });
      }
    }
    else {
      loadinng.value = false;

     if(otherMobVisible==true)
       { var mobiles= mobilecon.value;
       Navigator.pushReplacementNamed(context!, RouteNames.dashboard);
       }else
         {
           Get.snackbar(
             'Error', // Title
             "Something went wrong", // Message
             snackPosition: SnackPosition.BOTTOM,
             backgroundColor: Colors.pink,
             colorText: Colors.white,
             duration: Duration(seconds: 3),
           );
         }
      print(response.reasonPhrase);
    }
  }

  void resendOtp() {
    generateRandomOTP();
    print("OTP Resent!");
    startTimer();
    sendOtp(mobilecon.value, otp.value);
  }
  String maskMobileNumber(String mobileNumber) {
    if (mobileNumber.length == 10) {
      return 'xxxxxx${mobileNumber.substring(6)}';
    } else {
      return 'Invalid Number'; // Handle invalid input
    }
  }
  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Row(
            children: [
              Image.asset(Images.logoImage,
                height: 50,
                width: 50,
              ),
              SizedBox(width: 10),
              Text("Login"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are You a Member of a Maheshwari Pragati Mandal"),
              SizedBox(height: 10),


            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                Navigator.pushNamed(context, RouteNames.registration_screen);
              },
              child: Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                lmCodeVisible.value = true;
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }
  void _showLoginAlert2(BuildContext context) {
    print("fggh"+lmDyanmicMobNo.value.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String maskedNumber = maskMobileNumber(lmDyanmicMobNo.value);

        print("fggfghghjjkklj"+maskedNumber.toString());
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Row(
            children: [
              Image.asset(Images.logoImage,
                height: 50,
                width: 50,
              ),
              SizedBox(width: 10),
              Text("Login Verification"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [


              Text("Verify OTP for mobile $maskedNumber"),
              SizedBox(height: 10),


            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                otherMobVisible.value=true;
              },
              child: Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                Navigator.pushNamed(context, RouteNames.otp_screen);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}

