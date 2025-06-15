import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/GetEventsList/GetEventsListData.dart';
import 'package:mpm/model/GetEventsList/GetEventsListModelClass.dart';
import 'package:mpm/repository/get_events_list_repository/get_events_list_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/Events/event_detail_page.dart';
import 'package:mpm/view/Events/member_registered_event.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventRepository _eventRepo = EventRepository();
  List<EventData> _upcomingEvents = [];
  List<EventData> _pastEvents = [];
  bool _isLoading = true;
  String? _error;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final json = await _eventRepo.fetchEvents();
      final eventModel = EventModelClass.fromJson(json);

      if (eventModel.status == true && eventModel.data != null) {
        final today = DateTime.now();
        final upcoming = <EventData>[];
        final past = <EventData>[];

        for (var e in eventModel.data!) {
          final date = DateTime.tryParse(e.dateStartsFrom ?? '');
          if (date != null) {
            if (date.isAfter(today) || date.isAtSameMomentAs(today)) {
              upcoming.add(e);
            } else {
              past.add(e);
            }
          }
        }

        upcoming.sort((a, b) => a.dateStartsFrom!.compareTo(b.dateStartsFrom!));
        past.sort((a, b) => b.dateStartsFrom!.compareTo(a.dateStartsFrom!));

        setState(() {
          _upcomingEvents = upcoming;
          _pastEvents = past;
          _isLoading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = eventModel.message ?? 'Failed to load events';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildEventCard(EventData event) {
    final parsedDate =
        DateTime.tryParse(event.dateStartsFrom ?? '') ?? DateTime.now();
    final day = DateFormat('d').format(parsedDate);
    final month = DateFormat('MMM').format(parsedDate);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(event: event),
          ),
        );
      },
      child: Padding(
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
                height: 80,
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
                    const SizedBox(height: 4),
                    Text(
                      event.eventDescription ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text('Hosted by ${event.eventOrganiserName ?? 'Unknown'}',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
            _buildTabButton("Upcoming Events", 0),
            const SizedBox(width: 8),
            _buildTabButton("Past Events", 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final bool isSelected = _selectedTabIndex == index;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text("Events", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_offer, color: Colors.white),
            tooltip: 'Filter Offers',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisteredEventsListPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : RefreshIndicator(
        color: Colors.redAccent,
        onRefresh: _fetchEvents,
        child: Column(
          children: [
            _buildEventFilterTabs(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4),
                itemCount: _selectedTabIndex == 0
                    ? _upcomingEvents.length
                    : _pastEvents.length,
                itemBuilder: (context, index) => _buildEventCard(
                    _selectedTabIndex == 0
                        ? _upcomingEvents[index]
                        : _pastEvents[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
