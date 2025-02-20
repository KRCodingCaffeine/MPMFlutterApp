import 'package:mpm/OccuptionProfession/OccuptionProfessionModel.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/CheckPinCode/CheckPinCodeModel.dart';
import 'package:mpm/model/CheckPinCode/Country.dart';
import 'package:mpm/model/CheckUser/CheckLMCode.dart';
import 'package:mpm/model/CheckUser/CheckModelClass.dart';
import 'package:mpm/model/CountryModel/CountryModelClass.dart';

import 'package:mpm/model/Occupation/OccupationModel.dart';
import 'package:mpm/model/OccupationSpec/OccuptionSpecialization.dart';
import 'package:mpm/model/Qualification/QualificationModel.dart';
import 'package:mpm/model/QualificationCategory/QualificationCategoryModel.dart';
import 'package:mpm/model/QualificationMain/QualicationMainModel.dart';
import 'package:mpm/model/Register/RegisterModelClass.dart';
import 'package:mpm/model/State/StateModelClass.dart';


import 'package:mpm/model/bloodgroup/BloodGroupModel.dart';
import 'package:mpm/model/city/CityModelClass.dart';
import 'package:mpm/model/documenttype/DocumentTypeModel.dart';
import 'package:mpm/model/gender/GenderModelClass.dart';
import 'package:mpm/model/marital/MaritalModel.dart';
import 'package:mpm/model/membersalutation/MemberSalutationModel.dart';
import 'package:mpm/model/membership/MembershipModel.dart';
import 'package:mpm/model/relation/RelationModel.dart';
import 'package:mpm/model/search/SearchLMCodeModel.dart';
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
  Future<CountryModelClass> CountryApi() async {
    dynamic response =  await _apiService.getApi(Urls.country_url,"");
    print("bfnbfn"+response.toString());
    return CountryModelClass.fromJson(response);
  }
  Future<StateModelClass> StateApi() async {
    dynamic response =  await _apiService.getApi(Urls.state_url,"");
    print("bfnbfn"+response.toString());
    return StateModelClass.fromJson(response);
  }
  Future<CityModelClass> CityApi() async {
    dynamic response =  await _apiService.getApi(Urls.city_url,"");
    print("bfnbfn"+response.toString());
    return CityModelClass.fromJson(response);
  }

  Future<SearchLMCodeModel> userCheckLMCodeApi(var data) async {

    dynamic response = await _apiService.getApi(Urls.searchMemberProfile_url+"?search_term="+data, "");
    print("vdgvgdv"+response.toString());
    return SearchLMCodeModel.fromJson(response);

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
  Future<MemberSalutationModel> userMemberSalutation() async {
    dynamic response = await _apiService.getApi(Urls.memberSalutation_url,"");
    print("vdgvgdv"+response.toString());
    return MemberSalutationModel.fromJson(response);
  }


  Future<CheckModel> sendOTP(var data) async {
    dynamic response = await _apiService.postApi(data,Urls.sendOTP,"","2");
    print("vdgvgdv"+response.toString());
    return CheckModel.fromJson(response);
  }

  Future<CheckModel> verifyOTP(var data) async {
    dynamic response = await _apiService.postApi(data,Urls.verifyOTP,"","2");
    print("vdgvgdv"+response.toString());
    return CheckModel.fromJson(response);
  }






}