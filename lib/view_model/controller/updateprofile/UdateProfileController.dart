import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mpm/OccuptionProfession/OccuptionProfessionData.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/model/GetProfile/BusinessInfo.dart';
import 'package:mpm/model/GetProfile/FamilyMembersData.dart';
import 'package:mpm/model/GetProfile/GetProfileData.dart';
import 'package:mpm/model/GetProfile/GetProfileModel.dart';
import 'package:mpm/model/GetProfile/Qualification.dart';
import 'package:mpm/model/Occupation/OccupationData.dart';
import 'package:mpm/model/Occupation/addoccuption/AddOccuptionModel.dart';
import 'package:mpm/model/OccupationSpec/OccuptionSpecData.dart';
import 'package:mpm/model/Qualification/QualificationData.dart';
import 'package:mpm/model/QualificationCategory/QualificationCategoryModel.dart';
import 'package:mpm/model/QualificationMain/QualicationMainData.dart';
import 'package:mpm/model/Register/RegisterModelClass.dart';
import 'package:mpm/model/UpdateFamilyRelation/UpdateFamilyMember.dart';
import 'package:mpm/model/relation/RelationData.dart';
import 'package:mpm/repository/update_repository/UpdateProfileRepository.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/urls.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/view/profile%20view/profile_view.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';

import '../../../view/profile view/family_info_page.dart';
import '../../../view/profile view/personal_info_page.dart';

class UdateProfileController extends GetxController {
  final api = UpdateProfileRepository();
  var userName = "".obs;

  var profileImage = "".obs; // Add this field

  // Example function to update profile image
  void updateProfileImage(String newImageUrl) {
    profileImage.value = newImageUrl;
  }

  var firstName = ''.obs;
  var middleName = ''.obs;
  var surName = ''.obs;
  var fathersName = ''.obs;
  var mothersName = ''.obs;
  var mobileNumber = ''.obs;
  var whatsAppNumber = ''.obs;
  var email = ''.obs;
  var dob = ''.obs;
  var gender = ''.obs;
  var gender_id = ''.obs;
  var maritalStatus = ''.obs;
  var marital_status_id = ''.obs;
  var bloodGroup = ''.obs;
  var blood_group_id = ''.obs;
  var marriageAnniversaryDate = ''.obs;
  var memberCode = ''.obs;
  var memberSalutaitonId = ''.obs;
  var membershipApprovalStatusId = ''.obs;
  var membershipTypeId = ''.obs;
  var memberStatusId = ''.obs;
  var proposerId = ''.obs;
  var addressProof = ''.obs;
  var addressProofTypeId = ''.obs;
  var otp = ''.obs;
  var verifyOtpStatus = ''.obs;
  var mobileVerifyStatus = ''.obs;
  var sangathanApprovalStatus = ''.obs;
  var vyavasthapikaApprovalStatus = ''.obs;
  var familyHeadMemberId = ''.obs;
  var tempId = ''.obs;
  var isJangana = ''.obs;
  var saraswaniOptionId = ''.obs;

//Address Data
  var zone_id = ''.obs;
  var address = ''.obs;
  var flatNo = ''.obs;
  var zone_name = ''.obs;
  var area_id = ''.obs;
  var state_id = ''.obs;
  var city_id = ''.obs;
  var country_id = ''.obs;
  var pincode = ''.obs;
  var documentType = ''.obs;
  var document = ''.obs;
  var loading = false.obs;
  var addloading = false.obs;

  var organisationName = 'Company Name'.obs;
  var officePhone = 'Landline Number'.obs;
  var buildingName = 'Building Name'.obs;

  var areaName = 'Area'.obs;
  var city2 = 'Office Location'.obs;
  var stateName = 'State'.obs;
  var countryName = 'Country'.obs;
  var officePincode = 'Postal Code'.obs;
  var businessEmail = 'Official Email'.obs;
  var website = 'Official URL'.obs;
  var getUserData = GetProfileData().obs;
  var memberId = "".obs;
  final rxStatusOccupation = Status.LOADING.obs;
  final rxStatusOccupationData = Status.IDLE.obs;
  final rxStatusOccupationSpec = Status.IDLE.obs;
  var occuptionList = <OccupationData>[].obs;
  var occuptionProfessionList = <OccuptionProfessionData>[].obs;
  var occuptionSpeList = <OccuptionSpecData>[].obs;

  void setOccuption(List<OccupationData> _value) =>
      occuptionList.value = _value;

  void setOccuptionPro(List<OccuptionProfessionData> _value) =>
      occuptionProfessionList.value = _value;

  setOccuptionSpe(List<OccuptionSpecData> _value) =>
      occuptionSpeList.value = _value;

  void setRxRequestOccuption(Status _value) =>
      rxStatusOccupation.value = _value;

  void setRxRequestOccuptionData(Status _value) =>
      rxStatusOccupationData.value = _value;

  void setRxRequestOccuptionSpec(Status _value) =>
      rxStatusOccupationSpec.value = _value;
  var relationShipTypeList = <RelationData>[].obs;
  Rx<TextEditingController> educationdetailController =
      TextEditingController().obs;

  setRelationShipType(List<RelationData> _value) =>
      relationShipTypeList.value = _value;
  var qualificationList = <Qualification>[].obs;
  var businessInfoList = <BusinessInfo>[].obs;
  var selectQlification = ''.obs;
  var selectQualicationMain = ''.obs;
  var selectQualicationCat = ''.obs;
  final rxStatusRelationType = Status.LOADING.obs;
  var familyDataList = <FamilyMembersData>[].obs;
  var areaDataList = <FamilyMembersData>[].obs;
  var selectRelationShipType = ''.obs;
  final Rx<TextEditingController> firstNameController =
      TextEditingController().obs;
  final Rx<TextEditingController> middleNameController =
      TextEditingController().obs;
  final Rx<TextEditingController> surNameController =
      TextEditingController().obs;
  final Rx<TextEditingController> fathersNameController =
      TextEditingController().obs;
  final Rx<TextEditingController> mothersNameController =
      TextEditingController().obs;
  final Rx<TextEditingController> mobileNumberController =
      TextEditingController().obs;
  final Rx<TextEditingController> whatsAppNumberController =
      TextEditingController().obs;
  final Rx<TextEditingController> emailController = TextEditingController().obs;
  final Rx<TextEditingController> dobController = TextEditingController().obs;
  final Rx<TextEditingController> genderController =
      TextEditingController().obs;
  final Rx<TextEditingController> maritalStatusController =
      TextEditingController().obs;
  final Rx<TextEditingController> bloodGroupController =
      TextEditingController().obs;
  Rx<TextEditingController> countryController = TextEditingController().obs;
  Rx<TextEditingController> buildingController = TextEditingController().obs;
  Rx<TextEditingController> pincodeController = TextEditingController().obs;
  Rx<TextEditingController> cityController = TextEditingController().obs;
  Rx<TextEditingController> zoneController = TextEditingController().obs;
  Rx<TextEditingController> areaController = TextEditingController().obs;
  Rx<TextEditingController> housenoController = TextEditingController().obs;
  Rx<TextEditingController> stateController = TextEditingController().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  void setSelectRelationShip(String value) {
    selectRelationShipType(value);
  }

  void getUserProfile() async {
    CheckUserData2? userData = await SessionManager.getSession();
    loading.value = true;
    var id = userData?.memberId.toString();
    //id="1";
    api.getUserData(id).then((_value) async {
      loading.value = false;
      getUserData.value = _value.data!;
      memberId.value = id.toString();
      fathersName.value = getUserData.value.fatherName.toString();
      firstName.value = getUserData.value.firstName.toString();
      middleName.value = getUserData.value.middleName.toString();
      surName.value = getUserData.value.lastName.toString();
      userName.value = firstName.value + middleName.value + surName.value;
      mothersName.value = getUserData.value.motherName.toString();
      mobileNumber.value = getUserData.value.mobile.toString();
      email.value = getUserData.value.email.toString();
      dob.value = getUserData.value.dob.toString();
      maritalStatus.value = getUserData.value.marital_status.toString();
      marital_status_id.value = getUserData.value.maritalStatusId.toString();
      gender.value = getUserData.value.gender_name.toString();
      gender_id.value = getUserData.value.genderId.toString();
      bloodGroup.value = getUserData.value.blood_group.toString();
      blood_group_id.value = getUserData.value.bloodGroupId.toString();
      whatsAppNumber.value = getUserData.value.whatsappNumber.toString();
      marriageAnniversaryDate.value =
          getUserData.value.marriageAnniversaryDate.toString();
      memberCode.value = getUserData.value.memberCode.toString();
      memberSalutaitonId.value =
          getUserData.value.memberSalutaitonId.toString();
      membershipApprovalStatusId.value =
          getUserData.value.membershipApprovalStatusId.toString();
      membershipTypeId.value = getUserData.value.membershipTypeId.toString();
      memberStatusId.value = getUserData.value.memberStatusId.toString();
      proposerId.value = getUserData.value.proposerId.toString();
      addressProof.value = getUserData.value.addressProofPath.toString();
      addressProofTypeId.value =
          getUserData.value.addressProofTypeId.toString();
      otp.value = getUserData.value.otp.toString();
      verifyOtpStatus.value = getUserData.value.verifyOtpStatus.toString();
      mobileVerifyStatus.value =
          getUserData.value.mobileVerifyStatus.toString();
      sangathanApprovalStatus.value =
          getUserData.value.sangathanApprovalStatus.toString();
      vyavasthapikaApprovalStatus.value =
          getUserData.value.vyavasthapikaApprovalStatus.toString();
      familyHeadMemberId.value =
          getUserData.value.familyHeadMemberId.toString();
      tempId.value = getUserData.value.tempId.toString();
      isJangana.value = getUserData.value.isJangana.toString();
      saraswaniOptionId.value = getUserData.value.saraswaniOptionId.toString();
      firstNameController.value.text = firstName.value;
      middleNameController.value.text = middleName.value;
      surNameController.value.text = surName.value;
      fathersNameController.value.text = fathersName.value;
      mothersNameController.value.text = mothersName.value;
      mobileNumberController.value.text = mobileNumber.value;
      whatsAppNumberController.value.text = whatsAppNumber.value;
      emailController.value.text = email.value;
      dobController.value.text = dob.value;
      genderController.value.text = gender.value;
      maritalStatusController.value.text = maritalStatus.value;
      bloodGroupController.value.text = bloodGroup.value;
      organisationName.value =
          getUserData.value.occupation!.occupationOtherName.toString();
      officePhone.value = getUserData.value.mobile.toString();
      qualificationList.value = getUserData.value.qualification!;
      businessInfoList.value = getUserData.value.businessInfo!;
      familyDataList.value = getUserData.value.familyMembersData!;
      if (getUserData.value.address != null) {
        area_id.value = getUserData.value.address!.areaName.toString();
        zone_id.value = getUserData.value.address!.zoneId.toString();
        address.value = getUserData.value.address!.address.toString();
        flatNo.value = getUserData.value.address!.flatNo.toString();
        zone_name.value = getUserData.value.address!.zoneName.toString();
        state_id.value = getUserData.value.address!.stateId.toString();
        city_id.value = getUserData.value.address!.cityId.toString();
        country_id.value = getUserData.value.address!.countryId.toString();
        pincode.value = getUserData.value.address!.pincode.toString();
        documentType.value = getUserData.value.address!.addressType.toString();
        countryController.value.text =
            getUserData.value.address!.countryName.toString();
        buildingController.value.text =
            getUserData.value.address!.buildingNameId.toString();
        //pincodeController.value = getUserData.value.address!.stateId;
      }
     /* CheckUserData2 userData = CheckUserData2(
        memberId: memberId.value,
        firstName: firstName.value,
        lastName: surName.value,
        middleName: middleName.value,
        mobile: mobileNumber.value,
        fatherName: fathersName.value,
        motherName: mothersName.value,
        whatsappNumber: whatsAppNumber.value,
        email: email.value,
        genderId: gender_id.value,
        maritalStatusId: marital_status_id.value,
        bloodGroupId: blood_group_id.value,
        memberCode: memberCode.value,
        memberSalutaitonId: memberSalutaitonId.value,
        membershipApprovalStatusId: membershipApprovalStatusId.value,
        membershipTypeId: membershipTypeId.value,
        memberStatusId: memberStatusId.value,
        proposerId: proposerId.value,
        profileImage: profileImage.value,
        addressProof: addressProof.value,
        addressProofTypeId: addressProofTypeId.value,
        otp: otp.value,
        verifyOtpStatus: verifyOtpStatus.value,
        mobileVerifyStatus: mobileVerifyStatus.value,
        sangathanApprovalStatus: sangathanApprovalStatus.value,
        vyavasthapikaApprovalStatus: vyavasthapikaApprovalStatus.value,
        familyHeadMemberId: familyHeadMemberId.value,
        tempId: tempId.value,
        isJangana: isJangana.value,
        saraswaniOptionId: saraswaniOptionId.value,
      );
      await SessionManager.saveSessionUserData(userData!);*/
    }).onError((error, strack) {
      loading.value = false;
      print("err" + error.toString());
    });
  }

  void getOccupationData() {
    setRxRequestOccuption(Status.LOADING);
    api.userOccupationDataApi().then((_value) {
      setRxRequestOccuption(Status.COMPLETE);
      setOccuption(_value.data!);
      occuptionList.add(OccupationData(
          id: "other",
          occupation: 'Other',
          status: '1',
          createdAt: null,
          updatedAt: null));
    }).onError((error, strack) {
      setRxRequestOccuption(Status.ERROR);
    });
  }

  void getOccupationProData(String occupation_id) {
    Map datas = {"occupation_id": occupation_id};
    setRxRequestOccuptionData(Status.LOADING);
    api.userOccutionPreCodeApi(datas).then((_value) {
      setRxRequestOccuptionData(Status.COMPLETE);
      setOccuptionPro(_value.data!);
    }).onError((error, strack) {
      setRxRequestOccuptionData(Status.ERROR);
    });
  }

  void getOccupationSpectData(String occupation_profession_id) {
    Map datas = {"occupation_profession_id": occupation_profession_id};
    setRxRequestOccuptionSpec(Status.LOADING);
    api.userOccutionSpectionCodeApi(datas).then((_value) {
      setRxRequestOccuptionSpec(Status.COMPLETE);
      setOccuptionSpe(_value.data!);
    }).onError((error, strack) {
      setRxRequestOccuptionSpec(Status.ERROR);
    });
  }

  final rxStatusQualification = Status.LOADING.obs;
  final rxStatusQualificationMain = Status.IDLE.obs;
  final rxStatusQualificationCat = Status.IDLE.obs;
  var qulicationList = <QualificationData>[].obs;
  var qulicationMainList = <QualicationMainData>[].obs;
  var qulicationCategoryList = <Qualificationcategorydata>[].obs;
  var isQualicationList = false.obs;
  var isQualicationCateList = false.obs;

  void setSelectQualification(String value) {
    selectQlification(value);
  }

  void setSelectQualificationMain(String value) {
    selectQualicationMain(value);
  }

  void setSelectQualificationCat(String value) {
    selectQualicationMain(value);
  }

  setQlication(List<QualificationData> _value) => qulicationList.value = _value;

  setQualicationMain(List<QualicationMainData> _value) =>
      qulicationMainList.value = _value;

  setQualicationCategory(List<Qualificationcategorydata> _value) =>
      qulicationCategoryList.value = _value;

  void getQualification() {
    setRxRequestQualification(Status.LOADING);
    api.userQualification().then((_value) {
      setRxRequestQualification(Status.COMPLETE);
      setQlication(_value.data!);
      qulicationList.add(QualificationData(
          id: "other",
          qualification: 'Other',
          status: '1',
          createdAt: null,
          updatedAt: null));
    }).onError((error, strack) {
      setRxRequestQualification(Status.ERROR);
    });
  }

  void getQualicationMain(String qualification_id) {
    Map datas = {"qualification_id": qualification_id};
    setRxRequestQualificationMain(Status.LOADING);
    api.userQualificationMain(datas).then((_value) {
      setRxRequestQualificationMain(Status.COMPLETE);
      setQualicationMain(_value.data!);
    }).onError((error, strack) {
      setRxRequestQualificationMain(Status.ERROR);
    });
  }

  void getQualicationCategory(String qualification_main_id) {
    Map datas = {"qualification_main_id": qualification_main_id};
    setRxRequestQualificationCat(Status.LOADING);
    api.userQualificationCategory(datas).then((_value) {
      setRxRequestQualificationCat(Status.COMPLETE);
      setQualicationCategory(_value.data!);
    }).onError((error, strack) {
      setRxRequestQualificationCat(Status.ERROR);
    });
  }

  setRxRequestQualification(Status _value) =>
      rxStatusQualification.value = _value;

  void setRxRequestQualificationMain(Status _value) =>
      rxStatusQualificationMain.value = _value;

  void setRxRequestQualificationCat(Status _value) =>
      rxStatusQualificationCat.value = _value;

  void setRxRelationType(Status _value) => rxStatusRelationType.value = _value;

  void addQualification(BuildContext con) async {
    CheckUserData2? userData = await SessionManager.getSession();
    print('User ID: ${userData?.memberId}');
    print('User Name: ${userData?.mobile}');
    memberId.value = userData!.memberId.toString();
    addloading.value = true;
    try {
      Map map = {
        "member_id": memberId.value,
        "qualification_id": selectQlification.value,
        "qualification_main_id": selectQualicationMain.value,
        "qualification_category_id": selectQualicationCat.value,
        "qualification_other_name": educationdetailController.value.text,
        "created_by": memberId.value
      };
      //print("fffh"+map.toString());
      api.addQualification(map).then((_value) async {
        addloading.value = false;
        if (_value['status'] == true) {
          Navigator.pushReplacementNamed(con, RouteNames.dashboard);
          Get.snackbar(
            'Success', // Title
            "Add Education Successfully", // Message
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      }).onError((error, strack) async {
        addloading.value = false;
        print("fvvf" + error.toString());
        Get.snackbar(
          'Error', // Title
          "Some thing went wrong ", // Message
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.pink,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      });
    } catch (e) {
      addloading.value = false;
      print('Error: $e');
    } finally {}
  }

  void getRelation() {
    Map datas = {"attribute_id": "1"};
    setRxRelationType(Status.LOADING);
    api.userFamilyRelation(datas).then((_value) {
      setRxRelationType(Status.COMPLETE);
      setRelationShipType(_value.data!);
    }).onError((error, strack) {
      setRxRelationType(Status.ERROR);
    });
  }

  void updateFamilyRelation(BuildContext con, String memerId) async {
    CheckUserData2? userData = await SessionManager.getSession();
    //print('User ID: ${userData?.memberId}');
    //print('User Name: ${userData?.mobile}');
    memberId.value = userData!.memberId.toString();
    //addloading.value=true;
    try {
      Map map = {
        "member_id": memerId,
        "relationship_type_id": selectRelationShipType.value,
      };
      //print("fffh"+map.toString());
      await api
          .updateFamilyRelation(map)
          .then((UpdateFamilyMember _value) async {
        // addloading.value=false;
        //print("gnfg"+_value.message.toString());
        if (_value.status == true) {
          Navigator.pushReplacementNamed(con, RouteNames.dashboard);

          Get.snackbar(
            'Success', // Title
            "Update Relation SuccessFully", // Message
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );

          getUserProfile();
        }
      }).onError((error, strack) async {
        //addloading.value=false;
        print("fvvf" + error.toString());
        Get.snackbar(
          'Error', // Title
          "Some thing went wrong ", // Message
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.pink,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      });
    } catch (e) {
      addloading.value = false;
      print('Error: $e');
    } finally {}
  }

  void addAndupdateOccuption(BuildContext con, String memerId) async {
    CheckUserData2? userData = await SessionManager.getSession();
    print('User ID: ${userData?.memberId}');
    print('User Name: ${userData?.mobile}');
    memberId.value = userData!.memberId.toString();
    //addloading.value=true;
    try {
      Map map = {
        "member_id": memerId,
        "occupation_id": "",
        "occupation_profession_id": "",
        "occupation_specialization_id": "",
        "occupation_other_name": "",
        "updated_by": "1"
      };
      //print("fffh"+map.toString());
      await api
          .updateOrAddOccuption(map)
          .then((AddOccuptionModel _value) async {
        // addloading.value=false;
        print("gnfg" + _value.message.toString());
        if (_value.status == true) {
          Navigator.pushReplacementNamed(con, RouteNames.dashboard);
          Get.snackbar(
            'Success', // Title
            "Update Relation SuccessFully", // Message
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      }).onError((error, strack) async {
        //addloading.value=false;
        print("fvvf" + error.toString());
        Get.snackbar(
          'Error', // Title
          "Some thing went wrong ", // Message
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.pink,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      });
    } catch (e) {
      addloading.value = false;
      print('Error: $e');
    } finally {}
  }

  void userUpdateProfile(BuildContext context, String type) async {
    //print("member"+memberId.value);
    CheckUserData2? userData = await SessionManager.getSession();
    //print('User ID: ${userData?.memberId}');
    //print('User Name: ${userData?.mobile}');
    final url = Uri.parse(Urls.updateProfile_url);

    var email = emailController.value.text.trim();
    var mobile = mobileNumberController.value.text.trim();
    NewMemberController memberController = Get.put(NewMemberController());
    //var blood_group_id = memberController.selectBloodGroup.value;
    //var gender_id =gen;
    //var marital_status_id = memberController.selectMarital.value;
    var dob = dobController.value.text.trim();

    var whatsapp_number = whatsAppNumberController.value.text.trim();
    loading.value = true;

    Map<String, String> payload = {
      "member_id": userData!.memberId.toString(),
      "first_name": firstNameController.value.text,
      "last_name": surNameController.value.text,
      ""
          "middle_name": middleNameController.value.text,
      "father_name": fathersNameController.value.text,
      "mother_name": mothersNameController.value.text,
      "email": email,
      "whatsapp_number": whatsapp_number,
      "mobile": mobile,
      "gender_id": gender_id.value,
      "marital_status_id": marital_status_id.value,
      "blood_group_id": blood_group_id.value,
      "dob": dob,
      "marriage_anniversary_date":
          memberController.marriagedateController.value.text,
      "salutation_id": "",
    };
    print("Update profile payload $payload");
    var request = http.MultipartRequest('POST', url);
    request.fields.addAll(payload);
    //request.files.add(await http.MultipartFile.fromPath('document_image',document_image));
    // if(profile_image!="") {
    //   request.files.add(
    //       await http.MultipartFile.fromPath("image_profile", profile_image));
    // }

    http.StreamedResponse response =
        await request.send().timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      loading.value = false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      //print("vfbb"+jsonResponse.toString());
      RegisterModelClass registerResponse =
          RegisterModelClass.fromJson(jsonResponse);
      if (registerResponse.status == true) {
        getUserProfile();
        Get.snackbar(
          "Success",
          "Update Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        memberId.value = registerResponse.data.toString();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PersonalInformationPage(),
          ),
        );
      } else {
        Get.snackbar(
          "Error",
          registerResponse.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } else {
      loading.value = false;
      // print(""+await response.stream.bytesToString());
      String responseBody = await response.stream.bytesToString();
      loading.value = false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      RegisterModelClass registerResponse =
          RegisterModelClass.fromJson(jsonResponse);

      Get.snackbar(
        "Error",
        "" + jsonResponse.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
