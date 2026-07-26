import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/utils/urls.dart';

class VitranMemberOrderListRepository {
  final api = NetWorkApiService();

  Future<dynamic> fetchVitranMemberOrders({
    required String memberId,
    String? vitranId,
    String? orderStatus,
  }) async {
    try {
      final url =
          "${Urls.list_vitran_member_order_url}"
          "?member_id=$memberId"
          "&vitran_id=${vitranId ?? ""}"
          "&order_status=${orderStatus ?? ""}";

      debugPrint(url);

      final response = await api.getApi(url, "");

      debugPrint(response.toString());

      return response;
    } catch (e) {
      rethrow;
    }
  }
}