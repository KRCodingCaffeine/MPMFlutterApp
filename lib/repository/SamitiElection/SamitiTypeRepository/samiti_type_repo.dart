import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/SamitiElection/SamitiTypes/SamitiTypeModelClass.dart';
import 'package:mpm/utils/urls.dart';

class SamitiTypeRepository {
  final api = NetWorkApiService();

  Future<SamitiTypeModelClass> fetchSamitiTypes() async {
    try {
      final url = Urls.get_samiti_types_url;

      debugPrint(
        'Get Samiti Types URL: $url',
      );

      final response = await api.getApi(
        url,
        "",
      );

      debugPrint(
        'Get Samiti Types Response: $response',
      );

      return SamitiTypeModelClass.fromJson(
        response,
      );
    } catch (e) {
      debugPrint(
        'Get Samiti Types Repository Error: $e',
      );

      rethrow;
    }
  }
}