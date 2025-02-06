import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CheckPinCode/Building.dart';
import 'package:mpm/model/CheckPinCode/CheckPinCodeModel.dart';
import 'package:mpm/model/CheckUser/CheckUserData.dart';
import 'package:mpm/model/Register/RegisterModelClass.dart';
import 'package:mpm/model/bloodgroup/BloodData.dart';
import 'package:mpm/model/documenttype/DocumentTypeModel.dart';
import 'package:mpm/model/gender/DataX.dart';
import 'package:mpm/model/marital/MaritalData.dart';
import 'package:mpm/model/membership/MemberShipData.dart';
import 'package:mpm/model/relation/RelationData.dart';
import 'package:mpm/repository/register_repository/register_repo.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/urls.dart';

class NewMemberController extends GetxController {
  final api = RegisterRepository();
  var loading = false.obs;
  RxBool isChecked = false.obs;
  final rxStatusLoading = Status.IDLE.obs;
  final rxStatusMemberLoading = Status.IDLE.obs;
  final rxStatusLoading2 = Status.LOADING.obs;
  final rxStatusmarried = Status.LOADING.obs;
  final rxStatusBuilding = Status.IDLE.obs;
  final rxStatusDocument = Status.LOADING.obs;
  final rxStatusMemberShipTYpe = Status.LOADING.obs;
  final rxStatusRelationType = Status.LOADING.obs;

  var genderList = <DataX>[].obs;
  var selectedGender = ''.obs;
  var maritalList = <MaritalData>[].obs;
  var selectMarital = ''.obs;
  var selectMember = CheckUserData().obs;
  var bloodgroupList = <BloodGroupData>[].obs;
  var selectBloodGroup = ''.obs;
  var selectBuilding = ''.obs;
  var selectDocumentType = ''.obs;
  var selectMemberShipType = ''.obs;
  var selectRelationShipType = ''.obs;
  var memberList = <CheckUserData>[].obs;
  var ducumentList = <CheckUserData>[].obs;

  var checkPinCodeList = <Building>[].obs;
  var memberShipList = <MemberShipData>[].obs;
  var documntTypeList = <DocumentTypeData>[].obs;
  var relationShipTypeList = <RelationData>[].obs;
  var isButtonEnabled = false.obs;
  var lmCodeValue = ''.obs;
  var userprofile = ''.obs;
  var userdocumentImage = ''.obs;
  var isBuilding = false.obs;
  var isRelation = false.obs;
  var isMarried = false.obs; //

  Rx<TextEditingController> housenoController = TextEditingController().obs;
  Rx<TextEditingController> stateController = TextEditingController().obs;
  Rx<TextEditingController> countryController = TextEditingController().obs;
  Rx<TextEditingController> cityController = TextEditingController().obs;
  Rx<TextEditingController> zoneController = TextEditingController().obs;
  Rx<TextEditingController> areaController = TextEditingController().obs;

  Rx<TextEditingController> pincodeController = TextEditingController().obs;
  Rx<TextEditingController> firstNameController = TextEditingController().obs;
  Rx<TextEditingController> lastNameController = TextEditingController().obs;
  Rx<TextEditingController> middleNameController = TextEditingController().obs;
  Rx<TextEditingController> mobileController = TextEditingController().obs;
  Rx<TextEditingController> whatappmobileController =
      TextEditingController().obs;
  Rx<TextEditingController> fatherNameController = TextEditingController().obs;
  Rx<TextEditingController> motherNameController = TextEditingController().obs;
  Rx<DateTime?> anniversaryDate = Rx<DateTime?>(null);

  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> buildingController = TextEditingController().obs;
  TextEditingController dateController = TextEditingController();
  void setRxRequest(Status _value) => rxStatusLoading.value = _value;
  void setRxMemberRequest(Status _value) =>
      rxStatusMemberLoading.value = _value;
  void setRxRequest2(Status _value) => rxStatusLoading2.value = _value;
  void setRxRequestMarried(Status _value) => rxStatusmarried.value = _value;
  void setRxRequestBuilding(Status _value) => rxStatusBuilding.value = _value;
  void setRxRequestDocument(Status _value) => rxStatusDocument.value = _value;
  void setRxRequestMemberShip(Status _value) =>
      rxStatusMemberShipTYpe.value = _value;
  void setRxRelationType(Status _value) => rxStatusRelationType.value = _value;
  void setGender(List<DataX> _value) => genderList.value = _value;
  void setMaritalStatus(List<MaritalData> _value) => maritalList.value = _value;
  void setBloodStatus(List<BloodGroupData> _value) =>
      bloodgroupList.value = _value;
  void setMember(List<CheckUserData> _value) => memberList.value = _value;
  setcheckPinCode(List<Building> _value) => checkPinCodeList.value = _value;
  setdocumentType(List<DocumentTypeData> _value) =>
      documntTypeList.value = _value;
  setMemberShipType(List<MemberShipData> _value) =>
      memberShipList.value = _value;
  setRelationShipType(List<RelationData> _value) =>
      relationShipTypeList.value = _value;

  var dropdownItems = <String>[].obs;
  var selectedValue = ''.obs;
  void toggleCheckbox(bool? value) {
    isChecked.value = value ?? false;
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

  void setSelectedGender(String value) {
    selectedGender(value);
  }

  void setSelectedBuilding(String value) {
    selectBuilding(value);
  }

  void setSelectedMarital(String value) {
    selectMarital(value);
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

  void setSelectMemberShip(String value) {
    selectMemberShipType(value);
  }

  void setSelectRelationShip(String value) {
    selectRelationShipType(value);
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
      setMemberShipType(_value.data!);
    }).onError((error, strack) {
      setRxRequestMemberShip(Status.ERROR);
    });
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
      stateController.value.text = pincodeResponse.data!.state!.name.toString();
      countryController.value.text =
          pincodeResponse.data!.country!.name.toString();
      cityController.value.text = pincodeResponse.data!.city!.name.toString();
      zoneController.value.text = pincodeResponse.data!.zone!.name.toString();
      areaController.value.text = pincodeResponse.data!.areaName!.toString();
    } else {
      print(response.reasonPhrase);
      setRxRequestBuilding(Status.COMPLETE);
    }
  }

  void userRegister(var LM_code, BuildContext context) async {
    final url = Uri.parse(Urls.addmemberorfamily_url);
    LM_code = "LM-0006";
    var first = firstNameController.value.text;
    var last = lastNameController.value.text.trim();
    var name = first + "" + last;
    var email = emailController.value.text.trim();
    var mobile = mobileController.value.text.trim();
    var fathers_name = fatherNameController.value.text.trim();
    var mothers_name = motherNameController.value.text.trim();
    var pincode = pincodeController.value.text.trim();
    var blood_group_id = selectBloodGroup.value;
    var gender_id = selectedGender.value;
    var marital_status_id = selectMarital.value;
    var dob = dateController.value.text.trim();

    var building_name = buildingController.value.text;
    var building_id = "";
    var membership_type_id = selectMemberShipType.value;
    if (selectBuilding.value == "other") {
      building_id = "";
    } else {
      building_id = selectBuilding.value;
    }
    var full_address = stateController.value.text +
        "" +
        cityController.value.text +
        "" +
        countryController.value.text +
        "" +
        zoneController.value.text +
        "" +
        areaController.value.text;
    var document_type = selectDocumentType.value;
    var password = "1234";
    var flat_no = housenoController.value.text;

    //var token=await SessionManager.getToken();
    var token =
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyMSIsImlhdCI6MTczNTQ2NjMyOCwiZXhwIjoxNzM1NDY5OTI4fQ.YVCh_-zc1Cap8ERgkY9yRVduxalEFEqUPT8RRs-NRcg";

    // var token="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIyMSIsImlhdCI6MTczNTQ1ODE1MCwiZXhwIjoxNzM1NDYxNzUwfQ.qSTPYD9uHX8eVNr1ZSdZIMBi1M_tlcrC8wg3vXxvwIY";
    print("bbbb" + token.toString());

    var whatsapp_number = whatappmobileController.value.text.trim();
    var relation_type = "";
    if (selectRelationShipType.value == "") {
      relation_type = "normal";
    } else {
      relation_type = "family";
    }
    var relation_id = selectRelationShipType.value;
    loading.value = true;
    var profile_image = userprofile.value;
    var document_image = userdocumentImage.value;
    Map<String, String> payload = {
      "LM_code": LM_code,
      "name": name,
      "email": email,
      "mobile": mobile,
      "password": password,
      "pincode": pincode,
      "blood_group_id": blood_group_id,
      "gender_id": gender_id,
      "marital_status_id": marital_status_id,
      "dob": dob,
      "building_name": building_name,
      "full_address": full_address,
      "document_type": document_type,
      "building_id": building_id,
      "member_type_id": membership_type_id,
      "whatsapp_number": whatsapp_number,
      "fathers_name": fathers_name,
      "mothers_name": mothers_name,
      "flat_no": flat_no,
      "relation_type": relation_type,
      "relation_id": relation_id
    };
    print("ccvv" + payload.toString());
    var request = http.MultipartRequest('POST', url);
    request.fields.addAll(payload);
    request.files.add(
        await http.MultipartFile.fromPath('document_image', document_image));
    if (profile_image != "") {
      request.files.add(
          await http.MultipartFile.fromPath("image_profile", profile_image));
    }
    var headers = {'Authorization': 'Bearer $token'};
    request.headers.addAll(headers);
    http.StreamedResponse response =
        await request.send().timeout(Duration(seconds: 120));
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      loading.value = false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      RegisterModelClass registerResponse =
          RegisterModelClass.fromJson(jsonResponse);
      if (registerResponse.status == true) {
        Get.snackbar(
          "Success",
          "New User Register Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        Navigator.pushReplacementNamed(context!, RouteNames.dashboard);
      } else {
        Get.snackbar(
          "Error",
          registerResponse.message.toString(),
          backgroundColor: Color(0xFFDC3545),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } else {
      loading.value = false;
      print("gfgghgh" + response.reasonPhrase.toString());
      String responseBody = await response.stream.bytesToString();
      loading.value = false;
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      RegisterModelClass registerResponse =
          RegisterModelClass.fromJson(jsonResponse);

      Get.snackbar(
        "Error",
        "" + registerResponse.message.toString(),
        backgroundColor: Color(0xFFDC3545),
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
      setMember(_value.data!);
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
      // Set loading state to false
    }
  }
}
