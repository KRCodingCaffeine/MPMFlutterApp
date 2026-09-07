import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/utils/urls.dart';

class ElectionRepository {
  final api = NetWorkApiService();

  Future<dynamic> fetchElections({
    String? startYear,
    String? endYear,
    String? status,
    String? candidateType,
    String? samitiId,
    String? samitiSubCategoryId,
    String? memberId,
    String? mobile,
    String? electionId,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (startYear != null && startYear.isNotEmpty) {
        queryParams['start_year'] = startYear;
      }

      if (endYear != null && endYear.isNotEmpty) {
        queryParams['end_year'] = endYear;
      }

      if (samitiId != null && samitiId.isNotEmpty) {
        queryParams['samiti_id'] = samitiId;
      }

      if (samitiSubCategoryId != null &&
          samitiSubCategoryId.isNotEmpty) {
        queryParams['samiti_sub_category_id'] =
            samitiSubCategoryId;
      }

      final uri = Uri.parse(
        Urls.election_list_url,
      ).replace(
        queryParameters: queryParams,
      );

      final url = uri.toString();

      debugPrint('Election API URL: $url');

      final response = await api.getApi(
        url,
        "",
      );

      debugPrint(
        'Election API Response: $response',
      );

      return response;
    } catch (e) {
      debugPrint(
        'Election Repository Error: $e',
      );

      rethrow;
    }
  }
}