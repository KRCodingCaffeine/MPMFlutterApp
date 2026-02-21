import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/JobPortal/job_detail.dart';
import 'package:share_plus/share_plus.dart';

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
  String? selectedJobTitleForMembers;
  List<Map<String, dynamic>> postedJobs = [
    {
      "title": "Flutter Developer",
      "company": "Tech Solutions Pvt Ltd",
      "location": "Mumbai",
      "salary": "₹5 - 8 LPA",
      "description": "Build cross platform mobile apps."
    },
    {
      "title": "UI Designer",
      "company": "Creative Studio",
      "location": "Ahmedabad",
      "salary": "₹4 - 6 LPA",
      "description": "Design modern UI/UX screens."
    },
    {
      "title": "Senior Accountant",
      "company": "Maheshwari Finance Group",
      "location": "Delhi",
      "salary": "₹6 - 9 LPA",
      "description": "Manage accounting and GST."
    },
  ];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController vacancyController = TextEditingController();
  final TextEditingController lastDateController = TextEditingController();

  String selectedJobType = "Full-time";
  String selectedWorkMode = "On-site";
  String selectedCategoryForPost = "IT";

  final List<String> jobTypes = ["Full-time", "Part-time", "Internship"];
  final List<String> workModes = ["On-site", "Remote", "Hybrid"];

  List<Map<String, dynamic>> appliedMembers = [
    {
      "name": "Rahul Sharma",
      "email": "rahul.sharma@gmail.com",
      "mobile": "9876543210",
      "whatsapp": "9876543210",
      "father_name": "Ramesh Sharma",
      "mother_name": "Sunita Sharma",
      "building": "Shanti Residency",
      "flat": "A-302",
      "area": "Andheri East",
      "city": "Mumbai",
      "state": "Maharashtra",
      "country": "India",
      "pincode": "400069",
      "education": "B.Tech Computer Engineering",
      "experience": "3 Years",
      "occupation": "Flutter Developer",
      "job": "Flutter Developer",
      "isShortlisted": false,
    },
    {
      "name": "Priya Mehta",
      "email": "priya.mehta@gmail.com",
      "mobile": "9823456789",
      "whatsapp": "9823456789",
      "father_name": "Mahesh Mehta",
      "mother_name": "Kavita Mehta",
      "building": "Green Park Apartments",
      "flat": "B-104",
      "area": "Satellite",
      "city": "Ahmedabad",
      "state": "Gujarat",
      "country": "India",
      "pincode": "380015",
      "education": "MBA Marketing",
      "experience": "2 Years",
      "occupation": "UI/UX Designer",
      "job": "UI Designer",
      "isShortlisted": false,
    },
    {
      "name": "Amit Verma",
      "email": "amit.verma@gmail.com",
      "mobile": "9811122233",
      "whatsapp": "9811122233",
      "father_name": "Suresh Verma",
      "mother_name": "Anita Verma",
      "building": "Lake View Towers",
      "flat": "C-504",
      "area": "Dwarka",
      "city": "Delhi",
      "state": "Delhi",
      "country": "India",
      "pincode": "110075",
      "education": "B.Com",
      "experience": "1 Year",
      "occupation": "Account Executive",
      "job": "Senior Accountant",
      "isShortlisted": false,
    },
    {
      "name": "Neha Kapoor",
      "email": "neha.kapoor@gmail.com",
      "mobile": "9898989898",
      "whatsapp": "9898989898",
      "father_name": "Raj Kapoor",
      "mother_name": "Meena Kapoor",
      "building": "Sky Heights",
      "flat": "D-210",
      "area": "Powai",
      "city": "Mumbai",
      "state": "Maharashtra",
      "country": "India",
      "pincode": "400076",
      "education": "MCA",
      "experience": "5 Years",
      "occupation": "Senior Software Engineer",
      "job": "Flutter Developer",
      "isShortlisted": false,
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
    {
      "title": "Flutter Developer",
      "company": "Tech Solutions Pvt Ltd",
      "location": "Mumbai",
      "salary": "₹5 - 8 LPA",
      "experience": "2-4 Years",
      "category": "IT",
      "description":
          "We are looking for a skilled Flutter Developer to build cross-platform mobile apps.",
      "isBookmarked": false
    },
    {
      "title": "Senior Accountant",
      "company": "Maheshwari Finance Group",
      "location": "Ahmedabad",
      "salary": "₹4 - 7 LPA",
      "experience": "3-5 Years",
      "category": "Finance",
      "description":
          "Manage financial records, GST filing, and accounting operations.",
      "isBookmarked": false
    },
    {
      "title": "Digital Marketing Executive",
      "company": "GrowthX Media",
      "location": "Delhi",
      "salary": "₹3 - 5 LPA",
      "experience": "1-3 Years",
      "category": "Marketing",
      "description":
          "Handle SEO, Google Ads, and social media marketing campaigns.",
      "isBookmarked": false
    },
    {
      "title": "UI/UX Designer",
      "company": "Creative Studio",
      "location": "Remote",
      "salary": "₹4 - 6 LPA",
      "experience": "2-4 Years",
      "category": "Design",
      "description":
          "Design user-friendly mobile and web interfaces with modern design tools.",
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
              ? recruiterTab == 0
                  ? selectedJobTitleForMembers ?? "Posted Jobs"
                  : "Post Job"
              : showJobs
                  ? selectedTab == 0
                      ? "Job"
                      : selectedTab == 1
                          ? "Saved Jobs"
                          : "Applied Jobs"
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: showJobs
            ? _buildCurrentTab(filteredJobs, savedJobs)
            : isRecruiter
                ? _buildRecruiterSection()
                : _buildSelectionCard(),
      ),
      floatingActionButton: (isRecruiter &&
              recruiterTab == 1 &&
              postedJobs.isNotEmpty)
          ? FloatingActionButton(
              backgroundColor:
                  ColorHelperClass.getColorFromHex(ColorResources.red_color),
              onPressed: () {
                _openPostJobBottomSheet();
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
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
      if (selectedJobTitleForMembers == null) {
        return _buildPostedJobsForMembers();
      } else {
        return _buildAppliedMembersForJob(selectedJobTitleForMembers!);
      }
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
        if (selectedTab == 0) ...[
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
        ],
        Expanded(
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final job = list[index];

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
              const SizedBox(height: 30),
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
                    "Offer Jobs (Employer)",
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

  Widget _buildPostedJobsForMembers() {
    if (postedJobs.isEmpty) {
      return const Center(child: Text("No jobs posted yet"));
    }

    return ListView.builder(
      itemCount: postedJobs.length,
      itemBuilder: (context, index) {
        final job = postedJobs[index];

        int applicantCount = appliedMembers
            .where((member) => member["job"] == job["title"])
            .length;

        int shortlistedCount = appliedMembers
            .where((member) =>
                member["job"] == job["title"] &&
                member["isShortlisted"] == true)
            .length;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedJobTitleForMembers = job["title"];
            });
          },
          child: Container(
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
                      child: Text(
                        job["title"] ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "$applicantCount Applicants",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (shortlistedCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "$shortlistedCount Shortlisted",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(job["company"] ?? ""),
                const SizedBox(height: 6),
                Text(
                  job["location"] ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppliedMembersForJob(String jobTitle) {
    final filteredMembers =
        appliedMembers.where((member) => member["job"] == jobTitle).toList();

    bool hasShortlisted =
        filteredMembers.any((member) => member["isShortlisted"] == true);

    return Column(
      children: [
        if (hasShortlisted)
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _shareShortlistedMembers(context),
              icon: const Icon(Icons.share),
              label: const Text("Share Shortlisted"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
        if (filteredMembers.isEmpty)
          const Expanded(
            child: Center(child: Text("No applicants for this job")),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: filteredMembers.length,
              itemBuilder: (context, index) {
                final member = filteredMembers[index];
                bool isShortlisted = member["isShortlisted"] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              member["name"] ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isShortlisted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Shortlisted",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("Experience: ${member["experience"]}"),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _showProfileBottomSheet(member);
                          },
                          child: const Text(
                            "View Profile",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showProfileBottomSheet(Map<String, dynamic> member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int experienceYears = int.tryParse(
              member["experience"]
                      ?.toString()
                      .replaceAll(RegExp(r'[^0-9]'), '') ??
                  "0",
            ) ??
            0;

        bool isShortlisted = member["isShortlisted"] ?? false;

        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.85,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Member Profile",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: isShortlisted
                            ? null
                            : () {
                                setState(() {
                                  member["isShortlisted"] = true;
                                });

                                Navigator.pop(context);

                                Future.delayed(
                                    const Duration(milliseconds: 300), () {
                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "${member["name"]} has been shortlisted"),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                });
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isShortlisted
                                ? Colors.green.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isShortlisted
                                    ? Icons.check_circle
                                    : Icons.star_border,
                                size: 16,
                                color:
                                    isShortlisted ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isShortlisted ? "Shortlisted" : "Shortlist",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isShortlisted
                                      ? Colors.green
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("Personal Details"),
                          const SizedBox(height: 12),
                          _profileRow("Name", member["name"]),
                          _profileRow("Email", member["email"]),
                          _profileRow("Mobile", member["mobile"]),
                          _profileRow("WhatsApp", member["whatsapp"]),
                          const SizedBox(height: 20),
                          _sectionTitle("Family Details"),
                          const SizedBox(height: 12),
                          _profileRow("Father's Name", member["father_name"]),
                          _profileRow("Mother's Name", member["mother_name"]),
                          const SizedBox(height: 20),
                          _sectionTitle("Residential Address"),
                          const SizedBox(height: 12),
                          Text(
                            "${member["flat"] ?? ""}, "
                            "${member["building"] ?? ""}, "
                            "${member["area"] ?? ""},\n"
                            "${member["city"] ?? ""}, "
                            "${member["state"] ?? ""}, "
                            "${member["country"] ?? ""} - "
                            "${member["pincode"] ?? ""}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 15),
                          _sectionTitle("Education"),
                          const SizedBox(height: 12),
                          _profileRow(
                              "Highest Qualification", member["education"]),
                          const SizedBox(height: 20),
                          if (experienceYears > 1) ...[
                            const Divider(),
                            const SizedBox(height: 15),
                            _sectionTitle("Occupation"),
                            const SizedBox(height: 12),
                            _profileRow(
                                "Experience",
                                member["experience"] ??
                                    "$experienceYears Years"),
                            _profileRow(
                                "Current Occupation", member["occupation"]),
                          ],
                          const SizedBox(height: 20),
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

  void _shareShortlistedMembers(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    final shortlisted = appliedMembers
        .where((member) => member["isShortlisted"] == true)
        .toList();

    if (shortlisted.isEmpty) return;

    String shareText = "🌟 Shortlisted Members Details\n\n";

    for (var member in shortlisted) {
      shareText += '''
      👤 Name: ${member["name"]}
      📧 Email: ${member["email"]}
      📱 Mobile: ${member["mobile"]}
      💬 WhatsApp: ${member["whatsapp"]}
      
      🎓 Education: ${member["education"]}
      💼 Occupation: ${member["occupation"]}
      
      🏠 Address:
      ${member["building"]}, ${member["flat"]}
      ${member["area"]}, ${member["city"]}
      ${member["state"]}, ${member["country"]} - ${member["pincode"]}
      
      ----------------------------------
      ''';
    }

    await Share.share(
      shareText,
      subject: "Shortlisted Members",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Widget _profileRow(String label, dynamic value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        const Text(": "),
        Expanded(
          child: Text(
            value?.toString() ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
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
            ElevatedButton(
              onPressed: () {
                _openPostJobBottomSheet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
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
            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job["title"] ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onSelected: (value) {
                      if (value == "edit") {
                        _openPostJobBottomSheet(editIndex: index);
                      } else if (value == "delete") {
                        _showDeleteDialog(index);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: "edit",
                        child: Text(
                          "Edit Job",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: "delete",
                        child: Text(
                          "Delete Job",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.red.withOpacity(0.08),
                      ),
                      child: const Text(
                        "Edit / Delete",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 6),
              const SizedBox(height: 8),
              _infoRow("Company", job["company"] ?? ""),
              const SizedBox(height: 8),
              _infoRow("Location", job["location"] ?? ""),
              const SizedBox(height: 8),
              _infoRow("Salary", job["salary"] ?? ""),
              const SizedBox(height: 8),
              _infoRow("Description", job["description"] ?? ""),
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
      qualificationController.text = job["qualification"] ?? "";
      experienceController.text = job["experience"] ?? "";
      skillsController.text = job["skills"] ?? "";
      vacancyController.text = job["vacancy"] ?? "";
      lastDateController.text = job["lastDate"] ?? "";
      selectedJobType = job["jobType"] ?? "Full-time";
      selectedWorkMode = job["workMode"] ?? "On-site";
      selectedCategoryForPost = job["category"] ?? "IT";
    } else {
      titleController.clear();
      companyController.clear();
      locationController.clear();
      salaryController.clear();
      descriptionController.clear();
      qualificationController.clear();
      experienceController.clear();
      skillsController.clear();
      vacancyController.clear();
      lastDateController.clear();
      selectedJobType = "Full-time";
      selectedWorkMode = "On-site";
      selectedCategoryForPost = "IT";
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
            heightFactor: 0.85,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                          side: BorderSide(
                            color: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          bool isUpdate = editIndex != null;
                          setState(() {
                            final jobData = {
                              "title": titleController.text,
                              "company": companyController.text,
                              "location": locationController.text,
                              "salary": salaryController.text,
                              "description": descriptionController.text,
                              "qualification": qualificationController.text,
                              "experience": experienceController.text,
                              "skills": skillsController.text,
                              "vacancy": vacancyController.text,
                              "lastDate": lastDateController.text,
                              "jobType": selectedJobType,
                              "workMode": selectedWorkMode,
                              "category": selectedCategoryForPost,
                            };

                            if (isUpdate) {
                              postedJobs[editIndex] = jobData;
                            } else {
                              postedJobs.add(jobData);
                            }

                            recruiterTab = 1;
                          });

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isUpdate
                                    ? "Job updated successfully"
                                    : "Job added successfully",
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(editIndex != null ? "Update" : "Post Job"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                          _buildTextField("Salary (e.g ₹5-8 LPA)",
                              controller: salaryController),
                          _buildTextField("Minimum Qualification",
                              controller: qualificationController),
                          _buildTextField("Experience Required (e.g 2-4 Years)",
                              controller: experienceController),
                          _buildTextField("Required Skills (Comma separated)",
                              controller: skillsController),
                          _buildTextField("Number of Vacancies",
                              controller: vacancyController),
                          _buildTextField("Last Date to Apply",
                              controller: lastDateController),
                          const SizedBox(height: 10),
                          _buildDropdown(
                            label: "Job Type",
                            items: jobTypes,
                            selectedValue: selectedJobType,
                            onChanged: (val) {
                              setState(() {
                                selectedJobType = val;
                              });
                            },
                          ),
                          _buildDropdown(
                            label: "Work Mode",
                            items: workModes,
                            selectedValue: selectedWorkMode,
                            onChanged: (val) {
                              setState(() {
                                selectedWorkMode = val;
                              });
                            },
                          ),
                          _buildDropdown(
                            label: "Category",
                            items: categories,
                            selectedValue: selectedCategoryForPost,
                            onChanged: (val) {
                              setState(() {
                                selectedCategoryForPost = val;
                              });
                            },
                          ),
                          _buildTextField("Job Description",
                              controller: descriptionController, maxLines: 4),
                          const SizedBox(height: 30),
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

  Widget _buildTextField(String label,
      {int maxLines = 1, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black38, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelStyle: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black38, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelStyle: const TextStyle(color: Colors.black),
        ),
        isEmpty: selectedValue.isEmpty,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(10),
            isExpanded: true,
            value: selectedValue.isEmpty ? null : selectedValue,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                onChanged(val);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          const Text(
            ": ",
            style: TextStyle(color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: label == "Salary" ? Colors.green : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int index) {
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Delete Job",
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
          content: const Text(
            "Are you sure you want to delete this job?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: BorderSide(
                  color: ColorHelperClass.getColorFromHex(
                      ColorResources.red_color),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  postedJobs.removeAt(index);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Job deleted successfully"),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
