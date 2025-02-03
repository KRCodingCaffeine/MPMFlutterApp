import 'package:mpm/OccuptionProfession/OccuptionProfessionModel.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/CheckPinCode/CheckPinCodeModel.dart';
import 'package:mpm/model/CheckUser/CheckLMCode.dart';
import 'package:mpm/model/CheckUser/CheckModelClass.dart';

import 'package:mpm/model/Occupation/OccupationModel.dart';
import 'package:mpm/model/OccupationSpec/OccuptionSpecialization.dart';
import 'package:mpm/model/Qualification/QualificationModel.dart';
import 'package:mpm/model/QualificationCategory/QualificationCategoryModel.dart';
import 'package:mpm/model/QualificationMain/QualicationMainModel.dart';
import 'package:mpm/model/Register/RegisterModelClass.dart';


import 'package:mpm/model/bloodgroup/BloodGroupModel.dart';
import 'package:mpm/model/documenttype/DocumentTypeModel.dart';
import 'package:mpm/model/gender/GenderModelClass.dart';
import 'package:mpm/model/marital/MaritalModel.dart';
import 'package:mpm/model/membership/MembershipModel.dart';
import 'package:mpm/model/relation/RelationModel.dart';
import 'package:mpm/utils/urls.dart';

class RegisterRepository {
  final _apiService  = NetWorkApiService();


  Future<GenderModelClass> userGenderApi() async {
 var token="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsb2NhbGhvc3QiLCJzdWIiOiI2IiwiaWF0IjoxNzMyNjA0ODUzLCJleHAiOjE3MzI2MDg0NTN9.X-EV2yFYM7Fugzqt4l7Wkogqc7ccQA64ApEOMqJ6aJg";
    dynamic response =  await _apiService.getApi(Urls.gender_url,token);
    print("bfnbfn"+response.toString());
    return GenderModelClass.fromJson(response);
  }
  Future<MaritalModel> userMaritalApi() async {
 var token="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsb2NhbGhvc3QiLCJzdWIiOiI2IiwiaWF0IjoxNzMyNjA0ODUzLCJleHAiOjE3MzI2MDg0NTN9.X-EV2yFYM7Fugzqt4l7Wkogqc7ccQA64ApEOMqJ6aJg";
    dynamic response =  await _apiService.getApi(Urls.material_url,token);
    print("bfnbfn"+response.toString());
    return MaritalModel.fromJson(response);
  }
  Future<BloodGroupModel> userBloodGroupApi() async {
 var token="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsb2NhbGhvc3QiLCJzdWIiOiI2IiwiaWF0IjoxNzMyNjA0ODUzLCJleHAiOjE3MzI2MDg0NTN9.X-EV2yFYM7Fugzqt4l7Wkogqc7ccQA64ApEOMqJ6aJg";
    dynamic response =  await _apiService.getApi(Urls.bloodgroup_url,token);
    print("bfnbfn"+response.toString());
    return BloodGroupModel.fromJson(response);
  }
  Future<OccupationModel> userOccupationDataApi() async {
     dynamic response =  await _apiService.postApi("",Urls.occuption_url,"","2");
    print("bfnbfn"+response.toString());
    return OccupationModel.fromJson(response);
  }
  Future<CheckLMCode> userCheckLMCodeApi(var data) async {

    dynamic response = await _apiService.postApi(data, Urls.check_url, "","2");
    print("vdgvgdv"+response.toString());
    return CheckLMCode.fromJson(response);

  }
  Future<OccuptionProfessionModel> userOccutionPreCodeApi(var data) async {
    dynamic response = await _apiService.postApi(data, Urls.occuption_profession_url, "","2");
    print("vdgvgdv"+response.toString());
    return OccuptionProfessionModel.fromJson(response);

  }
  Future<OccuptionSpectionModel> userOccutionSpectionCodeApi(var data) async {
    dynamic response = await _apiService.postApi(data, Urls.occuption_specialization_url, "","2");
    print("vdgvgdv"+response.toString());
    return OccuptionSpectionModel.fromJson(response);

  }
  Future<QualificationModel> userQualification() async {
    dynamic response = await _apiService.postApi("", Urls.qualification_url, "","2");
    print("vdgvgdv"+response.toString());
    return QualificationModel.fromJson(response);

  }
  Future<QualicationMainModel> userQualificationMain(var data) async {
    dynamic response = await _apiService.postApi(data, Urls.qualificationmain_url, "","2");
    print("vdgvgdv"+response.toString());
    return QualicationMainModel.fromJson(response);

  }
  Future<QualificationCategoryModel> userQualificationCategory(var data) async {
    dynamic response = await _apiService.postApi(data, Urls.qualificationcategory_url, "","2");
    print("vdgvgdv"+response.toString());
    return QualificationCategoryModel.fromJson(response);
  }
  Future<DocumentTypeModel> userDocumentType() async {
    dynamic response = await _apiService.postApi("", Urls.documentotion_url, "","2");
    print("vdgvgdv"+response.toString());
    return DocumentTypeModel.fromJson(response);
  }
  Future<MembershipModel> userMemberShip() async {
    var token ="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsb2NhbGhvc3QiLCJzdWIiOiI2IiwiaWF0IjoxNzMyNjA0ODUzLCJleHAiOjE3MzI2MDg0NTN9.X-EV2yFYM7Fugzqt4l7Wkogqc7ccQA64ApEOMqJ6aJg";
    dynamic response = await _apiService.getApi(Urls.membership_url,token);
    print("vdgvgdv"+response.toString());
    return MembershipModel.fromJson(response);
  }

 Future<RelationModel> userFamilyRelation(data) async {
    dynamic response = await _apiService.postApi(data,Urls.relation_url,"","2");
    print("vdgvgdv"+response.toString());
    return RelationModel.fromJson(response);
  }






}