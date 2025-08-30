import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mpm/view_model/controller/samiti/SamitiController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/urls.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  SamitiController controller = Get.put(SamitiController());
  final TextEditingController _searchController = TextEditingController();
  final UdateProfileController dashBoardController = Get.find();
  final String defaultProfile = "assets/images/user.png";

  void _filterMembers(String query) {
    if (query.length >= 4) {
      controller.getSearchLPM(query);
    } else {
      controller.searchDataList.clear();
    }
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
              child: Obx(() {
                if (controller.loading2.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFe61428)),
                  );
                } else if (controller.searchDataList.value.isEmpty) {
                  return const Center(
                    child: Text(
                      "No members found",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: controller.searchDataList.value.length,
                    itemBuilder: (context, index) {
                      var member = controller.searchDataList.value[index];
                      var firstname = member?.firstName ?? "";
                      var lastname = member?.lastName ?? "";
                      var name = "$firstname $lastname".trim();
                      var lmcode = member?.memberCode ?? "";

                      return buildMemberCard(
                        context,
                        lmcode: lmcode,
                        name: name,
                        mobile: member.mobile,
                        email: member.email,
                        profileImage: member.profileImage != null
                            ? member.profileImage!.isEmpty
                                ? defaultProfile
                                : member.profileImage
                            : defaultProfile,
                      );
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMemberCard(
    BuildContext context, {
    required String lmcode,
    String? name,
    String? mobile,
    String? email,
    String? profileImage,
  }) {
    return InkWell(
      // onTap: () {
      //   // Navigate to MemberDetailPage on tap
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const MemberDetailPage(),
      //     ),
      //   );
      // },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipOval(
                child: (profileImage != null && profileImage.isNotEmpty)
                    ? FadeInImage(
                  placeholder: const AssetImage("assets/images/user3.png"),
                  image: NetworkImage(Urls.imagePathUrl + profileImage),
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/images/user3.png",
                      fit: BoxFit.cover,
                      width: 70,
                      height: 70,
                    );
                  },
                  fit: BoxFit.cover,
                  width: 70,
                  height: 70,
                )
                    : Image.asset(
                  "assets/images/user3.png",
                  fit: BoxFit.cover,
                  width: 70,
                  height: 70,
                ),
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
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black, // Default text color (Black)
                        ),
                        children: [
                          const TextSpan(
                            text: "Membership Code: ",
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: (lmcode.trim().isNotEmpty) ? lmcode : " -- ",
                            style: const TextStyle(
                              color: Color(0xFFDC3545),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    mobile != null && mobile.trim().isNotEmpty
                        ? GestureDetector(
                            onTap: () async {
                              final Uri launchUri =
                                  Uri(scheme: 'tel', path: mobile);

                              try {
                                if (!await launchUrl(launchUri)) {
                                  throw 'Could not launch $launchUri';
                                }
                              } catch (e) {
                                print("Error launching dialer: $e");
                              }
                            },
                            child: Text(
                              "Mobile: $mobile",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueAccent,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    const SizedBox(height: 4),

                    Text(
                      "Email: ${email ?? "-"}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow Icon at Bottom Right
              // const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

/// **Member Detail Page**
class MemberDetailPage extends StatelessWidget {
  const MemberDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
