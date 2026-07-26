import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/SattuVitran/SattuVitranList/VitranData.dart';
import 'package:mpm/model/SattuVitran/SattuVitranList/VitranModelClass.dart';
import 'package:mpm/repository/SattuVitran/SattuVitranList/vitran_repository.dart';
import 'package:mpm/view/SattuVitran/sattu_vitran_detail.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/SattuVitran/sattu_vitran_member_order.dart';

class SattuVitranView extends StatefulWidget {
  const SattuVitranView({super.key});

  @override
  State<SattuVitranView> createState() => _SattuVitranViewState();
}

class _SattuVitranViewState extends State<SattuVitranView> {
  final Color _brandColor =
  ColorHelperClass.getColorFromHex(ColorResources.logo_color);

  late Future<VitranModelClass> _vitranFuture;

  @override
  void initState() {
    super.initState();
    _vitranFuture = _fetchVitranList();
  }

  Future<VitranModelClass> _fetchVitranList() async {
    final response = await VitranRepository().fetchVitran(limit: 10);
    return VitranModelClass.fromJson(response);
  }

  Future<void> _refreshVitranList() async {
    setState(() {
      _vitranFuture = _fetchVitranList();
    });
    await _vitranFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _brandColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Vitran',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Vitranmemberorder(),
                  ),
                );
              },
              icon: const Icon(
                Icons.receipt_long,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                'My Orders',
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
      body: FutureBuilder<VitranModelClass>(
        future: _vitranFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildMessageState(
              message: 'Failed to load sattu vitran list',
              actionLabel: 'Retry',
              onActionTap: _refreshVitranList,
            );
          }

          final vitranList = snapshot.data?.data ?? [];

          if (vitranList.isEmpty) {
            return _buildMessageState(
              message: 'No sattu vitran found',
              actionLabel: 'Refresh',
              onActionTap: _refreshVitranList,
            );
          }

          return RefreshIndicator(
            color: _brandColor,
            onRefresh: _refreshVitranList,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              itemCount: vitranList.length,
              itemBuilder: (context, index) {
                return _buildEventCard(vitranList[index]);
              },
            ),
          );
        },
      ),
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
            Icon(
              Icons.event_note_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onActionTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(VitranData vitran) {
    final coordinatorName = _getCoordinatorName(vitran);
    final description =
    _displayText(vitran.vitranDescription, fallback: 'No description');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            final vitranId = vitran.vitranId;
            if (vitranId == null || vitranId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vitran id not found')),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SattuVitranDetailPage(
                  event: SattuVitranEvent(
                    vitranId: vitranId,
                    name: _displayText(
                      vitran.vitranName,
                      fallback: 'Sattu Vitran',
                    ),
                    date: DateTime.now(),
                    coordinatorName: coordinatorName,
                    description: description,
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status Indicator / Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _brandColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.event_note,
                    color: _brandColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayText(vitran.vitranName,
                            fallback: 'Sattu Vitran'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Coordinator: $coordinatorName',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (vitran.vitranDescription != null &&
                          vitran.vitranDescription!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                description,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCoordinatorName(VitranData vitran) {
    // First try to get from organizerSamiti
    for (final samiti in vitran.organizerSamiti ?? []) {
      final organizerName = samiti.organizerSamitiName;
      if (organizerName != null && organizerName.isNotEmpty) {
        return organizerName;
      }
    }

    // Then try to get from samitiOrganisers
    for (final organiser in vitran.samitiOrganisers ?? []) {
      final samitiName = organiser.samitiName;
      if (samitiName != null && samitiName.isNotEmpty) {
        return samitiName;
      }
    }

    return 'Not assigned';
  }

  String _displayText(String? value, {required String fallback}) {
    final trimmedValue = value?.trim();
    return trimmedValue == null || trimmedValue.isEmpty
        ? fallback
        : trimmedValue;
  }
}