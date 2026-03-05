import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mpm/repository/JobPortal/JobPortalRoleRepo/update_job_portal_role_repository.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/JobPortal/job_seeker_view.dart';
import 'package:mpm/view/JobPortal/recruiter_job_view.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class JobView extends StatefulWidget {
  const JobView({super.key});

  @override
  State<JobView> createState() => _JobViewState();
}

class _JobViewState extends State<JobView> {
  final UpdateJobPortalRoleRepository repository =
      UpdateJobPortalRoleRepository();
  final UdateProfileController profileController =
      Get.find<UdateProfileController>();

  bool isLoading = false;

  Future<void> updateRole(String role) async {
    try {
      setState(() {
        isLoading = true;
      });

      String memberId = profileController.memberId.value;

      final body = {"member_id": memberId, "job_portal_role": role};

      final response = await repository.updateJobPortalRole(body);

      if (response.status == true) {
        debugPrint("✅ Role Updated: ${response.message}");
      } else {
        debugPrint("Failed: ${response.message}");
      }
    } catch (e) {
      debugPrint("API Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          "Job",
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
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
                          ),
                          onPressed: () async {
                            await updateRole("job_seeker");

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const JobSeekerView(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.search),
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
                          onPressed: () async {
                            await updateRole("recruiter");

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RecruiterJobView(),
                              ),
                            );
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
                            side: const BorderSide(
                                color: Colors.redAccent, width: 1.5),
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
            ),
    );
  }
}
