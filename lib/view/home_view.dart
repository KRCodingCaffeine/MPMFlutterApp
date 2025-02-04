import 'dart:async'; // Import the timer
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

  // ScrollController to manage horizontal scroll
  final ScrollController _scrollController = ScrollController();
  late Timer _timer; // Timer to trigger automatic scroll
  late double screenWidth;

  final List<Map<String, dynamic>> gridItems = [
    {'icon': Images.user, 'label': 'Make New Member'},
    {'icon': Images.discount, 'label': 'Discounts'},
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

    // Using addPostFrameCallback to defer accessing MediaQuery until after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access the context after the frame has been rendered
      double screenWidth = MediaQuery.of(context).size.width * 0.8;

      // Start automatic scrolling with smooth animation
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if (_scrollController.hasClients) {
          final double maxScroll = _scrollController.position.maxScrollExtent;
          final double currentScroll = _scrollController.offset;

          // If we've reached the end of the list, reset to the beginning
          if (currentScroll == maxScroll) {
            _scrollController.jumpTo(0); // Reset to the beginning of the list
          } else {
            _scrollController.animateTo(
              currentScroll +
                  screenWidth, // Scroll by screenWidth (80% of screen)
              duration: const Duration(
                  milliseconds: 1500), // Longer duration for smoother scroll
              curve: Curves.easeInOut, // Smoother curve for the scroll
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    _scrollController.dispose(); // Dispose the scroll controller
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
          // Membership Review Notice
          Container(
            margin: const EdgeInsets.all(16.0),
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
                  onTap: () {
                    // Handle close action
                  },
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Spacing between Membership Notice and GridView
          const SizedBox(height: 16),

          // Grid View (Takes available space)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gridItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 10, // Space between columns
                  mainAxisSpacing: 10, // Space between rows
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final item = gridItems[index];
                  return GestureDetector(
                    onTap: () {
                      if (item['label'] == "Family Member") {
                        regiController.isRelation.value = true;
                        Navigator.pushNamed(context, RouteNames.newMember);
                      } else if (item['label'] == "Make New Member") {
                        regiController.isRelation.value = false;
                        Navigator.pushNamed(context, RouteNames.newMember);
                      }
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
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

          // Spacer pushes the next widgets to the bottom
          const Spacer(),

          // Maheswari Bhavans Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Maheswari Bhavans",
                style: TextStyleClass.black12style.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Horizontal ListView (Fixed at bottom)
          SizedBox(
            height: 180, // Adjust height as needed
            child: ListView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              children: bhawanItems.map((item) {
                return _buildBhawanCard(item["title"], item["imagePath"]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build a Bhawan Card
  Widget _buildBhawanCard(String title, String imagePath) {
    return Container(
      width: screenWidth, // Fixed width for each card
      margin: const EdgeInsets.only(right: 16.0), // Adds spacing between cards
      child: Card(
        color: Colors.white,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text Column (Left Side)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyleClass.black12style.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.info, color: Colors.black), // Optional: Set icon color to black
                      label: const Text(
                        "Know More",
                        style: TextStyle(color: Colors.black), // Set text color to black
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100], // Light grey background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        foregroundColor: Colors.black, // Ensures text & icon color is black
                      ),
                    ),
                  ],
                ),
              ),

              // Square Image (Right Side)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(8.0), // Rounded corners for image
                child: Image.asset(
                  imagePath, // Dynamic image path
                  width: 100, // Fixed width
                  height: 100, // Fixed height
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
