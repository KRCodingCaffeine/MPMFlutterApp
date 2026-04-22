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
  String selectedLocation = "All";
  RangeValues selectedSalaryRange = const RangeValues(0, 20);
  TextEditingController searchController = TextEditingController();

  double _getSalaryValue(String salary) {
    try {
      final cleaned = salary.replaceAll("₹", "").replaceAll("LPA", "").trim();
      final parts = cleaned.split("-");
      return double.parse(parts.first.trim());
    } catch (e) {
      return 0;
    }
  }

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

      final matchesLocation =
          selectedLocation == "All" || job["location"] == selectedLocation;

      final jobSalary = _getSalaryValue(job["salary"]);

      final matchesSalary = jobSalary >= selectedSalaryRange.start &&
          jobSalary <= selectedSalaryRange.end;

      return matchesCategory &&
          matchesSearch &&
          matchesLocation &&
          matchesSalary;
    }).toList();
    List<Map<String, dynamic>> displayJobs;

    if (selectedTab == 1) {
      displayJobs = jobs.where((job) => job["isBookmarked"] == true).toList();
    } else if (selectedTab == 2) {
      displayJobs = appliedJobs;
    } else {
      displayJobs = filteredJobs;
    }

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
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Search jobs eg: developer, accountant...",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// FILTER BUTTON
                GestureDetector(
                  onTap: _openFilterSheet,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.filter_alt,
                      color: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: displayJobs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: displayJobs.length,
                    itemBuilder: (context, index) {
                      final job = displayJobs[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// LEFT SIDE DETAILS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job["title"],
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    job["company"],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        job["location"],
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const SizedBox(width: 14),
                                      Text(
                                        job["salary"],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Experience: ${job["experience"]}",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Posted: ${job["postedDate"]}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            /// RIGHT SIDE ACTIONS
                            Column(
                              children: [
                                /// SAVE BUTTON
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      job["isBookmarked"] =
                                          !(job["isBookmarked"] ?? false);
                                    });
                                  },
                                  child: Icon(
                                    (job["isBookmarked"] ?? false)
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    size: 24,
                                    color: (job["isBookmarked"] ?? false)
                                        ? Colors.orange
                                        : Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 50),

                                /// APPLY BUTTON
                                selectedTab != 2
                                    ? SizedBox(
                                        height: 36,
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
                                                builder: (_) =>
                                                    JobDetailView(job: job),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            "Apply",
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          "Applied",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                              ],
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

  Widget _buildEmptyState() {
    String title = "";
    String message = "";

    if (selectedTab == 1) {
      title = "No Saved Jobs";
      message = "Jobs you bookmark will appear here.";
    } else if (selectedTab == 2) {
      title = "No Applied Jobs";
      message = "Jobs you apply for will appear here.";
    } else {
      title = "No Jobs Found";
      message = "Try changing filters or search keywords.";
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet() {
    List<String> locations = ["All", "Mumbai", "Ahmedabad"];

    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          String tempLocation = selectedLocation;
          RangeValues tempSalary = selectedSalaryRange;

          return StatefulBuilder(
            builder: (context, setModalState) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      /// HEADER (FIXED)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Filter Jobs",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),

                      const Divider(),

                      /// SCROLLABLE CONTENT
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// LOCATION
                              const Text(
                                "Location",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),

                              const SizedBox(height: 10),

                              Column(
                                children: ["All", "Mumbai", "Ahmedabad"]
                                    .map((location) {
                                  return RadioListTile(
                                    value: location,
                                    groupValue: tempLocation,
                                    title: Text(location),
                                    activeColor:
                                        ColorHelperClass.getColorFromHex(
                                            ColorResources.red_color),
                                    onChanged: (value) {
                                      setModalState(() {
                                        tempLocation = value.toString();
                                      });
                                    },
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 20),

                              /// SALARY RANGE
                              const Text(
                                "Salary Range (LPA)",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),

                              const SizedBox(height: 10),

                              RangeSlider(
                                values: tempSalary,
                                min: 0,
                                max: 20,
                                divisions: 20,
                                labels: RangeLabels(
                                  "${tempSalary.start.round()} LPA",
                                  "${tempSalary.end.round()} LPA",
                                ),
                                activeColor: ColorHelperClass.getColorFromHex(
                                    ColorResources.red_color),
                                onChanged: (values) {
                                  setModalState(() {
                                    tempSalary = values;
                                  });
                                },
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${tempSalary.start.round()} LPA"),
                                  Text("${tempSalary.end.round()} LPA"),
                                ],
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),

                      /// BUTTONS (ALSO FIXED)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  tempLocation = "All";
                                  tempSalary = const RangeValues(0, 20);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    ColorHelperClass.getColorFromHex(
                                        ColorResources.red_color),
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Clear"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedLocation = tempLocation;
                                  selectedSalaryRange = tempSalary;
                                });

                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    ColorHelperClass.getColorFromHex(
                                        ColorResources.red_color),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Apply"),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}
