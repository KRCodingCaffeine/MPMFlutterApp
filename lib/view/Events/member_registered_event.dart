import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/GetMemberRegisteredEvents/GetMemberRegisteredEventsData.dart';
import 'package:mpm/model/GetMemberRegisteredEvents/GetMemberRegisteredEventsModelClass.dart';
import 'package:mpm/model/UpdateEventByMember/UpdateEventByMemberModelClass.dart';
import 'package:mpm/repository/get_member_registered_events_repository/get_member_registered_events_repo.dart';
import 'package:mpm/repository/update_event_by_member_repository/update_event_by_member_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/Events/member_registered_event_detail.dart' hide EventAttendeesRepository;

class RegisteredEventsListPage extends StatefulWidget {
  @override
  _RegisteredEventsListPageState createState() =>
      _RegisteredEventsListPageState();
}

class _RegisteredEventsListPageState extends State<RegisteredEventsListPage> {
  late Future<EventAttendeesModelClass> _registeredEventsFuture;
  final EventAttendeesRepository _repository = EventAttendeesRepository();
  final CancelEventRepository _cancelRepo = CancelEventRepository();

  List<EventAttendeeData> _events = [];
  Set<int> _cancelledEventIds = {};

  String memberName = 'Loading...';

  @override
  void initState() {
    super.initState();
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
            setState(() {
              _events = (response.data ?? []).where((event) {
                final endDate = DateTime.tryParse(event.dateEndTo ?? '');
                if (endDate == null) return false;
                return endDate.isAfter(DateTime.now()) ||
                    endDate.isAtSameMomentAs(DateTime.now());
              }).toList();
            });
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

  Widget _buildEventCard(EventAttendeeData event) {
    final parsedDate =
        DateTime.tryParse(event.dateStartsFrom ?? '') ?? DateTime.now();
    final day = DateFormat('d').format(parsedDate);
    final month = DateFormat('MMM').format(parsedDate);

    final bool isCancelled =
        event.cancelledDate != null && event.cancelledDate!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RegisteredEventsDetailPage(
                        eventAttendee: event,
                      ),
                ),
              );
            },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(day,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(month,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 60,
                width: 1,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.eventName ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text('Member: $memberName',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      isCancelled
                          ? 'Cancelled on: ${_formatDate(event.cancelledDate)}'
                          : 'Registered on: ${_formatDate(event.registrationDate)}',
                      style: TextStyle(
                          color: isCancelled ? Colors.red : Colors.grey[600],
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  String _getUserName(String? firstName, String? middleName, String? lastName) {
    final fName = firstName ?? '';
    final mName = middleName?.isNotEmpty == true ? ' $middleName ' : ' ';
    final lName = lastName ?? '';
    return '$fName$mName$lName'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          'Registered Events List',
          style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.045,
              fontWeight: FontWeight.w500),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<EventAttendeesModelClass>(
          future: _registeredEventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildEmptyState();
            } else if (_events.isEmpty) {
              return _buildEmptyState();
            } else {
              return RefreshIndicator(
                color: Colors.redAccent,
                onRefresh: _loadUserDataAndFetchEvents,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: _events.length,
                  itemBuilder: (context, index) =>
                      _buildEventCard(_events[index]),
                ),
              );
            }
          }),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: Colors.redAccent,
      onRefresh: _loadUserDataAndFetchEvents,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available, size: 34, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Not yet registered to any event',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Register for events from the Events section',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
