import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/samiti/SamitiController.dart';

import '../../utils/urls.dart';

class SamitiDetailPage extends StatefulWidget {
  SamitiDetailPage({super.key});

  @override
  _SamitiDetailPageState createState() => _SamitiDetailPageState();
}

class _SamitiDetailPageState extends State<SamitiDetailPage> {
  SamitiController controller = Get.put(SamitiController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.getSamitiTypeDeatils();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          controller.samitiName.value.toString(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            if (controller.loading2.value) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (controller.samitiDetailList.value == null ||
                controller.samitiDetailList.value.isEmpty) {
              return SafeArea(
                  child: Center(
                child: Text("No data found "),
              ));
            }
            return ListView.builder(
              itemCount: controller.samitiDetailList.value.length,
              itemBuilder: (context, index) {
                final member = controller.samitiDetailList.value[index];
                print("member samiti ${member.memberCode}");
                var firstname = "";
                var middlename = "";
                var lastname = "";
                var mobile = "";
                var memberCode = "";
                if (member.firstName.toString() == "null") {
                  firstname = "";
                } else {
                  firstname = member.firstName.toString();
                }
                if (member.middleName.toString() == "null") {
                  middlename = "";
                } else {
                  middlename = member.middleName.toString();
                }
                if (member.lastName.toString() == "null") {
                  lastname = "";
                } else {
                  lastname = member.lastName.toString();
                }
                if (member.mobile.toString() == "null") {
                  mobile = " ";
                } else {
                  mobile = member.mobile.toString();
                }
                var name = firstname + " " + lastname;

                if (member.memberCode.toString() == "null") {
                  memberCode = "";
                } else {
                  memberCode = member.memberCode.toString();
                }
                return _buildMemberCard(
                    samitiRoles: member.samitiRolesName.toString(),
                    lmCode: memberCode,
                    name: name,
                    mobile: mobile,
                    profileImage: member.profileImagePath,
                    memberId: member.memberId);
              },
            );
          })),
    );
  }

  /// **Reusable method to build a member card with profile image**
  Widget _buildMemberCard({
    required String samitiRoles,
    required String lmCode,
    required String name,
    required String mobile,
    required String profileImage,
    required String memberId,
  }) {
    return Center(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Profile Image with default fallback
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                // Background color while loading
                child: ClipOval(
                  child: (profileImage != null && profileImage.isNotEmpty)
                      ? FadeInImage(
                          placeholder:
                              const AssetImage("assets/images/user3.png"),
                          // Placeholder while loading
                          image: NetworkImage(Urls.imagePathUrl + profileImage),
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset("assets/images/male.png",
                                fit: BoxFit.cover);
                          },
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                        )
                      : Image.asset("assets/images/male.png",
                          fit: BoxFit.cover, width: 80, height: 80),
                ),
              ),
              const SizedBox(width: 16),
              // Information Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role Text (Super Admin)
                    Text(
                      "Role: ${samitiRoles ?? 'Unknown Role'}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Name and LM Code
                    Text(
                      name ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Member Code : ${lmCode.isNotEmpty ? lmCode : memberId}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFDC3545),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Mobile Number
                    Text(
                      "Mobile: ${mobile ?? 'No Mobile'}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
