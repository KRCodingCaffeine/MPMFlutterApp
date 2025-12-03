// lib/view/Networking/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/Networking/network_filters.dart';

class FilterBottomSheet extends StatefulWidget {
  final NetworkFilters initialFilters;
  final String? searchQuery;
  final Map<String, List<String>>? availableFilters;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    this.searchQuery,
    this.availableFilters,
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
  List<String> _availableProductCategories = [];
  List<String> _availableProductSubcategories = [];

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
    _loadFilterOptions();
  }

  Future<void> _loadFilterOptions() async {
    // If availableFilters provided, use them
    if (widget.availableFilters != null) {
      setState(() {
        _availableOccupations = widget.availableFilters!['occupations'] ?? [];
        _availableProfessions = widget.availableFilters!['professions'] ?? [];
        _availableSpecializations = widget.availableFilters!['specializations'] ?? [];
        _availableSubcategories = widget.availableFilters!['subcategories'] ?? [];
        _availableProductCategories = widget.availableFilters!['product_categories'] ?? [];
        _availableProductSubcategories = widget.availableFilters!['product_subcategories'] ?? [];
      });

      // Determine matched level based on search query
      _determineMatchedLevel();
    }
  }

  void _determineMatchedLevel() {
    final searchQuery = widget.searchQuery?.toLowerCase().trim();
    if (searchQuery == null || searchQuery.isEmpty) return;

    // Check which level the search query matches
    // Similar to PHP logic
    final occupationMatch = _availableOccupations.any(
            (item) => item.toLowerCase() == searchQuery
    );
    final professionMatch = _availableProfessions.any(
            (item) => item.toLowerCase() == searchQuery
    );
    final specializationMatch = _availableSpecializations.any(
            (item) => item.toLowerCase() == searchQuery
    );
    final subcategoryMatch = _availableSubcategories.any(
            (item) => item.toLowerCase() == searchQuery
    );

    if (occupationMatch) {
      _matchedLevel = 'occupation';
      _matchedValue = _availableOccupations.firstWhere(
              (item) => item.toLowerCase() == searchQuery
      );
    } else if (professionMatch) {
      _matchedLevel = 'profession';
      _matchedValue = _availableProfessions.firstWhere(
              (item) => item.toLowerCase() == searchQuery
      );
    } else if (specializationMatch) {
      _matchedLevel = 'specialization';
      _matchedValue = _availableSpecializations.firstWhere(
              (item) => item.toLowerCase() == searchQuery
      );
    } else if (subcategoryMatch) {
      _matchedLevel = 'subcategory';
      _matchedValue = _availableSubcategories.firstWhere(
              (item) => item.toLowerCase() == searchQuery
      );
    }
  }

  void _resetFilters() {
    setState(() {
      _currentFilters = NetworkFilters.empty();
    });
  }

  void _applyFilters() {
    Navigator.of(context).pop<NetworkFilters>(_currentFilters);
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
        );
      } else {
        _currentFilters = _currentFilters.copyWith(
          occupations: List.from(_currentFilters.occupations)
            ..add(occupation),
        );
      }
    });
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
        );
      } else {
        _currentFilters = _currentFilters.copyWith(
          professions: List.from(_currentFilters.professions)
            ..add(profession),
        );
      }
    });
  }

  void _toggleSpecialization(String specialization) {
    setState(() {
      if (_currentFilters.specializations.contains(specialization)) {
        _currentFilters = _currentFilters.copyWith(
          specializations: List.from(_currentFilters.specializations)
            ..remove(specialization),
          subcategories: [],
        );
      } else {
        _currentFilters = _currentFilters.copyWith(
          specializations: List.from(_currentFilters.specializations)
            ..add(specialization),
        );
      }
    });
  }

  void _toggleSubcategory(String subcategory) {
    setState(() {
      if (_currentFilters.subcategories.contains(subcategory)) {
        _currentFilters = _currentFilters.copyWith(
          subcategories: List.from(_currentFilters.subcategories)
            ..remove(subcategory),
        );
      } else {
        _currentFilters = _currentFilters.copyWith(
          subcategories: List.from(_currentFilters.subcategories)
            ..add(subcategory),
        );
      }
    });
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

    if (filteredItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: filteredItems.map((item) {
                final isSelected = selectedItems.contains(item);
                return FilterChip(
                  label: Text(item),
                  selected: isSelected,
                  onSelected: (selected) => onToggle(item),
                  backgroundColor: isSelected ? null : Colors.grey[100],
                  selectedColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 13,
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
                                "Search matched $_matchedLevel: $_matchedValue",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // OCCUPATION FILTER
                    _buildFilterSection(
                      title: "Occupation",
                      items: _availableOccupations,
                      selectedItems: _currentFilters.occupations,
                      onToggle: _toggleOccupation,
                      showAll: _matchedLevel != 'occupation',
                    ),

                    // PROFESSION FILTER
                    _buildFilterSection(
                      title: "Profession",
                      items: _availableProfessions,
                      selectedItems: _currentFilters.professions,
                      onToggle: _toggleProfession,
                      showAll: _matchedLevel != 'profession',
                    ),

                    // SPECIALIZATION FILTER
                    _buildFilterSection(
                      title: "Specialization",
                      items: _availableSpecializations,
                      selectedItems: _currentFilters.specializations,
                      onToggle: _toggleSpecialization,
                      showAll: _matchedLevel != 'specialization',
                    ),

                    // SUB-CATEGORY FILTER
                    _buildFilterSection(
                      title: "Sub Category",
                      items: _availableSubcategories,
                      selectedItems: _currentFilters.subcategories,
                      onToggle: _toggleSubcategory,
                      showAll: _matchedLevel != 'subcategory',
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