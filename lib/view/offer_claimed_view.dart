import 'package:flutter/material.dart';
import 'package:mpm/model/GetClaimedOfferByID/GetClaimedOfferByIDModelClass.dart';
import 'package:mpm/repository/claimed_offer_by_id_repository/claimed_offer_by_id_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class ClaimedOfferListPage extends StatefulWidget {
  @override
  _ClaimedOfferListPageState createState() => _ClaimedOfferListPageState();
}

class _ClaimedOfferListPageState extends State<ClaimedOfferListPage> {
  late Future<ClaimedOfferModel> _claimedOffersFuture;
  final ClaimOfferRepository _repository = ClaimOfferRepository();
  int? memberId;
  String userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchOffers();
  }

  Future<void> _loadUserDataAndFetchOffers() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData != null) {
        final id = _parseMemberId(userData.memberId);
        if (id != null) {
          final name = _getUserName(
            userData.firstName,
            userData.middleName,
            userData.lastName,
          );

          setState(() {
            memberId = id;
            userName = name;
            _claimedOffersFuture = _repository.fetchClaimedOffersByMemberId(id);
          });
          return;
        }
      }
      setState(() {
        _claimedOffersFuture = Future.error('User data not available');
      });
    } catch (e) {
      setState(() {
        _claimedOffersFuture = Future.error('Failed to load user data: $e');
      });
    }
  }

  String _getUserName(String? firstName, String? middleName, String? lastName) {
    final fName = firstName ?? '';
    final mName = middleName?.isNotEmpty == true ? ' $middleName ' : ' ';
    final lName = lastName ?? '';
    return '$fName$mName$lName'.trim();
  }

  int? _parseMemberId(dynamic memberId) {
    if (memberId == null) return null;
    if (memberId is int) return memberId;
    if (memberId is String) return int.tryParse(memberId);
    return null;
  }

  Widget _buildDefaultLogo() {
    return Center(
      child: Image.asset(
        'assets/images/med-3.png',
        width: 75,
        height: 75,
      ),
    );
  }

  Widget _buildTag(String text, Color color,
      {Color textColor = Colors.white,
        double fontSize = 12,
        EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4)}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

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
      body: FutureBuilder<ClaimedOfferModel>(
        future: _claimedOffersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadUserDataAndFetchOffers,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.data == null || snapshot.data!.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No claimed offers found'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserDataAndFetchOffers,
                    child: Text('Refresh'),
                  ),
                ],
              ),
            );
          } else {
            final offers = snapshot.data!.data!;
            return RefreshIndicator(
              color: Colors.red,
              onRefresh: _loadUserDataAndFetchOffers,
              child: ListView.builder(
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            // Left Logo & Name
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                (offer.orgLogo != null && offer.orgLogo!.isNotEmpty)
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    offer.orgLogo!,
                                    width: 75,
                                    height: 75,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => _buildDefaultLogo(),
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        width: 75,
                                        height: 75,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                                    : _buildDefaultLogo(),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 75,
                                  child: Text(
                                    offer.orgName ?? 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 12),
                            Container(width: 1, color: Colors.grey[400]),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ordered By: $userName',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Claimed on: ${_formatDate(offer.createdAt)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        if (offer.medicines != null && offer.medicines!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Medicines:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ...offer.medicines!.map((medicine) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                                            child: Text(
                                              '• ${medicine.medicineName} (Container Type: ${medicine.medicineContainerId} , Qty: ${medicine.quantity})',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          )).toList(),
                                        ],
                                      ],
                                    ),
                                  ),

                                  if (offer.organisationSubcategoryName != null &&
                                      offer.organisationSubcategoryName!.isNotEmpty)
                                    Positioned(
                                      top: 4,
                                      right: 0,
                                      child: _buildTag(
                                        offer.organisationSubcategoryName!,
                                        Colors.redAccent,
                                        textColor: Colors.white,
                                        fontSize: 10,
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                },
              ),
            );
          }
        },
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}