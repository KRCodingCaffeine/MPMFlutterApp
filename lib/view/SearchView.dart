import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/dashboard/dashboardcontroller.dart';
import 'package:mpm/view_model/controller/samiti/SamitiController.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  SamitiController controller= Get.put(SamitiController());
  final TextEditingController _searchController = TextEditingController();
  final DashBoardController dashBoardController = Get.find();
  final String defaultProfile = "assets/images/user3.png";
  void _filterMembers(String query) {
    // setState(() {
    //   filteredMembers = members
    //       .where((member) =>
    //   member["name"]!.toLowerCase().contains(query.toLowerCase()) ||
    //       member["mobile"]!.contains(query))
    //       .toList();
    // });
    controller.getSearchLPM(query);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: dashBoardController.showAppBar.value?AppBar(
        title: const Text('Search Member', style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: const IconThemeData(color: Colors.white),
      ):null,
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Field
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterMembers,
                  decoration: const InputDecoration(
                    hintText: "Search by name or mobile...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Member List
            Expanded(
              child: Obx(() =>
              controller.loading2.value
                  ? Center(child: CircularProgressIndicator(color: Colors.pink,))
                  : ListView.builder(
                    itemCount: controller.searchDataList.length,
                    itemBuilder: (context, index) {
                      var member = controller.searchDataList[index];
                      var firstname = "";
                      var middlename = "";
                      var lastname = "";
                      var name="";
                      var lmcode="";
                      if(member?.firstName!=null)
                      {
                        firstname = member!.firstName.toString();
                      }
                      if(member?.middleName!=null)
                      {
                        middlename = member!.middleName.toString();
                      }
                      if(member?.lastName!=null)
                      {
                        lastname = member!.lastName.toString();
                      }
                      if(member?.memberCode!=null)
                      {
                        lmcode = member!.memberCode.toString();
                      }
                     name = firstname+middlename+lastname;
                      return buildMemberCard(
                        context,
                        lmcode: lmcode,
                        name: name,
                        mobile: member.mobile,
                        profileImage: member.profileImage!.isEmpty
                            ? defaultProfile
                            : member.profileImage,
                      );
                    },
                  )
              ),)
          ],
        ),
      ),
    );
  }



  Widget buildMemberCard(BuildContext context, {
    required String lmcode,
    String? name, String? mobile,
    String? profileImage}) {
      return InkWell(
      onTap: () {
        // Navigate to MemberDetailPage on tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetailPage(),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage(profileImage.toString()),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and LM Code in the same row
                    Row(
                      children: [
                        Text(
                          name.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lmcode,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC3545), // Red color
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Mobile: $mobile",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Arrow Icon at Bottom Right
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

}

/// **Member Detail Page**
class MemberDetailPage extends StatelessWidget {
  const MemberDetailPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
