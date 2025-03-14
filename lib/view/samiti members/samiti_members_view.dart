import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

import 'package:mpm/view_model/controller/samiti/SamitiController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class SamitiMembersViewPage extends StatefulWidget {
  const SamitiMembersViewPage({super.key});

  @override
  State<SamitiMembersViewPage> createState() => _SamitiMembersViewPageState();
}

class _SamitiMembersViewPageState extends State<SamitiMembersViewPage> {
  SamitiController controller = Get.put(SamitiController());
  final UdateProfileController dashBoardController = Get.find();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getSamitiType();
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Obx(() {
          if (controller.loading.value) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color(0xFFe61428),
            ));
          }
          if (controller.getSamitidata.value == null) {
            return const Center(child: Text("No data available"));
          }
          return ListView(
            children: controller.getSamitidata.value!.entries.map((entry) {
              String title = entry.key;
              List<dynamic> items = entry.value;
              return _buildExpansionTile(title, items);
            }).toList(),
          );
        }));
  }

  /// **Reusable method for ExpansionTile**
  Widget _buildExpansionTile(String title, List<dynamic> items) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, color: Colors.black87),
      ),
      children: [
        items.isEmpty
            ? const Center(child: Text("No data"))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildCard(items[index]);
                },
              ),
      ],
    );
  }

  /// **Reusable method for creating a card with equal size and alignment**
  Widget _buildCard(Map<String, dynamic> item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: GestureDetector(
        onTap: () {
          controller.samitiId.value = item['samiti_sub_category_id'];
          controller.samitiName.value = item['samiti_sub_category_name'];
          Navigator.pushNamed(context, RouteNames.samitimemberdetails);
        },
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item['samiti_sub_category_name'],
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
