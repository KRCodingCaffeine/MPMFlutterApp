import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/SamitiElection/SamitiTypes/SamitiTypeData.dart';
import 'package:mpm/repository/SamitiElection/SamitiTypeRepository/samiti_type_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/SamitiElection/consent_status.dart';
import 'package:mpm/view/SamitiElection/samiti_election_form.dart';

import 'package:mpm/view_model/controller/samiti/SamitiController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class SamitiElectionView extends StatefulWidget {
  const SamitiElectionView({super.key});

  @override
  State<SamitiElectionView> createState() => _SamitiElectionViewState();
}

class _SamitiElectionViewState extends State<SamitiElectionView> {
  final SamitiController controller = Get.put(SamitiController());
  final UdateProfileController dashBoardController = Get.find();
  final SamitiTypeRepository _samitiTypeRepository = SamitiTypeRepository();

  final Color _brandColor =
  ColorHelperClass.getColorFromHex(ColorResources.logo_color);

  // Dropdown values
  String? _selectedYearRange;
  String? _selectedSamitiTypeKey;
  String? _selectedSamitiSubCategoryId;

  // Data lists
  List<String> _yearRanges = [];
  List<String> _samitiTypeKeys = [];
  List<SamitiTypeData> _samitiList = [];

  // Loading states
  bool _isLoadingSamitiTypes = false;

  // Track if filters are selected
  bool _hasSelectedFilters = false;

  @override
  void initState() {
    super.initState();
    _generateYearRanges();
    _loadSamitiTypes();
    // Set default year range
    _selectedYearRange = '2026 - 2028';
  }

  void _generateYearRanges() {
    List<String> ranges = [];
    for (int year = 2026; year <= 2034; year += 2) {
      ranges.add('$year - ${year + 2}');
    }
    setState(() {
      _yearRanges = ranges;
    });
  }

  Future<void> _loadSamitiTypes() async {
    setState(() {
      _isLoadingSamitiTypes = true;
    });

    try {
      final response = await _samitiTypeRepository.fetchSamitiTypes();
      if (response.data != null && response.data!.isNotEmpty) {
        setState(() {
          _samitiTypeKeys = response.data!.keys.toList();
        });
      }
    } catch (e) {
      debugPrint('Failed to load Samiti Types: $e');
    } finally {
      setState(() {
        _isLoadingSamitiTypes = false;
      });
    }
  }

  void _loadSamitisForType(String? typeKey) async {
    if (typeKey == null) {
      setState(() {
        _samitiList = [];
        _selectedSamitiSubCategoryId = null;
        _hasSelectedFilters = false;
      });
      return;
    }

    setState(() {
      _isLoadingSamitiTypes = true;
    });

    try {
      final response = await _samitiTypeRepository.fetchSamitiTypes();
      if (response.data != null && response.data!.containsKey(typeKey)) {
        setState(() {
          _samitiList = response.data![typeKey] ?? [];
          if (_selectedSamitiSubCategoryId != null) {
            final exists = _samitiList.any(
                  (s) => s.samitiSubCategoryId == _selectedSamitiSubCategoryId,
            );
            if (!exists) {
              _selectedSamitiSubCategoryId = null;
            }
          }
          _checkFiltersSelected();
        });
      }
    } catch (e) {
      debugPrint('Failed to load Samiti list: $e');
    } finally {
      setState(() {
        _isLoadingSamitiTypes = false;
      });
    }
  }

  void _checkFiltersSelected() {
    setState(() {
      _hasSelectedFilters =
          _selectedYearRange != null &&
              _selectedSamitiTypeKey != null &&
              _selectedSamitiSubCategoryId != null;
    });
  }

  // Get start year and end year from selected range
  Map<String, String> _getYearRange() {
    if (_selectedYearRange == null) return {};
    final parts = _selectedYearRange!.split(' - ');
    return {
      'startYear': parts[0],
      'endYear': parts[1],
    };
  }

  // Add this method to get the samiti ID from the selected sub-category
  String? _getSamitiId() {
    if (_selectedSamitiSubCategoryId == null) return null;

    // Find the selected samiti in the list
    final selectedSamiti = _samitiList.firstWhere(
          (samiti) => samiti.samitiSubCategoryId == _selectedSamitiSubCategoryId,
      orElse: () => SamitiTypeData(),
    );

    // Return the samitiId (which should be the numeric ID)
    return selectedSamiti.samitiId;
  }

  // Navigate to Election Form with parameters
  void _openElectionForm() {
    if (!_hasSelectedFilters) return;

    final yearRange = _getYearRange();
    final samitiId = _getSamitiId();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SamitiElectionFormView(
          startYear: yearRange['startYear'],
          endYear: yearRange['endYear'],
          samitiTypeKey: samitiId,
          samitiSubCategoryId: _selectedSamitiSubCategoryId,
        ),
      ),
    );
  }

  // Navigate to Consent Status with parameters
  void _openConsentStatus() {
    if (!_hasSelectedFilters) return;

    final yearRange = _getYearRange();
    final samitiId = _getSamitiId();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsentStatus(
          startYear: yearRange['startYear'],
          endYear: yearRange['endYear'],
          samitiTypeKey: samitiId,
          samitiSubCategoryId: _selectedSamitiSubCategoryId,
        ),
      ),
    );
  }

  // Button builder for action buttons
  Widget _buildActionButton(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 130,
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 45),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _brandColor,
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Samiti Election',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section Card
            _buildFilterCard(),
            const SizedBox(height: 16),

            // Action Buttons (only show when filters are selected)
            if (_hasSelectedFilters) ...[
              _buildActionButton(
                context,
                "Election Form",
                Icons.how_to_vote,
                Colors.blue,
                _openElectionForm,
              ),
              _buildActionButton(
                context,
                "Consent Status",
                Icons.assignment_turned_in,
                Colors.green,
                _openConsentStatus,
              ),
            ] else ...[
              // Empty state when filters not selected
              _buildEmptyState(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: _brandColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Select Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildYearRangeDropdown(),
          const SizedBox(height: 12),
          _buildSamitiTypeDropdown(),
          const SizedBox(height: 12),
          _buildSamitiDropdown(),
        ],
      ),
    );
  }

  Widget _buildYearRangeDropdown() {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      borderRadius:
      BorderRadius.circular(10),
      isExpanded: true,
      value: _selectedYearRange,
      hint: const Text('Select Year Range'),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _brandColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        prefixIcon: Icon(
          Icons.calendar_today,
          color: Colors.grey.shade600,
          size: 20,
        ),
      ),
      items: _yearRanges.map((String yearRange) {
        return DropdownMenuItem<String>(
          value: yearRange,
          child: Text(yearRange),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedYearRange = newValue;
          _checkFiltersSelected();
        });
      },
    );
  }

  Widget _buildSamitiTypeDropdown() {
    final List<DropdownMenuItem<String>> items = _samitiTypeKeys.map((String key) {
      return DropdownMenuItem<String>(
        value: key,
        child: Text(key),
      );
    }).toList();

    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      borderRadius:
      BorderRadius.circular(10),
      value: _selectedSamitiTypeKey,
      hint: _samitiTypeKeys.isEmpty && !_isLoadingSamitiTypes
          ? const Text('No Types Available')
          : const Text('Select Samiti Type'),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _brandColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        prefixIcon: Icon(
          Icons.category,
          color: Colors.grey.shade600,
          size: 20,
        ),
        suffixIcon: _isLoadingSamitiTypes
            ? const SizedBox(
          width: 20,
          height: 20,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        )
            : null,
      ),
      items: items,
      onChanged: _isLoadingSamitiTypes ? null : (String? newValue) {
        setState(() {
          _selectedSamitiTypeKey = newValue;
          _selectedSamitiSubCategoryId = null;
          _samitiList = [];
          _hasSelectedFilters = false;

          if (newValue != null) {
            _loadSamitisForType(newValue);
          }
        });
      },
      isExpanded: true,
    );
  }

  Widget _buildSamitiDropdown() {
    final List<DropdownMenuItem<String>> items = _samitiList.map((SamitiTypeData samiti) {
      return DropdownMenuItem<String>(
        value: samiti.samitiSubCategoryId,
        child: Text(
          samiti.samitiSubCategoryName ?? 'Unknown',
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();

    final bool isLoading = _isLoadingSamitiTypes;

    final bool hasValidValue = _selectedSamitiSubCategoryId != null &&
        items.any((item) => item.value == _selectedSamitiSubCategoryId);

    if (_selectedSamitiSubCategoryId != null && !hasValidValue && items.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedSamitiSubCategoryId != null) {
          final exists = items.any((item) => item.value == _selectedSamitiSubCategoryId);
          if (!exists) {
            setState(() {
              _selectedSamitiSubCategoryId = null;
            });
          }
        }
      });
    }

    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      borderRadius:
      BorderRadius.circular(10),
      value: hasValidValue ? _selectedSamitiSubCategoryId : null,
      hint: _samitiList.isEmpty && !isLoading
          ? const Text('No Samitis Available')
          : const Text('Select Samiti'),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _brandColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        prefixIcon: Icon(
          Icons.business,
          color: Colors.grey.shade600,
          size: 20,
        ),
        suffixIcon: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        )
            : null,
      ),
      items: items,
      onChanged: (isLoading || _selectedSamitiTypeKey == null)
          ? null
          : (String? newValue) {
        setState(() {
          _selectedSamitiSubCategoryId = newValue;
          _checkFiltersSelected();
        });
      },
      isExpanded: true,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_alt_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Select Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please select Year Range, Samiti Type\nand Samiti to continue',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}