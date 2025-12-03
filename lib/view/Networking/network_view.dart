// lib/view/Networking/network_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mpm/model/SearchOccupation/SearchOccupationData.dart';
import 'package:mpm/model/SearchOccupation/SearchOccupationModelClass.dart';
import 'package:mpm/repository/search_occupation_repository/search_occupation_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/Networking/filter_bottom_sheet.dart';
import 'package:mpm/view/Networking/network_filters.dart';

class NetworkView extends StatefulWidget {
  const NetworkView({super.key});

  @override
  State<NetworkView> createState() => _NetworkViewState();
}

class _NetworkViewState extends State<NetworkView> {
  final TextEditingController _searchController = TextEditingController();
  final SearchOccupationRepository _repo = SearchOccupationRepository();

  // Search state
  Timer? _debounceTimer;
  bool _isLoading = false;
  bool _hasSearched = false;
  List<SearchOccupationData> _results = [];

  // Filters
  NetworkFilters _filters = NetworkFilters.empty();

  // Pagination
  int _currentPage = 1;
  final int _limit = 20;
  int _totalResults = 0;
  int _totalPages = 1;

  // Filter options from API
  Map<String, List<String>> _availableFilters = {
    'occupations': [],
    'professions': [],
    'specializations': [],
    'subcategories': [],
    'product_categories': [],
    'product_subcategories': [],
  };

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

// In your NetworkView class
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
          _results = response.data ?? [];
        } else {
          // For pagination, append new results
          _results.addAll(response.data ?? []);
        }

        _totalResults = response.totalResults ?? 0;
        _totalPages = (_totalResults / _limit).ceil();

        // Debug information
        debugPrint("Updated results count: ${_results.length}");
        debugPrint("Total pages: $_totalPages");
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
          initialFilters: _filters,
          searchQuery: _searchController.text.trim(),
          availableFilters: _availableFilters,
        );
      },
    );

    if (newFilters != null) {
      setState(() => _filters = newFilters);
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch(resetPage: true);
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _filters = NetworkFilters.empty();
    });
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(resetPage: true);
    }
  }

  void _loadMore() {
    if (_currentPage < _totalPages && !_isLoading) {
      setState(() => _currentPage++);
      _performSearch(resetPage: false);
    }
  }

  Widget _buildMemberCard(SearchOccupationData member) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);
    final occ = member.occupation;

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
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Profile image
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: SizedBox(
                height: 100,
                width: 100,
                child: member.profileImage != null &&
                    member.profileImage!.isNotEmpty
                    ? FadeInImage(
                  placeholder:
                  const AssetImage("assets/images/user3.png"),
                  image: NetworkImage(
                    Urls.imagePathUrl + member.profileImage!,
                  ),
                  fit: BoxFit.cover,
                )
                    : Image.asset("assets/images/user3.png"),
              ),
            ),

            const SizedBox(height: 12),

            // Name
            Text(
              member.fullName ?? "No Name",
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            // Profession
            Text(
              occ?.professionName ?? "",
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),

            // Specialization
            if ((occ?.specializationName ?? "").isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  occ!.specializationName!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Connect Button
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: () => _showConnectDialog(member),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Connect",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showConnectDialog(SearchOccupationData member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Connect with Member"),
        content: Text(
            "Send connection request to ${member.fullName ?? 'this member'}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement connection request logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text("Connection request sent to ${member.fullName}"),
                ),
              );
            },
            child: const Text("Send Request"),
          ),
        ],
      ),
    );
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
            _hasSearched ? "No results found" : "Search for members",
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
                : "Enter a name, profession, or specialization to find members",
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

    return Scaffold(
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
                      onChanged: (value) {
                        _debounceTimer?.cancel();
                        _debounceTimer =
                            Timer(const Duration(milliseconds: 500), () {
                          _performSearch(resetPage: true);
                        });
                      },
                      onSubmitted: (value) => _performSearch(resetPage: true),
                      decoration: const InputDecoration(
                        hintText:
                            "Search members, profession, specialization...",
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Filter button
                GestureDetector(
                  onTap: _openFilterSheet,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _filters.hasFilters ? themeColor : Colors.white,
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
                      color: _filters.hasFilters ? Colors.white : themeColor,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results header
          if (_hasSearched && !_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$_totalResults ${_totalResults == 1 ? 'result' : 'results'} found",
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
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

          if (!_hasSearched && !_isLoading) Expanded(child: _buildEmptyState()),
        ],
      ),
    );
  }
}
