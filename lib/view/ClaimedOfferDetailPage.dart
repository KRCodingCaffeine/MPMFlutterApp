import 'package:flutter/material.dart';
import 'package:mpm/model/GetClaimedOfferByID/GetClaimedOfferData.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class ClaimedOfferDetailPage extends StatelessWidget {
  final GetClaimedOfferData offer;

  ClaimedOfferDetailPage({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(offer.orgName ?? 'Offer Details',
            style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prescription Document
            if (offer.medicinePrescriptionDocument != null &&
                offer.medicinePrescriptionDocument!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prescription:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      offer.medicinePrescriptionDocument!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Text('Image not available'),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes!)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),

            // Medicines List
            if (offer.medicines != null && offer.medicines!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Medicines:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ...offer.medicines!.map((medicine) => Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '• ${medicine.medicineName} (Container ID: ${medicine.medicineContainerId}, Qty: ${medicine.quantity})',
                          style: TextStyle(fontSize: 13),
                        ),
                      )),
                ],
              ),
            SizedBox(height: 20),

            Text('Claimed On:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('Claimed on: ${offer.createdAt}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            SizedBox(height: 20),

            // Organization Address
            Text('Address:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('${offer.orgAddress}, ${offer.orgCity}, ${offer.orgState}',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 20),

            // Contact Info
            Text('Contact Info:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('Contact: ${offer.orgMobile}', style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text('Email: ${offer.orgEmail}', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
