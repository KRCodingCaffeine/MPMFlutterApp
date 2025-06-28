import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/SaraswaniOption/SaraswaniOptionModelClass.dart';
import 'package:mpm/utils/urls.dart';

class SaraswaniOptionRepository {
  final NetWorkApiService _api = NetWorkApiService();

  Future<SaraswaniOptionModelClass> SaraswaniOptionApi() async {
    try {
      final response = await _api.getApi(Urls.saraswani_option_url, "");
      debugPrint("Saraswani Option API Response: $response");
      return SaraswaniOptionModelClass.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
