import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/SearchOccupation/SearchOccupationModelClass.dart';
import 'package:mpm/utils/urls.dart';

class SearchOccupationRepository {
  final api = NetWorkApiService();

  Future<SearchOccupationModelClass> searchOccupation({
    required String searchTerm,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final url =
          "${Urls.searchOccupation_url}?search_term=$searchTerm&limit=$limit&offset=$offset";

      debugPrint("Search Occupation URL: $url");

      final response = await api.getApi(url, "");

      debugPrint("Search Occupation Response: $response");

      return SearchOccupationModelClass.fromJson(response);

    } catch (e) {
      debugPrint("Error searching occupation: $e");
      rethrow;
    }
  }
}
