import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/JobPortal/job_detail.dart';

class JobSeekerView extends StatefulWidget {
  const JobSeekerView({super.key});

  @override
  State<JobSeekerView> createState() => _JobSeekerViewState();
}

class _JobSeekerViewState extends State<JobSeekerView> {
  int selectedTab = 0;

  String selectedCategory = "All";

  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> appliedJobs = [];

  final List<String> categories = ["IT", "Finance", "Marketing", "Design"];

  final List<Map<String, dynamic>> jobs = [
    {
      "title": "Flutter Developer",
      "company": "Tech Solutions Pvt Ltd",
      "location": "Mumbai",
      "salary": "₹5 - 8 LPA",
      "experience": "2-4 Years",
      "postedDate": "20 Feb 2026",
      "category": "IT",
      "isBookmarked": false
    },
    {
      "title": "Senior Accountant",
      "company": "Maheshwari Finance Group",
      "location": "Ahmedabad",
      "salary": "₹4 - 6 LPA",
      "experience": "3-5 Years",
      "postedDate": "18 Feb 2026",
      "category": "Finance",
      "isBookmarked": false
    }
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredJobs = jobs.where((job) {
      final matchesCategory =
          selectedCategory == "All" || job["category"] == selectedCategory;

      final matchesSearch = job["title"]
          .toLowerCase()
          .contains(searchController.text.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text(
          "Job",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search jobs...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredJobs.length,
              itemBuilder: (context, index) {
                final job = filteredJobs[index];

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              job["title"],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              (job["isBookmarked"] ?? false)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: (job["isBookmarked"] ?? false)
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                job["isBookmarked"] =
                                !(job["isBookmarked"] ?? false);
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(job["company"],
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(job["location"]),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(job["salary"],
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text("Experience: ${job["experience"]}"),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            "Posted on: ${job["postedDate"] ?? "Recently"}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (selectedTab != 2)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              if (!appliedJobs.contains(job)) {
                                setState(() {
                                  appliedJobs.add(job);
                                });
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JobDetailView(job: job),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Apply"),
                          ),
                        ),
                      if (selectedTab == 2)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Applied",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        onTap: (index) {
          setState(() {
            selectedTab = index;
          });
        },
        selectedItemColor:
        ColorHelperClass.getColorFromHex(ColorResources.red_color),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Job",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: "Saved",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: "Applied",
          ),
        ],
      ),
    );
  }
}
