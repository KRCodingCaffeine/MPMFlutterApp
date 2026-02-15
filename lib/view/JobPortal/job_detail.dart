import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class JobDetailView extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailView({super.key, required this.job});

  @override
  State<JobDetailView> createState() => _JobDetailViewState();
}

class _JobDetailViewState extends State<JobDetailView> {

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          "Job Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [

          /// ⭐ Bookmark Toggle
          IconButton(
            icon: Icon(
              job["isBookmarked"]
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: job["isBookmarked"]
                  ? Colors.orange
                  : Colors.white,
            ),
            onPressed: () {
              setState(() {
                job["isBookmarked"] =
                !job["isBookmarked"];
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            /// Job Title
            Text(
              job["title"],
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            /// Company
            Text(
              job["company"],
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 16),

            /// Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                  )
                ],
              ),
              child: Column(
                children: [

                  _buildInfoRow(Icons.location_on,
                      "Location", job["location"]),

                  const Divider(),

                  _buildInfoRow(Icons.currency_rupee,
                      "Salary", job["salary"]),

                  const Divider(),

                  _buildInfoRow(Icons.work,
                      "Experience", job["experience"]),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Description
            const Text(
              "Job Description",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              job["description"],
              style: const TextStyle(height: 1.5),
            ),

            const SizedBox(height: 40),

            /// Apply Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Application Submitted"),
                    ),
                  );
                },

                child: const Text(
                  "Apply Now",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: const TextStyle(
              fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}