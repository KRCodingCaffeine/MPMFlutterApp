import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/model/GetEventDetailsById/GetEventDetailsByIdData.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/Events/event_view.dart';
import 'package:path_provider/path_provider.dart';

class EventPaymentDetailPage extends StatelessWidget {
  final GetEventDetailsByIdData eventDetails;
  final int selectedMemberCount;
  final int selectedFoodBoxCount;

  const EventPaymentDetailPage({
    Key? key,
    required this.eventDetails,
    this.selectedMemberCount = 1,
    this.selectedFoodBoxCount = 0,
  }) : super(key: key);

  int get _eventEntryAmount {
    final amount = eventDetails.eventAmount?.trim();
    if (amount == null || amount.isEmpty) {
      return 0;
    }

    return int.tryParse(amount) ?? 0;
  }

  int get _foodAmount {
    final amount = eventDetails.foodAmount?.trim();
    if (amount == null || amount.isEmpty) {
      return 0;
    }

    return int.tryParse(amount) ?? 0;
  }

  bool get _hasPaidFood {
    return eventDetails.hasFood == '1' &&
        eventDetails.hasFoodPaid?.trim().toLowerCase() == 'paid';
  }

  int get _eventEntryTotal {
    final memberCount = selectedMemberCount > 0 ? selectedMemberCount : 1;
    return _eventEntryAmount * memberCount;
  }

  int get _foodTotal {
    if (!_hasPaidFood) {
      return 0;
    }

    return _foodAmount * selectedFoodBoxCount;
  }

  int get _totalPaymentAmount {
    return _eventEntryTotal + _foodTotal;
  }

  bool get _hasQrImage {
    final qrCode = eventDetails.eventAmountQrCode?.trim();
    if (qrCode == null || qrCode.isEmpty) {
      return false;
    }

    return qrCode.startsWith('http://') || qrCode.startsWith('https://');
  }

  Future<void> _downloadQr(BuildContext context) async {
    final qrUrl = eventDetails.eventAmountQrCode?.trim();

    if (qrUrl == null || qrUrl.isEmpty) {
      _showPremiumSnackBar(
        context: context,
        message: 'QR not available',
        icon: Icons.qr_code_scanner_rounded,
        color: Colors.orangeAccent,
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(qrUrl));

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/event_qr.png');

      await file.writeAsBytes(response.bodyBytes);

      _showPremiumSnackBar(
        context: context,
        message: 'QR downloaded successfully!',
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF2ECC71),
      );
    } catch (e) {
      _showPremiumSnackBar(
        context: context,
        message: 'Download failed: $e',
        icon: Icons.error_outline_rounded,
        color: Colors.redAccent,
      );
    }
  }

  void _showPremiumSnackBar({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor =
        ColorHelperClass.getColorFromHex(ColorResources.red_color);
    final logoColor =
        ColorHelperClass.getColorFromHex(ColorResources.logo_color);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: logoColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const EventsPage()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'Event Payment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQrShowcase(context, themeColor),
              const SizedBox(height: 18),
              if ((eventDetails.eventOrganiserName?.isNotEmpty ?? false) ||
                  (eventDetails.eventOrganiserMobile?.isNotEmpty ?? false)) ...[
                const SizedBox(height: 18),
                _buildCoordinatorCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrShowcase(BuildContext context, Color themeColor) {
    final eventName = eventDetails.eventName ?? 'the event';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "We have received your registration request for the event $eventName.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Kindly make the payment through the QR code provided.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 260,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFAF6),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE8DECF), width: 1.2),
              ),
              child: Column(
                children: [
                  Container(
                    height: 350,
                    width: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _hasQrImage
                        ? Image.network(
                            eventDetails.eventAmountQrCode!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildQrPlaceholder(),
                          )
                        : _buildQrPlaceholder(),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _downloadQr(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Click here to download QR Code to pay Rs. $_totalPaymentAmount',
                        style: TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Text(
          //   "Amount is calculated based on your selected family members also.",
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //     fontSize: 12,
          //     color: themeColor.withOpacity(0.85),
          //     fontWeight: FontWeight.w500,
          //     height: 1.4,
          //   ),
          // ),
          // const SizedBox(height: 12),
          _buildAmountBreakdown(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildAmountBreakdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7DAC6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountRow(
            label:
                'Event Entry amount: Rs. $_eventEntryAmount x $selectedMemberCount',
            value: 'Rs. $_eventEntryTotal',
          ),
          if (_hasPaidFood)
            _buildAmountRow(
              label: _foodAmount > 0
                  ? 'Food amount: Rs. $_foodAmount x $selectedFoodBoxCount'
                  : 'Food amount: selected boxes $selectedFoodBoxCount',
              value: 'Rs. $_foodTotal',
            ),
          const Divider(height: 18),
          _buildAmountRow(
            label: 'Total amount',
            value: 'Rs. $_totalPaymentAmount',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    final textStyle = TextStyle(
      fontSize: isTotal ? 15 : 13,
      fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
      color: Colors.black87,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: textStyle)),
        const SizedBox(width: 12),
        Text(value, style: textStyle, textAlign: TextAlign.right),
      ],
    );
  }

  Widget _buildQrPlaceholder() {
    return Container(
      color: const Color(0xFFFFFCF8),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2_rounded, size: 72, color: Colors.black38),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'QR image not available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatorCard() {
    final organiserName = eventDetails.eventOrganiserName ?? '';
    final organiserMobile = eventDetails.eventOrganiserMobile ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFECE3D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coordinator Details',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),

          /// 🔥 FIXED TEXT (NO const)
          Text(
            "If you have any queries related to payment or the event, feel free to contact:\n",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),

          if (organiserName.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildContactRow(Icons.person_outline, organiserName),
          ],

          if (organiserMobile.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildContactRow(Icons.call_outlined, organiserMobile),
          ],
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F1E7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF9C4A2D)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
