import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/model/SattuVitran/VitranMemberOrderList/VitranMemberOrderListData.dart';
import 'package:mpm/model/SattuVitran/VitranMemberOrderList/VitranMemberOrderListModelClass.dart';
import 'package:mpm/repository/SattuVitran/VitranMemberOrderListRepository/vitran_member_order_list_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/SattuVitran/sattu_vitran_member_order_detail.dart';

class Vitranmemberorder extends StatefulWidget {
  const Vitranmemberorder({super.key});

  @override
  State<Vitranmemberorder> createState() => _VitranmemberorderState();
}

class _VitranmemberorderState extends State<Vitranmemberorder> {
  final Color _brandColor =
  ColorHelperClass.getColorFromHex(ColorResources.logo_color);

  late Future<VitranMemberOrderListModelClass> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = _fetchOrders();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureOrders = _fetchOrders();
    });

    await _futureOrders;
  }

  Future<VitranMemberOrderListModelClass> _fetchOrders() async {
    CheckUserData2? user = await SessionManager.getSession();

    if (user == null || user.memberId == null) {
      throw Exception("Please login again");
    }

    final response =
    await VitranMemberOrderListRepository().fetchVitranMemberOrders(
      memberId: user.memberId.toString(),
    );

    return VitranMemberOrderListModelClass.fromJson(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'My Orders',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: _brandColor,
      ),
      body: FutureBuilder<VitranMemberOrderListModelClass>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Failed to load orders",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandColor,
                    ),
                  ),
                ],
              ),
            );
          }

          final List<VitranMemberOrderListData> orders =
              snapshot.data?.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No Orders Found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your orders will appear here",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: _brandColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(orders[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(VitranMemberOrderListData order) {
    final distributionDate = _formatDate(order.distributionDate);
    final distributionTime = _formatTimeRange(
      order.distributionStartTime,
      order.distributionEndTime,
    );

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _brandColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.vitranOrderCode ?? "N/A",
                          style: TextStyle(
                            color: _brandColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.vitranName ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(order.orderStatus).withOpacity(.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.orderStatus ?? "",
                    style: TextStyle(
                      color: _statusColor(order.orderStatus),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.vitranDistributionCenterName ?? "-",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 15,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Distribution Date: $distributionDate",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 15,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Distribution Time: $distributionTime",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Amount",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "₹${order.totalCost?.toStringAsFixed(0) ?? "0"}",
                  style: TextStyle(
                    color: _brandColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // View / Edit Details Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SattuVitranMemberOrderDetail(
                        vitranMemberOrderId: order.vitranMemberOrderId ?? '',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text(
                  "View / Edit Details",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  String _formatTimeRange(String? startTime, String? endTime) {
    final formattedStart = _formatTime(startTime);
    final formattedEnd = _formatTime(endTime);

    if (formattedStart == "-" && formattedEnd == "-") {
      return "-";
    } else if (formattedStart == "-") {
      return "Ends at $formattedEnd";
    } else if (formattedEnd == "-") {
      return "Starts at $formattedStart";
    } else {
      return "$formattedStart - $formattedEnd";
    }
  }

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

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "ordered":
        return Colors.orange;

      case "confirmed":
        return Colors.blue;

      case "completed":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}