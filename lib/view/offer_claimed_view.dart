import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class ClaimedOfferListPage extends StatelessWidget {
  final List<Map<String, dynamic>> dummyOffers = [
    {
      'title': 'Health Check Up',
      'userName': 'Manoj Kumar Murugan',
      'claimedDate': '2025-05-10',
      'image': null,
    },
    {
      'title': 'Generic Medicines',
      'userName': 'Karthika Rajesh.',
      'claimedDate': '2025-05-12',
      'image': null,
    },
    {
      'title': 'Health Check Up',
      'userName': 'Satya Narayan Somani',
      'claimedDate': '2025-05-14',
      'image': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text(
          'Claimed Offers',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: ListView.builder(
          itemCount: dummyOffers.length,
          itemBuilder: (context, index) {
            final offer = dummyOffers[index];
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.local_offer, color: Colors.redAccent),
                  ),
                  title: Text(
                    offer['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Claimed by: ${offer['userName']}\nDate: ${offer['claimedDate']}',
                    style: const TextStyle(height: 1.4),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}