import 'package:get/get.dart';
import 'package:mpm/OccuptionProfession/OccuptionProfessionModel.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/GetProfile/GetProfileModel.dart';
import 'package:mpm/model/Occupation/OccupationModel.dart';
import 'package:mpm/model/Occupation/addoccuption/AddOccuptionModel.dart';
import 'package:mpm/model/OccupationSpec/OccuptionSpecialization.dart';
import 'package:mpm/model/Qualification/QualificationModel.dart';
import 'package:mpm/model/QualificationCategory/QualificationCategoryModel.dart';
import 'package:mpm/model/QualificationMain/QualicationMainModel.dart';
import 'package:mpm/model/UpdateFamilyRelation/UpdateFamilyMember.dart';
import 'package:mpm/model/relation/RelationModel.dart';
import 'package:mpm/utils/urls.dart';

class UpdateProfileRepository {
  var api=NetWorkApiService();
  Future<GetUserProfileModel> getUserData(data) async {
    var url=Urls.getProfile_url+"?member_id=$data";
   // print("urls"+url.toString());
    dynamic response = await api.getApi(Urls.getProfile_url+"?member_id=$data","");
    print("Profile Data"+response.toString());
    return GetUserProfileModel.fromJson(response);
  }
  Future<dynamic> addQualification(data) async {
    dynamic response = await api.postApi(data,Urls.addEducation_url,"","2");
    //print("vdgvgdv"+response.toString());
    return response;
  }
  Future<dynamic> updateQualification(data) async {
    dynamic response = await api.postApi(data,Urls.updateQualification_url,"","2");
    print("vdgvgdv"+response.toString()+Urls.updateQualification_url);
    return response;
  }
  Future<UpdateFamilyMember> updateFamilyRelation(data) async {
    dynamic response = await api.postApi(data,Urls.addUpdateFamilyMEber_url,"","2");
    //print("vdgvgdv"+response.toString());
    return UpdateFamilyMember.fromJson(response);
  }
  Future<OccupationModel> userOccupationDataApi() async {
    dynamic response =  await api.postApi("",Urls.occuption_url,"","2");
    //print("bfnbfn"+response.toString());
    return OccupationModel.fromJson(response);
  }
  Future<OccuptionProfessionModel> userOccutionPreCodeApi(var data) async {
    dynamic response = await api.postApi(data, Urls.occuption_profession_url, "","2");
   // print("vdgvgdv"+response.toString());
    return OccuptionProfessionModel.fromJson(response);

  }
  Future<OccuptionSpectionModel> userOccutionSpectionCodeApi(var data) async {
    dynamic response = await api.postApi(data, Urls.occuption_specialization_url, "","2");
    //print("vdgvgdv"+response.toString());
    return OccuptionSpectionModel.fromJson(response);

  }
  Future<AddOccuptionModel> updateOrAddOccuption(data) async {
    dynamic response = await api.postApi(data,Urls.addOccuption_url,"","2");
    //print("vdgvgdv"+response.toString());
    return AddOccuptionModel.fromJson(response);
  }
  Future<QualificationModel> userQualification() async {
    dynamic response = await api.postApi("", Urls.qualification_url, "","2");
    //print("vdgvgdv"+response.toString());
    return QualificationModel.fromJson(response);

  }
  Future<dynamic> userAddBusiness(data) async {
    dynamic response = await api.postApi(data, Urls.addBusinessInfo_url, "","2");
    //print("vdgvgdv"+response.toString());
    return response;

  }
  Future<dynamic> userUpdateBusiness(data) async {
    dynamic response = await api.postApi(data, Urls.updateBusinessInfo_url, "","2");
    //print("vdgvgdv"+response.toString());
    return response;

  }
  Future<QualicationMainModel> userQualificationMain(var data) async {
    dynamic response = await api.postApi(data, Urls.qualificationmain_url, "","2");
    //print("vdgvgdv"+response.toString());
    return QualicationMainModel.fromJson(response);

  }
  Future<QualificationCategoryModel> userQualificationCategory(var data) async {
    dynamic response = await api.postApi(data, Urls.qualificationcategory_url, "","2");
    //print("vdgvgdv"+response.toString());
    return QualificationCategoryModel.fromJson(response);
  }
  Future<RelationModel> userFamilyRelation(data) async {
    dynamic response = await api.postApi(data,Urls.relation_url,"","2");
    print("relationdata"+response.toString());
    return RelationModel.fromJson(response);
  }
  Future<dynamic> userJanganaStatus(data) async {
    print("relationdata"+Urls.updateJanganaStatus_url+"?member_id=$data");
    dynamic response = await api.getApi(Urls.updateJanganaStatus_url+"?member_id=$data","");

    return response;
  }


}