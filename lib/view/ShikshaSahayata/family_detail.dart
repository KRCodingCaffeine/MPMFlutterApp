import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/model/GetProfile/FamilyHeadMemberData.dart';
import 'package:mpm/model/GetProfile/FamilyMembersData.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import '../../view_model/controller/dashboard/NewMemberController.dart';

class FamilyDetail extends StatefulWidget {
  const FamilyDetail({Key? key}) : super(key: key);

  @override
  State<FamilyDetail> createState() => _FamilyDetailState();
}

class _FamilyDetailState extends State<FamilyDetail> {
  String? currentMemberId;

  final UdateProfileController controller =
  Get.put(UdateProfileController());
  final NewMemberController regiController =
  Get.put(NewMemberController());

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  void _loadSessionData() async {
    CheckUserData2? userData = await SessionManager.getSession();
    setState(() {
      currentMemberId = userData?.memberId?.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text(
          "Family Info",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final List<dynamic> unifiedList = [];

          if (controller.familyHeadData.value != null) {
            unifiedList.add(controller.familyHeadData.value);
          }

          unifiedList.addAll(
            controller.familyDataList.value.where(
                  (m) =>
              m.memberId !=
                  controller.familyHeadData.value?.memberId,
            ),
          );

          if (unifiedList.isEmpty) {
            return const Center(
              child: Text(
                "No family members found",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: unifiedList.length,
            itemBuilder: (context, index) {
              final item = unifiedList[index];

              if (item is FamilyHeadMemberData) {
                return _buildUnifiedFamilyCard(
                  name:
                  "${item.firstName ?? ''} ${item.lastName ?? ''}".trim(),
                  memberCode: item.memberCode ?? item.memberId ?? '',
                  profileImage: item.profileImage,
                  isHead: true,
                );
              }

              if (item is FamilyMembersData) {
                return _buildUnifiedFamilyCard(
                  name:
                  "${item.firstName ?? ''} ${item.lastName ?? ''}".trim(),
                  memberCode: item.memberCode ?? item.memberId ?? '',
                  profileImage: item.profileImage,
                  isHead: false,
                );
              }

              return const SizedBox.shrink();
            },
          );
        }),
      ),
    );
  }

  // ===================== UNIFIED FAMILY CARD =====================

  Widget _buildUnifiedFamilyCard({
    required String name,
    required String memberCode,
    String? profileImage,
    required bool isHead,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.grey[50],
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage:
          profileImage != null && profileImage.isNotEmpty
              ? NetworkImage(Urls.imagePathUrl + profileImage)
              : const AssetImage("assets/images/user3.png")
          as ImageProvider,
          backgroundColor: Colors.grey[300],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "Member Code: $memberCode",
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}
