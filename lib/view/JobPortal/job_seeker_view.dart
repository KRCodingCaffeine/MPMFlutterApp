import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/JobPortal/GetJobByMemberId/GetJobByMemberIdData.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/repository/JobPortal/GetJobByMemberIdRepo/get_job_by_member_id_repository.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/JobPortal/job_detail.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class JobSeekerView extends StatefulWidget {
  const JobSeekerView({super.key});

  @override
  State<JobSeekerView> createState() => _JobSeekerViewState();
}

class _JobSeekerViewState extends State<JobSeekerView> {
  int selectedTab = 0;
  final GetJobByMemberIdRepository jobRepository = GetJobByMemberIdRepository();
  final UdateProfileController profileController =
      Get.find<UdateProfileController>();
  final NewMemberController regiController = Get.put(NewMemberController());

  String selectedCategory = "All";
  String selectedLocation = "All";
  RangeValues selectedSalaryRange = const RangeValues(0, 20);
  TextEditingController searchController = TextEditingController();
  TextEditingController preferredNameController = TextEditingController();
  TextEditingController preferredEmailController = TextEditingController();
  TextEditingController preferredMobileController = TextEditingController();
  TextEditingController preferredWhatsappController = TextEditingController();
  TextEditingController fieldToWorkController = TextEditingController();
  TextEditingController expectedSalaryController = TextEditingController();
  String selectedPreferredCityId = "";
  String selectedPreferredWorkMode = "On-site";
  String selectedPreferredJobType = "Full-time";
  final List<String> preferredWorkModes = [
    "On-site",
    "Work From Home",
    "Hybrid",
  ];
  final List<String> preferredJobTypes = [
    "Full-time",
    "Part-time",
    "Internship",
  ];

  double _getSalaryValue(String salary) {
    try {
      final cleaned = salary.replaceAll("₹", "").replaceAll("LPA", "").trim();
      final parts = cleaned.split("-");
      return _normalizeSalaryForFilter(double.parse(parts.first.trim()));
    } catch (e) {
      return 0;
    }
  }

  double _normalizeSalaryForFilter(double salary) {
    if (salary > 1000) {
      return (salary * 12) / 100000;
    }

    return salary;
  }

  List<Map<String, dynamic>> appliedJobs = [];

  final List<String> categories = ["IT", "Finance", "Marketing", "Design"];

  List<Map<String, dynamic>> jobs = [];

  @override
  void initState() {
    super.initState();
    if (regiController.cityList.isEmpty) {
      regiController.getCity();
    }
    loadJobs();
  }

  @override
  void dispose() {
    searchController.dispose();
    preferredNameController.dispose();
    preferredEmailController.dispose();
    preferredMobileController.dispose();
    preferredWhatsappController.dispose();
    fieldToWorkController.dispose();
    expectedSalaryController.dispose();
    super.dispose();
  }

  Future<void> loadJobs() async {
    try {
      final response = await jobRepository.getJobs(
        profileController.memberId.value,
        status: "published",
      );

      if (!mounted) return;

      if (response.status == true && response.data != null) {
        setState(() {
          jobs = response.data!
              .where((job) => job.status?.toLowerCase() == "published")
              .map(_mapJobToViewData)
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Job List Fetch Error: $e");
    }
  }

  Map<String, dynamic> _mapJobToViewData(GetJobByMemberIdData job) {
    return {
      "title": job.title ?? "",
      "company": (job.companyName ?? "").trim().isNotEmpty
          ? job.companyName
          : "Company",
      "location": job.location ?? "",
      "salary": _formatSalary(job),
      "experience": _formatExperience(job),
      "postedDate": _formatPostedDate(job),
      "category": "IT",
      "isBookmarked": false,
      "jobData": job,
    };
  }

  String _formatSalary(GetJobByMemberIdData job) {
    if (job.salaryVisible == "0") return "Not disclosed";

    final min = job.salaryMin?.toString().trim() ?? "";
    final max = job.salaryMax?.toString().trim() ?? "";

    if (min.isEmpty && max.isEmpty) return "Not disclosed";
    if (min.isNotEmpty && max.isNotEmpty) return "₹$min - $max LPA";
    return "₹${min.isNotEmpty ? min : max} LPA";
  }

  String _formatExperience(GetJobByMemberIdData job) {
    final min = job.experienceMinYears?.toString().trim() ?? "";
    final max = job.experienceMaxYears?.toString().trim() ?? "";

    if (min.isEmpty && max.isEmpty) return "Not specified";
    if (min.isNotEmpty && max.isNotEmpty) return "$min-$max Years";
    return "${min.isNotEmpty ? min : max} Years";
  }

  String _formatPostedDate(GetJobByMemberIdData job) {
    final date = job.publishedAt ?? job.createdAt ?? "";
    if (date.length >= 10) return date.substring(0, 10);
    return date;
  }

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
        actions: [
          TextButton(
            onPressed: _openPreferredCitySheet,
            child: const Text(
              "Add preferred Details",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
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

  String _cleanProfileValue(String value) {
    return value == "null" ? "" : value.trim();
  }

  void _prefillPreferredDetails() {
    preferredNameController.text = _cleanProfileValue(
      profileController.userName.value,
    );
    preferredEmailController.text = _cleanProfileValue(
      profileController.email.value,
    );
    preferredMobileController.text = _cleanProfileValue(
      profileController.mobileNumber.value,
    );
    preferredWhatsappController.text = _cleanProfileValue(
      profileController.whatsAppNumber.value,
    );

    final cityId = _cleanProfileValue(profileController.city_id.value);
    if (cityId.isNotEmpty) {
      selectedPreferredCityId = cityId;
    }
  }

  Future<void> _openPreferredCitySheet() async {
    _prefillPreferredDetails();

    if (regiController.cityList.isEmpty) {
      await regiController.getCity();
    }

    if (!mounted) return;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.85,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Submit"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Add preferred Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              _buildPreferredTextField(
                                label: "Name",
                                controller: preferredNameController,
                              ),
                              _buildPreferredTextField(
                                label: "Email",
                                controller: preferredEmailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              _buildPreferredTextField(
                                label: "Mobile Number",
                                controller: preferredMobileController,
                                keyboardType: TextInputType.phone,
                              ),
                              _buildPreferredTextField(
                                label: "Whatsapp Number",
                                controller: preferredWhatsappController,
                                keyboardType: TextInputType.phone,
                              ),
                              _buildPreferredDropdown(
                                label: "Work Mode",
                                items: preferredWorkModes,
                                selectedValue: selectedPreferredWorkMode,
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedPreferredWorkMode = value;
                                  });
                                },
                              ),
                              _buildPreferredDropdown(
                                label: "Job Type",
                                items: preferredJobTypes,
                                selectedValue: selectedPreferredJobType,
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedPreferredJobType = value;
                                  });
                                },
                              ),
                              _buildPreferredTextField(
                                label: "Field to Work",
                                controller: fieldToWorkController,
                              ),
                              _buildPreferredTextField(
                                label: "Expected Salary",
                                controller: expectedSalaryController,
                                keyboardType: TextInputType.number,
                              ),
                              _buildPreferredCityDropdown(
                                modalSetState: setModalState,
                              ),
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
      },
    );
  }

  Widget _buildPreferredTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
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

  Widget _buildPreferredDropdown({
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
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black38, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelStyle: const TextStyle(color: Colors.black),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(10),
            isExpanded: true,
            value: selectedValue,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPreferredCityDropdown({
    required StateSetter modalSetState,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Obx(() {
        if (regiController.cityList.isEmpty) {
          return const Text("No city available");
        }

        final hasSelectedCity = regiController.cityList.any(
          (city) => city.id.toString() == selectedPreferredCityId,
        );

        return InputDecorator(
          decoration: const InputDecoration(
            labelText: "Preferred City",
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black38, width: 1),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            labelStyle: TextStyle(color: Colors.black),
          ),
          isEmpty: !hasSelectedCity,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
              isExpanded: true,
              value: hasSelectedCity ? selectedPreferredCityId : null,
              items: regiController.cityList.map((CityData city) {
                return DropdownMenuItem<String>(
                  value: city.id.toString(),
                  child: Text(city.cityName ?? "Unknown"),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  modalSetState(() {
                    selectedPreferredCityId = value;
                  });
                }
              },
            ),
          ),
        );
      }),
    );
  }

  void _openFilterSheet() {
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
