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

  // Loading states
  bool _isLoadingElections = false;

  // Error states
  String? _errorMessage;

  // Track if elections have been loaded
  bool _hasLoadedElections = false;

  @override
  void initState() {
    super.initState();
    // Auto-load elections when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadElections();
    });
  }

  Future<void> _loadElections() async {
    if (widget.startYear == null || widget.endYear == null || widget.samitiSubCategoryId == null) {
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
        if (_electionList.isEmpty) {
          _errorMessage = 'No elections found for the selected criteria';
        }
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
    // Show loading state
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

    // Show error state
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

    // Show no results state
    if (_electionList.isEmpty && _hasLoadedElections) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No elections found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No election data available for the selected filters',
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

    // Show election list
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

                      if (election.mobile != null && election.mobile!.isNotEmpty)
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