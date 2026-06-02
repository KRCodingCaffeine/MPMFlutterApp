import 'package:flutter/material.dart';
import 'package:mpm/model/GetEventDetailsById/GetEventDetailsByIdData.dart';
import 'package:mpm/repository/payment_transaction_id_repository/payment_transaction_id_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/Events/event_view.dart';
import 'package:url_launcher/url_launcher.dart';

class EventPaymentDetailPage extends StatefulWidget {
  final GetEventDetailsByIdData eventDetails;
  final int selectedMemberCount;
  final int selectedFoodBoxCount;

  const EventPaymentDetailPage({
    Key? key,
    required this.eventDetails,
    this.selectedMemberCount = 1,
    this.selectedFoodBoxCount = 0,
  }) : super(key: key);

  @override
  State<EventPaymentDetailPage> createState() => _EventPaymentDetailPageState();
}

class _EventPaymentDetailPageState extends State<EventPaymentDetailPage> {
  final TextEditingController transactionIdController = TextEditingController();
  final PaymentTransactionRepository _paymentTransactionRepository =
      PaymentTransactionRepository();
  bool _isSubmittingTransaction = false;

  GetEventDetailsByIdData get eventDetails => widget.eventDetails;
  int get selectedMemberCount => widget.selectedMemberCount;
  int get selectedFoodBoxCount => widget.selectedFoodBoxCount;

  @override
  void dispose() {
    transactionIdController.dispose();
    super.dispose();
  }

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

  Uri? get _gPayUri {
    final upiCode = eventDetails.eventUPICode?.trim();
    if (upiCode == null || upiCode.isEmpty) {
      return null;
    }

    if (upiCode.startsWith('upi://') || upiCode.startsWith('tez://')) {
      return Uri.tryParse(upiCode);
    }

    return Uri(
      scheme: 'tez',
      host: 'upi',
      path: 'pay',
      queryParameters: {
        'pa': upiCode,
        'pn': eventDetails.eventName?.trim().isNotEmpty == true
            ? eventDetails.eventName!.trim()
            : 'Event Payment',
        if (_totalPaymentAmount > 0) 'am': _totalPaymentAmount.toString(),
        'cu': 'INR',
      },
    );
  }

  Future<void> _openGPay(BuildContext context) async {
    final uri = _gPayUri;
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('UPI code not available')),
      );
      return;
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Pay')),
      );
    }
  }

  Future<void> _submitTransactionId() async {
    final transactionId = transactionIdController.text.trim();
    if (transactionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter transaction id"),
        ),
      );
      return;
    }

    final eventId = eventDetails.eventId?.toString() ?? '';
    final session = await SessionManager.getSession();
    final memberId = session?.memberId?.toString() ?? '';

    if (eventId.isEmpty || memberId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to submit transaction id"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingTransaction = true;
    });

    try {
      final response =
          await _paymentTransactionRepository.updatePaymentTransaction(
        eventId: eventId,
        memberId: memberId,
        paymentTransactionId: transactionId,
      );

      if (!mounted) return;

      if (response.status == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ?? "Transaction id submitted successfully",
            ),
            backgroundColor: Colors.green,
            duration: const Duration(minutes: 1),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const EventsPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ?? "Failed to submit transaction id",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit transaction id: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingTransaction = false;
        });
      }
    }
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
            color: Colors.black.withValues(alpha: 0.06),
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFAF6),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE8DECF), width: 1.2),
            ),
            child: Container(
              height: 350,
              width: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openGPay(context),
                child: _hasQrImage
                    ? Image.network(
                        eventDetails.eventAmountQrCode!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildQrPlaceholder(),
                      )
                    : _buildQrPlaceholder(),
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
          const SizedBox(height: 16),
          _buildTransactionIdSection(context, themeColor),
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

  Widget _buildTransactionIdSection(BuildContext context, Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7DAC6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Once your payment is completed click here to enter your transaction id",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: transactionIdController,
            decoration: const InputDecoration(
              labelText: "Enter Transaction ID",
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black38, width: 1),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              labelStyle: TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmittingTransaction ? null : _submitTransactionId,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSubmittingTransaction
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Submit"),
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
