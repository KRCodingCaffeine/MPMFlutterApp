import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view_model/controller/samiti/SamitiController.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  SamitiController controller = Get.put(SamitiController());
  final TextEditingController _searchController = TextEditingController();

  bool get _hasSearchQuery => _searchController.text.trim().length >= 4;

  void _filterMembers(String query) {
    setState(() {});
    if (query.trim().length >= 4) {
      controller.getSearchLPM(query);
    } else {
      controller.searchDataList.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    controller.dispose();
    super.dispose();
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
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: "Search by name or mobile",
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
                if (controller.loading2.value && _hasSearchQuery) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFe61428)),
                  );
                }
                if (!_hasSearchQuery) {
                  return _buildHintCard(
                    icon: Icons.person_search,
                    title: "Search members",
                    message:
                        "Enter at least 4 characters to search by name or mobile number.",
                  );
                }
                if (controller.searchDataList.isEmpty) {
                  return _buildHintCard(
                    icon: Icons.search_off,
                    title: "No members found",
                    message:
                        "Try a different name or mobile number.",
                  );
                }
                return ListView.builder(
                  itemCount: controller.searchDataList.length,
                  itemBuilder: (context, index) {
                    final member = controller.searchDataList[index];
                    final name = [
                      member.firstName,
                      member.middleName,
                      member.lastName,
                    ]
                        .where((part) => part != null && part.trim().isNotEmpty)
                        .join(" ");
                    final isDeceased =
                        (member.memberStatusId ?? "").trim() == "4";

                    return buildMemberCard(
                      context,
                      lmcode: member.memberCode ?? "",
                      name: name,
                      mobile: member.mobile,
                      email: member.email,
                      profileImage: member.profileImage,
                      isDeceased: isDeceased,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0x14E61428),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 36, color: const Color(0xFFe61428)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
    bool isDeceased = false,
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
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          name.toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isDeceased)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC3545),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Deceased",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
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
                    if (mobile != null && mobile.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () async {
                          final Uri launchUri =
                              Uri(scheme: 'tel', path: mobile.trim());

                          try {
                            if (!await launchUrl(launchUri)) {
                              throw 'Could not launch $launchUri';
                            }
                          } catch (e) {
                            debugPrint("Error launching dialer: $e");
                          }
                        },
                        child: Text(
                          "Mobile: ${mobile.trim()}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                    if (email != null && email.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Email: ${email.trim()}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
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
