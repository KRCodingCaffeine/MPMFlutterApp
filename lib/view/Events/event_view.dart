import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/GetEventsList/GetEventsListData.dart';
import 'package:mpm/model/GetEventsList/GetEventsListModelClass.dart';
import 'package:mpm/model/Zone/ZoneData.dart';
import 'package:mpm/repository/get_events_list_repository/get_events_list_repo.dart';
import 'package:mpm/repository/zone_repository/zone_repo.dart';
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
  final ZoneRepository _zoneRepo = ZoneRepository();

  List<EventData> _upcomingEvents = [];
  List<EventData> _pastEvents = [];
  List<EventData> _allEvents = [];
  bool _isLoading = true;
  String? _error;
  int _selectedTabIndex = 0;

  List<ZoneData> _zoneList = [];
  List<ZoneData> _selectedZones = [];
  bool _isFilterDrawerOpen = false;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isAllSelected = false;

  @override
  void initState() {
    super.initState();
    _fetchZones();
    _fetchEvents();
  }

  Future<void> _fetchZones() async {
    try {
      final response = await _zoneRepo.ZoneApi();
      setState(() {
        _zoneList = response.data ?? [];
        _zoneList.insert(0, ZoneData(id: '1', zoneName: "All"));
      });
    } catch (e) {
      print("Zone API Error: $e");
    }
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });

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
          _allEvents = eventModel.data!;
          _upcomingEvents = upcoming;
          _pastEvents = past;
          _isLoading = false;
          _error = null;
        });
        _applyFilters();
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

  void _applyFilters() {
    setState(() {
      List<EventData> filteredEvents = _allEvents;

      // Apply zone filter
      if (_selectedZones.isNotEmpty) {
        filteredEvents = filteredEvents.where((e) {
          // If event is for all zones (isAllZone = 1), include it only if "All" is selected
          if (e.isAllZone == '1') {
            return _isAllSelected;
          }
          // For zone-specific events (isAllZone = 0), check if they match selected zones
          else {
            return _selectedZones.any((zone) =>
            e.zones?.any((eventZone) => eventZone.id == zone.id) ?? false);
          }
        }).toList();
      }

      // Apply date range filter
      if (_startDate != null && _endDate != null) {
        filteredEvents = filteredEvents.where((e) {
          final eventStartDate = DateTime.tryParse(e.dateStartsFrom ?? '');
          final eventEndDate = DateTime.tryParse(e.dateEndTo ?? '');

          if (eventStartDate == null || eventEndDate == null) return false;

          return (eventStartDate.isBefore(_endDate!) ||
              eventStartDate.isAtSameMomentAs(_endDate!)) &&
              (eventEndDate.isAfter(_startDate!) ||
                  eventEndDate.isAtSameMomentAs(_startDate!));
        }).toList();
      }

      // Split into upcoming/past
      final today = DateTime.now();
      final upcoming = <EventData>[];
      final past = <EventData>[];

      for (var e in filteredEvents) {
        final date = DateTime.tryParse(e.dateStartsFrom ?? '');
        if (date != null) {
          if (date.isAfter(today) || date.isAtSameMomentAs(today)) {
            upcoming.add(e);
          } else {
            past.add(e);
          }
        }
      }

      _upcomingEvents = upcoming;
      _pastEvents = past;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDate ?? DateTime.now()
          : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _startDate!.isAfter(_endDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_startDate != null && _endDate!.isBefore(_startDate!)) {
            _startDate = _endDate;
          }
        }
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
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
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

  Widget _buildFilterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: InkWell(
        onTap: () {
          setState(() {
            _isFilterDrawerOpen = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Filters", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    if (_isAllSelected || _selectedZones.isNotEmpty || _startDate != null || _endDate != null)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (_isAllSelected)
                            Chip(
                              label: const Text("All Zones"),
                              labelStyle: const TextStyle(
                                  fontSize: 12, color: Colors.white),
                              backgroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              deleteIcon: const Icon(Icons.close,
                                  color: Colors.white, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _isAllSelected = false;
                                  _applyFilters();
                                });
                              },
                            ),
                          ..._selectedZones
                              .map((zone) => Chip(
                            label: Text(zone.zoneName ?? ''),
                            labelStyle: const TextStyle(
                                fontSize: 12, color: Colors.white),
                            backgroundColor:
                            ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                            deleteIcon: const Icon(Icons.close,
                                color: Colors.white, size: 18),
                            onDeleted: () {
                              setState(() {
                                _selectedZones.remove(zone);
                                _applyFilters();
                              });
                            },
                          ))
                              .toList(),
                          if (_startDate != null)
                            Chip(
                              label: Text(
                                  "From: ${DateFormat('dd-MM-yyyy').format(_startDate!)}"),
                              labelStyle: const TextStyle(
                                  fontSize: 12, color: Colors.white),
                              backgroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              deleteIcon: const Icon(Icons.close,
                                  color: Colors.white, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _startDate = null;
                                  _applyFilters();
                                });
                              },
                            ),
                          if (_endDate != null)
                            Chip(
                              label: Text(
                                  "To: ${DateFormat('dd-MM-yyyy').format(_endDate!)}"),
                              labelStyle: const TextStyle(
                                  fontSize: 12, color: Colors.white),
                              backgroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              deleteIcon: const Icon(Icons.close,
                                  color: Colors.white, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _endDate = null;
                                  _applyFilters();
                                });
                              },
                            ),
                        ],
                      )
                  ],
                ),
              ),
              const Icon(Icons.filter_list),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFilterDrawer() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Material(
        elevation: 16,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Filters",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _isFilterDrawerOpen = false),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Zones",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: const Text("All Zones"),
                value: _isAllSelected,
                onChanged: (bool? value) {
                  setState(() {
                    _isAllSelected = value ?? false;
                    if (_isAllSelected) {
                      _selectedZones.clear();
                    }
                  });
                },
              ),
              Expanded(
                child: ListView(
                  children: _zoneList
                      .where((zone) => zone.id != '1') // Exclude "All" from list
                      .map((zone) => CheckboxListTile(
                    title: Text(zone.zoneName ?? ''),
                    value: _selectedZones.contains(zone),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedZones.add(zone);
                          _isAllSelected = false;
                        } else {
                          _selectedZones.remove(zone);
                        }
                      });
                    },
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Date Range",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                title: Text(
                  _startDate == null
                      ? "Select Start Date"
                      : "Start: ${DateFormat('dd-MM-yyyy').format(_startDate!)}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: Text(
                  _endDate == null
                      ? "Select End Date"
                      : "End: ${DateFormat('dd-MM-yyyy').format(_endDate!)}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        ColorHelperClass.getColorFromHex(ColorResources.red_color),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _isFilterDrawerOpen = false;
                          _applyFilters();
                        });
                      },
                      child: const Text("Apply Filters"),
                    ),
                  ),
                ],
              ),
            ],
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
            tooltip: 'Registered Events',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RegisteredEventsListPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildEventFilterTabs(),
              _buildFilterButton(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!))
                        : RefreshIndicator(
                            color: Colors.redAccent,
                            onRefresh: _fetchEvents,
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
              ),
            ],
          ),
          if (_isFilterDrawerOpen) _buildFilterDrawer(),
        ],
      ),
    );
  }
}
