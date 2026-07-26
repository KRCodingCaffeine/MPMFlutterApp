import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/utils/urls.dart';

class VitranRepository {
  final api = NetWorkApiService();

  Future<dynamic> fetchVitranDetails(String vitranId) async {
    try {
      final url = "${Urls.vitran_details_url}?vitran_id=$vitranId";

      final response = await api.getApi(url, "");

      debugPrint("Vitran Details Response : $response");

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
