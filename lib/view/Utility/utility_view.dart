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
  String? _selectedArea;
  String? _selectedCategory;
  List<String> _zones = [];
  Set<String> _savedDoctors = {};
  int _selectedTabIndex = 0;

  bool get _hasSearch => _searchController.text.trim().isNotEmpty;

  // Doctors are listed only once the member searches or picks a speciality
  bool get _hasActiveQuery => _hasSearch || _selectedSpecialty != null;

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

  // Zones from the API plus any zone a doctor is listed in, de-duplicated
  List<String> _availableAreas() {
    final areas = <String, String>{};
    for (final zone in [..._zones, ..._allDoctors.map((d) => d.zone)]) {
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

  List<Doctor> _visibleDoctors() {
    if (!_hasActiveQuery) return [];
    final query = _searchController.text.trim().toLowerCase();

    return _allDoctors.where((doctor) {
      final matchesSpecialty = _selectedSpecialty == null ||
          doctor.specialty == _selectedSpecialty;
      final matchesArea =
          _selectedArea == null || _sameZone(doctor.zone, _selectedArea!);
      final matchesCategory = _selectedCategory == null ||
          doctor.categoryName == _selectedCategory;
      return _matchesSearch(doctor, query) &&
          matchesSpecialty &&
          matchesArea &&
          matchesCategory;
    }).toList();
  }

  String get _listTitle {
    if (_hasSearch) return 'Search results';
    if (_selectedSpecialty != null) {
      return _selectedCategory ?? _selectedSpecialty!;
    }
    return 'Doctors';
  }

  void _clearSearch() {
    _searchController.clear();
    _selectedSpecialty = null;
    _selectedArea = null;
    _selectedCategory = null;
    setState(() {});
  }

  Future<void> _openSpecialtyFinder(String specialty) async {
    final sameSpecialty = _selectedSpecialty == specialty;
    final result = await showModalBottomSheet<_SpecialtyFinderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SpecialtyFinderSheet(
        specialty: specialty,
        icon: _specialtyIcon(specialty),
        doctors: _allDoctors.where((d) => d.specialty == specialty).toList(),
        areas: _availableAreas(),
        memberZone: _memberZone,
        categories: specialtyCategoriesFor(specialty),
        initialArea: sameSpecialty ? _selectedArea : null,
        initialCategory: sameSpecialty ? _selectedCategory : null,
        isActive: sameSpecialty,
        matchesArea: _sameZone,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _selectedSpecialty = specialty;
      _selectedArea = result.area;
      _selectedCategory = result.category;
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
              'Add',
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

  Widget _buildDiscoverPage(Color themeColor) {
    final doctors = _visibleDoctors();
    final countLabel =
        '${doctors.length} ${doctors.length == 1 ? 'doctor' : 'doctors'}';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildSearchBar(themeColor)),
        SliverToBoxAdapter(child: _buildSpecialtySection(themeColor)),
        if (!_hasActiveQuery)
          SliverToBoxAdapter(child: _buildFinderInstructions(themeColor))
        else ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader(title: _listTitle, count: countLabel),
          ),
          if (doctors.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(
                icon: Icons.search_off,
                title: 'No doctors found',
                message: _selectedSpecialty != null && !_hasSearch
                    ? 'No $_listTitle is listed in ${_selectedArea ?? 'any area'} yet. Try another area or category.'
                    : 'Try another name, mobile number, or speciality.',
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
    );
  }

  // Shown in place of the doctor list until the member searches or picks a speciality
  Widget _buildFinderInstructions(Color themeColor) {
    const steps = [
      (
        Icons.search,
        'Search directly',
        'Type a doctor\'s name or mobile number in the search bar above.',
      ),
      (
        Icons.medical_services_outlined,
        'Pick a speciality',
        'Tap a speciality above, or "View more" to see the full list.',
      ),
      (
        Icons.location_on_outlined,
        'Select your area',
        'Choose the geographical area you want to find a doctor in.',
      ),
      (
        Icons.category_outlined,
        'Choose a category',
        'Narrow it down, e.g. Interventional or Pediatric Cardiologist.',
      ),
    ];

    final stats = [
      ('${_allDoctors.length}', 'Doctors'),
      ('${_availableAreas().length}', 'Areas'),
      ('${getAvailableSpecialties().length}', 'Specialities'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E8EC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeColor.withValues(alpha: 0.10),
                    themeColor.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_hospital_outlined, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find a doctor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2430),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Doctors from our community, a call away.',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF5B6270)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  for (var i = 0; i < stats.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              stats[i].$1,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: themeColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stats[i].$2,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF8A9099)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(
                'HOW IT WORKS',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8A9099),
                ),
              ),
            ),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF1F2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: themeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(steps[i].$1, size: 15, color: const Color(0xFF1F2430)),
                              const SizedBox(width: 6),
                              Text(
                                steps[i].$2,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2430),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            steps[i].$3,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: Color(0xFF5B6270),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF7F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.call, size: 18, color: Color(0xFF2E7D4F)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tap Call on a doctor\'s card to ring them directly, or Share profile to send their details to family.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: Color(0xFF2E5A3E),
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
                  'Speciality',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2430),
                  ),
                ),
              ),
              if (_selectedSpecialty != null || _hasSearch) ...[
                GestureDetector(
                  onTap: _clearSearch,
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
                        selected: _selectedSpecialty == name,
                        themeColor: themeColor,
                        onTap: () => _openSpecialtyFinder(name),
                      ),
                    ))
                .toList(),
          ),
        ),
        if (_selectedSpecialty != null) _buildActiveFilters(themeColor),
        const SizedBox(height: 8),
      ],
    );
  }

  // Area and category picked in the finder; tapping either reopens it
  Widget _buildActiveFilters(Color themeColor) {
    Widget filterChip(IconData icon, String label) {
      return Flexible(
        child: Material(
          color: Colors.white,
          shape: StadiumBorder(
            side: BorderSide(color: themeColor.withValues(alpha: 0.35)),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => _openSpecialtyFinder(_selectedSpecialty!),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 15, color: themeColor),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2430),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more, size: 16, color: Color(0xFF8A9099)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          filterChip(Icons.location_on_outlined, _selectedArea ?? 'All areas'),
          const SizedBox(width: 8),
          filterChip(
            Icons.category_outlined,
            _selectedCategory ?? 'All categories',
          ),
        ],
      ),
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
                        'All Specialities',
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
                        selected: _selectedSpecialty == name,
                        themeColor: themeColor,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _openSpecialtyFinder(name);
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
            Container(
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
            const SizedBox(height: 6),
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
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildCardAction(
                        icon: Icons.call,
                        label: 'Call',
                        color: Colors.white,
                        background: const Color(0xFF2E9E5B),
                        onTap: () => _callDoctor(doctor),
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

class _SpecialtyFinderResult {
  final String? area;
  final String? category;

  const _SpecialtyFinderResult({this.area, this.category});
}

/// Two-step picker shown when a specialty is tapped:
/// 1. choose a geographical area, 2. choose a category within the specialty.
class _SpecialtyFinderSheet extends StatefulWidget {
  final String specialty;
  final IconData icon;
  final List<Doctor> doctors;
  final List<String> areas;
  final String memberZone;
  final List<SpecialtyCategory> categories;
  final String? initialArea;
  final String? initialCategory;
  final bool isActive;
  final bool Function(String doctorZone, String area) matchesArea;

  const _SpecialtyFinderSheet({
    required this.isActive,
    required this.specialty,
    required this.icon,
    required this.doctors,
    required this.areas,
    required this.memberZone,
    required this.categories,
    required this.initialArea,
    required this.initialCategory,
    required this.matchesArea,
  });

  @override
  State<_SpecialtyFinderSheet> createState() => _SpecialtyFinderSheetState();
}

class _SpecialtyFinderSheetState extends State<_SpecialtyFinderSheet> {
  static const _textDark = Color(0xFF1F2430);
  static const _textMuted = Color(0xFF8A9099);
  static const _border = Color(0xFFE6E8EC);

  final TextEditingController _areaSearchController = TextEditingController();
  int _step = 0;
  String? _area;

  Color get _themeColor =>
      ColorHelperClass.getColorFromHex(ColorResources.red_color);

  @override
  void initState() {
    super.initState();
    _area = widget.initialArea;
  }

  @override
  void dispose() {
    _areaSearchController.dispose();
    super.dispose();
  }

  List<Doctor> _doctorsIn(String? area) {
    if (area == null) return widget.doctors;
    return widget.doctors.where((d) => widget.matchesArea(d.zone, area)).toList();
  }

  String _doctorCount(int count) =>
      count == 0 ? 'No doctors yet' : '$count ${count == 1 ? 'doctor' : 'doctors'}';

  String? get _memberArea {
    if (widget.memberZone.isEmpty) return null;
    for (final area in widget.areas) {
      if (area.toLowerCase() == widget.memberZone.toLowerCase()) return area;
    }
    return widget.memberZone;
  }

  void _selectArea(String? area) {
    setState(() {
      _area = area;
      _step = 1;
    });
  }

  void _selectCategory(String? category) {
    Navigator.pop(
      context,
      _SpecialtyFinderResult(area: _area, category: category),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        height: media.size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F8FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(
                    begin: Offset(child.key == const ValueKey(1) ? 0.15 : -0.15, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: _step == 0
                    ? KeyedSubtree(key: const ValueKey(0), child: _buildAreaStep())
                    : KeyedSubtree(key: const ValueKey(1), child: _buildCategoryStep()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: _border)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
      child: Column(
        children: [
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 44,
                child: _step == 1
                    ? IconButton(
                        onPressed: () => setState(() => _step = 0),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        color: _textDark,
                      )
                    : null,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _step == 0 ? 'Select geographical area' : 'Choose a category',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Step ${_step + 1} of 2  ·  ${widget.specialty}',
                      style: const TextStyle(fontSize: 12, color: _textMuted),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 44,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 22),
                  color: _textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: List.generate(2, (index) {
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.only(left: index == 0 ? 0 : 6),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _step ? _themeColor : _border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: _textMuted,
        ),
      ),
    );
  }

  Widget _buildAreaStep() {
    final query = _areaSearchController.text.trim().toLowerCase();
    final memberArea = _memberArea;
    final otherAreas = widget.areas
        .where((area) => area.toLowerCase() != memberArea?.toLowerCase())
        .where((area) => query.isEmpty || area.toLowerCase().contains(query))
        .toList();
    final showMemberArea = memberArea != null &&
        (query.isEmpty || memberArea.toLowerCase().contains(query));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        TextField(
          controller: _areaSearchController,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 14, color: _textDark),
          decoration: InputDecoration(
            hintText: 'Search area or zone',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9AA0A8)),
            prefixIcon: const Icon(Icons.search, color: _textMuted),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _themeColor),
            ),
          ),
        ),
        if (query.isEmpty) ...[
          const SizedBox(height: 14),
          _buildOptionTile(
            icon: Icons.public,
            title: 'All areas',
            subtitle: _doctorCount(widget.doctors.length),
            selected: widget.isActive && _area == null,
            onTap: () => _selectArea(null),
          ),
        ],
        if (showMemberArea) ...[
          _buildSectionLabel('Your area'),
          _buildOptionTile(
            icon: Icons.my_location,
            title: memberArea,
            subtitle: _doctorCount(_doctorsIn(memberArea).length),
            badge: 'Your zone',
            selected: _area == memberArea,
            onTap: () => _selectArea(memberArea),
          ),
        ],
        if (otherAreas.isNotEmpty) _buildSectionLabel('Areas'),
        ...otherAreas.map((area) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildOptionTile(
                icon: Icons.location_on_outlined,
                title: area,
                subtitle: _doctorCount(_doctorsIn(area).length),
                selected: _area == area,
                onTap: () => _selectArea(area),
              ),
            )),
        if (otherAreas.isEmpty && !showMemberArea && query.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                'No matching area found',
                style: TextStyle(fontSize: 13, color: _textMuted),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryStep() {
    final areaDoctors = _doctorsIn(_area);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Summary of what was picked so far
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _themeColor.withValues(alpha: 0.10),
                _themeColor.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _themeColor.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _themeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.specialty,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 13, color: _textMuted),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '${_area ?? 'All areas'}  ·  ${_doctorCount(areaDoctors.length)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: _textMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _step = 0),
                style: TextButton.styleFrom(
                  foregroundColor: _themeColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text(
                  'Change',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        _buildSectionLabel('Categories'),
        _buildOptionTile(
          icon: Icons.grid_view_rounded,
          title: 'All ${widget.specialty} categories',
          subtitle: _doctorCount(areaDoctors.length),
          selected: widget.isActive &&
              widget.initialCategory == null &&
              widget.initialArea == _area,
          onTap: () => _selectCategory(null),
        ),
        const SizedBox(height: 8),
        ...widget.categories.map((category) {
          final count =
              areaDoctors.where((d) => d.categoryName == category.name).length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildOptionTile(
              icon: category.isService
                  ? Icons.support_agent_outlined
                  : Icons.medical_services_outlined,
              title: category.name,
              typeLabel: category.isService ? 'Service' : 'Speciality',
              isService: category.isService,
              subtitle: _doctorCount(count),
              count: count,
              selected: widget.isActive &&
                  widget.initialCategory == category.name &&
                  widget.initialArea == _area,
              onTap: () => _selectCategory(category.name),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    String? badge,
    String? typeLabel,
    bool isService = false,
    int? count,
  }) {
    final dimmed = count == 0;

    return Material(
      color: selected ? _themeColor.withValues(alpha: 0.06) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _themeColor : _border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: dimmed ? const Color(0xFFF1F2F4) : const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: dimmed ? _textMuted : _themeColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (typeLabel != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isService
                                  ? const Color(0xFFE8F1FF)
                                  : const Color(0xFFF1F2F4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              typeLabel.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.5,
                                letterSpacing: 0.6,
                                fontWeight: FontWeight.w700,
                                color: isService
                                    ? const Color(0xFF2F6FDB)
                                    : const Color(0xFF5B6270),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (badge != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _themeColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badge.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9.5,
                                letterSpacing: 0.6,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: _textMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle : Icons.chevron_right,
                size: selected ? 22 : 20,
                color: selected ? _themeColor : const Color(0xFFB6BBC3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}