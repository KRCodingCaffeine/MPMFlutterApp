import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/JobPortal/job_detail.dart';

class JobView extends StatefulWidget {
  const JobView({super.key});

  @override
  State<JobView> createState() => _JobViewState();
}

class _JobViewState extends State<JobView> {
  bool showJobs = false;
  int selectedTab = 0;
  bool isRecruiter = false;
  int recruiterTab = 0;
  List<Map<String, dynamic>> postedJobs = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<Map<String, String>> appliedMembers = [
    {
      "name": "Rahul Sharma",
      "job": "Flutter Developer",
      "experience": "3 Years",
      "status": "Pending"
    },
    {
      "name": "Priya Mehta",
      "job": "UI Designer",
      "experience": "2 Years",
      "status": "Pending"
    },
  ];

  String selectedCategory = "All";
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> appliedJobs = [];

  final List<String> categories = [
    "All",
    "IT",
    "Finance",
    "Marketing",
    "Design"
  ];

  final List<Map<String, dynamic>> jobs = [

    // ================= IT =================
    {
      "title": "Flutter Developer",
      "company": "Tech Solutions Pvt Ltd",
      "location": "Mumbai",
      "salary": "₹5 - 8 LPA",
      "experience": "2-4 Years",
      "category": "IT",
      "description": "We are looking for a skilled Flutter Developer to build cross-platform mobile apps.",
      "isBookmarked": false
    },

    // ================= FINANCE =================
    {
      "title": "Senior Accountant",
      "company": "Maheshwari Finance Group",
      "location": "Ahmedabad",
      "salary": "₹4 - 7 LPA",
      "experience": "3-5 Years",
      "category": "Finance",
      "description": "Manage financial records, GST filing, and accounting operations.",
      "isBookmarked": false
    },

    // ================= MARKETING =================
    {
      "title": "Digital Marketing Executive",
      "company": "GrowthX Media",
      "location": "Delhi",
      "salary": "₹3 - 5 LPA",
      "experience": "1-3 Years",
      "category": "Marketing",
      "description": "Handle SEO, Google Ads, and social media marketing campaigns.",
      "isBookmarked": false
    },

    // ================= DESIGN =================
    {
      "title": "UI/UX Designer",
      "company": "Creative Studio",
      "location": "Remote",
      "salary": "₹4 - 6 LPA",
      "experience": "2-4 Years",
      "category": "Design",
      "description": "Design user-friendly mobile and web interfaces with modern design tools.",
      "isBookmarked": false
    },

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

    List<Map<String, dynamic>> savedJobs =
        jobs.where((job) => (job["isBookmarked"] ?? false)).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          isRecruiter
              ? "Recruiter Panel"
              : "Job",
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: showJobs
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    showJobs = false;
                    selectedTab = 0;
                  });
                },
              )
            : null,
        actions: isRecruiter && recruiterTab == 1
            ? [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _openPostJobBottomSheet();
            },
          )
        ]
            : null,
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: showJobs
            ? _buildCurrentTab(filteredJobs, savedJobs)
            : isRecruiter
                ? _buildRecruiterSection()
                : _buildSelectionCard(),
      ),

      bottomNavigationBar: showJobs
          ? BottomNavigationBar(
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
                  label: "Home",
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
            )
          : isRecruiter
              ? BottomNavigationBar(
                  currentIndex: recruiterTab,
                  onTap: (index) {
                    setState(() {
                      recruiterTab = index;
                    });
                  },
                  selectedItemColor: ColorHelperClass.getColorFromHex(
                      ColorResources.red_color),
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.people), label: "Applied Members"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.add_box), label: "Post Job"),
                  ],
                )
              : null,
    );
  }

  // ================= TAB SWITCH =================

  Widget _buildCurrentTab(List<Map<String, dynamic>> filteredJobs,
      List<Map<String, dynamic>> savedJobs) {
    if (selectedTab == 0) {
      return _buildHomeUI(filteredJobs);
    } else if (selectedTab == 1) {
      return _buildHomeUI(savedJobs);
    } else {
      return _buildHomeUI(appliedJobs);
    }
  }

  Widget _buildRecruiterSection() {
    if (recruiterTab == 0) {
      return _buildAppliedMembers();
    } else {
      return _buildPostJobForm();
    }
  }

  Widget _buildHomeUI(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(child: Text("No jobs found"));
    }

    return Column(
      children: [
        /// 🔍 Search (OLD STYLE RESTORED)
        TextField(
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

        const SizedBox(height: 12),

        /// 📂 Category Chips (OLD STYLE RESTORED)
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(categories[index]),
                  selected: selectedCategory == categories[index],
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = categories[index];
                    });
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 15),

        /// 💼 JOB LIST (OLD CARD UI RESTORED)
        Expanded(
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final job = list[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailView(job: job),
                    ),
                  );
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
                              color: Colors.green,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text("Experience: ${job["experience"]}"),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!appliedJobs.contains(job)) {
                              setState(() {
                                appliedJobs.add(job);
                              });
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Applied Successfully")),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Apply"),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildSelectionCard() {
    return Center(
      child: Card(
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔴 Top Icon
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.work_outline,
                  size: 35,
                  color: Colors.redAccent,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Are you looking for?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              /// 🔵 Looking for Job
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      showJobs = true;
                    });
                  },
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text(
                    "Looking for Job",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              /// 🟢 Recruiter Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      isRecruiter = true;
                    });
                  },
                  icon: const Icon(Icons.work, color: Colors.redAccent),
                  label: const Text(
                    "Recruiter (Post Job)",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppliedMembers() {
    if (appliedMembers.isEmpty) {
      return const Center(child: Text("No applications yet"));
    }

    return ListView.builder(
      itemCount: appliedMembers.length,
      itemBuilder: (context, index) {
        final member = appliedMembers[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade200, blurRadius: 6)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member["name"] ?? "",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("Applied For: ${member["job"]}"),
              Text("Experience: ${member["experience"]}"),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // STATUS BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: member["status"] == "Accepted"
                          ? Colors.green.withOpacity(0.1)
                          : member["status"] == "Rejected"
                          ? Colors.red.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      member["status"] ?? "",
                      style: TextStyle(
                        color: member["status"] == "Accepted"
                            ? Colors.green
                            : member["status"] == "Rejected"
                            ? Colors.red
                            : Colors.orange,
                      ),
                    ),
                  ),

                  if (member["status"] == "Pending")
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              member["status"] = "Accepted";
                            });
                          },
                          child: const Text("Accept",
                              style: TextStyle(color: Colors.green)),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              member["status"] = "Rejected";
                            });
                          },
                          child: const Text("Reject",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostJobForm() {
    if (postedJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.work_outline,
              size: 60,
              color: Colors.grey,
            ),

            const SizedBox(height: 15),

            const Text(
              "No Jobs Posted Yet",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Start by posting your first job",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            /// ✅ POST JOB BUTTON
            ElevatedButton(
              onPressed: () {
                _openPostJobBottomSheet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                ColorHelperClass.getColorFromHex(
                    ColorResources.red_color),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Post Job",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: postedJobs.length,
      itemBuilder: (context, index) {
        final job = postedJobs[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade200, blurRadius: 6)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(job["title"] ?? "",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),

                  Row(
                    children: [

                      /// ✏ EDIT
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.blue),
                        onPressed: () {
                          _openPostJobBottomSheet(
                            editIndex: index,
                          );
                        },
                      ),

                      /// 🗑 DELETE
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () {
                          setState(() {
                            postedJobs.removeAt(index);
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 6),
              Text("Company: ${job["company"] ?? ""}"),
              Text("Location: ${job["location"] ?? ""}"),
              Text("Salary: ${job["salary"] ?? ""}",
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }

  void _openPostJobBottomSheet({int? editIndex}) {
    if (editIndex != null) {
      final job = postedJobs[editIndex];

      titleController.text = job["title"] ?? "";
      companyController.text = job["company"] ?? "";
      locationController.text = job["location"] ?? "";
      salaryController.text = job["salary"] ?? "";
      descriptionController.text = job["description"] ?? "";
    } else {
      titleController.clear();
      companyController.clear();
      locationController.clear();
      salaryController.clear();
      descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.65,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [

                  const SizedBox(height: 12),

                  /// 🔹 TOP BUTTON ROW (LIKE YOUR EDIT SHEET)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      /// ❌ CANCEL
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                          ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                          side: BorderSide(
                            color: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),

                      /// ✅ POST / UPDATE
                      ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isEmpty ||
                              companyController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please fill required fields")),
                            );
                            return;
                          }

                          setState(() {
                            if (editIndex != null) {
                              postedJobs[editIndex] = {
                                "title": titleController.text,
                                "company": companyController.text,
                                "location": locationController.text,
                                "salary": salaryController.text,
                                "description": descriptionController.text,
                              };
                            } else {
                              postedJobs.add({
                                "title": titleController.text,
                                "company": companyController.text,
                                "location": locationController.text,
                                "salary": salaryController.text,
                                "description": descriptionController.text,
                              });
                            }
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
                        child: Text(
                            editIndex != null ? "Update" : "Post Job"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// 🔹 FORM SECTION
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildTextField("Job Title",
                              controller: titleController),
                          _buildTextField("Company Name",
                              controller: companyController),
                          _buildTextField("Location",
                              controller: locationController),
                          _buildTextField("Salary",
                              controller: salaryController),
                          _buildTextField("Description",
                              controller: descriptionController,
                              maxLines: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, {int maxLines = 1, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black26),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black26),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black26),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black26, width: 1.0),
          ),
        ),
      ),
    );
  }
}
