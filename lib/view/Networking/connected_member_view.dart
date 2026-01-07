import 'package:flutter/material.dart';
import 'package:mpm/model/BusinessProfile/ConnectedMember/ConnectedMemberData.dart';
import 'package:mpm/repository/BusinessProfileRepo/connected_member_repository/connected_member_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';

class ConnectedMemberView extends StatefulWidget {
  const ConnectedMemberView({super.key});

  @override
  State<ConnectedMemberView> createState() => _ConnectedMemberViewState();
}

class _ConnectedMemberViewState extends State<ConnectedMemberView> {
  final ConnectedMemberRepository _repo = ConnectedMemberRepository();

  bool _isLoading = true;
  List<ConnectedMemberData> _members = [];

  @override
  void initState() {
    super.initState();
    _loadConnectedMembers();
  }

  Future<void> _loadConnectedMembers() async {
    setState(() => _isLoading = true);

    try {
      final user = await SessionManager.getSession();

      if (user == null || user.memberId == null) {
        throw Exception("Session expired");
      }

      final response = await _repo.getConnectedMembers(
        requestedByMemberId: user.memberId.toString(),
      );

      if (response.status == true) {
        setState(() {
          _members = response.data ?? [];
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading connected members: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to load connected members"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor =
    ColorHelperClass.getColorFromHex(ColorResources.red_color);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              "Connected Members",
              style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w500),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        color: ColorHelperClass.getColorFromHex(ColorResources.red_color),
        onRefresh: _loadConnectedMembers,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _members.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [_buildEmptyState()],
        )
            : ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: _members.length,
          itemBuilder: (context, index) {
            return _buildMemberCard(_members[index], themeColor);
          },
        ),
      ),
    );
  }

  // ================= MEMBER CARD =================

  Widget _buildMemberCard(
      ConnectedMemberData member, Color themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              height: 60,
              width: 60,
              child: member.profileImage != null &&
                  member.profileImage!.isNotEmpty
                  ? Image.network(
                Urls.imagePathUrl + member.profileImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Image.asset("assets/images/user3.png"),
              )
                  : Image.asset("assets/images/user3.png"),
            ),
          ),

          const SizedBox(width: 12),

          // Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                // Membership Code
                if ((member.memberCode ?? "").isNotEmpty)
                  Text(
                    "Membership Code : ${member.memberCode}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                if ((member.mobile ?? "").isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text(
                          "Mobile : ${member.mobile!}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (member.professionDisplay.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Contact for : ${member.professionDisplay}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                if (member.connectedDateFormatted.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Contact on : ${member.connectedDateFormatted}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline,
              size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No Connected Members",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Your connected members will appear here",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
