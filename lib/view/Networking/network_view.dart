// lib/view/Networking/network_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:mpm/model/BusinessProfile/BusinessAddress/BusinessAddressData.dart';
import 'package:mpm/model/BusinessProfile/BusinessOccupationProfile/BusinessOccupationProfileData.dart';
import 'package:mpm/model/BusinessProfile/GetAllBusinessOccupationProfile/GetAllBusinessOccupationProfileModelClass.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/model/SearchOccupation/SearchOccupationData.dart';
import 'package:mpm/model/SearchOccupation/SearchOccupationModelClass.dart';
import 'package:mpm/repository/BusinessProfileRepo/business_occupation_profile_repository/business_occupation_profile_repo.dart';
import 'package:mpm/repository/BusinessProfileRepo/send_business_profile_repository/send_business_profile_repo.dart';
import 'package:mpm/repository/search_occupation_repository/search_occupation_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/Networking/filter_bottom_sheet.dart';
import 'package:mpm/view/Networking/network_filters.dart';
import 'package:mpm/view/profile%20view/business_info_page.dart';
import 'package:mpm/view/profile%20view/occupation_detail_view.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';


class NetworkView extends StatefulWidget {
  const NetworkView({super.key});

  @override
  State<NetworkView> createState() => _NetworkViewState();
}

class _NetworkViewState extends State<NetworkView> {
  UdateProfileController controller =Get.put(UdateProfileController());
  final TextEditingController _searchController = TextEditingController();
  final SearchOccupationRepository _repo = SearchOccupationRepository();
  final SendBusinessProfileRepository _sendRepo =
      SendBusinessProfileRepository();
  final BusinessOccupationProfileRepository _businessRepo =
  BusinessOccupationProfileRepository();

  @override
  void initState() {
    super.initState();
    // Listen to search controller changes to update UI (for clear button)
    _searchController.addListener(() {
      setState(() {}); // Rebuild to show/hide clear button
    });
  }

  // Search state
  Timer? _debounceTimer;
  bool _isLoading = false;
  bool _hasSearched = false;
  List<SearchOccupationData> _results = [];
  List<SearchOccupationData> _allResults =
      []; // Store all unfiltered results from API

  // Filters
  NetworkFilters _filters = NetworkFilters.empty();

  // Pagination
  int _currentPage = 1;
  final int _limit = 20;
  int _totalResults = 0;
  int _totalPages = 1;

  // Filter options from API
  Map<String, dynamic> _availableFilters = {
    'zones': [],
    'occupations': [],
    'professions': [],
    'specializations': [],
    'subcategories': [],
    'sub_subcategories': [],
    'product_categories': [],
    'product_subcategories': [],
  };

  // Track matched level and value from search
  String? _matchedLevel;
  String? _matchedValue;

  // Search suggestions - using dynamic to avoid import issues
  List<dynamic> _suggestions = [];
  bool _showSuggestions = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Load search suggestions
  Future<void> _loadSuggestions(String query) async {
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      debugPrint("Loading suggestions for: $query");
      final suggestions = await _repo.searchSuggestions(keyword: query);
      debugPrint("Received ${suggestions.length} suggestions");
      for (var sug in suggestions) {
        debugPrint("  - ${sug.displayText ?? sug.name} (${sug.type})");
      }
      setState(() {
        _suggestions = suggestions;
        _showSuggestions = suggestions.isNotEmpty;
        debugPrint("Setting _showSuggestions to: ${suggestions.isNotEmpty}");
        debugPrint("_suggestions.length: ${_suggestions.length}");
      });
    } catch (e) {
      debugPrint("Error loading suggestions: $e");
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  Future<BusinessOccupationProfileData?> _fetchBusinessProfile(String memberId) async {
    try {
      final res = await _businessRepo.fetchBusinessOccupationProfiles(
        memberId: memberId,
        fullDetails: true,
      );

      // If no data, return null
      if (res.data == null || res.data!.isEmpty) return null;

      // Return the first profile directly
      return res.data!.first;
    } catch (e) {
      debugPrint("❌ Error fetching business profile: $e");
      return null;
    }
  }

  // Handle suggestion tap - THIS IS THE ONLY WAY TO TRIGGER SEARCH
  void _onSuggestionTap(dynamic suggestion) {
    // Use search_term from suggestion for the actual search
    final searchValue =
        suggestion.searchTerm ?? suggestion.value ?? suggestion.name ?? '';
    debugPrint(
        "Suggestion tapped: ${suggestion.displayText ?? suggestion.name} (${suggestion.type})");
    debugPrint("Using search_term: $searchValue");

    setState(() {
      _searchController.text = searchValue;
      _showSuggestions = false;
      _searchFocusNode.unfocus();
    });

    // Trigger search ONLY when suggestion is clicked
    if (searchValue.isNotEmpty) {
      _performSearch(resetPage: true);
    } else {
      debugPrint("Search term is empty");
    }
  }

// In your NetworkView class
  Future<void> _performSearch({bool resetPage = true}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    final searchTerm = _searchController.text.trim();

    // Check for minimum characters (at least 3 as per your web implementation)
    if (searchTerm.length < 3) {
      if (searchTerm.isEmpty) {
        setState(() {
          _results = [];
          _hasSearched = false;
          _totalResults = 0;
        });
      } else {
        // Show message for minimum characters
        setState(() {
          _results = [];
          _hasSearched = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      debugPrint("Performing search for: '$searchTerm', Page: $_currentPage");
      debugPrint("Active filters: ${_filters.hasFilters}");

      // Calculate offset based on page
      final offset = (_currentPage - 1) * _limit;

      final response = await _repo.searchOccupation(
        searchTerm: searchTerm,
        limit: _limit,
        offset: offset,
        filters: _filters.hasFilters ? _filters : null,
      );

      debugPrint("Search completed successfully");
      debugPrint("Total results: ${response.data?.length ?? 0}");

      setState(() {
        if (resetPage) {
          _allResults = response.data ?? [];
        } else {
          // For pagination, append new results
          _allResults.addAll(response.data ?? []);
        }

        _totalResults = response.totalResults ?? 0;
        _totalPages = (_totalResults / _limit).ceil();
        debugPrint("Total results from API: $_totalResults");
        debugPrint("Results data length: ${response.data?.length ?? 0}");

        // Apply filters to the results
        _applyLocalFilters();

        // Update filter options from API response or extract from results
        if (response.filters != null) {
          debugPrint("========== FILTERS FROM API ==========");
          debugPrint(
              "Occupations (${response.filters!.occupations.length}): ${response.filters!.occupations}");
          debugPrint(
              "Professions (${response.filters!.professions.length}): ${response.filters!.professions}");
          debugPrint(
              "Specializations (${response.filters!.specializations.length}): ${response.filters!.specializations}");
          debugPrint(
              "Subcategories (${response.filters!.subcategories.length}): ${response.filters!.subcategories}");
          debugPrint(
              "Sub-subcategories (${response.filters!.subSubcategories.length}): ${response.filters!.subSubcategories}");
          debugPrint("======================================");

          // Check if subcategories should be hidden (if it only contains the matched search term)
          List<String> subcategoriesToShow = response.filters!.subcategories;
          if (subcategoriesToShow.length == 1 &&
              subcategoriesToShow.first.toLowerCase() ==
                  searchTerm.toLowerCase()) {
            debugPrint(
                "Hiding subcategories - only contains matched search term: ${subcategoriesToShow.first}");
            subcategoriesToShow = [];
          }

          _availableFilters = {
            'zones': response.filters!.zones, // Zones from API
            'occupations':
                response.filters!.occupations, // Will be hidden if empty
            'professions':
                response.filters!.professions, // Will be hidden if empty
            'specializations':
                response.filters!.specializations, // Will be hidden if empty
            'subcategories':
                subcategoriesToShow, // Hidden if empty or only matched term
            'sub_subcategories': response
                .filters!.subSubcategories, // Show all sub-subcategories
            'product_categories': [],
            'product_subcategories': [],
          };
        } else {
          debugPrint(
              "========== NO FILTERS IN API - EXTRACTING FROM RESULTS ==========");
          // Extract filters from search results (matching PHP formatFilters logic)
          _availableFilters = _extractFiltersFromResults(_allResults);
          debugPrint(
              "Extracted Occupations (${_availableFilters['occupations']!.length}): ${_availableFilters['occupations']}");
          debugPrint(
              "Extracted Professions (${_availableFilters['professions']!.length}): ${_availableFilters['professions']}");
          debugPrint(
              "Extracted Specializations (${_availableFilters['specializations']!.length}): ${_availableFilters['specializations']}");
          debugPrint(
              "Extracted Subcategories (${_availableFilters['subcategories']!.length}): ${_availableFilters['subcategories']}");
          debugPrint(
              "Extracted Sub-subcategories (${_availableFilters['sub_subcategories']!.length}): ${_availableFilters['sub_subcategories']}");
          debugPrint(
              "=================================================================");
        }

        // Update matched level and value
        _matchedLevel = response.matchedLevel;
        // Clean matched value if it's an object string
        String? cleanMatchedValue = response.matchedValue;
        if (cleanMatchedValue != null && cleanMatchedValue.startsWith('{')) {
          // Try to extract name from object string
          final match = RegExp(r'occupation_name:\s*([^,}]+)')
              .firstMatch(cleanMatchedValue);
          if (match != null) {
            cleanMatchedValue = match.group(1)?.trim();
          } else {
            // Try profession_name
            final profMatch = RegExp(r'profession_name:\s*([^,}]+)')
                .firstMatch(cleanMatchedValue);
            if (profMatch != null) {
              cleanMatchedValue = profMatch.group(1)?.trim();
            }
          }
        }
        _matchedValue = cleanMatchedValue;

        // Debug information
        debugPrint("Updated results count: ${_results.length}");
        debugPrint("Total pages: $_totalPages");
        debugPrint(
            "Matched level: $_matchedLevel, Matched value: $_matchedValue");
      });
    } catch (e) {
      debugPrint("Search Error: $e");

      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('400')
                  ? "Search term must be at least 3 characters"
                  : "Error: ${e.toString().replaceAll('Exception: ', '')}",
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

// Add a test button to check API connection
  Widget _buildTestApiButton() {
    return FloatingActionButton(
      onPressed: () async {
        await _repo.testApiConnection();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Testing API connection... Check logs for results"),
            backgroundColor: Colors.blue,
          ),
        );
      },
      backgroundColor: Colors.blue,
      child: const Icon(Icons.wifi_find),
    );
  }

  Future<void> _openFilterSheet() async {
    final newFilters = await showModalBottomSheet<NetworkFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterBottomSheet(
          initialFilters: _filters, // Pass current filters to maintain state
          searchQuery: _searchController.text.trim(),
          availableFilters: _availableFilters,
          matchedLevel: _matchedLevel,
          matchedValue: _matchedValue,
          onFilterChanged: (updatedFilters) {
            // Apply filters immediately when changed (without closing sheet)
            setState(() {
              _filters = updatedFilters;
              _applyLocalFilters(); // Filter locally instead of making API call
            });
          },
        );
      },
    );

    // Update filters when sheet is closed (for final state)
    if (newFilters != null) {
      setState(() {
        _filters = newFilters;
        _applyLocalFilters(); // Apply filters locally
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _filters = NetworkFilters.empty();
      _applyLocalFilters(); // Re-apply filters (will show all results)
    });
  }

  // Check if there are any filters available to show (more than 1 item per filter type)
  bool _hasFiltersAvailable() {
    // Check zones
    final zones = _availableFilters['zones'] as List?;
    if (zones != null && zones.length > 1) return true;
    
    // Check other filters (they should be List<String>)
    final filterKeys = ['occupations', 'professions', 'specializations', 'subcategories', 'sub_subcategories', 'product_categories', 'product_subcategories'];
    for (var key in filterKeys) {
      final filterList = _availableFilters[key] as List?;
      if (filterList != null && filterList.length > 1) {
        return true;
      }
    }
    return false;
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _showSuggestions = false;
      _suggestions = [];
      _results = [];
      _allResults = [];
      _hasSearched = false;
      _totalResults = 0;
      _filters = NetworkFilters.empty();
      _matchedLevel = null;
      _matchedValue = null;
      _searchFocusNode.unfocus();
    });
  }

  // Filter results locally based on selected filters
  void _applyLocalFilters() {
    if (_allResults.isEmpty) {
      _results = [];
      return;
    }

    if (!_filters.hasFilters) {
      // No filters selected, show all results
      _results = List.from(_allResults);
      debugPrint("No filters applied - showing all ${_results.length} results");
      return;
    }

    debugPrint("========== APPLYING FILTERS ==========");
    debugPrint("Selected occupations: ${_filters.occupations}");
    debugPrint("Selected professions: ${_filters.professions}");
    debugPrint("Selected specializations: ${_filters.specializations}");
    debugPrint("Selected subcategories: ${_filters.subcategories}");
    debugPrint("Selected subSubcategories: ${_filters.subSubcategories}");
    debugPrint("Selected zones: ${_filters.zones}");
    debugPrint("Total results before filtering: ${_allResults.length}");
    if (_filters.zones.isNotEmpty) {
      debugPrint("Sample member zones: ${_allResults.take(3).map((m) => '${m.fullName}: zone=${m.zoneName} (id=${m.zoneId})').join(', ')}");
    }

    // Helper function to normalize strings for comparison
    String normalize(String? str) {
      if (str == null) return '';
      return str.trim().toLowerCase();
    }

    // Filter results based on selected filters
    _results = _allResults.where((member) {
      // Check occupation filter
      if (_filters.occupations.isNotEmpty) {
        final memberOccupation = normalize(member.occupationNameValue);
        final matches = _filters.occupations.any((filterOcc) => 
          normalize(filterOcc) == memberOccupation
        );
        if (!matches) {
          return false;
        }
      }

      // Check profession filter
      if (_filters.professions.isNotEmpty) {
        final memberProfession = normalize(member.professionNameValue);
        final matches = _filters.professions.any((filterProf) => 
          normalize(filterProf) == memberProfession
        );
        if (!matches) {
          return false;
        }
      }

      // Check specialization filter
      if (_filters.specializations.isNotEmpty) {
        final memberSpecialization = normalize(member.specializationNameValue);
        final matches = _filters.specializations.any((filterSpec) => 
          normalize(filterSpec) == memberSpecialization
        );
        if (!matches) {
          return false;
        }
      }

      // Check subcategory filter
      if (_filters.subcategories.isNotEmpty) {
        final memberSubcategory = normalize(member.subCategoryNameValue);
        final matches = _filters.subcategories.any((filterSubcat) => 
          normalize(filterSubcat) == memberSubcategory
        );
        if (!matches) {
          return false;
        }
      }

      // Check sub-subcategory filter
      if (_filters.subSubcategories.isNotEmpty) {
        final memberSubSubcategory = normalize(member.subSubCategoryNameValue);
        final matches = _filters.subSubcategories.any((filterSubSubcat) => 
          normalize(filterSubSubcat) == memberSubSubcategory
        );
        if (!matches) {
          return false;
        }
      }

      // Check zone filter
      if (_filters.zones.isNotEmpty) {
        final memberZoneName = normalize(member.zoneName);
        final memberZoneId = normalize(member.zoneId);
        final matches = _filters.zones.any((filterZone) {
          final normalizedFilterZone = normalize(filterZone);
          return normalizedFilterZone == memberZoneName || normalizedFilterZone == memberZoneId;
        });
        if (!matches) {
          return false;
        }
      }

      return true;
    }).toList();

    debugPrint("Filtered results: ${_results.length} out of ${_allResults.length}");
    debugPrint("======================================");
  }

  // Extract filters from search results - matches PHP formatFilters() function
  Map<String, dynamic> _extractFiltersFromResults(
      List<SearchOccupationData> results) {
    // Helper function to format filters (matches PHP formatFilters logic)
    // BUT exclude 'Other' as per requirement
    List<String> formatFilters(List<String?> list) {
      // Filter out null, empty, and 'Other' values
      final mapped = list
          .where((v) => v != null && v.isNotEmpty && v.toLowerCase() != 'other')
          .map((v) => v!)
          .toList();
      // Get unique values
      final unique = mapped.toSet().toList();
      // Limit to 100 items
      return unique.take(100).toList();
    }

    // Extract from results - handle both direct fields and nested occupation object
    final occupations = <String>[];
    final professions = <String>[];
    final specializations = <String>[];
    final subcategories = <String>[];
    final subSubcategories = <String>[];

    for (var result in results) {
      // Extract occupation name
      final occName = result.occupationNameValue;
      if (occName != null &&
          occName.isNotEmpty &&
          occName.toLowerCase() != 'other') {
        occupations.add(occName);
      }

      // Extract profession name
      final profName = result.professionNameValue;
      if (profName != null &&
          profName.isNotEmpty &&
          profName.toLowerCase() != 'other') {
        professions.add(profName);
      }

      // Extract specialization name
      final specName = result.specializationNameValue;
      if (specName != null &&
          specName.isNotEmpty &&
          specName.toLowerCase() != 'other') {
        specializations.add(specName);
      }

      // Extract subcategory name
      final subcatName = result.subCategoryName;
      if (subcatName != null &&
          subcatName.isNotEmpty &&
          subcatName.toLowerCase() != 'other') {
        subcategories.add(subcatName);
      }

      // Extract sub-subcategory name
      final subSubcatName = result.subSubCategoryName;
      if (subSubcatName != null &&
          subSubcatName.isNotEmpty &&
          subSubcatName.toLowerCase() != 'other') {
        subSubcategories.add(subSubcatName);
      }
    }

    return {
      'zones': [], // Zones come from API filters, not from results
      'occupations': occupations.toSet().toList(),
      'professions': professions.toSet().toList(),
      'specializations': specializations.toSet().toList(),
      'subcategories': subcategories.toSet().toList(),
      'sub_subcategories': subSubcategories.toSet().toList(),
      'product_categories': [],
      'product_subcategories': [],
    };
  }

  // Get icon for suggestion type
  IconData _getSuggestionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'occupation':
        return Icons.work;
      case 'profession':
        return Icons.business_center;
      case 'specialization':
        return Icons.star;
      case 'specialization_sub_category':
      case 'subcategory':
        return Icons.category;
      case 'specialization_sub_sub_category':
      case 'sub subcategory':
        return Icons.label;
      default:
        return Icons.search;
    }
  }

  // Format suggestion type for display
  String _formatSuggestionType(String type) {
    switch (type.toLowerCase()) {
      case 'specialization_sub_category':
        return 'Sub Category';
      case 'specialization_sub_sub_category':
        return 'Sub Subcategory';
      default:
        return type.replaceAll('_', ' ').split(' ').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
    }
  }

  void _loadMore() {
    if (_currentPage < _totalPages && !_isLoading) {
      setState(() => _currentPage++);
      _performSearch(resetPage: false);
    }
  }

  Widget _buildMemberCard(SearchOccupationData member) {
    final themeColor =
    ColorHelperClass.getColorFromHex(ColorResources.red_color);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: SizedBox(
                  height: 80,
                  width: 80,
                  child: member.profileImage != null &&
                      member.profileImage!.isNotEmpty
                      ? FadeInImage(
                    placeholder: const AssetImage("assets/images/user3.png"),
                    image: NetworkImage(
                      Urls.imagePathUrl + member.profileImage!,
                    ),
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset("assets/images/user3.png", fit: BoxFit.cover);
                    },
                  )
                      : Image.asset(
                          "assets/images/user3.png",
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Name
            Text(
              member.fullName ?? "No Name",
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 6),

            // Profession
            if ((member.professionNameValue ?? "").isNotEmpty)
              Text(
                member.professionNameValue!,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),

            // Specialization pill
            if ((member.specializationNameValue ?? "").isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200, width: 1),
                  ),
                  child: Text(
                    member.specializationNameValue!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // Connect Button
            ElevatedButton(
              onPressed: () => _showConnectDialog(member),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Connect",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),

            // const SizedBox(height: 8),

            // 🔥 NEW — View Detail Button
            // SizedBox(
            //   width: double.infinity,
            //   height: 36,
            //   child: OutlinedButton(
            //     onPressed: () async {
            //       showDialog(
            //         context: context,
            //         barrierDismissible: false,
            //         builder: (_) => const Center(child: CircularProgressIndicator()),
            //       );
            //
            //       final business = await _fetchBusinessProfile(member.memberId.toString());
            //
            //       Navigator.pop(context);
            //
            //       _showMemberDetailDialog(member, business);
            //     },
            //
            //     style: OutlinedButton.styleFrom(
            //       side: BorderSide(color: themeColor),
            //       foregroundColor: themeColor,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //     child: const Text(
            //       "View Detail",
            //       style: TextStyle(fontSize: 13),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _showConnectDialog(SearchOccupationData member) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
                "Contact Member",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Name", member.fullName ?? "N/A"),
              const SizedBox(height: 12),
              _buildInfoRow("Mobile", member.mobile ?? "N/A"),
              const SizedBox(height: 12),
              _buildInfoRow(
                "Profession",
                "${member.occupationProfessionName ?? ''} - ${member.specializationName ?? ''}"
                    .trim(),
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Cancel"),
            ),

            // SEND MESSAGE BUTTON
            ElevatedButton(
              onPressed: () async {
                // Keep dialog open until API finishes
                try {
                  final CheckUserData2? userData =
                      await SessionManager.getSession();

                  if (userData == null || userData.memberId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("User session expired. Please login again."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final String requestMemberId = userData.memberId.toString();
                  final String memberId = member.memberId.toString();

                  debugPrint(
                      "📤 Sending request: member_id=$memberId, request_member_id=$requestMemberId");

                  final response = await _sendRepo.sendBusinessProfile(
                    memberId: memberId,
                    requestMemberId: requestMemberId,
                  );

                  // Close dialog AFTER API response
                  Navigator.pop(dialogContext);

                  // Show snackbar on main screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        response.message ?? "Message sent successfully",
                      ),
                      backgroundColor:
                          response.status == true ? Colors.green : Colors.red,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Something went wrong"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Send Message"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.black87,
            ),
          )
        ],
      ),
    );
  }

  void _showMemberDetailDialog(
      SearchOccupationData member,
      BusinessOccupationProfileData? business,
      ) {
    final themeColor =
    ColorHelperClass.getColorFromHex(ColorResources.red_color);

    BusinessAddressData? address =
    (business?.addresses != null && business!.addresses!.isNotEmpty)
        ? business.addresses!.first
        : null;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person_outline, size: 22),
                          SizedBox(width: 8),
                          Text(
                            "Member Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 26),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundImage: (member.profileImage != null &&
                                  member.profileImage!.isNotEmpty)
                                  ? NetworkImage(
                                  Urls.imagePathUrl + member.profileImage!)
                                  : const AssetImage("assets/images/user3.png")
                              as ImageProvider,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              member.fullName ?? "No Name",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member.memberCode ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                color: themeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 12),
                            Divider(color: Colors.grey[400]),
                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.phone, size: 18),
                                const SizedBox(width: 6),
                                Text(member.mobile ?? "N/A"),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.email_outlined, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    member.email ?? "N/A",
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              business?.businessName ??
                                  "Business Name Not Available",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),

                            const Text(
                              "Business Address",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),

                            Text(
                              _formatAddress(address),
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 12),
                            Divider(color: Colors.grey[400]),
                            const SizedBox(height: 12),

                            const Text(
                              "Contact Detail",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text("Mobile: ${business?.businessMobile ?? 'N/A'}"),
                            const SizedBox(height: 4),
                            Text("Landline: ${business?.businessLandline ?? 'N/A'}"),
                            const SizedBox(height: 4),
                            Text("Email: ${business?.businessEmail ?? 'N/A'}"),
                            const SizedBox(height: 4),
                            Text("Website: ${business?.businessWebsite ?? 'N/A'}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatAddress(BusinessAddressData? addr) {
    if (addr == null) return "N/A";

    return "${addr.flatNo ?? ''}, ${addr.address ?? ''}, ${addr.areaName ?? ''}\n"
        "${addr.cityName ?? ''}, ${addr.stateName ?? ''}, ${addr.countryName ?? ''}\n"
        "Pincode: ${addr.pincode ?? ''}";
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            _hasSearched ? "No results found" : "Search for Connect",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _hasSearched
                ? "Try different search terms or filters"
                : "Enter occupation(doctors, lawyers, consultants) to find members",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor =
        ColorHelperClass.getColorFromHex(ColorResources.red_color);

    return GestureDetector(
      onTap: () {
        // Close suggestions when tapping outside
        if (_showSuggestions) {
          setState(() {
            _showSuggestions = false;
            _searchFocusNode.unfocus();
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor:
          ColorHelperClass.getColorFromHex(ColorResources.logo_color),
          title: const Text(
            "Networking",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            // Warning banner for missing occupation or business profile
            Obx(() {
              final occ = controller.currentOccupation.value;
              final allOccupations = controller.allOccupations;
              
              // Check if banner should be shown
              // Show if: no occupation data OR (occupation exists with ID 1/2/3 but no business profile)
              final hasNoOccupation = allOccupations.isEmpty || occ == null;
              final hasOccupationButNoBusiness = occ != null &&
                  (occ.occupationId == "1" || occ.occupationId == "2" || occ.occupationId == "3") &&
                  occ.memberBusinessOccupationProfile == null;
              
              final shouldShowBanner = hasNoOccupation || hasOccupationButNoBusiness;
              
              // Determine navigation target
              final shouldGoToOccupationEntry = hasNoOccupation;
              final shouldGoToBusinessProfile = hasOccupationButNoBusiness;

              if (shouldShowBanner) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      if (hasNoOccupation) {
                        // Navigate to occupation entry screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BusinessInformationPage(),
                          ),
                        );
                      } else if (hasOccupationButNoBusiness) {
                        // Navigate to detailed business profile screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OccupationDetailViewPage(
                              memberId: occ.memberId.toString(),
                              memberOccupationId: occ.memberOccupationId.toString(),
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.shade900.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Click here to update your Occupation and Detailed Business Profile',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
            
            // Search bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (value) {
                          // Only load suggestions when typing (min 2 chars)
                          // DO NOT trigger search API while typing
                          if (value.length >= 2) {
                            _loadSuggestions(value);
                          } else {
                            setState(() {
                              _showSuggestions = false;
                              _suggestions = [];
                              _results = [];
                              _hasSearched = false;
                            });
                          }
                          // Remove auto-search - only search on suggestion click
                        },
                        onSubmitted: (value) {
                          setState(() {
                            _showSuggestions = false;
                          });
                        },
                        onTap: () {
                          if (_searchController.text.length >= 2) {
                            _loadSuggestions(_searchController.text);
                          }
                        },
                        decoration: InputDecoration(
                          hintText:
                              "Search occupation(doctors, lawyers, consultants)…",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.grey),
                                  onPressed: () {
                                    _clearSearch();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Filter button
                  IgnorePointer(
                    ignoring: !_hasSearched || !_hasFiltersAvailable(), // Disable when no search or no filters available
                    child: Opacity(
                      opacity: (_hasSearched && _hasFiltersAvailable()) ? 1 : 0.4, // Dim when disabled
                      child: GestureDetector(
                        onTap: (_hasSearched && _hasFiltersAvailable()) ? _openFilterSheet : null,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                _filters.hasFilters ? themeColor : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _filters.hasFilters
                                  ? themeColor
                                  : Colors.grey[300]!,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.filter_alt,
                            color:
                                _filters.hasFilters ? Colors.white : themeColor,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Suggestions dropdown - Show below search box
            if (_showSuggestions && _suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return InkWell(
                      onTap: () {
                        debugPrint(
                            "Suggestion clicked: ${suggestion.displayText ?? suggestion.name}");
                        _onSuggestionTap(suggestion);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: index < _suggestions.length - 1 ? 1 : 0,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getSuggestionIcon(suggestion.type ?? ''),
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _cleanSuggestionText(
                                        suggestion.displayText ??
                                            suggestion.name ??
                                            ''),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatSuggestionType(
                                        suggestion.type ?? ''),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Results header
            if (_hasSearched && !_isLoading)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _filters.hasFilters && _allResults.isNotEmpty
                          ? "${_results.length} ${_results.length == 1 ? 'result' : 'results'} found (Filtered from ${_allResults.length} total ${_allResults.length == 1 ? 'result' : 'results'})"
                          : "${_results.length} ${_results.length == 1 ? 'result' : 'results'} found",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_filters.hasFilters)
                      GestureDetector(
                        onTap: _clearFilters,
                        child: Row(
                          children: [
                            const Icon(Icons.filter_alt_off,
                                size: 16, color: Colors.red),
                            const SizedBox(width: 4),
                            Text(
                              "Clear filters",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.red[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

            // Loading indicator
            if (_isLoading && _results.isEmpty)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            // Results list
            if (_results.isNotEmpty)
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollEndNotification &&
                        scrollNotification.metrics.extentAfter == 0 &&
                        !_isLoading &&
                        _currentPage < _totalPages) {
                      _loadMore();
                    }
                    return false;
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.61,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _results.length + (_isLoading ? 1 : 0),
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      if (index < _results.length) {
                        return _buildMemberCard(_results[index]);
                      } else {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),

            // Empty state
            if (_results.isEmpty && !_isLoading && _hasSearched)
              Expanded(child: _buildEmptyState()),

            if (!_hasSearched && !_isLoading)
              Expanded(child: _buildEmptyState()),
          ],
        ),
      ),
    );
  }

  String _cleanSuggestionText(String text) {
    // Remove everything after first " ("
    if (text.contains("(")) {
      return text.split("(").first.trim();
    }
    return text.trim();
  }
}
