import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/GetEventAttendeesDetailById/GetEventAttendeesDetailByIdData.dart';
import 'package:mpm/model/GetMemberRegisteredEvents/GetMemberRegisteredEventsData.dart';
import 'package:mpm/model/GetMemberRegisteredEvents/GetMemberRegisteredEventsModelClass.dart';
import 'package:mpm/model/UpdateEventByMember/UpdateEventByMemberModelClass.dart';
import 'package:mpm/model/UpdatePriceDistribution/UpdatePriceDistributionData.dart';
import 'package:mpm/repository/get_member_registered_events_repository/get_member_registered_events_repo.dart';
import 'package:mpm/repository/update_event_by_member_repository/update_event_by_member_repo.dart';
import 'package:mpm/repository/update_price_distribution_repository/update_price_distribution_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:dio/dio.dart';
import 'package:mpm/view/Events/event_view.dart';
import 'package:mpm/view/Events/member_registered_event.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mpm/utils/Session.dart';

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

class RegisteredEventsDetailPage extends StatefulWidget {
  final GetEventAttendeesDetailByIdData eventAttendee;

  const RegisteredEventsDetailPage({Key? key, required this.eventAttendee})
      : super(key: key);

  @override
  _RegisteredEventsDetailPageState createState() =>
      _RegisteredEventsDetailPageState();
}

class _RegisteredEventsDetailPageState
    extends State<RegisteredEventsDetailPage> {
  late Future<EventAttendeesModelClass> _registeredEventsFuture;
  UdateProfileController controller = Get.put(UdateProfileController());
  final EventAttendeesRepository _repository = EventAttendeesRepository();
  final CancelEventRepository _cancelRepo = CancelEventRepository();
  final RxList<UpdatePriceDistributionData> educationList = <UpdatePriceDistributionData>[].obs;

  final Rx<File?> _image = Rx<File?>(null);
  final RxString selectedMemberId = "".obs;
  final RxString selectedYear = ''.obs;

  bool _isLoading = false;
  bool _isPastEvent = false;
  int? _memberId;
  bool _isCancelled = false;

  String get _eventName =>
      widget.eventAttendee.event?.eventName ?? 'Registered Event Details';
  String? get _eventOrganiserName =>
      widget.eventAttendee.event?.eventOrganiserName;
  String? get _eventOrganiserMobile =>
      widget.eventAttendee.event?.eventOrganiserMobile;
  String? get _dateStartsFrom => widget.eventAttendee.event?.dateStartsFrom;
  String? get _dateEndTo => widget.eventAttendee.event?.dateEndTo;
  String? get _studentName => widget.eventAttendee.priceMember?.studentName;
  String? get _seatNo => widget.eventAttendee.seatAllotment?.seatNo;
  String? get _eventId => widget.eventAttendee.event?.eventId;
  String? existingMarksheetUrl;


  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  final TextEditingController standardController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();

  String memberName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchMemberId();
    _checkEventDate();
    _checkIfCancelled();
    _loadUserDataAndFetchEvents();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    try {
      if (widget.eventAttendee.priceMember?.markSheetAttachment != null &&
          widget.eventAttendee.priceMember!.markSheetAttachment!.isNotEmpty) {
        setState(() {
          existingMarksheetUrl = widget.eventAttendee.priceMember!.markSheetAttachment;
        });
      }
    } catch (e) {
      debugPrint("Error loading event details: $e");
    }
  }

  Future<void> _loadUserDataAndFetchEvents() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData != null) {
        final name = _getUserName(
            userData.firstName, userData.middleName, userData.lastName);

        setState(() {
          memberName = name;
          _registeredEventsFuture = _repository
              .fetchEventAttendeesByMemberId(
                  int.tryParse(userData.memberId.toString()) ?? 0)
              .then((response) {
            return response;
          });
        });
        return;
      }
      setState(() {
        _registeredEventsFuture = Future.error('User data not available');
      });
    } catch (e) {
      setState(() {
        _registeredEventsFuture = Future.error(e.toString());
      });
    }
  }

  String _getUserName(String? firstName, String? middleName, String? lastName) {
    final fName = firstName ?? '';
    final mName = middleName?.isNotEmpty == true ? ' $middleName ' : ' ';
    final lName = lastName ?? '';
    return '$fName$mName$lName'.trim();
  }

  void _checkIfCancelled() {
    setState(() {
      _isCancelled = widget.eventAttendee.cancelledDate != null &&
          widget.eventAttendee.cancelledDate!.isNotEmpty;
    });
  }

  Future<void> _showCancelConfirmationDialog() async {
    if (_isCancelled) {
      _showErrorSnackbar("Registration is already cancelled");
      return;
    }

    if (_isPastEvent) {
      _showErrorSnackbar("Cannot cancel registration for past events");
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cancel Registration",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: const Text(
            "Are you sure you want to cancel your registration for this event?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelEventRegistration();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
              ),
              child: const Text("Yes", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelEventRegistration() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData == null) throw Exception("User not logged in");
      if (_eventId == null) throw Exception("Event ID not available");

      final response = await _cancelRepo.cancelEventRegistration(
        memberId: userData.memberId.toString(),
        eventId: _eventId!,
      );

      final parsed = UpdateEventBYMemberModelClass.fromJson(response);

      if (parsed.status == true) {
        setState(() {
          _isCancelled = true;
          widget.eventAttendee.cancelledDate = DateTime.now().toIso8601String();
        });
        _showSuccessSnackbar("Cancelled this event registration successfully");
      } else {
        throw Exception("Failed to cancel this event registration");
      }
    } catch (e) {
      _showErrorSnackbar("Error: ${e.toString()}");
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => EventsPage()),
      );
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _updateStudentPrize() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData == null || userData.memberId == null) {
        throw Exception('User not logged in');
      }

      // Ensure record exists
      if (widget.eventAttendee.priceMember?.eventAttendeesPriceMemberId == null) {
        throw Exception('No existing student prize record found to update');
      }

      final updateData = {
        'event_attendees_price_member_id':
        widget.eventAttendee.priceMember!.eventAttendeesPriceMemberId,
        'event_attendees_id': widget.eventAttendee.eventAttendeesId,
        'event_id': widget.eventAttendee.event?.eventId,
        'member_id': widget.eventAttendee.memberId,
        'price_member_id': selectedMemberId.value,
        'student_name': studentNameController.text.trim(),
        'school_name': schoolNameController.text.trim(),
        'standard_passed': standardController.text.trim(),
        'year_of_passed': selectedYear.value,
        'grade': gradeController.text.trim(),
        'updated_by': userData.memberId.toString(),
        'mark_sheet_attachment': _image.value?.path ?? '',
      };

      debugPrint("Sending Student Prize Update: $updateData");

      final repository = UpdatePriceDistributionRepository();
      final response = await repository.updatePriceDistribution(updateData);

      if (response.status == true) {
        // ✅ Clear fields
        studentNameController.clear();
        schoolNameController.clear();
        standardController.clear();
        gradeController.clear();
        _image.value = null;
        selectedMemberId.value = "";

        await _showSuccessDialog(
          'Successfully updated Student Prize Distribution details',
        );

        // ✅ Close this page and tell previous screen to refresh
        Navigator.pop(context, true);
      } else {
        throw Exception(response.message ?? 'Failed to update');
      }
    } catch (e) {
      debugPrint("Error updating student prize: $e");
      await _showErrorDialog('Something went wrong please try again');
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Success",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Error",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchMemberId() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData != null && userData.memberId != null) {
        setState(() {
          _memberId = int.tryParse(userData.memberId.toString());
        });
      }
    } catch (e) {
      debugPrint("Error fetching member ID: $e");
    }
  }

  List<String> getLastTwoFinancialYears() {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;

    int startYear = month >= 4 ? year : year - 1;

    String previousFY1 = "${startYear - 2} - ${startYear - 1}";
    String previousFY2 = "${startYear - 1} - $startYear";

    return [previousFY1, previousFY2];
  }


  void _checkEventDate() {
    if (_dateEndTo == null) return;

    final eventDate = DateTime.tryParse(_dateEndTo!);
    if (eventDate != null) {
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      setState(() {
        _isPastEvent = eventDate.isBefore(todayMidnight);
      });
    }
  }

  bool get _hasStudentPrizeMember {
    final student = widget.eventAttendee.priceMember;
    if (student == null) return false;

    return student.studentName?.isNotEmpty == true ||
        student.schoolName?.isNotEmpty == true ||
        student.standardPassed?.isNotEmpty == true ||
        student.grade?.isNotEmpty == true ||
        student.yearOfPassed?.isNotEmpty == true;
  }

  Widget _buildEventInfo() {
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return 'Not Available';
      try {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
      } catch (_) {
        return 'Invalid Date';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registration Details:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow(
                "Registration Date",
                formatDate(widget.eventAttendee.registrationDate),
              ),
              if (_isCancelled && widget.eventAttendee.cancelledDate != null)
                _buildRow(
                  "Cancelled on",
                  formatDate(widget.eventAttendee.cancelledDate),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentPrizeCard() {
    final student = widget.eventAttendee.priceMember;

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    student?.studentName ?? "Not Available",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: (value) {
                    if (value == 'edit') {
                      studentNameController.text =
                          widget.eventAttendee.priceMember?.studentName ?? '';
                      schoolNameController.text =
                          widget.eventAttendee.priceMember?.schoolName ?? '';
                      standardController.text =
                          widget.eventAttendee.priceMember?.standardPassed ?? '';
                      gradeController.text =
                          widget.eventAttendee.priceMember?.grade ?? '';
                      selectedYear.value =
                          widget.eventAttendee.priceMember?.yearOfPassed ?? '';
                      _showEducationDetailsSheet(context);
                    } else if (value == 'delete') {
                      // Handle delete action
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        'Edit',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red),
                      ),
                    ),
                  ],
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFDC3545),
                      elevation: 4,
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              ],
            ),

            const Divider(color: Color(0xFFE0E0E0)),
            const SizedBox(height: 10),

            if ((student?.schoolName ?? '').isNotEmpty)
              _buildRow("School", student!.schoolName ?? "Not Available"),

            if ((student?.standardPassed ?? '').isNotEmpty)
              _buildRow("Standard", student!.standardPassed ?? "Not Available"),

            if ((student?.grade ?? '').isNotEmpty)
              _buildRow("Grade", student!.grade ?? "Not Available"),

            if ((student?.yearOfPassed ?? '').isNotEmpty)
              _buildRow("Year", student!.yearOfPassed ?? "Not Available"),
          ],
        ),
      ),
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
        if (_eventOrganiserName != null) ...[
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
                        text: _eventOrganiserName!
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
        if (_eventOrganiserMobile != null) ...[
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                _eventOrganiserMobile!,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              _eventName,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.eventAttendee.eventQrCode != null &&
                      widget.eventAttendee.eventQrCode!.isNotEmpty) ...[
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                                      widget.eventAttendee.eventQrCode!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(Icons.broken_image, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.eventAttendee.eventQrCode!,
                                height: 300,
                                width: 400, 
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                const Icon(Icons.qr_code, size: 80, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Scan this QR Code for Gate Pass Entry",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                  const Text(
                    'Attendee Details:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow("Name", memberName),
                        _buildRow(
                          "Reference Code",
                          widget.eventAttendee.eventAttendeesCode ??
                              "Not Available",
                        ),
                        _buildRow(
                          "Seat No",
                          _seatNo ?? "Not Allotted",
                        ),
                        _buildRow(
                          "No of Food Coupon",
                          widget.eventAttendee.noOfFoodContainer ?? "Not Allotted",
                        ),
                        _buildRow(
                          "Event Date",
                          _dateStartsFrom != null
                              ? DateFormat('dd MMM yyyy').format(
                                  DateTime.parse(_dateStartsFrom!),
                                )
                              : "Unknown Date",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildEventInfo(),
                  if (_hasStudentPrizeMember) ...[
                    const Divider(thickness: 1, color: Colors.grey),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Student Prize Member:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // studentNameController.text = widget.eventAttendee.priceMember?.studentName ?? '';
                            // schoolNameController.text = widget.eventAttendee.priceMember?.schoolName ?? '';
                            // standardController.text = widget.eventAttendee.priceMember?.standardPassed ?? '';
                            // gradeController.text = widget.eventAttendee.priceMember?.grade ?? '';
                            // selectedYear.value = widget.eventAttendee.priceMember?.yearOfPassed ?? '';
                            // _showEducationDetailsSheet(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFDC3545),
                            elevation: 4,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.add, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Add',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _buildStudentPrizeCard(),
                  ],
                  const SizedBox(height: 10),
                  if (_eventOrganiserName != null ||
                      _eventOrganiserMobile != null) ...[
                    const Divider(thickness: 1, color: Colors.grey),
                    const SizedBox(height: 16),
                    _buildOrganiserInfo(),
                    const SizedBox(height: 24),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
        bottomNavigationBar: _isCancelled || _isPastEvent
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorHelperClass.getColorFromHex(
                      ColorResources.red_color),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _showCancelConfirmationDialog();
                },
                child: const Text(
                  'Cancel Registration',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const Text(
            " : ",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEducationDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[100],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _updateStudentPrize();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Obx(() {
                        final familyList = controller.familyDataList;

                        if (familyList.isEmpty) {
                          return const Center(child: Text('No Members available'));
                        } else {
                          final selectedValue = selectedMemberId.value;

                          return Expanded(
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: selectedValue.isNotEmpty ? 'Select Children *' : null,
                                border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black38, width: 1)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                labelStyle: const TextStyle(color: Colors.black),
                              ),
                              child: DropdownButton<String>(
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                isExpanded: true,
                                underline: Container(),
                                hint: const Text('Select Children *', style: TextStyle(fontWeight: FontWeight.bold)),
                                value: selectedValue.isNotEmpty ? selectedValue : null,
                                items: familyList.map((member) {
                                  return DropdownMenuItem<String>(
                                    value: member.memberId.toString(),
                                    child: Text(
                                      "${member.firstName} ${member.middleName ?? ''} ${member.lastName}",
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    selectedMemberId.value = newValue;

                                    final selectedMember = familyList.firstWhereOrNull(
                                          (m) => m.memberId.toString() == newValue,
                                    );

                                    if (selectedMember != null) {
                                      final fullName = [
                                        selectedMember.firstName,
                                        selectedMember.middleName ?? "",
                                        selectedMember.lastName ?? ""
                                      ].where((name) => name.isNotEmpty).join(" ");
                                      studentNameController.text = fullName;
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        }
                      })
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                _buildTextField(
                    label: "School Name",
                    controller: schoolNameController,
                    type: TextInputType.text,
                    empty: "Enter school name"
                ),
                _buildTextField(
                    label: "Standard Passed",
                    controller: standardController,
                    type: TextInputType.text,
                    empty: "Enter standard"
                ),
                _buildTextField(
                    label: "Percentage of Marks or Grade",
                    controller: gradeController,
                    type: TextInputType.text,
                    empty: "Enter marks/grade"
                ),
                Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          final years = getLastTwoFinancialYears();
                          final selectedValue = selectedYear.value;

                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: selectedValue.isNotEmpty ? 'Year of Passing *' : null,
                              border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black38, width: 1)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              labelStyle: const TextStyle(color: Colors.black),
                            ),
                            child: DropdownButton<String>(
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              isExpanded: true,
                              underline: Container(),
                              hint: const Text('Year of Passing *', style: TextStyle(fontWeight: FontWeight.bold)),
                              value: selectedValue.isNotEmpty ? selectedValue : null,
                              items: years.map((year) {
                                return DropdownMenuItem<String>(
                                  value: year,
                                  child: Text(year),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  selectedYear.value = newValue;
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Obx(() {
                  return Column(
                    children: [
                      if (_image.value != null || existingMarksheetUrl != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _image.value != null
                                ? Image.file(_image.value!, fit: BoxFit.cover)
                                : Image.network(existingMarksheetUrl!, fit: BoxFit.cover),
                          ),
                        ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showImagePicker(context),
                          icon: const Icon(Icons.image),
                          label: Text(
                            existingMarksheetUrl != null && _image.value == null
                                ? "Change Mark Sheet"
                                : "Upload Mark Sheet",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImagePicker(BuildContext context) async {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text("Take a Picture"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  _image.value = File(pickedFile.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.redAccent),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  _image.value = File(pickedFile.path);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required TextInputType type,
    required String empty,
    bool readOnly = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: type,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          hintStyle: const TextStyle(color: Colors.black54),
          border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black38, width: 1)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return empty;
          return null;
        },
      ),
    );
  }

}
