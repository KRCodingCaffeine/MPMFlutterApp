import 'package:flutter/material.dart';

import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/GetSaraswaniPublication/GetSaraswaniPublicationModelClass.dart';
import 'package:mpm/utils/urls.dart';

class SaraswaniPublicationRepository {
  final api = NetWorkApiService();

  Future<SaraswaniPublicationModelClass> fetchSaraswaniPublication({
    required String month,
    required String year,
  }) async {
    try {
      final requestBody = {
        'month': month,
        'year': year,
      };

      final response = await api.postApi(
        requestBody,
        Urls.get_saraswani_publication,
        "",
        "2",
      );

      debugPrint("Saraswani Publication Response: $response");

      return SaraswaniPublicationModelClass.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching Saraswani publication: $e");
      rethrow;
    }
  }
}
