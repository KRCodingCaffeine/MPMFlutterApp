import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:mpm/model/SattuVitran/GetVitranDetails/GetVitranDetailsModel.dart';
import 'package:mpm/model/SattuVitran/GetVitranDetails/OrganizerSamitiData.dart';
import 'package:mpm/model/SattuVitran/GetVitranDetails/ProductData.dart';
import 'package:mpm/model/SattuVitran/UpdateVitranMemberOrder/UpdateVitranMemberOrderData.dart';
import 'package:mpm/model/SattuVitran/VitranMemberOrder/VitranMemberOrderData.dart';
import 'package:mpm/model/SattuVitran/VitranMemberOrderDetails/VitranMemberOrderDetailsData.dart';
import 'package:mpm/model/SattuVitran/VitranMemberOrderDetails/VitranMemberOrderDetailsModelClass.dart';
import 'package:mpm/model/SattuVitran/VitranMemberOrderDetails/VitranMemberOrderProductDetailsData.dart';
import 'package:mpm/repository/SattuVitran/UpdateVitranMemberOrderRepository/update_vitran_member_order_repo.dart';
import 'package:mpm/repository/SattuVitran/VitranMemberOrderDetailsRepository/vitran_member_order_details_repo.dart';
import 'package:mpm/repository/SattuVitran/VitranDetailRepository/vitran_detail_repository.dart';
import 'package:mpm/model/SattuVitran/UpdateVitranMemberOrder/UpdateVitranMemberOrderModelClass.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class SattuVitranMemberOrderDetail extends StatefulWidget {
  final String vitranMemberOrderId;

  const SattuVitranMemberOrderDetail({
    Key? key,
    required this.vitranMemberOrderId,
  }) : super(key: key);

  @override
  State<SattuVitranMemberOrderDetail> createState() =>
      _SattuVitranMemberOrderDetailState();
}

class _SattuVitranMemberOrderDetailState
    extends State<SattuVitranMemberOrderDetail> {
  final Color _brandColor =
  ColorHelperClass.getColorFromHex(ColorResources.logo_color);

  late Future<VitranMemberOrderDetailsModelClass> _futureOrder;
  VitranMemberOrderDetailsData? _currentOrder;

  // Vitran details
  GetVitranDetailsModel? _vitranDetails;
  bool _isLoadingVitranDetails = false;

  // Bottom sheet state variables
  String? _selectedDistributionCenterId;
  List<Map<String, dynamic>> _editProducts = [];
  List<int> _editQuantities = [];

  @override
  void initState() {
    super.initState();
    _futureOrder = _loadOrder();
  }

  Future<VitranMemberOrderDetailsModelClass> _loadOrder() async {
    try {
      final response = await VitranMemberOrderDetailsRepository()
          .fetchVitranMemberOrderDetails(
        vitranMemberOrderId: widget.vitranMemberOrderId,
      );

      if (response is VitranMemberOrderDetailsModelClass) {
        return response;
      } else if (response is Map<String, dynamic>) {
        return VitranMemberOrderDetailsModelClass.fromJson(response);
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }
    } catch (e) {
      print('Error loading order: $e');
      rethrow;
    }
  }

  Future<void> _fetchVitranDetails(String vitranId) async {
    if (_vitranDetails != null) return;

    setState(() {
      _isLoadingVitranDetails = true;
    });

    try {
      final response = await VitranRepository().fetchVitranDetails(vitranId);
      final details = GetVitranDetailsModel.fromJson(response);

      setState(() {
        _vitranDetails = details;
        _isLoadingVitranDetails = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVitranDetails = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load vitran details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _futureOrder = _loadOrder();
      _vitranDetails = null;
    });
    await _futureOrder;
  }

// Method to update order
  Future<void> _updateOrder(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Build products list with quantities and IDs - FILTER OUT QUANTITY 0
      final products = _editProducts.asMap().entries
          .where((entry) {
        final index = entry.key;
        final quantity = _editQuantities[index];
        return quantity > 0; // Only include products with quantity > 0
      })
          .map((entry) {
        final index = entry.key;
        final product = entry.value;
        final quantity = _editQuantities[index];

        // Build product map with all required fields
        final productMap = {
          "product_id": product['vitranProductId'] ?? '',
          "product_qty": quantity,
          "product_cost": product['productCost'] ?? 0,
          "product_total_cost": (product['productCost'] ?? 0) * quantity,
        };

        // If product has an existing order product ID, include it for update
        if (product['vitranMemberOrderProductId'] != null &&
            product['vitranMemberOrderProductId'].toString().isNotEmpty) {
          productMap['vitran_member_order_product_id'] =
          product['vitranMemberOrderProductId'];
        }

        return productMap;
      }).toList();

      // Check if there are any products
      if (products.isEmpty) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one product with quantity > 0'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Create data model for update
      final updateData = UpdateVitranMemberOrderData(
        vitranMemberOrderId: _currentOrder!.vitranMemberOrderId,
        orderStatus: _currentOrder?.orderStatus ?? "ordered",
        vitranDistributionCenterId: _selectedDistributionCenterId,
      );

      // Call update API
      final response = await UpdateVitranMemberOrderRepository().updateOrder(
        updateData,
        jsonEncode(products),
      );

      // Close loading dialog
      Navigator.pop(context);

      final model = UpdateVitranMemberOrderModelClass.fromJson(response);

      if (model.status == true) {
        // Close bottom sheet
        Navigator.pop(context);

        // Show success SnackBar for 2 minutes (no action button)
        final snackBar = SnackBar(
          content: Text(model.message ?? "Order updated successfully!"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 30),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // Refresh order details
        _refresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(model.message ?? "Failed to update order."),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return "-";
    }
    try {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  Color _statusColor(String? status) {
    switch ((status ?? "").toLowerCase()) {
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

  IconData _statusIcon(String? status) {
    switch ((status ?? "").toLowerCase()) {
      case "ordered":
        return Icons.shopping_cart_checkout;
      case "confirmed":
        return Icons.verified;
      case "completed":
        return Icons.check_circle;
      case "cancelled":
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Widget _buildStatusChip(String? status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _statusIcon(status),
            size: 18,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            status ?? "-",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _brandColor.withOpacity(.12),
            child: Icon(
              icon,
              color: _brandColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: _brandColor.withOpacity(.10),
          child: Icon(
            icon,
            size: 18,
            color: _brandColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountCard(double amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: _brandColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            "Grand Total",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "₹ ${amount.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ],
      ),
    );
  }

  OrganizerSamitiData? _getSelectedCenter(List<OrganizerSamitiData>? centers) {
    if (centers == null || _selectedDistributionCenterId == null) return null;
    try {
      return centers.firstWhere(
            (c) => c.vitranDistributionCenterId == _selectedDistributionCenterId,
      );
    } catch (_) {
      return null;
    }
  }

  void _showEditBottomSheet(VitranMemberOrderDetailsData order) async {
    // Fetch vitran details if not already fetched
    if (_vitranDetails == null && order.vitranId != null) {
      await _fetchVitranDetails(order.vitranId!);
    }

    // Initialize edit data
    _selectedDistributionCenterId = order.vitranDistributionCenterId;

    // Get products from vitran details or use existing order products
    final List<ProductData>? vitranProducts = _vitranDetails?.data?.products;
    if (vitranProducts != null && vitranProducts.isNotEmpty) {
      _editProducts = vitranProducts.map((product) {
        VitranMemberOrderProductDetailsData? orderProduct;
        if (order.products != null) {
          try {
            orderProduct = order.products!.firstWhere(
                  (p) => p.productName == product.productName,
            );
          } catch (_) {
            orderProduct = null;
          }
        }

        return {
          'productName': product.productName ?? '-',
          'productDescription': product.productDescription ?? '', // Added description
          'productCost': double.tryParse(product.productCost ?? '0') ?? 0,
          'productUnitDisplayName': product.productUnitDisplayName ?? '',
          'productQty': orderProduct?.productQty ?? 0,
          'productTotalCost': orderProduct?.productTotalCost ?? 0,
          'vitranProductId': product.vitranProductId,
          'productUnitId': product.vitranProductUnitId,
          'vitranMemberOrderProductId': orderProduct?.vitranMemberOrderProductId,
        };
      }).toList();
    } else {
      _editProducts = order.products?.map((product) {
        return {
          'productName': product.productName ?? '-',
          'productDescription': product.productDescription ?? '', // Added description
          'productCost': product.productCost ?? 0,
          'productUnitDisplayName': product.productUnitDisplayName ?? '',
          'productQty': product.productQty ?? 0,
          'productTotalCost': product.productTotalCost ?? 0,
          'vitranMemberOrderProductId': product.vitranMemberOrderProductId,
          'productUnitId': product.productUnitId ?? "1",
        };
      }).toList() ?? [];
    }
    _editQuantities = _editProducts.map((p) => p['productQty'] as int).toList();

    final List<OrganizerSamitiData>? distributionCenters =
        _vitranDetails?.data?.organizerSamiti;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: _brandColor,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Edit Order',
                      style: TextStyle(
                        color: _brandColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 30),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Distribution Place Dropdown
                      const Text(
                        'Distribution Place',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (_isLoadingVitranDetails)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDistributionCenterId,
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              hint: const Text('Select distribution center'),
                              items: distributionCenters?.map((center) {
                                return DropdownMenuItem<String>(
                                  value: center.vitranDistributionCenterId,
                                  child: Text(
                                    center.vitranDistributionCenterName ?? 'Unknown Center',
                                  ),
                                );
                              }).toList() ?? [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('No centers available'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedDistributionCenterId = value;
                                });
                              },
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 14),

                      // Distribution Center Details
                      if (_selectedDistributionCenterId != null && distributionCenters != null)
                        _buildDistributionDetails(
                          _getSelectedCenter(distributionCenters),
                        ),

                      const SizedBox(height: 20),

                      // Products Section
                      const Text(
                        'Products',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (_isLoadingVitranDetails)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_editProducts.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('No products found'),
                          ),
                        )
                      else
                        ...List.generate(_editProducts.length, (index) {
                          final product = _editProducts[index];
                          final quantity = _editQuantities[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _brandColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: _brandColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['productName'] ?? 'Product',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹ ${product['productCost']} / ${product['productDescription']}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'No of packs',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: _brandColor),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildQuantityButton(
                                            icon: Icons.remove,
                                            onTap: () {
                                              setState(() {
                                                if (_editQuantities[index] > 0) {
                                                  _editQuantities[index]--;
                                                  _editProducts[index]['productQty'] =
                                                  _editQuantities[index];
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(
                                            width: 32,
                                            child: Text(
                                              '$quantity',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          _buildQuantityButton(
                                            icon: Icons.add,
                                            onTap: () {
                                              setState(() {
                                                _editQuantities[index]++;
                                                _editProducts[index]['productQty'] =
                                                _editQuantities[index];
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Action Buttons - Fixed at bottom
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _updateOrder(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
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

  Widget _buildDistributionDetails(OrganizerSamitiData? samiti) {
    if (samiti == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailText(
            title: 'Distribution Place',
            value: samiti.vitranDistributionCenterName ?? 'Not available',
          ),
          const SizedBox(height: 8),
          _buildDetailText(
            title: 'Address',
            value: samiti.vitranDistributionCenterDetails ?? 'Not available',
          ),
          const SizedBox(height: 8),
          _buildDetailText(
            title: 'Sanyojak',
            value: _getSanyojakDisplay(samiti),
          ),
          const SizedBox(height: 8),
          _buildDetailText(
            title: 'Contact',
            value: samiti.organizerContactDetails ?? 'Not available',
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
            value: '${_formatTimeText(samiti.distributionStartTime)} - ${_formatTimeText(samiti.distributionEndTime)}',
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
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 16, color: _brandColor),
      ),
    );
  }

  String _formatDateText(String? dateText) {
    if (dateText == null || dateText.isEmpty) return 'Not available';
    final date = DateTime.tryParse(dateText);
    if (date == null) return 'Not available';
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String _formatTimeText(String? timeText) {
    if (timeText == null || timeText.isEmpty) return 'Not available';
    final trimmedTime = timeText.trim();
    final date = DateTime.tryParse('2000-01-01 $trimmedTime');
    if (date == null) return trimmedTime;
    return DateFormat('hh:mm a').format(date);
  }

  String _getSanyojakDisplay(OrganizerSamitiData? samiti) {
    if (samiti == null) return 'Not available';

    if (samiti.sanyojakName != null && samiti.sanyojakName!.isNotEmpty) {
      String display = samiti.sanyojakName!;
      if (samiti.sanyojakMobile != null && samiti.sanyojakMobile!.isNotEmpty) {
        display += ' - ${samiti.sanyojakMobile}';
      }
      return display;
    }

    if (samiti.sanyojak != null && samiti.sanyojak!.isNotEmpty) {
      final firstSanyojak = samiti.sanyojak!.first;
      String name = '';
      if (firstSanyojak.memberFirstName != null) {
        name += firstSanyojak.memberFirstName!;
      }
      if (firstSanyojak.memberLastName != null) {
        name += ' ${firstSanyojak.memberLastName!}';
      }
      name = name.trim();

      if (name.isNotEmpty) {
        String display = name;
        if (firstSanyojak.memberMobile != null && firstSanyojak.memberMobile!.isNotEmpty) {
          display += ' - ${firstSanyojak.memberMobile}';
        }
        return display;
      }
    }

    return 'Not available';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _brandColor,
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Order Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton.icon(
              onPressed: () {
                if (_currentOrder != null) {
                  _showEditBottomSheet(_currentOrder!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order data is loading...'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                'Edit Order',
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
      body: FutureBuilder<VitranMemberOrderDetailsModelClass>(
        future: _futureOrder,
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
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Failed to load order: ${snapshot.error}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final VitranMemberOrderDetailsData? order = snapshot.data?.data;

          if (order == null) {
            return const Center(
              child: Text("Order not found"),
            );
          }

          if (_currentOrder == null) {
            _currentOrder = order;
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: Colors.redAccent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.vitranName ?? "Sattu Vitran",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildStatusChip(order.orderStatus),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildAmountCard(order.totalCost ?? 0),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoTile(
                                icon: Icons.calendar_today,
                                title: "Order Date",
                                value: _formatDate(order.orderedAt),
                              ),
                            ),
                            Expanded(
                              child: _buildInfoTile(
                                icon: Icons.receipt_long,
                                title: "Order ID",
                                value: order.vitranOrderCode ?? "-",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle(
                    "Distribution Center",
                    Icons.store,
                  ),
                  Card(
                    elevation: 1,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoTile(
                            icon: Icons.location_city,
                            title: "Center",
                            value: order.vitranDistributionCenterName ?? "-",
                          ),
                          const Divider(),
                          _buildInfoTile(
                            icon: Icons.location_on,
                            title: "Address",
                            value: order.vitranDistributionCenterDetails ?? "-",
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle(
                    "Ordered Products",
                    Icons.shopping_bag,
                  ),
                  if (order.products == null || order.products!.isEmpty)
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(25),
                        child: Center(
                          child: Text("No products found."),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.products!.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = order.products![index];

                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: _brandColor.withOpacity(.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.shopping_basket,
                                        color: _brandColor,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.productName ?? "-",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "₹ ${product.productCost?.toStringAsFixed(2) ?? "0"} / ${product.productDescription ?? ""}",
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 30),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            "Quantity",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "${product.productQty}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            "Total",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "₹ ${product.productTotalCost?.toStringAsFixed(2) ?? "0"}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: _brandColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}