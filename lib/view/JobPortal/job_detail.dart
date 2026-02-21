import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class JobDetailView extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailView({super.key, required this.job});

  @override
  State<JobDetailView> createState() => _JobDetailViewState();
}

class _JobDetailViewState extends State<JobDetailView> {
  File? cvFile;
  String? existingCvUrl;
  bool isApplied = false;
  bool cvUploaded = false;
  String uploadedCvName = "Manoj_CV.pdf";

  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    existingCvUrl =
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";
  }

  void _openApplyModal() {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorHelperClass.getColorFromHex(
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

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Application Applied Successfully"),
                                backgroundColor: Colors.green),
                          );
                        },
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
                  const SizedBox(height: 30),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildTextField(
                            "Enter your profile summary",
                            controller: descriptionController,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "Upload CV",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
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
                                ),
                              ),
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
  }

  void _showCvPickerOptions(BuildContext context, Function(File) onPicked) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text("Take a Photo"),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (picked != null) {
                  onPicked(File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.redAccent),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  onPicked(File(picked.path));
                }
              },
            ),
          ],
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
    final job = widget.job;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          widget.job["title"] ?? "Job Details",
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
            Text(
              job["title"],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              job["company"],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.location_on, "Location", job["location"]),
                  const Divider(),
                  _buildInfoRow(Icons.currency_rupee, "Salary", job["salary"]),
                  const Divider(),
                  _buildInfoRow(Icons.work, "Experience", job["experience"]),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Profile Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(job["description"]),
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
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildTextField(String label,
      {int maxLines = 1, TextEditingController? controller}) {
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
