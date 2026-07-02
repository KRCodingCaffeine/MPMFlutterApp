import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/UpdateMoreOccupation/UpdateMoreOccupationModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateMoreOccupationRepository {
  final api = NetWorkApiService();

  Future<UpdateMoreOccupationModelClass> updateMoreOccupation(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.update_more_occupation_url;

      debugPrint("MORE OCCUPATION DETAIL API URL: $url");
      debugPrint("MORE OCCUPATION DETAIL RAW BODY: $body");

      final safeBody = _convertAllValuesToStrings(body);
      debugPrint("MORE OCCUPATION DETAIL FORM BODY: $safeBody");

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "2",
      );

      debugPrint("MORE OCCUPATION DETAIL API RESPONSE: $response");

      return UpdateMoreOccupationModelClass.fromJson(response);
    } catch (e) {
      debugPrint("MORE OCCUPATION DETAIL API ERROR: $e");
      rethrow;
    }
  }

  Map<String, dynamic> _convertAllValuesToStrings(Map<String, dynamic> body) {
    final safeBody = <String, dynamic>{};

    body.forEach((key, value) {
      safeBody[key] = value?.toString() ?? '';
    });

    return safeBody;
  }
}
