import 'package:flutter/material.dart';
import 'package:mpm/model/BusinessProfile/ConnectedMember/ConnectedMemberData.dart';
import 'package:mpm/repository/BusinessProfileRepo/connected_member_repository/connected_member_repo.dart';
import 'package:mpm/repository/BusinessProfileRepo/delete_business_connect_request_repository/delete_business_connect_request_repo.dart';
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
  final DeleteBusinessConnectRequestRepository _deleteRepo =
  DeleteBusinessConnectRequestRepository();

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
        crossAxisAlignment: CrossAxisAlignment.center,
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
                    child: Text(
                      "Mobile : ${member.mobile!}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
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

          // ⋮ MENU
          PopupMenuButton<String>(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(member);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            child: const Icon(
              Icons.more_vert,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ConnectedMemberData member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),

          // TITLE + DIVIDER (SAME AS LOGOUT)
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Delete Connection",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),

          // CONTENT
          content: Text(
            "Are you sure you want to delete ${member.displayName} from your connected members?",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),

          // ACTIONS
          actions: [
            // NO BUTTON
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("No"),
            ),

            // YES / DELETE BUTTON
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteConnectedMember(member);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteConnectedMember(ConnectedMemberData member) async {
    if (member.requestId == null || member.requestId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid connection ID"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Optional: show loader dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response =
      await _deleteRepo.deleteBusinessConnectRequest(member.requestId!);

      Navigator.pop(context); // close loader

      if (response.status == true) {
        setState(() {
          _members.removeWhere(
                (m) => m.requestId == member.requestId,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ?? "Connection deleted successfully",
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? "Failed to delete connection"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // close loader

      debugPrint("❌ Delete error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong while deleting"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
