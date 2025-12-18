import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class EducationDetailView extends StatefulWidget {
  const EducationDetailView({super.key});

  @override
  State<EducationDetailView> createState() => _EducationDetailViewState();
}

class _EducationDetailViewState extends State<EducationDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text(
          "Education Detail",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add, color: Colors.white),
        //     onPressed: () => _showAddApplicantModalSheet(context),
        //   )
        // ],
      ),
      body: Center(
        child: Text(
          "No Education Details Added Yet",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
