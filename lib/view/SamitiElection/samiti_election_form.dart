import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/SamitiElection/AddElectionMember/AddLMElection/AddLMElectionModelClass.dart';
import 'package:mpm/model/SamitiElection/AddElectionMember/AddNONMElection/AddNONMElectionModelClass.dart';
import 'package:mpm/model/bloodgroup/BloodData.dart';
import 'package:mpm/model/gender/DataX.dart';
import 'package:mpm/model/marital/MaritalData.dart';
import 'package:mpm/model/search/SearchData.dart';
import 'package:mpm/repository/SamitiElection/AddElectionRepository/AddLMElectionRepository/add_lm_election_repo.dart';
import 'package:mpm/repository/SamitiElection/AddElectionRepository/AddNONMElectionRepository/addnonm_election_repo.dart';
import 'package:mpm/repository/SamitiElection/AddElectionRepository/SamitiConvertToLMRepository/samiti_convert_to_LM_repo.dart';
import 'package:mpm/repository/SamitiElection/AddElectionRepository/SamitiVerifyOTPLMRepository/samiti_verify_OTP_LM_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';

import 'package:mpm/view_model/controller/samiti/SamitiController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:url_launcher/url_launcher.dart';

class SamitiElectionFormView extends StatefulWidget {
  final String? startYear;
  final String? endYear;
  final String? samitiTypeKey;
  final String? samitiSubCategoryId;

  const SamitiElectionFormView({
    super.key,
    this.startYear,
    this.endYear,
    this.samitiTypeKey,
    this.samitiSubCategoryId,
  });

  @override
  State<SamitiElectionFormView> createState() => _SamitiElectionFormViewState();
}

class _SamitiElectionFormViewState extends State<SamitiElectionFormView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SamitiController controller = Get.put(SamitiController());
  final UdateProfileController dashBoardController = Get.find();
  final TextEditingController _lmSearchController = TextEditingController();
  final TextEditingController _nmSearchController = TextEditingController();
  final String defaultProfile = "assets/images/user.png";

  // Observable for search text
  final RxString _lmSearchText = ''.obs;
  final RxString _nmSearchText = ''.obs;
  File? _profileImage; // Add this for profile image in convert dialog
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        controller.searchDataList.clear();
        _lmSearchController.clear();
        _nmSearchController.clear();
        _lmSearchText.value = '';
        _nmSearchText.value = '';
      }
    });

    _lmSearchController.addListener(() {
      _lmSearchText.value = _lmSearchController.text;
    });
    _nmSearchController.addListener(() {
      _nmSearchText.value = _nmSearchController.text;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lmSearchController.dispose();
    _nmSearchController.dispose();
    _lmSearchText.close();
    _nmSearchText.close();
    controller.dispose();
    super.dispose();
  }

  void _filterLMMembers(String query) {
    if (query.length >= 4) {
      controller.getSearchLM(query);
    } else {
      controller.searchDataList.clear();
    }
  }

  void _filterNMMembers(String query) {
    if (query.length >= 4) {
      controller.getSearchNM(query);
    } else {
      controller.searchDataList.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Election Form',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFe61428),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(
                  icon: Icon(Icons.people, size: 20),
                  text: "LM Members",
                ),
                Tab(
                  icon: Icon(Icons.group, size: 20),
                  text: "NM Members",
                ),
                Tab(
                  icon: Icon(Icons.person_add, size: 20),
                  text: "New Member",
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLMMembersTab(),
                _buildNMMembersTab(),
                _buildAddMemberTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== LM MEMBERS TAB ====================
  Widget _buildLMMembersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchField(
            controller: _lmSearchController,
            hintText: "Search by name, LM code, or mobile...",
            onChanged: _filterLMMembers,
            suffixIcon: _lmSearchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _lmSearchController.clear();
                      _lmSearchText.value = '';
                      controller.searchDataList.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "LM Members Found",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Obx(() {
                  final hasText = _lmSearchText.value.isNotEmpty;
                  return hasText
                      ? Text(
                          "${controller.searchDataList.length} results",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        )
                      : const SizedBox.shrink();
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.loading2.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFe61428)),
                );
              } else if (controller.searchDataList.value.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.search_off,
                  message: _lmSearchController.text.isEmpty
                      ? "Search for LM members to send consent form"
                      : "No LM members found. Try a different search term.",
                );
              } else {
                return ListView.builder(
                  itemCount: controller.searchDataList.value.length,
                  itemBuilder: (context, index) {
                    var member = controller.searchDataList.value[index];
                    var firstname = member?.firstName ?? "";
                    var middlename = member?.middleName ?? "";
                    var lastname = member?.lastName ?? "";
                    var name = "$firstname $middlename $lastname".trim();
                    var lmcode = member?.memberCode ?? "";

                    return _buildMemberCard(
                      context,
                      memberType: "LM",
                      lmcode: lmcode,
                      name: name,
                      mobile: member.mobile,
                      email: member.email,
                      profileImage: member.profileImage != null
                          ? member.profileImage!.isEmpty
                              ? defaultProfile
                              : member.profileImage
                          : defaultProfile,
                      memberData: member,
                      showConsentButton: true,
                      showConvertButton: false,
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  // ==================== NM MEMBERS TAB ====================
  Widget _buildNMMembersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchField(
            controller: _nmSearchController,
            hintText: "Search by name, NM code, or mobile...",
            onChanged: _filterNMMembers,
            suffixIcon: _nmSearchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _nmSearchController.clear();
                      _nmSearchText.value = '';
                      controller.searchDataList.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "NM Members Found",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Obx(() {
                  final hasText = _nmSearchText.value.isNotEmpty;
                  return hasText
                      ? Text(
                          "${controller.searchDataList.length} results",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        )
                      : const SizedBox.shrink();
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.loading2.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFe61428)),
                );
              } else if (controller.searchDataList.value.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.search_off,
                  message: _nmSearchController.text.isEmpty
                      ? "Search for NM members to convert to LM"
                      : "No NM members found. Try a different search term.",
                );
              } else {
                return ListView.builder(
                  itemCount: controller.searchDataList.value.length,
                  itemBuilder: (context, index) {
                    var member = controller.searchDataList.value[index];
                    var firstname = member?.firstName ?? "";
                    var middlename = member?.middleName ?? "";
                    var lastname = member?.lastName ?? "";
                    var name = "$firstname $middlename $lastname".trim();
                    var nmcode = member?.memberCode ?? "";

                    return _buildMemberCard(
                      context,
                      memberType: "NM",
                      lmcode: nmcode,
                      name: name,
                      mobile: member.mobile,
                      email: member.email,
                      profileImage: member.profileImage != null
                          ? member.profileImage!.isEmpty
                              ? defaultProfile
                              : member.profileImage
                          : defaultProfile,
                      memberData: member,
                      showConsentButton: false,
                      showConvertButton: true,
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  // ==================== ADD MEMBER TAB ====================
  Widget _buildAddMemberTab() {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController middleNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController mobileController = TextEditingController();
    final TextEditingController whatsappController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: "First Name *",
                hintText: "Enter first name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter first name";
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: middleNameController,
              decoration: InputDecoration(
                labelText: "Middle Name",
                hintText: "Enter middle name (optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: "Last Name *",
                hintText: "Enter last name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter last name";
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: "Mobile Number *",
                hintText: "Enter 10-digit mobile number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.phone),
                filled: true,
                fillColor: Colors.white,
                counterText: "",
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter mobile number";
                }
                if (value.trim().length != 10) {
                  return "Mobile number must be 10 digits";
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                  return "Please enter valid mobile number";
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: whatsappController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: "WhatsApp Number *",
                hintText: "Enter 10-digit WhatsApp number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon:
                    const Icon(Icons.phone_android, color: Colors.green),
                filled: true,
                fillColor: Colors.white,
                counterText: "",
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter WhatsApp number";
                }
                if (value.trim().length != 10) {
                  return "WhatsApp number must be 10 digits";
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                  return "Please enter valid WhatsApp number";
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email Address *",
                hintText: "Enter email address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter email address";
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value.trim())) {
                  return "Please enter valid email address";
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    _submitNewMember(
                      context,
                      firstName: firstNameController.text.trim(),
                      middleName: middleNameController.text.trim(),
                      lastName: lastNameController.text.trim(),
                      mobile: mobileController.text.trim(),
                      whatsapp: whatsappController.text.trim(),
                      email: emailController.text.trim(),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe61428),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 22),
                    SizedBox(width: 10),
                    Text(
                      "Add New Member",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "All fields marked with * are required",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.group_add,
              size: 60,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ==================== SUBMIT NEW MEMBER METHOD ====================
  void _submitNewMember(
    BuildContext context, {
    required String firstName,
    required String middleName,
    required String lastName,
    required String mobile,
    required String whatsapp,
    required String email,
  }) {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFe61428)),
                  SizedBox(height: 16),
                  Text(
                    "Adding new member...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Call the API
    _addNMElection(
      context: context,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      mobile: mobile,
      whatsapp: whatsapp,
      email: email,
    );
  }

  // ==================== ADD NM ELECTION (NEW MEMBER) ====================
  Future<void> _addNMElection({
    required BuildContext context,
    required String firstName,
    required String middleName,
    required String lastName,
    required String mobile,
    required String whatsapp,
    required String email,
  }) async {
    try {
      final userId = dashBoardController.memberId.value;
      final repository = AddNONMElectionRepository();

      debugPrint("===== ADD NM ELECTION DEBUG =====");
      debugPrint("First Name: $firstName");
      debugPrint("Middle Name: $middleName");
      debugPrint("Last Name: $lastName");
      debugPrint("Mobile: $mobile");
      debugPrint("WhatsApp: $whatsapp");
      debugPrint("Email: $email");
      debugPrint("Samiti ID: ${widget.samitiTypeKey}");
      debugPrint("Samiti Sub Category ID: ${widget.samitiSubCategoryId}");
      debugPrint("Start Year: ${widget.startYear}");
      debugPrint("End Year: ${widget.endYear}");
      debugPrint("Created By: $userId");
      debugPrint("================================");

      // Call the API
      final result = await repository.addNMElection(
        firstName: firstName,
        middleName: middleName.isNotEmpty ? middleName : null,
        lastName: lastName,
        mobile: mobile,
        email: email,
        whatsappNumber: whatsapp,
        samitiId: widget.samitiTypeKey ?? "",
        samitiSubCategoryId: widget.samitiSubCategoryId ?? "",
        samitiRoleId: null, // Optional
        startYear: widget.startYear,
        endYear: widget.endYear,
        createdBy: userId.toString(),
      );

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      if (result.status == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message ?? "New member added successfully!",
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear form fields or navigate back
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop(); // Close the form or navigate back
          }
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? "Failed to add new member"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
    Widget? suffixIcon,
  }) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MEMBER CARD ====================
  Widget _buildMemberCard(
    BuildContext context, {
    required String memberType,
    required String lmcode,
    String? name,
    String? mobile,
    String? email,
    String? profileImage,
    dynamic memberData,
    bool showConsentButton = false,
    bool showConvertButton = false,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ClipOval(
                  child: (profileImage != null && profileImage.isNotEmpty)
                      ? FadeInImage(
                          placeholder:
                              const AssetImage("assets/images/user3.png"),
                          image: NetworkImage(Urls.imagePathUrl + profileImage),
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/images/user3.png",
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                            );
                          },
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                        )
                      : Image.asset(
                          "assets/images/user3.png",
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: "$memberType Code: ",
                              style: const TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text:
                                  (lmcode.trim().isNotEmpty) ? lmcode : " -- ",
                              style: const TextStyle(
                                color: Color(0xFFDC3545),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      mobile != null && mobile.trim().isNotEmpty
                          ? GestureDetector(
                              onTap: () async {
                                final Uri launchUri =
                                    Uri(scheme: 'tel', path: mobile);
                                try {
                                  if (!await launchUrl(launchUri)) {
                                    throw 'Could not launch $launchUri';
                                  }
                                } catch (e) {
                                  debugPrint("Error launching dialer: $e");
                                }
                              },
                              child: Text(
                                "Mobile: $mobile",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 4),
                      Text(
                        "Email: ${email ?? "-"}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Action Buttons
            if (showConsentButton || showConvertButton) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Only show Send Consent button for LM members
                  if (showConsentButton && !showConvertButton)
                    OutlinedButton.icon(
                      onPressed: () {
                        // Convert SearchData to Map before passing
                        Map<String, dynamic>? memberMap;
                        if (memberData != null) {
                          if (memberData is SearchData) {
                            memberMap = {
                              'memberId': memberData.memberId,
                              'id': memberData.memberId,
                              'member_id': memberData.memberId,
                              'firstName': memberData.firstName,
                              'lastName': memberData.lastName,
                              'mobile': memberData.mobile,
                              'email': memberData.email,
                              'memberCode': memberData.memberCode,
                              'profileImage': memberData.profileImage,
                              'membershipTypeId': memberData.membershipTypeId,
                            };
                          } else if (memberData is Map<String, dynamic>) {
                            memberMap = memberData;
                          }
                        }
                        _showConsentFormDialog(context, name ?? "",
                            memberData: memberMap);
                      },
                      icon: const Icon(Icons.send, size: 16),
                      label: const Text("Send Consent"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                  // Only show Convert button for NM members
                  if (showConvertButton && !showConsentButton)
                    ElevatedButton.icon(
                      onPressed: () {
                        _showConvertDialog(context, name ?? "",
                            memberData: memberData);
                      },
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text("Convert to LM"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFe61428),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== DIALOGS ====================

  void _showConsentFormDialog(BuildContext context, String memberName,
      {Map<String, dynamic>? memberData}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.send,
                    color: Colors.green.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Send Consent Form",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(
                thickness: 1,
                color: Colors.grey.shade300,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure you want to send the consent form to $memberName?",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              if (memberData != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow("Member ID",
                          memberData['memberId']?.toString() ?? 'N/A'),
                      _buildDetailRow("Member Code",
                          memberData['memberCode']?.toString() ?? 'N/A'),
                      _buildDetailRow(
                          "Mobile", memberData['mobile']?.toString() ?? 'N/A'),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Close the consent dialog
                Navigator.of(context).pop();

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                  color: Color(0xFFe61428)),
                              SizedBox(height: 16),
                              Text(
                                "Adding LM member...",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );

                try {
                  // Call the add election API
                  final result = await _addLMElection(
                    memberData: memberData,
                  );

                  // Close loading dialog
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }

                  if (result.status == true) {
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Consent form sent to successfully!"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 3),
                      ),
                    );

                    // Refresh the list
                    _refreshMemberList();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(result.message ?? "Failed to add LM member"),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  // Refresh the search results displayed in the active member tab.
  void _refreshMemberList() {
    if (_tabController.index == 1 && _nmSearchController.text.isNotEmpty) {
      _filterNMMembers(_nmSearchController.text);
    } else if (_tabController.index == 0 &&
        _lmSearchController.text.isNotEmpty) {
      _filterLMMembers(_lmSearchController.text);
    }
  }

  // Method to add LM election
  Future<AddLMElectionModelClass> _addLMElection(
      {Map<String, dynamic>? memberData}) async {
    try {
      final userId = dashBoardController.memberId.value;
      final repository = AddElectionRepository();

      String? memberId;
      if (memberData != null) {
        memberId = memberData['memberId']?.toString() ??
            memberData['id']?.toString() ??
            memberData['member_id']?.toString();
      }

      if (memberId == null || memberId.isEmpty) {
        debugPrint("Warning: No memberId found in memberData");
      }

      debugPrint("===== ADD LM ELECTION DEBUG =====");
      debugPrint("Member ID: $memberId");
      debugPrint("Samiti ID (samitiTypeKey): ${widget.samitiTypeKey}");
      debugPrint("Samiti Sub Category ID: ${widget.samitiSubCategoryId}");
      debugPrint("Start Year: ${widget.startYear}");
      debugPrint("End Year: ${widget.endYear}");
      debugPrint("Created By: $userId");
      debugPrint("================================");

      if (widget.samitiTypeKey == null || widget.samitiTypeKey!.isEmpty) {
        throw Exception("Samiti ID is required");
      }
      if (widget.samitiSubCategoryId == null ||
          widget.samitiSubCategoryId!.isEmpty) {
        throw Exception("Samiti Sub Category ID is required");
      }

      final result = await repository.addElection(
        candidateType: "LM",
        memberId: memberId,
        samitiId: widget.samitiTypeKey ?? "",
        samitiSubCategoryId: widget.samitiSubCategoryId ?? "",
        startYear: widget.startYear,
        endYear: widget.endYear,
        createdBy: userId.toString(),
      );

      debugPrint("Add Election Result: ${result.toJson()}");
      return result;
    } catch (e) {
      debugPrint("Error adding LM election: $e");
      rethrow;
    }
  }

  Future<void> _showConvertDialog(BuildContext context, String memberName,
      {dynamic memberData}) async {
    // Controllers for form fields
    final TextEditingController mobileController = TextEditingController();
    final TextEditingController whatsappController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController marriageAnniversaryController =
        TextEditingController();

    String? memberId;
    String fallbackMobile = '';
    String fallbackEmail = '';
    String fallbackProfileImage = '';
    if (memberData is SearchData) {
      memberId = memberData.memberId;
      fallbackMobile = memberData.mobile ?? '';
      fallbackEmail = memberData.email ?? '';
      fallbackProfileImage = memberData.profileImage ?? '';
    } else if (memberData is Map<String, dynamic>) {
      memberId = memberData['memberId']?.toString() ??
          memberData['member_id']?.toString() ??
          memberData['id']?.toString();
      fallbackMobile = memberData['mobile']?.toString() ?? '';
      fallbackEmail = memberData['email']?.toString() ?? '';
      fallbackProfileImage = memberData['profile_image']?.toString() ?? '';
    }

    // Load the selected NM member's complete profile for conversion fields.
    final memberProfile = memberId == null || memberId.isEmpty
        ? null
        : await dashBoardController.getMemberProfile(memberId);
    if (!mounted) return;

    // Reset profile image when dialog opens
    _profileImage = null;
    final existingProfileImage =
        memberProfile?.profileImage ?? fallbackProfileImage;

    // Form key for validation
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    mobileController.text = memberProfile?.mobile ?? fallbackMobile;
    whatsappController.text = memberProfile?.whatsappNumber ?? '';
    emailController.text = memberProfile?.email ?? fallbackEmail;
    dateController.text = memberProfile?.dob ?? '';
    marriageAnniversaryController.text =
        memberProfile?.marriageAnniversaryDate ?? '';

    // Use GetX controller for dropdown data
    final NewMemberController memberController = Get.put(NewMemberController());
    memberController.setSelectedGender(memberProfile?.genderId ?? '');
    memberController.setSelectedBloodGroup(memberProfile?.bloodGroupId ?? '');
    memberController.setSelectedMarital(memberProfile?.maritalStatusId ?? '');

    // Load dropdown data if not already loaded
    if (memberController.genderList.isEmpty) {
      memberController.getGender();
    }
    if (memberController.bloodgroupList.isEmpty) {
      memberController.getBloodGroup();
    }
    if (memberController.maritalList.isEmpty) {
      memberController.getMaritalStatus();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        color: const Color(0xFFe61428),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Convert NM to LM',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    thickness: 1,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Convert $memberName from NM to LM Member',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Profile Image Upload
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              _showImagePicker(context, setState);
                            },
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : existingProfileImage.isNotEmpty
                                      ? NetworkImage(Urls.imagePathUrl +
                                          existingProfileImage)
                                      : null,
                              child: _profileImage == null &&
                                      existingProfileImage.isEmpty
                                  ? Icon(
                                      Icons.camera_alt,
                                      color: Colors.grey[700],
                                      size: 40,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mobile Number
                        TextFormField(
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: InputDecoration(
                            labelText: 'Mobile Number *',
                            hintText: 'Enter 10-digit mobile number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.phone),
                            filled: true,
                            fillColor: Colors.white,
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter mobile number';
                            }
                            if (value.trim().length != 10) {
                              return 'Mobile number must be 10 digits';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                              return 'Please enter valid mobile number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // WhatsApp Number
                        TextFormField(
                          controller: whatsappController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: InputDecoration(
                            labelText: 'WhatsApp Number *',
                            hintText: 'Enter 10-digit WhatsApp number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.phone_android,
                                color: Colors.green),
                            filled: true,
                            fillColor: Colors.white,
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter WhatsApp number';
                            }
                            if (value.trim().length != 10) {
                              return 'WhatsApp number must be 10 digits';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                              return 'Please enter valid WhatsApp number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Email
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email Address *',
                            hintText: 'Enter email address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.email),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter email address';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value.trim())) {
                              return 'Please enter valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Gender Dropdown
                        Obx(() {
                          if (memberController.rxStatusLoading2.value ==
                              Status.LOADING) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFe61428),
                                  ),
                                ),
                              ),
                            );
                          } else if (memberController.rxStatusLoading2.value ==
                              Status.ERROR) {
                            return const Center(
                              child: Text('Failed to load genders',
                                  style: TextStyle(color: Colors.red)),
                            );
                          } else if (memberController.genderList.isEmpty) {
                            return const Center(
                              child: Text('No genders available'),
                            );
                          } else {
                            return DropdownButtonFormField<String>(
                              value: memberController
                                      .selectedGender.value.isNotEmpty
                                  ? memberController.selectedGender.value
                                  : null,
                              decoration: InputDecoration(
                                labelText: 'Gender *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.person),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              hint: const Text('Select Gender'),
                              items: memberController.genderList
                                  .map((DataX gender) {
                                return DropdownMenuItem<String>(
                                  value: gender.id.toString(),
                                  child: Text(gender.genderName ?? 'Unknown'),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  memberController.setSelectedGender(newValue);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select gender';
                                }
                                return null;
                              },
                            );
                          }
                        }),
                        const SizedBox(height: 14),

                        // Blood Group Dropdown
                        Obx(() {
                          if (memberController.rxStatusLoading.value ==
                              Status.LOADING) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFe61428),
                                  ),
                                ),
                              ),
                            );
                          } else if (memberController.rxStatusLoading.value ==
                              Status.ERROR) {
                            return const Center(
                              child: Text('Failed to load blood groups',
                                  style: TextStyle(color: Colors.red)),
                            );
                          } else if (memberController.bloodgroupList.isEmpty) {
                            return const Center(
                              child: Text('No blood groups available'),
                            );
                          } else {
                            return DropdownButtonFormField<String>(
                              value: memberController
                                      .selectBloodGroup.value.isNotEmpty
                                  ? memberController.selectBloodGroup.value
                                  : null,
                              decoration: InputDecoration(
                                labelText: 'Blood Group',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.bloodtype),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              hint: const Text('Select Blood Group'),
                              items: memberController.bloodgroupList
                                  .map((BloodGroupData item) {
                                return DropdownMenuItem<String>(
                                  value: item.id.toString(),
                                  child: Text(item.bloodGroup ?? 'Unknown'),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  memberController
                                      .setSelectedBloodGroup(newValue);
                                }
                              },
                            );
                          }
                        }),
                        const SizedBox(height: 14),

                        // Marital Status Dropdown
                        Obx(() {
                          if (memberController.rxStatusmarried.value ==
                              Status.LOADING) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFe61428),
                                  ),
                                ),
                              ),
                            );
                          } else if (memberController.rxStatusmarried.value ==
                              Status.ERROR) {
                            return const Center(
                              child: Text('Failed to load marital status',
                                  style: TextStyle(color: Colors.red)),
                            );
                          } else if (memberController.maritalList.isEmpty) {
                            return const Center(
                              child: Text('No marital status available'),
                            );
                          } else {
                            return DropdownButtonFormField<String>(
                              value: memberController
                                      .selectMarital.value.isNotEmpty
                                  ? memberController.selectMarital.value
                                  : null,
                              decoration: InputDecoration(
                                labelText: 'Marital Status *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.favorite),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              hint: const Text('Select Marital Status'),
                              items: memberController.maritalList
                                  .map((MaritalData item) {
                                return DropdownMenuItem<String>(
                                  value: item.id.toString(),
                                  child: Text(item.maritalStatus ?? 'Unknown'),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  memberController.setSelectedMarital(newValue);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select marital status';
                                }
                                return null;
                              },
                            );
                          }
                        }),
                        const SizedBox(height: 14),

                        // Marriage Anniversary (conditional)
                        Obx(() {
                          final bool isMarried = memberController
                                  .selectMarital.value.isNotEmpty &&
                              memberController.maritalList.any((item) =>
                                  item.id.toString() ==
                                      memberController.selectMarital.value &&
                                  item.maritalStatus?.trim().toLowerCase() ==
                                      'married');

                          if (!isMarried) return const SizedBox.shrink();

                          return Column(
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.text,
                                readOnly: true,
                                controller: marriageAnniversaryController,
                                decoration: InputDecoration(
                                  labelText: 'Marriage Anniversary',
                                  hintText: 'Select Marriage Anniversary',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.calendar_today),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: ColorHelperClass
                                                .getColorFromHex(
                                                    ColorResources.red_color),
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: ColorHelperClass
                                                  .getColorFromHex(
                                                      ColorResources.red_color),
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    String formattedDate =
                                        DateFormat('dd/MM/yyyy')
                                            .format(pickedDate);
                                    marriageAnniversaryController.text =
                                        formattedDate;
                                  }
                                },
                              ),
                              const SizedBox(height: 14),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Close the dialog and proceed with conversion
                      Navigator.of(context).pop();
                      _processNMConversion(
                        // The conversion dialog's context is disposed above.
                        // Keep subsequent dialogs attached to the form screen.
                        context: this.context,
                        memberName: memberName,
                        memberData: memberData,
                        mobile: mobileController.text.trim(),
                        whatsapp: whatsappController.text.trim(),
                        email: emailController.text.trim(),
                        genderId: memberController.selectedGender.value,
                        bloodGroupId: memberController.selectBloodGroup.value,
                        maritalStatusId: memberController.selectMarital.value,
                        dob: dateController.text.trim(),
                        marriageAnniversary:
                            marriageAnniversaryController.text.trim(),
                        profileImage: _profileImage,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFe61428),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text("Convert"),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Image picker method - Updated to use class-level _profileImage
  void _showImagePicker(BuildContext context, StateSetter setState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.redAccent),
              title: const Text('Take a Picture'),
              onTap: () {
                _getImage(ImageSource.camera, setState);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.redAccent),
              title: const Text('Choose from Gallery'),
              onTap: () {
                _getImage(ImageSource.gallery, setState);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Get image method - Updated to use class-level _profileImage
  Future<void> _getImage(ImageSource img, StateSetter setState) async {
    if (_picker.supportsImageSource(img) == true) {
      try {
        final XFile? pickedFile =
            await _picker.pickImage(source: img, imageQuality: 80);
        if (pickedFile != null) {
          setState(() {
            _profileImage = File(pickedFile.path);
          });
        }
      } catch (e) {
        debugPrint("Error picking image: $e");
      }
    }
  }

// Process NM to LM Conversion with OTP
  void _processNMConversion({
    required BuildContext context,
    required String memberName,
    dynamic memberData,
    required String mobile,
    required String whatsapp,
    required String email,
    required String genderId,
    required String bloodGroupId,
    required String maritalStatusId,
    required String dob,
    required String marriageAnniversary,
    File? profileImage,
  }) {
    // Get member ID from memberData
    String? memberId;
    if (memberData != null) {
      if (memberData is SearchData) {
        memberId = memberData.memberId?.toString();
      } else if (memberData is Map<String, dynamic>) {
        memberId = memberData['memberId']?.toString() ??
            memberData['id']?.toString() ??
            memberData['member_id']?.toString();
      }
    }

    if (memberId == null || memberId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Member ID not found"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFe61428)),
                  SizedBox(height: 16),
                  Text(
                    "Converting NM to LM...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Call the API
    _convertNMToLM(
      context: context,
      memberId: memberId,
      memberName: memberName,
      mobile: mobile,
      whatsapp: whatsapp,
      email: email,
      genderId: genderId,
      bloodGroupId: bloodGroupId,
      maritalStatusId: maritalStatusId,
      marriageAnniversary: marriageAnniversary,
      profileImage: profileImage,
    );
  }

  // Convert NM to LM API call
  Future<void> _convertNMToLM({
    required BuildContext context,
    required String memberId,
    required String memberName,
    required String mobile,
    required String whatsapp,
    required String email,
    required String genderId,
    required String bloodGroupId,
    required String maritalStatusId,
    required String marriageAnniversary,
    File? profileImage,
  }) async {
    try {
      final repository = SamitiConvertToLMRepository();

      debugPrint("===== CONVERT NM TO LM DEBUG =====");
      debugPrint("Member ID: $memberId");
      debugPrint("Mobile: $mobile");
      debugPrint("WhatsApp: $whatsapp");
      debugPrint("Email: $email");
      debugPrint("Gender ID: $genderId");
      debugPrint("Blood Group ID: $bloodGroupId");
      debugPrint("Marital Status ID: $maritalStatusId");
      debugPrint("Marriage Anniversary: $marriageAnniversary");
      debugPrint("Samiti ID: ${widget.samitiTypeKey}");
      debugPrint("Samiti Sub Category ID: ${widget.samitiSubCategoryId}");
      debugPrint("Start Year: ${widget.startYear}");
      debugPrint("End Year: ${widget.endYear}");
      debugPrint("================================");

      // Call the API with all required fields
      final result = await repository.convertToLM(
        memberId: memberId,
        mobile: mobile,
        whatsappNumber: whatsapp,
        email: email,
        genderId: genderId,
        bloodGroupId: bloodGroupId,
        maritalStatusId: maritalStatusId,
        marriageAnniversaryDate:
            marriageAnniversary.isNotEmpty ? marriageAnniversary : null,
        samitiId: widget.samitiTypeKey ?? "",
        samitiSubCategoryId: widget.samitiSubCategoryId ?? "",
        samitiRoleId: "13",
        startYear: widget.startYear ?? "",
        endYear: widget.endYear ?? "",
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (result.status == true) {
        // Show OTP dialog directly - no snackbar
        if (mounted) {
          _showOTPDialog(context, memberId, memberName);
        }
      } else {
        // Show error message only on failure
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.msg ?? "Failed to convert NM to LM"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

// Show OTP Dialog
  void _showOTPDialog(
      BuildContext context, String memberId, String memberName) {
    // Check if context is still valid
    if (!mounted) {
      debugPrint("Widget not mounted, cannot show OTP dialog");
      return;
    }

    final TextEditingController otpController = TextEditingController();
    final GlobalKey<FormState> otpFormKey = GlobalKey<FormState>();

    // Timer for resend
    int _resendTimer = 30;
    bool _canResend = false;

    // Use showDialog with proper context
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Start timer when dialog opens
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_resendTimer > 0 && mounted) {
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() {
                      _resendTimer--;
                      if (_resendTimer == 0) {
                        _canResend = true;
                      }
                    });
                  }
                });
              }
            });

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: const Color(0xFFe61428),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Verify OTP',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    thickness: 1,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
              content: Form(
                key: otpFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please enter the OTP sent to your registered mobile number.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: InputDecoration(
                        labelText: 'Enter OTP *',
                        hintText: 'Enter 4-digit OTP',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.sms),
                        filled: true,
                        fillColor: Colors.white,
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter OTP';
                        }
                        if (value.trim().length != 4) {
                          return 'OTP must be 4 digits';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                          return 'Please enter valid OTP';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _canResend
                              ? 'Didn\'t receive OTP?'
                              : 'Resend OTP in ${_resendTimer}s',
                          style: TextStyle(
                            fontSize: 13,
                            color: _canResend ? Colors.blue : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (otpFormKey.currentState!.validate()) {
                      // Keep this dialog open while its loading overlay is shown.
                      _verifyOTP(
                        dialogContext,
                        memberId,
                        otpController.text.trim(),
                        memberName,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFe61428),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text("Verify OTP"),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Verify OTP
  void _verifyOTP(
      BuildContext context, String memberId, String otp, String memberName) {
    // Check if mounted before showing dialog
    if (!mounted) {
      debugPrint("Widget not mounted, cannot verify OTP");
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFe61428)),
                  SizedBox(height: 16),
                  Text(
                    "Verifying OTP...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    _verifyOTPAPI(
      context: context,
      memberId: memberId,
      otp: otp,
      memberName: memberName,
    );
  }

// Verify OTP API call
  Future<void> _verifyOTPAPI({
    required BuildContext context,
    required String memberId,
    required String otp,
    required String memberName,
  }) async {
    try {
      final repository = SamitiVerifyOTPLMRepository();

      debugPrint("===== VERIFY OTP DEBUG =====");
      debugPrint("Member ID: $memberId");
      debugPrint("OTP: $otp");
      debugPrint("Samiti ID: ${widget.samitiTypeKey}");
      debugPrint("Samiti Sub Category ID: ${widget.samitiSubCategoryId}");
      debugPrint("Start Year: ${widget.startYear}");
      debugPrint("End Year: ${widget.endYear}");
      debugPrint("============================");

      final result = await repository.verifyOTP(
        memberId: memberId,
        otp: otp,
        samitiId: widget.samitiTypeKey ?? "",
        samitiSubCategoryId: widget.samitiSubCategoryId ?? "",
        samitiRoleId: "13",
        startYear: widget.startYear ?? "",
        endYear: widget.endYear ?? "",
      );

      // The loading overlay is the top-most route.
      final navigator = Navigator.of(this.context, rootNavigator: true);
      if (mounted && navigator.canPop()) {
        navigator.pop();
      }

      if (result.status == true) {
        // The OTP dialog remains beneath the loading overlay until success.
        if (mounted && navigator.canPop()) {
          navigator.pop();
        }

        // Show success message
        String message = "OTP verified successfully.";
        if (result.emailSent == true) {
          message += " Consent letter sent via email.";
        }
        if (result.whatsappSent == true) {
          message += " Consent letter sent via WhatsApp.";
        }

        if (mounted) {
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }

        // Refresh the list
        _refreshMemberList();
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(
              content: Text(result.data?.toString() ??
                  "Invalid OTP or samiti details missing. Please try again."),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final navigator = Navigator.of(this.context, rootNavigator: true);
        if (navigator.canPop()) {
          navigator.pop();
        }
      }

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
