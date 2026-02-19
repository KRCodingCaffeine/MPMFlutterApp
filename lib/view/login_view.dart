import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mpm/repository/forgot_member_login_repository/forgot_member_login_repo.dart';
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
                                hintText: 'Enter Your Mobile / Membership Code',
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter Membership code / Mobile number';
                                } else if (RegExp(r'^[0-9]+$')
                                    .hasMatch(value)) {
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
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 8),
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
                      const SizedBox(height: 8),

                      // "Forgot Mobile or Membership?" Button
                      Obx(() => Visibility(
                            visible: controller.showForgotButton.value,
                            child: TextButton(
                              onPressed: () {
                                _showForgotBottomSheet(context);
                              },
                              child: const Text(
                                "Forgot Mobile or Membership?",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          )),
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

  void _showForgotBottomSheet(BuildContext context) {
    final firstNameController = TextEditingController();
    final middleNameController = TextEditingController();
    final surnameController = TextEditingController();
    final mobileController = TextEditingController();
    final emailController = TextEditingController();
    final messageController = TextEditingController();

    final forgotRepo = ForgotMemberLoginRepository();

    bool isSubmitting = false;

    // Track touched fields individually
    bool firstTouched = false;
    bool surnameTouched = false;
    bool mobileTouched = false;
    bool emailTouched = false;
    bool messageTouched = false;

    String? firstError;
    String? surnameError;
    String? mobileError;
    String? emailError;
    String? messageError;

    // Individual validators
    void validateFirst() {
      firstError = firstNameController.text.trim().isEmpty
          ? "First name is required"
          : null;
    }

    void validateSurname() {
      surnameError =
          surnameController.text.trim().isEmpty ? "Surname is required" : null;
    }

    void validateMobile() {
      mobileError = mobileController.text.trim().length != 10
          ? "Mobile must be 10 digits"
          : null;
    }

    void validateEmail() {
      emailError =
          !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text.trim())
              ? "Enter valid email"
              : null;
    }

    void validateMessage() {
      messageError =
          messageController.text.trim().isEmpty ? "Message is required" : null;
    }

    bool isFormValid() {
      validateFirst();
      validateSurname();
      validateMobile();
      validateEmail();
      validateMessage();

      return firstError == null &&
          surnameError == null &&
          mobileError == null &&
          emailError == null &&
          messageError == null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        ElevatedButton(
                            onPressed: (!isFormValid() || isSubmitting)
                                ? null
                                : () async {
                                    setState(() {
                                      isSubmitting = true;
                                    });

                                    final fullName =
                                        "${firstNameController.text.trim()} "
                                                "${middleNameController.text.trim()} "
                                                "${surnameController.text.trim()}"
                                            .trim();

                                    try {
                                      final response = await forgotRepo
                                          .sendForgotMemberLoginRequest(
                                        fullName: fullName,
                                        mobile: mobileController.text.trim(),
                                        email: emailController.text.trim(),
                                        message: messageController.text.trim(),
                                      );

                                      Navigator.pop(context);

                                      if (response.status == true) {
                                        Get.snackbar(
                                          "Success",
                                          "Forgot login request submitted successfully.",
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                        );
                                      } else {
                                        Get.snackbar(
                                          "Failed",
                                          "Unable to submit request.",
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      }
                                    } catch (_) {
                                      Navigator.pop(context);
                                      Get.snackbar(
                                        "Error",
                                        "Something went wrong.",
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    } finally {
                                      setState(() {
                                        isSubmitting = false;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isSubmitting
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text("Submitting..."),
                                    ],
                                  )
                                : const Text("Submit")),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _forgotField(
                      "First Name *",
                      firstNameController,
                      errorText: firstTouched ? firstError : null,
                      onChanged: (_) {
                        firstTouched = true;
                        validateFirst();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    _forgotField(
                      "Middle Name",
                      middleNameController,
                    ),
                    const SizedBox(height: 12),
                    _forgotField(
                      "Surname *",
                      surnameController,
                      errorText: surnameTouched ? surnameError : null,
                      onChanged: (_) {
                        surnameTouched = true;
                        validateSurname();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    _forgotField(
                      "Mobile *",
                      mobileController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      errorText: mobileTouched ? mobileError : null,
                      onChanged: (_) {
                        mobileTouched = true;
                        validateMobile();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    _forgotField(
                      "Email *",
                      emailController,
                      keyboardType: TextInputType.emailAddress,
                      errorText: emailTouched ? emailError : null,
                      onChanged: (_) {
                        emailTouched = true;
                        validateEmail();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    _forgotField(
                      "Message *",
                      messageController,
                      maxLines: 3,
                      errorText: messageTouched ? messageError : null,
                      onChanged: (_) {
                        messageTouched = true;
                        validateMessage();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _forgotField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        labelStyle: const TextStyle(color: Colors.black),
        hintText: label,
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black38, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 20,
        ),
      ),
    );
  }
}
