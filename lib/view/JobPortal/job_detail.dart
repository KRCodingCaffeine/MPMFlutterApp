import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mpm/model/JobPortal/GetJobById/GetJobByIdData.dart';
import 'package:mpm/repository/JobPortal/MemberApplyJobRepo/member_apply_job_repository.dart';
import 'package:mpm/repository/JobPortal/GetJobByIdRepo/get_job_by_id_repository.dart';
import 'package:mpm/repository/JobPortal/GetSeekerResumeRepo/get_seeker_resume_repository.dart';
import 'package:mpm/repository/JobPortal/UploadResumeRepo/upload_resume_repository.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final Dio _dio = Dio();
  final GetJobByIdRepository getJobByIdRepository = GetJobByIdRepository();
  final GetSeekerResumeRepository getSeekerResumeRepository =
      GetSeekerResumeRepository();
  final UploadResumeRepository uploadResumeRepository =
      UploadResumeRepository();
  final MemberApplyJobRepository memberApplyJobRepository =
      MemberApplyJobRepository();

  File? cvFile;
  String? existingCvUrl;
  String? existingCvName;
  String memberCvDisplayName = "Member.CV";
  bool isApplied = false;
  bool isSubmittingApplication = false;
  bool isLoadingJobDetail = false;
  bool isLoadingSeekerResume = false;
  String? jobDetailError;
  String? seekerResumeError;
  GetJobByIdData? jobDetailData;

  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

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

  Future<void> _loadSeekerResume({VoidCallback? refreshModal}) async {
    try {
      setState(() {
        isLoadingSeekerResume = true;
        seekerResumeError = null;
      });
      refreshModal?.call();

      final session = await SessionManager.getSession();
      final memberId = session?.memberId?.toString().trim() ?? "";
      memberCvDisplayName = _buildMemberCvDisplayName(
        session?.firstName,
        session?.middleName,
        session?.lastName,
      );

      if (memberId.isEmpty) {
        setState(() {
          existingCvUrl = null;
          existingCvName = null;
          seekerResumeError = "Member id not found";
        });
        refreshModal?.call();
        return;
      }

      final response =
          await getSeekerResumeRepository.getSeekerResume(memberId);
      if (!mounted) return;

      final resumeUrl = _firstValue(
        response.data?.resumeUrl,
        response.data?.resumePath,
      );
      debugPrint("Seeker Resume URL: $resumeUrl");

      if (response.status == true && resumeUrl.isNotEmpty) {
        setState(() {
          existingCvUrl = resumeUrl;
          existingCvName = memberCvDisplayName;
        });
        refreshModal?.call();
      } else {
        setState(() {
          existingCvUrl = null;
          existingCvName = null;
          seekerResumeError = response.message ?? "Resume not found";
        });
        refreshModal?.call();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        existingCvUrl = null;
        existingCvName = null;
        seekerResumeError = "Unable to fetch resume";
      });
      refreshModal?.call();
      debugPrint("Get Seeker Resume Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoadingSeekerResume = false;
        });
        refreshModal?.call();
      }
    }
  }

  Future<void> _submitApplication({
    VoidCallback? refreshModal,
  }) async {
    if (isSubmittingApplication) return;

    try {
      setState(() {
        isSubmittingApplication = true;
      });
      refreshModal?.call();

      final session = await SessionManager.getSession();
      final memberId = session?.memberId?.toString().trim() ?? "";
      final jobId = _firstValue(jobDetailData?.jobId, widget.jobId);

      if (memberId.isEmpty) {
        _showSnackBar("Member ID is missing. Please login again", Colors.red);
        return;
      }

      if (jobId.isEmpty) {
        _showSnackBar("Job ID is missing", Colors.red);
        return;
      }

      String resumePath = existingCvUrl?.trim() ?? "";

      if (cvFile != null) {
        final uploadResponse = await uploadResumeRepository.uploadResume(
          memberId: memberId,
          filePath: cvFile!.path,
        );

        if (uploadResponse.status != true) {
          _showSnackBar(
            uploadResponse.message.isNotEmpty
                ? uploadResponse.message
                : "Unable to upload resume",
            Colors.red,
          );
          return;
        }

        resumePath = uploadResponse.data?.resumePath ?? resumePath;
      }

      if (resumePath.isEmpty) {
        _showSnackBar("Please upload resume", Colors.red);
        return;
      }

      final now = DateTime.now();
      final response = await memberApplyJobRepository.memberApplyJob({
        "member_id": memberId,
        "job_id": jobId,
        "application_status": "applied",
        "applied_date": _formatApiDate(now),
        "remarks": descriptionController.text.trim(),
        "created_by": memberId,
        "created_at": _formatApiDateTime(now),
      });

      if (!mounted) return;

      if (response.status == true) {
        setState(() {
          isApplied = true;
        });

        Navigator.pop(context);
        _showSnackBar(
          response.message ?? "Application Applied Successfully",
          Colors.green,
        );
        return;
      }

      _showSnackBar(
        response.message ?? "Unable to apply job",
        response.code == 409 ? Colors.orange : Colors.red,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString(), Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          isSubmittingApplication = false;
        });
        refreshModal?.call();
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void _openApplyModal() {
    bool resumeFetchStarted = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[100],
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            if (!resumeFetchStarted) {
              resumeFetchStarted = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadSeekerResume(refreshModal: () {
                  if (mounted && context.mounted) {
                    modalSetState(() {});
                  }
                });
              });
            }

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
                                  onPressed: isSubmittingApplication
                                      ? null
                                      : () {
                                          _submitApplication(
                                            refreshModal: () {
                                              if (mounted && context.mounted) {
                                                modalSetState(() {});
                                              }
                                            },
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
                                  child: isSubmittingApplication
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text("Submit"),
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
                                "Existing CV",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (isLoadingSeekerResume)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (cvFile != null)
                                _buildCvPreview(
                                  fileName: _fileNameFromPath(cvFile!.path),
                                  isNetwork: false,
                                  onReplace: () {
                                    _showCvPickerOptions(context, (file) {
                                      setState(() => cvFile = file);
                                      modalSetState(() {});
                                    });
                                  },
                                  onView: () {
                                    _showDocumentPreview(
                                      context,
                                      cvFile!.path,
                                      memberCvDisplayName,
                                    );
                                  },
                                )
                              else if (existingCvUrl != null &&
                                  existingCvUrl!.isNotEmpty)
                                _buildCvPreview(
                                  fileName: existingCvName ?? existingCvUrl!,
                                  isNetwork: true,
                                  onReplace: () {
                                    _showCvPickerOptions(context, (file) {
                                      setState(() {
                                        cvFile = file;
                                        existingCvUrl = null;
                                      });
                                      modalSetState(() {});
                                    });
                                  },
                                  onView: () {
                                    _showDocumentPreview(
                                      context,
                                      existingCvUrl!,
                                      existingCvName ?? memberCvDisplayName,
                                    );
                                  },
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (seekerResumeError != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          seekerResumeError!,
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                      ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          _showCvPickerOptions(context, (file) {
                                            setState(() => cvFile = file);
                                            modalSetState(() {});
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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

                /// PDF
                ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                  ),
                  title: const Text("Choose PDF"),
                  onTap: () async {
                    Navigator.pop(context);

                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );

                    if (result != null && result.files.single.path != null) {
                      onFilePicked(
                        File(result.files.single.path!),
                      );
                    }
                  },
                ),

                /// WORD DOCUMENT
                ListTile(
                  leading: const Icon(
                    Icons.description,
                    color: Colors.blue,
                  ),
                  title: const Text("Choose Word Document"),
                  onTap: () async {
                    Navigator.pop(context);

                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['doc', 'docx'],
                    );

                    if (result != null && result.files.single.path != null) {
                      onFilePicked(
                        File(result.files.single.path!),
                      );
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

  void _showDocumentPreview(
    BuildContext context,
    String filePath,
    String title,
  ) {
    final viewPath = _resolveDocumentPathForView(filePath);
    final extension = _fileExtension(viewPath);
    debugPrint("Opening Document URL: $viewPath");

    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      _showImagePreviewDialog(context, viewPath, title);
      return;
    }

    if (['pdf', 'docx', 'doc'].contains(extension)) {
      if (viewPath.startsWith("http")) {
        _downloadAndOpenDocument(viewPath, title, extension);
      } else {
        OpenFilex.open(viewPath);
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Unsupported file format"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showImagePreviewDialog(
    BuildContext context,
    String filePath,
    String title,
  ) {
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
              height: 400,
              width: double.infinity,
              child: InteractiveViewer(
                child: filePath.startsWith("http")
                    ? Image.network(
                        filePath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text("Failed to load image"),
                        ),
                      )
                    : Image.file(
                        File(filePath),
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
              ),
              child: const Text("Close"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAndOpenDocument(
    String url,
    String title,
    String extension,
  ) async {
    final permissionStatus = await _requestPermission();
    if (!permissionStatus) return;

    try {
      Directory? directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      if (directory == null) {
        throw Exception("Storage directory not found");
      }

      final safeTitle = title
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
          .replaceAll(RegExp(r'\s+'), '_');
      final fileName = "$safeTitle.$extension";
      final filePath = "${directory.path}/$fileName";

      await _showDownloadProgressDialog(
        url: url,
        filePath: filePath,
        fileName: fileName,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  Future<void> _showDownloadProgressDialog({
    required String url,
    required String filePath,
    required String fileName,
  }) async {
    int downloadProgress = 0;
    bool downloadStarted = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            if (!downloadStarted) {
              downloadStarted = true;
              Future.microtask(() async {
                try {
                  await _dio.download(
                    url,
                    filePath,
                    onReceiveProgress: (received, total) {
                      if (total > 0) {
                        final newProgress = ((received / total) * 100).toInt();
                        setLocalState(() {
                          downloadProgress = newProgress;
                        });
                      }
                    },
                  );

                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  _showDownloadDialog(context, fileName, filePath);
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Download failed: $e")),
                  );
                }
              });
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: downloadProgress / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorHelperClass.getColorFromHex(
                        ColorResources.red_color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Downloading... $downloadProgress%",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDownloadDialog(
    BuildContext context,
    String fileName,
    String filePath,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            "Download Complete",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text("$fileName has been downloaded successfully."),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
              ),
              child: const Text("Close"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                OpenFilex.open(filePath);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("View"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        return true;
      }

      final status = await Permission.storage.request();
      if (status.isGranted) return true;

      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Storage permission is needed to download the file."),
        ),
      );
      return false;
    }

    return true;
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
                  _buildInfoRow(
                      Icons.business_center, "Work Mode", job["workMode"]),
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
                        _showDocumentPreview(
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
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          color: Colors.white,
          child: SizedBox(
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
          ),
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
    return _buildPublicFileUrl(jobSummaryFile);
  }

  String _buildPublicFileUrl(String filePath) {
    final path = filePath.trim();
    if (path.startsWith("http")) return path;

    return Urls.imagePathUrl + path.replaceFirst(RegExp(r'^/+'), '');
  }

  String _fileNameFromPath(String path) {
    return path.split(RegExp(r'[\\/]')).last;
  }

  String _buildMemberCvDisplayName(
    String? firstName,
    String? middleName,
    String? lastName,
  ) {
    final memberName = [
      firstName,
      middleName,
      lastName,
    ]
        .map((name) => name?.trim() ?? "")
        .where((name) => name.isNotEmpty && name != "null")
        .join(" ");

    return "${memberName.isNotEmpty ? memberName : "Member"}.CV";
  }

  String _fileExtension(String path) {
    final cleanPath = path.split("?").first;
    final extension = cleanPath.split(".").last.toLowerCase();
    return extension == cleanPath.toLowerCase() ? "" : extension;
  }

  String _formatApiDate(DateTime dateTime) {
    return [
      dateTime.year.toString().padLeft(4, '0'),
      dateTime.month.toString().padLeft(2, '0'),
      dateTime.day.toString().padLeft(2, '0'),
    ].join("-");
  }

  String _formatApiDateTime(DateTime dateTime) {
    final date = _formatApiDate(dateTime);
    final time = [
      dateTime.hour.toString().padLeft(2, '0'),
      dateTime.minute.toString().padLeft(2, '0'),
      dateTime.second.toString().padLeft(2, '0'),
    ].join(":");

    return "$date $time";
  }

  String _resolveDocumentPathForView(String path) {
    final cleanPath = path.trim();
    if (cleanPath.startsWith("http")) return cleanPath;
    if (File(cleanPath).existsSync()) return cleanPath;

    return Urls.base_url + cleanPath.replaceFirst(RegExp(r'^/+'), '');
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
