import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/GetOccupationByMemberId/GetOccupationByMemberIdModelClass.dart';
import 'package:mpm/utils/urls.dart';

class GetOccupationByMemberIdRepository {
  final api = NetWorkApiService();

  Future<GetOccupationByMemberIdModelClass> getOccupationsByMemberId(
      String memberId) async {
    try {
      final url =
          "${Urls.get_occupations_by_member_id_url}?member_id=$memberId";

      debugPrint("🔵 Get Occupations API URL: $url");

      final response = await api.getApi(
        url,
        "",
      );

      debugPrint("🟢 Response: $response");

      return GetOccupationByMemberIdModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Fetching Occupations: $e");
      rethrow;
    }
  }
}