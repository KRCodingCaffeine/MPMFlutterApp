import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/DashBoardEvents/DashBoardEventsData.dart';
import 'package:mpm/model/GetEventsList/GetEventsListData.dart';
import 'package:mpm/model/Offer/OfferData.dart';
import 'package:mpm/model/OfferSubcategory/OfferSubcatData.dart';
import 'package:mpm/repository/dashboard_events_repository/dashboard_events_repo.dart';
import 'package:mpm/repository/qr_code_scanner_repository/qr_code_scanner_repo.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/view/DiscountOfferDetailPage.dart';
import 'package:mpm/view/payment/PaymentScreen.dart';
import 'package:mpm/view/Events/event_detail_page.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/offer/OfferController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  final regiController = Get.put(NewMemberController());
  final controller = Get.put(UdateProfileController());
  final offerController = Get.put(OfferController());
  late AnimationController _tagController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  final double _cardWidth = 360.0;
  final double _cardSpacing = 16.0;
  late Timer _timer;
  double screenWidth = 0.0;

  String _formatDate(String dateString) {
    try {
      final date = DateFormat('dd-MM-yyyy').parse(dateString);
      return DateFormat('d-M-y').format(date);
    } catch (e) {
      debugPrint("Date parse error: $e");
      return dateString;
    }
  }

  List<DashboardEventData> dashboardEvents = [];
  int? memberId;
  List<Map<String, dynamic>> get gridItems {
    final items = [
      {'icon': Images.user, 'label': 'My Profile'},
      {'icon': Images.makenewmember, 'label': 'Make New Member'},
      {'icon': Images.discount, 'label': 'Discounts & Offers'},
      {'icon': Images.events, 'label': 'Events'},
      {'icon': Images.saraswani, 'label': 'Sarawani'},
    ];

    if (memberId == 1 || memberId == 2) {
      items.add({'icon': Images.qr_code, 'label': 'QR Code Scanner'});
    }

    return items;
  }

  @override
  void initState() {
    super.initState();
    controller.getUserProfile().then((_) {
      memberId = int.tryParse(controller.memberId.value);
      if (memberId != null && memberId! > 0) {
        fetchDashboardEvents(memberId!);
      } else {
        debugPrint("Invalid or missing member ID.");
      }
    });

    offerController.fetchOffers();

    _tagController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _tagController, curve: Curves.easeInOut),
    );

    ever(controller.emailVerifyStatus, (value) {
      if (value == "1") {
        // Email verified, no need to show banner
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
        if (_scrollController.hasClients) {
          final double scrollAmount = _cardWidth + _cardSpacing;
          final double maxScroll = _scrollController.position.maxScrollExtent;
          final double currentScroll = _scrollController.offset;

          if (currentScroll + scrollAmount >= maxScroll) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          } else {
            _scrollController.animateTo(
              currentScroll + scrollAmount,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          }
        }
      });
    });
  }

  Future<void> fetchDashboardEvents(int memberId) async {
    try {
      final response = await DashboardEventsRepository().getDashboardEvents(memberId);
      if (response.status == true && response.data != null) {
        setState(() {
          dashboardEvents = response.data!;
        });
      } else {
        debugPrint("Failed to load dashboard events: ${response.message}");
      }
    } catch (e) {
      debugPrint("Dashboard events fetch error: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => int.tryParse(controller.membershipApprovalStatusId.value) != null &&
              int.parse(controller.membershipApprovalStatusId.value) < 6
              ? _buildMembershipNotice()
              : const SizedBox.shrink()),

          Obx(() => Visibility(
              visible: controller.showDashboardReviewFlag.value,
              child: _buildJanganaNotice())),

          Obx(() => Visibility(
            visible: controller.showEmailVerifyBanner.value,
            child: _buildEmailVerifyBanner(),
          )),

          Center(
            child: Obx(() => Visibility(
              visible: controller.isPay.value,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PaymentScreen(paymentAmount: '1')),
                    );
                  },
                  child: Text("Pay Now", style: TextStyleClass.white14style),
                ),
              ),
            )),
          ),

          _buildGridView(),

          Obx(() {
            if (offerController.isLoading.value) {
              return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
            }
            if (offerController.offerList.isEmpty) {
              return const SizedBox.shrink();
            }
            return _buildBannerCard(offerController.offerList.first);
          }),

          _buildAdvertisementTitle(),
          _buildDashboardEventsList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBannerCard(OfferData offer) {
    Widget? dateTag;
    if (offer.validFrom != null || offer.validTo != null) {
      String dateText = '';
      if (offer.validFrom != null && offer.validTo != null) {
        dateText = "Till : ${_formatDate(offer.validFrom!)} - ${_formatDate(offer.validTo!)}";
      } else if (offer.validTo != null) {
        dateText = "Till : ${_formatDate(offer.validTo!)}";
      } else if (offer.validFrom != null) {
        dateText = "From : ${_formatDate(offer.validFrom!)}";
      }

      if (dateText.isNotEmpty) {
        dateTag = _buildTag(
          dateText,
          Colors.grey[300]!,
          textColor: Colors.black45,
          fontSize: 10,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        );
      }
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiscountOfferDetailPage(offer: offer),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left Logo & Org Name
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (offer.orgLogo != null && offer.orgLogo!.isNotEmpty)
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        offer.orgLogo!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildDefaultLogo(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                        : _buildDefaultLogo(),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 95,
                      child: Text(
                        offer.orgName ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),
                Container(width: 1, color: Colors.grey[400]),
                const SizedBox(width: 12),

                // Offer details
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.offerDiscountName ?? 'No title',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              offer.offerDescription ?? 'No description',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            if (dateTag != null) dateTag!,
                          ],
                        ),
                      ),

                      // Animated "Special Offer" tag
                      Positioned(
                        top: 4,
                        right: 0,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildTag(
                            'Special Offer',
                            ColorHelperClass.getColorFromHex(ColorResources.red_color),
                            textColor: Colors.white,
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, size: 30, color: Colors.grey),
    );
  }

  Widget _buildMembershipNotice() {
    final status = controller.membershipTypeId.value.trim();
    final message = {
      '2': "Your payment is pending.",
      '3': "We received your payment and it's under approval.",
      '4': "Your membership is under Sangathan Samiti review.",
      '5': "Your membership is under Vyaspathika Samiti review.",
    }[status] ?? "Membership status unknown. Please check your account.";

    return _buildNoticeContainer(message);
  }

  Widget _buildJanganaNotice() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, RouteNames.profile),
      child: _buildNoticeContainer("Your Janaganana is pending. Please click here to complete it."),
    );
  }

  Widget _buildEmailVerifyBanner() {
    return Obx(() {
      if (controller.emailVerifyStatus.value != "0") {
        return const SizedBox.shrink();
      }

      return GestureDetector(
        onTap: () => _showVerificationDialog(context),
        child: _buildNoticeContainer("Your email is not verified. Please click here to verify it."),
      );
    });
  }

  void _showVerificationDialog(BuildContext context) {
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
                "Email Verification",
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
            "We'll send a verification link to your email address. Please check your inbox.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
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
                controller.sendVerificationEmail();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoticeContainer(String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Color(0xFFe61428)),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.black))),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: GridView.builder(
          itemCount: gridItems.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = gridItems[index];
            return GestureDetector(
              onTap: () => _handleGridItemClick(item['label']),
              child: Card(
                color: Colors.white,
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(item['icon'], height: 30, width: 30),
                    const SizedBox(height: 8),
                    Text(
                      item['label'],
                      style: TextStyleClass.pink14style.copyWith(fontSize: 10),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleGridItemClick(String label) {
    switch (label) {
      case "Sarawani":
        Navigator.pushNamed(context, RouteNames.saraswani_label);
        break;
      case "Make New Member":
        regiController.isRelation.value = false;
        Navigator.pushNamed(context, RouteNames.newMember);
        break;
      case "My Profile":
        regiController.isRelation.value = false;
        Navigator.pushNamed(context, RouteNames.profile);
        break;
      case "Discounts & Offers":
        Navigator.pushNamed(context, RouteNames.discount_offer_view);
        break;
      case "Events":
        Navigator.pushNamed(context, RouteNames.event_view);
        break;
      case "QR Code Scanner":
         Navigator.pushNamed(context, RouteNames.qr_code);
         break;
      // case "QR Code Scanner":
      //   _showAttendanceMarkedDialog(context);
      //   break;
    }
  }

  void _showAttendanceMarkedDialog(BuildContext context) {
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
                "Attendance Marked",
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
            "Member attendance has been successfully marked.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAdvertisementTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Text("Advertisement", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDashboardEventsList() {
    if (dashboardEvents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: dashboardEvents.length > 1
          ? ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dashboardEvents.length,
        itemBuilder: (context, index) {
          final event = dashboardEvents[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailPage(eventId: event.id?.toString() ?? ''),
                ),
              );
            },
            child: _buildEventCard(event),
          );
        },
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailPage(eventId: dashboardEvents.first.id?.toString() ?? ''),
              ),
            );
          },
          child: _buildEventCard(dashboardEvents.first),
        ),
      ),
    );
  }

  Widget _buildEventCard(DashboardEventData event) {
    Widget? dateTag;
    if (event.date != null && event.date!.isNotEmpty) {
      final dateText = "Till : ${_formatDate(event.date!)}";
      dateTag = _buildTag(
        dateText,
        Colors.grey[300]!,
        textColor: Colors.black45,
        fontSize: 10,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      );
    }

    return Container(
      width: 360,
      margin: const EdgeInsets.only(right: 16.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              event.thumbnailImg ?? '',
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 80,
                width: 80,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event.title ?? '',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Hosted by ${event.organizedBy ?? ''}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (dateTag != null) dateTag!,
              ],
            ),
          ),
        ],
      ),
    );
  }

  EventData convertToEventData(DashboardEventData dashboardEvent) {
    return EventData(
      eventId: dashboardEvent.id?.toString(),
      eventName: dashboardEvent.title,
      eventImage: dashboardEvent.thumbnailImg,
      dateStartsFrom: dashboardEvent.date,
      eventDescription: dashboardEvent.desc ?? '',
      eventOrganiserName: dashboardEvent.organizedBy,
    );
  }

  Widget _buildTag(String text, Color bgColor,
      {Color textColor = Colors.white, double fontSize = 12, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, color: textColor),
      ),
    );
  }
}