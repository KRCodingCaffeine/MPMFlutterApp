import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/ShikshaSahayata/applicant_detail.dart';
import 'package:mpm/view/ShikshaSahayata/family_detail.dart';

class ShikshaSahayataByParentingView extends StatefulWidget {
  const ShikshaSahayataByParentingView({super.key});

  @override
  State<ShikshaSahayataByParentingView> createState() => _ShikshaSahayataByParentingViewState();
}

class _ShikshaSahayataByParentingViewState extends State<ShikshaSahayataByParentingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          "Shiksha Sahayata For Children",
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [

            buildCustomButton(
              title: "Applicant Detail",
              icon: Icons.person,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ApplicantDetail(),
                ),
              ),
            ),

            buildCustomButton(
              title: "Family Detail",
              icon: Icons.family_restroom,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FamilyDetail(),
                ),
              ),            ),

            buildCustomButton(
              title: "Education Detail",
              icon: Icons.menu_book,
              onTap: () {},
            ),

            buildCustomButton(
              title: "Current Year Education",
              icon: Icons.school,
              onTap: () {},
            ),

            buildCustomButton(
              title: "Other Charity Fund",
              icon: Icons.volunteer_activism,
              onTap: () {},
            ),

            buildCustomButton(
              title: "Any Other Charity?",
              icon: Icons.handshake,
              onTap: () {},
            ),

            buildCustomButton(
              title: "MPM",
              icon: Icons.verified, // or Icons.approval
              onTap: () {},
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // -------------------------------------
  // Custom Button (same as ProfileView)
  // -------------------------------------
  Widget buildCustomButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios,
              size: 16, color: Colors.black),
          onTap: onTap,
        ),
        const Divider(color: Colors.grey, thickness: 0.5),
      ],
    );
  }
}
