// lib/view/Networking/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/Networking/network_filters.dart';

class FilterBottomSheet extends StatefulWidget {
  final NetworkFilters initialFilters;
  final String? searchQuery;
  final Map<String, dynamic>? availableFilters;
  final String? matchedLevel;
  final String? matchedValue;
  final Function(NetworkFilters)? onFilterChanged; // Callback for immediate filter application

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    this.searchQuery,
    this.availableFilters,
    this.matchedLevel,
    this.matchedValue,
    this.onFilterChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late NetworkFilters _currentFilters;

  // Track which levels were matched in search
  String? _matchedLevel;
  String? _matchedValue;

  // Available filter options
  List<String> _availableOccupations = [];
  List<String> _availableProfessions = [];
  List<String> _availableSpecializations = [];
  List<String> _availableSubcategories = [];
  List<String> _availableSubSubcategories = [];
  List<String> _availableProductCategories = [];
  List<String> _availableProductSubcategories = [];
  List<String> _availableZones = [];

  // Expansion states
  bool _occupationExpanded = true;
  bool _professionExpanded = true;
  bool _specializationExpanded = true;
  bool _subCategoryExpanded = true;
  bool _productCategoryExpanded = true;
  bool _productSubcategoryExpanded = true;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
    _matchedLevel = widget.matchedLevel;
    _matchedValue = widget.matchedValue;
    _loadFilterOptions();
  }

  // Helper function to ensure filter items are strings
  // Exclude 'Other' as per requirement
  List<String> _ensureStringList(List<dynamic>? list) {
    if (list == null) return [];
    return list.map((item) {
      if (item == null) return null;
      if (item is String) {
        if (item.isEmpty || item.toLowerCase() == 'other') return null;
        return item;
      }
      if (item is Map) {
        // If it's an object, try to extract the name field (prioritize 'name' field)
        final value = item['name']?.toString() ?? 
               item['occupation_name']?.toString() ?? 
               item['profession_name']?.toString() ??
               item['specialization_name']?.toString() ??
               item['specialization_sub_category_name']?.toString() ??
               item['specialization_sub_sub_category_name']?.toString() ??
               item['occupation']?.toString() ?? 
               item.toString();
        if (value.isEmpty || value.toLowerCase() == 'other') return null;
        return value;
      }
      final str = item.toString();
      if (str.isEmpty || str == 'null' || str.toLowerCase() == 'other') return null;
      return str;
    }).where((s) => s != null && s!.isNotEmpty && s != 'null').cast<String>().toList();
  }

  Future<void> _loadFilterOptions() async {
    // If availableFilters provided, use them
    if (widget.availableFilters != null) {
      debugPrint("Loading filter options:");
      debugPrint("Zones: ${widget.availableFilters!['zones']?.length ?? 0}");
      debugPrint("Occupations: ${widget.availableFilters!['occupations']?.length ?? 0}");
      debugPrint("Professions: ${widget.availableFilters!['professions']?.length ?? 0}");
      debugPrint("Specializations: ${widget.availableFilters!['specializations']?.length ?? 0}");
      debugPrint("Subcategories: ${widget.availableFilters!['subcategories']?.length ?? 0}");
      debugPrint("Sub-subcategories: ${widget.availableFilters!['sub_subcategories']?.length ?? 0}");
      
      setState(() {
        // Handle zones - extract name from zone objects
        final zonesData = widget.availableFilters!['zones'] as List<dynamic>?;
        if (zonesData != null && zonesData.isNotEmpty) {
          _availableZones = zonesData.map((zone) {
            if (zone is Map) {
              return zone['name']?.toString() ?? '';
            }
            return zone.toString();
          }).where((name) => name.isNotEmpty).toList();
        }
        
        // Ensure all filter items are strings, not objects
        _availableOccupations = _ensureStringList(widget.availableFilters!['occupations'] as List<dynamic>?);
        _availableProfessions = _ensureStringList(widget.availableFilters!['professions'] as List<dynamic>?);
        _availableSpecializations = _ensureStringList(widget.availableFilters!['specializations'] as List<dynamic>?);
        _availableSubcategories = _ensureStringList(widget.availableFilters!['subcategories'] as List<dynamic>?);
        _availableSubSubcategories = _ensureStringList(widget.availableFilters!['sub_subcategories'] as List<dynamic>?);
        _availableProductCategories = _ensureStringList(widget.availableFilters!['product_categories'] as List<dynamic>?);
        _availableProductSubcategories = _ensureStringList(widget.availableFilters!['product_subcategories'] as List<dynamic>?);
        
        // Remove duplicates and ensure 'Other' is at the end
        _availableOccupations = _formatFilterList(_availableOccupations);
        _availableProfessions = _formatFilterList(_availableProfessions);
        _availableSpecializations = _formatFilterList(_availableSpecializations);
        _availableSubcategories = _formatFilterList(_availableSubcategories);
        _availableSubSubcategories = _formatFilterList(_availableSubSubcategories);
      });

      // Clean matched value if it's an object
      if (_matchedValue != null && _matchedValue!.startsWith('{')) {
        // Try to extract the name from object string
        final match = RegExp(r'occupation_name:\s*([^,}]+)').firstMatch(_matchedValue!);
        if (match != null) {
          _matchedValue = match.group(1)?.trim();
        }
      }

      // Use matched level/value from API if provided, otherwise determine from search query
      if (_matchedLevel == null || _matchedValue == null) {
        _determineMatchedLevel();
      }
    } else {
      debugPrint("No availableFilters provided to FilterBottomSheet");
    }
  }

  // Format filter list - remove duplicates, exclude 'Other'
  List<String> _formatFilterList(List<String> list) {
    return list
        .where((item) => item.toLowerCase() != 'other')
        .toSet()
        .toList();
  }

  // Get clean matched value (extract name from object if needed)
  String _getCleanMatchedValue() {
    if (_matchedValue == null) return '';
    
    // If it's already a clean string, return it
    if (!_matchedValue!.startsWith('{')) {
      return _matchedValue!;
    }
    
    // Try to extract name from object string
    final match = RegExp(r'occupation_name:\s*([^,}]+)').firstMatch(_matchedValue!);
    if (match != null) {
      return match.group(1)?.trim() ?? _matchedValue!;
    }
    
    // Try profession_name
    final profMatch = RegExp(r'profession_name:\s*([^,}]+)').firstMatch(_matchedValue!);
    if (profMatch != null) {
      return profMatch.group(1)?.trim() ?? _matchedValue!;
    }
    
    return _matchedValue!;
  }

  void _determineMatchedLevel() {
    final searchQuery = widget.searchQuery?.toLowerCase().trim();
    if (searchQuery == null || searchQuery.isEmpty) return;

    // Check which level the search query matches
    // Similar to PHP logic - check exact match first, then partial
    String? matchedOcc;
    String? matchedProf;
    String? matchedSpec;
    String? matchedSubcat;

    // Check exact matches first
    for (var occ in _availableOccupations) {
      if (occ.toLowerCase().trim() == searchQuery) {
        matchedOcc = occ;
        break;
      }
    }

    if (matchedOcc == null) {
      // Check partial matches for occupation
      for (var occ in _availableOccupations) {
        final occLower = occ.toLowerCase().trim();
        if (occLower.contains(searchQuery) || searchQuery.contains(occLower)) {
          matchedOcc = occ;
          break;
        }
      }
    }

    if (matchedOcc != null) {
      _matchedLevel = 'occupation';
      _matchedValue = matchedOcc;
      return;
    }

    // Check profession
    for (var prof in _availableProfessions) {
      if (prof.toLowerCase().trim() == searchQuery) {
        matchedProf = prof;
        break;
      }
    }

    if (matchedProf == null) {
      for (var prof in _availableProfessions) {
        final profLower = prof.toLowerCase().trim();
        if (profLower.contains(searchQuery)) {
          matchedProf = prof;
          break;
        }
      }
    }

    if (matchedProf != null) {
      _matchedLevel = 'profession';
      _matchedValue = matchedProf;
      return;
    }

    // Check specialization
    for (var spec in _availableSpecializations) {
      if (spec.toLowerCase().trim() == searchQuery) {
        matchedSpec = spec;
        break;
      }
    }

    if (matchedSpec == null) {
      for (var spec in _availableSpecializations) {
        final specLower = spec.toLowerCase().trim();
        if (specLower.contains(searchQuery)) {
          matchedSpec = spec;
          break;
        }
      }
    }

    if (matchedSpec != null) {
      _matchedLevel = 'specialization';
      _matchedValue = matchedSpec;
      return;
    }

    // Check subcategory
    for (var subcat in _availableSubcategories) {
      if (subcat.toLowerCase().trim() == searchQuery) {
        matchedSubcat = subcat;
        break;
      }
    }

    if (matchedSubcat == null) {
      for (var subcat in _availableSubcategories) {
        final subcatLower = subcat.toLowerCase().trim();
        if (subcatLower.contains(searchQuery)) {
          matchedSubcat = subcat;
          break;
        }
      }
    }

    if (matchedSubcat != null) {
      _matchedLevel = 'subcategory';
      _matchedValue = matchedSubcat;
    }
  }

  void _resetFilters() {
    setState(() {
      _currentFilters = NetworkFilters.empty();
    });
    // Apply immediately when clearing
    widget.onFilterChanged?.call(_currentFilters);
    Navigator.of(context).pop<NetworkFilters>(_currentFilters);
  }

  void _applyFilters() {
    // Notify parent about final filter state before closing
    widget.onFilterChanged?.call(_currentFilters);
    Navigator.of(context).pop<NetworkFilters>(_currentFilters);
  }

  void _notifyFilterChange() {
    // Notify parent about filter change without closing the sheet
    widget.onFilterChanged?.call(_currentFilters);
  }

  void _toggleOccupation(String occupation) {
    setState(() {
      if (_currentFilters.occupations.contains(occupation)) {
        _currentFilters = _currentFilters.copyWith(
          occupations: List.from(_currentFilters.occupations)
            ..remove(occupation),
          // Clear child filters when parent is removed
          professions: [],
          specializations: [],
          subcategories: [],
          subSubcategories: [],
        );
      } else {
        _currentFilters = _currentFilters.copyWith(
          occupations: List.from(_currentFilters.occupations)
            ..add(occupation),
        );
      }
    });
    // Apply filter immediately without closing sheet
    _notifyFilterChange();
  }

  void _toggleProfession(String profession) {
    setState(() {
      if (_currentFilters.professions.contains(profession)) {
        _currentFilters = _currentFilters.copyWith(
          professions: List.from(_currentFilters.professions)
            ..remove(profession),
          // Clear child filters
          specializations: [],
          subcategories: [],
          subSubcategories: [],
        );
      } else {
        _currentFilters = _currentFilters.copyWith(
          professions: List.from(_currentFilters.professions)
            ..add(profession),
        );
      }
    });
    // Apply filter immediately without closing sheet
    _notifyFilterChange();
  }

  void _toggleSpecialization(String specialization) {
    setState(() {
      if (_currentFilters.specializations.contains(specialization)) {
        _currentFilters = _currentFilters.copyWith(
          specializations: List.from(_currentFilters.specializations)
            ..remove(specialization),
          subcategories: [],
          subSubcategories: [],
        );
      } else {
        _currentFilters = _currentFilters.copyWith(
          specializations: List.from(_currentFilters.specializations)
            ..add(specialization),
        );
      }
    });
    // Apply filter immediately without closing sheet
    _notifyFilterChange();
  }

  void _toggleSubcategory(String subcategory) {
    setState(() {
      if (_currentFilters.subcategories.contains(subcategory)) {
        _currentFilters = _currentFilters.copyWith(
          subcategories: List.from(_currentFilters.subcategories)
            ..remove(subcategory),
          subSubcategories: [],
        );
      } else {
        _currentFilters = _currentFilters.copyWith(
          subcategories: List.from(_currentFilters.subcategories)
            ..add(subcategory),
        );
      }
    });
    // Apply filter immediately without closing sheet
    _notifyFilterChange();
  }

  void _toggleSubSubcategory(String subSubcategory) {
    setState(() {
      if (_currentFilters.subSubcategories.contains(subSubcategory)) {
        _currentFilters = _currentFilters.copyWith(
          subSubcategories: List.from(_currentFilters.subSubcategories)
            ..remove(subSubcategory),
        );
      } else {
        _currentFilters = _currentFilters.copyWith(
          subSubcategories: List.from(_currentFilters.subSubcategories)
            ..add(subSubcategory),
        );
      }
    });
    // Apply filter immediately without closing sheet
    _notifyFilterChange();
  }

  void _toggleZone(String zone) {
    setState(() {
      if (_currentFilters.zones.contains(zone)) {
        _currentFilters = _currentFilters.copyWith(
          zones: List.from(_currentFilters.zones)
            ..remove(zone),
        );
      } else {
        _currentFilters = _currentFilters.copyWith(
          zones: List.from(_currentFilters.zones)
            ..add(zone),
        );
      }
    });
    // Apply filter immediately without closing sheet
    _notifyFilterChange();
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> items,
    required List<String> selectedItems,
    required Function(String) onToggle,
    bool isMultiSelect = true,
    bool showAll = true,
  }) {
    final filteredItems = showAll
        ? items
        : items.where((item) => item.isNotEmpty).toList();

    // Don't show section if empty or has only one item (as per requirement)
    if (filteredItems.isEmpty || filteredItems.length == 1) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: true,
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: filteredItems.map((item) {
                final isSelected = selectedItems.contains(item);
                return InkWell(
                  onTap: () => onToggle(item),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[200]!,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) => onToggle(item),
                          activeColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);
    final screenHeight = MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Draggable handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Filters",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        if (_currentFilters.hasFilters)
                          TextButton(
                            onPressed: _resetFilters,
                            child: const Text(
                              "Clear All",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Filter sections
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(8),
                  children: [
                    // Show matched level info if applicable
                    if (_matchedLevel != null && _matchedValue != null)
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Search matched $_matchedLevel: ${_getCleanMatchedValue()}",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ZONES FILTER - Show first
                    _buildFilterSection(
                      title: "Zones",
                      items: _availableZones,
                      selectedItems: _currentFilters.zones,
                      onToggle: _toggleZone,
                      showAll: true,
                    ),

                    // OCCUPATION FILTER - Only show if occupation matched or no match
                    if (_matchedLevel == null || _matchedLevel == 'occupation')
                      _buildFilterSection(
                        title: "Level 1",
                        items: _availableOccupations,
                        selectedItems: _currentFilters.occupations,
                        onToggle: _toggleOccupation,
                        showAll: true,
                      ),

                    // PROFESSION FILTER - Hide if profession matched (show only child levels)
                    if (_matchedLevel == null || _matchedLevel == 'occupation' || _matchedLevel == 'profession')
                      if (_matchedLevel != 'profession')
                        _buildFilterSection(
                          title: "Level 2",
                          items: _availableProfessions,
                          selectedItems: _currentFilters.professions,
                          onToggle: _toggleProfession,
                          showAll: true,
                        ),

                    // SPECIALIZATION FILTER - Always show if available
                    _buildFilterSection(
                      title: "Level 3",
                      items: _availableSpecializations,
                      selectedItems: _currentFilters.specializations,
                      onToggle: _toggleSpecialization,
                      showAll: true,
                    ),

                    // SUB-CATEGORY FILTER - Always show if available
                    _buildFilterSection(
                      title: "Level 4",
                      items: _availableSubcategories,
                      selectedItems: _currentFilters.subcategories,
                      onToggle: _toggleSubcategory,
                      showAll: true,
                    ),

                    // SUB-SUB-CATEGORY FILTER
                    if (_availableSubSubcategories.isNotEmpty)
                      _buildFilterSection(
                        title: "Level 5",
                        items: _availableSubSubcategories,
                        selectedItems: _currentFilters.subSubcategories,
                        onToggle: _toggleSubSubcategory,
                        showAll: true,
                      ),

                    // PRODUCT CATEGORY FILTER (if you have product search)
                    if (_availableProductCategories.isNotEmpty)
                      _buildFilterSection(
                        title: "Product Category",
                        items: _availableProductCategories,
                        selectedItems: _currentFilters.productCategories,
                        onToggle: (category) {
                          setState(() {
                            if (_currentFilters.productCategories.contains(category)) {
                              _currentFilters = _currentFilters.copyWith(
                                productCategories: List.from(_currentFilters.productCategories)
                                  ..remove(category),
                                productSubcategories: [],
                              );
                            } else {
                              _currentFilters = _currentFilters.copyWith(
                                productCategories: List.from(_currentFilters.productCategories)
                                  ..add(category),
                              );
                            }
                          });
                        },
                      ),

                    // PRODUCT SUB-CATEGORY FILTER
                    if (_availableProductSubcategories.isNotEmpty)
                      _buildFilterSection(
                        title: "Product Sub Category",
                        items: _availableProductSubcategories,
                        selectedItems: _currentFilters.productSubcategories,
                        onToggle: (subcategory) {
                          setState(() {
                            if (_currentFilters.productSubcategories.contains(subcategory)) {
                              _currentFilters = _currentFilters.copyWith(
                                productSubcategories: List.from(_currentFilters.productSubcategories)
                                  ..remove(subcategory),
                              );
                            } else {
                              _currentFilters = _currentFilters.copyWith(
                                productSubcategories: List.from(_currentFilters.productSubcategories)
                                  ..add(subcategory),
                              );
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),

              // Apply Button
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Apply Filters",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}