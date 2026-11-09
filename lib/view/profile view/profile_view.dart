import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/GetProfile/Occupation.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/login_view.dart';
import 'package:mpm/view/payment/PaymentScreen.dart';
import 'package:mpm/view/profile%20view/Education_page_info.dart';
import 'package:mpm/view/profile%20view/business_info_page.dart';
import 'package:mpm/view/profile%20view/family_info_page.dart';
import 'package:mpm/view/profile%20view/occupation_detail_view.dart';
import 'package:mpm/view/profile%20view/personal_info_page.dart';
import 'package:mpm/view/profile%20view/residence_info_page.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';


class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;


  UdateProfileController controller =Get.put(UdateProfileController());
  NewMemberController newMemberController=Get.put(NewMemberController());

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.getUserProfile();
    controller.getQualification();
    controller.getRelation();
    controller.getOccupationData();
    newMemberController.getGender();
    newMemberController.getBloodGroup();
    newMemberController.getMaritalStatus();
    newMemberController.getCountry();
    newMemberController.getCity();
    newMemberController.getState();
    newMemberController.getDocumentType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              "My Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      drawer: AppDrawer(),
      body: Obx((){
        if(controller.loading.value)
          {
            return const Center(child: CircularProgressIndicator(),);
          }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Profile Picture Section
              Center(
                child: Card(
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Obx(() {
                              return CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[300],
                                child: ClipOval(
                                  child: (controller.profileImage.value.isNotEmpty)
                                      ? FadeInImage(
                                    placeholder: const AssetImage("assets/images/user3.png"),
                                    image: NetworkImage(Urls.imagePathUrl + controller.profileImage.value),
                                    imageErrorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        "assets/images/male.png",
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                      );
                                    },
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  )
                                      : Image.asset(
                                    "assets/images/user3.png",
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Obx(() {
                                    return Text(
                                      "${controller.firstName.value} ${controller.middleName.value}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Obx(() {
                                return Text(
                                  "${controller.surName.value}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                );
                              }),
                              const SizedBox(height: 4),
                              Obx(() {
                                final code = controller.memberCode.value.trim();
                                return Text(
                                  "Membership Code: ${code.isNotEmpty ? code : " -- "}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                );
                              }),
                              const SizedBox(height: 4),
                              Obx(() {
                                return Text(
                                  "Mobile: ${controller.mobileNumber.value}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showConvertNmToLmSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorHelperClass.getColorFromHex(
                      ColorResources.red_color,
                    ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Convert NM to LM',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "View/Edit",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Custom Buttons Section
                  buildCustomButton(
                    title: "Personal Info",
                    icon: Icons.person,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PersonalInformationPage(),
                      ),
                    ),
                  ),
                  buildCustomButton(
                    title: "Residential Info",
                    icon: Icons.home,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResidenceInformationPage(),
                      ),
                    ),
                  ),
                  buildCustomButton(
                    title: "Family Info",
                    icon: Icons.family_restroom,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FamilyInfoPage(),
                      ),
                    ),
                  ),
                  buildCustomButton(
                    title: "Education Info",
                    icon: Icons.school,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EducationPageInfo(),
                      ),
                    ),
                  ),
                  buildCustomButton(
                    title: "Occupation Info",
                    icon: Icons.work,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BusinessInformationPage(),
                      ),
                    ),
                  ),
                  buildCustomButton(
                    title: "Detailed Business Profile",
                    icon: Icons.badge,
                    onTap: () {
                      final occ = controller.currentOccupation.value;

                      if (occ == null) {
                        Get.snackbar("Error", "No occupation found");
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OccupationDetailViewPage(
                            memberId: occ.memberId.toString(),
                            memberOccupationId: occ.memberOccupationId.toString(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Obx((){
                controller.checkReviewApproval();
                return Visibility(
                    visible: controller.showDashboardReviewFlag.value,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          showJanganaDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          ColorHelperClass.getColorFromHex(
                              ColorResources.red_color),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text("Update Jangana",
                            style: TextStyleClass.white14style),
                      ),
                    )
                );
              }),
              Center(
                child: Obx(() {
                  return Visibility(
                    visible: controller.isPay.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentScreen(paymentAmount: '1'),
                              ),
                            );
                          },
                          child: const Text("Pay Now", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAdCard2(String imagePath) {
    return GestureDetector(
      onTap: () async{
        showJanganaDialog(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 150,
        margin: const EdgeInsets.only(right: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(imagePath, fit: BoxFit.fill),
        ),
      ),
    );
  }
  Widget buildCustomButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: TextStyle(fontSize: 16, color: color)),
          trailing: const Icon(Icons.arrow_forward_ios,
              size: 16, color: Colors.black),
          onTap: onTap,
        ),
        const Divider(
            color: Colors.grey,
            thickness: 0.5), // Ensures divider is always visible
      ],
    );
  }

  void _showConvertNmToLmSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ConvertNmToLmSheet(),
    );
  }

  void showJanganaDialog(BuildContext context) {
    showDialog(
      context: context,
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
            children: const [
              Text(
                "Jangana",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to update your Jangana?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.updateJanganaStatus();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}

class _ConvertNmToLmSheet extends StatefulWidget {
  const _ConvertNmToLmSheet();

  @override
  State<_ConvertNmToLmSheet> createState() => _ConvertNmToLmSheetState();
}

class _ConvertNmToLmSheetState extends State<_ConvertNmToLmSheet> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _profile = Get.find<UdateProfileController>();
  final _member = Get.find<NewMemberController>();

  final _firstName = TextEditingController();
  final _middleName = TextEditingController();
  final _surname = TextEditingController();
  final _fatherOrSpouse = TextEditingController();
  final _motherName = TextEditingController();
  final _mobile = TextEditingController();
  final _whatsapp = TextEditingController();
  final _email = TextEditingController();
  final _dob = TextEditingController();
  final _anniversary = TextEditingController();

  File? _image;
  String? _genderId;
  String? _bloodGroupId;
  String? _maritalStatusId;

  @override
  void initState() {
    super.initState();
    _firstName.text = _clean(_profile.firstName.value);
    _middleName.text = _clean(_profile.middleName.value);
    _surname.text = _clean(_profile.surName.value);
    _fatherOrSpouse.text = _clean(_profile.fathersName.value);
    _motherName.text = _clean(_profile.mothersName.value);
    _mobile.text = _clean(_profile.mobileNumber.value);
    _whatsapp.text = _clean(_profile.whatsAppNumber.value);
    _email.text = _clean(_profile.email.value);
    _dob.text = _clean(_profile.dob.value);
    _anniversary.text = _clean(_profile.marriageAnniversaryDate.value);
    _genderId = _clean(_profile.gender_id.value);
    _bloodGroupId = _clean(_profile.blood_group_id.value);
    _maritalStatusId = _clean(_profile.marital_status_id.value);
    if (_genderId!.isEmpty) _genderId = null;
    if (_bloodGroupId!.isEmpty) _bloodGroupId = null;
    if (_maritalStatusId!.isEmpty) _maritalStatusId = null;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _middleName.dispose();
    _surname.dispose();
    _fatherOrSpouse.dispose();
    _motherName.dispose();
    _mobile.dispose();
    _whatsapp.dispose();
    _email.dispose();
    _dob.dispose();
    _anniversary.dispose();
    super.dispose();
  }

  String _clean(String value) {
    final text = value.trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null && mounted) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _pickDate(TextEditingController controller, {DateTime? lastDate}) async {
    DateTime initial = DateTime.now();
    final current = controller.text.trim().replaceAll('-', '/');
    if (current.isNotEmpty) {
      try {
        initial = DateFormat('dd/MM/yyyy').parse(current);
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(lastDate ?? DateTime.now())
          ? (lastDate ?? DateTime.now())
          : initial,
      firstDate: DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
    );
    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {});
    }
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Please enter $label';
    return null;
  }

  String? _mobileValidator(String? value, {required bool required}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Please enter mobile number' : null;
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
      return 'Please enter a valid 10 digit number';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_genderId == null || _bloodGroupId == null || _maritalStatusId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender, blood group and marital status')),
      );
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);
    final existingImage = _clean(_profile.profileImage.value);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Convert NM to LM',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 46,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : (existingImage.isNotEmpty
                                      ? NetworkImage(Urls.imagePathUrl + existingImage)
                                      : const AssetImage('assets/images/user3.png')
                                          as ImageProvider),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Profile Image',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: themeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _field(_firstName, 'First Name *', validator: (v) => _required(v, 'first name')),
                    _field(_middleName, 'Middle Name'),
                    _field(_surname, 'Surname *', validator: (v) => _required(v, 'surname')),
                    _field(_fatherOrSpouse, "Father's / Spouse Name"),
                    _field(_motherName, 'Mother Name'),
                    _field(
                      _mobile,
                      'Mobile *',
                      keyboard: TextInputType.phone,
                      maxLength: 10,
                      validator: (v) => _mobileValidator(v, required: true),
                    ),
                    _field(
                      _whatsapp,
                      'WhatsApp',
                      keyboard: TextInputType.phone,
                      maxLength: 10,
                      validator: (v) => _mobileValidator(v, required: false),
                    ),
                    _field(
                      _email,
                      'Email',
                      keyboard: TextInputType.emailAddress,
                      capitalize: TextCapitalization.none,
                    ),
                    Obx(() => _dropdown(
                          label: 'Gender *',
                          value: _genderId,
                          items: _member.genderList
                              .map((item) => DropdownMenuItem(
                                    value: item.id,
                                    child: Text(item.genderName ?? ''),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _genderId = value),
                        )),
                    _field(
                      _dob,
                      'Date of Birth *',
                      readOnly: true,
                      onTap: () => _pickDate(_dob),
                      validator: (v) => _required(v, 'date of birth'),
                    ),
                    Obx(() => _dropdown(
                          label: 'Blood Group *',
                          value: _bloodGroupId,
                          items: _member.bloodgroupList
                              .map((item) => DropdownMenuItem(
                                    value: item.id,
                                    child: Text(item.bloodGroup ?? ''),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _bloodGroupId = value),
                        )),
                    Obx(() => _dropdown(
                          label: 'Marital Status *',
                          value: _maritalStatusId,
                          items: _member.maritalList
                              .map((item) => DropdownMenuItem(
                                    value: item.id,
                                    child: Text(item.maritalStatus ?? ''),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _maritalStatusId = value),
                        )),
                    _field(
                      _anniversary,
                      'Marriage Anniversary',
                      readOnly: true,
                      onTap: () => _pickDate(_anniversary, lastDate: DateTime.now()),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
    TextCapitalization capitalize = TextCapitalization.words,
    int? maxLength,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        textCapitalization: capitalize,
        maxLength: maxLength,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          counterText: '',
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final selected = items.any((item) => item.value == value) ? value : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        key: ValueKey('$label-$selected-${items.length}'),
        initialValue: selected,
        isExpanded: true,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
