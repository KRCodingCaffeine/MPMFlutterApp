import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/GetLatestSaraswaniPublication/GetLatestSaraswaniPublicationModelClass.dart';
import 'package:mpm/utils/urls.dart';

class GetLatestSaraswaniPublicationRepo {
  final api = NetWorkApiService();

  Future<GetLatestSaraswaniPublicationModelClass> fetchlatestSaraswaniPublications() async {
    try {
      final response = await api.getApi(Urls.getLatestSaraswaniPublications, "");
      debugPrint("Latest Saraswani Publications Response: $response");
      return GetLatestSaraswaniPublicationModelClass.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching latest Saraswani publications: $e");
      rethrow;
    }
  }
}
