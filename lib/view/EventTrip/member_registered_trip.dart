import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/EventTripModel/TripMemberRegisteredDetailById/TripMemberRegisteredDetailByIdData.dart';
import 'package:mpm/model/EventTripModel/TripMemberRegisteredDetailById/TripMemberRegisteredDetailByIdModelClass.dart';
import 'package:mpm/repository/EventTripRepository/trip_member_registered_detail_by_id_repository/trip_member_registered_detail_by_id_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/EventTrip/member_registered_trip_detail.dart';
import 'package:mpm/view/Events/member_registered_event_detail.dart' hide EventAttendeesRepository;

class RegisteredTripsListPage extends StatefulWidget {
  @override
  _RegisteredTripsListPageState createState() =>
      _RegisteredTripsListPageState();
}

class _RegisteredTripsListPageState extends State<RegisteredTripsListPage> {
  late Future<TripMemberRegisteredDetailByIdModelCLass> _registeredTripsFuture;
  final TripMemberRegisteredDetailByIdRepository _repository =
  TripMemberRegisteredDetailByIdRepository();

  List<TripMemberRegisteredDetailByIdData> _trips = [];

  String memberName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchTrips();
  }

  Future<void> _loadUserDataAndFetchTrips() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData != null) {
        final name = _getUserName(
            userData.firstName, userData.middleName, userData.lastName);

        setState(() {
          memberName = name;
          _registeredTripsFuture = _repository
              .fetchRegisteredTrips(userData.memberId.toString())
              .then((response) {
            setState(() {
              _trips = (response.data ?? []).where((trip) {
                final endDate = DateTime.tryParse(trip.tripEndDate ?? '');
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
        _registeredTripsFuture = Future.error('User data not available');
      });
    } catch (e) {
      setState(() {
        _registeredTripsFuture = Future.error(e.toString());
      });
    }
  }

  Widget _buildTripCard(TripMemberRegisteredDetailByIdData trip) {
    final parsedDate =
        DateTime.tryParse(trip.tripStartDate ?? '') ?? DateTime.now();
    final day = DateFormat('d').format(parsedDate);
    final month = DateFormat('MMM').format(parsedDate);

    final bool isCancelled =
        trip.cancelledDate != null && trip.cancelledDate!.isNotEmpty;

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
                builder: (context) => RegisteredTripsDetailPage(
                  tripReferenceCode: trip,
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
                    Text(trip.tripName ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text('Member: $memberName',
                        style:
                        TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      isCancelled
                          ? 'Cancelled on: ${_formatDate(trip.cancelledDate)}'
                          : 'Registered on: ${_formatDate(trip.registrationDate)}',
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
          'Registered Trips List',
          style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.045,
              fontWeight: FontWeight.w500),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<TripMemberRegisteredDetailByIdModelCLass>(
          future: _registeredTripsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildEmptyState();
            } else if (_trips.isEmpty) {
              return _buildEmptyState();
            } else {
              return RefreshIndicator(
                color: Colors.redAccent,
                onRefresh: _loadUserDataAndFetchTrips,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: _trips.length,
                  itemBuilder: (context, index) => _buildTripCard(_trips[index]),
                ),
              );
            }
          }),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: Colors.redAccent,
      onRefresh: _loadUserDataAndFetchTrips,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_travel, size: 34, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Not yet registered to any trip',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Register for trips from the Trips section',
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