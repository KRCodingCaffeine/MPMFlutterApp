import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/Utility/utility_view.dart';
import 'package:url_launcher/url_launcher.dart';

class SpecialtyDoctorsView extends StatefulWidget {
  final String specialty;
  final List<Doctor> doctors;
  final List<String> zones;

  const SpecialtyDoctorsView({
    super.key,
    required this.specialty,
    required this.doctors,
    required this.zones,
  });

  @override
  State<SpecialtyDoctorsView> createState() => _SpecialtyDoctorsViewState();
}

class _SpecialtyDoctorsViewState extends State<SpecialtyDoctorsView> {
  final TextEditingController _searchController = TextEditingController();
  String? _zone;
  String? _category;
  String? _clinic;

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
    return widget.doctors.where((doctor) {
      if (!_matchesSearch(doctor, query)) return false;
      if (_zone != null && !_sameZone(doctor.zone, _zone!)) return false;
      if (_category != null && doctor.categoryName != _category) return false;
      if (_clinic != null && doctor.clinicName != _clinic) return false;
      return true;
    }).toList();
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
              onChanged: (_) => setState(() {}),
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
      bottomNavigationBar: _FilterBar(
        themeColor: themeColor,
        zones: widget.zones,
        categories: _categories,
        clinics: _clinics,
        zone: _zone,
        category: _category,
        clinic: _clinic,
        onZone: (value) => setState(() => _zone = value),
        onCategory: (value) => setState(() => _category = value),
        onClinic: (value) => setState(() => _clinic = value),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final Color themeColor;
  final List<String> zones;
  final List<String> categories;
  final List<String> clinics;
  final String? zone;
  final String? category;
  final String? clinic;
  final ValueChanged<String?> onZone;
  final ValueChanged<String?> onCategory;
  final ValueChanged<String?> onClinic;

  const _FilterBar({
    required this.themeColor,
    required this.zones,
    required this.categories,
    required this.clinics,
    required this.zone,
    required this.category,
    required this.clinic,
    required this.onZone,
    required this.onCategory,
    required this.onClinic,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _filterDropdown(
                label: 'Location / Zone',
                icon: Icons.location_on_outlined,
                value: zone,
                options: zones,
                onChanged: onZone,
              ),
              const SizedBox(height: 8),
              _filterDropdown(
                label: 'Category',
                icon: Icons.category_outlined,
                value: category,
                options: categories,
                onChanged: onCategory,
              ),
              const SizedBox(height: 8),
              _filterDropdown(
                label: 'Clinic name',
                icon: Icons.local_hospital_outlined,
                value: clinic,
                options: clinics,
                onChanged: onClinic,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : null,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, size: 18, color: themeColor),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF8A9099))),
            ],
          ),
          icon: const Icon(Icons.expand_more, color: Color(0xFF8A9099)),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('All', style: TextStyle(fontSize: 13, color: themeColor)),
            ),
            ...options.map(
              (option) => DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1F2430)),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
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
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: themeColor),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.local_hospital_outlined, size: 14, color: Color(0xFF8A9099)),
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
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF8A9099)),
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
                Text(
                  doctor.mobileNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E9E5B),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF2E9E5B),
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
