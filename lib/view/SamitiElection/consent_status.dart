import 'package:flutter/material.dart';
import 'package:mpm/model/SamitiElection/ElectionList/ElectionData.dart';
import 'package:mpm/model/SamitiElection/ElectionList/ElectionModelClass.dart';
import 'package:mpm/repository/SamitiElection/ElectionListRepository/election_list_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class ConsentStatus extends StatefulWidget {
  final String? startYear;
  final String? endYear;
  final String? samitiTypeKey;
  final String? samitiSubCategoryId;

  const ConsentStatus({
    super.key,
    this.startYear,
    this.endYear,
    this.samitiTypeKey,
    this.samitiSubCategoryId,
  });

  @override
  State<ConsentStatus> createState() => _ConsentStatusState();
}

class _ConsentStatusState extends State<ConsentStatus> {
  final ElectionRepository _electionRepository = ElectionRepository();

  final Color _brandColor =
      ColorHelperClass.getColorFromHex(ColorResources.logo_color);

  List<ElectionData> _electionList = [];

  bool _isLoadingElections = false;

  String? _errorMessage;

  bool _hasLoadedElections = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadElections();
    });
  }

  Future<void> _loadElections() async {
    if (widget.startYear == null ||
        widget.endYear == null ||
        widget.samitiSubCategoryId == null) {
      setState(() {
        _errorMessage = 'Missing required parameters';
        _hasLoadedElections = true;
      });
      return;
    }

    setState(() {
      _isLoadingElections = true;
      _electionList = [];
      _errorMessage = null;
      _hasLoadedElections = true;
    });

    try {
      final response = await _electionRepository.fetchElections(
        startYear: widget.startYear!,
        endYear: widget.endYear!,
        samitiSubCategoryId: widget.samitiSubCategoryId,
      );

      final electionModel = ElectionModelClass.fromJson(response);

      setState(() {
        _electionList = electionModel.data ?? [];
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load elections: $e';
      });
    } finally {
      setState(() {
        _isLoadingElections = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadElections();
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
              'Consent Status',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
      ),
      body: RefreshIndicator(
        color: _brandColor,
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Results Section
              _buildResultsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    // 1. Loading
    if (_isLoadingElections) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading elections...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Error (only when we have an actual error AND no data)
    if (_errorMessage != null && _electionList.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. No records — empty list after successful load
    if (_electionList.isEmpty && _hasLoadedElections) {
      return _buildEmptyState();
    }

    // 4. Election list
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _electionList.length,
      itemBuilder: (context, index) {
        final election = _electionList[index];
        return _buildElectionCard(election);
      },
    );
  }

  /// Polished empty state UI
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: _brandColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 44,
                color: _brandColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Record Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No consent records are available for the selected Samiti.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElectionCard(ElectionData election) {
    final statusColor = _getStatusColor(election.status);
    final statusText = _getStatusText(election.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            // Handle tap if needed
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _brandColor.withOpacity(0.1),
                  child: Text(
                    (election.firstName?.isNotEmpty ?? false)
                        ? election.firstName![0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: _brandColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        election.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (election.memberCode != null &&
                          election.memberCode!.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              'Membership Code: ',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                election.memberCode!,
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
                      if (election.mobile != null &&
                          election.mobile!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              election.mobile!,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      if (election.email != null && election.email!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.email,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                election.email!,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Consent Status: $statusText',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'consent_approved':
        return Colors.green;
      case 'consent_sent':
        return Colors.orange;
      case 'conversion_pending':
        return Colors.red;
      case 'awaiting_admin_confirm':
        return Colors.green;
      case 'rejected':
        return Colors.red.shade700;
      case 'cancelled':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'consent_approved':
        return 'Consent Given';
      case 'consent_sent':
        return 'Consent Sent';
      case 'conversion_pending':
        return 'Conversion Pending';
      case 'awaiting_admin_confirm':
        return 'Consent Given';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status ?? 'Unknown';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
