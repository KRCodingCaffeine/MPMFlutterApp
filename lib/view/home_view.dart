import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';

import '../model/CheckUser/CheckUserData2.dart';
import '../utils/Session.dart';
import '../view_model/controller/updateprofile/UdateProfileController.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final regiController = Get.put(NewMemberController());
  UdateProfileController controller =Get.put(UdateProfileController());
  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  double screenWidth = 0.0;
  String? membershipApprovalStatus;

  final List<Map<String, dynamic>> gridItems = [
    {'icon': Images.user, 'label': 'My Profile'},
    {'icon': Images.makenewmember, 'label': 'Make New Member'},
    {'icon': Images.discount, 'label': 'Discounts & Offers'},
  ];

  final List<Map<String, dynamic>> bhawanItems = [
    {"imagePath": "assets/images/banner1.jpg"},
    {"imagePath": "assets/images/banner2.jpg"},
    {"imagePath": "assets/images/banner3.jpg"},
    {"imagePath": "assets/images/banner4.jpg"},
    {"imagePath": "assets/images/banner5.jpg"},
    {"imagePath": "assets/images/banner6.jpg"},
  ];

  @override
  void initState() {
    super.initState();
    controller.getUserProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenWidth = MediaQuery.of(context).size.width * 0.7;
      _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
        if (_scrollController.hasClients) {
          final double maxScroll = _scrollController.position.maxScrollExtent;
          final double currentScroll = _scrollController.offset;

          if (currentScroll >= maxScroll) {
            _scrollController.jumpTo(0);
          } else {
            _scrollController.animateTo(
              currentScroll + screenWidth,
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (int.tryParse(controller.membershipApprovalStatusId.value) != null &&
                int.parse(controller.membershipApprovalStatusId.value) < 6) {
              return _buildMembershipNotice();
            } else {
              return SizedBox.shrink(); // Return an empty widget when not needed
            }
          }),

          Obx((){
            return Visibility(
              visible: controller.showDashboardReviewFlag.value,
                child: _buildAdCard2("assets/images/banner1.jpg"));
          }),
          _buildGridView(),
          _buildAdvertisementTitle(),
          _buildAdvertisementList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMembershipNotice() {
    String message;
    switch (controller.membershipApprovalStatusId.value.trim()) {
      case '2':
        message = "Your membership is currently under review for Sangathan Samiti approval.";
        break;
      case '3':
        message = "Your membership currently under review for Vyaspathika Samiti approval.";
        break;
      case '4':
        message = "Your payment is pending.";
        break;
      case '5':
        message = "We received your payment and its under approval .";
        break;
      default:
        message = "Membership status unknown. Please check your account.";
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Color(0xFFe61428)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.black),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: GridView.builder(
          itemCount: gridItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = gridItems[index];
            return GestureDetector(
              onTap: () => _handleGridItemClick(item['label']),
              child: Card(
                color: Colors.white,
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      item['icon'],
                      height: 50.0,
                      width: 50.0,
                      allowDrawingOutsideViewBox: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['label'],
                      style: TextStyleClass.pink14style,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleGridItemClick(String label) {
    if (label == "Make New Member") {
      regiController.isRelation.value = false;
      Navigator.pushNamed(context, RouteNames.newMember);
    } else if (label == "My Profile") {
      regiController.isRelation.value = false;
      Navigator.pushNamed(context, RouteNames.profile);
    } else if (label == "Discounts & Offers") {
      Navigator.pushNamed(context, RouteNames.discount_offer_view);
    }
  }

  Widget _buildAdvertisementTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Text(
        "Advertisement",
        style: TextStyleClass.black12style.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAdvertisementList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: bhawanItems.length,
        itemBuilder: (context, index) {
          return _buildAdCard(bhawanItems[index]["imagePath"]);
        },
      ),
    );
  }

  Widget _buildAdCard2(String imagePath) {
    return GestureDetector(
      onTap: () async{
        Navigator.pushNamed(context, RouteNames.profile);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 150,
        margin:  EdgeInsets.only(right: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
          child: Text("Your Janaganana is pending. Please click here to complete Janganana."),),
        ),
      ),
    );
  }

  Widget _buildAdCard(String imagePath) {
    return Container(
      width: 300,
      height: 150,
      margin: const EdgeInsets.only(right: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(imagePath, fit: BoxFit.fill),
      ),
    );
  }
}
