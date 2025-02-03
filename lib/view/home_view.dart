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

  final regiController= Get.put(NewMemberController());
  final List<Map<String, dynamic>> gridItems = [
    {'icon': Images.networking, 'label': 'Networking'},
    {'icon':Images.vivah, 'label': 'Vivah'},
    {'icon': Images.bhavan, 'label': 'Bhavan'},
    {'icon': Images.discount, 'label': 'Discounts'},
    {'icon': Images.publication, 'label': 'Publications'},
    {'icon': Images.events, 'label': 'Events'},
    {'icon':Images.shiksha, 'label': 'Shiksha'},
    {'icon': Images.chikitsha, 'label': 'Chikitsha'},
    {'icon': Images.user, 'label': 'Family Member'},
    {'icon': Images.user, 'label': 'Add Member'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
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
          Expanded(
            child: GridView.count(
              crossAxisCount: 3, // Number of columns
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: EdgeInsets.all(16),
              children: List.generate(gridItems.length, (index) {
                final item = gridItems[index];
                return GestureDetector(
                  onTap: () async{
                    if(item['label']=="Family Member")
                      {

                        regiController.isRelation.value=true;
                        Navigator.pushNamed(context!, RouteNames.newMember);
                      }
                    else if(item['label']=="Add Member")
                      {
                        regiController.isRelation.value=false;
                        Navigator.pushNamed(context!, RouteNames.newMember);
                      }
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 8.0, // Adds shadow to the card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounds the corners
                    ),
                    child: Container(
                      height: 200,
                      width: 200,
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(item['icon'],
                            height: 50.0,
                            width: 50.0,
                            allowDrawingOutsideViewBox: true,
                          ),
                          SizedBox(height: 8),
                          Text(
                            item['label'],
                            style: TextStyleClass.pink14style,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ]));
  }
}
