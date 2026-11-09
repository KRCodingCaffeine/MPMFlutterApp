import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/model/AddDoctor/AddDoctorModel.dart';
import 'package:mpm/model/DoctorList/DoctorListModel.dart';
import 'package:mpm/model/CountryModel/CountryData.dart';
import 'package:mpm/model/CountryModel/CountryModelClass.dart';
import 'package:mpm/model/State/StateData.dart';
import 'package:mpm/model/State/StateModelClass.dart';
import 'package:mpm/model/OccupationSpec/OccuptionSpecData.dart';
import 'package:mpm/model/OccuptionSpecSubSubCategory/OccuptionSpecSubSubCategoryData.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/model/city/CityModelClass.dart';
import 'package:mpm/model/search/SearchData.dart';
import 'package:mpm/repository/add_doctor_repository/add_doctor_repo.dart';
import 'package:mpm/repository/doctor_list_repository/doctor_list_repo.dart';
import 'package:mpm/repository/register_repository/register_repo.dart';
import 'package:mpm/repository/update_repository/UpdateProfileRepository.dart';
import 'package:mpm/repository/zone_repository/zone_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/Utility/add_doctor_choice_view.dart';
import 'package:mpm/view/Utility/specialty_doctors_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UtilityView extends StatefulWidget {
  const UtilityView({super.key});

  @override
  State<UtilityView> createState() => _UtilityViewState();
}

class _UtilityViewState extends State<UtilityView> {
  List<Doctor> _allDoctors = [];
  List<Doctor> _recentDoctors = [];
  List<String> _zones = [];
  Set<String> _savedDoctors = {};
  int _selectedTabIndex = 0;
  bool _isDoctorsLoading = true;
  String? _doctorsError;
  final DoctorListRepository _doctorListRepository = DoctorListRepository();

  List<String> getAvailableSpecialties() {
    final specialties = _allDoctors
        .map((doctor) => doctor.specialty.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
    return specialties;
  }

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _loadZones();
  }

  Future<void> _loadDoctors() async {
    try {
      final rows = await _doctorListRepository.getAllDoctors();
      final doctors = rows.expand(_doctorsFromApi).toList();
      if (!mounted) return;
      setState(() {
        _allDoctors = doctors;
        _isDoctorsLoading = false;
        _doctorsError = doctors.isEmpty ? 'No doctors found' : null;
      });
    } catch (e) {
      debugPrint('❌ Error loading doctors: $e');
      if (!mounted) return;
      setState(() {
        _isDoctorsLoading = false;
        _doctorsError = 'Unable to load doctors';
      });
    }
  }

  List<Doctor> _doctorsFromApi(DoctorListData item) {
    final occupations = item.occupationList;
    if (occupations.isEmpty) {
      return [_mapDoctor(item, null)];
    }
    return occupations.map((occupation) => _mapDoctor(item, occupation)).toList();
  }

  Doctor _mapDoctor(DoctorListData item, DoctorListOccupation? occupation) {
    final addresses = item.addresses ?? [];
    final office = addresses.cast<DoctorListAddress?>().firstWhere(
          (address) => (address?.addressType ?? '').toLowerCase() == 'office',
          orElse: () => null,
        );
    final home = addresses.cast<DoctorListAddress?>().firstWhere(
          (address) => (address?.addressType ?? '').toLowerCase() == 'home',
          orElse: () => null,
        );
    final clinic = office ?? (addresses.isNotEmpty ? addresses.first : null);
    final location = clinic ?? home;

    final specialty = _cleanDoctorText(occupation?.specializationName);
    final category = _cleanDoctorText(occupation?.specializationSubCategoryName);
    final subCategory = _cleanDoctorText(occupation?.specializationSubSubCategoryName);
    final categoryName = category.isNotEmpty
        ? category
        : (subCategory.isNotEmpty ? subCategory : '');

    return Doctor(
      name: _doctorName(item),
      specialty: specialty,
      category: categoryName.isEmpty || categoryName == specialty ? null : categoryName,
      mobileNumber: _cleanDoctorText(item.mobile),
      imageUrl: _cleanDoctorText(item.profileImage),
      email: _cleanDoctorText(item.email),
      experience: _cleanDoctorText(occupation?.occupationOtherName),
      clinicName: _cleanDoctorText(office?.clinicName),
      address: _doctorAddress(location),
      zone: _cleanDoctorText(location?.zoneName),
    );
  }

  String _doctorName(DoctorListData item) {
    final fullName = _cleanDoctorText(item.fullName);
    if (fullName.isNotEmpty) return fullName;
    return [
      item.firstName,
      item.middleName,
      item.lastName,
    ].map(_cleanDoctorText).where((part) => part.isNotEmpty && part != '-').join(' ');
  }

  String _doctorAddress(DoctorListAddress? address) {
    if (address == null) return '';
    return [
      address.flatNo,
      address.address,
      address.areaName,
      address.cityName,
      address.pincode,
    ].map(_cleanDoctorText).where((part) => part.isNotEmpty).join(', ');
  }

  String _cleanDoctorText(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty || text.toLowerCase() == 'null' || text == '-') return '';
    return text;
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
        title: Text(
          'Doctors(${_allDoctors.length})',
          style: const TextStyle(
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

  bool _sameSpecialty(String doctorSpecialty, String selectedSpecialty) {
    return doctorSpecialty.trim().toLowerCase() == selectedSpecialty.trim().toLowerCase();
  }

  int _specialtyCount(String specialty) {
    return _allDoctors.where((doctor) => _sameSpecialty(doctor.specialty, specialty)).length;
  }

  void _openSpecialty(String specialty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpecialtyDoctorsView(
          specialty: specialty,
          doctors: _allDoctors
              .where((doctor) => _sameSpecialty(doctor.specialty, specialty))
              .toList(),
          zones: _availableAreas(),
          onDoctorsFound: _rememberSearchedDoctors,
        ),
      ),
    );
  }

  void _rememberSearchedDoctors(List<Doctor> doctors) {
    if (!mounted || doctors.isEmpty) return;
    setState(() {
      final next = <Doctor>[];
      final seen = <String>{};
      for (final doctor in [...doctors, ..._recentDoctors]) {
        final key = '${doctor.name}|${doctor.mobileNumber}';
        if (seen.add(key)) next.add(doctor);
      }
      _recentDoctors = next.take(15).toList();
    });
  }

  Widget _buildDiscoverPage(Color themeColor) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildSpecialtySection(themeColor)),
        if (_recentDoctors.isNotEmpty)
          SliverToBoxAdapter(child: _buildRecentDoctors()),
      ],
    );
  }

  Widget _buildRecentDoctors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Recently searched',
          count: '${_recentDoctors.length}',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            children: [
              for (var i = 0; i < _recentDoctors.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _buildDoctorCard(_recentDoctors[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildSpecialtySection(Color themeColor) {
    if (_isDoctorsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final specialties = getAvailableSpecialties()..sort();
    if (specialties.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
        child: Text(
          _doctorsError ?? 'No doctors found',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8A9099),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'Speciality',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2430),
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 0.72,
          ),
          itemCount: specialties.length,
          itemBuilder: (context, index) {
            final name = specialties[index];
            return _buildSpecialtyChip(
              label: name,
              count: _specialtyCount(name),
              selected: false,
              themeColor: themeColor,
              onTap: () => _openSpecialty(name),
            );
          },
        ),
      ],
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
                          if (doctor.zone.trim().isNotEmpty ||
                              doctor.experience.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 14, color: Color(0xFF8A9099)),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    [
                                      if (doctor.zone.trim().isNotEmpty) doctor.zone,
                                      if (doctor.experience.trim().isNotEmpty)
                                        doctor.experience,
                                    ].join('  ·  '),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddDoctorChoiceView(
                              onAddDoctor: _showAddDoctorBottomSheet,
                            ),
                          ),
                        );
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
                        'I understand, Submit',
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

  void _showAddDoctorBottomSheet(SearchData? member, AddDoctorRepository repository) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddDoctorBottomSheet(
        member: member,
        repository: repository,
      ),
    );
  }
}

class _ClinicAddressEntry {
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController pincode = TextEditingController();
  final TextEditingController flatNo = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController area = TextEditingController();
  String? cityId;
  String? stateId;
  String? countryId;

  void clearText() {
    name.clear();
    phone.clear();
    pincode.clear();
    flatNo.clear();
    address.clear();
    area.clear();
    cityId = null;
    stateId = null;
    countryId = null;
  }

  void dispose() {
    name.dispose();
    phone.dispose();
    pincode.dispose();
    flatNo.dispose();
    address.dispose();
    area.dispose();
  }
}

class _AffiliationEntry {
  final TextEditingController narration = TextEditingController();

  void dispose() => narration.dispose();
}

class AddDoctorBottomSheet extends StatefulWidget {
  final SearchData? member;
  final AddDoctorRepository repository;

  const AddDoctorBottomSheet({
    super.key,
    this.member,
    required this.repository,
  });

  @override
  State<AddDoctorBottomSheet> createState() => _AddDoctorBottomSheetState();
}

class _AddDoctorBottomSheetState extends State<AddDoctorBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _registerRepo = RegisterRepository();
  final _profileRepo = UpdateProfileRepository();
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

  static const int _maxClinics = 5;

  final List<_ClinicAddressEntry> _clinics = [_ClinicAddressEntry()];
  final List<_AffiliationEntry> _affiliations = [_AffiliationEntry()];

  bool _isLocationLoading = true;
  List<CountryData> _countries = [];
  List<StateData> _states = [];
  List<CityData> _cities = [];

  bool _isSubmitting = false;
  bool _isSpecLoading = true;
  String? _specError;
  List<OccuptionSpecData> _specializations = [];
  String? _fieldId;
  bool _isSubSubLoading = false;
  String? _subSubError;
  List<OccuptionSpecSubSubCategoryData> _subSubCategories = [];
  String? _specialityId;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    if (member != null) {
      _firstNameController.text = _memberText(member.firstName);
      _middleNameController.text = _memberText(member.middleName);
      _surnameController.text = _memberText(member.lastName);
      _mobileController.text = _memberText(member.mobile);
      _emailController.text = _memberText(member.email);
    }
    _loadLocations();
    _loadDoctorSpecializations();
  }

  String _memberText(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
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
    for (final clinic in _clinics) {
      clinic.dispose();
    }
    for (final affiliation in _affiliations) {
      affiliation.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDoctorSpecializations() async {
    try {
      final occupations = await _profileRepo.userOccupationDataApi();
      String? professionId;

      for (final occupation in occupations.data ?? []) {
        final id = occupation.id?.toString() ?? '';
        if (id.isEmpty) continue;
        try {
          final professions = await _profileRepo.userOccutionPreCodeApi({
            'occupation_id': id,
          });
          final doctor = (professions.data ?? []).firstWhereOrNull(
            (item) => (item.name ?? '').trim().toLowerCase() == 'doctor',
          );
          if (doctor != null && (doctor.id ?? '').toString().isNotEmpty) {
            professionId = doctor.id.toString();
            break;
          }
        } catch (e) {
          debugPrint('Occupation $id has no doctor profession: $e');
        }
      }

      List<OccuptionSpecData> specs = [];
      if (professionId != null) {
        final response = await _profileRepo.userOccutionSpectionCodeApi({
          'occupation_profession_id': professionId,
        });
        specs = (response.data ?? [])
            .where((item) => (item.id ?? '').toString().trim().isNotEmpty)
            .toList();
        specs.sort(
          (a, b) => (a.name ?? '')
              .toLowerCase()
              .compareTo((b.name ?? '').toLowerCase()),
        );
      }

      if (!mounted) return;
      setState(() {
        _specializations = specs;
        _isSpecLoading = false;
        _specError = specs.isEmpty ? 'Field list is unavailable.' : null;
      });
    } catch (e) {
      debugPrint('❌ Error loading doctor specialities: $e');
      if (!mounted) return;
      setState(() {
        _isSpecLoading = false;
        _specError = 'Unable to load field.';
      });
    }
  }

  Future<void> _loadSubSubCategories(String specializationId) async {
    setState(() {
      _isSubSubLoading = true;
      _subSubError = null;
      _subSubCategories = [];
      _specialityId = null;
    });

    try {
      final subCategories = await _profileRepo
          .userOccutionSpectionSubCategoryApi(specializationId);
      final subCategoryIds = (subCategories.data ?? [])
          .map((item) => item.specializationSubCategoryId?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      final responses = await Future.wait(
        subCategoryIds.map((subCategoryId) async {
          try {
            return await _profileRepo
                .userOccutionSpecializationSubSubCategoryApi(subCategoryId);
          } catch (e) {
            debugPrint('No sub-sub category for $subCategoryId: $e');
            return null;
          }
        }),
      );

      final items = <OccuptionSpecSubSubCategoryData>[];
      for (final response in responses) {
        items.addAll(response?.data ?? []);
      }
      items.sort(
        (a, b) => (a.subSubCategoryName ?? '')
            .toLowerCase()
            .compareTo((b.subSubCategoryName ?? '').toLowerCase()),
      );

      if (!mounted || _fieldId != specializationId) return;
      setState(() {
        _subSubCategories = items;
        _isSubSubLoading = false;
        _subSubError = items.isEmpty ? 'No speciality for this field.' : null;
      });
    } catch (e) {
      debugPrint('No sub category for specialization $specializationId: $e');
      if (!mounted || _fieldId != specializationId) return;
      setState(() {
        _subSubCategories = [];
        _isSubSubLoading = false;
        _subSubError = 'No speciality for this field.';
      });
    }
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
        for (final clinic in _clinics) {
          _applyDefaultLocation(clinic);
        }
      });
    } catch (e) {
      debugPrint('❌ Error loading locations: $e');
      if (!mounted) return;
      setState(() => _isLocationLoading = false);
    }
  }

  void _applyDefaultLocation(_ClinicAddressEntry clinic) {
    final india = _countries.firstWhereOrNull(
      (country) => (country.countryName ?? '').trim().toLowerCase() == 'india',
    );
    final maharashtra = _states.firstWhereOrNull((state) {
      final name = (state.stateName ?? '').trim().toLowerCase();
      return name == 'maharashtra' || name == 'maharastra' || name == 'mahastra';
    });
    clinic.countryId ??= india?.id ?? maharashtra?.countryId;
    if (maharashtra != null &&
        (clinic.countryId == null || maharashtra.countryId == clinic.countryId)) {
      clinic.stateId ??= maharashtra.id;
      clinic.countryId ??= maharashtra.countryId;
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

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    final selectedField = _specializations.firstWhereOrNull(
      (item) => item.id?.toString() == _fieldId,
    );
    final occupationId = AddDoctorRequest.parseId(selectedField?.occupationId);
    final professionId = AddDoctorRequest.parseId(selectedField?.occupationProfessionId);
    final specializationId = AddDoctorRequest.parseId(selectedField?.id);
    if (occupationId == null || professionId == null || specializationId == null) {
      _showMessage('Selected field is missing occupation details. Please choose it again.');
      return;
    }

    final addresses = _clinicAddresses();
    if (addresses.isEmpty) {
      _showMessage('Please add a clinic address.');
      return;
    }
    if (addresses.any((address) => address.countryId == null)) {
      _showMessage('Please select a country for each clinic address.');
      return;
    }

    final session = await SessionManager.getSession();
    final createdBy = AddDoctorRequest.parseId(session?.memberId);
    if (!mounted) return;
    if (createdBy == null || createdBy <= 0) {
      _showMessage('Login session expired. Please login again.');
      return;
    }

    final speciality = _subSubCategories.firstWhereOrNull(
      (item) => item.subSubCategoryId?.toString() == _specialityId,
    );
    final memberId = AddDoctorRequest.parseId(widget.member?.memberId);
    final request = AddDoctorRequest(
      firstName: _firstNameController.text.trim(),
      middleName: AddDoctorRequest.emptyToNull(_middleNameController.text),
      lastName: _surnameController.text.trim(),
      mobile: AddDoctorRequest.emptyToNull(_mobileController.text),
      email: AddDoctorRequest.emptyToNull(_emailController.text),
      createdBy: createdBy,
      memberId: memberId,
      occupations: [
        AddDoctorOccupation(
          occupationId: occupationId,
          occupationProfessionId: professionId,
          occupationSpecializationId: specializationId,
          occupationSpecializationSubCategoryId:
              AddDoctorRequest.parseId(speciality?.subCategoryId),
          occupationSpecializationSubSubCategoryId:
              AddDoctorRequest.parseId(_specialityId),
        ),
      ],
      addresses: addresses,
    );

    setState(() => _isSubmitting = true);
    try {
      final response = await widget.repository.addDoctor(request);
      if (!mounted) return;
      if (response.status != true) {
        setState(() => _isSubmitting = false);
        _showMessage(response.message ?? 'Unable to add doctor.');
        return;
      }

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            response.message ??
                'Doctor details submitted. Mandal office will review and make it live.',
          ),
          backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showMessage(_errorMessage(e));
    }
  }

  List<AddDoctorAddress> _clinicAddresses() {
    final addresses = <AddDoctorAddress>[];
    for (final clinic in _clinics) {
      final clinicName = AddDoctorRequest.emptyToNull(clinic.name.text);
      final clinicPhone = AddDoctorRequest.emptyToNull(clinic.phone.text);
      final flatNo = AddDoctorRequest.emptyToNull(clinic.flatNo.text);
      final address = AddDoctorRequest.emptyToNull(clinic.address.text);
      final areaName = AddDoctorRequest.emptyToNull(clinic.area.text);
      final pincode = AddDoctorRequest.parseId(clinic.pincode.text);
      final hasDetails = clinicName != null ||
          clinicPhone != null ||
          flatNo != null ||
          address != null ||
          areaName != null ||
          pincode != null;
      if (!hasDetails) continue;

      addresses.add(
        AddDoctorAddress(
          addressType: 'office',
          clinicName: clinicName,
          clinicPhone: clinicPhone,
          flatNo: flatNo,
          address: address,
          areaName: areaName,
          cityId: AddDoctorRequest.parseId(clinic.cityId),
          stateId: AddDoctorRequest.parseId(clinic.stateId),
          countryId: AddDoctorRequest.parseId(clinic.countryId),
          pincode: pincode,
        ),
      );
    }
    return addresses;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
      ),
    );
  }

  String _errorMessage(Object error) {
    final text = error.toString();
    final start = text.indexOf('{');
    if (start >= 0) {
      try {
        final decoded = jsonDecode(text.substring(start));
        if (decoded is Map) {
          final errors = decoded['errors'];
          if (errors is Map && errors.isNotEmpty) {
            return errors.values.first.toString();
          }
          if (decoded['message'] != null) {
            return decoded['message'].toString();
          }
        }
      } catch (_) {}
    }
    return 'Unable to add doctor. Please try again.';
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
    String keyPrefix = '',
    bool? loading,
    String? Function(String?)? validator,
  }) {
    final isLoading = loading ?? _isLocationLoading;
    // Drop the selection if it is not in the current (filtered) list
    final selected =
        items.any((item) => item.value == value) ? value : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        key: ValueKey('$keyPrefix-$label-$selected-${items.length}'),
        initialValue: selected,
        isExpanded: true,
        items: items,
        onChanged: isLoading ? null : onChanged,
        validator: validator,
        menuMaxHeight: 350,
        decoration: _inputDecoration(label, icon).copyWith(
          suffixIcon: isLoading
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

  List<DropdownMenuItem<String>> _specializationItems() {
    final seen = <String>{};
    final items = <DropdownMenuItem<String>>[];
    for (final spec in _specializations) {
      final id = spec.id?.toString() ?? '';
      final name = (spec.name ?? '').trim();
      if (id.isEmpty || name.isEmpty || !seen.add(id)) continue;
      items.add(
        DropdownMenuItem<String>(
          value: id,
          child: Text(name, overflow: TextOverflow.ellipsis),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<String>> _subSubCategoryItems() {
    final seen = <String>{};
    final items = <DropdownMenuItem<String>>[];
    for (final item in _subSubCategories) {
      final id = item.subSubCategoryId?.toString() ?? '';
      final name = (item.subSubCategoryName ?? '').trim();
      if (id.isEmpty || name.isEmpty || !seen.add(id)) continue;
      items.add(
        DropdownMenuItem<String>(
          value: id,
          child: Text(name, overflow: TextOverflow.ellipsis),
        ),
      );
    }
    return items;
  }

  Widget _buildSubSubCategoryDropdown() {
    const label = 'Speciality *';
    const icon = Icons.local_hospital_outlined;

    if (_fieldId == null) {
      return const SizedBox.shrink();
    }

    if (_isSubSubLoading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: InputDecorator(
          decoration: _inputDecoration(label, icon).copyWith(
            suffixIcon: const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          child: Text(
            'Loading...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      );
    }

    if (_subSubCategories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: InputDecorator(
          decoration: _inputDecoration(label, icon),
          child: Text(
            _subSubError ?? 'No speciality for this field.',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      );
    }

    return _buildDropdown(
      label: label,
      icon: icon,
      keyPrefix: 'sub-sub-$_fieldId',
      value: _specialityId,
      loading: false,
      items: _subSubCategoryItems(),
      validator: (selected) {
        if (selected == null || selected.trim().isEmpty) {
          return 'Please select speciality';
        }
        return null;
      },
      onChanged: (value) => setState(() => _specialityId = value),
    );
  }

  Widget _buildSpecializationDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required ValueChanged<String?> onChanged,
    required String requiredMessage,
  }) {
    if (_isSpecLoading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: InputDecorator(
          decoration: _inputDecoration(label, icon).copyWith(
            suffixIcon: const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          child: Text(
            'Loading...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      );
    }

    if (_specializations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: InputDecorator(
          decoration: _inputDecoration(label, icon),
          child: Text(
            _specError ?? 'No options available',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      );
    }

    return _buildDropdown(
      label: label,
      icon: icon,
      keyPrefix: 'spec',
      value: value,
      loading: false,
      items: _specializationItems(),
      validator: (selected) {
        if (selected == null || selected.trim().isEmpty) return requiredMessage;
        return null;
      },
      onChanged: onChanged,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, {VoidCallback? onRemove}) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: themeColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              visualDensity: VisualDensity.compact,
              tooltip: 'Remove',
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            ),
        ],
      ),
    );
  }

  void _addClinic() {
    if (_clinics.length >= _maxClinics) return;
    final clinic = _ClinicAddressEntry();
    _applyDefaultLocation(clinic);
    setState(() => _clinics.add(clinic));
  }

  void _removeClinic(int index) {
    if (_clinics.length == 1) {
      setState(() {
        _clinics.first.clearText();
        _applyDefaultLocation(_clinics.first);
      });
      return;
    }
    final clinic = _clinics[index];
    setState(() => _clinics.removeAt(index));
    WidgetsBinding.instance.addPostFrameCallback((_) => clinic.dispose());
  }

  void _addAffiliation() {
    setState(() => _affiliations.add(_AffiliationEntry()));
  }

  void _removeAffiliation(int index) {
    if (_affiliations.length == 1) {
      setState(() => _affiliations.first.narration.clear());
      return;
    }
    final entry = _affiliations[index];
    setState(() => _affiliations.removeAt(index));
    WidgetsBinding.instance.addPostFrameCallback((_) => entry.dispose());
  }

  Widget _buildClinicAddress(int index) {
    final clinic = _clinics[index];
    final title = _clinics.length == 1
        ? 'Clinic Address'
        : 'Clinic Address ${index + 1}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(
          title,
          Icons.local_hospital_outlined,
          onRemove: () => _removeClinic(index),
        ),
        _buildTextField(
          controller: clinic.name,
          label: 'Clinic / Hospital Name',
          icon: Icons.local_hospital_outlined,
        ),
        _buildTextField(
          controller: clinic.phone,
          label: 'Clinic Phone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          maxLength: 12,
        ),
        _buildTextField(
          controller: clinic.pincode,
          label: 'Pincode',
          icon: Icons.pin_drop_outlined,
          keyboardType: TextInputType.number,
          maxLength: 6,
          validator: _pincodeValidator,
        ),
        _buildTextField(
          controller: clinic.flatNo,
          label: 'Flat / Office No',
          icon: Icons.business_outlined,
        ),
        _buildTextField(
          controller: clinic.address,
          label: 'Clinic Address',
          icon: Icons.location_on_outlined,
          maxLines: 2,
        ),
        _buildTextField(
          controller: clinic.area,
          label: 'Area / Locality',
          icon: Icons.signpost_outlined,
        ),
        ..._buildLocationDropdowns(
          keyPrefix: 'clinic-$index',
          cityId: clinic.cityId,
          stateId: clinic.stateId,
          countryId: clinic.countryId,
          onChanged: (cityId, stateId, countryId) {
            setState(() {
              clinic.cityId = cityId;
              clinic.stateId = stateId;
              clinic.countryId = countryId;
            });
          },
        ),
      ],
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
    String keyPrefix = '',
  }) {
    final cities = _citiesFor(stateId, countryId);
    final states = _statesFor(countryId);

    return [
      _buildDropdown(
        label: 'City',
        icon: Icons.location_city_outlined,
        keyPrefix: keyPrefix,
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
        keyPrefix: keyPrefix,
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
        keyPrefix: keyPrefix,
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

                      _buildSectionTitle('Field & Speciality', Icons.medical_services_outlined),
                      _buildSpecializationDropdown(
                        label: 'Field *',
                        icon: Icons.category_outlined,
                        value: _fieldId,
                        requiredMessage: 'Please select field',
                        onChanged: (value) {
                          if (value == null || value == _fieldId) return;
                          setState(() => _fieldId = value);
                          _loadSubSubCategories(value);
                        },
                      ),
                      _buildSubSubCategoryDropdown(),

                      _buildSectionTitle('Doctor affiliated with', Icons.account_balance_outlined),
                      for (var i = 0; i < _affiliations.length; i++) ...[
                        if (_affiliations.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Text(
                                  'Narration ${i + 1}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4B5160),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => _removeAffiliation(i),
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Remove',
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                ),
                              ],
                            ),
                          ),
                        _buildTextField(
                          controller: _affiliations[i].narration,
                          label: 'Narration',
                          icon: Icons.notes_outlined,
                          maxLines: 3,
                        ),
                      ],
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _addAffiliation,
                          icon: Icon(Icons.add, color: themeColor),
                          label: Text(
                            'Add affiliated with',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeColor,
                            ),
                          ),
                        ),
                      ),

                      for (var i = 0; i < _clinics.length; i++) _buildClinicAddress(i),
                      if (_clinics.length < _maxClinics)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _addClinic,
                            icon: Icon(Icons.add, color: themeColor),
                            label: Text(
                              'Add clinic address',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: themeColor,
                              ),
                            ),
                          ),
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
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
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

