import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/UpdateFoodContainer/UpdateFoodContainerModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateFoodContainerRepository {
  final api = NetWorkApiService();

  /// Update Food Container for an event attendee
  Future<UpdateFoodContainerModelClass> updateFoodContainer(
      Map<String, dynamic> requestBody) async {
    try {
      final response = await api.postApi(
        requestBody,
        Urls.update_food_container_url,
        "",
        "2",
      );

      debugPrint("Update Food Container Response: $response");

      return UpdateFoodContainerModelClass.fromJson(response);
    } catch (e) {
      debugPrint("Error updating food container: $e");
      rethrow;
    }
  }
}
