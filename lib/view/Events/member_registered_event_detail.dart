import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/GetEventAttendeesDetailById/GetEventAttendeesDetailByIdData.dart';
import 'package:mpm/model/GetEventDetailsById/GetEventDetailsByIdData.dart';
import 'package:mpm/model/GetMemberRegisteredEvents/GetMemberRegisteredEventsModelClass.dart';
import 'package:mpm/model/StudentPrizeRegistration/StudentPrizeRegistrationData.dart';
import 'package:mpm/model/UpdateEventByMember/UpdateEventByMemberModelClass.dart';
import 'package:mpm/model/UpdatePriceDistribution/UpdatePriceDistributionData.dart';
import 'package:mpm/repository/delete_price_distribution_repository/delete_price_distribution_repo.dart';
import 'package:mpm/repository/get_even_details_by_id_repository/get_even_details_by_id_repo.dart';
import 'package:mpm/repository/get_member_registered_events_repository/get_member_registered_events_repo.dart';
import 'package:mpm/repository/student_prize_registration_repository/student_prize_registration_repo.dart';
import 'package:mpm/repository/update_event_by_member_repository/update_event_by_member_repo.dart';
import 'package:mpm/repository/update_food_container_reposiory/update_food_container_repo.dart';
import 'package:mpm/repository/update_price_distribution_repository/update_price_distribution_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/Events/event_view.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
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
  final GetEventDetailByIdRepository _eventDetailRepo =
      GetEventDetailByIdRepository();
  final RxList<UpdatePriceDistributionData> educationList =
      <UpdatePriceDistributionData>[].obs;
  final StudentPrizeRegistrationRepository repo = StudentPrizeRegistrationRepository();

  final Rx<File?> _image = Rx<File?>(null);
  final RxString selectedMemberId = "".obs;
  final RxString selectedYear = ''.obs;

  bool _isLoading = false;
  bool _isPastEvent = false;
  int? _memberId;
  bool _isCancelled = false;
  Map<String, dynamic>? _userData;

  String get _eventName =>
      widget.eventAttendee.event?.eventName ?? 'Registered Event Details';
  String? get _eventOrganiserName =>
      widget.eventAttendee.event?.eventOrganiserName;
  String? get _eventOrganiserMobile =>
      widget.eventAttendee.event?.eventOrganiserMobile;
  String? get _dateStartsFrom => widget.eventAttendee.event?.dateStartsFrom;
  String? get _dateEndTo => widget.eventAttendee.event?.dateEndTo;
  String? get _studentName =>
      widget.eventAttendee.priceMembersList?.isNotEmpty == true
          ? widget.eventAttendee.priceMembersList!.first.studentName
          : null;
  String? get _seatNo => widget.eventAttendee.seatAllotment?.seatNo;
  String? get _eventId => widget.eventAttendee.event?.eventId;
  String? existingMarksheetUrl;
  GetEventDetailsByIdData? _eventDetails;

  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  final TextEditingController standardController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();

  String memberName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
    _fetchMemberId();
    _checkEventDate();
    _checkIfCancelled();
    _loadUserDataAndFetchEvents();
    _loadEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    try {
      final eventId = widget.eventAttendee.event?.eventId;
      if (eventId == null || eventId.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await _eventDetailRepo.EventsDetailById(eventId);
      if (response['status'] == true && response['data'] != null) {
        setState(() {
          _eventDetails = GetEventDetailsByIdData.fromJson(response['data']);
          _isLoading = false;
          _checkEventDate();
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load event details')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading event details: $e')),
      );
    }
  }

  Future<void> _loadEventDetails() async {
    try {
      if (widget.eventAttendee.priceMembersList?.isNotEmpty == true) {
        final student = widget.eventAttendee.priceMembersList!.first;
        if (student.markSheetAttachment != null &&
            student.markSheetAttachment!.isNotEmpty) {
          existingMarksheetUrl = student.markSheetAttachment;
        }
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
      if (widget.eventAttendee.priceMembersList?.isNotEmpty == true &&
          widget.eventAttendee.priceMembersList!.first
                  .eventAttendeesPriceMemberId ==
              null) {
        throw Exception('No existing student prize record found to update');
      }

      final updateData = {
        'event_attendees_price_member_id':
            widget.eventAttendee.priceMembersList?.isNotEmpty == true
                ? widget.eventAttendee.priceMembersList!.first
                    .eventAttendeesPriceMemberId
                : null,
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
        studentNameController.clear();
        schoolNameController.clear();
        standardController.clear();
        gradeController.clear();
        _image.value = null;
        selectedMemberId.value = "";

        await _showSuccessDialog(
          'Successfully updated Student Prize Distribution details',
        );

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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
                foregroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
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
    if (widget.eventAttendee.event?.eventsTypeId != "3") return false;

    final students = widget.eventAttendee.priceMembersList;

    if (students == null || students.isEmpty) {
      return true;
    }

    final student = students.first;
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

  /// Build cards for multiple student prize members
  Widget _buildStudentPrizeCards() {
    final students = widget.eventAttendee.priceMembersList ?? [];

    if (students == null || students.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No Student detail added yet...',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      children: students.map((student) {
        return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        student.studentName ?? "Not Available",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          studentNameController.text =
                              student.studentName ?? '';
                          schoolNameController.text = student.schoolName ?? '';
                          standardController.text =
                              student.standardPassed ?? '';
                          gradeController.text = student.grade ?? '';
                          selectedYear.value = student.yearOfPassed ?? '';
                          _showEducationDetailsSheet(context, student);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, student);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            'Edit',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.red),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFFE0E0E0)),
                const SizedBox(height: 10),
                if ((student.schoolName ?? '').isNotEmpty)
                  _buildRow("School", student.schoolName!),
                if ((student.standardPassed ?? '').isNotEmpty)
                  _buildRow("Standard", student.standardPassed!),
                if ((student.grade ?? '').isNotEmpty)
                  _buildRow("Grade", student.grade!),
                if ((student.yearOfPassed ?? '').isNotEmpty)
                  _buildRow("Year", student.yearOfPassed!),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, PriceMember? student) async {
    if (student == null) return;

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
                "Delete Confirmation",
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
            "Are you sure you want to delete this student’s details?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC3545),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteStudent(student);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3545),
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

  void _deleteStudent(PriceMember student) async {
    if (student.eventAttendeesPriceMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid student record, cannot delete.')),
      );
      return;
    }

    final repository = DeletePriceDistributionRepository();

    try {
      final response = await repository.deletePriceDistribution(
        student.eventAttendeesPriceMemberId,
      );

      if (response.status == true) {
        debugPrint(
            'Deleted student: ${student.studentName}, Deleted ID: ${response.data?.deletedId}');

        Get.snackbar(
          'Success',
          'Student deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Navigator.pop(context, true);
      } else {
        throw Exception(response.message ?? 'Failed to delete student');
      }
    } catch (e) {
      debugPrint('Error deleting student: $e');

      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _registerForStudentPrize() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData == null || userData.memberId == null) {
        throw Exception('User not logged in');
      }

      final registrationData = StudentPrizeRegistrationData(
        eventId: int.tryParse(widget.eventAttendee.event?.eventId ?? "0"),
        memberId: int.tryParse(userData.memberId.toString()),
        addedBy: int.tryParse(userData.memberId.toString()),
        eventAttendeesId: int.tryParse(widget.eventAttendee.eventAttendeesId ?? "0"),
        priceMemberId: int.tryParse(selectedMemberId.value),
        studentName: studentNameController.text.trim(),
        schoolName: schoolNameController.text.trim(),
        standardPassed: standardController.text.trim(),
        yearOfPassed: selectedYear.value,
        grade: gradeController.text.trim(),
        addBy: int.tryParse(userData.memberId.toString()),
        markSheetAttachment: _image.value?.path,
      );

      debugPrint("Sending Student Prize Registration: ${registrationData.toJson()}");

      final response = await repo.registerForStudentPrize(registrationData);

      if (response['status'] == true) {
        if (response['already_registered'] == true) {
          await _showAlreadyRegisteredDialog(response['message']);
        } else {
          studentNameController.clear();
          schoolNameController.clear();
          standardController.clear();
          gradeController.clear();
          _image.value = null;
          selectedMemberId.value = "";
          selectedYear.value = "";

          await _showSuccesDialog('Successfully registered for Student Prize Distribution');
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to register');
      }
    } catch (e) {
      await _showErorDialog('Something went wrong please try again');
    }
  }

// Add this method to handle the "already registered" case
  Future<void> _showAlreadyRegisteredDialog(String message) async {
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
                "Already Registered",
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

  Future<void> _showSuccesDialog(String message) async {
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

  Future<void> _showErorDialog(String message) async {
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
                                      errorBuilder: (_, __, ___) =>
                                          const Center(
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
                                width: 400,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.qr_code,
                                    size: 80,
                                    color: Colors.grey),
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
                        _buildRows(
                          "No of Food Coupon",
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.eventAttendee.noOfFoodContainer ??
                                    "Not Allotted",
                                style: const TextStyle(fontSize: 14),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  int? eventAttendeesId = int.tryParse(
                                      widget.eventAttendee.eventAttendeesId ??
                                          '');

                                  if (eventAttendeesId != null) {
                                    _showFoodBottomSheet(
                                      context,
                                      eventAttendeesId,
                                      currentFoodOption: (widget.eventAttendee
                                                      .noOfFoodContainer !=
                                                  null &&
                                              widget.eventAttendee
                                                      .noOfFoodContainer !=
                                                  "0")
                                          ? "Yes"
                                          : "No",
                                      currentFoodBoxCount: int.tryParse(widget
                                                  .eventAttendee
                                                  .noOfFoodContainer ??
                                              '0') ??
                                          0,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Invalid event attendees ID')),
                                    );
                                  }
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
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                          'Student Prize Registration:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            final userData = await SessionManager.getSession();
                            // int? eventAttendeesId = int.tryParse(widget.eventAttendee.eventAttendeesId ?? '');
                            if (userData != null && userData.memberId != null) {
                              final attendeeId = int.tryParse(
                                      widget.eventAttendee.eventAttendeesId ??
                                          '0') ??
                                  0;

                              final eventIdStr =
                                  widget.eventAttendee.event?.eventId;
                              if (eventIdStr != null && eventIdStr.isNotEmpty) {
                                final eventId = int.tryParse(eventIdStr);
                                if (eventId != null) {
                                  _showAddEducationDetailsSheet(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Invalid Event ID')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Event ID not available')),
                                );
                              }
                            }
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
                    _buildStudentPrizeCards(),
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

  void _showAddEducationDetailsSheet(BuildContext context) {
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
                        _registerForStudentPrize();
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
                                    child: Text("${member.firstName} ${member.middleName ?? ''} ${member.lastName}"),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    selectedMemberId.value = newValue;

                                    final selectedMember = controller.familyDataList.firstWhereOrNull(
                                            (m) => m.memberId.toString() == newValue
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
                      }),
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
                      if (_image.value != null)
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
                            child: Image.file(_image.value!, fit: BoxFit.cover),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showImagePicker(context),
                          icon: const Icon(Icons.image),
                          label: const Text("Upload Mark Sheet"),
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

  void _showFoodBottomSheet(
    BuildContext context,
    int eventAttendeesId, {
    String? currentFoodOption,
    int currentFoodBoxCount = 0,
  }) {
    final TextEditingController _foodBoxController = TextEditingController(
        text: currentFoodBoxCount > 0 ? currentFoodBoxCount.toString() : '');
    String? selectedFoodOption = currentFoodOption;
    int localFoodBoxCount = currentFoodBoxCount;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[100],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                      style:
                          OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _updateFoodContainer(eventAttendeesId,
                            selectedFoodOption, localFoodBoxCount);
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
                const Text(
                  "Do you want to update your food coupons for this event?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 25),
                DropdownButtonFormField<String>(
                  value: selectedFoodOption,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Food Coupons',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  items: ["Yes", "No"].map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    (context as Element).markNeedsBuild();
                    selectedFoodOption = value;
                    if (selectedFoodOption == "No") {
                      localFoodBoxCount = 0;
                      _foodBoxController.clear();
                    }
                  },
                ),
                const SizedBox(height: 20),
                if (selectedFoodOption == "Yes")
                  TextFormField(
                    controller: _foodBoxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Number of Food Boxes (Max 2)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        int num = int.tryParse(value) ?? 0;
                        if (num > 2) {
                          _foodBoxController.text = '2';
                          _foodBoxController.selection =
                              TextSelection.fromPosition(
                            TextPosition(
                                offset: _foodBoxController.text.length),
                          );
                          localFoodBoxCount = 2;
                        } else {
                          localFoodBoxCount = num;
                        }
                      } else {
                        localFoodBoxCount = 0;
                      }
                    },
                  ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateFoodContainer(
      int eventAttendeesId, String? selectedOption, int boxCount) async {
    try {
      final userData = await SessionManager.getSession();
      if (userData == null || userData.memberId == null) {
        throw Exception('User not logged in');
      }

      if (selectedOption == null) {
        throw Exception('Please select a food option');
      }

      final repository = UpdateFoodContainerRepository();
      final requestBody = {
        'event_attendees_id': eventAttendeesId.toString(),
        'no_of_food_container':
            (selectedOption == "Yes" ? boxCount : 0).toString(),
        'updated_by': userData.memberId.toString(),
      };

      debugPrint("Updating Food Container: $requestBody");

      final response = await repository.updateFoodContainer(requestBody);

      if (response.status == true) {
        Get.snackbar(
          'Success',
          response.message ?? 'Food container updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(response.message ?? 'Failed to update food container');
      }
    } catch (e) {
      debugPrint("Error updating food container: $e");
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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

  Widget _buildRows(String label, {String? value, Widget? child}) {
    assert(value != null || child != null,
        'Either value or child must be provided');

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
            child: child ??
                Text(
                  value ?? '',
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

  void _showEducationDetailsSheet(BuildContext context, PriceMember student) {
    if (student.priceMemberId != null) {
      selectedMemberId.value = student.priceMemberId.toString();
    }

    studentNameController.text = student.studentName ?? '';
    schoolNameController.text = student.schoolName ?? '';
    standardController.text = student.standardPassed ?? '';
    gradeController.text = student.grade ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[100],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                      style:
                          OutlinedButton.styleFrom(foregroundColor: Colors.red),
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

                // 🔽 Children Dropdown (now auto-selects existing student)
                Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Obx(() {
                        final familyList = controller.familyDataList;
                        if (familyList.isEmpty) {
                          return const Center(
                              child: Text('No Members available'));
                        } else {
                          final selectedValue = selectedMemberId.value;
                          return Expanded(
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: selectedValue.isNotEmpty
                                    ? 'Select Children *'
                                    : null,
                                border: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black38, width: 1)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 4),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                              ),
                              child: DropdownButton<String>(
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                isExpanded: true,
                                underline: Container(),
                                hint: const Text('Select Children *',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                value: selectedValue.isNotEmpty
                                    ? selectedValue
                                    : null,
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
                                    final selectedMember =
                                        familyList.firstWhereOrNull(
                                      (m) => m.memberId.toString() == newValue,
                                    );
                                    if (selectedMember != null) {
                                      final fullName = [
                                        selectedMember.firstName,
                                        selectedMember.middleName ?? "",
                                        selectedMember.lastName ?? ""
                                      ]
                                          .where((name) => name.isNotEmpty)
                                          .join(" ");
                                      studentNameController.text = fullName;
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                _buildTextField(
                    label: "School Name",
                    controller: schoolNameController,
                    type: TextInputType.text,
                    empty: "Enter school name"),
                _buildTextField(
                    label: "Standard Passed",
                    controller: standardController,
                    type: TextInputType.text,
                    empty: "Enter standard"),
                _buildTextField(
                    label: "Percentage of Marks or Grade",
                    controller: gradeController,
                    type: TextInputType.text,
                    empty: "Enter marks/grade"),

                // 🔽 Year of Passing (pre-filled from student.yearOfPassed)
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
                              labelText: selectedValue.isNotEmpty
                                  ? 'Year of Passing *'
                                  : null,
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black38, width: 1)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              labelStyle: const TextStyle(color: Colors.black),
                            ),
                            child: DropdownButton<String>(
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              isExpanded: true,
                              underline: Container(),
                              hint: const Text('Year of Passing *',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              value: selectedValue.isNotEmpty
                                  ? selectedValue
                                  : null,
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
                // 🔽 Marksheet preview (auto-loads existing if available)
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
                                : Image.network(existingMarksheetUrl!,
                                    fit: BoxFit.cover),
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
                            backgroundColor: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
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
}
