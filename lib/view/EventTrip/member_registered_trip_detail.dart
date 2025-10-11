import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/EventTripModel/AddTraveller/AddTravellerData.dart';
import 'package:mpm/model/EventTripModel/AddTraveller/AddTravellerModelClass.dart';
import 'package:mpm/model/EventTripModel/DeleteTraveller/DeleteTravellerData.dart';
import 'package:mpm/model/EventTripModel/DeleteTraveller/DeleteTravellerModelClass.dart';
import 'package:mpm/model/EventTripModel/UpdateTraveller/UpdateTravellerData.dart';
import 'package:mpm/model/EventTripModel/UpdateTraveller/UpdateTravellerModelClass.dart';
import 'package:mpm/model/EventTripModel/TripMemberRegisteredDetailById/TripMemberRegisteredDetailByIdData.dart';
import 'package:mpm/model/EventTripModel/TripMemberRegisteredDetailById/TripMemberRegisteredDetailByIdModelClass.dart';
import 'package:mpm/repository/EventTripRepository/add_traveller_repository/add_traveller_repo.dart';
import 'package:mpm/repository/EventTripRepository/cancel_trip_regsitration_repository/cancel_trip_regsitration_repo.dart';
import 'package:mpm/repository/EventTripRepository/delete_traveller_repository/delete_traveller_repo.dart';
import 'package:mpm/repository/EventTripRepository/update_traveller_repository/update_traveller_repo.dart';
import 'package:mpm/repository/EventTripRepository/trip_member_registered_detail_by_id_repository/trip_member_registered_detail_by_id_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/view/EventTrip/event_trip.dart';
import 'package:mpm/view/EventTrip/member_registered_trip.dart';

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

class RegisteredTripsDetailPage extends StatefulWidget {
  final TripMemberRegisteredDetailByIdData tripReferenceCode;

  const RegisteredTripsDetailPage({Key? key, required this.tripReferenceCode})
      : super(key: key);

  @override
  _RegisteredTripsDetailPageState createState() =>
      _RegisteredTripsDetailPageState();
}

class _RegisteredTripsDetailPageState
    extends State<RegisteredTripsDetailPage> {
  late Future<TripMemberRegisteredDetailByIdModelCLass> _registeredTripsFuture;
  final TripMemberRegisteredDetailByIdRepository _repository =
  TripMemberRegisteredDetailByIdRepository();
  final TextEditingController travellerNameController = TextEditingController();
  final AddTravellerRepository _addTravellerRepository = AddTravellerRepository();
  final DeleteTravellerRepository _deleteTravellerRepository = DeleteTravellerRepository();
  final UpdateTravellerRepository _updateTravellerRepository = UpdateTravellerRepository();
  final CancelTripRegistrationRepository _cancelTripRepo = CancelTripRegistrationRepository();

  final Rx<File?> _image = Rx<File?>(null);
  final RxString selectedMemberId = "".obs;
  final RxString selectedYear = ''.obs;

  bool _isLoading = false;
  bool _isPastTrip = false;
  int? _memberId;
  bool _isCancelled = false;
  Map<String, dynamic>? _userData;

  String get _tripName =>
      widget.tripReferenceCode.tripName ?? 'Registered Trip Details';
  String? get _tripOrganiserName =>
      widget.tripReferenceCode.tripOrganiserName;
  String? get _tripOrganiserMobile =>
      widget.tripReferenceCode.tripOrganiserMobile;
  String? get _dateStartsFrom => widget.tripReferenceCode.tripStartDate;
  String? get _dateEndTo => widget.tripReferenceCode.tripEndDate;
  String? get _tripDescription => widget.tripReferenceCode.tripDescription;
  String? get _tripCostType => widget.tripReferenceCode.tripCostType;
  String? get _tripAmount => widget.tripReferenceCode.tripAmount;
  String? get _tripRegistrationLastDate => widget.tripReferenceCode.tripRegistrationLastDate;
  List<Traveller>? get _travellers => widget.tripReferenceCode.travellers;

  String memberName = 'Loading...';
  var loading = false.obs;

  @override
  void initState() {
    super.initState();
    _fetchMemberId();
    _checkTripDate();
    _checkIfCancelled();
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

  String _getUserName(String? firstName, String? middleName, String? lastName) {
    final fName = firstName ?? '';
    final mName = middleName?.isNotEmpty == true ? ' $middleName ' : ' ';
    final lName = lastName ?? '';
    return '$fName$mName$lName'.trim();
  }

  void _checkIfCancelled() {
    setState(() {
      _isCancelled = widget.tripReferenceCode.cancelledDate != null &&
          widget.tripReferenceCode.cancelledDate!.isNotEmpty;
    });
  }

  Future<void> _showCancelConfirmationDialog() async {
    if (_isCancelled) {
      _showErrorSnackbar("Registration is already cancelled");
      return;
    }

    if (_isPastTrip) {
      _showErrorSnackbar("Cannot cancel registration for past trips");
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
            "Are you sure you want to cancel your registration for this trip?",
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
                _cancelTripRegistration();
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

  Future<void> _cancelTripRegistration() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get trip registered member ID
      final tripRegisteredMemberId = widget.tripReferenceCode.tripRegisteredMemberId;
      if (tripRegisteredMemberId == null) {
        throw Exception("Trip registration ID not available");
      }

      debugPrint("Cancelling trip registration - ID: $tripRegisteredMemberId");

      final response = await _cancelTripRepo.cancelTripRegistration(
        tripRegisteredMemberId: tripRegisteredMemberId,
      );

      if (response.status == true) {
        setState(() {
          _isCancelled = true;
          widget.tripReferenceCode.cancelledDate = DateTime.now().toIso8601String();
        });
        _showSuccessSnackbar(response.message ?? "Cancelled this trip registration successfully");
      } else {
        throw Exception(response.message ?? "Failed to cancel this trip registration");
      }
    } catch (e) {
      debugPrint("Cancel trip registration error: $e");
      _showErrorSnackbar("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => EventTripPage()),
        );
      }
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool _validateTravellerForm() {
    if (travellerNameController.text.isEmpty) {
      _showErrorSnackbar("Please enter traveller name");
      return false;
    }

    if (widget.tripReferenceCode.tripRegisteredMemberId == null) {
      _showErrorSnackbar("Trip registration ID not available");
      return false;
    }

    return true;
  }

  Future<void> _addTraveller() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData == null || userData.memberId == null) {
        throw Exception('User not logged in');
      }

      final travellerData = AddTravellerData(
        travellerName: travellerNameController.text.trim(),
        tripRegisteredMemberId: widget.tripReferenceCode.tripRegisteredMemberId,
        addedBy: userData.memberId.toString(),
      );

      debugPrint("Adding Traveller: ${travellerData.toJson()}");

      final response = await _addTravellerRepository.addTraveller(travellerData);

      if (response is Map<String, dynamic>) {
        if (response['status'] == true) {
          if (response['already_added'] == true) {
            _showAlreadyAddedDialog(response['message'] ?? "Traveller already exists");
          } else {
            await _showTravellerSuccessDialog('Traveller added successfully');
          }
        } else {
          throw Exception(response['message'] ?? 'Failed to add traveller');
        }
      } else if (response is AddTravellerModelClass) {
        if (response.status == true) {
          await _showTravellerSuccessDialog('Traveller added successfully');
        } else {
          throw Exception(response.message ?? 'Failed to add traveller');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      debugPrint("Error adding traveller: $e");
      _showErrorSnackbar("Failed to add traveller: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTraveller(Traveller traveller) async {
    try {
      if (traveller.tripTravellerId == null) {
        throw Exception('Traveller ID not available');
      }

      final userData = await SessionManager.getSession();
      if (userData == null || userData.memberId == null) {
        throw Exception('User not logged in');
      }

      final updateData = {
        'trip_traveller_id': traveller.tripTravellerId,
        'traveller_name': travellerNameController.text.trim(),
        'updated_by': userData.memberId.toString(),
      };

      debugPrint("Updating Traveller: $updateData");

      final response = await _updateTravellerRepository.updateTraveller(updateData);

      if (response.status == true) {
        await _showUpdateSuccessDialog('Traveller updated successfully');
      } else {
        throw Exception(response.message ?? 'Failed to update traveller');
      }
    } catch (e) {
      debugPrint("Error updating traveller: $e");
      _showErrorSnackbar("Failed to update traveller: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTraveller(Traveller traveller) async {
    try {
      if (traveller.tripTravellerId == null) {
        throw Exception('Traveller ID not available');
      }

      final response = await _deleteTravellerRepository.deleteTraveller(traveller.tripTravellerId!);

      if (response.status == true) {
        await _showDeleteSuccessDialog('Traveller deleted successfully');
      } else {
        throw Exception(response.message ?? 'Failed to delete traveller');
      }
    } catch (e) {
      debugPrint("Error deleting traveller: $e");
      _showErrorSnackbar("Failed to delete traveller: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showUpdateTravellerSheet(BuildContext context, Traveller traveller) async {
    travellerNameController.text = traveller.travellerName ?? '';

    await showModalBottomSheet(
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
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_validateTravellerForm()) {
                          Navigator.pop(context);
                          await _updateTraveller(traveller);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "Update",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                _buildTextField(
                  label: "Traveller Name *",
                  controller: travellerNameController,
                  type: TextInputType.text,
                  empty: "Enter traveller name",
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteTravellerConfirmation(BuildContext context, Traveller traveller) async {
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
                "Delete Traveller",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: Text(
            "Are you sure you want to delete ${traveller.travellerName ?? 'this traveller'}?",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteTraveller(traveller);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
              ),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUpdateSuccessDialog(String message) async {
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
                Navigator.pop(context, true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisteredTripsListPage(),
                  ),
                );
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

  Future<void> _showDeleteSuccessDialog(String message) async {
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
                Navigator.pop(context, true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisteredTripsListPage(),
                  ),
                );
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

  Future<void> _showTravellerSuccessDialog(String message) async {
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
                Navigator.pop(context, true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisteredTripsListPage(),
                  ),
                );
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

  Future<void> _showAlreadyAddedDialog(String message) async {
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
                "Already Added",
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
                Navigator.pop(context);
                Navigator.pop(context);
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

  void _checkTripDate() {
    if (_dateEndTo == null) return;

    final tripDate = DateTime.tryParse(_dateEndTo!);
    if (tripDate != null) {
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      setState(() {
        _isPastTrip = tripDate.isBefore(todayMidnight);
      });
    }
  }

  Widget _buildTripInfo() {
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
                formatDate(widget.tripReferenceCode.registrationDate),
              ),
              if (_isCancelled && widget.tripReferenceCode.cancelledDate != null)
                _buildRow(
                  "Cancelled on",
                  formatDate(widget.tripReferenceCode.cancelledDate),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTravellerCards() {
    final travellers = _travellers ?? [];

    if (travellers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'You are not added any traveller along with you',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      children: travellers.asMap().entries.map((entry) {
        final index = entry.key; 
        final traveller = entry.value;

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
                        '${index + 1}. ${traveller.travellerName ?? "Not Available"}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
                          _showUpdateTravellerSheet(context, traveller);
                        } else if (value == 'delete') {
                          _showDeleteTravellerConfirmation(context, traveller);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
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
                            horizontal: 10,
                            vertical: 4,
                          ),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrganiserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trip Organiser Details:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        if (_tripOrganiserName != null) ...[
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
                        text: 'Organiser: ',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      TextSpan(
                        text: _tripOrganiserName!
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
        if (_tripOrganiserMobile != null) ...[
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                _tripOrganiserMobile!,
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
              _tripName,
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
            const Text(
              'Trip Details:',
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
                    widget.tripReferenceCode.tripReferenceCode ??
                        "Not Available",
                  ),
                  _buildRow(
                    "Trip Dates",
                    _dateStartsFrom != null && _dateEndTo != null
                        ? "${DateFormat('dd MMM yyyy').format(DateTime.parse(_dateStartsFrom!))} - ${DateFormat('dd MMM yyyy').format(DateTime.parse(_dateEndTo!))}"
                        : "Dates not available",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildTripInfo(),

            // Replace this section in your build method:
            if (_travellers != null) ...[
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Travellers:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final userData = await SessionManager.getSession();
                      if (userData != null && userData.memberId != null) {
                        _showAddTravellerSheet(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unable to retrieve member details'),
                          ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _buildTravellerCards(),
            ],
            const SizedBox(height: 24),

            if (_tripOrganiserName != null ||
                _tripOrganiserMobile != null) ...[
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 16),
              _buildOrganiserInfo(),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _isCancelled || _isPastTrip
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

  void _showAddTravellerSheet(BuildContext context) {
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
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_validateTravellerForm()) {
                          await _addTraveller();
                        }
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
                _buildTextField(
                  label: "Traveller Name *",
                  controller: travellerNameController,
                  type: TextInputType.text,
                  empty: "Enter traveller name",
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
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
          border:
          const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          enabledBorder:
          const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black38, width: 1)),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return empty;
          return null;
        },
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
}