import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class RecruiterJobView extends StatefulWidget {
  const RecruiterJobView({super.key});

  @override
  State<RecruiterJobView> createState() => _RecruiterJobViewState();
}

class _RecruiterJobViewState extends State<RecruiterJobView> {
  int recruiterTab = 0;

  List<Map<String, dynamic>> postedJobs = [
    {
      "title": "Flutter Developer",
      "company": "Tech Solutions Pvt Ltd",
      "location": "Mumbai",
      "salary": "₹5 - 8 LPA",
    },
  ];

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
      "profile_summary":
          "Passionate Flutter developer with 3 years of experience building scalable mobile applications with clean UI and optimized performance.",
      "resume":
          "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      "status": "pending",
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
      "profile_summary":
          "Creative UI/UX designer with strong user research and wireframing skills, focused on delivering intuitive and visually appealing digital experiences.",
      "resume":
          "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      "status": "pending",
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
      "experience": "0 Year",
      "occupation": "Account Executive",
      "job": "Senior Accountant",
      "profile_summary":
          "Detail-oriented accounting professional with strong knowledge of financial reporting, taxation basics, and bookkeeping practices.",
      "resume":
          "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      "status": "pending",
      "isShortlisted": false,
    },
    {
      "name": "Neha Kapoor",
      "email": "neha.kapoor@gmail.com",
      "mobile": "9898989898",
      "whatsapp": "1234567890",
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
      "profile_summary":
          "Senior software engineer with 5 years of experience in mobile app architecture, API integration, and performance optimization.",
      "resume":
          "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      "status": "pending",
      "isShortlisted": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text(
          "Offer Jobs",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: recruiterTab == 0
          ? _buildPostedJobs()
          : const Center(child: Text("Post Job Form")),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: recruiterTab,
        onTap: (index) {
          setState(() {
            recruiterTab = index;
          });
        },
        selectedItemColor:
            ColorHelperClass.getColorFromHex(ColorResources.red_color),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.business_center), label: "Posted Jobs"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Post Job"),
        ],
      ),
    );
  }

  Widget _buildPostedJobs() {
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
          // onTap: () {
          //   setState(() {
          //     selectedJobTitleForMembers = job["title"];
          //   });
          // },
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
}
