import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class VitranRepository {
  final api = NetWorkApiService();

  Future<dynamic> fetchVitran({int limit = 20}) async {
    try {
      final url = "${Urls.vitran_list_url}?limit=$limit";

      final response = await api.getApi(url, "");

      debugPrint("Vitran Response : $response");

      return response;
    } catch (e) {
      rethrow;
    }
  }
}