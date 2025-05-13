import 'package:flutter/material.dart';
import 'package:mpm/model/Offer/OfferData.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:intl/intl.dart';
import 'package:mpm/view/avail_offer_page.dart';

class DiscountOfferDetailPage extends StatelessWidget {
  final OfferData offer;

  const DiscountOfferDetailPage({
    super.key,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text("Offer Details", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompanyInfo(),
            const SizedBox(height: 16),
            const Divider(thickness: 0.5, color: Colors.grey),
            const SizedBox(height: 16),

            Center(
              child: GestureDetector(
                onTap: () => _showFullImage(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: offer.offerImage != null && offer.offerImage!.isNotEmpty
                      ? Image.network(
                    offer.offerImage!,
                    height: 350,
                    width: 350,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultOfferImage(),
                  )
                      : _buildDefaultOfferImage(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: Text(
                offer.offerDiscountName ?? 'No title',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Offer Detail:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              offer.offerDescription ?? 'No description available',
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            _buildValidityInfo(),

            if (offer.orgMobile != null || offer.orgEmail != null) ...[
              const SizedBox(height: 24),
              const Divider(thickness: 0.5, color: Colors.grey),
              const SizedBox(height: 16),
              _buildContactInfo(),
            ],

            const SizedBox(height: 24),
            const Divider(thickness: 0.5, color: Colors.grey),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AvailOfferPage()),
                  );
                },
                child: const Text("Avail Offer", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultOfferImage() {
    return Container(
      height: 300,
      width: 300,
      color: Colors.grey[200],
      child: Center(
        child: Image.asset(
          'assets/images/discounts.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Center(
              child: offer.offerImage != null && offer.offerImage!.isNotEmpty
                  ? Image.network(
                offer.offerImage!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/discounts.jpg',
                  fit: BoxFit.contain,
                ),
              )
                  : Image.asset(
                'assets/images/discounts.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: offer.orgLogo != null && offer.orgLogo!.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              offer.orgLogo!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildDefaultLogo(),
            ),
          )
              : _buildDefaultLogo(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.orgName ?? 'Unknown Company',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (offer.orgAddress != null)
                Text(
                  offer.orgAddress!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              if (offer.orgArea != null || offer.orgCity != null) ...[
                const SizedBox(height: 4),
                Text(
                  [offer.orgArea, offer.orgCity].where((e) => e != null).join(', '),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValidityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Validity Period:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              offer.validFrom != null && offer.validTo != null
                  ? '${_formatDate(offer.validFrom!)} - ${_formatDate(offer.validTo!)}'
                  : 'Not specified',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FixedColumnWidth(10),
            2: FlexColumnWidth(),
          },
          children: [
            if (offer.orgMobile != null)
              _buildTableRow('Mobile Number', offer.orgMobile!),
            if (offer.orgMobile != null)
              _buildSpacerRow(),
            if (offer.orgMobile != null)
              _buildTableRow('WhatsApp Number', offer.orgMobile!),
            if (offer.orgEmail != null)
              _buildSpacerRow(),
            if (offer.orgEmail != null)
              _buildTableRow('Email', offer.orgEmail!),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
        Center(child: Text(':')),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  TableRow _buildSpacerRow() {
    return const TableRow(
      children: [
        SizedBox(height: 8),
        SizedBox(),
        SizedBox(),
      ],
    );
  }

  Widget _buildDefaultLogo() {
    return Center(
      child: Image.asset(
        'assets/images/logo.png',
        width: 75,
        height: 75,
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
