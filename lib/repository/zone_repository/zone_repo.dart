import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/Zone/ZoneModelClass.dart';
import 'package:mpm/utils/urls.dart';

class ZoneRepository {
  final NetWorkApiService _api = NetWorkApiService();

  Future<ZoneModelClass> ZoneApi() async {
    try {
      final response = await _api.getApi(Urls.zone_url, "");
      debugPrint("Zone API Response: $response");
      return ZoneModelClass.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
