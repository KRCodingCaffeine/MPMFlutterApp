import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/EventAttendees/EventAttendeesData.dart';
import 'package:mpm/model/EventAttendees/EventAttendeesModelClass.dart';
import 'package:mpm/model/EventRegistrationConfirmation/EventRegistrationConfirmationData.dart';
import 'package:mpm/model/EventRegistrationConfirmation/EventRegistrationConfirmationModelClass.dart';
import 'package:mpm/model/GetEventsByCoordinator/GetEventsByCoordinatorData.dart';
import 'package:mpm/model/GetEventsByCoordinator/GetEventsByCoordinatorModelClass.dart';
import 'package:mpm/model/GetEventsList/GetEventsListData.dart';
import 'package:mpm/model/GetEventsList/GetEventsListModelClass.dart';
import 'package:mpm/repository/event_attendees_repository/event_attendees_repo.dart';
import 'package:mpm/repository/event_registration_confirmation_repository/event_registration_confirmation_repo.dart';
import 'package:mpm/repository/get_events_by_coordinator_repository/get_events_by_coordinator_repo.dart';
import 'package:mpm/repository/get_events_list_repository/get_events_list_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class EventAttendeesView extends StatefulWidget {
  const EventAttendeesView({super.key, this.eventId});

  final String? eventId;

  @override
  State<EventAttendeesView> createState() => _EventAttendeesViewState();
}

class _EventAttendeesViewState extends State<EventAttendeesView> {
  // final EventRepository _eventRepository = EventRepository();
  final GetEventsByCoordinatorRepository _eventRepository =
  GetEventsByCoordinatorRepository();
  final EventAttendeesRepository _attendeesRepository =
      EventAttendeesRepository();
  final EventRegistrationConfirmationRepository _confirmationRepository =
      EventRegistrationConfirmationRepository();
  final Set<String> _approvedAttendeeIds = {};
  final Set<String> _approvingAttendeeIds = {};
  final Set<String> _rejectingAttendeeIds = {};

  Future<EventAttendeesModelClass>? _attendeesFuture;
  Future<void>? _eventsFuture;
  // final List<EventData> _upcomingEvents = [];
  // final List<EventData> _pastEvents = [];
  final List<GetEventsByCoordinatorData> _upcomingEvents = [];
  final List<GetEventsByCoordinatorData> _pastEvents = [];

  GetEventsByCoordinatorData? _selectedEvent;
  String? _eventId;
  // EventData? _selectedEvent;
  String? _eventsError;
  int _selectedTabIndex = 0;
  bool _routeArgumentsLoaded = false;

  Color get _brandColor =>
      ColorHelperClass.getColorFromHex(ColorResources.logo_color);

  @override
  void initState() {
    super.initState();
    _eventId = widget.eventId;
    _eventsFuture = _fetchEvents();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_routeArgumentsLoaded) return;
    _routeArgumentsLoaded = true;

    _eventId ??= _getEventIdFromArguments();
    if (_eventId != null && _eventId!.isNotEmpty) {
      _selectedEvent = _getEventFromArguments();
      _attendeesFuture = _fetchEventAttendees();
    }
  }

  String? _getEventIdFromArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String || args is int) {
      return args.toString();
    }

    if (args is Map) {
      final id = args['event_id'] ?? args['eventId'] ?? args['id'];
      return id?.toString();
    }

    return null;
  }

  GetEventsByCoordinatorData? _getEventFromArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map && args['event'] is GetEventsByCoordinatorData) {
      return args['event'] as GetEventsByCoordinatorData;
    }

    return null;
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _eventsError = null;
    });

    try {
      String memberId = '';
      String zoneId = '';

      if (Get.isRegistered<UdateProfileController>()) {
        final user =
            Get.find<UdateProfileController>().getUserData.value;

        memberId = user.memberId.toString();
        zoneId = user.address?.zoneId ?? '';
      }

      final response = await _eventRepository.fetchCoordinatorEvents(
        memberId: memberId,
        zoneId: zoneId,
      );

      final model =
      GetEventsByCoordinatorModelClass.fromJson(response);

      if (model.status == true && model.data != null) {
        _setEvents(model.data!);
      } else {
        setState(() {
          _upcomingEvents.clear();
          _pastEvents.clear();
          _eventsError = model.message ?? 'No Events';
        });
      }
    } catch (e) {
      setState(() {
        _eventsError = e.toString();
      });
    }
  }

  void _setEvents(List<GetEventsByCoordinatorData> events) {
    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);

    final upcoming = <GetEventsByCoordinatorData>[];
    final past = <GetEventsByCoordinatorData>[];

    for (final event in events) {
      final endDate =
      DateTime.tryParse(event.dateEndTo ?? '');

      if (endDate == null) continue;

      if (endDate.isBefore(currentDate)) {
        past.add(event);
      } else {
        upcoming.add(event);
      }
    }

    upcoming.sort((a, b) {
      final d1 =
          DateTime.tryParse(a.dateStartsFrom ?? '') ?? DateTime.now();

      final d2 =
          DateTime.tryParse(b.dateStartsFrom ?? '') ?? DateTime.now();

      return d1.compareTo(d2);
    });

    past.sort((a, b) {
      final d1 =
          DateTime.tryParse(b.dateStartsFrom ?? '') ?? DateTime.now();

      final d2 =
          DateTime.tryParse(a.dateStartsFrom ?? '') ?? DateTime.now();

      return d1.compareTo(d2);
    });

    setState(() {
      _upcomingEvents
        ..clear()
        ..addAll(upcoming);

      _pastEvents
        ..clear()
        ..addAll(past);

      _eventsError = null;
    });
  }

  Future<EventAttendeesModelClass> _fetchEventAttendees() async {
    final response = await _attendeesRepository.fetchEventAttendees(_eventId!);
    return EventAttendeesModelClass.fromJson(response);
  }

  Future<void> _refreshAttendees() async {
    if (_eventId == null || _eventId!.isEmpty) return;

    setState(() {
      _attendeesFuture = _fetchEventAttendees();
    });

    try {
      await _attendeesFuture;
    } catch (_) {}
  }

  Future<void> _refreshEvents() async {
    setState(() {
      _eventsFuture = _fetchEvents();
    });
    await _eventsFuture;
  }

  Future<void> _approveAttendee(EventAttendeesData attendee) async {
    final attendeeId = attendee.eventAttendeesId;
    if (attendeeId == null || attendeeId.isEmpty) {
      _showSnackBar('Attendee ID not available', isSuccess: false);
      return;
    }

    setState(() {
      _approvingAttendeeIds.add(attendeeId);
    });

    try {
      final response = await _confirmationRepository.confirmEventRegistration(
        EventRegistrationConfirmationData(
          attendeeId: attendeeId,
          confirmationStatus: 'confirmed',
        ),
      );
      final confirmation =
          EventRegistrationConfirmationModelClass.fromJson(response);

      if (confirmation.status == true) {
        setState(() {
          attendee.confirmationStatus = 'confirmed';
          _approvedAttendeeIds.add(
            confirmation.data?.attendeeId ?? attendeeId,
          );
        });
        _showSnackBar('The Member Approved for this event successfully');
      } else {
        _showSnackBar(
          confirmation.message ?? 'Failed to approve this member for the event',
          isSuccess: false,
        );
      }
    } catch (e) {
      _showSnackBar('Error approving registration: $e', isSuccess: false);
    } finally {
      if (!mounted) return;
      setState(() {
        _approvingAttendeeIds.remove(attendeeId);
      });
    }
  }

  Future<void> _rejectAttendee(EventAttendeesData attendee) async {
    final attendeeId = attendee.eventAttendeesId;

    if (attendeeId == null || attendeeId.isEmpty) {
      _showSnackBar(
        'Attendee ID not available',
        isSuccess: false,
      );
      return;
    }

    setState(() {
      _rejectingAttendeeIds.add(attendeeId);
    });

    try {
      final response = await _confirmationRepository.confirmEventRegistration(
        EventRegistrationConfirmationData(
          attendeeId: attendeeId,
          confirmationStatus: 'rejected',
        ),
      );

      final confirmation =
          EventRegistrationConfirmationModelClass.fromJson(response);

      if (confirmation.status == true) {
        setState(() {
          attendee.confirmationStatus = 'rejected';
        });

        _showSnackBar(
          'The member registration has been rejected.',
        );

        await _refreshAttendees();
      } else {
        _showSnackBar(
          confirmation.message ?? 'Failed to reject registration.',
          isSuccess: false,
        );
      }
    } catch (e) {
      _showSnackBar(
        'Error rejecting registration: $e',
        isSuccess: false,
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _rejectingAttendeeIds.remove(attendeeId);
      });
    }
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  void _openAttendees(GetEventsByCoordinatorData event) {
    if (event.eventId == null) return;

    setState(() {
      _eventId = event.eventId;
      _selectedEvent = event;

      _approvedAttendeeIds.clear();
      _approvingAttendeeIds.clear();
      _rejectingAttendeeIds.clear();

      _attendeesFuture = _fetchEventAttendees();
    });
  }

  void _showEventList() {
    setState(() {
      _eventId = null;
      _selectedEvent = null;
      _attendeesFuture = null;
      _approvedAttendeeIds.clear();
      _approvingAttendeeIds.clear();
      _rejectingAttendeeIds.clear();

      _eventsFuture = _fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: _brandColor,
        leading: _selectedEvent != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _showEventList,
              )
            : null,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _selectedEvent == null ? 'Event Attendees' : 'Attendees List',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_eventId == null || _eventId!.isEmpty) {
      return _buildEventListBody();
    }

    return _buildAttendeesBody();
  }

  Widget _buildEventListBody() {
    return FutureBuilder<void>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_eventsError != null) {
          return _buildEmptyState(
            icon: Icons.error_outline,
            title: 'Unable to load events',
            message: 'Pull down to try again.',
            onRefresh: _refreshEvents,
          );
        }

        final events = _selectedTabIndex == 0 ? _upcomingEvents : _pastEvents;

        return Column(
          children: [
            _buildEventFilterTabs(),
            Expanded(
              child: events.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.event_busy_outlined,
                      title: _selectedTabIndex == 0
                          ? 'No upcoming events'
                          : 'No past events',
                      message: 'Events will appear here when available.',
                      onRefresh: _refreshEvents,
                    )
                  : RefreshIndicator(
                      color: _brandColor,
                      onRefresh: _refreshEvents,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return _buildEventCard(events[index]);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttendeesBody() {
    return FutureBuilder<EventAttendeesModelClass>(
      future: _attendeesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.error_outline,
            title: 'Unable to load attendees',
            message: 'Pull down to try again.',
            onRefresh: _refreshAttendees,
          );
        }

        final attendees = snapshot.data?.data ?? [];
        if (attendees.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline,
            title: 'No attendees found',
            message: 'Registered attendees will appear here.',
            onRefresh: _refreshAttendees,
          );
        }

        return RefreshIndicator(
          color: _brandColor,
          onRefresh: _refreshAttendees,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_selectedEvent != null) _buildSelectedEventHeader(),
              ...List.generate(attendees.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
                  child: _buildAttendeeCard(attendees[index]),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            _buildTabButton('Upcoming Events', 0),
            const SizedBox(width: 8),
            _buildTabButton('Past Events', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorHelperClass.getColorFromHex(ColorResources.red_color)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(GetEventsByCoordinatorData event) {
    final parsedDate =
        DateTime.tryParse(event.dateStartsFrom ?? '') ?? DateTime.now();
    final day = DateFormat('d').format(parsedDate);
    final month = DateFormat('MMM').format(parsedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openAttendees(event),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 58,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      month,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(height: 86, width: 1, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.eventName ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Coordinator: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: event.eventOrganiserName
                                    ?.split(',')
                                    .join(', ') ??
                                'Unknown',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if ((event.eventDescription ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        event.eventDescription!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedEventHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _brandColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _brandColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available_outlined, color: _brandColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedEvent?.eventName ?? 'Selected Event',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeCard(EventAttendeesData attendee) {
    final name = _getAttendeeName(attendee);
    final attendeesCode = _valueOrDash(attendee.eventAttendeesCode);
    final mobileNumber = _valueOrDash(attendee.mobile);
    final memberCode = _valueOrDash(attendee.memberCode);

    final email = _valueOrDash(attendee.email);
    final isApproved = _isApproved(attendee);
    final attendeeId = attendee.eventAttendeesId;
    final isApproving =
        attendeeId != null && _approvingAttendeeIds.contains(attendeeId);
    final isRejecting =
        attendeeId != null && _rejectingAttendeeIds.contains(attendeeId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _brandColor.withValues(alpha: 0.12),
                child: Text(
                  name.isNotEmpty && name != '-' ? name[0] : '-',
                  style: TextStyle(
                    color: _brandColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Attendees Code: $attendeesCode',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            Icons.badge_outlined,
            'Membership Code',
            memberCode,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.phone_outlined,
            'Mobile Number',
            mobileNumber,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.email_outlined, 'Email', email),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Registered On',
            attendee.registrationDate != null &&
                    attendee.registrationDate!.isNotEmpty
                ? DateFormat('dd MMM yyyy').format(
                    DateTime.parse(attendee.registrationDate!),
                  )
                : '-',
          ),
          if (!_isFreeEvent(attendee)) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.payment_outlined,
              'Payment Transaction Id',
              attendee.paymentTransactionId != null &&
                      attendee.paymentTransactionId!.isNotEmpty
                  ? attendee.paymentTransactionId!
                  : '-',
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: isApproved || isApproving || isRejecting
                  ? null
                  : () => _approveAttendee(attendee),
              icon: isApproving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isApproved
                          ? Icons.check_circle_outline
                          : Icons.verified_outlined,
                      size: 18,
                    ),
              label: Text(isApproved ? 'Approved' : 'Approve'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isApproved ? Colors.green : Colors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.green,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (!isApproved) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: isApproving || isRejecting
                    ? null
                    : () => _rejectAttendee(attendee),
                icon: isRejecting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.cancel_outlined,
                        size: 18,
                      ),
                label: const Text("Reject"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.red,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isApproved(EventAttendeesData attendee) {
    if (_isFreeEvent(attendee)) {
      return true;
    }

    final attendeeId = attendee.eventAttendeesId ?? attendee.eventAttendeesCode;

    if (attendeeId != null && _approvedAttendeeIds.contains(attendeeId)) {
      return true;
    }

    final status = (attendee.confirmationStatus ?? '').trim().toLowerCase();

    return status == 'confirmed';
  }

  bool _isFreeEvent(EventAttendeesData attendee) {
    final eventCostType =
        (attendee.eventCostType ?? _selectedEvent?.eventCostType ?? '')
            .trim()
            .toLowerCase();

    return eventCostType == 'free' || eventCostType == '0';
  }

  String _getAttendeeName(EventAttendeesData attendee) {
    if (attendee.memberFullName != null &&
        attendee.memberFullName!.trim().isNotEmpty) {
      return attendee.memberFullName!.trim();
    }

    final nameParts = [
      attendee.firstName,
      attendee.middleName,
      attendee.lastName,
    ].where((name) => name != null && name.trim().isNotEmpty);

    final fullName = nameParts.join(' ').trim();
    return fullName.isNotEmpty ? fullName : '-';
  }

  String _valueOrDash(String? value) {
    final trimmedValue = value?.trim() ?? '';
    return trimmedValue.isNotEmpty ? trimmedValue : '-';
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _brandColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    Future<void> Function()? onRefresh,
  }) {
    return RefreshIndicator(
      color: _brandColor,
      onRefresh: onRefresh ?? () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 38, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
