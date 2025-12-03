import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/OccuptionProfession/OccuptionProfessionData.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/AddExistingFamilyMember/addExistingFamilyMemberData.dart';
import 'package:mpm/model/BusinessProfile/GetAllBusinessOccupationProfile/GetAllBusinessOccupationProfileModelClass.dart';
import 'package:mpm/model/BusinessProfile/GetAllOccupationProduct/GetAllOccupationProductModelClass.dart';
import 'package:mpm/model/ChangeFamilyHead/changeFamilyHeadData.dart';
import 'package:mpm/model/CheckPinCode/Building.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/model/GetProfile/BusinessInfo.dart';
import 'package:mpm/model/GetProfile/FamilyHeadMemberData.dart';
import 'package:mpm/model/GetProfile/FamilyMembersData.dart';
import 'package:mpm/model/GetProfile/GetProfileData.dart';
import 'package:mpm/model/GetProfile/Occupation.dart';
import 'package:mpm/model/GetProfile/Qualification.dart';
import 'package:mpm/model/Occupation/OccupationData.dart';
import 'package:mpm/model/OccupationSpec/OccuptionSpecData.dart';
import 'package:mpm/model/OccuptionSpecSubCategory/OccuptionSpecSubCategoryData.dart';
import 'package:mpm/model/OccuptionSpecSubSubCategory/OccuptionSpecSubSubCategoryData.dart';
import 'package:mpm/model/ProductCategory/ProductCategoryData.dart';
import 'package:mpm/model/ProductSubcategory/ProductSubcategoryData.dart';
import 'package:mpm/model/Qualification/QualificationData.dart';
import 'package:mpm/model/QualificationCategory/QualificationCategoryModel.dart';
import 'package:mpm/model/QualificationMain/QualicationMainData.dart';
import 'package:mpm/model/Register/RegisterModelClass.dart';
import 'package:mpm/model/SaraswaniOption/SaraswaniOptionData.dart';
import 'package:mpm/model/UpdateFamilyRelation/UpdateFamilyMember.dart';
import 'package:mpm/model/relation/RelationData.dart';
import 'package:mpm/repository/BusinessProfileRepo/add_occupation_business_repository/add_occupation_business_repo.dart';
import 'package:mpm/repository/BusinessProfileRepo/delete_occupation_business_repository/delete_occupation_business_repo.dart';
import 'package:mpm/repository/BusinessProfileRepo/get_occupation_product_by_id_repository/get_occupation_product_by_id_repo.dart';
import 'package:mpm/repository/BusinessProfileRepo/update_occupation_business_repository/update_occupation_business_repo.dart';
import 'package:mpm/repository/add_existing_family_member_repository/add_existing_family_member_repo.dart';
import 'package:mpm/repository/add_occupation_repository/add_occupation_repo.dart';
import 'package:mpm/repository/change_family_head_repository/change_family_head_repo.dart';
import 'package:mpm/repository/product_category_repository/product_category_repo.dart';
import 'package:mpm/repository/product_subcategory_repository/product_subcategory_repo.dart';
import 'package:mpm/repository/register_repository/register_repo.dart';
import 'package:mpm/repository/send_verification_email_repository/send_verification_email_repo.dart';
import 'package:mpm/repository/update_repository/UpdateProfileRepository.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/notification/NotificationApiController.dart';
import '../../../repository/BusinessProfileRepo/get_all_business_occupation_profile_repository/get_all_business_occupation_profile_repo.dart';

class UdateProfileController extends GetxController {
  final api = UpdateProfileRepository();
  var currentIndex = 0.obs;
  var showAppBar = false.obs;
  var showDashboardReviewFlag = false.obs;
  var userMaritalStatus = "".obs;
  var is_jangana = "".obs;
  var emailVerifyStatus = "".obs;
  var emailVerificationStatus = 0.obs;
  var membership_approval_status_id = "".obs;
  var documentDynamicImage = "".obs;
  var isLoadingPayment = false.obs;
  final AddExistingMemberIntoFamilyRepository addExistingMemberRepo =
      AddExistingMemberIntoFamilyRepository();
  final ChangeFamilyHeadRepository _changeHeadRepo =
      ChangeFamilyHeadRepository();
  final addOccupationRepo = AddOccupationRepository();

  var isPay = false.obs;
  RxBool showEmailVerifyBanner = false.obs;

  void changeTab(int index) async {
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
  Rx<TextEditingController> organisationNameController =
      TextEditingController().obs;
  Rx<TextEditingController> udorganisationNameController =
      TextEditingController().obs;
  Rx<TextEditingController> officePhoneController = TextEditingController().obs;
  Rx<TextEditingController> udofficePhoneController =
      TextEditingController().obs;
  Rx<TextEditingController> addressbusinessinfoNameController =
      TextEditingController().obs;
  Rx<TextEditingController> upaddressbusinessinfoNameController =
      TextEditingController().obs;

  Rx<TextEditingController> addressController = TextEditingController().obs;
  Rx<TextEditingController> areaNameController = TextEditingController().obs;
  Rx<TextEditingController> udareaNameController = TextEditingController().obs;
  Rx<TextEditingController> flatnoController = TextEditingController().obs;
  Rx<TextEditingController> udflatnoController = TextEditingController().obs;

  Rx<TextEditingController> stateNameController = TextEditingController().obs;
  Rx<TextEditingController> countryNameController = TextEditingController().obs;
  Rx<TextEditingController> officePincodeController =
      TextEditingController().obs;
  Rx<TextEditingController> udofficePincodeController =
      TextEditingController().obs;
  // Rx<TextEditingController> businessEmailController =
  //     TextEditingController().obs;
  Rx<TextEditingController> udbusinessEmailController =
      TextEditingController().obs;
  Rx<TextEditingController> websiteController = TextEditingController().obs;
  Rx<TextEditingController> upwebsiteController = TextEditingController().obs;
  Rx<TextEditingController> occupationController = TextEditingController().obs;
  Rx<TextEditingController> occupation_profession_nameController =
      TextEditingController().obs;
  Rx<TextEditingController> specialization_nameController =
      TextEditingController().obs;
  Rx<TextEditingController> specialization_sub_nameController =
      TextEditingController().obs;
  Rx<TextEditingController> specialization_sub_sub_nameController =
      TextEditingController().obs;
  RxList<OccuptionSpecSubCategoryData> occuptionSubCategoryList =
      <OccuptionSpecSubCategoryData>[].obs;
  RxString selectedSubCategory = "".obs;
  final RxString selectedSubSubCategory = ''.obs;
  final RxList<OccuptionSpecSubSubCategoryData> occuptionSubSubCategoryList = <OccuptionSpecSubSubCategoryData>[].obs;


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
  var saraswaniOption = ''.obs;
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
  var addBussinessLoading = false.obs;
  var selectMarital = ''.obs;
  BuildContext? context = Get.context;
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
  var occupationData = false.obs;
  var occupationProData = false.obs;

  void setOccuption(List<OccupationData> _value) =>
      occuptionList.value = _value;

  void setOccuptionPro(List<OccuptionProfessionData> _value) =>
      occuptionProfessionList.value = _value;

  setOccuptionSpe(List<OccuptionSpecData> _value) =>
      occuptionSpeList.value = _value;
  void setSelectOccuptionPro(String value) {
    selectOccuptionPro.value = value;
  }

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
  var familyHeadData = Rxn<FamilyHeadMemberData>();
  RxString selectedMemberId = "".obs;

  var areaDataList = <FamilyMembersData>[].obs;
  var selectRelationShipType = ''.obs;
  var occuptionFlag = false.obs;
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
  final Rx<TextEditingController> marriageAnniversaryController =
      TextEditingController().obs;
  final Rx<TextEditingController> bloodGroupController =
      TextEditingController().obs;
  final saraswaniOptionController = TextEditingController();
  RxList<SaraswaniOptionData> saraswaniOptionList = <SaraswaniOptionData>[].obs;
  Rx<TextEditingController> countryController = TextEditingController().obs;
  Rx<TextEditingController> buildingController = TextEditingController().obs;
  Rx<TextEditingController> flatNoController = TextEditingController().obs;
  Rx<TextEditingController> pincodeController = TextEditingController().obs;
  Rx<TextEditingController> cityController = TextEditingController().obs;
  Rx<TextEditingController> zoneController = TextEditingController().obs;
  Rx<TextEditingController> areaController = TextEditingController().obs;
  Rx<TextEditingController> housenoController = TextEditingController().obs;
  Rx<TextEditingController> stateController = TextEditingController().obs;
  Rx<TextEditingController> updateresidentalAddressController =
      TextEditingController().obs;
  final Rx<TextEditingController> documentTypeController =
      TextEditingController().obs;
  final Rx<TextEditingController> documentController =
      TextEditingController().obs;
  var MaritalAnnivery = false.obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  void setSelectRelationShip(String value) {
    selectRelationShipType(value);
  }

  Future<void> getUserProfile() async {
    try {
      CheckUserData2? userData = await SessionManager.getSession();
      if (userData == null || userData.memberId == null) {
        loading.value = false;
        Get.snackbar(
          'Error',
          'Please login again',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      loading.value = true;
      var id = userData.memberId.toString();
      
      if (id.isEmpty) {
        loading.value = false;
        Get.snackbar(
          'Error',
          'Member ID is missing',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      final _value = await api.getUserData(id);
      loading.value = false;
      
      if (_value.data == null) {
        Get.snackbar(
          'Error',
          'Failed to load profile data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      getUserData.value = _value.data!;
      memberId.value = id.toString();
      fathersName.value = getUserData.value.fatherName.toString();
      firstName.value = getUserData.value.firstName.toString();
      middleName.value = getUserData.value.middleName.toString();
      surName.value = getUserData.value.lastName.toString();
      userName.value =
          '${firstName.value} ${middleName.value.isNotEmpty ? middleName.value + " " : ""}${surName.value}';
      mothersName.value = getUserData.value.motherName.toString();
      mobileNumber.value = getUserData.value.mobile.toString();
      email.value = getUserData.value.email.toString();
      emailVerifyStatus.value = getUserData.value.emailVerifyStatus.toString();
      showEmailVerifyBanner.value = emailVerifyStatus.value == "0";
      dob.value = getUserData.value.dob.toString();
      maritalStatus.value = getUserData.value.maritalStatus.toString();
      marital_status_id.value = getUserData.value.maritalStatusId.toString();
      gender.value = getUserData.value.genderName.toString();
      gender_id.value = getUserData.value.genderId.toString();
      if (getUserData.value.maritalStatusId.toString() != "") {
        selectMarital.value = getUserData.value.maritalStatusId.toString();
        if (getUserData.value.maritalStatus == "Married") {
          MaritalAnnivery.value = true;
        } else {
          MaritalAnnivery.value = false;
        }
      }
      if (getUserData.value.addressProof != "") {
        if (getUserData.value.addressProof != null) {
          documentDynamicImage.value =
              Urls.imagePathUrl + getUserData.value.addressProof!;
        } else {
          documentDynamicImage.value = '';
        }
      }
      saraswaniOption.value =
          getUserData.value.saraswaniOption?.toString() ?? 'Not selected';
      saraswaniOptionController.text = saraswaniOption.value;
      saraswaniOptionId.value =
          getUserData.value.saraswaniOptionId?.toString() ?? '';

      bloodGroup.value = getUserData.value.bloodGroup.toString();
      blood_group_id.value = getUserData.value.bloodGroupId.toString();
      whatsAppNumber.value = getUserData.value.whatsappNumber.toString();
      if (getUserData.value.maritalStatusId.toString() != "") {
        userMaritalStatus.value = getUserData.value.maritalStatusId.toString();
      }
      if (getUserData.value.membershipApprovalStatusId.toString() != "") {
        membershipApprovalStatusId.value =
            getUserData.value.membershipApprovalStatusId.toString();
      }
      if (getUserData.value.isJangana.toString() != "") {
        isJangana.value = getUserData.value.isJangana.toString();
      }
      checkReviewApproval();
      marriageAnniversaryDate.value =
          getUserData.value.marriageAnniversaryDate.toString();
      memberCode.value = getUserData.value.memberCode.toString();
      memberSalutaitonId.value =
          getUserData.value.memberSalutaitonId.toString();

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
      if (getUserData.value.familyHeadMemberData != null) {
        familyHeadMemberId.value =
            getUserData.value.familyHeadMemberData!.memberId.toString();
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
      saraswaniOptionController.text = saraswaniOptionId.value;
      saraswaniOptionController.text = saraswaniOption.value;

      // Occupation
      // In UdateProfileController - Update the occupation section

// Occupation
      if (getUserData.value.occupation != null && getUserData.value.occupation!.isNotEmpty) {
        // For backward compatibility, set the first occupation as current
        if (getUserData.value.occupation!.isNotEmpty) {
          currentOccupation.value = getUserData.value.occupation!.first;
          hasOccupationData.value = true;

          // Update all occupation fields including null checks - use .first to get the first occupation
          occupationController.value.text =
              getUserData.value.occupation!.first.occupation ?? '';
          occupation_profession_nameController.value.text =
              getUserData.value.occupation!.first.occupationProfessionName ?? '';
          specialization_nameController.value.text =
              getUserData.value.occupation!.first.specializationName ?? '';
          specialization_sub_nameController.value.text =
              getUserData.value.occupation!.first.specializationSubCategoryName ?? '';
          specialization_sub_sub_nameController.value.text =
              getUserData.value.occupation!.first.specializationSubSubCategoryName ?? '';
          detailsController.value.text =
              getUserData.value.occupation!.first.occupationOtherName ?? '';
        }
      }
      var member_type_id = getUserData.value.membershipTypeId.toString();
      var memberapprovalstatusid =
          getUserData.value.membershipApprovalStatusId.toString();
      var isPaymentStatus = getUserData.value.isPaymentReceived.toString();
      if (member_type_id == "1" || member_type_id == "3") {
        if (int.parse(memberapprovalstatusid) < 2 && isPaymentStatus == "0") {
          isPay.value = true;
        } else {
          isPay.value = false;
        }
      } else {
        isPay.value = false;
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

      if (getUserData.value.familyHeadMemberData != null) {
        familyHeadMemberId.value =
            getUserData.value.familyHeadMemberData!.memberId.toString();
        familyHeadData.value = getUserData.value.familyHeadMemberData!;
      }
    } catch (error, stackTrace) {
      loading.value = false;
      Get.snackbar(
        'Error',
        'Failed to load profile: ${error.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    }
  }

  void isPayButton() {}

  // In UdateProfileController - Add this method
  List<Occupation> get allOccupations {
    return getUserData.value.occupation ?? [];
  }

// Optional: Keep currentOccupation for backward compatibility but update its usage
  Occupation? get firstOccupation {
    return getUserData.value.occupation != null && getUserData.value.occupation!.isNotEmpty
        ? getUserData.value.occupation!.first
        : null;
  }

  // Occupation Controller
  final Rx<Occupation?> currentOccupation = Rx<Occupation?>(null);
  final RxBool hasOccupationData = false.obs;
  final RxString selectedOccupation = RxString('');
  final RxString selectedProfession = RxString('');
  final RxString selectedSpecialization = RxString('');
  final RxBool showDetailsField = RxBool(false);
  final RxBool isOccupationLoading = RxBool(false);

  void resetDependentFields() {
    selectedProfession.value = '';
    selectedSpecialization.value = '';
    showDetailsField.value = false;
    occuptionProfessionList.clear();
    occuptionSpeList.clear();
  }

  Future<void> getOccupationData() async {
    try {
      rxStatusOccupation.value = Status.LOADING;
      final response = await api.userOccupationDataApi();
      occuptionList.value = response.data ?? [];

      occuptionList.add(OccupationData(
        id: "0",
        occupation: 'Other',
        status: '1',
        createdAt: null,
        updatedAt: null,
      ));

      rxStatusOccupation.value = Status.COMPLETE;
    } catch (error) {
      rxStatusOccupation.value = Status.ERROR;
      Get.snackbar(
        'Error',
        'Failed to load occupations',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> getOccupationProData(String occupationId) async {
    if (occupationId.isEmpty) return;

    try {
      rxStatusOccupationData.value = Status.LOADING;
      final response =
          await api.userOccutionPreCodeApi({"occupation_id": occupationId});
      occuptionProfessionList.value = response.data ?? [];

      if (occuptionProfessionList.isEmpty) {
        showDetailsField.value = true;
      } else {
        occuptionProfessionList.add(OccuptionProfessionData(
          id: "Other",
          name: "Other",
          occupationId: occupationId,
          status: '1',
          createdAt: null,
          updatedAt: null,
        ));
      }

      rxStatusOccupationData.value = Status.COMPLETE;
    } catch (error) {
      rxStatusOccupationData.value = Status.ERROR;
      Get.snackbar(
        'Error',
        'Failed to load professions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> getOccupationSpectData(String professionId) async {
    if (professionId.isEmpty) return;

    try {
      rxStatusOccupationSpec.value = Status.LOADING;
      final response = await api.userOccutionSpectionCodeApi(
          {"occupation_profession_id": professionId});
      occuptionSpeList.value = response.data ?? [];

      if (occuptionSpeList.isEmpty) {
        showDetailsField.value = true;
      } else {
        occuptionSpeList.add(OccuptionSpecData(
          id: "Other",
          name: "Other",
          occupationId: professionId,
          status: '1',
          createdAt: null,
          updatedAt: null,
        ));
      }

      rxStatusOccupationSpec.value = Status.COMPLETE;
    } catch (error) {
      rxStatusOccupationSpec.value = Status.ERROR;
      Get.snackbar(
        'Error',
        'Failed to load specializations',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> getOccupationSpecializationSubCategoryData(String specId) async {
    if (specId.isEmpty) return;

    try {
      rxStatusOccupationSpec.value = Status.LOADING;

      final response = await api.userOccutionSpectionSubCategoryApi(specId);
      occuptionSubCategoryList.value = response.data ?? [];

      if (occuptionSubCategoryList.isEmpty) {
        showDetailsField.value = true;
      } else {
        // Add "Other" option only if it doesn't exist
        if (!occuptionSubCategoryList
            .any((sub) => sub.specializationSubCategoryId == "Other")) {
          occuptionSubCategoryList.add(
            OccuptionSpecSubCategoryData(
              specializationSubCategoryId: "Other",
              specializationId: specId,
              specializationSubCategoryName: "Other",
              status: "1",
              createdAt: null,
              updatedAt: null,
            ),
          );
        }
      }

      rxStatusOccupationSpec.value = Status.COMPLETE;
    } catch (e) {
      rxStatusOccupationSpec.value = Status.ERROR;
      Get.snackbar(
        'Error',
        'Failed to load specialization sub-category',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> getOccupationSubSubCategoryData(String subCategoryId) async {
    if (subCategoryId.isEmpty) return;

    try {
      rxStatusOccupationSpec.value = Status.LOADING;

      final response = await api.userOccutionSpecializationSubSubCategoryApi(subCategoryId);
      occuptionSubSubCategoryList.value = response.data ?? [];

      if (occuptionSubSubCategoryList.isEmpty) {
        showDetailsField.value = true;
      } else {
        // Add “Other” option
        if (!occuptionSubSubCategoryList
            .any((item) => item.subSubCategoryId == "Other")) {
          occuptionSubSubCategoryList.add(
            OccuptionSpecSubSubCategoryData(
              subSubCategoryId: "Other",
              subCategoryId: subCategoryId,
              subSubCategoryName: "Other",
              status: "1",
            ),
          );
        }
      }

      rxStatusOccupationSpec.value = Status.COMPLETE;
    } catch (e) {
      rxStatusOccupationSpec.value = Status.ERROR;
      Get.snackbar(
        'Error',
        'Failed to load sub-sub-category',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> addOccupation() async {
    try {
      isOccupationLoading.value = true;

      final userData = await SessionManager.getSession();
      if (userData == null) throw Exception("User not logged in");

      if (selectedOccupation.value.isEmpty) {
        throw Exception("Please select an occupation");
      }

      // Handle dropdown values
      String occupationId = selectedOccupation.value;
      String professionId = (selectedProfession.value == "Other") ? "" : selectedProfession.value;
      String specializationId = (selectedSpecialization.value == "Other") ? "" : selectedSpecialization.value;
      String subCategoryId = (selectedSubCategory.value == "Other") ? "" : selectedSubCategory.value;
      String subSubCategoryId = (selectedSubSubCategory.value == "Other") ? "" : selectedSubSubCategory.value;

      // Final "Other Details"
      String otherName = showDetailsField.value ? detailsController.value.text : "";

      final Map<String, dynamic> data = {
        "member_id": userData.memberId.toString(),
        "occupation_id": occupationId,
        "occupation_profession_id": professionId,
        "occupation_specialization_id": specializationId,
        "occupation_specialization_sub_category_id": subCategoryId,
        "occupation_specialization_sub_sub_category_id": subSubCategoryId,
        "occupation_other_name": otherName,
        "created_by": userData.memberId.toString()
      };

      print("📤 Add Occupation Payload: $data");

      // Call Add repository
      final response = await addOccupationRepo.addOccupation(data);

      if (response.status == true) {
        Get.snackbar(
          'Success',
          response.message ?? "Occupation added successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        getUserProfile();
        Navigator.of(context!).pop();

        // ⚡ Reset fields after success
        selectedOccupation.value = "";
        selectedProfession.value = "";
        selectedSpecialization.value = "";
        selectedSubCategory.value = "";
        selectedSubSubCategory.value = "";
        detailsController.value.text = "";
        showDetailsField.value = false;

      } else {
        throw Exception(response.message ?? "Failed to add occupation");
      }
    } catch (e) {
      print("❌ Add Occupation Error: $e");

      Get.snackbar(
        'Error',
        e.toString().replaceAll("Exception:", "").trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isOccupationLoading.value = false;
    }
  }

  void initOccupationData(Occupation? occupation) {
    resetDependentFields();
    detailsController.value.clear();
    selectedSubCategory.value = "";

    if (occupation == null) return;

    selectedOccupation.value = occupation.occupationId ?? '';
    detailsController.value.text = occupation.occupationOtherName ?? '';

    if (selectedOccupation.value == "0") {
      showDetailsField.value = true;
      return;
    }

    getOccupationProData(selectedOccupation.value).then((_) {
      if (occupation.occupationProfessionId != null &&
          occupation.occupationProfessionId!.isNotEmpty) {
        selectedProfession.value = occupation.occupationProfessionId!;

        if (selectedProfession.value == "Other") {
          showDetailsField.value = true;
          return;
        }

        getOccupationSpectData(selectedProfession.value).then((_) {
          if (occupation.occupationSpecializationId != null &&
              occupation.occupationSpecializationId!.isNotEmpty) {
            selectedSpecialization.value =
                occupation.occupationSpecializationId!;

            // Load sub-categories if specialization exists
            getOccupationSpecializationSubCategoryData(
                    selectedSpecialization.value)
                .then((_) {
              if (occupation.occupationSpecializationSubCategoryId != null &&
                  occupation
                      .occupationSpecializationSubCategoryId!.isNotEmpty) {
                selectedSubCategory.value =
                    occupation.occupationSpecializationSubCategoryId!;

                if (selectedSubCategory.value == "Other") {
                  showDetailsField.value = true;
                } else {
                  showDetailsField.value = false;
                }
              } else {
                selectedSubCategory.value = "Other";
                showDetailsField.value = true;
              }
            });
          } else {
            selectedSpecialization.value = "Other";
            showDetailsField.value = true;
          }
        });
      } else {
        selectedProfession.value = "Other";
        showDetailsField.value = true;
      }
    });
  }

  // Business Product Category and subcategory

  final ProductCategoryRepository categoryRepo = ProductCategoryRepository();
  final ProductSubcategoryRepository subRepo = ProductSubcategoryRepository();

  /// Reactive Variables
  var categories = <ProductCategoryData>[].obs;
  var subcategories = <ProductSubcategoryData>[].obs;

  var selectedCategory = ''.obs;
  var selectedSubcategory = ''.obs;

  var isCategoryLoading = false.obs;
  var isSubcategoryLoading = false.obs;

  /// Reset when category changes
  void resetSubcategory() {
    selectedSubcategory.value = '';
    subcategories.clear();
  }

  /// Load Product Categories
  Future<void> loadCategories() async {
    try {
      isCategoryLoading.value = true;

      final response = await categoryRepo.getAllProductCategories();

      categories.value = response.data ?? [];

      // Add "Other" option
      categories.add(
        ProductCategoryData(
          categoryId: "Other",
          name: "Other",
          status: "1",
        ),
      );

      isCategoryLoading.value = false;
    } catch (e) {
      isCategoryLoading.value = false;
      Get.snackbar("Error", "Failed to load categories");
    }
  }

  /// Load Subcategories on category selection
  Future<void> loadSubcategories(String categoryId) async {
    if (categoryId == '') return;

    try {
      isSubcategoryLoading.value = true;
      resetSubcategory();

      final response =
          await subRepo.getAllSubcategories(categoryId: categoryId);

      subcategories.value = response.data ?? [];

      if (subcategories.isEmpty) {
        // no subcategories
      } else {
        subcategories.add(
          ProductSubcategoryData(
            subcategoryId: "Other",
            name: "Other",
            status: "1",
          ),
        );
      }

      isSubcategoryLoading.value = false;
    } catch (e) {
      isSubcategoryLoading.value = false;
      Get.snackbar("Error", "Failed to load subcategories");
    }
  }

  // Occupation Business Profile
  final Rx<GetAllBusinessOccupationProfileModelClass?> _businessProfiles =
      Rx<GetAllBusinessOccupationProfileModelClass?>(null);
  GetAllBusinessOccupationProfileModelClass? get businessProfiles =>
      _businessProfiles.value;

  final Rx<Status> _rxBusinessProfileStatus = Status.LOADING.obs;
  Status get rxBusinessProfileStatus => _rxBusinessProfileStatus.value;

  // Add repository
  final BusinessOccupationProfileRepository businessProfileRepo =
      BusinessOccupationProfileRepository();

  // Method to fetch business profiles
  Future<void> getBusinessOccupationProfiles(String memberId) async {
    try {
      _rxBusinessProfileStatus.value = Status.LOADING;
      final response =
          await businessProfileRepo.fetchBusinessOccupationProfiles(
        memberId: memberId,
        fullDetails: true,
      );

      if (response.status == true) {
        _businessProfiles.value = response;
        _rxBusinessProfileStatus.value = Status.COMPLETE;
      } else {
        _rxBusinessProfileStatus.value = Status.ERROR;
        Get.snackbar(
          "Error",
          response.message ?? "Failed to load business profiles",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _rxBusinessProfileStatus.value = Status.ERROR;
      debugPrint("❌ Error fetching business profiles: $e");
      Get.snackbar(
        "Error",
        "Failed to load business profiles: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  final AddOccupationBusinessRepository addOccupationBusinessRepo =
      AddOccupationBusinessRepository();
  final UpdateOccupationBusinessRepository updateOccupationBusiness =
      UpdateOccupationBusinessRepository();

  Rx<TextEditingController> businessNameController =
      TextEditingController().obs;
  Rx<TextEditingController> businessMobileController =
      TextEditingController().obs;
  Rx<TextEditingController> businessLandlineController =
      TextEditingController().obs;
  Rx<TextEditingController> businessEmailController =
      TextEditingController().obs;
  Rx<TextEditingController> businessWebsiteController =
      TextEditingController().obs;
  Rx<TextEditingController> businessFlatNoController =
      TextEditingController().obs;
  Rx<TextEditingController> businessAddressController =
      TextEditingController().obs;
  Rx<TextEditingController> businessAreaNameController =
      TextEditingController().obs;
  Rx<TextEditingController> businessPincodeController =
      TextEditingController().obs;

  // Add delete repository
  final DeleteOccupationBusinessRepository deleteOccupationBusinessRepo =
      DeleteOccupationBusinessRepository();

  // Add delete method
  Future<void> deleteBusinessOccupationProfile(
      String businessOccupationProfileId, String memberId) async {
    try {
      final response =
          await deleteOccupationBusinessRepo.deleteOccupationBusinessProfile(
        businessOccupationProfileId,
      );

      if (response.status == true) {
        Get.snackbar(
          "Success",
          response.message ?? "Business profile deleted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await getBusinessOccupationProfiles(memberId);
      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Failed to delete business profile",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete business profile: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint("❌ DELETE BUSINESS PROFILE ERROR: $e");
    }
  }

  // Business Profile
  final OccupationProductRepository occupationProductRepository =
      OccupationProductRepository();

  final Rx<GetAllOccupationProductsModelClass?> occupationProducts =
      Rx<GetAllOccupationProductsModelClass?>(null);

  Future<void> getAllOccupationProducts(String profileId) async {
    try {
      final response = await occupationProductRepository.getAllProducts(
          profileId: profileId);
      occupationProducts.value = response;
    } catch (e) {
      debugPrint("Error fetching occupation products: $e");
      rethrow;
    }
  }

  // Add Product
  final productNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final keywordsController = TextEditingController();
  final priceController = TextEditingController();
  final currencyController = TextEditingController();
  final unitController = TextEditingController();

  final categoryIdController = TextEditingController();
  final subcategoryIdController = TextEditingController();
  final typeController = TextEditingController(text: "product");

  final statusController = TextEditingController(text: "1");
  final isFeaturedController = TextEditingController(text: "0");
  final displayOrderController = TextEditingController(text: "1");

  final createdByController = TextEditingController(text: "1");

  // Qualification Controller
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
  var isOccuptionProData = false.obs;
  void setSelectOccuptionSpec(String value) {
    selectOccuptionSpec.value = value;
  }

  void setSelectQualification(String value) {
    selectQlification.value = value;
  }

  void setSelectQualificationMain(String value) {
    selectQualicationMain.value = value;
  }

  void setSelectQualificationCat(String value) {
    selectQualicationCat.value = value;
  }

  setRxRequestQualification(Status _value) =>
      rxStatusQualification.value = _value;

  void setRxRequestQualificationMain(Status _value) =>
      rxStatusQualificationMain.value = _value;

  void setRxRequestQualificationCat(Status _value) =>
      rxStatusQualificationCat.value = _value;

  setQlication(List<QualificationData> _value) => qulicationList.value = _value;

  setQualicationMain(List<QualicationMainData> _value) =>
      qulicationMainList.value = _value;

  setQualicationCategory(List<Qualificationcategorydata> _value) =>
      qulicationCategoryList.value = _value;

  void getQualification() {
    setRxRequestQualification(Status.LOADING);
    api.userQualification().then((_value) {
      setRxRequestQualification(Status.COMPLETE);

      qulicationList.value = _value.data! ?? [];

      final hasOther = qulicationList.value.any((item) => item.id == "other");
      if (!hasOther) {
        qulicationList.value.add(QualificationData(
          id: "other",
          qualification: 'Other',
          status: '1',
          createdAt: null,
          updatedAt: null,
        ));
      }
    }).onError((error, strack) {
      setRxRequestQualification(Status.ERROR);
    });
  }

  void getQualicationMain(String qualification_id) async {
    print("cvv" + qualification_id.toString());

    qulicationMainList.value = [];

    Map datas = {"qualification_id": qualification_id};
    setRxRequestQualificationMain(Status.LOADING);

    await api.userQualificationMain(datas).then((_value) {
      setRxRequestQualificationMain(Status.COMPLETE);

      if (_value.data != null && _value.data!.isNotEmpty) {
        qulicationMainList.value = _value.data!;

        final hasOther =
            qulicationMainList.value.any((item) => item.id == "other_main");
        if (!hasOther) {
          qulicationMainList.value.add(QualicationMainData(
            id: "other_main",
            qualificationId: qualification_id,
            name: 'Other',
            status: '1',
            createdAt: null,
            updatedAt: null,
          ));
        }
      }
    }).onError((error, strack) {
      print("cvv" + error.toString());
      setRxRequestQualificationMain(Status.ERROR);
    });
  }

  void getQualicationCategory(String qualification_main_id) {
    qulicationCategoryList.value = [];

    print("cvv111" + qualification_main_id.toString());
    Map datas = {"qualification_main_id": qualification_main_id};
    setRxRequestQualificationCat(Status.LOADING);

    api.userQualificationCategory(datas).then((_value) {
      setRxRequestQualificationCat(Status.COMPLETE);

      if (_value.data != null && _value.data!.isNotEmpty) {
        qulicationCategoryList.value = _value.data!;

        final hasOther = qulicationCategoryList.value
            .any((item) => item.id == "other_category");
        if (!hasOther) {
          qulicationCategoryList.value.add(Qualificationcategorydata(
            id: "other_category",
            qualificationId: "",
            qualificationMainId: qualification_main_id,
            name: 'Other',
            status: '1',
            createdAt: null,
            updatedAt: null,
          ));
        }
        isQualificationCategoryVisible.value = true;
        isQualificationDetailVisible.value = false;
      } else {
        isQualificationCategoryVisible.value = false;
        isQualificationDetailVisible.value = true;
      }
    }).onError((error, strack) {
      setRxRequestQualificationCat(Status.ERROR);
      print("cvv" + error.toString());
    });
  }

  void addQualification() async {
    CheckUserData2? userData = await SessionManager.getSession();
    print('User ID: ${userData?.memberId}');
    memberId.value = userData!.memberId.toString();
    addloading.value = true;
    try {
      final qualificationIdToSend =
          selectQlification.value == "other" ? null : selectQlification.value;

      final qualificationMainIdToSend =
          selectQualicationMain.value == "other_main" ||
                  selectQualicationMain.value.isEmpty
              ? null
              : selectQualicationMain.value;

      final qualificationCategoryIdToSend =
          selectQualicationCat.value == "other_category" ||
                  selectQualicationCat.value.isEmpty
              ? null
              : selectQualicationCat.value;

      Map<String, dynamic> map = {
        "member_id": memberId.value,
        if (qualificationIdToSend != null && qualificationIdToSend != "other")
          "qualification_id": qualificationIdToSend,
        if (qualificationMainIdToSend != null &&
            qualificationMainIdToSend != "other_main")
          "qualification_main_id": qualificationMainIdToSend,
        if (qualificationCategoryIdToSend != null &&
            qualificationCategoryIdToSend != "other_category")
          "qualification_category_id": qualificationCategoryIdToSend,
        "qualification_other_name": educationdetailController.value.text,
        "created_by": memberId.value,
      };

      print("Sending qualification data: $map");

      api.addQualification(map).then((_value) async {
        addloading.value = false;
        if (_value['status'] == true) {
          Get.snackbar(
            'Success',
            "Add Education Successfully",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          getUserProfile();
          Navigator.of(Get.context!).pop();
        } else {
          Get.snackbar(
            'Error',
            _value['message'] ?? "Failed to add qualification",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.pink,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      }).onError((error, strack) async {
        addloading.value = false;
        print("Error: $error");
        Get.snackbar(
          'Error',
          "Something went wrong: ${error.toString()}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.pink,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      });
    } catch (e) {
      addloading.value = false;
      print('Error: $e');
      Get.snackbar(
        'Error',
        "An unexpected error occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.pink,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  void updateQualification(String member_qualification_id) async {
    CheckUserData2? userData = await SessionManager.getSession();
    print('User ID: ${userData?.memberId}');
    print('User Name: ${userData?.mobile}');
    memberId.value = userData!.memberId.toString();
    addloading.value = true;
    try {
      Map<String, String> map = {
        'member_id': memberId.value.toString(),
        'qualification_id': selectQlification.value.toString(),
        'member_qualification_id': member_qualification_id.toString(),
        'qualification_main_id': selectQualicationMain.value.toString(),
        'qualification_category_id':
            (selectQualicationCat.value == "other_category" ||
                    selectQualicationCat.value.isEmpty)
                ? "0"
                : selectQualicationCat.value.toString(),
        'qualification_other_name': educationdetailController.value.text,
        'updated_by': memberId.value.toString(),
      };

      print("fffh" + map.toString());
      api.updateQualification(map).then((_value) async {
        addloading.value = false;
        if (_value['status'] == true) {
          Get.snackbar(
            'Success',
            "Update Education Successfully",
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
          'Error',
          "Some thing went wrong ",
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

  void checkReviewApproval() {
    if (memberStatusId.value == "1" &&
        membershipApprovalStatusId.value == "6") {
      if (emailVerifyStatus.value == "1") {
        if (isJangana.value == "0") {
          showDashboardReviewFlag.value = true;
        } else {
          showDashboardReviewFlag.value = false;
        }
      }
    }
  }

  // Family Relation
  void setRxRelationType(Status _value) => rxStatusRelationType.value = _value;

  void getRelation() {
    Map datas = {"attribute_id": "1"};
    setRxRelationType(Status.LOADING);
    api.userFamilyRelation(datas).then((_value) {
      setRxRelationType(Status.COMPLETE);
      setRelationShipType(_value.data!);
      print("relationdata" + _value.data!.toString());
    }).onError((error, strack) {
      setRxRelationType(Status.ERROR);
      print("relationdata" + error.toString());
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
          getUserProfile();
          Get.snackbar(
            'Success',
            "Update Relation SuccessFully",
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
          'Error',
          "Some thing went wrong ",
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
      await api.userJanganaStatus(memberId.value).then((_value) async {
        // addloading.value=false;

        if (_value['status'] == true) {
          Get.snackbar(
            'Success',
            "Update Jangana SuccessFully",
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
          'Error',
          "Some thing went wrong ",
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

  Future<void> sendVerificationEmail() async {
    try {
      final memberId = this.memberId.value;
      if (memberId.isEmpty) {
        throw Exception("Member ID not found");
      }

      final response = await SendVerificationEmailRepository()
          .sendVerificationEmail(memberId);

      if (response.status == true) {
        Get.snackbar(
          'Success',
          response.data?.message ?? 'Verification email sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        getUserProfile();
      } else {
        throw Exception(
            response.data?.message ?? 'Failed to send verification email');
      }
    } catch (e) {
      // Always show user-friendly message with "Email"
      final errorMessage = e.toString().contains("email")
          ? e.toString()
          : "Email verification failed. Please try again.";

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void userUpdateProfile(BuildContext context, String type) async {
    //print("member"+memberId.value);
    CheckUserData2? userData = await SessionManager.getSession();
    final url = Uri.parse(Urls.updateProfile_url);
    NewMemberController memberController = Get.put(NewMemberController());
    loading.value = true;

    if (MaritalAnnivery.value == false) {
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
      "marital_status_id": selectMarital.value,
      "blood_group_id": blood_group_id.value,
      "saraswani_option_id": saraswaniOptionId.value,
      "dob": dobController.value.text.trim(),
      "marriage_anniversary_date": marriageAnniversaryController.value.text,
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

  Future<void> userResidentalProfile(BuildContext context) async {
    CheckUserData2? userData = await SessionManager.getSession();
    if (userData == null) return;

    final NewMemberController regiController = Get.find<NewMemberController>();
    loading.value = true;

    try {
      // Validate required fields
      if (regiController.selectDocumentType.value.isEmpty) {
        Get.snackbar("Error", "Please select address proof type");
        loading.value = false;
        return;
      }

      // Get building name from selected building
      String buildingName = "";
      String buildingId = "";

      if (regiController.selectBuilding.value == "other") {
        // For "other", use custom building name
        buildingId = "";
        buildingName = regiController.buildingController.value.text.trim();
      } else if (regiController.selectBuilding.value.isNotEmpty) {
        // Find the building name from the building list
        buildingId = regiController.selectBuilding.value;
        try {
          final selectedBuilding = regiController.checkPinCodeList.firstWhere(
            (building) => building.id?.toString() == buildingId,
            orElse: () => Building(id: null, buildingName: null),
          );
          buildingName = selectedBuilding.buildingName?.toString() ?? "";
        } catch (e) {
          print("Error finding building name: $e");
          buildingName = "";
        }
      }

      // Prepare the data with correct field names
      final Map<String, dynamic> data = {
        "member_id": userData.memberId.toString(),
        "flat_no": flatNoController.value.text.trim(),
        "area": regiController.areaController.value.text.isNotEmpty
            ? regiController.areaController.value.text.trim()
            : regiController.area_name.value.trim(),
        "building_id": buildingId,
        "building_name": buildingName,
        "zone_id": regiController.zone_id.value,
        "address": updateresidentalAddressController.value.text.trim(),
        "city_id": regiController.city_id.value,
        "state_id": regiController.state_id.value,
        "country_id": regiController.country_id.value,
        "document_type": regiController.selectDocumentType.value,
        "pincode": pincodeController.value.text.trim(),
        "updated_by": userData.memberId.toString(),
      };

      print("Sending residential update: ${jsonEncode(data)}");

      final response = await updateAddress(data);
      print("Update response: $response");

      if (response['status'] == true) {
        // Force a complete refresh of user data
        await getUserProfile();

        Get.snackbar(
          "Success",
          "Residential info updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else {
        throw Exception(response['message'] ?? "Update failed");
      }
    } catch (e) {
      print("Update error: $e");
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      loading.value = false;
    }
  }

  Future<dynamic> updateAddress(Map<String, dynamic> data) async {
    try {
      // Convert to multipart request if image is included
      if (data.containsKey('document_image') &&
          data['document_image'] != null &&
          data['document_image'].isNotEmpty) {
        final file = File(data['document_image']);
        final request = http.MultipartRequest(
            'POST', Uri.parse(Urls.updateMemberAddress_url));

        // Add all fields including building_name
        data.forEach((key, value) {
          if (key != 'document_image') {
            request.fields[key] = value.toString();
          }
        });

        // Add file
        request.files.add(await http.MultipartFile.fromPath(
          'document_image',
          file.path,
        ));

        // Add headers
        request.headers['token'] = "2"; // Your token

        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        return jsonDecode(responseData);
      } else {
        // Regular POST request if no image
        // Remove document_image from data if it exists
        final postData = Map<String, dynamic>.from(data);
        postData.remove('document_image');

        final response = await http.post(
          Uri.parse(Urls.updateMemberAddress_url),
          body: postData,
          headers: {
            'token': '2', // Your token
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        );
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error updating address: $e');
      return {'status': false, 'message': 'Failed to update address: $e'};
    }
  }

  void userAddFamily(BuildContext context) async {
    CheckUserData2? userData = await SessionManager.getSession();
    NewMemberController regiController = Get.put(NewMemberController());
    final newFirstName =
        regiController.firstNameController.value.text.trim().toLowerCase();

    if (familyHeadData.value?.firstName?.toLowerCase() == newFirstName) {
      Get.snackbar(
        "Sorry",
        "A family member with this name already exists (family head)",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    bool nameExistsInFamily = familyDataList
        .any((member) => member.firstName?.toLowerCase() == newFirstName);

    if (nameExistsInFamily) {
      Get.snackbar(
        "Sorry",
        "A family member with this name already exists",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final url = Uri.parse(Urls.addmemberorfamily_url);
    print("vcgdhfh" + Urls.addmemberorfamily_url);

    familyloading.value = true;

    var building_name = buildingController.value.text;
    var building_id = "";

    if (regiController.selectBuilding.value == "other") {
      building_id = "";
    } else {
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
      "mobile": regiController.mobileController.value.text.isNotEmpty
          ? regiController.mobileController.value.text
          : "",
      "gender_id": regiController.selectedGender.value,
      "marital_status_id": marital_status_id,
      "blood_group_id": regiController.selectBloodGroup.value,
      "dob": regiController.dateController.text,
      "family_head_member_id": familyHeadMemberId.value,
      "relation_id": selectRelationShipType.value,
      "member_type_id": "2",
      "marriage_anniversary_date":
          regiController.marriagedateController.value.text,
      "salutation_id": regiController.selectMemberSalutation.value,
      "created_by": userData!.memberId.toString()
    };
    print("ccvv" + payload.toString());
    var request = http.MultipartRequest('POST', url);
    request.fields.addAll(payload);
    if (document_image != "") {
      request.files.add(
          await http.MultipartFile.fromPath('profile_image', document_image));
    }
    http.StreamedResponse response =
        await request.send().timeout(Duration(seconds: 60));
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      familyloading.value = false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      print("ccvv" + jsonResponse.toString());
      RegisterModelClass registerResponse =
          RegisterModelClass.fromJson(jsonResponse);
      if (registerResponse.status == true) {
        Get.snackbar(
          "Success",
          "Update Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        regiController.firstNameController.value.text = "";
        regiController.lastNameController.value.text = "";
        regiController.middleNameController.value.text = "";
        regiController.fathersnameController.value.text = "";
        regiController.mothersnameController.value.text = "";
        regiController.emailController.value.text = "";
        regiController.whatappmobileController.value.text = "";
        // regiController.mobileController.value.text = "";
        regiController.selectedGender.value = "";
        regiController.selectBloodGroup.value = "";
        regiController.dateController.text = "";
        selectRelationShipType.value = "";
        regiController.selectMarital.value = "";
        regiController.marriagedateController.value.text = "";
        regiController.selectMemberSalutation.value = "";
        regiController.selectMemberSalutation.value = "";
        getUserProfile();
        String mobile = regiController.mobileController.value.text.trim();

        if (mobile.isNotEmpty) {
          //   print("Sending OTP to: $mobile");
          //   sendOtp(regiController.mobileController.value.text);
          //   Navigator.of(context!).pop();
          //   showOtpBottomSheet(
          //       context!, regiController.mobileController.value.text);
          // }
          Navigator.of(context).pop();
          Get.snackbar(
            "Success",
            "Family member added successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          registerResponse.message.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } else {
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
  var family_member_id = "".obs;
  void sendOtp(var mobile) async {
    try {
      Map<String, String> map = {"mobile_number": mobile};
      api2.sendOTP(map).then((_value) async {
        if (_value.status == true) {
          Get.snackbar(
            "Success",
            "OTP sent successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          // Store the member ID for verification
          family_member_id.value = _value.data!.memberId.toString();
        } else {
          Get.snackbar(
            "Error",
            "Failed to send OTP",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }).onError((error, strack) async {
        Get.snackbar(
          'Error',
          error.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.pink,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void checkOtp(String otps, BuildContext context, String otpValidationFor,
      {VoidCallback? onSuccess}) {
    if (otpValidationFor != "add_family_member") {
      return;
    }

    try {
      Map<String, dynamic> map = {
        "member_id": family_member_id.value,
        "otp": otps,
      };

      api2.verifyOTP(map).then((_value) async {
        if (_value.status == true) {
          Get.snackbar(
            'Success',
            'OTP matched',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          Navigator.of(context).pop();
          if (onSuccess != null) {
            onSuccess();
          }
        } else {
          Get.snackbar(
            'Error',
            "Invalid OTP",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }).onError((error, stack) {
        print("Error: ${error.toString()}");
        if (error.toString().contains("Sorry! OTP doesn't match")) {
          Get.snackbar(
            'Error',
            "Sorry! OTP doesn't match",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.pink,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        } else {
          Get.snackbar(
            'Error',
            "Something went wrong",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.pink,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      });
    } catch (e) {
      print('Exception: $e');
    }
  }

  void userAddBuniessInfo() async {
    CheckUserData2? userData = await SessionManager.getSession();
    NewMemberController memberController = Get.put(NewMemberController());
    addBussinessLoading.value = true;
    memberId.value = userData!.memberId.toString();

    try {
      var payload = {
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
        'created_by': memberId.value,
        'pincode': officePincodeController.value.text
      };
      print("fffh" + payload.toString());
      await api.userAddBusiness(payload).then((dynamic _value) async {
        print("fffh2" + _value.toString());
        if (_value['status'] == true) {
          print("fffh" + _value['message'].toString());
          Get.snackbar(
            'Success', // Title
            _value['message'], // Message
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          organisationNameController.value.text = "";
          officePhoneController.value.text = "";
          businessEmailController.value.text = "";
          websiteController.value.text = "";
          flatnoController.value.text = "";
          addressbusinessinfoNameController.value.text = "";
          areaNameController.value.text = "";
          memberController.city_id.value = "";
          memberController.state_id.value = "";
          memberController.country_id.value = "";
          officePincodeController.value.text = "";

          getUserProfile();
          addBussinessLoading.value = false;
          Navigator.pop(context!, "");
        }
      }).onError((error, strack) async {
        addBussinessLoading.value = false;
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
      addBussinessLoading.value = false;
      print('Error: $e');
    } finally {}
  }

  void userUpdateBuniessInfo(BusinessInfo bussinessinfo) async {
    CheckUserData2? userData = await SessionManager.getSession();
    NewMemberController memberController = Get.put(NewMemberController());
    addloading.value = true;
    memberId.value = userData!.memberId.toString();

    try {
      var map = {
        'member_id': memberId.value,
        'organisation_name': udorganisationNameController.value.text,
        'office_phone': udofficePhoneController.value.text,
        'business_email': udbusinessEmailController.value.text,
        'website': upwebsiteController.value.text,
        'flat_no': udflatnoController.value.text,
        'address': upaddressbusinessinfoNameController.value.text,
        'area': udareaNameController.value.text,
        'city_id': memberController.city_id.value,
        'state_id': memberController.state_id.value,
        'country_id': memberController.country_id.value,
        'created_by': memberId.value,
        'pincode': udofficePincodeController.value.text,
        'member_address_id': bussinessinfo.memberAddressId.toString(),
        'member_business_info_id':
            bussinessinfo.membersBusinessInfoId.toString()
      };
      print("fffh" + map.toString());
      await api.userUpdateBusiness(map).then((dynamic _value) async {
        print("fffh2" + _value.toString());
        if (_value['status'] == true) {
          print("fffh" + _value['message'].toString());
          Get.snackbar(
            'Success', // Title
            _value['message'], // Message
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          getUserProfile();
          addloading.value = false;
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
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Adjust for keyboard height
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
                        resendOtp(context, mobile);
                      },
                      child: const Text(
                        "Resend OTP",
                        style: TextStyle(color: Color(0xFFe61428)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String otpValidationFor = "add_family_member";

                        checkOtp(
                          otpController.text.trim(),
                          context,
                          otpValidationFor,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorHelperClass.getColorFromHex(
                            ColorResources.red_color),
                      ),
                      child: const Text(
                        "Submit OTP",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void resendOtp(BuildContext context, String mobile) {
    sendOtp(mobile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP Resent Successfully")),
    );
  }

  Future<bool> addExistingFamilyMember(
      String memberId, String relationId) async {
    try {
      familyloading.value = true;

      final data = AddExistingMemberIntoFamilyData(
        memberId: int.parse(memberId),
        relationId: int.parse(relationId),
        currentMemberId: int.parse(familyHeadData.value!.memberId!),
      );

      final response = await addExistingMemberRepo.addExistingMember(data);

      if (response['status'] == true) {
        await getUserProfile();

        Get.snackbar(
          'Success',
          response['message'] ?? "Member added successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        return true;
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? "Failed to add member",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        "Member already related with another family. We can't add this member into your family.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return false;
    } finally {
      familyloading.value = false;
    }
  }

  Future<bool> changeFamilyHead(String newHeadId, String relationId) async {
    try {
      familyloading(true);

      final currentHeadId = familyHeadData.value?.memberId;

      final data = ChangeFamilyHeadData(
        currentFamilyHeadId: int.tryParse(currentHeadId ?? ''),
        newFamilyHeadId: int.tryParse(newHeadId),
        relationshipId: int.tryParse(relationId),
        memberId: int.tryParse(newHeadId),
      );

      final response = await _changeHeadRepo.changeFamilyHead(data);

      if (response['status'] == true) {
        await getUserProfile();

        Get.snackbar(
          'Success',
          response['message'] ?? 'Family head changed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        return true;
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to change family head',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to change family head: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return false;
    } finally {
      familyloading(false);
    }
  }
}
