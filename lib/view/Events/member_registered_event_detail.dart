import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/GetEventAttendeesDetailById/GetEventAttendeesDetailByIdData.dart';
import 'package:mpm/model/GetMemberRegisteredEvents/GetMemberRegisteredEventsData.dart';
import 'package:mpm/model/GetMemberRegisteredEvents/GetMemberRegisteredEventsModelClass.dart';
import 'package:mpm/model/UpdateEventByMember/UpdateEventByMemberModelClass.dart';
import 'package:mpm/repository/get_member_registered_events_repository/get_member_registered_events_repo.dart';
import 'package:mpm/repository/update_event_by_member_repository/update_event_by_member_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:dio/dio.dart';
import 'package:mpm/view/Events/event_view.dart';
import 'package:mpm/view/Events/member_registered_event.dart';
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
  final Dio _dio = Dio();
  late Future<EventAttendeesModelClass> _registeredEventsFuture;
  final EventAttendeesRepository _repository = EventAttendeesRepository();
  final CancelEventRepository _cancelRepo = CancelEventRepository();

  bool _isLoading = false;
  bool _isDownloading = false;
  int _downloadProgress = 0;
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

  String memberName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchMemberId();
    _checkEventDate();
    _checkIfCancelled();
    _loadUserDataAndFetchEvents();
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

    // Check if any of the student fields have actual data (not null or empty)
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
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow("Student Name", student?.studentName ?? "Not Available"),
            _buildRow("School", student?.schoolName ?? "Not Available"),
            _buildRow("Standard", student?.standardPassed ?? "Not Available"),
            _buildRow("Grade", student?.grade ?? "Not Available"),
            _buildRow("Year", student?.yearOfPassed ?? "Not Available"),
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
                    const Text(
                      'Event QR Code:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                                  child: Icon(Icons.broken_image,
                                      color: Colors.white),
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
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.qr_code,
                              size: 80,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentPrizeFormPage(
                                  eventId: widget.eventId,
                                  attendeeId: widget.attendeeId,
                                  memberId: widget.memberId,
                                  addedBy: widget.addedBy,
                                  existingData: edu,
                                ),
                              ),
                            );
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
                              Icon(Icons.edit, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Edit',
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
}
