import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/Networking/network_filters.dart';


class FilterBottomSheet extends StatefulWidget {
  final NetworkFilters initialFilters;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  /// ----------------- DATA LISTS (LEVELS) -----------------
  ///
  /// In real app, these will come from your APIs:
  ///   userOccupationDataApi(),
  ///   userOccutionPreCodeApi(),
  ///   userOccutionSpectionCodeApi(),
  ///   userOccutionSpectionSubCategoryApi(),
  ///   userOccutionSpecializationSubSubCategoryApi()
  ///
  /// For now, these are simple maps: { "id": int, "name": String, "parentId": int? }

  List<Map<String, dynamic>> _occupations = [];       // Level 1
  List<Map<String, dynamic>> _professions = [];       // Level 2
  List<Map<String, dynamic>> _specializations = [];   // Level 3
  List<Map<String, dynamic>> _subCategories = [];     // Level 4
  List<Map<String, dynamic>> _subSubCategories = [];  // Level 5 (optional use)

  /// ----------------- SELECTED VALUES -----------------
  int? _selectedOccupationId;
  int? _selectedProfessionId;
  final Set<int> _selectedSpecializationIds = {}; // multi
  final Set<int> _selectedSubCategoryIds = {};    // multi
  int? _selectedSubSubCategoryId;                 // single

  /// ----------------- EXPANSION STATES -----------------
  bool _occupationExpanded = true;
  bool _professionExpanded = true;
  bool _specializationExpanded = true;
  bool _subCategoryExpanded = true;
  bool _subSubCategoryExpanded = true;

  @override
  void initState() {
    super.initState();

    // Initialize from initialFilters
    _selectedOccupationId = widget.initialFilters.occupationId;
    _selectedProfessionId = widget.initialFilters.professionId;
    _selectedSpecializationIds.addAll(widget.initialFilters.specializationIds);
    _selectedSubCategoryIds.addAll(widget.initialFilters.subCategoryIds);

    _initData();
  }

  Future<void> _initData() async {
    /// TODO: Replace this with real API calls:
    ///
    /// Example:
    ///
    /// final occModel = await yourRepo.userOccupationDataApi();
    /// _occupations = occModel.data?.map((o) => {
    ///   "id": int.parse(o.id ?? "0"),
    ///   "name": o.occupation ?? "",
    /// }).toList() ?? [];
    ///
    /// For now, using static dummy data so UI works immediately.

    // Level 1: Occupations
    _occupations = [
      {"id": 1, "name": "Doctor"},
      {"id": 2, "name": "Engineer"},
      {"id": 3, "name": "Business"},
    ];

    // Level 2: Professions (linked by occupation_id)
    _professions = [
      {"id": 11, "occupationId": 1, "name": "Physician"},
      {"id": 12, "occupationId": 1, "name": "Surgeon"},
      {"id": 21, "occupationId": 2, "name": "Software Engineer"},
      {"id": 22, "occupationId": 2, "name": "Civil Engineer"},
      {"id": 31, "occupationId": 3, "name": "Trader"},
      {"id": 32, "occupationId": 3, "name": "Manufacturer"},
    ];

    // Level 3: Specialization (linked by professionId)
    _specializations = [
      {"id": 101, "professionId": 11, "name": "General Physician"},
      {"id": 102, "professionId": 11, "name": "Diabetologist"},
      {"id": 111, "professionId": 12, "name": "Neuro Surgeon"},
      {"id": 112, "professionId": 12, "name": "Cardio Surgeon"},
      {"id": 201, "professionId": 21, "name": "Frontend"},
      {"id": 202, "professionId": 21, "name": "Backend"},
      {"id": 211, "professionId": 22, "name": "Structural"},
      {"id": 212, "professionId": 22, "name": "Site Engineer"},
      {"id": 301, "professionId": 31, "name": "Retail Trader"},
      {"id": 302, "professionId": 31, "name": "Stock Market"},
      {"id": 311, "professionId": 32, "name": "Textile"},
      {"id": 312, "professionId": 32, "name": "Food Products"},
    ];

    // Level 4: Sub-Category (linked by specializationId)
    _subCategories = [
      {"id": 1001, "specializationId": 101, "name": "Family Doctor"},
      {"id": 1002, "specializationId": 102, "name": "Endocrine"},
      {"id": 1101, "specializationId": 111, "name": "Brain"},
      {"id": 1102, "specializationId": 112, "name": "Heart"},
      {"id": 2001, "specializationId": 201, "name": "Web UI"},
      {"id": 2002, "specializationId": 202, "name": "API"},
      {"id": 2101, "specializationId": 211, "name": "Bridge Design"},
      {"id": 2102, "specializationId": 212, "name": "Execution"},
      {"id": 3001, "specializationId": 301, "name": "Kirana"},
      {"id": 3002, "specializationId": 302, "name": "Intraday"},
      {"id": 3101, "specializationId": 311, "name": "Garments"},
      {"id": 3102, "specializationId": 312, "name": "Snacks"},
    ];

    // Level 5: Sub-Sub-Category (optional single-select)
    _subSubCategories = [
      {"id": 9001, "subCategoryId": 1001, "name": "Home Visit"},
      {"id": 9002, "subCategoryId": 1001, "name": "Clinic Only"},
      {"id": 9101, "subCategoryId": 2001, "name": "React Dev"},
      {"id": 9102, "subCategoryId": 2002, "name": "NodeJS Dev"},
    ];

    // If there is already some selection, ensure dependencies are consistent
    if (_selectedOccupationId != null) {
      // professions filtered automatically in UI builder
    }
    if (_selectedProfessionId != null) {
      // specializations filtered automatically
    }

    setState(() {});
  }

  /// ----------------- RESET & APPLY -----------------

  void _resetFilters() {
    setState(() {
      _selectedOccupationId = null;
      _selectedProfessionId = null;
      _selectedSpecializationIds.clear();
      _selectedSubCategoryIds.clear();
      _selectedSubSubCategoryId = null;
    });
  }

  void _applyFilters() {
    final result = NetworkFilters(
      occupationId: _selectedOccupationId,
      professionId: _selectedProfessionId,
      specializationIds: _selectedSpecializationIds.toList(),
      subCategoryIds: _selectedSubCategoryIds.toList(),
    );

    Navigator.of(context).pop<NetworkFilters>(result);
  }

  /// ----------------- HELPERS -----------------

  List<Map<String, dynamic>> _filteredProfessions() {
    if (_selectedOccupationId == null) return [];
    return _professions
        .where((p) => p["occupationId"] == _selectedOccupationId)
        .toList();
  }

  List<Map<String, dynamic>> _filteredSpecializations() {
    if (_selectedProfessionId == null) return [];
    return _specializations
        .where((s) => s["professionId"] == _selectedProfessionId)
        .toList();
  }

  List<Map<String, dynamic>> _filteredSubCategories() {
    if (_selectedSpecializationIds.isEmpty) return [];
    return _subCategories
        .where((sc) => _selectedSpecializationIds.contains(sc["specializationId"]))
        .toList();
  }

  List<Map<String, dynamic>> _filteredSubSubCategories() {
    if (_selectedSubCategoryIds.isEmpty) return [];
    return _subSubCategories
        .where((ssc) => _selectedSubCategoryIds.contains(ssc["subCategoryId"]))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor =
    ColorHelperClass.getColorFromHex(ColorResources.red_color);

    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: 1.0,
      minChildSize: 0.7,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),

              // Header
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Filters",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text(
                        "Reset",
                        style: TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  children: [
                    // ----------------- LEVEL 1: OCCUPATION -----------------
                    _buildSectionCard(
                      title: "Occupation",
                      isExpanded: _occupationExpanded,
                      onToggle: () {
                        setState(() {
                          _occupationExpanded = !_occupationExpanded;
                        });
                      },
                      child: _occupations.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "No occupations available",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      )
                          : Column(
                        children: _occupations.map((o) {
                          final int id = o["id"] as int;
                          final String name = o["name"].toString();
                          return RadioListTile<int>(
                            dense: true,
                            value: id,
                            groupValue: _selectedOccupationId,
                            onChanged: (val) {
                              setState(() {
                                _selectedOccupationId = val;
                                // Clear dependent selections
                                _selectedProfessionId = null;
                                _selectedSpecializationIds.clear();
                                _selectedSubCategoryIds.clear();
                                _selectedSubSubCategoryId = null;
                              });
                            },
                            title: Text(
                              name,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ----------------- LEVEL 2: PROFESSION -----------------
                    _buildSectionCard(
                      title: "Profession",
                      isExpanded: _professionExpanded,
                      onToggle: () {
                        setState(() {
                          _professionExpanded = !_professionExpanded;
                        });
                      },
                      child: _selectedOccupationId == null
                          ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Select an occupation first",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      )
                          : _buildProfessionList(),
                    ),

                    const SizedBox(height: 8),

                    // ----------------- LEVEL 3: SPECIALIZATION (MULTI) -----------------
                    _buildSectionCard(
                      title: "Specialization",
                      isExpanded: _specializationExpanded,
                      onToggle: () {
                        setState(() {
                          _specializationExpanded = !_specializationExpanded;
                        });
                      },
                      child: _selectedProfessionId == null
                          ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Select a profession first",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      )
                          : _buildSpecializationChips(),
                    ),

                    const SizedBox(height: 8),

                    // ----------------- LEVEL 4: SUB CATEGORY (MULTI) -----------------
                    _buildSectionCard(
                      title: "Sub Category",
                      isExpanded: _subCategoryExpanded,
                      onToggle: () {
                        setState(() {
                          _subCategoryExpanded = !_subCategoryExpanded;
                        });
                      },
                      child: _selectedSpecializationIds.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Select at least one specialization first",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      )
                          : _buildSubCategoryChips(),
                    ),

                    const SizedBox(height: 8),

                    _buildSectionCard(
                      title: "Sub-Sub-Category (optional)",
                      isExpanded: _subSubCategoryExpanded,
                      onToggle: () {
                        setState(() {
                          _subSubCategoryExpanded = !_subSubCategoryExpanded;
                        });
                      },
                      child: _selectedSubCategoryIds.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Select at least one sub category first",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      )
                          : _buildSubSubCategoryList(),
                    ),
                  ],
                ),
              ),

              // Sticky Apply Button
              SafeArea(
                top: false,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Apply Filters",
                        style: TextStyle(fontSize: 16, color: Colors.white),
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

  // ------------- UI BUILDERS FOR EACH SECTION -----------------

  Widget _buildSectionCard({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            dense: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            title: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
            onTap: onToggle,
          ),
          if (isExpanded)
            const Divider(height: 1),
          if (isExpanded) child,
        ],
      ),
    );
  }

  Widget _buildProfessionList() {
    final items = _filteredProfessions();
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "No professions available",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      );
    }
    return Column(
      children: items.map((p) {
        final int id = p["id"] as int;
        final String name = p["name"].toString();
        return RadioListTile<int>(
          dense: true,
          value: id,
          groupValue: _selectedProfessionId,
          onChanged: (val) {
            setState(() {
              _selectedProfessionId = val;
              _selectedSpecializationIds.clear();
              _selectedSubCategoryIds.clear();
              _selectedSubSubCategoryId = null;
            });
          },
          title: Text(
            name,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpecializationChips() {
    final items = _filteredSpecializations();
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "No specializations available",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: items.map((s) {
          final int id = s["id"] as int;
          final String name = s["name"].toString();
          final bool selected = _selectedSpecializationIds.contains(id);
          return FilterChip(
            label: Text(name),
            selected: selected,
            onSelected: (bool value) {
              setState(() {
                if (value) {
                  _selectedSpecializationIds.add(id);
                } else {
                  _selectedSpecializationIds.remove(id);
                  // Also clear dependent sub-categories and sub-sub-categories that belong only to this specialization
                  _selectedSubCategoryIds.removeWhere((scId) {
                    final sc = _subCategories
                        .firstWhere((e) => e["id"] == scId, orElse: () => {});
                    return sc["specializationId"] == id;
                  });
                  _selectedSubSubCategoryId = null;
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubCategoryChips() {
    final items = _filteredSubCategories();
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "No sub categories available",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: items.map((sc) {
          final int id = sc["id"] as int;
          final String name = sc["name"].toString();
          final bool selected = _selectedSubCategoryIds.contains(id);
          return FilterChip(
            label: Text(name),
            selected: selected,
            onSelected: (bool value) {
              setState(() {
                if (value) {
                  _selectedSubCategoryIds.add(id);
                } else {
                  _selectedSubCategoryIds.remove(id);
                  if (_selectedSubSubCategoryId != null) {
                    final subSub = _subSubCategories.firstWhere(
                          (e) => e["id"] == _selectedSubSubCategoryId,
                      orElse: () => {},
                    );
                    if (subSub["subCategoryId"] == id) {
                      _selectedSubSubCategoryId = null;
                    }
                  }
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubSubCategoryList() {
    final items = _filteredSubSubCategories();
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "No sub-sub-categories available",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      children: items.map((ssc) {
        final int id = ssc["id"] as int;
        final String name = ssc["name"].toString();
        return RadioListTile<int>(
          dense: true,
          value: id,
          groupValue: _selectedSubSubCategoryId,
          onChanged: (val) {
            setState(() {
              _selectedSubSubCategoryId = val;
            });
          },
          title: Text(
            name,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }
}
