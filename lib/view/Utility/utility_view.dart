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
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:url_launcher/url_launcher.dart';

class UtilityView extends StatefulWidget {
  const UtilityView({super.key});

  @override
  State<UtilityView> createState() => _UtilityViewState();
}

class _UtilityViewState extends State<UtilityView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _hasSearched = false;
  List<Doctor> _allDoctors = [];
  List<Doctor> _filteredDoctors = [];
  String? _selectedSpecialty;
  Set<String> _savedDoctors = {};
  int _selectedTabIndex = 0;

  // Sample doctor data
  final List<Doctor> sampleDoctors = [
    Doctor(
      name: 'Dr. Rajesh Kumar',
      specialty: 'Cardiologist',
      mobileNumber: '+91 98765 43210',
      imageUrl: '',
      email: 'rajesh.kumar@example.com',
      experience: '15 years',
      clinicName: 'Heart Care Clinic',
      address: '123, Main Road, Mumbai',
    ),
    Doctor(
      name: 'Dr. Priya Sharma',
      specialty: 'Dermatologist',
      mobileNumber: '+91 87654 32109',
      imageUrl: '',
      email: 'priya.sharma@example.com',
      experience: '10 years',
      clinicName: 'Skin Care Center',
      address: '456, Park Street, Delhi',
    ),
    Doctor(
      name: 'Dr. Amit Patel',
      specialty: 'Neurologist',
      mobileNumber: '+91 76543 21098',
      imageUrl: '',
      email: 'amit.patel@example.com',
      experience: '18 years',
      clinicName: 'Neuro Wellness',
      address: '789, Lake Road, Bangalore',
    ),
    Doctor(
      name: 'Dr. Sneha Reddy',
      specialty: 'Pediatrician',
      mobileNumber: '+91 65432 10987',
      imageUrl: '',
      email: 'sneha.reddy@example.com',
      experience: '8 years',
      clinicName: 'Little Care Clinic',
      address: '321, Green Valley, Hyderabad',
    ),
    Doctor(
      name: 'Dr. Vikram Singh',
      specialty: 'Orthopedic',
      mobileNumber: '+91 54321 09876',
      imageUrl: '',
      email: 'vikram.singh@example.com',
      experience: '20 years',
      clinicName: 'Bone & Joint Center',
      address: '654, Hospital Road, Chennai',
    ),
    Doctor(
      name: 'Dr. Meera Iyer',
      specialty: 'Gynecologist',
      mobileNumber: '+91 43210 98765',
      imageUrl: '',
      email: 'meera.iyer@example.com',
      experience: '12 years',
      clinicName: 'Women\'s Health Clinic',
      address: '987, Lake View, Pune',
    ),
    Doctor(
      name: 'Dr. Anil Gupta',
      specialty: 'General Physician',
      mobileNumber: '+91 32109 87654',
      imageUrl: '',
      email: 'anil.gupta@example.com',
      experience: '14 years',
      clinicName: 'Family Health Center',
      address: '147, Gandhi Nagar, Ahmedabad',
    ),
    Doctor(
      name: 'Dr. Sunita Verma',
      specialty: 'Ophthalmologist',
      mobileNumber: '+91 21098 76543',
      imageUrl: '',
      email: 'sunita.verma@example.com',
      experience: '9 years',
      clinicName: 'Eye Care Institute',
      address: '258, Ring Road, Jaipur',
    ),
  ];

  // Available specialties for filter
  List<String> getAvailableSpecialties() {
    final specialties = sampleDoctors.map((d) => d.specialty).toSet().toList();
    return specialties;
  }

  @override
  void initState() {
    super.initState();
    _allDoctors = sampleDoctors;
    _filteredDoctors = sampleDoctors;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        if (query.isEmpty && _selectedSpecialty == null) {
          _filteredDoctors = _allDoctors;
        } else {
          _filteredDoctors = _allDoctors.where((doctor) {
            bool matchesSearch = true;
            bool matchesSpecialty = true;

            if (query.isNotEmpty) {
              final searchTerm = query.toLowerCase();
              matchesSearch = doctor.name.toLowerCase().contains(searchTerm) ||
                  doctor.specialty.toLowerCase().contains(searchTerm) ||
                  doctor.clinicName.toLowerCase().contains(searchTerm);
            }

            if (_selectedSpecialty != null && _selectedSpecialty!.isNotEmpty) {
              matchesSpecialty =
                  doctor.specialty == _selectedSpecialty;
            }

            return matchesSearch && matchesSpecialty;
          }).toList();
        }
        _isLoading = false;
      });
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _selectedSpecialty = null;
      _filteredDoctors = _allDoctors;
      _hasSearched = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedSpecialty = null;
      _filteredDoctors = _allDoctors;
      if (_searchController.text.isNotEmpty) {
        _performSearch(_searchController.text);
      } else {
        _filteredDoctors = _allDoctors;
      }
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

  Future<void> _callDoctor(String mobileNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: mobileNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to make call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareDoctor(Doctor doctor) {
    final String shareText =
        '👨‍⚕️ Doctor: ${doctor.name}\n'
        '🏥 Specialty: ${doctor.specialty}\n'
        '📞 Phone: ${doctor.mobileNumber}\n'
        '📧 Email: ${doctor.email}\n'
        '🏢 Clinic: ${doctor.clinicName}\n'
        '📍 Address: ${doctor.address}\n'
        '⭐ Experience: ${doctor.experience}';

    // In a real app, use share package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${doctor.name}\'s contact...'),
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
      ),
    );
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
                                      _callDoctor(doctor.mobileNumber);
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: logoColor,
        title: const Text(
          "Doctors",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton.icon(
            onPressed: _showAddDoctorInstructions,
            icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
            label: const Text(
              'Add Doctors',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
                        if (value.isNotEmpty) {
                          _performSearch(value);
                        } else {
                          setState(() {
                            _hasSearched = false;
                            _filteredDoctors = _allDoctors;
                            if (_selectedSpecialty != null) {
                              _performSearch('');
                            }
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Search by name, specialty, or clinic...",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: _clearSearch,
                        )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Filter button
                GestureDetector(
                  onTap: () {
                    _showFilterBottomSheet();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedSpecialty != null ? themeColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedSpecialty != null ? themeColor : Colors.grey[300]!,
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
                      color: _selectedSpecialty != null ? Colors.white : themeColor,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active filter chip
          if (_selectedSpecialty != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedSpecialty!,
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: _clearFilters,
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_filteredDoctors.length} ${_filteredDoctors.length == 1 ? 'result' : 'results'} found',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

          // Results header
          if (_hasSearched && !_isLoading && _selectedSpecialty == null && _selectedTabIndex == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_filteredDoctors.length} ${_filteredDoctors.length == 1 ? 'result' : 'results'} found",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Saved header
          if (_selectedTabIndex == 1 && savedDoctors.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${savedDoctors.length} ${savedDoctors.length == 1 ? 'doctor' : 'doctors'} saved",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Loading indicator
          if (_isLoading && _filteredDoctors.isEmpty && _selectedTabIndex == 0)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Content based on selected tab
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildDoctorGrid(_filteredDoctors)
                : _buildDoctorGrid(savedDoctors),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Utility',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorGrid(List<Doctor> doctors) {
    if (doctors.isEmpty) {
      if (_selectedTabIndex == 1) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_border,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 20),
              Text(
                'No saved doctors',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the save icon on any doctor to save them here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

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
              _hasSearched ? "No doctors found" : "Search for Doctors",
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
                  : "Search by name, specialty, or clinic to find doctors",
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 10) / 2;

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(doctors.length, (index) {
              return SizedBox(
                width: itemWidth,
                child: _buildDoctorCard(doctors[index]),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);
    final isSaved = _savedDoctors.contains(doctor.name);

    return Stack(
      children: [
        Container(
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
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),

                // Profile image
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: Image.network(
                        doctor.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/images/user3.png",
                            fit: BoxFit.cover,
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
                ),

                const SizedBox(height: 10),

                // Name
                Text(
                  doctor.name,
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

                // Specialty pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!, width: 1),
                  ),
                  child: Text(
                    doctor.specialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Phone
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doctor.mobileNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Email
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doctor.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _callDoctor(doctor.mobileNumber),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: const Size(double.infinity, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.call, size: 14, color: Colors.white),
                        label: const Text(
                          'Call',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _shareDoctor(doctor),
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
                        icon: const Icon(Icons.share, size: 14, color: Colors.white),
                        label: const Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Left: Save button
        Positioned(
          top: 8,
          left: 8,
          child: GestureDetector(
            onTap: () => _toggleSaveDoctor(doctor),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSaved ? Colors.red[50] : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSaved ? Colors.red : Colors.grey[300]!,
                ),
              ),
              child: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                size: 20,
                color: isSaved ? Colors.red : Colors.grey[600],
              ),
            ),
          ),
        ),

        // Right: View Detail button
        Positioned(
          top: 8,
          right: 8,
          child: SizedBox(
            height: 25,
            child: OutlinedButton(
              onPressed: () => _showDoctorDetails(doctor),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: themeColor),
                foregroundColor: themeColor,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "View Profile",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
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

  void _showFilterBottomSheet() {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);
    final specialties = getAvailableSpecialties();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter by Specialty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedSpecialty = null;
                          _filteredDoctors = _allDoctors;
                          if (_searchController.text.isNotEmpty) {
                            _performSearch(_searchController.text);
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: specialties.length,
                  itemBuilder: (context, index) {
                    final specialty = specialties[index];
                    final isSelected = _selectedSpecialty == specialty;
                    return ListTile(
                      leading: Radio<String>(
                        value: specialty,
                        groupValue: _selectedSpecialty,
                        onChanged: (value) {
                          setState(() {
                            _selectedSpecialty = value;
                            _performSearch(_searchController.text);
                          });
                          Navigator.pop(context);
                        },
                        activeColor: themeColor,
                      ),
                      title: Text(
                        specialty,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? themeColor : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: themeColor)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedSpecialty = specialty;
                          _performSearch(_searchController.text);
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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

  Doctor({
    required this.name,
    required this.specialty,
    required this.mobileNumber,
    required this.imageUrl,
    required this.email,
    required this.experience,
    required this.clinicName,
    required this.address,
  });
}