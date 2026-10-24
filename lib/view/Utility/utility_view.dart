import 'package:flutter/material.dart';
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
          "Utility",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
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