import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/EventTripModel/GetEventTripDetailsById/GetEventTripDetailsByIdData.dart';
import 'package:mpm/model/EventTripModel/TripMemberRegistration/TripMemberRegistrationData.dart';
import 'package:mpm/repository/EventTripRepository/get_event_trip_details_by_id_repository/get_event_trip_details_by_id_repo.dart';
import 'package:mpm/repository/EventTripRepository/member_register_trip_repository/member_register_trip_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:dio/dio.dart';
import 'package:mpm/view/EventTrip/add_trip_member_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class TripDetailPage extends StatefulWidget {
  final String tripId;

  const TripDetailPage({Key? key, required this.tripId}) : super(key: key);

  @override
  _TripDetailPageState createState() => _TripDetailPageState();
}

Future<Size> _getImageSize(String imageUrl) async {
  final Completer<Size> completer = Completer();
  final Image image = Image.network(imageUrl);
  image.image.resolve(const ImageConfiguration()).addListener(
    ImageStreamListener((ImageInfo info, bool _) {
      final myImage = info.image;
      completer
          .complete(Size(myImage.width.toDouble(), myImage.height.toDouble()));
    }),
  );
  return completer.future;
}

class _TripDetailPageState extends State<TripDetailPage> {
  final Dio _dio = Dio();
  final GetEventTripDetailByIdRepository _tripDetailRepo =
  GetEventTripDetailByIdRepository();

  bool _isLoading = true;
  bool _isDownloading = false;
  int _downloadProgress = 0;
  bool _isRegistering = false;
  bool _isRegistered = false;
  bool _isPastTrip = false;
  GetEventTripDetailsByIdData? _tripDetails;

  @override
  void initState() {
    super.initState();
    _fetchTripDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchTripDetails() async {
    try {
      final response = await _tripDetailRepo.EventTripDetailById(widget.tripId);
      if (response['status'] == true && response['data'] != null) {
        setState(() {
          _tripDetails = GetEventTripDetailsByIdData.fromJson(response['data']);
          _isLoading = false;
          _checkTripDate();
          _checkRegistrationStatus();
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load trip details')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading trip details: $e')),
      );
    }
  }

  void _checkTripDate() {
    if (_tripDetails?.tripEndDate == null) return;

    final tripDate = DateTime.tryParse(_tripDetails!.tripEndDate!);
    if (tripDate != null) {
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      setState(() {
        _isPastTrip = tripDate.isBefore(todayMidnight);
      });
    }
  }

  Future<void> _checkRegistrationStatus() async {
    setState(() {
      _isRegistered = false;
    });
  }

  Future<void> _showRegistrationConfirmationDialog() async {
    bool shouldProceed = await _showFinalConfirmationDialog();
    if (!shouldProceed) return;

    // Show second confirmation dialog
    bool addMembers = await _showAddMembersConfirmationDialog();

    if (addMembers) {
      // User wants to add members, redirect to member addition page
      await _redirectToAddMembersPage();
    } else {
      // User doesn't want to add members, just register for trip
      _registerForTrip();
    }
  }

  Future<bool> _showFinalConfirmationDialog() async {
    final shouldProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Confirm Registration",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
            "Are you sure you want to register for this trip?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
              ),
              child: const Text(
                "Yes, Register",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    return shouldProceed ?? false;
  }

  Future<bool> _showAddMembersConfirmationDialog() async {
    final addMembers = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Add Members",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
            "Are you sure you want to add members to the journey with you?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
              ),
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    return addMembers ?? false;
  }

  Future<void> _redirectToAddMembersPage() async {
    try {
      final userData = await SessionManager.getSession();

      if (userData != null && _tripDetails != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripMembersFormPage(
              tripId: int.parse(_tripDetails!.tripId!),
              memberId: int.tryParse(userData.memberId.toString())!,
            ),
          ),
        );
      }
    } catch (e) {
      await _showErrorDialog('Failed to redirect: ${e.toString()}');
    }
  }

  Future<void> _registerForTrip() async {
    if (_isRegistering || _isRegistered || _tripDetails == null) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      final userData = await SessionManager.getSession();
      final memberId = userData?.memberId;

      if (memberId == null) {
        throw Exception("Member info not found");
      }

      final memberName = [
        userData?.firstName,
        userData?.middleName,
        userData?.lastName
      ].where((element) => element != null && element.isNotEmpty)
          .join(" ");

      final registrationData = TripMemberRegistrationData(
        memberId: memberId.toString(),
        tripId: _tripDetails!.tripId.toString(),
        addedBy: memberId.toString(),
        travellerNames: [memberName],
      );

      final repo = TripMemberRegistrationRepository();
      final response = await repo.registerForTrip(registrationData);

      if (response['status'] == true) {
        setState(() {
          _isRegistered = true;
        });

        await _showSuccessDialog(
          response['message'] ?? 'Successfully registered for this trip',
        );
      } else if (response['already_registered'] == true) {
        await _showAlreadyRegisteredDialog(
          response['message'] ?? 'You are already registered',
        );
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      await _showErrorDialog('Registration failed: ${e.toString()}');
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  Future<void> _showAlreadyRegisteredDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Already Registered",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isRegistered = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Success",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _redirectToTripsList();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Error",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: const Text(
            "Something went wrong. Please try again later.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _redirectToTripsList() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // Widget _buildTripInfoList() {
  //   final slots = _tripDetails?.allEventDates ?? [];
  //
  //   String formatDate(String? dateStr) {
  //     if (dateStr == null || dateStr.isEmpty) return 'Unknown Date';
  //     try {
  //       return DateFormat('EEEE, MMMM d, y').format(DateTime.parse(dateStr));
  //     } catch (_) {
  //       return 'Invalid Date';
  //     }
  //   }
  //
  //   String formatTime(String? timeStr) {
  //     if (timeStr == null || timeStr.isEmpty) return '';
  //     try {
  //       final parsedTime = DateFormat("HH:mm:ss").parse(timeStr);
  //       return DateFormat("h:mm a").format(parsedTime);
  //     } catch (_) {
  //       return '';
  //     }
  //   }
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Trip Date & Time:',
  //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //       ),
  //       ...slots.map((slot) {
  //         return Container(
  //           margin: const EdgeInsets.symmetric(vertical: 4),
  //           padding: const EdgeInsets.all(12),
  //           child: Row(
  //             children: [
  //               const Icon(Icons.calendar_today, size: 18, color: Colors.black),
  //               const SizedBox(width: 10),
  //               Expanded(
  //                 child: Wrap(
  //                   crossAxisAlignment: WrapCrossAlignment.center,
  //                   children: [
  //                     Text(
  //                       formatDate(slot.eventDate),
  //                       style: const TextStyle(fontWeight: FontWeight.w600),
  //                     ),
  //                     if (slot.eventStartTime != null &&
  //                         slot.eventStartTime!.isNotEmpty) ...[
  //                       const SizedBox(width: 6),
  //                       const Text('from ',
  //                           style: TextStyle(color: Colors.grey)),
  //                       Text(formatTime(slot.eventStartTime)),
  //                     ],
  //                     if (slot.eventEndTime != null &&
  //                         slot.eventEndTime!.isNotEmpty) ...[
  //                       const SizedBox(width: 6),
  //                       const Text('to ', style: TextStyle(color: Colors.grey)),
  //                       Text(formatTime(slot.eventEndTime)),
  //                     ],
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       }).toList(),
  //     ],
  //   );
  // }

  Widget _buildTripCostInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trip Cost:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        if (_tripDetails?.tripCostType != null &&
            _tripDetails!.tripCostType!.isNotEmpty) ...[
          Row(
            children: [
              const Text(
                'Contact organisers for more details.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
        if (_tripDetails?.tripAmount != null &&
            _tripDetails!.tripAmount!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Amount: ₹${_tripDetails!.tripAmount!}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRegisterButton() {
    if (_isPastTrip) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRegistered
                ? Colors.redAccent
                : ColorHelperClass.getColorFromHex(ColorResources.red_color),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _isRegistered ? null : _showRegistrationConfirmationDialog,
          child: _isRegistering
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Text(
            _isRegistered ? "Registered" : "Register Here",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        return true;
      } else if (sdkInt >= 30) {
        var status = await Permission.storage.request();
        if (status.isGranted) return true;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('Storage permission is needed to download the file.')),
        );
        return false;
      } else {
        var status = await Permission.storage.request();
        if (status.isGranted) return true;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('Storage permission is needed to download the file.')),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _downloadAndOpenPdf(String url, String fileName) async {
    final permissionStatus = await _requestPermission();
    if (!permissionStatus) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      Directory? directory = Platform.isAndroid
          ? (await getExternalStorageDirectory())!
          : await getApplicationDocumentsDirectory();

      String filePath = "${directory!.path}/$fileName";

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            int newProgress = ((received / total) * 100).toInt();
            setState(() {
              _downloadProgress = newProgress;
            });
          }
        },
      );

      setState(() {
        _isDownloading = false;
      });

      _showDownloadDialog(context, fileName, filePath);
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  void _showDownloadDialog(
      BuildContext context, String fileName, String filePath) {
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
            children: [
              const Text(
                "Download Complete",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),
          content: Text(
            "$fileName has been downloaded successfully.",
            style: const TextStyle(
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
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("View"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrganiserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Coordinator Details:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        if (_tripDetails?.tripOrganiserName != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.person, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Coordinator: ',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      TextSpan(
                        text: _tripDetails!.tripOrganiserName!
                            .split(',')
                            .map((name) => name.trim())
                            .join(', '),
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (_tripDetails?.tripOrganiserMobile != null) ...[
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                _tripDetails!.tripOrganiserMobile!,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSamitiOrganisers() {
    if (_tripDetails?.samitiOrganisers == null ||
        _tripDetails!.samitiOrganisers!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Organised By:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        ..._tripDetails!.samitiOrganisers!.map((organiser) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.groups, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    organiser.subCategory?.samitiSubCategoryName ?? 'Unknown Samiti',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor:
          ColorHelperClass.getColorFromHex(ColorResources.logo_color),
          title: const Text('Trip Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_tripDetails == null) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor:
          ColorHelperClass.getColorFromHex(ColorResources.logo_color),
          title: const Text('Trip Details'),
        ),
        body: const Center(child: Text('Failed to load trip details')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              _tripDetails!.tripName ?? 'Trip Details',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_tripDetails!.tripImage != null &&
                _tripDetails!.tripImage!.isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.black,
                      insetPadding: const EdgeInsets.all(10),
                      child: InteractiveViewer(
                        panEnabled: true,
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.network(
                          _tripDetails!.tripImage!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child:
                            Icon(Icons.broken_image, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 500,
                        maxWidth: 400,
                      ),
                      child: FutureBuilder<Size>(
                        future: _getImageSize(_tripDetails!.tripImage!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else if (snapshot.hasError || !snapshot.hasData) {
                            return const SizedBox.shrink();
                          } else {
                            final imageSize = snapshot.data!;
                            final isLandscape =
                                imageSize.width > imageSize.height;

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _tripDetails!.tripImage!,
                                fit: isLandscape
                                    ? BoxFit.fitWidth
                                    : BoxFit.cover,
                                width: double.infinity,
                                height: isLandscape ? 250 : null,
                                errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 80),
                              ),
                            );
                          }
                        },
                      )),
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Trip Description:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _tripDetails!.tripDescription ??
                  'No trip description available',
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
            // const SizedBox(height: 24),
            // _buildTripInfoList(),
            const SizedBox(height: 24),
            if (_tripDetails!.tripCostType?.toLowerCase() != 'free') ...[
              _buildTripCostInfo(),
              const SizedBox(height: 24),
            ],
            if (_tripDetails!.tripOrganiserName != null ||
                _tripDetails!.tripOrganiserMobile != null) ...[
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 16),
              _buildOrganiserInfo(),
              const SizedBox(height: 16),
            ],
            _buildSamitiOrganisers(),
            if (_tripDetails!.tripTermsAndConditions != null &&
                _tripDetails!.tripTermsAndConditions!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Trip Document:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final docUrl = _tripDetails!.tripTermsAndConditions!;
                  final fileExtension = docUrl.split('.').last.toLowerCase();

                  if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: InteractiveViewer(
                                child: Image.network(
                                  docUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Center(
                                      child: Text('Failed to load image')),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          docUrl,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    );
                  } else if (['pdf', 'docx'].contains(fileExtension)) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        icon: Icon(
                          fileExtension == 'pdf'
                              ? Icons.picture_as_pdf
                              : Icons.description,
                          color:
                          fileExtension == 'pdf' ? Colors.red : Colors.blue,
                        ),
                        label: _isDownloading
                            ? LinearProgressIndicator(
                          value: _downloadProgress / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                          ),
                        )
                            : Text(
                            "Download & View ${fileExtension.toUpperCase()}"),
                        onPressed: _isDownloading
                            ? null
                            : () => _downloadAndOpenPdf(
                          docUrl,
                          'Trip_Terms_${_tripDetails!.tripId}.$fileExtension',
                        ),
                      ),
                    );
                  } else {
                    return const Text(
                      "Unsupported file format",
                      style: TextStyle(color: Colors.red),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar:
      _isPastTrip ? const SizedBox.shrink() : _buildRegisterButton(),
    );
  }
}