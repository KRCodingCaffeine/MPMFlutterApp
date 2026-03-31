import 'package:flutter/material.dart';
import 'package:mpm/model/GetEventDetailsById/GetEventDetailsByIdData.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:url_launcher/url_launcher.dart';

class EventPaymentDetailPage extends StatelessWidget {
  final GetEventDetailsByIdData eventDetails;

  const EventPaymentDetailPage({
    Key? key,
    required this.eventDetails,
  }) : super(key: key);

  String get _paymentAmount {
    final amount = eventDetails.eventAmount?.trim();
    if (amount == null || amount.isEmpty) {
      return '0';
    }
    return amount;
  }

  bool get _hasQrImage {
    final qrCode = eventDetails.eventQrCode?.trim();
    if (qrCode == null || qrCode.isEmpty) {
      return false;
    }

    return qrCode.startsWith('http://') || qrCode.startsWith('https://');
  }

  Future<void> _handleQrTap(BuildContext context) async {
    final qrCode = eventDetails.eventQrCode?.trim();
    if (qrCode == null || qrCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code is not available for this event.')),
      );
      return;
    }

    Uri? paymentUri;

    if (qrCode.startsWith('upi://') || qrCode.startsWith('tez://')) {
      paymentUri = Uri.parse(qrCode);
      final updatedParams = Map<String, String>.from(paymentUri.queryParameters);
      updatedParams['am'] = _paymentAmount;
      updatedParams.putIfAbsent('cu', () => 'INR');
      paymentUri = paymentUri.replace(queryParameters: updatedParams);
    }

    if (paymentUri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This QR is an image. Direct Google Pay launch needs a UPI payment link from the API.',
          ),
        ),
      );
      return;
    }

    if (await canLaunchUrl(paymentUri)) {
      await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open Google Pay on this device.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor =
        ColorHelperClass.getColorFromHex(ColorResources.red_color);
    final logoColor =
        ColorHelperClass.getColorFromHex(ColorResources.logo_color);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: logoColor,
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEEE7DA),
              Color(0xFFF8F5EF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(themeColor, logoColor),
              const SizedBox(height: 18),
              _buildAmountCard(themeColor),
              const SizedBox(height: 18),
              _buildQrShowcase(context, themeColor),
              const SizedBox(height: 18),
              _buildInfoCard(),
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

  Widget _buildHeroCard(Color themeColor, Color logoColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            logoColor,
            themeColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              (eventDetails.eventCostType?.isNotEmpty ?? false)
                  ? '${eventDetails.eventCostType} Access'
                  : 'Premium Access',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            eventDetails.eventName ?? 'Event Payment',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            eventDetails.eventDescription?.isNotEmpty == true
                ? eventDetails.eventDescription!
                : 'Complete payment for your event registration using the QR below.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFECE3D5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.currency_rupee, color: themeColor, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Event Amount',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _paymentAmount,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          if (eventDetails.eventRegistrationLastDate?.isNotEmpty ?? false)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F2E8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Last Date',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    eventDetails.eventRegistrationLastDate!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQrShowcase(BuildContext context, Color themeColor) {
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
              Icon(Icons.qr_code_2_rounded, color: themeColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Scan Or Tap To Pay',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the QR card to continue with Google Pay using the event amount.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _handleQrTap(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 260,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFAF6),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE8DECF), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 220,
                    width: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFF0E7DB)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _hasQrImage
                        ? Image.network(
                            eventDetails.eventQrCode!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildQrPlaceholder(),
                          )
                        : _buildQrPlaceholder(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Tap QR to pay Rs. $_paymentAmount',
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Notes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Use the QR above to pay the event amount. After payment, keep the transaction reference ready in case the organiser asks for verification.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatorCard() {
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
          if (eventDetails.eventOrganiserName?.isNotEmpty ?? false)
            _buildContactRow(Icons.person_outline, eventDetails.eventOrganiserName!),
          if (eventDetails.eventOrganiserMobile?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            _buildContactRow(Icons.call_outlined, eventDetails.eventOrganiserMobile!),
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
