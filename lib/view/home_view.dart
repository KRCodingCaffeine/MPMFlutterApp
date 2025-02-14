import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final regiController = Get.put(NewMemberController());

  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  late double screenWidth;

  final List<Map<String, dynamic>> gridItems = [
    {'icon': Images.user, 'label': 'My Profile'},
    {'icon': Images.makenewmember, 'label': 'Make New Member'},
    {'icon': Images.discount, 'label': 'Discounts & Offers'},
  ];

  final List<Map<String, dynamic>> bhawanItems = [
    {
      "title": "Girgaon Bhawan",
      "imagePath": "assets/images/girgaon_bhawan.png"
    },
    {
      "title": "Andheri Bhawan",
      "imagePath": "assets/images/girgaon_bhawan.png"
    },
    {
      "title": "Goregaon Bhawan",
      "imagePath": "assets/images/girgaon_bhawan.png"
    },
    {
      "title": "Borivali Bhawan",
      "imagePath": "assets/images/girgaon_bhawan.png"
    },
    {
      "title": "Ghatkopar Bhawan",
      "imagePath": "assets/images/girgaon_bhawan.png"
    },
  ];

  @override
  void initState() {
    super.initState();

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
          // Membership Notice
          Padding(
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
                  const Expanded(
                    child: Text(
                      "Your membership is currently under review for approval.",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Grid View
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GridView.builder(
                itemCount: gridItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2, // Better spacing for text
                ),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = gridItems[index];
                  return GestureDetector(
                    onTap: () {
                      if (item['label'] == "Make New Member") {
                        regiController.isRelation.value = false;
                        Navigator.pushNamed(context, RouteNames.newMember);
                      }
                      if (item['label'] == "My Profile") {
                        regiController.isRelation.value = false;
                        Navigator.pushNamed(context, RouteNames.profile);
                      }
                      if (item['label'] == "Discounts & Offers") {
                        Navigator.pushNamed(
                            context, RouteNames.discount_offer_view);
                      }
                    },
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
          ),

          // Maheswari Bhavans Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              "Maheswari Bhavans",
              style: TextStyleClass.black12style.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Horizontal ListView
          SizedBox(
            height: 160,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: bhawanItems.length,
              itemBuilder: (context, index) {
                final item = bhawanItems[index];
                return _buildBhawanCard(item["title"], item["imagePath"]);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Bhawan Card
  Widget _buildBhawanCard(String title, String imagePath) {
    return Container(
      width: screenWidth,
      margin: const EdgeInsets.only(right: 16.0),
      child: Card(
        color: Colors.white,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              // Left: Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyleClass.black12style.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.info, color: Colors.black),
                      label: const Text("Know More",
                          style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
