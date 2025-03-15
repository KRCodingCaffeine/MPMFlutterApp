import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/textstyleclass.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/login_view.dart';
import 'package:mpm/view/profile%20view/Education_page_info.dart';
import 'package:mpm/view/profile%20view/business_info_page.dart';
import 'package:mpm/view/profile%20view/family_info_page.dart';
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white),
        ),
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
                                backgroundColor: Colors.grey[300], // Background color while loading
                                child: ClipOval(
                                  child: (controller.profileImage.value.isNotEmpty)
                                      ? FadeInImage(
                                    placeholder: const AssetImage("assets/images/user3.png"), // Placeholder while loading
                                    image: NetworkImage(Urls.imagePathUrl + controller.profileImage.value), // Network image
                                    imageErrorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        "assets/images/male.png", // Fallback image on error
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
                                    "assets/images/user3.png", // Default image if profileImage is empty
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
                                  "${controller.surName.value} ${controller.memberCode.value}",
                                  style: TextStyle(
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

  void showJanganaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Jangana"),
          content: const Text("Are you sure you ant to update your Jangana?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {

               controller.updateJanganaStatus();
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
