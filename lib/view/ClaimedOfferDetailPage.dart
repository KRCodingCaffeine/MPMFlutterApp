import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/GetClaimedOfferByID/GetClaimedOfferData.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class ClaimedOfferDetailPage extends StatefulWidget {
  final GetClaimedOfferData offer;

  ClaimedOfferDetailPage({required this.offer});

  @override
  State<ClaimedOfferDetailPage> createState() => _ClaimedOfferDetailPageState();
}

class _ClaimedOfferDetailPageState extends State<ClaimedOfferDetailPage> {
  final UdateProfileController _profileController =
      Get.isRegistered<UdateProfileController>()
          ? Get.find<UdateProfileController>()
          : Get.put(UdateProfileController());

  late final Future<void> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileIfNeeded();
  }

  String getContainerName(dynamic id) {
    switch (id.toString()) {
      case '1':
        return 'Strip';
      case '2':
        return 'Tube';
      case '3':
        return 'Bottle';
      case '4':
        return 'Box';
      case '5':
        return 'Pouch';
      default:
        return 'Unknown';
    }
  }

  Future<void> _loadProfileIfNeeded() async {
    if (_profileController.getUserData.value.address != null) {
      return;
    }

    await _profileController.getUserProfile();
  }

  String _buildMemberAddress() {
    final address = _profileController.getUserData.value.address;

    final lines = <String>[
      _joinParts([
        address?.flatNo?.toString(),
        address?.buildingName?.toString(),
      ]),
      _joinParts([
        address?.address?.toString(),
        address?.areaName?.toString(),
      ]),
      _joinParts([
        address?.cityName?.toString(),
        address?.stateName?.toString(),
        address?.pincode?.toString(),
      ]),
    ].where((line) => line.isNotEmpty).toList();

    if (lines.isEmpty) {
      return '--';
    }

    return lines.join(', \n');
  }

  String _joinParts(List<String?> parts) {
    return parts
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              widget.offer.orgName ?? 'Offer Details',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prescription Document
            if (widget.offer.medicinePrescriptionDocument != null &&
                widget.offer.medicinePrescriptionDocument!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prescription:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.offer.medicinePrescriptionDocument!,
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
                  const SizedBox(height: 16),
                ],
              ),

            // Medicines List
            if (widget.offer.medicines != null &&
                widget.offer.medicines!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medicines:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  ...widget.offer.medicines!.map((medicine) => Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '• ${medicine.medicineName} (${medicine.quantity} ${getContainerName(medicine.medicineContainerId)})',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ))
                ],
              ),
            const SizedBox(height: 20),

            Text(
              'Ordered on: ${_formatDate(widget.offer.createdAt)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 16),

            const Text(
              'Address:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            FutureBuilder<void>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(left: 12.0, top: 8),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    _buildMemberAddress(),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 16),

            const Text(
              'Contact Info:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FixedColumnWidth(10),
                2: FlexColumnWidth(),
              },
              children: [
                _buildTableRow(
                    'Person Name', widget.offer.offerContactPersonName ?? '--'),
                _buildSpacerRow(),
                _buildTableRow('Person Mobile Number',
                    widget.offer.offerContactPersonMobile ?? '--'),
                _buildSpacerRow(),
                _buildTableRow('Email', widget.offer.orgEmail ?? '--'),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
        const Center(child: Text(':')),
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

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, dd-MM-yy').format(date);
    } catch (e) {
      return '';
    }
  }
}
