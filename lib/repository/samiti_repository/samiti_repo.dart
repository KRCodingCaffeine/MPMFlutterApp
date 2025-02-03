import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/samiti/SamitiDetailModel.dart';

import 'package:mpm/utils/urls.dart';
class SamitiRepository{
  var api=NetWorkApiService();
  Future<dynamic> userSamitiApi() async {
    dynamic response= api.getApi(Urls.samiti_url,"");
    print("bdnbfndb"+response.toString());

    return response;
  }
  Future<dynamic> userSamitiDetailsApi(data) async {
    print("urls"+Urls.samiti_detail_url+"?samiti_category_id="+data);
    dynamic response= api.getApi(Urls.samiti_detail_url+"?samiti_category_id="+data,"");
  return response;
  }
}