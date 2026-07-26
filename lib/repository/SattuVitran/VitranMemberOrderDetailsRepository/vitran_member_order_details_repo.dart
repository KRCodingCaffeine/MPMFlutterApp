import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/utils/urls.dart';

class VitranMemberOrderDetailsRepository {
  final api = NetWorkApiService();

  Future<dynamic> fetchVitranMemberOrderDetails({
    required String vitranMemberOrderId,
  }) async {
    try {
      final url =
          "${Urls.get_vitran_member_order_details_url}"
          "?vitran_member_order_id=$vitranMemberOrderId";

      debugPrint(url);

      final response = await api.getApi(url, "");

      debugPrint(response.toString());

      return response;
    } catch (e) {
      rethrow;
    }
  }
}