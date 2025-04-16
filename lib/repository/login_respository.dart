import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/CheckUser/CheckModelClass.dart';
import 'package:mpm/model/Register/RegisterModelClass.dart';
import 'package:mpm/utils/urls.dart';

class LoginRepo{
  var api=NetWorkApiService();
  Future<dynamic> userLoginApi(var data) async {
   dynamic response= api.postApi(data, Urls.check_url, "","1");
   return response;

  }
  Future<RegisterModelClass> userVerify(var token) async {
    dynamic response = await api.getApi(Urls.verify_url,token);
    print("vdgvgdv"+response.toString());
    return RegisterModelClass.fromJson(response);
  }
  Future<RegisterModelClass> sendOTP(var data) async {
    dynamic response = await api.postApi(data,Urls.sendOTP,"","2");
    print("vdgvgdv"+response.toString());
    return RegisterModelClass.fromJson(response);
  }

  Future<CheckModel> verifyOTP(var data) async {
    dynamic response = await api.postApi(data,Urls.verifyOTP,"","2");
    print("vdgvgdv"+response.toString());
    return CheckModel.fromJson(response);
  }
  Future<dynamic> userToken(data) async {
    dynamic response = await api.postApi(data,Urls.updatetoken_url,"","2");
    return response;
  }

}