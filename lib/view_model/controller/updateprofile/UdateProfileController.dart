import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mpm/OccuptionProfession/OccuptionProfessionData.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/model/GetProfile/BusinessInfo.dart';
import 'package:mpm/model/GetProfile/FamilyMembersData.dart';
import 'package:mpm/model/GetProfile/GetProfileData.dart';
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
import 'package:mpm/repository/register_repository/register_repo.dart';
import 'package:mpm/repository/update_repository/UpdateProfileRepository.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/view/profile%20view/profile_view.dart';
import 'package:mpm/view/profile%20view/residence_info_page.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';

import '../../../view/profile view/family_info_page.dart';
import '../../../view/profile view/personal_info_page.dart';

class UdateProfileController extends GetxController {
  final api = UpdateProfileRepository();
  var currentIndex = 0.obs;
  var showAppBar = false.obs;
  var showDashboardReviewFlag=false.obs;
  var userMaritalStatus="".obs;
  var is_jangana="".obs;
  var membership_approval_status_id="".obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void toggleAppBar(bool value, {bool fromDrawer = false}) {
    showAppBar.value = value;
  }
  var userName = ''.obs;
  var memberId = ''.obs;
  var mobileNumber = ''.obs;
  var lmCode = ''.obs;
  var profileImage = ''.obs;
    Rx<TextEditingController> detailsController = TextEditingController().obs;
   Rx<TextEditingController> organisationNameController = TextEditingController().obs;
   Rx<TextEditingController> udorganisationNameController = TextEditingController().obs;
   Rx<TextEditingController> officePhoneController= TextEditingController().obs;
   Rx<TextEditingController> udofficePhoneController= TextEditingController().obs;
   Rx<TextEditingController> addressbusinessinfoNameController= TextEditingController().obs;
   Rx<TextEditingController> upaddressbusinessinfoNameController= TextEditingController().obs;

   Rx<TextEditingController> addressController = TextEditingController().obs;
   Rx<TextEditingController> areaNameController= TextEditingController().obs;
   Rx<TextEditingController> udareaNameController= TextEditingController().obs;
   Rx<TextEditingController> flatnoController= TextEditingController().obs;
   Rx<TextEditingController> udflatnoController= TextEditingController().obs;

   Rx<TextEditingController> stateNameController = TextEditingController().obs;
   Rx<TextEditingController> countryNameController = TextEditingController().obs;
   Rx<TextEditingController> officePincodeController = TextEditingController().obs;
   Rx<TextEditingController> udofficePincodeController = TextEditingController().obs;
   Rx<TextEditingController> businessEmailController = TextEditingController().obs;
   Rx<TextEditingController> udbusinessEmailController = TextEditingController().obs;
   Rx<TextEditingController> websiteController = TextEditingController().obs;
   Rx<TextEditingController> upwebsiteController = TextEditingController().obs;
   Rx<TextEditingController> occupationController = TextEditingController().obs;
   Rx<TextEditingController> occupation_profession_nameController = TextEditingController().obs;
   Rx<TextEditingController> specialization_nameController = TextEditingController().obs;



  var newProfileImage = "".obs;
  var userdocumentImage = "".obs;
  var newdocumentImage = "".obs;


  void updateProfileImage(String newImageUrl) {
    profileImage.value = newImageUrl;
  }

  var isQualificationDetailVisible = false.obs;
  var isQualificationCategoryVisible = false.obs;

  var firstName = ''.obs;
  var middleName = ''.obs;
  var surName = ''.obs;
  var fathersName = ''.obs;
  var mothersName = ''.obs;

  var whatsAppNumber = ''.obs;
  var email = ''.obs;
  var dob = ''.obs;
  var gender = ''.obs;
  var gender_id = ''.obs;
  var maritalStatus = ''.obs;
  var marital_status_id = ''.obs;
  var isMarried = false.obs;
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
  var addBussinessLoading=false.obs;

  BuildContext? context=Get.context;
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
  var familyloading = false.obs;
  var addloading = false.obs;
  var selectOccuptionPro = ''.obs;
  var organisationName = ''.obs;
  var officePhone = 'Landline Number'.obs;
  var buildingName = 'Building Name'.obs;

  var areaName = ''.obs;
  var city2 = ''.obs;
  var stateName = ''.obs;
  var countryName = ''.obs;
  var officePincode = ''.obs;
  var businessEmail = 'Official Email'.obs;
  var website = 'Official URL'.obs;
  var getUserData = GetProfileData().obs;

  final rxStatusOccupation = Status.LOADING.obs;
  final rxStatusOccupationData = Status.IDLE.obs;
  final rxStatusOccupationSpec = Status.IDLE.obs;
  var occuptionList = <OccupationData>[].obs;
  var occuptionProfessionList = <OccuptionProfessionData>[].obs;
  var occuptionSpeList = <OccuptionSpecData>[].obs;
  var family_head_member_id = "".obs;
  var occupationData=false.obs;

  void setOccuption(List<OccupationData> _value) =>
      occuptionList.value = _value;

  void setOccuptionPro(List<OccuptionProfessionData> _value) =>
      occuptionProfessionList.value = _value;

  setOccuptionSpe(List<OccuptionSpecData> _value) =>
      occuptionSpeList.value = _value;
  void setSelectOccuptionPro(String value) {
    selectOccuptionPro(value);
  }

  void setRxRequestOccuption(Status _value) =>
      rxStatusOccupation.value = _value;

  void setRxRequestOccuptionData(Status _value) =>
      rxStatusOccupationData.value = _value;

  void setRxRequestOccuptionSpec(Status _value) =>
      rxStatusOccupationSpec.value = _value;
  var relationShipTypeList = <RelationData>[].obs;
  Rx<TextEditingController> educationdetailController = TextEditingController().obs;

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

  final Rx<TextEditingController> firstNameController = TextEditingController().obs;
  final Rx<TextEditingController> middleNameController = TextEditingController().obs;
  final Rx<TextEditingController> surNameController = TextEditingController().obs;
  final Rx<TextEditingController> fathersNameController = TextEditingController().obs;
  final Rx<TextEditingController> mothersNameController = TextEditingController().obs;
  final Rx<TextEditingController> mobileNumberController = TextEditingController().obs;
  final Rx<TextEditingController> whatsAppNumberController = TextEditingController().obs;
  final Rx<TextEditingController> emailController = TextEditingController().obs;
  final Rx<TextEditingController> dobController = TextEditingController().obs;
  final Rx<TextEditingController> genderController = TextEditingController().obs;
  final Rx<TextEditingController> maritalStatusController = TextEditingController().obs;
  final Rx<TextEditingController> marriageAnniversaryController = TextEditingController().obs;
  final Rx<TextEditingController> bloodGroupController = TextEditingController().obs;
  Rx<TextEditingController> countryController = TextEditingController().obs;
  Rx<TextEditingController> buildingController = TextEditingController().obs;
  Rx<TextEditingController> flatNoController = TextEditingController().obs;
  Rx<TextEditingController> pincodeController = TextEditingController().obs;
  Rx<TextEditingController> cityController = TextEditingController().obs;
  Rx<TextEditingController> zoneController = TextEditingController().obs;
  Rx<TextEditingController> areaController = TextEditingController().obs;
  Rx<TextEditingController> housenoController = TextEditingController().obs;
  Rx<TextEditingController> stateController = TextEditingController().obs;
  Rx<TextEditingController> updateresidentalAddressController = TextEditingController().obs;
  final Rx<TextEditingController> documentTypeController = TextEditingController().obs;
  final Rx<TextEditingController> documentController = TextEditingController().obs;

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
      userName.value = '${firstName.value} ${middleName.value.isNotEmpty ? middleName.value + " " : ""}${surName.value}';
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
      if(getUserData.value.maritalStatusId.toString()!="")
        {
            userMaritalStatus.value=getUserData.value.maritalStatusId.toString();
        }
      if(getUserData.value.membershipApprovalStatusId.toString()!="")
        {
          membershipApprovalStatusId.value = getUserData.value.membershipApprovalStatusId.toString();
        }
      if(getUserData.value.isJangana.toString()!="")
        {
          isJangana.value = getUserData.value.isJangana.toString();
        }
      checkReviewApproval();
      marriageAnniversaryDate.value = getUserData.value.marriageAnniversaryDate.toString();
      memberCode.value = getUserData.value.memberCode.toString();
      memberSalutaitonId.value = getUserData.value.memberSalutaitonId.toString();
      membershipApprovalStatusId.value = getUserData.value.membershipApprovalStatusId.toString();
      membershipTypeId.value = getUserData.value.membershipTypeId.toString();
      memberStatusId.value = getUserData.value.memberStatusId.toString();
      proposerId.value = getUserData.value.proposerId.toString();
      addressProof.value = getUserData.value.addressProofPath.toString();
      addressProofTypeId.value = getUserData.value.addressProofTypeId.toString();
      otp.value = getUserData.value.otp.toString();
      verifyOtpStatus.value = getUserData.value.verifyOtpStatus.toString();
      mobileVerifyStatus.value = getUserData.value.mobileVerifyStatus.toString();
      sangathanApprovalStatus.value =
          getUserData.value.sangathanApprovalStatus.toString();
      vyavasthapikaApprovalStatus.value =
          getUserData.value.vyavasthapikaApprovalStatus.toString();
      if (getUserData.value.familyHeadMemberData != null) {
        familyHeadMemberId.value = getUserData.value.familyHeadMemberData!.memberId.toString();
      }
      tempId.value = getUserData.value.tempId.toString();
      profileImage.value = getUserData.value.profileImage.toString();
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
      marriageAnniversaryController.value.text = marriageAnniversaryDate.value;
      bloodGroupController.value.text = bloodGroup.value;
      if (getUserData.value.occupation != null) {
        occupationData.value=true;
        organisationName.value = getUserData.value.occupation!.occupationOtherName.toString();

        if(getUserData.value.occupation!.occupationId.toString()!="")
          {
            selectOccuption.value = getUserData.value.occupation!.occupationId.toString();
            getOccupationProData(getUserData.value.occupation!.occupationId.toString());
            isOccutionList.value = true;
            selectOccuptionPro.value = getUserData.value.occupation!.occupationProfessionId.toString();
            if(getUserData.value.occupation!.occupationSpecializationId.toString()!=null) {
              getOccupationSpectData(getUserData.value.occupation!.occupationProfessionId.toString());
              selectOccuptionSpec.value = getUserData.value.occupation!.occupationSpecializationId.toString();

            }


          }
        else
          {
            isOccutionList.value = false;
          }
        if(getUserData.value.occupation!.occupationProfessionId!=null) {
           isOccutionList.value=true;
           occupationController.value.text=getUserData.value.occupation!.occupation.toString();
           occupation_profession_nameController.value.text=getUserData.value.occupation!.occupationProfessionName.toString();
           specialization_nameController.value.text=getUserData.value.occupation!.specializationName.toString();
           getOccupationProData(getUserData.value.occupation!.occupationProfessionId.toString());
           getOccupationSpectData(getUserData.value.occupation!.occupationSpecializationId.toString());
           selectOccuptionSpec.value=getUserData.value.occupation!.occupationSpecializationId.toString();
            selectOccuptionPro.value = getUserData.value.occupation!.occupationProfessionId.toString();
        }
        else {
          isOccutionList.value=false;
        }
        detailsController.value.text = getUserData.value.occupation!.occupationOtherName.toString();
      }
      else
        {
          occupationData.value=false;
        }
      officePhone.value = getUserData.value.mobile.toString();
      if (getUserData.value.qualification != null) {
        qualificationList.value = getUserData.value.qualification!;

      }
      if (getUserData.value.businessInfo != null) {
        businessInfoList.value = getUserData.value.businessInfo!;

      }

      if (getUserData.value.familyMembersData != null) {
        print("hjfhhjj" + getUserData.value.familyMembersData.toString());
        familyDataList.value = getUserData.value.familyMembersData!;
      }



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
  var selectOccuptionSpec = ''.obs;
  var selectOccuption = ''.obs;
  var isOccutionList = false.obs;
  void setSelectOccuptionSpec(String value) {
    selectOccuptionSpec(value);
  }
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
    print("cvv"+qualification_id.toString());
    Map datas = {"qualification_id": qualification_id};
    setRxRequestQualificationMain(Status.LOADING);
    api.userQualificationMain(datas).then((_value) {
      setRxRequestQualificationMain(Status.COMPLETE);
      qulicationMainList.value.add(_value.data!);
      print("cvv"+_value.data!.toString());
     setQualicationMain(qulicationMainList.value);
    }).onError((error, strack) {
      print("cvv"+error.toString());
      setRxRequestQualificationMain(Status.ERROR);
    });
  }

  void getQualicationCategory(String qualification_main_id) {
    print("cvv111"+qualification_main_id.toString());
    Map datas = {"qualification_category_id": qualification_main_id};
    setRxRequestQualificationCat(Status.LOADING);
    api.userQualificationCategory(datas).then((_value) {
      setRxRequestQualificationCat(Status.COMPLETE);
      setQualicationCategory(_value.data!);
    }).onError((error, strack) {
      setRxRequestQualificationCat(Status.ERROR);
      print("cvv"+error.toString());
    });
  }
void checkReviewApproval(){
    if(userMaritalStatus.value=="1" && membership_approval_status_id.value=="6")
      {
        if(isJangana.value=="0")
          {
            showDashboardReviewFlag.value=true;
          }
        else
          {
            showDashboardReviewFlag.value=false;
          }
      }
}
  setRxRequestQualification(Status _value) =>
      rxStatusQualification.value = _value;

  void setRxRequestQualificationMain(Status _value) =>
      rxStatusQualificationMain.value = _value;

  void setRxRequestQualificationCat(Status _value) =>
      rxStatusQualificationCat.value = _value;

  void setRxRelationType(Status _value) => rxStatusRelationType.value = _value;

  void addQualification() async {
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
          Get.snackbar(
            'Success', // Title
            "Add Education Successfully", // Message
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          selectQlification.value="";
          selectQualicationMain.value="";
          selectQualicationCat.value="";
          educationdetailController.value.text="";
          getUserProfile();
          Navigator.of(context!).pop();
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
  void updateQualification() async {
    CheckUserData2? userData = await SessionManager.getSession();
    print('User ID: ${userData?.memberId}');
    print('User Name: ${userData?.mobile}');
    memberId.value = userData!.memberId.toString();
    addloading.value = true;
    try {
      Map map = {
        'member_id':  memberId.value,
        'member_qualification_id': selectQlification.value,
        'qualification_main_id': selectQualicationMain.value,
        'qualification_category_id': selectQualicationCat.value,
        'qualification_other_name': educationdetailController.value.text,
        'updated_by': memberId.value
      };
      //print("fffh"+map.toString());
      api.updateQualification(map).then((_value) async {
        addloading.value = false;
        if (_value['status'] == true) {

          Get.snackbar(
            'Success', // Title
            "Update Education Successfully", // Message
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          getUserProfile();
          Navigator.of(context!).pop();
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
      print("relationdata"+_value.data!.toString());
    }).onError((error, strack) {
      setRxRelationType(Status.ERROR);
      print("relationdata"+error.toString());
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
      await api.updateFamilyRelation(map)
          .then((UpdateFamilyMember _value) async {
        // addloading.value=false;
        //print("gnfg"+_value.message.toString());
        if (_value.status == true) {

          getUserProfile();
          Get.snackbar(
            'Success', // Title
            "Update Relation SuccessFully", // Message
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          getUserProfile();
          Navigator.of(context!).pop();

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

  void addAndupdateOccuption() async {
    CheckUserData2? userData = await SessionManager.getSession();
    print('User ID: ${userData?.memberId}');
    print('User Name: ${userData?.mobile}');
    memberId.value = userData!.memberId.toString();
    //addloading.value=true;
    try {
      Map map = {
        "member_id": memberId.value,
        "occupation_id": selectOccuption.value,
        "occupation_profession_id": selectOccuptionPro.value,
        "occupation_specialization_id": selectOccuptionSpec.value,
        "occupation_other_name": detailsController.value.text,
        "updated_by": "1"
      };
      print("fffh"+map.toString());
      await api.updateOrAddOccuption(map)
          .then((AddOccuptionModel _value) async {
        // addloading.value=false;
        print("gnfg" + _value.message.toString());
        if (_value.status == true) {

          Get.snackbar(
            'Success', // Title
            "Update Relation SuccessFully", // Message
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          getUserProfile();
          Navigator.of(context!).pop();
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
  void updateJanganaStatus() async {
    CheckUserData2? userData = await SessionManager.getSession();
    print('User ID: ${userData?.memberId}');
    print('User Name: ${userData?.mobile}');
    memberId.value = userData!.memberId.toString();
    //addloading.value=true;
    try {
      Map map = {
        "member_id": memberId.value,

      };
      print("fffh"+map.toString());
      await api.userJanganaStatus(map).then((_value) async {
        // addloading.value=false;
        print("gnfg" + _value.message.toString());
        if (_value.status == true) {

          Get.snackbar(
            'Success', // Title
            "Update Jangana SuccessFully", // Message
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          getUserProfile();
          Navigator.pushReplacementNamed(context!, RouteNames.dashboard);
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

    final url = Uri.parse(Urls.updateProfile_url);

    NewMemberController memberController = Get.put(NewMemberController());

    loading.value = true;

    if (marital_status_id.value != "1") {
      marriageAnniversaryController.value.text = "";
    }

    Map<String, String> payload = {
      "member_id": userData!.memberId.toString(),
      "first_name": firstNameController.value.text,
      "last_name": surNameController.value.text,
      "middle_name": middleNameController.value.text,
      "father_name": fathersNameController.value.text,
      "mother_name": mothersNameController.value.text,
      "email": emailController.value.text.trim(),
      "whatsapp_number": whatsAppNumberController.value.text.trim(),
      "gender_id": gender_id.value,
      "marital_status_id": marital_status_id.value,
      "blood_group_id": blood_group_id.value,
      "dob": dobController.value.text.trim(),
      "marriage_anniversary_date":
      marriageAnniversaryController.value.text,
      "salutation_id": memberSalutaitonId.value,
    };

    var request = http.MultipartRequest('POST', url);
    request.fields.addAll(payload);

    print("Profile Image Path: ${newProfileImage.value}");
    if (newProfileImage.value.isNotEmpty) {
      print("Uploading Image...");
      request.files.add(
        await http.MultipartFile.fromPath(
            "profile_image", newProfileImage.value),
      );
    } else {
      print("No image to upload.");
    }


    http.StreamedResponse response =
    await request.send().timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      loading.value = false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

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
          getUserProfile();
        Navigator.of(context!).pop();

      } else {
        Get.snackbar(
          "Error",
          registerResponse.toString(),
          backgroundColor:
          ColorHelperClass.getColorFromHex(ColorResources.red_color),
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
      RegisterModelClass registerResponse =  RegisterModelClass.fromJson(jsonResponse);

      Get.snackbar(
        "Error",
        "" + jsonResponse.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void userResidentalProfile(BuildContext context) async {
    CheckUserData2? userData = await SessionManager.getSession();

    final url = Uri.parse(Urls.updateMemberAddress_url);
    print("vcgdhfh" + Urls.updateMemberAddress_url+"ggg"+updateresidentalAddressController.value.text);
    NewMemberController regiController = Get.put(NewMemberController());

    loading.value = true;
    var area="";
if(regiController.area_name.value=="")
  {
    area=regiController.area_name.value;
  }
else
  {
    area= regiController.areaController.value.text;
  }

    var building_name = buildingController.value.text;
    var building_id = "";

    if (regiController.selectBuilding.value == "other") {
      building_id = "";
    }
    else {
      building_id = regiController.selectBuilding.value;
    }
    var document_type = regiController.selectDocumentType.value;
    var document_image = userdocumentImage.value;
    print("vvb" + document_image);

    var payload = {
      "member_id": userData!.memberId.toString(),
      "flat_no": flatNoController.value.text.toString(),
      "area": area,
      "building_id": building_id,
      "zone_id": regiController.zone_id.value,
      "city_id": regiController.city_id.value,
      "state_id": regiController.state_id.value,
      "country_id": regiController.country_id.value,
      "document_type": document_type,
      "address": updateresidentalAddressController.value.text,
      "pincode": pincodeController.value.text,

      "updated_by": userData!.memberId.toString()
    };

    print("ccvv" + payload.toString());
    var request = http.MultipartRequest('POST', url);
    request.fields.addAll(payload);
    if(document_image!="") {
      request.files.add(
          await http.MultipartFile.fromPath('document_image', document_image));
    }
    http.StreamedResponse response = await request.send().timeout(
        Duration(seconds: 60));
    //
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      loading.value = false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      print("ccvv" + jsonResponse.toString());
      RegisterModelClass registerResponse = RegisterModelClass.fromJson(
          jsonResponse);
      if (registerResponse.status == true) {
        Get.snackbar(
          "Success",
          "Update Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        pincodeController.value.text="";
        getUserProfile();
        Navigator.of(context!).pop();
      }
      else {
        Get.snackbar(
          "Error",
          registerResponse.message.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
    else {
      loading.value = false;
      print("ccvv" + await response.reasonPhrase.toString());
       String responseBody = await response.stream.bytesToString();
      print("" +responseBody);
      // loading.value=false;
      // Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      // RegisterModelClass registerResponse = RegisterModelClass.fromJson(jsonResponse);
      //
      // Get.snackbar(
      //   "Error",
      //   ""+registerResponse.message.toString(),
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.TOP,
      // );
    }


  }

  void userAddFamily() async {
    CheckUserData2? userData = await SessionManager.getSession();

    final url = Uri.parse(Urls.addmemberorfamily_url);
    print("vcgdhfh" + Urls.addmemberorfamily_url);
    NewMemberController regiController = Get.put(NewMemberController());

    familyloading.value = true;


    var building_name = buildingController.value.text;
    var building_id = "";

    if (regiController.selectBuilding.value == "other") {
      building_id = "";
    }
    else {
      building_id = regiController.selectBuilding.value;
    }
    var document_type = regiController.selectDocumentType.value;
    var document_image = userdocumentImage.value;
    var marital_status_id = regiController.selectMarital.value;
    print("vvb" + document_image);

    Map<String, String> payload = {
      "proposer_id": userData!.memberId.toString(),
      "first_name": regiController.firstNameController.value.text,
      "last_name": regiController.lastNameController.value.text,
          "middle_name": regiController.middleNameController.value.text,
      "father_name": regiController.fathersnameController.value.text,
      "mother_name": regiController.mothersnameController.value.text,
      "email": regiController.emailController.value.text,
      "whatsapp_number": regiController.whatappmobileController.value.text,
      "mobile": regiController.mobileController.value.text,
      "gender_id": regiController.selectedGender.value,
      "marital_status_id": marital_status_id,
      "blood_group_id": regiController.selectBloodGroup.value,
      "dob": regiController.dateController.text,
      "family_head_member_id": familyHeadMemberId.value,
      "relation_id": selectRelationShipType.value,
      "member_type_id": regiController.selectMemberShipType.value,
      "marriage_anniversary_date": regiController.marriagedateController.value.text,
      "salutation_id": regiController.selectMemberSalutation.value,
      "created_by": "1"
    };
    print("ccvv" + payload.toString());
    var request = http.MultipartRequest('POST', url);
    request.fields.addAll(payload);
    if(document_image!="") {
      request.files.add(
          await http.MultipartFile.fromPath('profile_image', document_image));
    }
    http.StreamedResponse response = await request.send().timeout(
        Duration(seconds: 60));
    //
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      familyloading.value = false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      print("ccvv" + jsonResponse.toString());
      RegisterModelClass registerResponse = RegisterModelClass.fromJson(
          jsonResponse);
      if (registerResponse.status == true) {
        Get.snackbar(
          "Success",
          "Update Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        regiController.firstNameController.value.text="";
        regiController.lastNameController.value.text="";
        regiController.middleNameController.value.text="";
        regiController.fathersnameController.value.text="";
        regiController.mothersnameController.value.text="";
        regiController.emailController.value.text="";
        regiController.whatappmobileController.value.text="";
       // regiController.mobileController.value.text="";
        regiController.selectedGender.value="";
        regiController.selectBloodGroup.value="";
        regiController.dateController.text="";

        selectRelationShipType.value="";
        regiController.selectMarital.value="";
        regiController.marriagedateController.value.text="";
        regiController.selectMemberSalutation.value="";
        regiController.selectMemberSalutation.value="";
        getUserProfile();
         sendOtp(regiController.mobileController.value.text);
        Navigator.of(context!).pop();
        showOtpBottomSheet(context!,regiController.mobileController.value.text);
        regiController.mobileController.value.text="";
      }
      else {
        Get.snackbar(
          "Error",
          registerResponse.message.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
    else {
      familyloading.value = false;
     // print("ccvv" + await response.reasonPhrase.toString());
      //  String responseBody = await response.stream.bytesToString();
      print("ccvv" + await response.stream.bytesToString());
      // loading.value=false;
      // Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      //  RegisterModelClass registerResponse = RegisterModelClass.fromJson(jsonResponse);
      // //
      // Get.snackbar(
      //   "Error",
      //   ""+registerResponse.message.toString(),
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.TOP,
      // );
    }
  }
  final api2 = RegisterRepository();
  var family_member_id="".obs;
  void sendOtp(var mobile) async {

    try {
      Map<String,String> map={
        "mobile_number":mobile
      };
      api2.sendOTP(map).then((_value) async {
        if(_value.status==true)
        {
          Get.snackbar(
            "Success",
            "Send Otp Successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          family_member_id.value=  _value.data!.memberId.toString();
        }
        else
        {

        }

      }).onError((error, strack) async {
        Get.snackbar(
          'Error', // Title
          error.toString(), // Message
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.pink,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

      });
    } catch (e) {
      print('Error: $e');
    } finally {

    }
  }

  void checkOtp(var otps, BuildContext context) {
    try {
      Map map={
        "member_id":family_member_id.value,
        "otp":otps
      };
      api2.verifyOTP(map).then((_value) async {
        if(_value.status==true)
        {

          Get.snackbar(
            'Success', // Title
            'OTP matched', // Message
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          Navigator.of(context!).pop();
        }
        else
        {

        }
      }).onError((error, strack) async {
        print("fvvf"+error.toString());
        if(error.toString().contains("Sorry! OTP doesn't match"))
        {
          Get.snackbar(
            'Error', // Title
            "Sorry! OTP doesn't match", // Message
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.pink,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
        else {
          Get.snackbar(
            'Error', // Title
            "Some thing went wrong ", // Message
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.pink,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      });
    } catch (e) {
      print('Error: $e');
    } finally {

    }


  }

  void userAddBuniessInfo() async {
    CheckUserData2? userData = await SessionManager.getSession();
    NewMemberController memberController = Get.put(NewMemberController());
    addBussinessLoading.value=true;
    memberId.value = userData!.memberId.toString();

    try {
      var payload={
        'member_id': memberId.value,
        'organisation_name': organisationNameController.value.text,
        'office_phone': officePhoneController.value.text,
        'business_email': businessEmailController.value.text,
        'website': websiteController.value.text,
        'flat_no': flatnoController.value.text,
        'address': addressbusinessinfoNameController.value.text,
        'area': areaNameController.value.text,
        'city_id': memberController.city_id.value,
        'state_id': memberController.state_id.value,
        'country_id': memberController.country_id.value,
        'created_by': '1',
        'pincode':  officePincodeController.value.text
      };
      print("fffh"+payload.toString());
      await api.userAddBusiness(payload)
          .then((dynamic _value) async {
        print("fffh2"+_value.toString());
        if (_value['status'] == true) {
          print("fffh"+ _value['message'].toString());
          Get.snackbar(
            'Success', // Title
            _value['message'], // Message
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          organisationNameController.value.text="";
          officePhoneController.value.text="";
          businessEmailController.value.text="";
          websiteController.value.text="";
          flatnoController.value.text="";
          addressbusinessinfoNameController.value.text="";
          areaNameController.value.text="";
          memberController.city_id.value="";
          memberController.state_id.value="";
          memberController.country_id.value="";
          officePincodeController.value.text="";

          getUserProfile();
          addBussinessLoading.value=false;
          Navigator.pop(context!,"");
        }
      }).onError((error, strack) async {
        addBussinessLoading.value=false;
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
      addBussinessLoading.value=false;
      print('Error: $e');
    } finally {}


  }
  void userUpdateBuniessInfo(BusinessInfo bussinessinfo) async {
    CheckUserData2? userData = await SessionManager.getSession();
    NewMemberController memberController = Get.put(NewMemberController());
    addloading.value=true;
    memberId.value = userData!.memberId.toString();

    try {
      var map={
        'member_id': memberId.value,
        'organisation_name': udorganisationNameController.value.text,
        'office_phone': udofficePhoneController.value.text,
        'business_email': udbusinessEmailController.value.text,
        'website':  upwebsiteController.value.text,
        'flat_no': udflatnoController.value.text,
        'address': upaddressbusinessinfoNameController.value.text,
        'area': udareaNameController.value.text,
        'city_id': memberController.city_id.value,
        'state_id': memberController.state_id.value,
        'country_id': memberController.country_id.value,
        'created_by': '1',
        'pincode': udofficePincodeController.value.text,
        'member_address_id': bussinessinfo.memberAddressId.toString(),
        'member_business_info_id': bussinessinfo.membersBusinessInfoId.toString()
      };
      print("fffh"+map.toString());
      await api.userUpdateBusiness(map)
          .then((dynamic _value) async {
        print("fffh2"+_value.toString());
        if (_value['status'] == true) {
          print("fffh"+ _value['message'].toString());
          Get.snackbar(
            'Success', // Title
            _value['message'], // Message
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          getUserProfile();
          addloading.value=false;
          Navigator.of(context!).pop();
        }
      }).onError((error, strack) async {
        addloading.value=false;
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
  void showOtpBottomSheet(BuildContext context, String mobile) {
    final TextEditingController otpController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // Ensure the bottom sheet is scrollable
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard height
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use minimum height
            children: [
              const SizedBox(height: 20),
              const Text(
                "Enter OTP",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter OTP",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Resend OTP logic
                        resendOtp(context,mobile);
                      },
                      child: const Text(
                        "Resend OTP",
                        style: TextStyle(color: Color(0xFFe61428)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Submit OTP logic
                        checkOtp(otpController.text,context!);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                      ),
                      child: const Text(
                        "Submit OTP",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Add extra space at the bottom
            ],
          ),
        );
      },
    );
  }
  void resendOtp(BuildContext context,String mobile) {
    sendOtp(mobile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP Resent Successfully")),
    );
  }
}


