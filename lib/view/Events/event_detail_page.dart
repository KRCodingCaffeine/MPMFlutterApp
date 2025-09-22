import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/model/EventRegesitration/EventRegistrationData.dart';
import 'package:mpm/model/GetEventDetailsById/GetEventDetailsByIdData.dart';
import 'package:mpm/model/GetEventsList/EventDateTimeData.dart';
import 'package:mpm/model/GetEventsList/GetEventsListData.dart';
import 'package:mpm/repository/event_register_repository/event_register_repo.dart';
import 'package:mpm/repository/get_even_details_by_id_repository/get_even_details_by_id_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:dio/dio.dart';
import 'package:mpm/view/Events/event_prize_page.dart';
import 'package:mpm/view/Events/event_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mpm/utils/Session.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunchUrl, launchUrl;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:mpm/view/Events/YouTubeBottomSheet.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;

  const EventDetailPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

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

class _EventDetailPageState extends State<EventDetailPage> {
  final Dio _dio = Dio();
  final GetEventDetailByIdRepository _eventDetailRepo =
      GetEventDetailByIdRepository();
  final EventRegistrationRepository _registrationRepo =
      EventRegistrationRepository();

  bool _isLoading = true;
  bool _isDownloading = false;
  int _downloadProgress = 0;
  bool _isRegistering = false;
  bool _isRegistered = false;
  bool _isPastEvent = false;
  GetEventDetailsByIdData? _eventDetails;

  int _foodBoxCount = 0;
  final _foodBoxController = TextEditingController();

  int? _attendeeId;

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  @override
  void dispose() {
    _foodBoxController.dispose();
    super.dispose();
  }

  Future<void> _fetchEventDetails() async {
    try {
      final response = await _eventDetailRepo.EventsDetailById(widget.eventId);
      if (response['status'] == true && response['data'] != null) {
        setState(() {
          _eventDetails = GetEventDetailsByIdData.fromJson(response['data']);
          _isLoading = false;
          _checkEventDate();
          _checkRegistrationStatus();
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

  void _checkEventDate() {
    if (_eventDetails?.dateEndTo == null) return;

    final eventDate = DateTime.tryParse(_eventDetails!.dateEndTo!);
    if (eventDate != null) {
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      setState(() {
        _isPastEvent = eventDate.isBefore(todayMidnight);
      });
    }
  }

  Future<void> _checkRegistrationStatus() async {
    // Implement your registration status check logic here
    setState(() {
      _isRegistered = false;
    });
  }

  Future<void> _showRegistrationConfirmationDialog() async {
    bool showFoodDialog =
        _eventDetails?.eventsTypeId != '1' && _eventDetails?.hasFood == '1';

    Future<bool> _showFoodDialog(BuildContext context) async {
      String? selectedFoodOption;
      final TextEditingController _foodBoxController = TextEditingController();

      final shouldProceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "Registration Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Do you want to request food coupons for this event?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedFoodOption,
                      decoration: const InputDecoration(
                        labelText: "Food Coupons",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black38, width: 1),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      items: ["Yes", "No"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFoodOption = value;
                          if (selectedFoodOption == "No") {
                            _foodBoxCount = 0;
                            _foodBoxController.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
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
                              _foodBoxCount = 2;
                            } else {
                              _foodBoxCount = num;
                            }
                          } else {
                            _foodBoxCount = 0;
                          }
                        },
                      ),
                  ],
                ),
                actions: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedFoodOption == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please select Yes or No')),
                        );
                        return;
                      }
                      if (selectedFoodOption == "Yes" &&
                          (_foodBoxCount <= 0 || _foodBoxCount > 2)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please enter a valid number of boxes (1-2)')),
                        );
                        return;
                      }
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );

      return shouldProceed ?? false;
    }

    Future<void> _showFinalConfirmationDialog() async {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "Confirm Registration",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
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
              "Are you sure you want to register for this event?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorHelperClass.getColorFromHex(
                      ColorResources.red_color),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _registerForEvent();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorHelperClass.getColorFromHex(
                      ColorResources.red_color),
                ),
                child: const Text(
                  "Yes, Register",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }

    if (showFoodDialog) {
      bool proceed = await _showFoodDialog(context);
      if (proceed) {
        await _showFinalConfirmationDialog();
      }
    } else {
      await _showFinalConfirmationDialog();
    }
  }

  Future<void> _showStudentPrizeConfirmationDialog(int eventTypeId, int attendeeId, int memberId) async {
    if (eventTypeId != 3) {
      _registerForEvent();
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Confirmation",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
            "Do you want to register your children for award function?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSuccessDialog('Successfully registered for this event');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final userData = await SessionManager.getSession();

                await _registerForEvent();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentPrizeFormPage(
                      eventId: int.parse(_eventDetails!.eventId!),
                      attendeeId: attendeeId!,
                      memberId: int.tryParse(userData!.memberId.toString())!,
                      addedBy: int.tryParse(userData!.memberId.toString())!,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
              ),
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerForEvent() async {
    if (_isRegistering || _isRegistered || _eventDetails == null) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      final userData = await SessionManager.getSession();
      if (userData == null || userData.memberId == null) {
        throw Exception('User not logged in');
      }

      final now = DateTime.now();
      final registrationData = EventRegistrationData(
        memberId: int.tryParse(userData.memberId.toString()),
        eventId: int.tryParse(_eventDetails!.eventId ?? ''),
        eventRegisteredDate: DateFormat('yyyy-MM-dd').format(now),
        addedBy: int.tryParse(userData.memberId.toString()),
        dateAdded: DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
        noOfFoodContainer: (_eventDetails?.eventsTypeId != '1' &&
                _eventDetails?.hasFood == '1')
            ? _foodBoxCount
            : 0,
      );
      debugPrint('Sending food count: ${registrationData.noOfFoodContainer}');
      final response =
          await _registrationRepo.registerForEvent(registrationData);

      if (response['status'] == true) {
        setState(() {
          _isRegistered = true;
        });
        // return int.tryParse(response['data']?['attendee_id'] ?? '');
        final attendeeId = int.tryParse(response['data']['attendee_id'] ?? 0);
        final memberId = int.tryParse(userData.memberId.toString()) ?? 0;

        if (_eventDetails?.eventsTypeId == '3') {
          await _showStudentPrizeConfirmationDialog(3, attendeeId ?? 0, memberId);
        } else {
          await _showSuccessDialog('Successfully registered for event');
        }
      } else {
        throw Exception('Failed to register for event');
      }
    } catch (e) {
      await _showErrorDialog('Registration failed: ${e.toString()}');
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Success",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _redirectToEventsList();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Error",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: const Text(
            "Something went wrong. Please try again later.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _redirectToEventsList() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _buildEventInfoList() {
    final slots = _eventDetails?.allEventDates ?? [];

    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return 'Unknown Date';
      try {
        return DateFormat('EEEE, MMMM d, y').format(DateTime.parse(dateStr));
      } catch (_) {
        return 'Invalid Date';
      }
    }

    String formatTime(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return '';
      try {
        final parsedTime = DateFormat("HH:mm:ss").parse(timeStr);
        return DateFormat("h:mm a").format(parsedTime);
      } catch (_) {
        return '';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Date & Time:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        ...slots.map((slot) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.black),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        formatDate(slot.eventDate),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (slot.eventStartTime != null &&
                          slot.eventStartTime!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Text('from ',
                            style: TextStyle(color: Colors.grey)),
                        Text(formatTime(slot.eventStartTime)),
                      ],
                      if (slot.eventEndTime != null &&
                          slot.eventEndTime!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Text('to ', style: TextStyle(color: Colors.grey)),
                        Text(formatTime(slot.eventEndTime)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEventCostInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Cost:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        if (_eventDetails?.eventCostType != null &&
            _eventDetails!.eventCostType!.isNotEmpty) ...[
          Row(
            children: [
              const Text(
                'Contact organisers for more details.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRegisterButton() {
    if (_isPastEvent) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRegistered
                ? Colors.redAccent
                : ColorHelperClass.getColorFromHex(ColorResources.red_color),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _isRegistered ? null : _showRegistrationConfirmationDialog,
          child: _isRegistering
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  _isRegistered ? "Registered" : "Register Here",
                  style: const TextStyle(fontSize: 16),
                ),
        ),
      ),
    );
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        return true;
      } else if (sdkInt >= 30) {
        var status = await Permission.storage.request();
        if (status.isGranted) return true;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Storage permission is needed to download the file.')),
        );
        return false;
      } else {
        var status = await Permission.storage.request();
        if (status.isGranted) return true;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Storage permission is needed to download the file.')),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _downloadAndOpenPdf(String url, String fileName) async {
    final permissionStatus = await _requestPermission();
    if (!permissionStatus) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      Directory? directory = Platform.isAndroid
          ? (await getExternalStorageDirectory())!
          : await getApplicationDocumentsDirectory();

      String filePath = "${directory!.path}/$fileName";

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            int newProgress = ((received / total) * 100).toInt();
            setState(() {
              _downloadProgress = newProgress;
            });
          }
        },
      );

      setState(() {
        _isDownloading = false;
      });

      _showDownloadDialog(context, fileName, filePath);

    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  void _showDownloadDialog(BuildContext context, String fileName, String filePath) {
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
            children: [
              const Text(
                "Download Complete",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),
          content: Text(
            "$fileName has been downloaded successfully.",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Close"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                OpenFilex.open(filePath);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("View"),
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
        if (_eventDetails?.eventOrganiserName != null) ...[
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
                        text: _eventDetails!.eventOrganiserName!
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
        if (_eventDetails?.eventOrganiserMobile != null) ...[
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                _eventDetails!.eventOrganiserMobile!,
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor:
              ColorHelperClass.getColorFromHex(ColorResources.logo_color),
          title: const Text('Event Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_eventDetails == null) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor:
              ColorHelperClass.getColorFromHex(ColorResources.logo_color),
          title: const Text('Event Details'),
        ),
        body: const Center(child: Text('Failed to load event details')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              _eventDetails!.eventName ?? 'Event Details',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_eventDetails!.eventImage != null &&
                _eventDetails!.eventImage!.isNotEmpty) ...[
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
                          _eventDetails!.eventImage!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child:
                                Icon(Icons.broken_image, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 500,
                        maxWidth: 400,
                      ),
                      child: FutureBuilder<Size>(
                        future: _getImageSize(_eventDetails!.eventImage!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else if (snapshot.hasError || !snapshot.hasData) {
                            return const SizedBox.shrink();
                          } else {
                            final imageSize = snapshot.data!;
                            final isLandscape =
                                imageSize.width > imageSize.height;

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _eventDetails!.eventImage!,
                                fit: isLandscape
                                    ? BoxFit.fitWidth
                                    : BoxFit.cover,
                                width: double.infinity,
                                height: isLandscape ? 250 : null,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 80),
                              ),
                            );
                          }
                        },
                      )),
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Event Description:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _eventDetails!.eventDescription ??
                  'No event description available',
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (_isPastEvent &&
                _eventDetails!.youtubeUrl != null &&
                _eventDetails!.youtubeUrl!.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorHelperClass.getColorFromHex(
                        ColorResources.red_color),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.play_circle_fill),
                  label: const Text("View Events Video"),
                  onPressed: () {
                    final url = _eventDetails!.youtubeUrl;
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.black,
                      builder: (_) => YouTubeBottomSheet(
                        youtubeUrl: url!,
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            _buildEventInfoList(),
            const SizedBox(height: 24),
            if (_eventDetails!.eventCostType?.toLowerCase() != 'free') ...[
              _buildEventCostInfo(),
              const SizedBox(height: 24),
            ],
            if (_eventDetails!.eventOrganiserName != null ||
                _eventDetails!.eventOrganiserMobile != null) ...[
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 16),
              _buildOrganiserInfo(),
              const SizedBox(height: 24),
            ],
            if (_eventDetails!.eventTermsAndConditionDocument != null &&
                _eventDetails!.eventTermsAndConditionDocument!.isNotEmpty) ...[
              const Text(
                'Events Document:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final docUrl = _eventDetails!.eventTermsAndConditionDocument!;
                  final fileExtension = docUrl.split('.').last.toLowerCase();

                  if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: InteractiveViewer(
                                child: Image.network(
                                  docUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Center(
                                      child: Text('Failed to load image')),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          docUrl,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    );
                  } else if (['pdf', 'docx'].contains(fileExtension)) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        icon: Icon(
                          fileExtension == 'pdf'
                              ? Icons.picture_as_pdf
                              : Icons.description,
                          color:
                              fileExtension == 'pdf' ? Colors.red : Colors.blue,
                        ),
                        label: _isDownloading
                            ? LinearProgressIndicator(
                                value: _downloadProgress / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ColorHelperClass.getColorFromHex(
                                      ColorResources.red_color),
                                ),
                              )
                            : Text(
                                "Download & View ${fileExtension.toUpperCase()}"),
                        onPressed: _isDownloading
                            ? null
                            : () => _downloadAndOpenPdf(
                                  docUrl,
                                  'Event_Terms_${_eventDetails!.eventId}.$fileExtension',
                                ),
                      ),
                    );
                  } else {
                    return const Text(
                      "Unsupported file format",
                      style: TextStyle(color: Colors.red),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar:
          _isPastEvent ? const SizedBox.shrink() : _buildRegisterButton(),
    );
  }
}
