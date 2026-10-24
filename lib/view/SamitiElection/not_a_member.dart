import 'package:flutter/material.dart';
import 'package:mpm/model/SamitiElection/ElectionList/ElectionData.dart';
import 'package:mpm/model/SamitiElection/ElectionList/ElectionModelClass.dart';
import 'package:mpm/model/SamitiElection/SamitiTypes/SamitiTypeData.dart';
import 'package:mpm/model/SamitiElection/SamitiTypes/SamitiTypeModelClass.dart';
import 'package:mpm/repository/SamitiElection/DeleteNotAnMemberRepository/delete_not_an_member_repo.dart';
import 'package:mpm/repository/SamitiElection/ElectionListRepository/election_list_repo.dart';
import 'package:mpm/repository/SamitiElection/SamitiTypeRepository/samiti_type_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class NotAMemberView extends StatefulWidget {
  final String? startYear;
  final String? endYear;
  final String? samitiTypeKey;
  final String? samitiSubCategoryId;

  const NotAMemberView({
    super.key,
    this.startYear,
    this.endYear,
    this.samitiTypeKey,
    this.samitiSubCategoryId,
  });

  @override
  State<NotAMemberView> createState() => _NotAMemberViewState();
}

class _NotAMemberViewState extends State<NotAMemberView> {
  final ElectionRepository _electionRepository = ElectionRepository();
  final SamitiTypeRepository _samitiTypeRepository = SamitiTypeRepository();
  final DeleteNotAnMemberRepository _deleteRepository =
      DeleteNotAnMemberRepository();

  final Color _brandColor =
      ColorHelperClass.getColorFromHex(ColorResources.logo_color);

  // Fixed year range
  static const String _startYear = '2026';
  static const String _endYear = '2028';

  List<ElectionData> _memberList = [];

  // Lookup maps for samiti type + category names
  Map<String, String> _samitiCategoryToTypeMap = {}; // subCatId -> typeName
  Map<String, String> _samitiCategoryNameMap = {}; // subCatId -> subCatName

  bool _isLoading = false;
  bool _isLoadingLookups = true;
  String? _errorMessage;
  bool _hasLoaded = false;

  // Track which card is being deleted
  String? _deletingElectionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadSamitiLookups();
      await _loadNotAMembers();
    });
  }

  // ============================================
  // BUILD LOOKUP MAPS from Samiti Types API
  // ============================================
  Future<void> _loadSamitiLookups() async {
    setState(() {
      _isLoadingLookups = true;
    });

    try {
      final SamitiTypeModelClass response =
          await _samitiTypeRepository.fetchSamitiTypes();

      final Map<String, List<SamitiTypeData>>? data = response.data;

      if (data != null) {
        data.forEach((samitiTypeName, samitiList) {
          for (final samiti in samitiList) {
            final subCatId = samiti.samitiSubCategoryId;
            if (subCatId != null && subCatId.isNotEmpty) {
              _samitiCategoryToTypeMap[subCatId] = samitiTypeName;
              _samitiCategoryNameMap[subCatId] =
                  samiti.samitiSubCategoryName ?? '-';
            }
          }
        });
      }

      debugPrint('Loaded Samiti lookup entries: '
          '${_samitiCategoryToTypeMap.length}');
    } catch (e) {
      debugPrint('Failed to load Samiti lookups: $e');
    } finally {
      setState(() {
        _isLoadingLookups = false;
      });
    }
  }

  // ============================================
  // LOAD NOT_A_MEMBER LIST (all samiti)
  // ============================================
  Future<void> _loadNotAMembers() async {
    setState(() {
      _isLoading = true;
      _memberList = [];
      _errorMessage = null;
      _hasLoaded = true;
    });

    try {
      final response = await _electionRepository.fetchElections(
        startYear: _startYear,
        endYear: _endYear,
        samitiSubCategoryId: null,
      );

      final electionModel = ElectionModelClass.fromJson(response);

      final allElections = electionModel.data ?? [];
      final filtered = allElections
          .where((e) =>
              (e.candidateType ?? '').toUpperCase().trim() == 'NOT_A_MEMBER')
          .toList();

      setState(() {
        _memberList = filtered;
        if (_memberList.isEmpty) {
          _errorMessage = 'No Not-A-Member records found for 2026 - 2028';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadSamitiLookups();
    await _loadNotAMembers();
  }

  String _getSamitiTypeName(ElectionData member) {
    final subCatId = member.samitiSubCategoryId;
    if (subCatId != null && _samitiCategoryToTypeMap.containsKey(subCatId)) {
      return _samitiCategoryToTypeMap[subCatId] ?? '-';
    }
    return '-';
  }

  String _getSamitiName(ElectionData member) {
    final subCatId = member.samitiSubCategoryId;
    if (subCatId != null && _samitiCategoryNameMap.containsKey(subCatId)) {
      return _samitiCategoryNameMap[subCatId] ?? '-';
    }
    return '-';
  }

  // ============================================
  // ✅ DELETE FLOW:
  // 1. User taps Delete button
  // 2. Confirmation dialog appears
  // 3. User taps "Yes, Delete"
  // 4. API call fires, member removed from list
  // ============================================
  Future<void> _deleteMember(ElectionData member) async {
    // Status guard
    final normalizedStatus = (member.status ?? '').trim().toLowerCase();
    final canDelete = normalizedStatus == 'consent_approved' ||
        normalizedStatus == 'awaiting_admin_confirm';

    if (!canDelete) {
      _showSnackBar(
        'Member can only be deleted after consent is approved.',
        isError: true,
      );
      return;
    }

    // STEP 1: Confirmation dialog
    final confirmed = await _showDeleteConfirmation(member);
    if (!confirmed) return;

    // Validate election ID
    if (member.electionId == null || member.electionId!.isEmpty) {
      _showSnackBar(
        'Election ID is missing. Cannot delete.',
        isError: true,
      );
      return;
    }

    // Show loading state on the card's delete button
    setState(() {
      _deletingElectionId = member.electionId;
    });

    // STEP 2: Call API
    try {
      debugPrint('========================================');
      debugPrint('Deleting Not-A-Member');
      debugPrint('Election ID: ${member.electionId}');
      debugPrint('Consent Status: ${member.status}');
      debugPrint('========================================');

      final response = await _deleteRepository.deleteNotAnMember(
        electionId: member.electionId!,
      );

      debugPrint('Delete API Status: ${response.status}');
      debugPrint('Delete API Code: ${response.code}');
      debugPrint('Delete API Message: ${response.message}');

      if (response.status == true) {
        // ✅ Success message
        _showSnackBar(
          response.message ?? 'Member deleted successfully.',
        );

        // ✅ RELOAD the list from the server
        await _loadNotAMembers();
      } else {
        _showSnackBar(
          response.message ?? 'Failed to delete member.',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('========================================');
      debugPrint('Delete error: $e');
      debugPrint('========================================');

      _showSnackBar(
        'Error deleting member. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingElectionId = null;
        });
      }
    }
  }

  Future<bool> _showDeleteConfirmation(ElectionData member) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Delete Member",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to delete ${member.fullName} ?",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
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
              'Not A Member',
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
              _buildYearRangeChip(),
              const SizedBox(height: 12),
              _buildResultsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearRangeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _brandColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _brandColor.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 16, color: _brandColor),
          const SizedBox(width: 8),
          Text(
            'Year Range: $_startYear - $_endYear',
            style: TextStyle(
              color: _brandColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_isLoading || _isLoadingLookups) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading Not-A-Member records...',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null && _memberList.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 64,
                color: Colors.orange.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No Records',
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _memberList.length,
      itemBuilder: (context, index) {
        final member = _memberList[index];
        return _buildMemberCard(member);
      },
    );
  }

  Widget _buildMemberCard(ElectionData member) {
    final statusColor = _getStatusColor(member.status);
    final statusText = _getStatusText(member.status);
    final isDeleting = _deletingElectionId == member.electionId;

    final samitiTypeName = _getSamitiTypeName(member);
    final samitiName = _getSamitiName(member);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============ TOP ROW: Avatar + Info ============
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _brandColor.withOpacity(0.1),
                    child: Text(
                      (member.firstName?.isNotEmpty ?? false)
                          ? member.firstName![0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: _brandColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.fullName.isNotEmpty ? member.fullName : '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (member.memberCode != null &&
                            member.memberCode!.isNotEmpty)
                          Row(
                            children: [
                              Text(
                                'Code: ',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  member.memberCode!,
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
                        if (samitiTypeName != '-')
                          Row(
                            children: [
                              Icon(Icons.category,
                                  size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  samitiTypeName,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        if (samitiName != '-')
                          Row(
                            children: [
                              Icon(Icons.business,
                                  size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  samitiName,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        if (member.mobile != null && member.mobile!.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.phone,
                                  size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                member.mobile!,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        if (member.email != null && member.email!.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.email,
                                  size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  member.email!,
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
                        if (member.startYear != null || member.endYear != null)
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                '${member.startYear ?? '-'} - ${member.endYear ?? '-'}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ============ BOTTOM ROW: Status + Delete ============
              Row(
                children: [
                  Flexible(
                    child: Container(
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
                      child: Text(
                        'Consent: $statusText',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildDeleteButton(member, isDeleting),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // DELETE BUTTON — enabled for approved / awaiting_admin_confirm
  // ============================================
  Widget _buildDeleteButton(ElectionData member, bool isDeleting) {
    final normalizedStatus = (member.status ?? '').trim().toLowerCase();

    final canDelete = normalizedStatus == 'consent_approved' ||
        normalizedStatus == 'awaiting_admin_confirm';

    final button = SizedBox(
      height: 34,
      child: ElevatedButton.icon(
        onPressed:
            (!canDelete || isDeleting) ? null : () => _deleteMember(member),
        icon: isDeleting
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                canDelete ? Icons.delete_outline : Icons.lock_outline,
                size: 16,
                color: Colors.white,
              ),
        label: Text(
          isDeleting ? 'Deleting...' : 'Delete',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              canDelete ? Colors.red.shade600 : Colors.grey.shade400,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
    );

    if (!canDelete) {
      return Tooltip(
        message: 'Delete is enabled only after consent is approved',
        child: button,
      );
    }

    return button;
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'consent_approved':
      case 'awaiting_admin_confirm':
        return Colors.green;
      case 'consent_sent':
        return Colors.orange;
      case 'conversion_pending':
        return Colors.red;
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
