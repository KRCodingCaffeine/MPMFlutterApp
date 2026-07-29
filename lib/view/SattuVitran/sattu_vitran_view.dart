import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:mpm/model/SattuVitran/SattuVitranList/VitranData.dart';
import 'package:mpm/model/SattuVitran/SattuVitranList/VitranModelClass.dart';
import 'package:mpm/model/SattuVitran/VitranMemberOrderList/VitranMemberOrderListData.dart';
import 'package:mpm/repository/SattuVitran/SattuVitranList/vitran_repository.dart';
import 'package:mpm/repository/SattuVitran/VitranMemberOrderListRepository/vitran_member_order_list_repo.dart';
import 'package:mpm/view/SattuVitran/sattu_vitran_detail.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/SattuVitran/sattu_vitran_member_order.dart';
import 'package:mpm/model/SattuVitran/VitranMemberOrderList/VitranMemberOrderListModelClass.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class SattuVitranView extends StatefulWidget {
  const SattuVitranView({super.key});

  @override
  State<SattuVitranView> createState() => _SattuVitranViewState();
}

class _SattuVitranViewState extends State<SattuVitranView> {
  final Color _brandColor =
  ColorHelperClass.getColorFromHex(ColorResources.logo_color);

  late Future<VitranModelClass> _vitranFuture;
  late Future<VitranMemberOrderListModelClass?> _recentOrderFuture;

  @override
  void initState() {
    super.initState();
    _vitranFuture = _fetchVitranList();
    _recentOrderFuture = _fetchRecentOrder();
  }

  Future<VitranModelClass> _fetchVitranList() async {
    final response = await VitranRepository().fetchVitran(limit: 10);
    return VitranModelClass.fromJson(response);
  }

  Future<VitranMemberOrderListModelClass?> _fetchRecentOrder() async {
    try {
      final profileController = Get.find<UdateProfileController>();
      final String memberId = profileController.memberId.value;

      if (memberId.isEmpty) {
        debugPrint("Member ID is empty. Cannot fetch recent orders.");
        return null;
      }

      final response = await VitranMemberOrderListRepository()
          .fetchVitranMemberOrders(memberId: memberId);

      final model = VitranMemberOrderListModelClass.fromJson(response);

      if (model.data != null && model.data!.isNotEmpty) {
        return model;
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching recent order: $e");
      return null;
    }
  }

  Future<void> _refreshVitranList() async {
    setState(() {
      _vitranFuture = _fetchVitranList();
      _recentOrderFuture = _fetchRecentOrder();
    });
    await _vitranFuture;
    await _recentOrderFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _brandColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Vitran',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Vitranmemberorder(),
                  ),
                );
              },
              icon: const Icon(
                Icons.receipt_long,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                'My Orders',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<VitranModelClass>(
        future: _vitranFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildMessageState(
              message: 'Failed to load sattu vitran list',
              actionLabel: 'Retry',
              onActionTap: _refreshVitranList,
            );
          }

          final vitranList = snapshot.data?.data ?? [];

          if (vitranList.isEmpty) {
            return _buildMessageState(
              message: 'No sattu vitran found',
              actionLabel: 'Refresh',
              onActionTap: _refreshVitranList,
            );
          }

          return RefreshIndicator(
            color: _brandColor,
            onRefresh: _refreshVitranList,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Fetch the recent order and display the banner
                  FutureBuilder<VitranMemberOrderListModelClass?>(
                    future: _recentOrderFuture,
                    builder: (context, orderSnapshot) {
                      if (orderSnapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(height: 0);
                      }

                      if (orderSnapshot.hasData && orderSnapshot.data != null) {
                        final orders = orderSnapshot.data!.data!;
                        if (orders.isNotEmpty) {
                          return _buildRecentOrderBanner(orders.first);
                        }
                      }
                      return const SizedBox(height: 0);
                    },
                  ),

                  // Existing Vitran List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 12, bottom: 16),
                    itemCount: vitranList.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(vitranList[index]);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- UPDATED BANNER WIDGET WITH TOTAL COST ---
  Widget _buildRecentOrderBanner(VitranMemberOrderListData order) {
    String formattedDate = _formatDate(order.distributionDate);
    String formattedStartTime = _formatTime(order.distributionStartTime);
    String formattedEndTime = _formatTime(order.distributionEndTime);
    String formattedTotal = order.totalCost != null
        ? '₹ ${order.totalCost!.toStringAsFixed(0)}'
        : '₹ 0';

    // Format time range
    String timeRange = '';
    if (formattedStartTime != '-' && formattedEndTime != '-') {
      timeRange = '$formattedStartTime - $formattedEndTime';
    } else if (formattedStartTime != '-') {
      timeRange = 'Starts at $formattedStartTime';
    } else if (formattedEndTime != '-') {
      timeRange = 'Ends at $formattedEndTime';
    } else {
      timeRange = '-';
    }

    return GestureDetector(
      onTap: () {
        // Navigate to order details or my orders
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const Vitranmemberorder(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Your Recent Order',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                // Total Cost Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _brandColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _brandColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    formattedTotal,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.receipt,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Order #${order.vitranOrderCode ?? 'N/A'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.vitranDistributionCenterName ?? 'N/A',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 4),
                Text(
                  'Date: $formattedDate',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Time: $timeRange',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.green.shade800,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to view all orders',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// --- HELPER: Format Time ---
  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return "-";
    try {
      final timeParts = time.split(':');
      if (timeParts.length >= 2) {
        final hour = int.parse(timeParts[0]);
        final minute = timeParts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return "$hour12:$minute $period";
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  // --- HELPER: Format Date ---
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      final parsedDate = DateTime.tryParse(date);
      if (parsedDate == null) return date;
      return DateFormat("dd MMM yyyy").format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Widget _buildMessageState({
    required String message,
    required String actionLabel,
    required Future<void> Function() onActionTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onActionTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(VitranData vitran) {
    final coordinatorName = _getCoordinatorName(vitran);
    final description =
    _displayText(vitran.vitranDescription, fallback: 'No description');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            final vitranId = vitran.vitranId;
            if (vitranId == null || vitranId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vitran id not found')),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SattuVitranDetailPage(
                  event: SattuVitranEvent(
                    vitranId: vitranId,
                    name: _displayText(
                      vitran.vitranName,
                      fallback: 'Sattu Vitran',
                    ),
                    date: DateTime.now(),
                    coordinatorName: coordinatorName,
                    description: description,
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _brandColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      "assets/images/sattu_vitran.svg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayText(vitran.vitranName,
                            fallback: 'Sattu Vitran'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'By: $coordinatorName',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCoordinatorName(VitranData vitran) {
    for (final samiti in vitran.samitiOrganisers ?? []) {
      final organizerName = samiti.samitiSubCategoryName;
      if (organizerName != null && organizerName.isNotEmpty) {
        return organizerName;
      }
    }
    for (final organiser in vitran.samitiOrganisers ?? []) {
      final samitiName = organiser.samitiName;
      if (samitiName != null && samitiName.isNotEmpty) {
        return samitiName;
      }
    }
    return 'Not assigned';
  }

  String _displayText(String? value, {required String fallback}) {
    final trimmedValue = value?.trim();
    return trimmedValue == null || trimmedValue.isEmpty
        ? fallback
        : trimmedValue;
  }
}