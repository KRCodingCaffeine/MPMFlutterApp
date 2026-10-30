import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/model/CountryModel/CountryData.dart';
import 'package:mpm/model/CountryModel/CountryModelClass.dart';
import 'package:mpm/model/State/StateData.dart';
import 'package:mpm/model/State/StateModelClass.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/model/city/CityModelClass.dart';
import 'package:mpm/repository/register_repository/register_repo.dart';
import 'package:mpm/repository/zone_repository/zone_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UtilityView extends StatefulWidget {
  const UtilityView({super.key});

  @override
  State<UtilityView> createState() => _UtilityViewState();
}

class _UtilityViewState extends State<UtilityView> {
  final TextEditingController _searchController = TextEditingController();
  List<Doctor> _allDoctors = [];
  String _memberZone = '';
  String? _selectedSpecialty;
  bool _allAreas = false;
  final Set<String> _selectedAreas = {};
  List<String> _zones = [];
  Set<String> _savedDoctors = {};
  int _selectedTabIndex = 0;

  bool get _hasSearch => _searchController.text.trim().isNotEmpty;

  bool get _hasAreaSelection => _allAreas || _selectedAreas.isNotEmpty;

  String get _areaLabel {
    if (!_hasAreaSelection) return 'Select geographical area';
    if (_allAreas) return 'All';
    final names = _selectedAreas.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    if (names.length <= 2) return names.join(', ');
    return '${names.length} areas';
  }

  // All shows every API-zone doctor. A specific area still needs a doctor type or a search.
  bool get _hasActiveQuery =>
      _allAreas || (_hasAreaSelection && (_hasSearch || _selectedSpecialty != null));

  // Sample doctor data
  final List<Doctor> sampleDoctors = buildSampleDoctors();

  // Available specialties for filter
  List<String> getAvailableSpecialties() {
    final specialties = sampleDoctors.map((d) => d.specialty).toSet().toList();
    return specialties;
  }

  @override
  void initState() {
    super.initState();
    _allDoctors = sampleDoctors;
    _loadMemberZone();
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      final response = await ZoneRepository().ZoneApi();
      final zones = (response.data ?? [])
          .map((zone) => zone.zoneName?.trim() ?? '')
          .where((name) => name.isNotEmpty && name.toLowerCase() != 'null')
          .toList();
      if (!mounted) return;
      setState(() => _zones = zones);
    } catch (e) {
      debugPrint('❌ Error loading zones: $e');
    }
  }

  // Only the zones returned by the zone API
  List<String> _availableAreas() {
    final areas = <String, String>{};
    for (final zone in _zones) {
      final name = zone.trim();
      if (name.isNotEmpty) areas.putIfAbsent(name.toLowerCase(), () => name);
    }
    return areas.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMemberZone() async {
    final profile = Get.isRegistered<UdateProfileController>()
        ? Get.find<UdateProfileController>()
        : Get.put(UdateProfileController());
    var zone = profile.getUserData.value.address?.zoneName?.toString().trim() ?? '';
    if (zone.isEmpty || zone.toLowerCase() == 'null') {
      try {
        await profile.getUserProfile();
        zone = profile.getUserData.value.address?.zoneName?.toString().trim() ?? '';
      } catch (_) {
        zone = '';
      }
    }
    if (!mounted) return;
    setState(() {
      _memberZone = zone.toLowerCase() == 'null' ? '' : zone;
    });
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  bool _matchesSearch(Doctor doctor, String query) {
    if (query.isEmpty) return true;
    final name = doctor.name.toLowerCase();
    final mobile = _digitsOnly(doctor.mobileNumber);
    final queryDigits = _digitsOnly(query);
    return name.contains(query) ||
        (queryDigits.isNotEmpty && mobile.contains(queryDigits));
  }

  bool _sameZone(String doctorZone, String memberZone) {
    final doctor = doctorZone.toLowerCase().trim();
    final member = memberZone.toLowerCase().trim();
    if (doctor.isEmpty || member.isEmpty) return false;
    return doctor == member || doctor.contains(member) || member.contains(doctor);
  }

  bool _matchesSelectedAreas(String zone) {
    if (_allAreas) {
      return _zones.any((area) => _sameZone(zone, area));
    }
    return _selectedAreas.any((area) => _sameZone(zone, area));
  }

  List<Doctor> _visibleDoctors() {
    if (!_hasAreaSelection) return [];
    final query = _searchController.text.trim().toLowerCase();

    return _allDoctors.where((doctor) {
      final matchesSpecialty = _selectedSpecialty == null ||
          doctor.specialty == _selectedSpecialty;
      return _matchesSearch(doctor, query) &&
          matchesSpecialty &&
          _matchesSelectedAreas(doctor.zone);
    }).toList();
  }

  String get _listTitle {
    if (_hasSearch && _selectedSpecialty == null) return 'Search results';
    if (_selectedSpecialty != null) return _selectedSpecialty!;
    if (_allAreas) return 'All';
    return 'Find a Doctor';
  }

  void _clearDoctorType() {
    _searchController.clear();
    _selectedSpecialty = null;
    setState(() {});
  }

  void _selectSpecialty(String specialty) {
    setState(() {
      _selectedSpecialty = _selectedSpecialty == specialty ? null : specialty;
    });
  }

  Future<void> _openAreaPicker() async {
    final areas = _availableAreas();
    final selected = await showModalBottomSheet<_AreaSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _AreaPickerSheet(
          areas: areas,
          memberZone: _memberZone,
          allSelected: _allAreas,
          selectedAreas: Set<String>.from(_selectedAreas),
          totalDoctors: _allDoctors
              .where((doctor) => _zones.any((zone) => _sameZone(doctor.zone, zone)))
              .length,
          doctorCount: (area) => _allDoctors
              .where((doctor) => _sameZone(doctor.zone, area))
              .length,
        );
      },
    );
    if (selected == null || !mounted) return;
    final sameAll = selected.all == _allAreas;
    final sameAreas = selected.all ||
        (selected.areas.length == _selectedAreas.length &&
            selected.areas.every(_selectedAreas.contains));
    if (sameAll && sameAreas) return;
    setState(() {
      _allAreas = selected.all;
      _selectedAreas
        ..clear()
        ..addAll(selected.all ? const <String>{} : selected.areas);
      _selectedSpecialty = null;
    });
  }

  void _toggleSaveDoctor(Doctor doctor) {
    setState(() {
      if (_savedDoctors.contains(doctor.name)) {
        _savedDoctors.remove(doctor.name);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed ${doctor.name} from saved'),
            backgroundColor: Colors.grey,
          ),
        );
      } else {
        _savedDoctors.add(doctor.name);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved ${doctor.name}'),
            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
          ),
        );
      }
    });
  }

  // Opens the phone dialer with the doctor's number straight away
  Future<void> _callDoctor(Doctor doctor) async {
    final number = doctor.mobileNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    var launched = false;
    try {
      launched = await launchUrl(Uri(scheme: 'tel', path: number));
    } catch (e) {
      debugPrint('❌ Error launching dialer: $e');
    }
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to make call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareDoctor(Doctor doctor) async {
    final category = doctor.category != null ? ' (${doctor.category})' : '';
    final shareText =
        '👨‍⚕️ ${doctor.name}\n'
        '🏥 ${doctor.specialty}$category\n'
        '⭐ Experience: ${doctor.experience}\n'
        '🏢 ${doctor.clinicName}\n'
        '📍 ${doctor.address}\n'
        '📞 ${doctor.mobileNumber}\n'
        '📧 ${doctor.email}';

    await Share.share(shareText, subject: '${doctor.name} - ${doctor.specialty}');
  }

  void _showDoctorDetails(Doctor doctor) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 22, color: themeColor),
                          const SizedBox(width: 8),
                          Text(
                            "Doctor Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, size: 26, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[300]),
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
                              backgroundColor: Colors.grey[200],
                              child: ClipOval(
                                child: Image.network(
                                  doctor.imageUrl,
                                  fit: BoxFit.cover,
                                  width: 90,
                                  height: 90,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/images/user3.png",
                                      fit: BoxFit.cover,
                                      width: 90,
                                      height: 90,
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.red[50],
                                      child: const Center(
                                        child: SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              doctor.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                doctor.specialty,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: themeColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 16, color: themeColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    doctor.zone,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Divider(color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.phone, size: 16, color: themeColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    doctor.mobileNumber,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.email_outlined, size: 16, color: themeColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    doctor.email,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    doctor.experience,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
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
                              doctor.clinicName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Clinic Address",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              doctor.address,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Divider(color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _callDoctor(doctor);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[600],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(Icons.call, color: Colors.white),
                                    label: const Text('Call Now', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _shareDoctor(doctor);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(Icons.share, color: Colors.white),
                                    label: const Text('Share', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
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

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);
    final logoColor = ColorHelperClass.getColorFromHex(ColorResources.logo_color);

    // Get filtered saved doctors
    List<Doctor> savedDoctors = _allDoctors
        .where((doctor) => _savedDoctors.contains(doctor.name))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: logoColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Doctors",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton.icon(
            onPressed: _showAddDoctorInstructions,
            icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 18),
            label: const Text(
              'Add Doctor',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _selectedTabIndex == 0
          ? _buildDiscoverPage(themeColor)
          : Column(
              children: [
                _buildSectionHeader(
                  title: 'Saved',
                  count:
                      '${savedDoctors.length} ${savedDoctors.length == 1 ? 'doctor' : 'doctors'}',
                ),
                Expanded(child: _buildDoctorGrid(savedDoctors)),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE6E8EC))),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: themeColor,
          unselectedItemColor: const Color(0xFF8A9099),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined),
              activeIcon: Icon(Icons.medical_services),
              label: 'Doctors',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border),
              activeIcon: Icon(Icons.bookmark),
              label: 'Saved',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String count,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2430),
            ),
          ),
          const Spacer(),
          Text(
            count,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8A9099),
            ),
          ),
        ],
      ),
    );
  }

  int _specialtyCount(String specialty) {
    if (!_hasAreaSelection) return 0;
    return _allDoctors
        .where((doctor) =>
            doctor.specialty == specialty && _matchesSelectedAreas(doctor.zone))
        .length;
  }

  Widget _buildDiscoverPage(Color themeColor) {
    final doctors = _hasActiveQuery ? _visibleDoctors() : const <Doctor>[];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildTotalDoctors(themeColor)),
        SliverToBoxAdapter(child: _buildAreaSelector(themeColor)),
        if (!_hasAreaSelection)
          SliverToBoxAdapter(child: _buildAreaPrompt(themeColor))
        else ...[
          SliverToBoxAdapter(child: _buildSpecialtySection(themeColor)),
          SliverToBoxAdapter(child: _buildSearchBar(themeColor)),
          if (!_hasActiveQuery)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Text(
                  'Choose Find a Doctor to see the doctors in $_areaLabel.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF5B6270),
                  ),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                title: _listTitle,
                count: '${doctors.length} ${doctors.length == 1 ? 'doctor' : 'doctors'}',
              ),
            ),
            if (doctors.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(
                  icon: Icons.search_off,
                  title: 'No doctors found',
                  message: _selectedSpecialty != null && !_hasSearch
                      ? 'No $_listTitle is listed in $_areaLabel yet.'
                      : 'Try another name or mobile number in $_areaLabel.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                sliver: SliverList.separated(
                  itemCount: doctors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _buildDoctorCard(doctors[index]),
                ),
              ),
          ],
        ],
      ],
    );
  }

  Widget _buildTotalDoctors(Color themeColor) {
    final count = _allDoctors.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6E8EC)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.groups_outlined, color: themeColor, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Total Doctors',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2430),
                ),
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: themeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaSelector(Color themeColor) {
    final selected = _hasAreaSelection;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Geographical area',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2430),
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _openAreaPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? themeColor : const Color(0xFFE6E8EC),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: themeColor, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _areaLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? const Color(0xFF1F2430)
                              : const Color(0xFF9AA0A8),
                        ),
                      ),
                    ),
                    const Icon(Icons.expand_more, color: Color(0xFF8A9099)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaPrompt(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E8EC)),
        ),
        child: Column(
          children: [
            Icon(Icons.location_on_outlined, color: themeColor, size: 28),
            const SizedBox(height: 8),
            const Text(
              'Select a geographical area first',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2430),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'After the area, choose Find a Doctor to see the doctors listed there.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF5B6270)),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSearchBar(Color themeColor) {
    return Padding(
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
          suffixIcon: _hasSearch
              ? IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF8A9099)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
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
    );
  }

  static const int _maxVisibleSpecialties = 5;

  Widget _buildSpecialtySection(Color themeColor) {
    final specialties = getAvailableSpecialties()..sort();

    // Keep a specialty picked from "View more" visible in the short row
    final visible = specialties.take(_maxVisibleSpecialties).toList();
    if (_selectedSpecialty != null && !visible.contains(_selectedSpecialty)) {
      visible
        ..insert(0, _selectedSpecialty!)
        ..removeLast();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Find a Doctor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2430),
                  ),
                ),
              ),
              if (_selectedSpecialty != null || _hasSearch) ...[
                GestureDetector(
                  onTap: _clearDoctorType,
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: themeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              if (specialties.length > _maxVisibleSpecialties)
                GestureDetector(
                  onTap: () => _showAllSpecialties(specialties, themeColor),
                  child: Text(
                    'View more',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: themeColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: visible
                .map((name) => Expanded(
                      child: _buildSpecialtyChip(
                        label: name,
                        count: _specialtyCount(name),
                        selected: _selectedSpecialty == name,
                        themeColor: themeColor,
                        onTap: () => _selectSpecialty(name),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showAllSpecialties(List<String> specialties, Color themeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      const Text(
                        'Find a Doctor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2430),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pop(sheetContext),
                        child: Icon(Icons.close, size: 26, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: specialties.length,
                    itemBuilder: (context, index) {
                      final name = specialties[index];
                      return _buildSpecialtyChip(
                        label: name,
                        count: _specialtyCount(name),
                        selected: _selectedSpecialty == name,
                        themeColor: themeColor,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _selectSpecialty(name);
                        },
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

  Widget _buildSpecialtyChip({
    required String label,
    required int count,
    required bool selected,
    required Color themeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: selected ? themeColor : const Color(0xFFFFF1F2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _specialtyIcon(label),
                        color: selected ? Colors.white : themeColor,
                        size: 24,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: count == 0 ? const Color(0xFFB6BBC3) : themeColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? themeColor : const Color(0xFF4B5160),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _specialtyIcon(String specialty) {
    switch (specialty.toLowerCase()) {
      case 'cardiologist':
        return Icons.favorite_border;
      case 'dermatologist':
        return Icons.face_retouching_natural;
      case 'neurologist':
        return Icons.psychology_outlined;
      case 'pediatrician':
        return Icons.child_care;
      case 'orthopedic':
        return Icons.accessibility_new;
      case 'gynecologist':
        return Icons.pregnant_woman;
      case 'general physician':
        return Icons.medical_services_outlined;
      case 'ophthalmologist':
        return Icons.visibility_outlined;
      default:
        return Icons.local_hospital_outlined;
    }
  }

  Widget _buildDoctorGrid(List<Doctor> doctors) {
    if (doctors.isEmpty) {
      if (_selectedTabIndex == 1) {
        return _buildEmptyState(
          icon: Icons.bookmark_border,
          title: 'No saved doctors',
          message: 'Save a doctor from the list to keep them here.',
        );
      }

      return _buildEmptyState(
        icon: Icons.medical_services_outlined,
        title: 'No doctors to show',
        message: 'Doctors will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: doctors.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildDoctorCard(doctors[index]),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0x14E61428),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: const Color(0xFFE61428)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2430),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF8A9099),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);
    final isSaved = _savedDoctors.contains(doctor.name);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showDoctorDetails(doctor),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6E8EC)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDoctorAvatar(doctor.imageUrl),
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
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildCardTag(
                                icon: _specialtyIcon(doctor.specialty),
                                label: doctor.specialty,
                                background: const Color(0xFFFFF1F2),
                                foreground: themeColor,
                              ),
                              if (doctor.category != null)
                                _buildCardTag(
                                  icon: Icons.category_outlined,
                                  label: doctor.category!,
                                  background: const Color(0xFFF1F2F4),
                                  foreground: const Color(0xFF4B5160),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _callDoctor(doctor),
                            child: Row(
                              children: [
                                const Icon(Icons.phone_outlined,
                                    size: 14, color: Color(0xFF2E9E5B)),
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
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 14, color: Color(0xFF8A9099)),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  '${doctor.zone}  ·  ${doctor.experience} exp',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8A9099),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _toggleSaveDoctor(doctor),
                      visualDensity: VisualDensity.compact,
                      tooltip: isSaved ? 'Remove from saved' : 'Save',
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        size: 22,
                        color: isSaved ? themeColor : const Color(0xFF8A9099),
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
                      child: _buildCardAction(
                        icon: Icons.share_outlined,
                        label: 'Share profile',
                        color: const Color(0xFF4B5160),
                        onTap: () => _shareDoctor(doctor),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildCardAction(
                        icon: Icons.person_outline,
                        label: 'View profile',
                        color: const Color(0xFF4B5160),
                        onTap: () => _showDoctorDetails(doctor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardTag({
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    Color? background,
  }) {
    return Material(
      color: background ?? const Color(0xFFF4F6F8),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          height: 38,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorAvatar(String imageUrl) {
    return ClipOval(
      child: SizedBox(
        height: 56,
        width: 56,
        child: imageUrl.trim().isEmpty
            ? Image.asset('assets/images/user3.png', fit: BoxFit.cover)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/user3.png', fit: BoxFit.cover);
                },
              ),
      ),
    );
  }

  void _showAddDoctorInstructions() {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);

    const instructions = [
      'The doctor you propose to add must be from Maheshwari community.',
      'He should be prepared to become member of the Mandal, if he is not at the moment.',
      'Please fill up his details and submit.',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 22, color: themeColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Icon(Icons.close, size: 26, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  ...List.generate(instructions.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: themeColor,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              instructions[index],
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      'Mandal office would go thru and then make this live.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.red[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _showAddDoctorBottomSheet();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'I understand, Confirm',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddDoctorBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddDoctorBottomSheet(),
    );
  }
}

class _AddDoctorBottomSheet extends StatefulWidget {
  const _AddDoctorBottomSheet();

  @override
  State<_AddDoctorBottomSheet> createState() => _AddDoctorBottomSheetState();
}

class _AddDoctorBottomSheetState extends State<_AddDoctorBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _registerRepo = RegisterRepository();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  // Personal info
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _alternateMobileController = TextEditingController();
  final _whatsappController = TextEditingController();

  // Home address
  final _homePincodeController = TextEditingController();
  final _homeFlatNoController = TextEditingController();
  final _homeAddressController = TextEditingController();
  final _homeAreaController = TextEditingController();
  String? _homeCityId;
  String? _homeStateId;
  String? _homeCountryId;

  // Clinic address
  final _clinicNameController = TextEditingController();
  final _clinicPhoneController = TextEditingController();
  final _clinicPincodeController = TextEditingController();
  final _clinicFlatNoController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _clinicAreaController = TextEditingController();
  String? _clinicCityId;
  String? _clinicStateId;
  String? _clinicCountryId;

  bool _isLocationLoading = true;
  List<CountryData> _countries = [];
  List<StateData> _states = [];
  List<CityData> _cities = [];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _alternateMobileController.dispose();
    _whatsappController.dispose();
    _homePincodeController.dispose();
    _homeFlatNoController.dispose();
    _homeAddressController.dispose();
    _homeAreaController.dispose();
    _clinicNameController.dispose();
    _clinicPhoneController.dispose();
    _clinicPincodeController.dispose();
    _clinicFlatNoController.dispose();
    _clinicAddressController.dispose();
    _clinicAreaController.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    try {
      final results = await Future.wait([
        _registerRepo.CountryApi(),
        _registerRepo.StateApi(),
        _registerRepo.CityApi(),
      ]);
      if (!mounted) return;
      setState(() {
        _countries = (results[0] as CountryModelClass).data ?? [];
        _states = (results[1] as StateModelClass).data ?? [];
        _cities = (results[2] as CityModelClass).data ?? [];
        _isLocationLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading locations: $e');
      if (!mounted) return;
      setState(() => _isLocationLoading = false);
    }
  }

  // States filtered by the selected country
  List<StateData> _statesFor(String? countryId) {
    if (countryId == null) return _states;
    return _states.where((s) => s.countryId == countryId).toList();
  }

  // Cities filtered by the selected state, or country when no state is selected
  List<CityData> _citiesFor(String? stateId, String? countryId) {
    if (stateId != null) {
      return _cities.where((c) => c.stateId == stateId).toList();
    }
    if (countryId != null) {
      return _cities.where((c) => c.countryId == countryId).toList();
    }
    return _cities;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (picked != null && mounted) {
        setState(() => _profileImage = File(picked.path));
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
    }
  }

  void _showImageSourcePicker() {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: themeColor),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: themeColor),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => _profileImage = null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _mobileValidator(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Please enter mobile number' : null;
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
      return 'Please enter a valid 10 digit number';
    }
    return null;
  }

  String? _pincodeValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) {
      return 'Please enter a valid 6 digit pincode';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: Submit doctor details to the API once it is available
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        content: const Text(
          'Doctor details submitted. Mandal office will review and make it live.',
        ),
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);

    return InputDecoration(
      labelText: label,
      counterText: '',
      prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: themeColor),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLength: maxLength,
        maxLines: maxLines,
        textCapitalization: keyboardType == TextInputType.text
            ? TextCapitalization.words
            : TextCapitalization.none,
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Drop the selection if it is not in the current (filtered) list
    final selected =
        items.any((item) => item.value == value) ? value : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        key: ValueKey('$label-$selected-${items.length}'),
        initialValue: selected,
        isExpanded: true,
        items: items,
        onChanged: _isLocationLoading ? null : onChanged,
        menuMaxHeight: 350,
        decoration: _inputDecoration(label, icon).copyWith(
          suffixIcon: _isLocationLoading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: themeColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Center(
        child: GestureDetector(
          onTap: _showImageSourcePicker,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage('assets/images/user3.png')
                            as ImageProvider,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _profileImage != null ? 'Change Profile Image' : 'Upload Profile Image',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// City, State and Country dropdowns. Picking a city fills its state and
  /// country; changing state or country clears selections that no longer match.
  List<Widget> _buildLocationDropdowns({
    required String? cityId,
    required String? stateId,
    required String? countryId,
    required void Function(String? cityId, String? stateId, String? countryId) onChanged,
  }) {
    final cities = _citiesFor(stateId, countryId);
    final states = _statesFor(countryId);

    return [
      _buildDropdown(
        label: 'City',
        icon: Icons.location_city_outlined,
        value: cityId,
        items: cities
            .map((city) => DropdownMenuItem<String>(
                  value: city.id,
                  child: Text(city.cityName ?? '', overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: (value) {
          final city = _cities.firstWhereOrNull((c) => c.id == value);
          onChanged(value, city?.stateId ?? stateId, city?.countryId ?? countryId);
        },
      ),
      _buildDropdown(
        label: 'State',
        icon: Icons.map_outlined,
        value: stateId,
        items: states
            .map((state) => DropdownMenuItem<String>(
                  value: state.id,
                  child: Text(state.stateName ?? '', overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: (value) {
          final state = _states.firstWhereOrNull((s) => s.id == value);
          final city = _cities.firstWhereOrNull((c) => c.id == cityId);
          onChanged(
            city?.stateId == value ? cityId : null,
            value,
            state?.countryId ?? countryId,
          );
        },
      ),
      _buildDropdown(
        label: 'Country',
        icon: Icons.public,
        value: countryId,
        items: _countries
            .map((country) => DropdownMenuItem<String>(
                  value: country.id,
                  child: Text(country.countryName ?? '', overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: (value) {
          final state = _states.firstWhereOrNull((s) => s.id == stateId);
          final city = _cities.firstWhereOrNull((c) => c.id == cityId);
          onChanged(
            city?.countryId == value ? cityId : null,
            state?.countryId == value ? stateId : null,
            value,
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.person_add_alt_1, color: themeColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Add Doctor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 26, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Personal Info
                      _buildSectionTitle('Personal Info', Icons.person_outline),
                      _buildProfileImagePicker(),
                      _buildTextField(
                        controller: _firstNameController,
                        label: 'First Name *',
                        icon: Icons.person_outline,
                        validator: (value) => _requiredValidator(value, 'first name'),
                      ),
                      _buildTextField(
                        controller: _middleNameController,
                        label: 'Middle Name',
                        icon: Icons.person_outline,
                      ),
                      _buildTextField(
                        controller: _surnameController,
                        label: 'Surname *',
                        icon: Icons.person_outline,
                        validator: (value) => _requiredValidator(value, 'surname'),
                      ),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                      _buildTextField(
                        controller: _mobileController,
                        label: 'Mobile Number *',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: (value) => _mobileValidator(value, required: true),
                      ),
                      _buildTextField(
                        controller: _alternateMobileController,
                        label: 'Alternate Mobile',
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: _mobileValidator,
                      ),
                      _buildTextField(
                        controller: _whatsappController,
                        label: 'WhatsApp Number',
                        icon: Icons.chat_outlined,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: _mobileValidator,
                      ),

                      // Home Address
                      _buildSectionTitle('Home Address', Icons.home_outlined),
                      _buildTextField(
                        controller: _homePincodeController,
                        label: 'Pincode',
                        icon: Icons.pin_drop_outlined,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: _pincodeValidator,
                      ),
                      _buildTextField(
                        controller: _homeFlatNoController,
                        label: 'Flat / House No',
                        icon: Icons.home_work_outlined,
                      ),
                      _buildTextField(
                        controller: _homeAddressController,
                        label: 'Home Address',
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                      _buildTextField(
                        controller: _homeAreaController,
                        label: 'Area / Locality',
                        icon: Icons.signpost_outlined,
                      ),
                      ..._buildLocationDropdowns(
                        cityId: _homeCityId,
                        stateId: _homeStateId,
                        countryId: _homeCountryId,
                        onChanged: (cityId, stateId, countryId) {
                          setState(() {
                            _homeCityId = cityId;
                            _homeStateId = stateId;
                            _homeCountryId = countryId;
                          });
                        },
                      ),

                      // Clinic Address
                      _buildSectionTitle('Clinic Address', Icons.local_hospital_outlined),
                      _buildTextField(
                        controller: _clinicNameController,
                        label: 'Clinic / Hospital Name',
                        icon: Icons.local_hospital_outlined,
                      ),
                      _buildTextField(
                        controller: _clinicPhoneController,
                        label: 'Clinic Phone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        maxLength: 12,
                      ),
                      _buildTextField(
                        controller: _clinicPincodeController,
                        label: 'Pincode',
                        icon: Icons.pin_drop_outlined,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: _pincodeValidator,
                      ),
                      _buildTextField(
                        controller: _clinicFlatNoController,
                        label: 'Flat / Office No',
                        icon: Icons.business_outlined,
                      ),
                      _buildTextField(
                        controller: _clinicAddressController,
                        label: 'Clinic Address',
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                      _buildTextField(
                        controller: _clinicAreaController,
                        label: 'Area / Locality',
                        icon: Icons.signpost_outlined,
                      ),
                      ..._buildLocationDropdowns(
                        cityId: _clinicCityId,
                        stateId: _clinicStateId,
                        countryId: _clinicCountryId,
                        onChanged: (cityId, stateId, countryId) {
                          setState(() {
                            _clinicCityId = cityId;
                            _clinicStateId = stateId;
                            _clinicCountryId = countryId;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Submit button
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 15,
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
      ),
    );
  }
}

class Doctor {
  final String name;
  final String specialty;
  final String mobileNumber;
  final String imageUrl;
  final String email;
  final String experience;
  final String clinicName;
  final String address;
  final String zone;
  final String? category;

  Doctor({
    required this.name,
    required this.specialty,
    required this.mobileNumber,
    required this.imageUrl,
    required this.email,
    required this.experience,
    required this.clinicName,
    required this.address,
    required this.zone,
    this.category,
  });

  /// Category within the specialty; doctors without one sit under the specialty itself
  String get categoryName => category ?? specialty;
}

class SpecialtyCategory {
  final String name;
  final bool isService;

  const SpecialtyCategory(this.name, {this.isService = false});
}

const Map<String, List<SpecialtyCategory>> _specialtyCategories = {
  'Cardiologist': [
    SpecialtyCategory('Cardiologist'),
    SpecialtyCategory('Cardiologist Opinion', isService: true),
    SpecialtyCategory('Interventional Cardiologist'),
    SpecialtyCategory('Vascular Cardiologist'),
    SpecialtyCategory('Pediatric Cardiologist'),
    SpecialtyCategory('Preventive Cardiologist And Rehabilitation Specialist'),
    SpecialtyCategory('Veterinary Cardiologist'),
    SpecialtyCategory('Invasive Cardiologist'),
  ],
  'Dermatologist': [
    SpecialtyCategory('Dermatologist'),
    SpecialtyCategory('Dermatologist Opinion', isService: true),
    SpecialtyCategory('Cosmetic Dermatologist'),
    SpecialtyCategory('Pediatric Dermatologist'),
    SpecialtyCategory('Trichologist'),
    SpecialtyCategory('Dermatosurgeon'),
  ],
  'Neurologist': [
    SpecialtyCategory('Neurologist'),
    SpecialtyCategory('Neurologist Opinion', isService: true),
    SpecialtyCategory('Pediatric Neurologist'),
    SpecialtyCategory('Neurosurgeon'),
    SpecialtyCategory('Neurophysician'),
  ],
  'Pediatrician': [
    SpecialtyCategory('Pediatrician'),
    SpecialtyCategory('Pediatric Consultation', isService: true),
    SpecialtyCategory('Neonatologist'),
    SpecialtyCategory('Pediatric Surgeon'),
  ],
  'Orthopedic': [
    SpecialtyCategory('Orthopedic'),
    SpecialtyCategory('Orthopedic Opinion', isService: true),
    SpecialtyCategory('Joint Replacement Surgeon'),
    SpecialtyCategory('Spine Surgeon'),
    SpecialtyCategory('Sports Medicine Specialist'),
    SpecialtyCategory('Pediatric Orthopedic'),
  ],
  'Gynecologist': [
    SpecialtyCategory('Gynecologist'),
    SpecialtyCategory('Gynecologist Opinion', isService: true),
    SpecialtyCategory('Obstetrician'),
    SpecialtyCategory('Infertility Specialist'),
    SpecialtyCategory('Gynecologic Oncologist'),
  ],
  'General Physician': [
    SpecialtyCategory('General Physician'),
    SpecialtyCategory('Doctor Home Visit', isService: true),
    SpecialtyCategory('Family Physician'),
    SpecialtyCategory('Internal Medicine Specialist'),
  ],
  'Ophthalmologist': [
    SpecialtyCategory('Ophthalmologist'),
    SpecialtyCategory('Eye Check-up', isService: true),
    SpecialtyCategory('Cataract Surgeon'),
    SpecialtyCategory('Retina Specialist'),
    SpecialtyCategory('Glaucoma Specialist'),
    SpecialtyCategory('Pediatric Ophthalmologist'),
  ],
};

List<SpecialtyCategory> specialtyCategoriesFor(String specialty) =>
    _specialtyCategories[specialty] ?? [SpecialtyCategory(specialty)];

const int _sampleDoctorsPerZone = 5;

const List<String> _sampleZones = [
  'Dadar',
  'Andheri',
  'Borivali',
  'Ghatkopar',
  'Mulund',
  'Chembur',
  'Malad',
  'Kandivali',
];

const List<String> _sampleDoctorNames = [
  'Rajesh Maheshwari', 'Priya Rathi', 'Amit Daga', 'Sneha Mundra', 'Vikram Somani',
  'Meera Bang', 'Anil Lahoti', 'Sunita Kabra', 'Kiran Malpani', 'Nikhil Bhattad',
  'Pooja Jajoo', 'Suresh Baheti', 'Kavita Biyani', 'Manish Toshniwal', 'Ritu Chandak',
  'Ashok Sarda', 'Neha Karwa', 'Deepak Laddha', 'Swati Mantri', 'Gopal Taparia',
  'Anjali Darak', 'Ramesh Bajaj', 'Shweta Mohta', 'Prakash Kalantri', 'Rekha Jhawar',
  'Sanjay Malani', 'Divya Agiwal', 'Mahesh Dhoot', 'Komal Inani', 'Vinod Navandar',
  'Aarti Zanwar', 'Harish Lohiya', 'Bhavna Randad', 'Sachin Totla', 'Nisha Pasari',
  'Girish Kothari', 'Seema Chitlangia', 'Arvind Bhutada', 'Payal Soni', 'Naresh Bhangadia',
];

const List<String> _sampleRoads = [
  'Station Road', 'MG Road', 'Link Road', 'LBS Marg', 'SV Road',
  'Gokhale Road', 'Ranade Road', 'Linking Road',
];

const Map<String, String> _sampleClinicSuffix = {
  'Cardiologist': 'Heart Care',
  'Dermatologist': 'Skin Clinic',
  'Neurologist': 'Neuro Centre',
  'Pediatrician': 'Child Clinic',
  'Orthopedic': 'Bone & Joint Centre',
  'Gynecologist': 'Women\'s Clinic',
  'General Physician': 'Family Clinic',
  'Ophthalmologist': 'Eye Care',
};

/// Sample data until the doctors API is ready: [_sampleDoctorsPerZone] doctors
/// in every zone, rotating through the specialties and their categories.
List<Doctor> buildSampleDoctors() {
  final specialties = _specialtyCategories.keys.toList();
  final doctors = <Doctor>[];

  for (var z = 0; z < _sampleZones.length; z++) {
    final zone = _sampleZones[z];
    for (var j = 0; j < _sampleDoctorsPerZone; j++) {
      final i = z * _sampleDoctorsPerZone + j;
      final specialty = specialties[i % specialties.length];
      final categories = specialtyCategoriesFor(specialty);
      final occurrence = i ~/ specialties.length;
      final category = categories[(occurrence + z) % categories.length].name;
      final fullName = _sampleDoctorNames[i % _sampleDoctorNames.length];
      final surname = fullName.split(' ').last;
      final digits = (9820010000 + i * 137913).toString();

      doctors.add(Doctor(
        name: 'Dr. $fullName',
        specialty: specialty,
        category: category == specialty ? null : category,
        mobileNumber: '+91 ${digits.substring(0, 5)} ${digits.substring(5)}',
        imageUrl: '',
        email: '${fullName.toLowerCase().replaceAll(' ', '.')}@example.com',
        experience: '${6 + (i * 7) % 20} years',
        clinicName: '$surname ${_sampleClinicSuffix[specialty] ?? 'Clinic'}',
        address: '${12 + i * 3}, ${_sampleRoads[i % _sampleRoads.length]}, $zone, Mumbai',
        zone: zone,
      ));
    }
  }
  return doctors;
}

class _AreaSelection {
  final bool all;
  final Set<String> areas;

  const _AreaSelection({required this.all, required this.areas});
}

class _AreaPickerSheet extends StatefulWidget {
  final List<String> areas;
  final String memberZone;
  final bool allSelected;
  final Set<String> selectedAreas;
  final int totalDoctors;
  final int Function(String area) doctorCount;

  const _AreaPickerSheet({
    required this.areas,
    required this.memberZone,
    required this.allSelected,
    required this.selectedAreas,
    required this.totalDoctors,
    required this.doctorCount,
  });

  @override
  State<_AreaPickerSheet> createState() => _AreaPickerSheetState();
}

class _AreaPickerSheetState extends State<_AreaPickerSheet> {
  late bool _all;
  late final Set<String> _picked;

  @override
  void initState() {
    super.initState();
    _all = widget.allSelected;
    _picked = _all ? <String>{} : Set<String>.from(widget.selectedAreas);
  }

  void _toggleAll() {
    setState(() {
      _all = !_all;
      if (_all) _picked.clear();
    });
  }

  void _toggleArea(String area) {
    setState(() {
      _all = false;
      if (_picked.contains(area)) {
        _picked.remove(area);
      } else {
        _picked.add(area);
      }
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      _AreaSelection(all: _all, areas: Set<String>.from(_picked)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);
    final member = widget.memberZone.trim().toLowerCase();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select geographical area',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2430),
                  ),
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                children: [
                  _areaTile(
                    themeColor: themeColor,
                    icon: Icons.public,
                    title: 'All',
                    subtitle: widget.totalDoctors == 1
                        ? '1 doctor'
                        : '${widget.totalDoctors} doctors',
                    selected: _all,
                    onTap: _toggleAll,
                  ),
                  ...widget.areas.map((area) {
                    final isMember = member.isNotEmpty && area.toLowerCase() == member;
                    final count = widget.doctorCount(area);
                    return _areaTile(
                      themeColor: themeColor,
                      icon: isMember ? Icons.my_location : Icons.location_on_outlined,
                      title: isMember ? '$area (Your zone)' : area,
                      subtitle: count == 1 ? '1 doctor' : '$count doctors',
                      selected: !_all && _picked.contains(area),
                      onTap: () => _toggleArea(area),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _apply,
                  style: FilledButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _areaTile({
    required Color themeColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selected: selected,
      selectedTileColor: themeColor.withValues(alpha: 0.08),
      leading: Icon(
        icon,
        color: selected ? themeColor : const Color(0xFF8A9099),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: const Color(0xFF1F2430),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF8A9099)),
      ),
      trailing: Icon(
        selected ? Icons.check_box : Icons.check_box_outline_blank,
        color: selected ? themeColor : const Color(0xFFB6BBC3),
      ),
      onTap: onTap,
    );
  }
}
