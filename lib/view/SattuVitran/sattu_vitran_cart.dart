import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/SattuVitran/GetVitranDetails/OrganizerSamitiData.dart';
import 'package:mpm/model/SattuVitran/VitranMemberOrder/VitranMemberOrderData.dart';
import 'package:mpm/model/SattuVitran/VitranMemberOrder/VitranMemberOrderModelClass.dart';
import 'package:mpm/repository/SattuVitran/VitranMemberOrderRepository/vitran_member_order_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/SattuVitran/sattu_vitran_view.dart';

class SattuVitranCartPage extends StatefulWidget {
  const SattuVitranCartPage({
    super.key,
    required this.items,
    required this.organizerSamitiList,
  });

  final List<SattuCartItem> items;
  final List<OrganizerSamitiData> organizerSamitiList;

  @override
  State<SattuVitranCartPage> createState() => _SattuVitranCartPageState();
}

class _SattuVitranCartPageState extends State<SattuVitranCartPage> {
  final Color _brandColor =
  ColorHelperClass.getColorFromHex(ColorResources.logo_color);

  String? _selectedDistributionCenterId;
  String? _loggedInMemberId;

  OrganizerSamitiData? get _selectedOrganizerSamiti {
    if (_selectedDistributionCenterId == null) return null;

    try {
      return widget.organizerSamitiList.firstWhere(
            (samiti) =>
        samiti.vitranDistributionCenterId == _selectedDistributionCenterId,
      );
    } catch (_) {
      return null;
    }
  }

  int get _totalAmount =>
      widget.items.fold(0, (sum, item) => sum + item.totalAmount);

  @override
  void initState() {
    super.initState();
    _getLoggedInMemberId();
  }

  Future<void> _getLoggedInMemberId() async {
    final userData = await SessionManager.getSession();
    if (userData != null && userData.memberId != null) {
      setState(() {
        _loggedInMemberId = userData.memberId.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _brandColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Cart',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500),
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          _buildSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Products',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...widget.items.map(_buildCartItemRow),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Distribution Place',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedDistributionCenterId,
                  dropdownColor: Colors.white,
                  // ✅ 1. Dropdown items with Sr. No.
                  items: widget.organizerSamitiList.asMap().entries.map((entry) {
                    int index = entry.key + 1; // Serial Number starts at 1
                    OrganizerSamitiData samiti = entry.value;
                    return DropdownMenuItem<String>(
                      value: samiti.vitranDistributionCenterId,
                      child: Text(
                        '$index. ${_displayText(
                          samiti.vitranDistributionCenterName,
                          fallback: 'Distribution Center',
                        )}',
                      ),
                    );
                  }).toList(),
                  // ✅ 2. Selected item display with Sr. No.
                  selectedItemBuilder: (context) {
                    return widget.organizerSamitiList.asMap().entries.map((entry) {
                      int index = entry.key + 1; // Serial Number starts at 1
                      OrganizerSamitiData samiti = entry.value;
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '$index. ${_displayText(
                              samiti.vitranDistributionCenterName,
                              fallback: 'Distribution Center',
                            )}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedDistributionCenterId = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Select distribution center',
                    hintStyle: const TextStyle(color: Colors.black),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                if (_selectedOrganizerSamiti != null) ...[
                  const SizedBox(height: 14),
                  _buildDistributionCenterDetails(_selectedOrganizerSamiti!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildSectionCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rs. $_totalAmount',
                  style: TextStyle(
                    color: _brandColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildConfirmBar(),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCartItemRow(SattuCartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Rs. ${item.unitPrice} x ${item.quantity}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Text(
            'Rs. ${item.totalAmount}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _selectedOrganizerSamiti == null || _loggedInMemberId == null
              ? null
              : _confirmOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: _brandColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[400],
            disabledForegroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Confirm',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildDistributionCenterDetails(OrganizerSamitiData samiti) {
    // Build Sanyojak display text with name and mobile
    String sanyojakDisplay = 'Not available';
    if (samiti.sanyojakName != null && samiti.sanyojakName!.isNotEmpty) {
      sanyojakDisplay = samiti.sanyojakName!;
      if (samiti.sanyojakMobile != null && samiti.sanyojakMobile!.isNotEmpty) {
        sanyojakDisplay += ' - ${samiti.sanyojakMobile}';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailText(
            title: 'Distribution Place',
            value: _displayText(
              samiti.vitranDistributionCenterName,
              fallback: 'Not available',
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailText(
            title: 'Address',
            value: _displayText(
              samiti.vitranDistributionCenterDetails,
              fallback: 'Not available',
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailText(
            title: 'Sanyojika',
            value: sanyojakDisplay,
          ),
          const SizedBox(height: 8),
          _buildDetailText(
            title: 'Contact',
            value: _displayText(
              samiti.organizerContactDetails,
              fallback: 'Not available',
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailText(
            title: 'Last Date to Order',
            value: _formatDateText(samiti.distributionEndDate),
          ),
          const SizedBox(height: 8),
          _buildDetailText(
            title: 'Distribution Date',
            value: _formatDateText(samiti.distributionDate),
          ),
          const SizedBox(height: 8),
          _buildDetailText(
            title: 'Distribution Time',
            value:
            '${_formatTimeText(samiti.distributionStartTime)} - ${_formatTimeText(samiti.distributionEndTime)}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailText({
    required String title,
    required String value,
  }) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$title: ',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmOrder() async {
    final confirm = await showDialog<bool>(
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
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart_checkout,
                    color: _brandColor,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Confirm Order",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context, false);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(
                thickness: 1,
                color: Colors.grey.shade300,
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure you want to confirm this order?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _brandColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _brandColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Rs. $_totalAmount",
                      style: TextStyle(
                        color: _brandColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
              ),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _placeOrder();
  }

  Future<void> _placeOrder() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final order = VitranMemberOrderData(
        vitranId: widget.items.first.vitranId,
        memberId: _loggedInMemberId,
        vitranDistributionCenterId: _selectedDistributionCenterId,
        orderedBy: _loggedInMemberId,
        orderStatus: "ordered",
      );

      final products = widget.items
          .map(
            (item) => {
          "product_id": item.productId,
          "product_qty": item.quantity,
          "product_cost": item.unitPrice,
          "product_unit_id": item.productUnitId ?? "1",
        },
      )
          .toList();

      debugPrint("Products being sent: ${jsonEncode(products)}");

      final response = await VitranMemberOrderRepository().placeOrder(
        order,
        jsonEncode(products),
      );

      Navigator.pop(context);

      final model = VitranMemberOrderModelClass.fromJson(response);

      if (model.status == true) {
        final snackBar = SnackBar(
          content: Text(model.message ?? "Order updated successfully!"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 30),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // Navigate to SattuVitranView after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SattuVitranView()),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(model.message ?? "Failed to place order."),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  String _distributionCenterValue(OrganizerSamitiData samiti) {
    return samiti.vitranDistributionCenterId ??
        samiti.vitranOrganizerSamitiId ??
        samiti.vitranDistributionCenterName ??
        '';
  }

  String _formatDateText(String? dateText) {
    if (dateText == null || dateText.isEmpty) {
      return 'Not available';
    }
    final date = DateTime.tryParse(dateText);
    if (date == null) {
      return 'Not available';
    }
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String _formatTimeText(String? timeText) {
    final trimmedTime = timeText?.trim();
    if (trimmedTime == null || trimmedTime.isEmpty) {
      return 'Not available';
    }

    final date = DateTime.tryParse('2000-01-01 $trimmedTime');
    if (date == null) {
      return trimmedTime;
    }

    return DateFormat('hh:mm a').format(date);
  }

  String _displayText(String? value, {required String fallback}) {
    final trimmedValue = value?.trim();
    return trimmedValue == null || trimmedValue.isEmpty
        ? fallback
        : trimmedValue;
  }
}

class SattuCartItem {
  const SattuCartItem({
    required this.vitranId,
    required this.memberId,
    required this.productId,
    required this.productUnitId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  final String vitranId;
  final String memberId;
  final String productId;
  final String productUnitId;

  final String name;
  final int unitPrice;
  final int quantity;

  int get totalAmount => unitPrice * quantity;
}