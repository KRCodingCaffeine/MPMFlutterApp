import 'dart:convert';
import 'dart:io';

import 'package:mpm/data/AppExpection.dart';
import 'package:mpm/data/network/base_api_service.dart';
import 'package:http/http.dart' as http;
class NetWorkApiService extends BaseApiService{
  @override
  Future getApi(String url, String token) async {
    dynamic resonseJson;
    try{
      final response = await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 40),
      );
      resonseJson= returnResponse(response);
      print("gfgfg"+resonseJson.toString());
    } on SocketException{
      throw InternetExpection("");
    } on RequestTimeOutExpection{
      throw RequestTimeOutExpection("");
    }
    return resonseJson;
  }
  dynamic returnResponse(http.Response response)
  {
    switch (response.statusCode){
      case 200:
        dynamic responseJson =json.decode(response.body);
        return responseJson;
      case 400:
        throw InvalidExpection();

        case 404:
        throw InvalidExpection();
        default: FetchDataExpection("Error communication ouuror");
    }

  }

  @override
  Future postApi(data, String url, String token,String type) async {
    dynamic resonseJson;
    var header;
    var body;
    if(type=="1")
      {
        header=<String,String> {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',

        };
        body=jsonEncode(data);
      }
    else
      {
        header=<String,String> {
          'Accept': 'application/json',

        };
        body=data;
      }
    try{
      final response = await http.post(Uri.parse(url),
        headers: header,
        body: body
      ).timeout(Duration(seconds: 60),
      );
      resonseJson= returnResponse(response);
      print("gfgfg"+response.body.toString());
    } on SocketException{
      throw InternetExpection("");
    } on RequestTimeOutExpection{
      throw RequestTimeOutExpection("");
    }
    return resonseJson;
  }

}
