import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/model/JobPortal/GetJobById/GetJobByIdData.dart';
import 'package:mpm/repository/JobPortal/GetJobByIdRepo/get_job_by_id_repository.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';

class JobDetailView extends StatefulWidget {
  final Map<String, dynamic> job;
  final String jobId;

  const JobDetailView({
    super.key,
    required this.job,
    required this.jobId,
  });

  @override
  State<JobDetailView> createState() => _JobDetailViewState();
}

class _JobDetailViewState extends State<JobDetailView> {
  final GetJobByIdRepository getJobByIdRepository = GetJobByIdRepository();

  File? cvFile;
  String? existingCvUrl;
  bool isApplied = false;
  bool cvUploaded = false;
  String uploadedCvName = "Manoj_CV.pdf";
  bool isLoadingJobDetail = false;
  String? jobDetailError;
  GetJobByIdData? jobDetailData;

  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    existingCvUrl =
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";
    _loadJobDetail();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadJobDetail() async {
    final jobId = widget.jobId.trim();
    if (jobId.isEmpty) {
      setState(() {
        jobDetailError = "Job id not found";
      });
      return;
    }

    try {
      setState(() {
        isLoadingJobDetail = true;
        jobDetailError = null;
      });

      final response = await getJobByIdRepository.getJobById(jobId);
      if (!mounted) return;

      if (response.status == true && response.data != null) {
        setState(() {
          jobDetailData = response.data;
        });
      } else {
        setState(() {
          jobDetailError = response.message ?? "Unable to fetch job detail";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        jobDetailError = "Unable to fetch job detail";
      });
      debugPrint("Get Job By Id Detail Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoadingJobDetail = false;
        });
      }
    }
  }

  void _openApplyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[100],
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.65,
          maxChildSize: 0.65,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  /// Header (Fixed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      children: [
                        /// Drag Handle
                        Container(
                          width: 45,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isApplied = true;
                                });

                                Navigator.pop(context);

                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Application Applied Successfully"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
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
                              child: const Text("Submit"),
                            ),
                          ],
                        ),
                        const Divider(),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  /// Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            "Enter your profile summary",
                            controller: descriptionController,
                            maxLines: 4,
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            "Upload CV",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (cvFile != null)
                            _buildCvPreview(
                              fileName: cvFile!.path.split('/').last,
                              isNetwork: false,
                              onReplace: () {
                                _showCvPickerOptions(context, (file) {
                                  setState(() => cvFile = file);
                                });
                              },
                              onView: () {
                                _showCvPreviewDialog(
                                  context,
                                  cvFile!.path,
                                  cvFile!.path.split('/').last,
                                );
                              },
                            )
                          else if (existingCvUrl != null &&
                              existingCvUrl!.isNotEmpty)
                            _buildCvPreview(
                              fileName: existingCvUrl!,
                              isNetwork: true,
                              onReplace: () {
                                _showCvPickerOptions(context, (file) {
                                  setState(() {
                                    cvFile = file;
                                    existingCvUrl = null;
                                  });
                                });
                              },
                              onView: () {
                                _showCvPreviewDialog(
                                  context,
                                  existingCvUrl!,
                                  existingCvUrl!.split('/').last,
                                );
                              },
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showCvPickerOptions(context, (file) {
                                    setState(() => cvFile = file);
                                  });
                                },
                                icon: const Icon(Icons.upload_file),
                                label: const Text("Upload CV *"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  ColorHelperClass.getColorFromHex(
                                      ColorResources.red_color),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCvPickerOptions(
    BuildContext context,
    Function(File) onFilePicked,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔹 HEADER
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Upload CV",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Divider(),

                /// 📷 CAMERA
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Colors.redAccent,
                  ),
                  title: const Text("Take a Picture"),
                  onTap: () async {
                    Navigator.pop(context);

                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      imageQuality: 70,
                    );

                    if (picked != null) {
                      onFilePicked(File(picked.path));
                    }
                  },
                ),

                /// 🖼 GALLERY
                ListTile(
                  leading: const Icon(
                    Icons.image,
                    color: Colors.redAccent,
                  ),
                  title: const Text("Choose from Gallery"),
                  onTap: () async {
                    Navigator.pop(context);

                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 70,
                    );

                    if (picked != null) {
                      onFilePicked(File(picked.path));
                    }
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCvPreview({
    required String fileName,
    required bool isNetwork,
    required VoidCallback onReplace,
    required VoidCallback onView,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.insert_drive_file, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(color: Colors.green),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility),
                  label: const Text("View"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onReplace,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Replace"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorHelperClass.getColorFromHex(
                        ColorResources.red_color),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCvPreviewDialog(
    BuildContext context,
    String filePath,
    String title,
  ) {
    bool isPdf = filePath.toLowerCase().endsWith(".pdf");

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: isPdf
                  ? const Center(
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: 80,
                        color: Colors.red,
                      ),
                    )
                  : filePath.startsWith("http")
                      ? Image.network(filePath, fit: BoxFit.contain)
                      : Image.file(File(filePath), fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
              ),
              child: const Text("Close"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = _buildDisplayJob();
    final jobSummaryFile = job["jobSummaryFile"];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          job["title"] ?? "Job Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoadingJobDetail)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(),
              ),
            if (jobDetailError != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  jobDetailError!,
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            Text(
              job["company"],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.location_on, "Location", job["location"]),
                  const Divider(),
                  _buildInfoRow(Icons.place, "Area", job["areaName"]),
                  const Divider(),
                  _buildInfoRow(Icons.currency_rupee, "Salary", job["salary"]),
                  const Divider(),
                  _buildInfoRow(Icons.work, "Experience", job["experience"]),
                  const Divider(),
                  _buildInfoRow(Icons.business_center, "Work Mode",
                      job["workMode"]),
                  const Divider(),
                  _buildInfoRow(Icons.schedule, "Job Type", job["workType"]),
                  const Divider(),
                  _buildInfoRow(
                    Icons.calendar_month,
                    "Last Apply Date",
                    job["lastApplyDate"],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Brief Job Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(job["description"] ?? ""),

            const SizedBox(height: 15),

            /// ✅ VIEW JOB SUMMARY BUTTON
            if (jobSummaryFile != null && jobSummaryFile.toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (jobSummaryFile is File) {
                        _showLocalDocumentPreviewDialog(
                          context,
                          jobSummaryFile,
                          "Job Description",
                        );
                      } else if (jobSummaryFile is String) {
                        _showCvPreviewDialog(
                          context,
                          _buildJobSummaryUrl(jobSummaryFile),
                          "Job Description",
                        );
                      }
                    },
                    label: const Text("View Job Description"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isApplied
                    ? null
                    : () {
                        _openApplyModal();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApplied ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isApplied ? "Applied" : "Apply Now",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.blue),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value.isNotEmpty ? value : "Not specified")),
      ],
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

  Map<String, dynamic> _buildDisplayJob() {
    final data = jobDetailData;
    final fallback = widget.job;

    return {
      "jobId": _firstValue(data?.jobId, fallback["jobId"]),
      "title": _firstValue(data?.title, fallback["title"], "Job Details"),
      "company": _firstValue(fallback["company"], null, "Company"),
      "location": _firstValue(data?.location, fallback["location"]),
      "areaName": _firstValue(data?.jobAreaName, fallback["areaName"]),
      "salary": _formatSalaryFromJobDetail(data) ??
          _firstValue(fallback["salary"], null, "Not disclosed"),
      "experience": _formatExperienceFromJobDetail(data) ??
          _firstValue(fallback["experience"], null, "Not specified"),
      "description": _firstValue(data?.description, fallback["description"]),
      "workMode": _firstValue(data?.workMode, fallback["workMode"]),
      "workType": _firstValue(data?.workType, fallback["workType"]),
      "noOfVacancy": _firstValue(data?.noOfVacancy, fallback["noOfVacancy"]),
      "lastApplyDate": _formatDate(_firstValue(
        data?.lastApplyDate,
        fallback["lastApplyDate"],
      )),
      "jobSummaryFile": _firstFileOrValue(
        data?.profileSummaryDocument,
        fallback["jobSummaryFile"],
      ),
    };
  }

  String _firstValue(
    dynamic first, [
    dynamic second,
    String fallbackValue = "",
  ]) {
    final firstText = first?.toString().trim() ?? "";
    if (firstText.isNotEmpty && firstText != "null") return firstText;

    final secondText = second?.toString().trim() ?? "";
    if (secondText.isNotEmpty && secondText != "null") return secondText;

    return fallbackValue;
  }

  dynamic _firstFileOrValue(dynamic first, dynamic second) {
    if (first is File) return first;
    if (second is File) return second;

    return _firstValue(first, second);
  }

  String _buildJobSummaryUrl(String jobSummaryFile) {
    final filePath = jobSummaryFile.trim();
    if (filePath.startsWith("http")) return filePath;

    return Urls.imagePathUrl + filePath.replaceFirst(RegExp(r'^/+'), '');
  }

  String _formatDate(String date) {
    if (date.length >= 10) return date.substring(0, 10);
    return date;
  }

  String? _formatSalaryFromJobDetail(GetJobByIdData? data) {
    if (data == null) return null;
    if (data.salaryVisible == "0") return "Not disclosed";

    final min = data.salaryMin?.toString().trim() ?? "";
    final max = data.salaryMax?.toString().trim() ?? "";

    if (min.isEmpty && max.isEmpty) return null;
    if (min.isNotEmpty && max.isNotEmpty) return "Rs. $min - $max LPA";
    return "Rs. ${min.isNotEmpty ? min : max} LPA";
  }

  String? _formatExperienceFromJobDetail(GetJobByIdData? data) {
    if (data == null) return null;

    final min = data.experienceMinYears?.toString().trim() ?? "";
    final max = data.experienceMaxYears?.toString().trim() ?? "";

    if (min.isEmpty && max.isEmpty) return null;
    if (min.isNotEmpty && max.isNotEmpty) return "$min-$max Years";
    return "${min.isNotEmpty ? min : max} Years";
  }

  void _showLocalDocumentPreviewDialog(
    BuildContext context,
    File file,
    String title,
  ) {
    bool isPdf = file.path.toLowerCase().endsWith(".pdf");

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 400,
                width: double.infinity,
                child: isPdf
                    ? const Center(
                        child: Icon(
                          Icons.picture_as_pdf,
                          size: 80,
                          color: Colors.red,
                        ),
                      )
                    : Image.file(
                        file,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Close"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
