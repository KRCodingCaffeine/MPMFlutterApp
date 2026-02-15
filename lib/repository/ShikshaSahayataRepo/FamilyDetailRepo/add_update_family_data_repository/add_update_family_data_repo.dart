import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/FamilyDetail/AddUpdateFamilyDataModelClass.dart';
import 'package:mpm/utils/urls.dart';

class AddUpdateFamilyDataRepository {
  final api = NetWorkApiService();

  Future<AddUpdateFamilyDataModelClass> addOrUpdateFamilyData(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.add_or_update_family_data_url;

      debugPrint("🔵 Add/Update Family API URL: $url");
      debugPrint("📤 Request Body: $body");

      final response = await api.postApi(
        body,
        url,
        "",
        "1",
      );

      debugPrint("🟢 Response: $response");

      return AddUpdateFamilyDataModelClass.fromJson(response);
    } catch (e) {
      debugPrint("❌ Error Add/Update Family Data: $e");
      rethrow;
    }
  }
}
