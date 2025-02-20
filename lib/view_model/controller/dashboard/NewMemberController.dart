import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mpm/OccuptionProfession/OccuptionProfessionData.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CheckPinCode/Building.dart';

import 'package:mpm/model/CheckPinCode/CheckPinCodeModel.dart';

import 'package:mpm/model/CheckUser/CheckUserData.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/model/CountryModel/CountryData.dart';
import 'package:mpm/model/Occupation/OccupationData.dart';
import 'package:mpm/model/OccupationSpec/OccuptionSpecData.dart';
import 'package:mpm/model/Qualification/QualificationData.dart';
import 'package:mpm/model/QualificationCategory/QualificationCategoryModel.dart';
import 'package:mpm/model/QualificationMain/QualicationMainData.dart';
import 'package:mpm/model/Register/RegisterModelClass.dart';
import 'package:mpm/model/State/StateData.dart';

import 'package:mpm/model/bloodgroup/BloodData.dart';
import 'package:mpm/model/city/CityData.dart';
import 'package:mpm/model/documenttype/DocumentTypeModel.dart';
import 'package:mpm/model/gender/DataX.dart';

import 'package:mpm/model/marital/MaritalData.dart';
import 'package:mpm/model/membersalutation/MemberSalutationData.dart';
import 'package:mpm/model/membership/MemberShipData.dart';
import 'package:mpm/model/relation/RelationData.dart';
import 'package:mpm/repository/register_repository/register_repo.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/urls.dart';

class NewMemberController extends GetxController {
  final api = RegisterRepository();
  var loading = false.obs;
  var withoutcheckotp=false.obs;
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

  var arg_page="".obs;
  var state_id="".obs;
  var city_id="".obs;
  var area_name="".obs;
  var zone_id="".obs;
  var country_id="".obs;
  var genderList = <DataX>[].obs;
  var selectedGender = ''.obs;
  var maritalList = <MaritalData>[].obs;
  var selectMarital = ''.obs;
  var selectMember = CheckUserData().obs;
  var selectOccuption = ''.obs;
  var selectOccuptionPro = ''.obs;
  var selectOccuptionSpec = ''.obs;
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
  var isMarried = false.obs; //
  var memberId="".obs;
  var MaritalAnnivery=false.obs;
  var selectMemberSalutation =''.obs;
  BuildContext? context=Get.context;
  var countryList = <CountryData>[].obs;
  var stateList = <StateData>[].obs;
  var cityList = <CityData>[].obs;
  var countryNotFound=false.obs;
  final rxStatusMemberSalutation = Status.LOADING.obs;
  void setRxRequestCountry(Status _value) => rxStatusCountryLoading.value=_value;
  void setRxRequestState(Status _value) => rxStatusStateLoading.value=_value;
  void setRxRequestCity(Status _value) => rxStatusCityLoading.value=_value;
  void setRxRequestMemberSalutation(Status _value) => rxStatusMemberSalutation.value=_value;
  Rx<TextEditingController> housenoController=TextEditingController().obs;
  Rx<TextEditingController> stateController=TextEditingController().obs;
  Rx<TextEditingController> cityController=TextEditingController().obs;
  Rx<TextEditingController> zoneController=TextEditingController().obs;
  Rx<TextEditingController> areaController=TextEditingController().obs;
  Rx<TextEditingController> fathersnameController = TextEditingController().obs;
  Rx<TextEditingController> mothersnameController = TextEditingController().obs;
  Rx<TextEditingController>   pincodeController=TextEditingController().obs;
  Rx<TextEditingController>   firstNameController=TextEditingController().obs;
  Rx<TextEditingController>   lastNameController=TextEditingController().obs;
  Rx<TextEditingController>   middleNameController=TextEditingController().obs;
  Rx<TextEditingController>   mobileController=TextEditingController().obs;
  Rx<TextEditingController>   whatappmobileController=TextEditingController().obs;
  Rx<TextEditingController> countryController = TextEditingController().obs;
  Rx<TextEditingController>   emailController=TextEditingController().obs;
  Rx<TextEditingController>   buildingController=TextEditingController().obs;
  Rx<TextEditingController>   occuptiondetailController=TextEditingController().obs;
  Rx<TextEditingController>   educationdetailController=TextEditingController().obs;
  TextEditingController dateController = TextEditingController();
  Rx<TextEditingController> marriagedateController = TextEditingController().obs;
  var memberSalutationList =<MemberSalutationData>[].obs;
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
  void setCountry(List<CountryData> _value) => countryList.value =_value;
  void setState(List<StateData> _value) => stateList.value =_value;
  void setCity(List<CityData> _value) => cityList.value =_value;
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

  setMemberSalutation(List<MemberSalutationData> _value) => memberSalutationList.value =_value;

  var dropdownItems = <String>[].obs;
  var selectedValue = ''.obs;
  var isOccutionList = false.obs;
  var isQualicationList = false.obs;
  var isQualicationCateList = false.obs;
  void toggleCheckbox(bool? value) {
    isChecked.value = value ?? false;
  }
  void getMemberSalutation(){
    setRxRequestMemberSalutation(Status.LOADING);
    api.userMemberSalutation().then((_value) {
      setRxRequestMemberSalutation(Status.COMPLETE);
      setMemberSalutation(_value.data!);
    }).onError((error,strack) {
      setRxRequestMemberSalutation(Status.ERROR);
    });
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
  void getCountry(){
    setRxRequestCountry(Status.LOADING);
    api.CountryApi().then((_value) {
      setRxRequestCountry(Status.COMPLETE);
      setCountry(_value.data!);
    }).onError((error,strack) {
      setRxRequestCountry(Status.ERROR);
    });
  }
  void getState(){
    setRxRequestState(Status.LOADING);
    api.StateApi().then((_value) {
      setRxRequestState(Status.COMPLETE);
      setState(_value.data!);
    }).onError((error,strack) {
      setRxRequestState(Status.ERROR);
    });
  }
  void getCity(){
    setRxRequestCity(Status.LOADING);
    api.CityApi().then((_value) {
      setRxRequestCity(Status.COMPLETE);
      setCity(_value.data!);
    }).onError((error,strack) {
      setRxRequestCity(Status.ERROR);
    });
  }

  void setSelectedGender(String value) {
    selectedGender(value);
  }

  void setSelectedCountry(String value) {
    country_id(value);
  }
  void setSelectedState(String value) {
    state_id(value);
  }void setSelectedCity(String value) {
    city_id(value);
  }

  void setSelectedBuilding(String value) {
    selectBuilding(value);
  }

  void setSelectedMarital(String value) {
    selectMarital(value);
    if(value.toString()=="1")
    {
      MaritalAnnivery.value=true;
    }
    else
    {
      MaritalAnnivery.value=false;
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

  void setSelectOccuptionPro(String value) {
    selectOccuptionPro(value);
  }

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

  void getMemberShip() {
    setRxRequestMemberShip(Status.LOADING);
    api.userMemberShip().then((_value) {
      setRxRequestMemberShip(Status.COMPLETE);
      var date=dateController.value.text;
      DateFormat inputFormat = DateFormat("dd/MM/yyyy");
      DateFormat outputFormat = DateFormat("yyyy-MM-dd");

      DateTime dob = inputFormat.parse(date);
      String formattedDate = outputFormat.format(dob);

      print(formattedDate);
      if(withoutcheckotp.value==false)
      {
        print('hhh');
        setMemberShipType(_value.data!);

      }
      else if(withoutcheckotp.value==true)
      {

        if(isUnder18(dob))
        {
          if(zoneController.value.text=="")
          {
            print('hhh');
            _showLoginAlert(context!);
          }
          else
          {
            memberShipList.value.clear();

            for(int i=0;i<_value.data!.length;i++)
            {
              var memName= _value.data![i].membershipName;
              var id=_value.data![i].id;
              if(memName=="Non Member") {
                memberShipList.value.add(MemberShipData(id: id,
                    membershipName: memName,
                    price: _value.data![i].price.toString(),
                    status: _value.data![i].status.toString(),
                    updatedAt: null,
                    createdAt: null));
              }
            }
          }
        }
        else {
          print('hhh222');
          memberShipList.value.clear();
          for(int i=0;i<_value.data!.length;i++)
          {

            var memName= _value.data![i].membershipName;
            var id=_value.data![i].id;
            if(zoneController.value.text=="")
            {
              if(memName=="Saraswani Member" || memName=="Guest Member")
              {
                memberShipList.value.add(MemberShipData(id: id,
                    membershipName: memName,
                    price: _value.data![i].price.toString(),
                    status: _value.data![i].status.toString(),
                    updatedAt: null,
                    createdAt: null));
              }
            }
            else {
              if (memName == "Non Member" || memName == "Life Member") {
                memberShipList.value.add(MemberShipData(id: id,
                    membershipName: memName,
                    price: _value.data![i].price.toString(),
                    status: _value.data![i].status.toString(),
                    updatedAt: null,
                    createdAt: null));
              }
            }
          }


        }
      }
    }).onError((error, strack) {
      setRxRequestMemberShip(Status.ERROR);
    });
  }
  bool isUnder18(DateTime dateOfBirth) {
    final today = DateTime.now();
    final age = today.year - dateOfBirth.year;
    if (dateOfBirth.month > today.month || (dateOfBirth.month == today.month && dateOfBirth.day > today.day)) {
      return age - 1 < 18;
    }
    return age < 18;
  }



  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Row(
            children: [
              Image.asset(Images.logoImage,
                height: 50,
                width: 50,
              ),
              SizedBox(width: 10),
              Text("Age"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Your are not eligible .your age 18 year under. "),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                   Navigator.of(context).pop();
                },
              child: Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

              },
              child: Text("Yes"),
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
    selectMemberSalutation(value);
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
      withoutcheckotp.value=true;
      countryNotFound.value=true;
      getMemberShip();
      setRxRequestBuilding(Status.COMPLETE);
      //  print(await response.stream.bytesToString());
      String responseBody = await response.stream.bytesToString();

      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      CheckPinCodeModel pincodeResponse =
      CheckPinCodeModel.fromJson(jsonResponse);
      print('Status: ${pincodeResponse.status}');
      print('Message: ${pincodeResponse.message}');
      setcheckPinCode(pincodeResponse.data!.building!);
      checkPinCodeList.add(Building(
          id: "other",
          userId: null,
          pincodeId: null,
          buildingName: "Can't find  your building",
          createdAt: null,
          updatedAt: null));
      // housenoController.value.text= _value.data.country;

      state_id.value=pincodeResponse.data!.state!.id.toString();
      city_id.value=pincodeResponse.data!.city!.id.toString();
      area_name.value=pincodeResponse.data!.areaName!.toString();
      zone_id.value=pincodeResponse.data!.zone!.id.toString();
      country_id.value=pincodeResponse.data!.country!.id.toString();
      countryController.value.text=pincodeResponse.data!.country!.name.toString();
      stateController.value.text= pincodeResponse.data!.state!.name.toString();
      cityController.value.text=pincodeResponse.data!.city!.name.toString();
      zoneController.value.text= pincodeResponse.data!.zone!.name.toString();
      areaController.value.text =pincodeResponse.data!.areaName!.toString();
    }
    else {
      countryNotFound.value=false;
      withoutcheckotp.value=true;
      getMemberShip();
      print(response.reasonPhrase);
      setRxRequestBuilding(Status.COMPLETE);
    }
  }

  // void userRegister(var LM_code, BuildContext context) async {
  //   final url = Uri.parse(Urls.addmemberorfamily_url);
  //   LM_code = "LM-0006";
  //   var first = firstNameController.value.text;
  //   var last = lastNameController.value.text.trim();
  //   var name = first + "" + last;
  //   var email = emailController.value.text.trim();
  //   var mobile = mobileController.value.text.trim();
  //   var fathers_name = fatherNameController.value.text.trim();
  //   var mothers_name = motherNameController.value.text.trim();
  //   var marriage_anniversary = marriageAnniversaryController.value.text.trim();
  //   var pincode = pincodeController.value.text.trim();
  //   var blood_group_id = selectBloodGroup.value;
  //   var gender_id = selectedGender.value;
  //   var marital_status_id = selectMarital.value;
  //   var dob = dateController.value.text.trim();
  //
  //   var building_name = buildingController.value.text;
  //   var building_id = "";
  //   var membership_type_id = selectMemberShipType.value;
  //   if (selectBuilding.value == "other") {
  //     building_id = "";
  //   } else {
  //     building_id = selectBuilding.value;
  //   }
  //   var full_address = stateController.value.text +
  //       "" +
  //       cityController.value.text +
  //       "" +
  //       zoneController.value.text +
  //       "" +
  //       areaController.value.text;
  //   var document_type = selectDocumentType.value;
  //   var password = "1234";
  //   var occupation_id = "";
  //   var flat_no = housenoController.value.text;
  //   if (selectOccuption.value == "other") {
  //     occupation_id = "";
  //   } else {
  //     occupation_id = selectOccuption.value;
  //   }
  //   var qualification_id = "";
  //   if (selectQlification.value == 'other') {
  //     qualification_id = "";
  //   } else {
  //     qualification_id = selectQlification.value;
  //   }
  //   //var token=await SessionManager.getToken();
  //   var token =
  //       "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyMSIsImlhdCI6MTczNTQ2NjMyOCwiZXhwIjoxNzM1NDY5OTI4fQ.YVCh_-zc1Cap8ERgkY9yRVduxalEFEqUPT8RRs-NRcg";
  //
  //   // var token="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyMSIsImlhdCI6MTczNTQ1ODE1MCwiZXhwIjoxNzM1NDYxNzUwfQ.qSTPYD9uHX8eVNr1ZSdZIMBi1M_tlcrC8wg3vXxvwIY";
  //   print("bbbb" + token.toString());
  //
  //   var profession_id = selectOccuptionPro.value;
  //   var qualification_main_id = selectQualicationMain.value;
  //   var specialization_id = selectOccuptionSpec.value;
  //   var qualification_category_id = selectQualicationCat.value;
  //   var occupation_details = occuptiondetailController.value.text.trim();
  //   var qualification_details = educationdetailController.value.text.trim();
  //   var whatsapp_number = whatappmobileController.value.text.trim();
  //   var relation_type = "";
  //   if (selectRelationShipType.value == "") {
  //     relation_type = "normal";
  //   } else {
  //     relation_type = "family";
  //   }
  //   var relation_id = selectRelationShipType.value;
  //   loading.value = true;
  //   var profile_image = userprofile.value;
  //   var document_image = userdocumentImage.value;
  //   Map<String, String> payload = {
  //     "LM_code": LM_code,
  //     "name": name,
  //     "email": email,
  //     "mobile": mobile,
  //     "password": password,
  //     "pincode": pincode,
  //     "blood_group_id": blood_group_id,
  //     "gender_id": gender_id,
  //     "marital_status_id": marital_status_id,
  //     "dob": dob,
  //     "building_name": building_name,
  //     "full_address": full_address,
  //     "document_type": document_type,
  //     "occupation_id": occupation_id,
  //     "qualification_id": qualification_id,
  //     "profession_id": profession_id,
  //     "qualification_main_id": qualification_main_id,
  //     "specialization_id": specialization_id,
  //     "qualification_category_id": qualification_category_id,
  //     "occupation_details": occupation_details,
  //     "qualification_details": qualification_details,
  //     "building_id": building_id,
  //     "member_type_id": membership_type_id,
  //     "whatsapp_number": whatsapp_number,
  //     "fathers_name": fathers_name,
  //     "mothers_name": mothers_name,
  //     "marriage_anniversary": marriage_anniversary,
  //     "flat_no": flat_no,
  //     "relation_type": relation_type,
  //     "relation_id": relation_id
  //   };
  //   print("ccvv" + payload.toString());
  //   var request = http.MultipartRequest('POST', url);
  //   request.fields.addAll(payload);
  //   request.files.add(
  //       await http.MultipartFile.fromPath('document_image', document_image));
  //   if (profile_image != "") {
  //     request.files.add(
  //         await http.MultipartFile.fromPath("image_profile", profile_image));
  //   }
  //   var headers = {'Authorization': 'Bearer $token'};
  //   request.headers.addAll(headers);
  //   http.StreamedResponse response =
  //   await request.send().timeout(Duration(seconds: 120));
  //   if (response.statusCode == 200) {
  //     String responseBody = await response.stream.bytesToString();
  //     loading.value = false;
  //     Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
  //     RegisterModelClass registerResponse =
  //     RegisterModelClass.fromJson(jsonResponse);
  //     if (registerResponse.status == true) {
  //       Get.snackbar(
  //         "Success",
  //         "New User Register Successfully",
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //         snackPosition: SnackPosition.TOP,
  //       );
  //       Navigator.pushReplacementNamed(context!, RouteNames.dashboard);
  //     } else {
  //       Get.snackbar(
  //         "Error",
  //         registerResponse.message.toString(),
  //         backgroundColor: Color(0xFFDC3545),
  //         colorText: Colors.white,
  //         snackPosition: SnackPosition.TOP,
  //       );
  //     }
  //   } else {
  //     loading.value = false;
  //     print("gfgghgh" + response.reasonPhrase.toString());
  //     String responseBody = await response.stream.bytesToString();
  //     loading.value = false;
  //     Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
  //     RegisterModelClass registerResponse =
  //     RegisterModelClass.fromJson(jsonResponse);
  //
  //     Get.snackbar(
  //       "Error",
  //       "" + registerResponse.message.toString(),
  //       backgroundColor: Color(0xFFDC3545),
  //       colorText: Colors.white,
  //       snackPosition: SnackPosition.TOP,
  //     );
  //   }
  // }
  void userRegister(var LM_code,BuildContext context) async{
    print("member"+memberId.value);
    final url = Uri.parse(Urls.register_url);
    var first=firstNameController.value.text;
    var last=lastNameController.value.text.trim();
    var name= first+""+last;
    var email=emailController.value.text.trim();
    var mobile=mobileController.value.text.trim();
    var pincode=pincodeController.value.text.trim();
    var blood_group_id=selectBloodGroup.value;
    var gender_id=selectedGender.value;
    var marital_status_id= selectMarital.value;
    var dob= dateController.value.text.trim();
    var building_name = buildingController.value.text;
    var building_id="";
    var membership_type_id= selectMemberShipType.value;
    if(selectBuilding.value=="other")
    {
      building_id="";
    }
    else
    {
      building_id=selectBuilding.value;
    }
    var document_type=selectDocumentType.value;

    var flat_no=housenoController.value.text;
    var whatsapp_number=whatappmobileController.value.text.trim();
    loading.value=true;
    var profile_image=userprofile.value;
    var document_image=userdocumentImage.value;
    Map<String,String> payload = {
      "proposer_id":memberId.value,
      "first_name":firstNameController.value.text,
      "last_name": lastNameController.value.text,""
          "middle_name": middleNameController.value.text,
      "father_name": fathersnameController.value.text,
      "mother_name":mothersnameController.value.text,
      "email": email,
      "whatsapp_number": whatsapp_number,
      "mobile": mobile,
      "gender_id": gender_id,
      "marital_status_id": marital_status_id,
      "pincode": pincode,
      "blood_group_id": blood_group_id,
      "dob": dob,
      "document_type": document_type,
      "building_id": building_id,
      "member_type_id":  membership_type_id,
      "flat_no": flat_no,
      "state_id":state_id.value.toString(),
      "city_id":city_id.value.toString(),
      "area_name":area_name.value.toString(),
      "zone_id":zone_id.value.toString(),
      "country_id":country_id.value.toString(),
      "marriage_anniversary_date": marriagedateController.value.text,
      "salutation_id": selectMemberSalutation.value,

    };
    print("ccvv"+payload.toString());
    var request = http.MultipartRequest('POST',url);
    request.fields.addAll(payload);
    request.files.add(await http.MultipartFile.fromPath('document_image',document_image));
    if(profile_image!="") {
      request.files.add(
          await http.MultipartFile.fromPath("image_profile", profile_image));
    }

    http.StreamedResponse response = await request.send().timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      loading.value=false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      print("vfbb"+jsonResponse.toString());
      RegisterModelClass registerResponse = RegisterModelClass.fromJson(jsonResponse);
      if(registerResponse.status==true)
      {
        Get.snackbar(
          "Success",
          "New Member Add Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        memberId.value=registerResponse.data.toString();

        Navigator.pushReplacementNamed(context!, RouteNames.otp_screen,arguments: {
          "memeberId":memberId.value,
          "page_type_direct":"1",
          "mobile": mobile
        });
      }
      else
      {
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
      loading.value=false;
      // print(""+await response.stream.bytesToString());
      String responseBody = await response.stream.bytesToString();
      loading.value=false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      RegisterModelClass registerResponse = RegisterModelClass.fromJson(jsonResponse);

      Get.snackbar(
        "Error",
        ""+registerResponse.message.toString(),
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
        'Error', // Title
        error.toString(), // Message
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
      otpBuffer.write(random.nextInt(10)); // Generate a single digit (0-9)
    }
    otp.value = otpBuffer.toString();
    print("fgfggghg" + otp.value);
  }

  void sendOtp(var mobile, var otp) async {
    var url =
        "https://web.azinfomedia.com/domestic/sendsms/bulksms_v2.php?apikey=TWFoZXNod2FyaTp4em5ESlVPcA==&type=TEXT&sender=ASCTRL&entityId=xznDJUOp&templateId=1707170308164618962&mobile=${mobile}&message=Your%20One%20Time%20Password%20(OTP)%20is:%20${otp}%20Please%20use%20this%20OTP%20to%20complete%20your%20login.%20For%20Any%20Support%20Contact%20-%20Maheshwari%20Pragati%20Mandal%20ASCENT";
    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the response if needed
        var data = json.decode(response.body);
        print('OTP Sent Successfully: $data');
      } else {
        print('Failed to send OTP. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {

    }
  }
}
