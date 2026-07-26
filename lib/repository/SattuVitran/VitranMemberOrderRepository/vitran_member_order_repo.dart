import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/SattuVitran/VitranMemberOrder/VitranMemberOrderData.dart';
import 'package:mpm/utils/urls.dart';

class VitranMemberOrderRepository {
  final api = NetWorkApiService();

  Future<dynamic> placeOrder(
      VitranMemberOrderData dataModel,
      String productsJson,
      ) async {
    try {
      final uri = Uri.parse(Urls.add_vitran_member_order_url);

      var request = http.MultipartRequest('POST', uri);

      // Parse products to ensure product_unit_id is always present
      List<dynamic> productsList = jsonDecode(productsJson);

      // Ensure each product has a product_unit_id
      List<Map<String, dynamic>> cleanedProducts = productsList.map((product) {
        Map<String, dynamic> cleaned = Map<String, dynamic>.from(product);

        // If product_unit_id is missing or empty, set a default value
        if (!cleaned.containsKey('product_unit_id') ||
            cleaned['product_unit_id'] == null ||
            cleaned['product_unit_id'].toString().isEmpty) {
          cleaned['product_unit_id'] = "1"; // Default unit ID
        }

        return cleaned;
      }).toList();

      request.fields.addAll({
        "vitran_id": dataModel.vitranId ?? "",
        "member_id": dataModel.memberId ?? "",
        "vitran_distribution_center_id":
        dataModel.vitranDistributionCenterId ?? "",
        "order_status": dataModel.orderStatus ?? "ordered",
        "ordered_by": dataModel.orderedBy ?? "",
        "products": jsonEncode(cleanedProducts),
      });

      debugPrint("URL : ${request.url}");
      debugPrint("Fields : ${request.fields}");

      final streamedResponse = await request.send();

      final response =
      await http.Response.fromStream(streamedResponse);

      debugPrint("Response: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }
}