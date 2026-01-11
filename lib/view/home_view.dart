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
import 'package:mpm/view_model/controller/notification/NotificationApiController.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  final regiController = Get.put(NewMemberController());
  final controller = Get.put(UdateProfileController());
  final offerController = Get.put(OfferController());
  late NotificationApiController notificationController;
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
      {'icon': Images.saraswani, 'label': 'Saraswani'},
      {'icon': Images.event_trip, 'label': 'Trips'},
      {'icon': Images.network, 'label': 'Networking'}
    ];

   /* if (memberId == 1 || memberId == 2 || memberId == 2040) {
      items.add({'icon': Images.network, 'label': 'Networking'});
    }*/

    if (memberId == 1 || memberId == 2) {
      items.add({'icon': Images.qr_code, 'label': 'QR Code Scanner'});
    }

    return items;
  }

  @override
  void initState() {
    super.initState();
    // Initialize notification controller safely
    if (Get.isRegistered<NotificationApiController>()) {
      notificationController = Get.find<NotificationApiController>();
    } else {
      notificationController = Get.put(NotificationApiController());
    }
    
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
        if (_scrollController.hasClients && dashboardEvents.length > 1) {
          final double cardWidth = MediaQuery.of(context).size.width * 0.9;
          final double spacing = MediaQuery.of(context).size.width * 0.04;
          final double scrollAmount = cardWidth + spacing;

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
        children: [
          // Scrollable content
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Membership notice
                  Obx(() => int.tryParse(controller.membershipApprovalStatusId.value) != null &&
                      int.parse(controller.membershipApprovalStatusId.value) < 6
                      ? _buildMembershipNotice()
                      : const SizedBox.shrink()),

                  // Jangana Notice
                  Obx(() => Visibility(
                      visible: controller.showDashboardReviewFlag.value,
                      child: _buildJanganaNotice())),

                  // Email verification banner
                  Obx(() => Visibility(
                    visible: controller.showEmailVerifyBanner.value,
                    child: _buildEmailVerifyBanner(),
                  )),

                  // Pay Now button
                  Center(
                    child: Obx(() => Visibility(
                      visible: controller.isPay.value,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PaymentScreen(paymentAmount: '1')),
                            );
                          },
                          child: Text("Pay Now", style: TextStyleClass.white14style),
                        ),
                      ),
                    )),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03,
                      vertical: 10
                    ),
                    child: GridView.builder(
                      itemCount: gridItems.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (MediaQuery.of(context).size.width ~/ 120).clamp(2, 4),
                        crossAxisSpacing: MediaQuery.of(context).size.width * 0.02,
                        mainAxisSpacing: MediaQuery.of(context).size.width * 0.02,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final item = gridItems[index];
                        final screenWidth = MediaQuery.of(context).size.width;
                        final iconSize = screenWidth * 0.08;
                        final fontSize = screenWidth * 0.040;
                        
                        // Get badge count based on menu item
                        int badgeCount = 0;
                        if (item['label'] == 'Events') {
                          badgeCount = notificationController.unreadEventCount.value;
                        } else if (item['label'] == 'Discounts & Offers') {
                          badgeCount = notificationController.unreadOfferCount.value;
                        } else if (item['label'] == 'Saraswani') {
                          badgeCount = notificationController.unreadSaraswaniCount.value;
                        } else if (item['label'] == 'Trips') {
                          badgeCount = notificationController.unreadTripsCount.value;
                        }
                        
                        return GestureDetector(
                          onTap: () => _handleGridItemClick(item['label']),
                          child: Card(
                            color: Colors.white,
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Icon with badge - wrapped in SizedBox to contain overflow
                                  SizedBox(
                                    width: iconSize + 16, // Extra space for badge
                                    height: iconSize + 16, // Extra space for badge
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.center,
                                      children: [
                                        Center(
                                          child: SvgPicture.asset(
                                            item['icon'], 
                                            height: iconSize, 
                                            width: iconSize,
                                          ),
                                        ),
                                        // Only wrap the badge in Obx
                                        if (item['label'] == 'Events' || item['label'] == 'Discounts & Offers' || item['label'] == 'Saraswani' || item['label'] == 'Trips')
                                          Obx(() {
                                            int count = 0;
                                            if (item['label'] == 'Events') {
                                              count = notificationController.unreadEventCount.value;
                                            } else if (item['label'] == 'Discounts & Offers') {
                                              count = notificationController.unreadOfferCount.value;
                                            } else if (item['label'] == 'Saraswani') {
                                              count = notificationController.unreadSaraswaniCount.value;
                                            } else if (item['label'] == 'Trips') {
                                              count = notificationController.unreadTripsCount.value;
                                            }
                                            
                                            if (count <= 0) {
                                              return const SizedBox.shrink();
                                            }
                                            
                                            return Positioned(
                                              right: 0,
                                              top: 0,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white, 
                                                    width: 2,
                                                  ),
                                                ),
                                                constraints: const BoxConstraints(
                                                  minWidth: 22,
                                                  minHeight: 22,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    count > 99 ? '99+' : count.toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.02),
                                  Flexible(
                                    child: Text(
                                      item['label'],
                                      style: TextStyleClass.pink14style.copyWith(fontSize: fontSize),
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Banner card
                  Obx(() {
                    if (offerController.isLoading.value) {
                      return const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (offerController.offerList.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _buildBannerCard(
                          offerController.offerList.first,
                        ),
                      ),
                    );
                  }),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Fade gradient at bottom to indicate scrollability
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey[100]!.withOpacity(0.0),
                            Colors.grey[100]!.withOpacity(0.5),
                            Colors.grey[100]!.withOpacity(0.9),
                            Colors.grey[100]!,
                          ],
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Fixed advertisement section at bottom
          Container(
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAdvertisementTitle(),
                _buildDashboardEventsList(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(OfferData offer) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cardHeight = screenHeight * 0.18;
    final horizontalMargin = screenWidth * 0.04;
    final cardPadding = screenWidth * 0.03;

    final titleFontSize = screenWidth * 0.045;
    final subtitleFontSize = screenWidth * 0.035;
    final buttonFontSize = screenWidth * 0.025;
    final percentFontSize = screenWidth * 0.05;

    final topCircleSize = screenWidth * 0.08;
    final bottomCircleSize = screenWidth * 0.1;
    final rightElementWidth = screenWidth * 0.15;
    final rightElementHeight = screenHeight * 0.025;

    return InkWell(
      onTap: () async {
        // Mark notifications as read for this specific offer
        if (offer.organisationOfferDiscountId != null) {
          await notificationController.markNotificationsAsReadByEventOfferId(offer.organisationOfferDiscountId!);
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiscountOfferDetailPage(offer: offer),
          ),
        );
      },
      child: Card(
        elevation: 10,
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF0D1B3D), Color(0xFF2A4C8C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -cardHeight * 0.2,
                left: -cardHeight * 0.1,
                child: Container(
                  width: cardHeight * 0.8,
                  height: cardHeight * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -cardHeight * 0.15,
                right: -cardHeight * 0.15,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Container(
                    width: cardHeight * 0.9,
                    height: cardHeight * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: cardHeight * 0.1,
                right: cardHeight * 0.2,
                child: Container(
                  width: cardHeight * 0.4,
                  height: cardHeight * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              Positioned(
                top: cardHeight * 0.1,
                left: cardHeight * 0.1,
                child: Container(
                  width: topCircleSize * 1.5,
                  height: topCircleSize * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.white.withOpacity(0.15), Colors.transparent],
                      radius: 0.8,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: cardHeight * 0.05,
                right: cardHeight * 0.05,
                child: Container(
                  width: bottomCircleSize * 1.8,
                  height: bottomCircleSize * 1.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                      radius: 0.9,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: cardHeight * 0.2,
                right: cardHeight * 0.05,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Container(
                    width: rightElementWidth * 1.2,
                    height: rightElementHeight,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            offer.offerDiscountName ?? "BEST OFFER",
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellowAccent,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  offset: const Offset(1, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: cardHeight * 0.02),
                          Text(
                              "Free Home Delivery • Arrives in 2–3 Days",
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(1, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: cardHeight * 0.04),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: cardPadding * 0.6,
                              vertical: cardHeight * 0.03,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.4),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              "ORDER NOW",
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: cardHeight * 0.1),
                      padding: EdgeInsets.all(cardPadding * 0.6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.6),
                            blurRadius: 8,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        "%",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: percentFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
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
    );
  }

  Widget _buildMembershipNotice() {
    final status = controller.membershipApprovalStatusId.value.trim();
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

  void _handleGridItemClick(String label) async {
    // Note: We no longer mark all notifications as read when clicking menu items
    // Instead, we mark specific notifications when clicking individual items
    // This allows users to see which specific items have unread notifications
    
    switch (label) {
      case "Saraswani":
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
      case "Trips":
        Navigator.pushNamed(context, RouteNames.event_trip);
        break;
      case "Networking":
        Navigator.pushNamed(context, RouteNames.networking);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.045; // 4.5% of screen width
    final horizontalPadding = screenWidth * 0.04; // 4% of screen width
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Text("Advertisement", style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDashboardEventsList() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final listHeight = screenHeight * 0.20; // 18% of screen height
    final horizontalPadding = screenWidth * 0.04; // 4% of screen width
    
    if (dashboardEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    return SizedBox(
      height: listHeight,
      child: dashboardEvents.length > 1
          ? ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: dashboardEvents.length,
        itemBuilder: (context, index) {
          final event = dashboardEvents[index];
          return GestureDetector(
            onTap: () async {
              // Mark notifications as read for this specific event
              if (event.id != null) {
                await notificationController.markNotificationsAsReadByEventOfferId(event.id!);
              }
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
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: GestureDetector(
          onTap: () async {
            // Mark notifications as read for this specific event
            if (dashboardEvents.first.id != null) {
              await notificationController.markNotificationsAsReadByEventOfferId(dashboardEvents.first.id!);
            }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9; // 85% of screen width
    final imageSize = screenWidth * 0.27; // 20% of screen width
    final fontSize = screenWidth * 0.047; // 3.5% of screen width
    final smallFontSize = screenWidth * 0.03; // 3% of screen width+
    
    Widget? dateTag;
    if (event.date != null && event.date!.isNotEmpty) {
      final dateText = "Till : ${_formatDate(event.date!)}";
      dateTag = _buildTag(
        dateText,
        Colors.grey[300]!,
        textColor: Colors.black45,
        fontSize: smallFontSize,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015, vertical: screenWidth * 0.005),
      );
    }

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.03),
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
              height: imageSize,
              width: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: imageSize,
                width: imageSize,
                color: Colors.grey[300],
                child: Icon(Icons.image_not_supported, size: imageSize * 0.4),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Container(width: 1, color: Colors.grey[400]),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event.title ?? '',
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  'Hosted by ${event.organizedBy ?? ''}',
                  style: TextStyle(color: Colors.grey[600], fontSize: smallFontSize),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenWidth * 0.01),
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