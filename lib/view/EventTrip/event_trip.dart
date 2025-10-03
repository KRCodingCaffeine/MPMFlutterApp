import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/EventTripModel/GetEventTrip/GetEventTripData.dart';
import 'package:mpm/model/Zone/ZoneData.dart';
import 'package:mpm/repository/EventTripRepository/get_event_trip_repository/get_event_trip_repo.dart';
import 'package:mpm/repository/zone_repository/zone_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class EventTripPage extends StatefulWidget {
  const EventTripPage({Key? key}) : super(key: key);

  @override
  _EventTripPageState createState() => _EventTripPageState();
}

class _EventTripPageState extends State<EventTripPage> {
  final EventTripRepository _tripRepo = EventTripRepository();
  final ZoneRepository _zoneRepo = ZoneRepository();

  List<GetEventTripData> _upcomingTrips = [];
  List<GetEventTripData> _pastTrips = [];
  List<GetEventTripData> _allTrips = [];
  bool _isLoading = true;
  String? _error;
  int _selectedTabIndex = 0;

  List<ZoneData> _zoneList = [];
  List<ZoneData> _selectedUpcomingZones = [];
  List<ZoneData> _selectedPastZones = [];
  DateTime? _upcomingStartDate;
  DateTime? _upcomingEndDate;
  DateTime? _pastStartDate;
  DateTime? _pastEndDate;
  bool _isUpcomingAllSelected = false;
  bool _isPastAllSelected = false;
  bool _isUpcomingFilterDrawerOpen = false;
  bool _isPastFilterDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _fetchZones();
    _fetchTrips();
  }

  Future<void> _fetchZones() async {
    try {
      final userData = Get.find<UdateProfileController>().getUserData.value;
      final userZoneId = userData.address?.zoneId;

      if (userZoneId == null) {
        print("User zone ID not found");
        return;
      }

      final response = await _zoneRepo.ZoneApi();
      final List<ZoneData> allZones = response.data ?? [];

      final userZone = allZones.firstWhere(
            (zone) => zone.id == userZoneId,
        orElse: () => ZoneData(id: userZoneId, zoneName: "Unknown Zone"),
      );

      setState(() {
        _zoneList = [ZoneData(id: '1', zoneName: "All"), userZone];
      });
    } catch (e) {
      debugPrint("Zone API Error: $e");
    }
  }

  Future<void> _fetchTrips() async {
    setState(() => _isLoading = true);

    try {
      final userData = Get.find<UdateProfileController>().getUserData.value;
      final zoneIdFromProfile = userData.address?.zoneId;
      final zoneId = (zoneIdFromProfile == null || zoneIdFromProfile.isEmpty)
          ? "1"
          : zoneIdFromProfile;

      final response = await _tripRepo.fetchTrips(zoneId);

      if (response['status'] == true && response['data'] != null) {
        final List<GetEventTripData> trips = (response['data'] as List<dynamic>)
            .map((e) => GetEventTripData.fromJson(e))
            .toList();

        setState(() {
          _allTrips = trips;
          _isLoading = false;
          _error = null;
        });
        _applyFilters();
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load trips';
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
      List<GetEventTripData> filteredTrips = _allTrips;

      List<ZoneData> selectedZones =
      _selectedTabIndex == 0 ? _selectedUpcomingZones : _selectedPastZones;
      bool isAllSelected =
      _selectedTabIndex == 0 ? _isUpcomingAllSelected : _isPastAllSelected;

      if (selectedZones.isNotEmpty || isAllSelected) {
        filteredTrips = filteredTrips.where((t) {
          return isAllSelected ||
              (selectedZones.any((zone) =>
              t.zones?.any((tripZone) => tripZone.id == zone.id) ?? false));
        }).toList();
      }

      DateTime? startDate =
      _selectedTabIndex == 0 ? _upcomingStartDate : _pastStartDate;
      DateTime? endDate =
      _selectedTabIndex == 0 ? _upcomingEndDate : _pastEndDate;

      if (startDate != null && endDate != null) {
        filteredTrips = filteredTrips.where((t) {
          final tripStartDate = DateTime.tryParse(t.tripStartDate ?? '');
          final tripEndDate = DateTime.tryParse(t.tripEndDate ?? '');

          if (tripStartDate == null || tripEndDate == null) return false;

          return (tripStartDate.isBefore(endDate) ||
              tripStartDate.isAtSameMomentAs(endDate)) &&
              (tripEndDate.isAfter(startDate) ||
                  tripEndDate.isAtSameMomentAs(startDate));
        }).toList();
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final upcoming = <GetEventTripData>[];
      final past = <GetEventTripData>[];
      for (var t in filteredTrips) {
        final startDate = DateTime.tryParse(t.tripStartDate ?? '');
        final endDate = DateTime.tryParse(t.tripEndDate ?? '');

        if (startDate != null && endDate != null) {
          if (endDate.isAfter(today) || endDate.isAtSameMomentAs(today)) {
            upcoming.add(t);
          } else {
            past.add(t);
          }
        }
      }

      upcoming.sort((a, b) {
        final aDate =
            DateTime.tryParse(a.tripStartDate ?? '') ?? DateTime.now();
        final bDate =
            DateTime.tryParse(b.tripStartDate ?? '') ?? DateTime.now();
        return aDate.compareTo(bDate);
      });

      past.sort((a, b) {
        final aDate =
            DateTime.tryParse(a.tripStartDate ?? '') ?? DateTime.now();
        final bDate =
            DateTime.tryParse(b.tripStartDate ?? '') ?? DateTime.now();
        return bDate.compareTo(aDate);
      });

      _upcomingTrips = upcoming;
      _pastTrips = past;
    });
  }

  Widget _buildTripCard(GetEventTripData trip) {
    final parsedDate =
        DateTime.tryParse(trip.tripStartDate ?? '') ?? DateTime.now();
    final day = DateFormat('d').format(parsedDate);
    final month = DateFormat('MMM').format(parsedDate);

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
              height: 100,
              width: 1,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.tripName ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18)),
                  const SizedBox(height: 4),
                  Text("Coordinator: ${trip.tripOrganiserName ?? 'Unknown'}",
                      style:
                      const TextStyle(color: Colors.black54, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    trip.tripDescription ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripFilterTabs() {
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
            _buildTabButton("Upcoming Trips", 0),
            const SizedBox(width: 8),
            _buildTabButton("Past Trips", 1),
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
    final isUpcomingTab = _selectedTabIndex == 0;
    final selectedZones = isUpcomingTab ? _selectedUpcomingZones : _selectedPastZones;
    final isAllSelected = isUpcomingTab ? _isUpcomingAllSelected : _isPastAllSelected;
    final startDate = isUpcomingTab ? _upcomingStartDate : _pastStartDate;
    final endDate = isUpcomingTab ? _upcomingEndDate : _pastEndDate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isUpcomingTab) {
              _isUpcomingFilterDrawerOpen = true;
            } else {
              _isPastFilterDrawerOpen = true;
            }
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
                    Text("${isUpcomingTab ? 'Upcoming' : 'Past'} Trips",
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    if (isAllSelected || selectedZones.isNotEmpty || startDate != null || endDate != null)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (isAllSelected)
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
                                  if (isUpcomingTab) {
                                    _isUpcomingAllSelected = false;
                                  } else {
                                    _isPastAllSelected = false;
                                  }
                                  _applyFilters();
                                });
                              },
                            ),
                          ...selectedZones
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
                                if (isUpcomingTab) {
                                  _selectedUpcomingZones.remove(zone);
                                } else {
                                  _selectedPastZones.remove(zone);
                                }
                                _applyFilters();
                              });
                            },
                          ))
                              .toList(),
                          if (startDate != null)
                            Chip(
                              label: Text(
                                  "From: ${DateFormat('dd-MM-yyyy').format(startDate)}"),
                              labelStyle: const TextStyle(
                                  fontSize: 12, color: Colors.white),
                              backgroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              deleteIcon: const Icon(Icons.close,
                                  color: Colors.white, size: 18),
                              onDeleted: () {
                                setState(() {
                                  if (isUpcomingTab) {
                                    _upcomingStartDate = null;
                                  } else {
                                    _pastStartDate = null;
                                  }
                                  _applyFilters();
                                });
                              },
                            ),
                          if (endDate != null)
                            Chip(
                              label: Text(
                                  "To: ${DateFormat('dd-MM-yyyy').format(endDate)}"),
                              labelStyle: const TextStyle(
                                  fontSize: 12, color: Colors.white),
                              backgroundColor: ColorHelperClass.getColorFromHex(
                                  ColorResources.red_color),
                              deleteIcon: const Icon(Icons.close,
                                  color: Colors.white, size: 18),
                              onDeleted: () {
                                setState(() {
                                  if (isUpcomingTab) {
                                    _upcomingEndDate = null;
                                  } else {
                                    _pastEndDate = null;
                                  }
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

  Widget _buildFilterDrawer(bool isUpcoming) {
    final selectedZones = isUpcoming ? _selectedUpcomingZones : _selectedPastZones;
    final isAllSelected = isUpcoming ? _isUpcomingAllSelected : _isPastAllSelected;
    final startDate = isUpcoming ? _upcomingStartDate : _pastStartDate;
    final endDate = isUpcoming ? _upcomingEndDate : _pastEndDate;

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
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    Text("${isUpcoming ? 'Upcoming' : 'Past'} Trips",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        if (isUpcoming) {
                          _isUpcomingFilterDrawerOpen = false;
                        } else {
                          _isPastFilterDrawerOpen = false;
                        }
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Zones", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        CheckboxListTile(
                          title: const Text("All Zones"),
                          value: isAllSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (isUpcoming) {
                                _isUpcomingAllSelected = value ?? false;
                                if (_isUpcomingAllSelected) {
                                  _selectedUpcomingZones.clear();
                                }
                              } else {
                                _isPastAllSelected = value ?? false;
                                if (_isPastAllSelected) {
                                  _selectedPastZones.clear();
                                }
                              }
                            });
                          },
                        ),
                        ..._zoneList
                            .where((zone) => zone.id != '1')
                            .map((zone) => CheckboxListTile(
                          title: Text(zone.zoneName ?? ''),
                          value: selectedZones.contains(zone),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                if (isUpcoming) {
                                  _selectedUpcomingZones.add(zone);
                                  _isUpcomingAllSelected = false;
                                } else {
                                  _selectedPastZones.add(zone);
                                  _isPastAllSelected = false;
                                }
                              } else {
                                if (isUpcoming) {
                                  _selectedUpcomingZones.remove(zone);
                                } else {
                                  _selectedPastZones.remove(zone);
                                }
                              }
                            });
                          },
                        ))
                            .toList(),
                        const SizedBox(height: 20),
                        const Text("Date Range",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildDateField(
                            label: 'Start Date *',
                            date: startDate,
                            onPicked: (pickedDate) {
                              setState(() {
                                if (isUpcoming) {
                                  _upcomingStartDate = pickedDate;
                                  if (_upcomingEndDate != null &&
                                      _upcomingStartDate!.isAfter(_upcomingEndDate!)) {
                                    _upcomingEndDate = _upcomingStartDate;
                                  }
                                } else {
                                  _pastStartDate = pickedDate;
                                  if (_pastEndDate != null &&
                                      _pastStartDate!.isAfter(_pastEndDate!)) {
                                    _pastEndDate = _pastStartDate;
                                  }
                                }
                              });
                            }),
                        const SizedBox(height: 16),
                        _buildDateField(
                            label: 'End Date *',
                            date: endDate,
                            onPicked: (pickedDate) {
                              setState(() {
                                if (isUpcoming) {
                                  _upcomingEndDate = pickedDate;
                                  if (_upcomingStartDate != null &&
                                      _upcomingEndDate!.isBefore(_upcomingStartDate!)) {
                                    _upcomingStartDate = _upcomingEndDate;
                                  }
                                } else {
                                  _pastEndDate = pickedDate;
                                  if (_pastStartDate != null &&
                                      _pastEndDate!.isBefore(_pastStartDate!)) {
                                    _pastStartDate = _pastEndDate;
                                  }
                                }
                              });
                            }),
                      ],
                    ),
                  ),
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
                            if (isUpcoming) {
                              _isUpcomingFilterDrawerOpen = false;
                            } else {
                              _isPastFilterDrawerOpen = false;
                            }
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
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required Function(DateTime) onPicked,
  }) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: date != null ? DateFormat('dd/MM/yyyy').format(date) : '',
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Select $label',
        border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
        focusedBorder:
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.black26, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        labelStyle: const TextStyle(color: Colors.black45),
      ),
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          onPicked(pickedDate);
        }
      },
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
              'Trips',
              style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w500),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTripFilterTabs(),
              _buildFilterButton(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(child: Text(_error!))
                    : RefreshIndicator(
                  color: Colors.redAccent,
                  onRefresh: _fetchTrips,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 4),
                    itemCount: _selectedTabIndex == 0
                        ? _upcomingTrips.length
                        : _pastTrips.length,
                    itemBuilder: (context, index) => _buildTripCard(
                        _selectedTabIndex == 0
                            ? _upcomingTrips[index]
                            : _pastTrips[index]),
                  ),
                ),
              ),
            ],
          ),
          if (_isUpcomingFilterDrawerOpen) _buildFilterDrawer(true),
          if (_isPastFilterDrawerOpen) _buildFilterDrawer(false),
        ],
      ),
    );
  }
}