import 'package:flutter/material.dart';
import 'package:mpm/model/SattuVitran/GetVitranDetails/GetVitranDetailsModel.dart';
import 'package:mpm/model/SattuVitran/GetVitranDetails/OrganizerSamitiData.dart'
    as detail_organizer;
import 'package:mpm/model/SattuVitran/GetVitranDetails/ProductData.dart'
    as detail_product;
import 'package:mpm/model/SattuVitran/GetVitranDetails/VitranData.dart'
    as detail_vitran;
import 'package:mpm/repository/SattuVitran/VitranDetailRepository/vitran_detail_repository.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/SattuVitran/sattu_vitran_cart.dart';

class SattuVitranEvent {
  const SattuVitranEvent({
    required this.vitranId,
    required this.name,
    required this.date,
    required this.coordinatorName,
    required this.description,
  });

  final String vitranId;
  final String name;
  final DateTime date;
  final String coordinatorName;
  final String description;
}

class SattuVitranDetailPage extends StatefulWidget {
  const SattuVitranDetailPage({
    super.key,
    required this.event,
  });

  final SattuVitranEvent event;

  @override
  State<SattuVitranDetailPage> createState() => _SattuVitranDetailPageState();
}

class _SattuVitranDetailPageState extends State<SattuVitranDetailPage> {
  final Color _brandColor =
      ColorHelperClass.getColorFromHex(ColorResources.logo_color);

  late Future<GetVitranDetailsModel> _vitranDetailFuture;
  List<detail_product.ProductData> _products = [];
  List<int> _quantities = [];
  detail_vitran.VitranData? _vitranData;

  bool get _hasSelectedProducts => _quantities.any((quantity) => quantity > 0);

  int get _selectedProductCount =>
      _quantities.where((quantity) => quantity > 0).length;

  int get _selectedItemCount =>
      _quantities.fold(0, (sum, quantity) => sum + quantity);

  int get _totalAmount {
    var total = 0;
    for (var index = 0; index < _products.length; index++) {
      total += _parseProductPrice(_products[index]) * _quantities[index];
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _vitranDetailFuture = _fetchVitranDetails();
  }

  Future<GetVitranDetailsModel> _fetchVitranDetails() async {
    final response =
        await VitranRepository().fetchVitranDetails(widget.event.vitranId);
    return GetVitranDetailsModel.fromJson(response);
  }

  Future<void> _refreshVitranDetails() async {
    setState(() {
      _vitranDetailFuture = _fetchVitranDetails();
    });
    await _vitranDetailFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _brandColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: FutureBuilder<GetVitranDetailsModel>(
          future: _vitranDetailFuture,
          builder: (context, snapshot) {
            final vitranName = _displayText(
              snapshot.data?.data?.vitranName,
              fallback: widget.event.name,
            );
            double fontSize = MediaQuery.of(context).size.width * 0.045;

            return Text(
              vitranName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500),
            );
          },
        ),
      ),
      body: FutureBuilder<GetVitranDetailsModel>(
        future: _vitranDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildMessageState(
              message: 'Failed to load sattu vitran details',
              actionLabel: 'Retry',
              onActionTap: _refreshVitranDetails,
            );
          }

          final vitranData = snapshot.data?.data;
          if (vitranData == null) {
            return _buildMessageState(
              message: 'Sattu vitran details not found',
              actionLabel: 'Refresh',
              onActionTap: _refreshVitranDetails,
            );
          }

          _setProducts(vitranData);

          return RefreshIndicator(
            color: _brandColor,
            onRefresh: _refreshVitranDetails,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                _hasSelectedProducts ? 104 : 24,
              ),
              children: [
                // _buildEventHeader(vitranData),
                // const SizedBox(height: 14),
                const Text(
                  'Sattu Churn Order',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (_products.isEmpty)
                  _buildEmptyProductsCard()
                else
                  ...List.generate(_products.length, (index) {
                    return _buildItemCard(index, _products[index]);
                  }),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar:
          _hasSelectedProducts ? _buildPlaceOrderBar(context) : null,
    );
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onActionTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildEventHeader(detail_vitran.VitranData vitranData) {
  //   final vitranDate = DateFormat('dd.MM.yyyy').format(
  //     _parseVitranDate(vitranData),
  //   );
  //   final coordinatorName = _getCoordinatorName(vitranData);
  //   final startDateToOrder = _formatDateText(vitranData.startDateOfOrder);
  //   final lastDateToOrder = _formatDateText(vitranData.lastDateToOrder);
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Description:',
  //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //       ),
  //       const SizedBox(height: 8),
  //       Text(
  //         _displayText(
  //           vitranData.vitranDescription,
  //           fallback: widget.event.description,
  //         ),
  //         style: const TextStyle(
  //           fontSize: 15,
  //           height: 1.5,
  //         ),
  //       ),
  //       const SizedBox(height: 18),
  //       _buildDetailRow(
  //         icon: Icons.person_outline,
  //         title: 'Coordinator',
  //         value: coordinatorName,
  //       ),
  //       const SizedBox(height: 10),
  //       _buildDetailRow(
  //         icon: Icons.event_available,
  //         title: 'Vitran Date',
  //         value: vitranDate,
  //       ),
  //       const SizedBox(height: 10),
  //       _buildDetailRow(
  //         icon: Icons.shopping_bag_outlined,
  //         title: 'Start Date To Order',
  //         value: startDateToOrder,
  //       ),
  //       const SizedBox(height: 10),
  //       _buildDetailRow(
  //         icon: Icons.event_busy_outlined,
  //         title: 'Last Date To Order',
  //         value: lastDateToOrder,
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildDetailRow({
  //   required IconData icon,
  //   required String title,
  //   required String value,
  // }) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       Icon(icon, size: 18, color: Colors.grey[600]),
  //       const SizedBox(width: 8),
  //       Expanded(
  //         child: Text.rich(
  //           TextSpan(
  //             children: [
  //               TextSpan(
  //                 text: '$title: ',
  //                 style: const TextStyle(
  //                   color: Colors.black,
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //               TextSpan(
  //                 text: value,
  //                 style: TextStyle(
  //                   color: Colors.grey[700],
  //                   fontSize: 14,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildEmptyProductsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(alpha: 0.18),
      child: const Text(
        'No products found',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _buildItemCard(int index, detail_product.ProductData item) {
    final quantity = _quantities[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(alpha: 0.18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _brandColor.withValues(alpha: 0.1),
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
                  _displayText(item.productName, fallback: 'Product'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _productPriceText(item),
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
              quantity == 0
                  ? OutlinedButton(
                      onPressed: () => _updateQuantity(index, 1),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _brandColor,
                        side: BorderSide(color: _brandColor),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Add Quantity'),
                    )
                  : _buildQuantityControl(index, quantity),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(int index, int quantity) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _brandColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onTap: () => _updateQuantity(index, quantity - 1),
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
            onTap: () => _updateQuantity(index, quantity + 1),
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

  Widget _buildPlaceOrderBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 13, 16, 5),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rs. $_totalAmount',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '$_selectedProductCount sattu churn • $_selectedItemCount qty',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _openCartPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Place Order',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration({double alpha = 0.2}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: alpha),
          spreadRadius: 1,
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      _quantities[index] = quantity < 0 ? 0 : quantity;
    });
  }

  void _openCartPage() {
    final selectedItems = <SattuCartItem>[];

    for (var index = 0; index < _products.length; index++) {
      final quantity = _quantities[index];

      if (quantity > 0) {
        final product = _products[index];

        selectedItems.add(
          SattuCartItem(
            vitranId: widget.event.vitranId,
            memberId: "2", // Replace with actual member ID from session
            productId: product.vitranProductId ?? "",
            productUnitId: product.vitranProductUnitId ?? "1", // Make sure this is provided
            name: _displayText(
              product.productName,
              fallback: 'Product',
            ),
            unitPrice: _parseProductPrice(product),
            quantity: quantity,
          ),
        );
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SattuVitranCartPage(
          items: selectedItems,
          organizerSamitiList: _getOrganizerSamitiList(),
        ),
      ),
    );
  }

  void _setProducts(detail_vitran.VitranData vitranData) {
    final products = vitranData.products ?? [];
    if (identical(_vitranData, vitranData) &&
        _products.length == products.length) {
      return;
    }

    _vitranData = vitranData;
    _products = products;
    _quantities = List<int>.filled(_products.length, 0);
  }

  List<detail_organizer.OrganizerSamitiData> _getOrganizerSamitiList() {
    return _vitranData?.organizerSamiti ?? [];
  }

  int _parseProductPrice(detail_product.ProductData product) {
    final priceText = product.productCost?.trim() ?? '';
    return double.tryParse(priceText)?.round() ?? 0;
  }

  String _productPriceText(detail_product.ProductData product) {
    final price = _parseProductPrice(product);
    final description =
        product.productDescription ?? product.productUnitDisplayName;

    if (description == null || description.trim().isEmpty) {
      return 'Rs. $price';
    }

    return 'Rs. $price ( ${description.trim()})';
  }

  String _displayText(String? value, {required String fallback}) {
    final trimmedValue = value?.trim();
    return trimmedValue == null || trimmedValue.isEmpty
        ? fallback
        : trimmedValue;
  }
}
