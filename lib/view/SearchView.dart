import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final String defaultProfile = "assets/images/user3.png";

  List<Map<String, String>> members = [
    {
      "lmcode": "LM1",
      "name": "Karthika K Rajesh",
      "mobile": "8898085105",
      "profile": "assets/images/user2.png"
    },
    {
      "lmcode": "LM2",
      "name": "Rajesh Mani Nair",
      "mobile": "8765432109",
      "profile": "assets/images/male.png"
    },
    {
      "lmcode": "LM4",
      "name": "Manoj Kumar Murugan",
      "mobile": "8086130758",
      "profile": ""
    },
    {
      "lmcode": "LM6",
      "name": "Developer Test",
      "mobile": "6543210987",
      "profile": "assets/images/user2.png"
    },
  ];

  List<Map<String, String>> filteredMembers = [];

  @override
  void initState() {
    super.initState();
    filteredMembers = members;
  }

  void _filterMembers(String query) {
    setState(() {
      filteredMembers = members
          .where((member) =>
              member["name"]!.toLowerCase().contains(query.toLowerCase()) ||
              member["mobile"]!.contains(query))
          .toList();
    });
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
              child: ListView.builder(
                itemCount: filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = filteredMembers[index];
                  return _buildMemberCard(
                    context,
                    lmcode: member["lmcode"]!,
                    name: member["name"]!,
                    mobile: member["mobile"]!,
                    profileImage: member["profile"]!.isEmpty
                        ? defaultProfile
                        : member["profile"]!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Reusable method to build a member card with navigation**
  Widget _buildMemberCard(
    BuildContext context, {
    required String lmcode,
    required String name,
    required String mobile,
    required String profileImage,
  }) {
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
                backgroundImage: AssetImage(profileImage),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and LM Code in the same row
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Mobile: $mobile",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lmcode,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFe61428), // Red color
                          ),
                        ),
                      ],
                    )
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
