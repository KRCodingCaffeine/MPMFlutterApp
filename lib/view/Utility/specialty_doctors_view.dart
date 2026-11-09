import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/Utility/utility_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SpecialtyDoctorsView extends StatefulWidget {
  final String specialty;
  final List<Doctor> doctors;
  final List<String> zones;
  final ValueChanged<List<Doctor>>? onDoctorsFound;

  const SpecialtyDoctorsView({
    super.key,
    required this.specialty,
    required this.doctors,
    required this.zones,
    this.onDoctorsFound,
  });

  @override
  State<SpecialtyDoctorsView> createState() => _SpecialtyDoctorsViewState();
}

class _SpecialtyDoctorsViewState extends State<SpecialtyDoctorsView> {
  final TextEditingController _searchController = TextEditingController();
  String? _zone;
  String? _category;
  String? _clinic;
  _DoctorSort _sort = _DoctorSort.nameAsc;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    final names = <String>{
      ...specialtyCategoriesFor(widget.specialty).map((category) => category.name),
      ...widget.doctors.map((doctor) => doctor.categoryName),
    };
    final list = names.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<String> get _clinics {
    final names = <String>{};
    for (final doctor in widget.doctors) {
      final name = doctor.clinicName.trim();
      if (name.isNotEmpty) names.add(name);
    }
    return names.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  bool _sameZone(String doctorZone, String selectedZone) {
    final doctor = doctorZone.toLowerCase().trim();
    final selected = selectedZone.toLowerCase().trim();
    if (doctor.isEmpty || selected.isEmpty) return false;
    return doctor == selected || doctor.contains(selected) || selected.contains(doctor);
  }

  bool _matchesSearch(Doctor doctor, String query) {
    if (query.isEmpty) return true;
    final digits = doctor.mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final queryDigits = query.replaceAll(RegExp(r'[^0-9]'), '');
    return doctor.name.toLowerCase().contains(query) ||
        (queryDigits.isNotEmpty && digits.contains(queryDigits));
  }

  List<Doctor> get _visibleDoctors {
    final query = _searchController.text.trim().toLowerCase();
    final doctors = widget.doctors.where((doctor) {
      if (!_matchesSearch(doctor, query)) return false;
      if (_zone != null && !_sameZone(doctor.zone, _zone!)) return false;
      if (_category != null && doctor.categoryName != _category) return false;
      if (_clinic != null && doctor.clinicName != _clinic) return false;
      return true;
    }).toList();
    doctors.sort((a, b) {
      final compare = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return _sort == _DoctorSort.nameAsc ? compare : -compare;
    });
    return doctors;
  }

  bool get _hasSearchOrFilter {
    return _searchController.text.trim().isNotEmpty ||
        _zone != null ||
        _category != null ||
        _clinic != null;
  }

  void _publishSearchedDoctors() {
    if (!_hasSearchOrFilter) return;
    final found = _visibleDoctors;
    if (found.isEmpty) return;
    widget.onDoctorsFound?.call(List<Doctor>.from(found));
  }

  Future<void> _showSortSheet() async {
    final picked = await _showChoiceSheet(
      title: 'Sort by',
      options: const ['Name (A - Z)', 'Name (Z - A)'],
      selected: _sort == _DoctorSort.nameAsc ? 'Name (A - Z)' : 'Name (Z - A)',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _sort = picked == 'Name (Z - A)' ? _DoctorSort.nameDesc : _DoctorSort.nameAsc;
    });
  }

  Future<void> _showCategorySheet(Color themeColor) async {
    final picked = await _showChoiceSheet(
      title: 'Category',
      options: ['All', ..._categories],
      selected: _category ?? 'All',
      themeColor: themeColor,
    );
    if (picked == null || !mounted) return;
    setState(() => _category = picked == 'All' ? null : picked);
    _publishSearchedDoctors();
  }

  Future<void> _showFiltersSheet(Color themeColor) async {
    final picked = await showModalBottomSheet<_FilterSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _FiltersSheet(
        themeColor: themeColor,
        zones: widget.zones,
        clinics: _clinics,
        zone: _zone,
        clinic: _clinic,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _zone = picked.zone;
      _clinic = picked.clinic;
    });
    _publishSearchedDoctors();
  }

  Future<String?> _showChoiceSheet({
    required String title,
    required List<String> options,
    required String selected,
    Color? themeColor,
  }) {
    final accent = themeColor ??
        ColorHelperClass.getColorFromHex(ColorResources.red_color);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final maxHeight = MediaQuery.sizeOf(context).height * 0.72;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2430),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF6D7278)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEDEDED)),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFF2F2F2)),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected = option == selected;
                      return ListTile(
                        title: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: const Color(0xFF1F2430),
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: accent, size: 20)
                            : null,
                        onTap: () => Navigator.pop(context, option),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _callDoctor(Doctor doctor) async {
    final number = doctor.mobileNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    var launched = false;
    try {
      launched = await launchUrl(Uri(scheme: 'tel', path: number));
    } catch (_) {}
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to make call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);
    final logoColor = ColorHelperClass.getColorFromHex(ColorResources.logo_color);
    final doctors = _visibleDoctors;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: logoColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${widget.specialty} (${widget.doctors.length})',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) {
                setState(() {});
                _publishSearchedDoctors();
              },
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1F2430)),
              decoration: InputDecoration(
                hintText: 'Search by name or mobile number',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9AA0A8)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8A9099)),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF8A9099)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          _publishSearchedDoctors();
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: Color(0xFFE6E8EC)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: Color(0xFFE6E8EC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(color: themeColor),
                ),
              ),
            ),
          ),
          Expanded(
            child: doctors.isEmpty
                ? const Center(
                    child: Text(
                      'No doctors found',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8A9099),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: doctors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _DoctorCard(
                      doctor: doctors[index],
                      themeColor: themeColor,
                      onCall: () => _callDoctor(doctors[index]),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomActionBar(
        themeColor: themeColor,
        sortActive: _sort != _DoctorSort.nameAsc,
        filtersActive: _zone != null || _clinic != null,
        categoryActive: _category != null,
        onSort: _showSortSheet,
        onFilters: () => _showFiltersSheet(themeColor),
        onCategory: () => _showCategorySheet(themeColor),
      ),
    );
  }
}

enum _DoctorSort { nameAsc, nameDesc }

class _FilterSelection {
  final String? zone;
  final String? clinic;

  const _FilterSelection({this.zone, this.clinic});
}

class _BottomActionBar extends StatelessWidget {
  final Color themeColor;
  final bool sortActive;
  final bool filtersActive;
  final bool categoryActive;
  final VoidCallback onSort;
  final VoidCallback onFilters;
  final VoidCallback onCategory;

  const _BottomActionBar({
    required this.themeColor,
    required this.sortActive,
    required this.filtersActive,
    required this.categoryActive,
    required this.onSort,
    required this.onFilters,
    required this.onCategory,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              _BottomAction(
                icon: Icons.swap_vert,
                label: 'SORT BY',
                active: sortActive,
                activeColor: themeColor,
                onTap: onSort,
              ),
              _BottomAction(
                icon: Icons.tune,
                label: 'FILTERS',
                active: filtersActive,
                activeColor: themeColor,
                onTap: onFilters,
              ),
              _BottomAction(
                icon: Icons.layers_outlined,
                label: 'CATEGORY',
                active: categoryActive,
                activeColor: themeColor,
                onTap: onCategory,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _BottomAction({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : const Color(0xFF6D7278);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  final Color themeColor;
  final List<String> zones;
  final List<String> clinics;
  final String? zone;
  final String? clinic;

  const _FiltersSheet({
    required this.themeColor,
    required this.zones,
    required this.clinics,
    required this.zone,
    required this.clinic,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  String? _zone;
  String? _clinic;

  @override
  void initState() {
    super.initState();
    _zone = widget.zone;
    _clinic = widget.clinic;
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2430),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF6D7278)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEDEDED)),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                children: [
                  const Text(
                    'Location / Zone',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2430),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _optionWrap(
                    options: widget.zones,
                    selected: _zone,
                    onSelected: (value) => setState(() => _zone = value),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Clinic name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2430),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _optionWrap(
                    options: widget.clinics,
                    selected: _clinic,
                    onSelected: (value) => setState(() => _clinic = value),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEDEDED)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(
                        context,
                        const _FilterSelection(),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1F2430),
                        side: const BorderSide(color: Color(0xFFD8DADF)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'CLEAR',
                        style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(
                        context,
                        _FilterSelection(zone: _zone, clinic: _clinic),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'APPLY',
                        style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionWrap({
    required List<String> options,
    required String? selected,
    required ValueChanged<String?> onSelected,
  }) {
    final values = <String?>[null, ...options];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) {
        final isSelected = value == selected;
        final label = value ?? 'All';
        return InkWell(
          onTap: () => onSelected(value),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? widget.themeColor.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? widget.themeColor : const Color(0xFFD8DADF),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? widget.themeColor : const Color(0xFF4B5160),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final Color themeColor;
  final VoidCallback onCall;

  const _DoctorCard({
    required this.doctor,
    required this.themeColor,
    required this.onCall,
  });

  Future<void> _shareProfile() async {
    final category = doctor.category != null ? ' (${doctor.category})' : '';
    final shareText = '👨‍⚕️ ${doctor.name}\n'
        '🏥 ${doctor.specialty}$category\n'
        '⭐ Experience: ${doctor.experience}\n'
        '🏢 ${doctor.clinicName}\n'
        '📍 ${doctor.address}\n'
        '📞 ${doctor.mobileNumber}\n'
        '📧 ${doctor.email}';

    await Share.share(shareText, subject: '${doctor.name} - ${doctor.specialty}');
  }

  void _viewProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 22, color: themeColor),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Doctor Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(dialogContext),
                      child: Icon(Icons.close, size: 24, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey[300], height: 1),
                const SizedBox(height: 16),
                _DoctorAvatar(imageUrl: doctor.imageUrl, size: 88),
                const SizedBox(height: 12),
                Text(
                  doctor.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    doctor.categoryName,
                    style: TextStyle(
                      fontSize: 13,
                      color: themeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _profileRow(Icons.local_hospital_outlined, doctor.clinicName),
                _profileRow(Icons.location_on_outlined, '${doctor.zone}\n${doctor.address}'),
                _profileRow(Icons.phone_outlined, doctor.mobileNumber),
                _profileRow(Icons.email_outlined, doctor.email),
                _profileRow(Icons.star_outline, '${doctor.experience} experience'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _profileRow(IconData icon, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: themeColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, height: 1.35, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DoctorAvatar(imageUrl: doctor.imageUrl, size: 56),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2430),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        doctor.categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: themeColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.local_hospital_outlined,
                              size: 14, color: Color(0xFF8A9099)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              doctor.clinicName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF4B5160)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: Color(0xFF8A9099)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              doctor.zone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF4B5160)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: onCall,
                        child: Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF2E9E5B)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                doctor.mobileNumber,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E9E5B),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF2E9E5B),
                                ),
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
          const Divider(height: 1, color: Color(0xFFEDEFF2)),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: _CardAction(
                    icon: Icons.share_outlined,
                    label: 'Share profile',
                    onTap: _shareProfile,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _CardAction(
                    icon: Icons.person_outline,
                    label: 'View profile',
                    onTap: () => _viewProfile(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _DoctorAvatar({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();
    return ClipOval(
      child: SizedBox(
        height: size,
        width: size,
        child: url.isEmpty
            ? Image.asset('assets/images/user3.png', fit: BoxFit.cover)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Image.asset('assets/images/user3.png', fit: BoxFit.cover),
              ),
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F6F8),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          height: 38,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF4B5160)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5160),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
