import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mpm/OccuptionProfession/OccuptionProfessionData.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CheckMobileExists/CheckMobileExistsModelClass.dart';
import 'package:mpm/model/CheckPinCode/Building.dart';

import 'package:mpm/model/CheckPinCode/CheckPinCodeModel.dart';

import 'package:mpm/model/CheckUser/CheckUserData.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/model/CountryModel/CountryData.dart';
import 'package:mpm/model/GetMemberSurname/GetMemberSurnameData.dart';
import 'package:mpm/model/Occupation/OccupationData.dart';
import 'package:mpm/model/OccupationSpec/OccuptionSpecData.dart';
import 'package:mpm/model/Qualification/QualificationData.dart';
import 'package:mpm/model/QualificationCategory/QualificationCategoryModel.dart';
import 'package:mpm/model/QualificationMain/QualicationMainData.dart';
import 'package:mpm/model/Register/RegisterModelClass.dart';
import 'package:mpm/model/SaraswaniOption/SaraswaniOptionData.dart';
import 'package:mpm/model/State/StateData.dart';

import 'package:mpm/model/bloodgroup/BloodData.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/model/documenttype/DocumentTypeModel.dart';
import 'package:mpm/model/gender/DataX.dart';

import 'package:mpm/model/marital/MaritalData.dart';
import 'package:mpm/model/membersalutation/MemberSalutationData.dart';
import 'package:mpm/model/membership/MemberShipData.dart';
import 'package:mpm/model/relation/RelationData.dart';
import 'package:mpm/repository/check_mobile_exists_repository/check_mobile_exists_repo.dart';
import 'package:mpm/repository/get_member_surname_repository/get_member_surname_repo.dart';
import 'package:mpm/repository/register_repository/register_repo.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/repository/saraswani_option_repository/saraswani_option_repo.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/urls.dart';

class NewMemberController extends GetxController {
  final api = RegisterRepository();
  var loading = false.obs;
  var withoutcheckotp = false.obs;
  RxBool isChecked = false.obs;
  final rxStatusCountryLoading = Status.IDLE.obs;
  final rxStatusStateLoading = Status.IDLE.obs;
  final rxStatusCityLoading = Status.IDLE.obs;
  final rxStatusLoading = Status.IDLE.obs;
  final rxStatusMemberLoading = Status.IDLE.obs;
  final rxStatusLoading2 = Status.LOADING.obs;
  final rxStatusmarried = Status.LOADING.obs;

  final rxStatusQualification = Status.LOADING.obs;
  final rxStatusQualificationMain = Status.IDLE.obs;
  final rxStatusQualificationCat = Status.IDLE.obs;
  final rxStatusBuilding = Status.IDLE.obs;
  final rxStatusDocument = Status.LOADING.obs;
  final rxStatusMemberShipTYpe = Status.LOADING.obs;
  final rxStatusSurname = Status.LOADING.obs;
  final surnameList = <MemberSurnameData>[].obs;
  final selectedSurname = ''.obs;
  final isMaheshwariSelected = false.obs;
  final sankhText = ''.obs;
  final showSankhField = false.obs;
  final showCustomSurnameField = false.obs;

  var arg_page = "".obs;
  var state_id = "".obs;
  var city_id = "".obs;
  var area_name = "".obs;
  var zone_id = "".obs;
  var country_id = "".obs;
  var genderList = <DataX>[].obs;
  var selectedGender = ''.obs;
  var maritalList = <MaritalData>[].obs;
  var selectMarital = ''.obs;
  var selectMember = CheckUserData().obs;
  var MandalZoneFlag = false.obs;

  var selectQlification = ''.obs;
  var selectQualicationMain = ''.obs;
  var selectQualicationCat = ''.obs;
  var bloodgroupList = <BloodGroupData>[].obs;
  var selectBloodGroup = ''.obs;
  var selectBuilding = ''.obs;
  var selectDocumentType = ''.obs;
  var selectMemberShipType = ''.obs;

  var memberList = <CheckUserData>[].obs;
  var ducumentList = <CheckUserData>[].obs;
  var qulicationList = <QualificationData>[].obs;
  var qulicationMainList = <QualicationMainData>[].obs;
  var qulicationCategoryList = <Qualificationcategorydata>[].obs;
  var checkPinCodeList = <Building>[].obs;
  var memberShipList = <MemberShipData>[].obs;
  var documntTypeList = <DocumentTypeData>[].obs;
  var isButtonEnabled = false.obs;
  var lmCodeValue = ''.obs;
  var userprofile = ''.obs;
  var userdocumentImage = ''.obs;
  var isBuilding = false.obs;
  var isRelation = false.obs;
  var isMarried = false.obs;
  var memberId = "".obs;
  var MaritalAnnivery = false.obs;
  var selectMemberSalutation = ''.obs;

  RxBool isCheckingMobile = false.obs;
  RxString mobileExistsMessage = ''.obs;
  RxBool isMobileValid = false.obs;

  final CheckMobileRepository _mobileRepo = CheckMobileRepository();

  Future<void> checkMobileExists(String mobileNumber) async {
    isCheckingMobile.value = true;
    mobileExistsMessage.value = '';
    isMobileValid.value = false;

    try {
      final response = await _mobileRepo.checkMobileNumberExists(mobileNumber);

      if (response.status == true) {
        if (response.code == 101) {
          // Mobile number does not exist, valid to proceed
          mobileExistsMessage.value = '';
          isMobileValid.value = true;
        } else if (response.code == 102) {
          // Mobile number already exists
          mobileExistsMessage.value = 'Mobile number already exists.';
          isMobileValid.value = false;
        } else {
          // Unexpected code
          mobileExistsMessage.value = response.message ?? 'Unexpected response';
          isMobileValid.value = false;
        }
      } else {
        mobileExistsMessage.value = response.message ?? 'Invalid response';
        isMobileValid.value = false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      mobileExistsMessage.value = 'Something went wrong';
      isMobileValid.value = false;
    } finally {
      isCheckingMobile.value = false;
    }
  }

  BuildContext? context = Get.context;
  var countryList = <CountryData>[].obs;
  var stateList = <StateData>[].obs;
  var cityList = <CityData>[].obs;
  var countryNotFound = false.obs;
  final rxStatusMemberSalutation = Status.LOADING.obs;
  void setRxRequestCountry(Status _value) =>
      rxStatusCountryLoading.value = _value;
  void setRxRequestState(Status _value) => rxStatusStateLoading.value = _value;
  void setRxRequestCity(Status _value) => rxStatusCityLoading.value = _value;
  void setRxRequestMemberSalutation(Status _value) =>
      rxStatusMemberSalutation.value = _value;
  RxString saraswaniOptionId = ''.obs;
  RxList<SaraswaniOptionData> saraswaniOptionList = <SaraswaniOptionData>[].obs;
  // This line ensures you can bind and display filtered options in the UI.
  RxList<SaraswaniOptionData> filteredSaraswaniOptionList =
      <SaraswaniOptionData>[].obs;
  Rx<TextEditingController> housenoController = TextEditingController().obs;
  Rx<TextEditingController> stateController = TextEditingController().obs;
  Rx<TextEditingController> cityController = TextEditingController().obs;
  Rx<TextEditingController> zoneController = TextEditingController().obs;
  Rx<TextEditingController> areaController = TextEditingController().obs;
  Rx<TextEditingController> fathersnameController = TextEditingController().obs;
  Rx<TextEditingController> mothersnameController = TextEditingController().obs;
  Rx<TextEditingController> pincodeController = TextEditingController().obs;
  Rx<TextEditingController> firstNameController = TextEditingController().obs;
  Rx<TextEditingController> lastNameController = TextEditingController().obs;
  Rx<TextEditingController> middleNameController = TextEditingController().obs;
  Rx<TextEditingController> mobileController = TextEditingController().obs;
  Rx<TextEditingController> whatappmobileController =
      TextEditingController().obs;
  Rx<TextEditingController> countryController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> buildingController = TextEditingController().obs;
  Rx<TextEditingController> occuptiondetailController =
      TextEditingController().obs;
  Rx<TextEditingController> educationdetailController =
      TextEditingController().obs;
  TextEditingController dateController = TextEditingController();
  Rx<TextEditingController> marriagedateController =
      TextEditingController().obs;
  Rx<TextEditingController> addressMemberController =
      TextEditingController().obs;
  var memberSalutationList = <MemberSalutationData>[].obs;
  void setRxRequest(Status _value) => rxStatusLoading.value = _value;
  void setRxMemberRequest(Status _value) =>
      rxStatusMemberLoading.value = _value;
  void setRxRequest2(Status _value) => rxStatusLoading2.value = _value;
  void setRxRequestMarried(Status _value) => rxStatusmarried.value = _value;

  void setRxRequestQualification(Status _value) =>
      rxStatusQualification.value = _value;
  void setRxRequestQualificationMain(Status _value) =>
      rxStatusQualificationMain.value = _value;
  void setRxRequestQualificationCat(Status _value) =>
      rxStatusQualificationCat.value = _value;
  void setRxRequestBuilding(Status _value) => rxStatusBuilding.value = _value;
  void setRxRequestDocument(Status _value) => rxStatusDocument.value = _value;
  void setRxRequestMemberShip(Status _value) =>
      rxStatusMemberShipTYpe.value = _value;

  void setGender(List<DataX> _value) => genderList.value = _value;
  void setMaritalStatus(List<MaritalData> _value) => maritalList.value = _value;
  void setBloodStatus(List<BloodGroupData> _value) =>
      bloodgroupList.value = _value;
  void setCountry(List<CountryData> _value) => countryList.value = _value;
  void setState(List<StateData> _value) => stateList.value = _value;
  void setCity(List<CityData> _value) => cityList.value = _value;
  void setMember(List<CheckUserData> _value) => memberList.value = _value;

  setQlication(List<QualificationData> _value) => qulicationList.value = _value;
  setQualicationMain(List<QualicationMainData> _value) =>
      qulicationMainList.value = _value;
  setQualicationCategory(List<Qualificationcategorydata> _value) =>
      qulicationCategoryList.value = _value;
  setcheckPinCode(List<Building> _value) => checkPinCodeList.value = _value;
  setdocumentType(List<DocumentTypeData> _value) =>
      documntTypeList.value = _value;
  setMemberShipType(List<MemberShipData> _value) =>
      memberShipList.value = _value;

  setMemberSalutation(List<MemberSalutationData> _value) =>
      memberSalutationList.value = _value;

  var dropdownItems = <String>[].obs;
  var selectedValue = ''.obs;

  var isQualicationList = false.obs;
  var isQualicationCateList = false.obs;
  void toggleCheckbox(bool? value) {
    isChecked.value = value ?? false;
  }

  void getMemberSalutation() {
    setRxRequestMemberSalutation(Status.LOADING);
    api.userMemberSalutation().then((_value) {
      setRxRequestMemberSalutation(Status.COMPLETE);
      setMemberSalutation(_value.data!);
    }).onError((error, strack) {
      setRxRequestMemberSalutation(Status.ERROR);
    });
  }

  Future<void> getSurnameList() async {
    try {
      rxStatusSurname.value = Status.LOADING;
      final response = await MemberSurnameRepository().fetchMemberSurnameList();
      if (response.status == true && response.data != null) {
        surnameList.assignAll(response.data!);
        rxStatusSurname.value = Status.COMPLETE;
      } else {
        rxStatusSurname.value = Status.ERROR;
      }
    } catch (e) {
      rxStatusSurname.value = Status.ERROR;
    }
  }

  void setSelectedSurname(String value) {
    selectedSurname.value = value;
  }

  void getGender() {
    setRxRequest2(Status.LOADING);
    api.userGenderApi().then((_value) {
      setRxRequest2(Status.COMPLETE);
      setGender(_value.data!);
    }).onError((error, strack) {
      setRxRequest2(Status.ERROR);
    });
  }

  void getCountry() {
    setRxRequestCountry(Status.LOADING);
    api.CountryApi().then((_value) {
      setRxRequestCountry(Status.COMPLETE);
      setCountry(_value.data!);
    }).onError((error, strack) {
      setRxRequestCountry(Status.ERROR);
    });
  }

  Future<void> getState() async {
    try {
      setRxRequestState(Status.LOADING);

      final response = await api.StateApi();
      List<StateData> states = response.data ?? [];

      final List<StateData> reorderedStates = [
        ...states.where((s) => s.id == '2'),
        ...states.where((s) => s.id == '22'),
        ...states.where((s) => s.id != '2' && s.id != '22'),
      ];

      setRxRequestState(Status.COMPLETE);
      setState(reorderedStates);
    } catch (e) {
      setRxRequestState(Status.ERROR);
    }
  }

  Future<void> getCity() async {
    try {
      setRxRequestCity(Status.LOADING);
      final _value = await api.CityApi();
      setRxRequestCity(Status.COMPLETE);
      setCity(_value.data!);

      final ids = cityList.map((e) => e.id.toString()).toList();
      final duplicates =
      ids.toSet().where((id) => ids.where((x) => x == id).length > 1);
      print('Duplicate IDs: $duplicates');
    } catch (e) {
      setRxRequestCity(Status.ERROR);
    }
  }


  void setSaraswaniOption(String value) {
    saraswaniOptionId.value = value;
  }

  void setSelectedGender(String value) {
    selectedGender(value);
  }

  void setSelectedCountry(String value) {
    country_id(value);
  }

  void setSelectedState(String value) {
    state_id(value);
  }

  void setSelectedCity(String value) {
    city_id.value = value;
  }

  void setSelectedBuilding(String value) {
    selectBuilding(value);
  }

  void setSelectedMarital(String value) {
    selectMarital.value = value;
    if (value.toString() == "1") {
      MaritalAnnivery.value = true;
    } else {
      MaritalAnnivery.value = false;
    }
  }

  void setSelectedBloodGroup(String value) {
    selectBloodGroup(value);
  }

  void setSelectMember(CheckUserData value) {
    selectMember(value);
  }

  void setDocumentType(String value) {
    selectDocumentType(value);
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

  void setSelectMemberShip(String value) {
    selectMemberShipType(value);
  }

  void getMaritalStatus() {
    setRxRequestMarried(Status.LOADING);
    api.userMaritalApi().then((_value) {
      setRxRequestMarried(Status.COMPLETE);
      setMaritalStatus(_value.data!);
    }).onError((error, strack) {
      setRxRequestMarried(Status.ERROR);
    });
  }

  void getBloodGroup() {
    setRxRequest(Status.LOADING);
    api.userBloodGroupApi().then((_value) {
      setRxRequest(Status.COMPLETE);
      setBloodStatus(_value.data!);
    }).onError((error, strack) {
      setRxRequest(Status.ERROR);
    });
  }

  void fetchSaraswaniOptions() async {
    rxStatusLoading.value = Status.LOADING;
    try {
      final response = await SaraswaniOptionRepository().SaraswaniOptionApi();
      saraswaniOptionList.value = response.data ?? [];
      rxStatusLoading.value = Status.COMPLETE;
    } catch (e) {
      rxStatusLoading.value = Status.ERROR;
    }
  }

  void getMemberShip() {
    setRxRequestMemberShip(Status.LOADING);
    api.userMemberShip().then((_value) {
      setRxRequestMemberShip(Status.COMPLETE);

      try {
        var date = dateController.value.text;
        if (date.isEmpty) {
          setRxRequestMemberShip(Status.ERROR);
          return;
        }

        DateFormat inputFormat = DateFormat("dd/MM/yyyy");
        DateTime dob = inputFormat.parse(date);

        memberShipList.clear();

        if (withoutcheckotp.value == false) {
          setMemberShipType(_value.data!);

          filteredSaraswaniOptionList.value = saraswaniOptionList;
        } else {
          if (isUnder18(dob)) {
            if (zoneController.value.text.isEmpty) {
              _showLoginAlert(context!);
            } else {
              _addMembershipIfMatches(_value.data!, "Non Member");

              filteredSaraswaniOptionList.value = saraswaniOptionList
                  .where((option) =>
                      (option.saraswaniOption?.toLowerCase() ?? '')
                          .contains('soft'))
                  .toList();
            }
          } else {
            if (countryNotFound.value) {
              if (zoneController.value.text.isEmpty) {
                _addMembershipIfMatches(_value.data!, "Saraswani Member");
                _addMembershipIfMatches(_value.data!, "Guest Member");

                filteredSaraswaniOptionList.value = saraswaniOptionList;
              } else {
                _addMembershipIfMatches(_value.data!, "Non Member");
                _addMembershipIfMatches(_value.data!, "Life Member");

                final hasNonMember = memberShipList.any((ms) =>
                    (ms.membershipName?.toLowerCase() ?? '') == 'non member');

                if (hasNonMember) {
                  filteredSaraswaniOptionList.value = saraswaniOptionList
                      .where((option) =>
                          (option.saraswaniOption?.toLowerCase() ?? '')
                              .contains('soft'))
                      .toList();
                } else {
                  filteredSaraswaniOptionList.value = saraswaniOptionList;
                }
              }
            } else {
              _addMembershipIfMatches(_value.data!, "Saraswani Member");

              filteredSaraswaniOptionList.value = saraswaniOptionList;
            }
          }
        }
      } catch (e) {
        print("Error parsing date: $e");
        setRxRequestMemberShip(Status.ERROR);
      }
    }).onError((error, strack) {
      setRxRequestMemberShip(Status.ERROR);
    });
  }

  void _addMembershipIfMatches(List<MemberShipData> memberships, String name) {
    for (var membership in memberships) {
      if (membership.membershipName == name) {
        memberShipList.add(MemberShipData(
          id: membership.id,
          membershipName: membership.membershipName,
          price: membership.price.toString(),
          status: membership.status.toString(),
          updatedAt: null,
          createdAt: null,
        ));
      }
    }
  }

  bool isUnder18(DateTime dateOfBirth) {
    final today = DateTime.now();
    final age = today.year - dateOfBirth.year;
    if (dateOfBirth.month > today.month ||
        (dateOfBirth.month == today.month && dateOfBirth.day > today.day)) {
      return age - 1 < 18;
    }
    return age < 18;
  }

  void getFamilyMemberShip(String dob, String zoneId) {
    print("DOB : $dob Zone: $zoneId");
    setRxRequestMemberShip(Status.LOADING);

    api.userMemberShip().then((_value) {
      setRxRequestMemberShip(Status.COMPLETE);

      DateFormat inputFormat = DateFormat("dd/MM/yyyy");
      DateFormat outputFormat = DateFormat("yyyy-MM-dd");

      DateTime dobDate = inputFormat.parse(dob);
      String formattedDate = outputFormat.format(dobDate);

      print("Formatted DOB: $formattedDate, Zone ID: $zoneId");

      memberShipList.value.clear();

      if (isUnder18(dobDate)) {
        if (zoneId.isEmpty) {
          _showLoginAlert(context!);
        } else {
          for (var membership in _value.data!) {
            if (membership.membershipName == "Non Member") {
              memberShipList.value.add(MemberShipData(
                id: membership.id,
                membershipName: membership.membershipName,
                price: membership.price.toString(),
                status: membership.status.toString(),
                updatedAt: null,
                createdAt: null,
              ));
            }
          }
        }
      } else {
        for (var membership in _value.data!) {
          if (zoneId.isEmpty) {
            if (membership.membershipName == "Saraswani Member" ||
                membership.membershipName == "Guest Member") {
              memberShipList.value.add(MemberShipData(
                id: membership.id,
                membershipName: membership.membershipName,
                price: membership.price.toString(),
                status: membership.status.toString(),
                updatedAt: null,
                createdAt: null,
              ));
            }
          } else {
            if (membership.membershipName == "Non Member" ||
                membership.membershipName == "Life Member") {
              memberShipList.value.add(MemberShipData(
                id: membership.id,
                membershipName: membership.membershipName,
                price: membership.price.toString(),
                status: membership.status.toString(),
                updatedAt: null,
                createdAt: null,
              ));
            }
          }
        }
      }
    }).onError((error, stack) {
      setRxRequestMemberShip(Status.ERROR);
      print("Error fetching membership: $error");
    });
  }

  void _showLoginAlert(BuildContext context) {
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
            children: [
              Row(
                children: [
                  Image.asset(
                    Images.logoImage,
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Age",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "You are not eligible. Your age is under 18 years.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(
                  ColorResources.red_color,
                ),
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

  void getDocumentType() {
    setRxRequestDocument(Status.LOADING);
    api.userDocumentType().then((_value) {
      setRxRequestDocument(Status.COMPLETE);
      setdocumentType(_value.data!);
    }).onError((error, strack) {
      setRxRequestDocument(Status.ERROR);
    });
  }

  void setSelectMemberSalutation(String value) {
    selectMemberSalutation.value = value;
  }

  void getCheckPinCode(var pincode) async {
    setRxRequestBuilding(Status.LOADING);
    var token =
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsb2NhbGhvc3QiLCJzdWIiOiI2IiwiaWF0IjoxNzMyNjA4ODc0LCJleHAiOjE3MzI2MTI0NzR9.5soj-FTXfHfGbr8qfJowy9RCJHJv65jRg1wx6hy_OCc";
    final url = Uri.parse(Urls.checkPinCode_url);
    Map payload = {"pincode": pincode};

    print("ccvv" + payload.toString());
    var headers = {
      'Authorization':
          'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsb2NhbGhvc3QiLCJzdWIiOiI2IiwiaWF0IjoxNzMyNjA4ODc0LCJleHAiOjE3MzI2MTI0NzR9.5soj-FTXfHfGbr8qfJowy9RCJHJv65jRg1wx6hy_OCc'
    };
    var request = http.MultipartRequest('POST', url);
    request.fields.addAll({'pincode': pincode});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      withoutcheckotp.value = true;
      countryNotFound.value = true;
      MandalZoneFlag.value = true;
      getMemberShip();
      setRxRequestBuilding(Status.COMPLETE);
      //  print(await response.stream.bytesToString());
      String responseBody = await response.stream.bytesToString();

      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      print("ggggggggggg" + jsonResponse.toString());
      CheckPinCodeModel pincodeResponse =
          CheckPinCodeModel.fromJson(jsonResponse);
      print('Status: ${pincodeResponse.status}');
      print('Message: ${pincodeResponse.message}');
      setcheckPinCode(pincodeResponse.data!.building!);
      if (!checkPinCodeList.any((b) => b.id == "other")) {
        checkPinCodeList.add(
          Building(
            id: "other",
            userId: null,
            pincodeId: null,
            buildingName: "Other",
            createdAt: null,
            updatedAt: null,
          ),
        );
      }
      // housenoController.value.text= _value.data.country;

      state_id.value = pincodeResponse.data!.state!.id.toString();
      city_id.value = pincodeResponse.data!.city!.id.toString();
      area_name.value = pincodeResponse.data!.areaName!.toString();
      zone_id.value = pincodeResponse.data!.zone!.id.toString();
      country_id.value = pincodeResponse.data!.country!.id.toString();
      countryController.value.text =
          pincodeResponse.data!.country!.name.toString();
      stateController.value.text = pincodeResponse.data!.state!.name.toString();
      cityController.value.text = pincodeResponse.data!.city!.name.toString();
      zoneController.value.text = pincodeResponse.data!.zone!.name.toString();
      areaController.value.text = pincodeResponse.data!.areaName!.toString();
    } else {
      MandalZoneFlag.value = false;
      countryNotFound.value = false;
      withoutcheckotp.value = true;
      areaController.value.text = "";
      getMemberShip();

      String responseBody = await response.stream.bytesToString();

      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      print("vvvvvvv" + responseBody.toString());
      setRxRequestBuilding(Status.COMPLETE);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchSaraswaniOptions();
  }

  void clearForm() {
    firstNameController.value.clear();
    lastNameController.value.clear();
    middleNameController.value.clear();
    fathersnameController.value.clear();
    mothersnameController.value.clear();
    mobileController.value.clear();
    whatappmobileController.value.clear();
    emailController.value.clear();
    buildingController.value.clear();
    occuptiondetailController.value.clear();
    educationdetailController.value.clear();
    dateController.clear();
    marriagedateController.value.clear();
    addressMemberController.value.clear();
    pincodeController.value.clear();
    housenoController.value.clear();
    stateController.value.clear();
    cityController.value.clear();
    zoneController.value.clear();
    areaController.value.clear();
    countryController.value.clear();

    // Reset dropdowns and observable variables
    selectedGender.value = '';
    selectMarital.value = '';
    selectBloodGroup.value = '';
    selectBuilding.value = '';
    selectDocumentType.value = '';
    selectMemberShipType.value = '';
    saraswaniOptionId.value = '';
    selectMemberSalutation.value = '';

    userprofile.value = '';
    userdocumentImage.value = '';
    isChecked.value = false;

    state_id.value = '';
    city_id.value = '';
    area_name.value = '';
    zone_id.value = '';
    country_id.value = '';
    memberId.value = '';
  }

  void userRegister(var LM_code, BuildContext context) async {
    print("member" + memberId.value);
    final url = Uri.parse(Urls.register_url);

    var first = firstNameController.value.text;
    var last = lastNameController.value.text.trim();

    var name = first + " " + last;
    var email = emailController.value.text.trim();
    var mobile = mobileController.value.text.trim();
    var pincode = pincodeController.value.text.trim();
    var blood_group_id = selectBloodGroup.value;
    var gender_id = selectedGender.value;
    var marital_status_id = selectMarital.value;
    var dob = dateController.value.text.trim();
    var building_name = buildingController.value.text.trim();
    var building_id = "";
    var membership_type_id = selectMemberShipType.value;
    var saraswani_option_id = saraswaniOptionId.value;

    if (selectBuilding.value == "other") {
      building_id = "0";
      if (building_name.isEmpty) {
        Get.snackbar(
          "Error",
          "Please enter building name",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        loading.value = false;
        return;
      }
    } else {
      building_id = selectBuilding.value;
      building_name = "";
    }

    var document_type = selectDocumentType.value;
    var flat_no = housenoController.value.text.trim();
    var whatsapp_number = whatappmobileController.value.text.trim();

    loading.value = true;
    var profile_image = userprofile.value;
    var document_image = userdocumentImage.value;

    Map<String, String> payload = {
      "proposer_id": memberId.value,
      "first_name": firstNameController.value.text.trim(),
      "last_name": last,
      "middle_name": middleNameController.value.text.trim(),
      "father_name": fathersnameController.value.text.trim(),
      "mother_name": mothersnameController.value.text.trim(),
      "email": email,
      "whatsapp_number": whatsapp_number.trim(),
      "mobile": mobile,
      "gender_id": gender_id,
      "marital_status_id": marital_status_id,
      "pincode": pincode,
      "blood_group_id": blood_group_id,
      "dob": dob,
      "document_type": document_type,
      "building_id": building_id,
      "building_name": building_name,
      "member_type_id": membership_type_id,
      "saraswani_option_id": saraswaniOptionId.value,
      "flat_no": flat_no,
      "state_id": state_id.value.toString(),
      "city_id": city_id.value.toString(),
      "area_name": area_name.value.toString(),
      "zone_id": zone_id.value.toString(),
      "country_id": country_id.value.toString(),
      "marriage_anniversary_date": marriagedateController.value.text,
      "salutation_id": selectMemberSalutation.value,
      "address": addressMemberController.value.text,
      "created_by": memberId.value,
      // "sankh_name": sankhText.value,
    };

    print("Payload: " + payload.toString());

    try {
      var request = http.MultipartRequest('POST', url);
      request.fields.addAll(payload);

      if (document_image.isNotEmpty) {
        request.files.add(
            await http.MultipartFile.fromPath('document_image', document_image)
        );
      }

      if (profile_image.isNotEmpty) {
        request.files.add(
            await http.MultipartFile.fromPath("image_profile", profile_image)
        );
      }

      http.StreamedResponse response =
      await request.send().timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        loading.value = false;
        Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        print("Response: " + jsonResponse.toString());

        RegisterModelClass registerResponse =
        RegisterModelClass.fromJson(jsonResponse);

        if (registerResponse.status == true) {
          clearForm();
          Get.snackbar(
            "Success",
            "New Member Added Successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );

          memberId.value = registerResponse.data.toString();
          Navigator.pushReplacementNamed(
              context!,
              RouteNames.regOtp_screen,
              arguments: {
                "memeberId": memberId.value,
                "page_type_direct": "1",
                "mobile": mobile,
                "email": email
              }
          );
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
        loading.value = false;
        String errorResponse = await response.stream.bytesToString();
        print("Error Response: " + errorResponse);
        Get.snackbar(
          "Error",
          "Failed to register. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      loading.value = false;
      print("Exception: " + e.toString());
      Get.snackbar(
        "Error",
        "An error occurred. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void checkLMcode(String lmCode) {
    setRxMemberRequest(Status.LOADING);
    Map datas = {"LM_code": lmCode};

    api.userCheckLMCodeApi(datas).then((_value) {
      setRxMemberRequest(Status.COMPLETE);
      lmCodeValue.value = lmCode;
      // setMember(_value.data!);
    }).onError((error, strack) {
      setRxMemberRequest(Status.ERROR);
      print("cvbcvbc" + error.toString());
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFFDC3545),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    });
  }

  var otp = '5555'.obs;
  void generateRandomOTP({int length = 4}) {
    final Random random = Random();
    final StringBuffer otpBuffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      otpBuffer.write(random.nextInt(10));
    }
    otp.value = otpBuffer.toString();
    print("fgfggghg" + otp.value);
  }
}
