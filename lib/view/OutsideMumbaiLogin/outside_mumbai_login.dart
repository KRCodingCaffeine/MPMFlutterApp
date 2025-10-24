import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/app_constants.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/login/logincontroller.dart';

class OutsideMumbaiLoginPage extends StatefulWidget {
  @override
  State<OutsideMumbaiLoginPage> createState() => _OutsideMumbaiLoginPageState();
}

class _OutsideMumbaiLoginPageState extends State<OutsideMumbaiLoginPage> {
  final LoginController controller = Get.put(LoginController());
  final FocusNode _mobileFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _tooltipEntry;

  GlobalKey<FormState>? _formKeyLogin;
  TextEditingController? mobileController;
  TextEditingController? lmController;

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    mobileController = TextEditingController();
    lmController = TextEditingController();
  }

  @override
  void dispose() {
    _hideTooltip();
    _mobileFocusNode.dispose();
    mobileController!.dispose();
    lmController!.dispose();
    super.dispose();
  }

  void _showTooltip() {
    _hideTooltip();
    _tooltipEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 40,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, -80),
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter your Membership Code (e.g., LM000, SW1023) or Registered Mobile Number.',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_tooltipEntry!);
  }

  void _hideTooltip() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _hideTooltip();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKeyLogin,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      const SizedBox(height: 140),
                      Image.asset(Images.logoImage, height: 220, width: 260),
                      const SizedBox(height: 20),
                      Text(
                        "Outside Mumbai Member Login",
                        style: TextStyleClass.black20style,
                      ),
                      Text(
                        "Please enter your Membership Code or Mobile Number",
                        style: TextStyleClass.black14style,
                      ),
                      const SizedBox(height: 20),

                      // Membership Code / Mobile field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: CompositedTransformTarget(
                            link: _layerLink,
                            child: TextFormField(
                              focusNode: _mobileFocusNode,
                              controller: mobileController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                hintText: 'Enter Membership Code / Mobile Number',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your membership code or mobile number';
                                }
                                return null;
                              },
                              onTap: _showTooltip,
                              onFieldSubmitted: (_) => _hideTooltip(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      Obx(() => SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKeyLogin!.currentState!.validate()) {
                                controller.checkUser(
                                    mobileController!.text, context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorHelperClass.getColorFromHex(
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
                              "Continue",
                              style: TextStyleClass.white16style,
                            ),
                          ),
                        ),
                      )),

                      const SizedBox(height: 30),

                      // Back to main login
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Back to Mumbai Login",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
