import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/model/SattuVitran/UpdateVitranMemberOrder/UpdateVitranMemberOrderData.dart';
import 'package:mpm/utils/urls.dart';

class UpdateVitranMemberOrderRepository {
  Future<dynamic> updateOrder(
      UpdateVitranMemberOrderData dataModel,
      String productsJson,
      ) async {
    try {
      final uri = Uri.parse(Urls.update_vitran_member_order_url);

      var request = http.MultipartRequest("POST", uri);

      // Parse and clean products
      List<dynamic> productsList = jsonDecode(productsJson);

      // Filter out products with quantity 0 or null
      List<Map<String, dynamic>> cleanedProducts = productsList
          .where((product) {
        int qty = product['product_qty'] ?? 0;
        return qty > 0;
      })
          .map((product) {
        Map<String, dynamic> item = Map<String, dynamic>.from(product);

        // Ensure all required fields are present
        if (!item.containsKey('vitran_member_order_product_id') ||
            item['vitran_member_order_product_id'] == null ||
            item['vitran_member_order_product_id'].toString().isEmpty) {
          item['vitran_member_order_product_id'] = "";
        }

        // Ensure product_id is present
        if (!item.containsKey('product_id') || item['product_id'] == null) {
          throw Exception('product_id is required for each product');
        }

        // Ensure product_unit_id is present
        if (!item.containsKey('product_unit_id') ||
            item['product_unit_id'] == null ||
            item['product_unit_id'].toString().isEmpty) {
          item['product_unit_id'] = "1";
        }

        // Ensure product_qty is present and > 0
        if (!item.containsKey('product_qty') ||
            item['product_qty'] == null ||
            (item['product_qty'] as int) <= 0) {
          throw Exception('product_qty must be greater than 0');
        }

        // Ensure product_cost is present
        if (!item.containsKey('product_cost') || item['product_cost'] == null) {
          item['product_cost'] = 0;
        }

        // Ensure product_total_cost is present
        if (!item.containsKey('product_total_cost') ||
            item['product_total_cost'] == null) {
          item['product_total_cost'] = (item['product_cost'] as num) * (item['product_qty'] as num);
        }

        return item;
      }).toList();

      // Build fields
      Map<String, String> fields = {
        "vitran_member_order_id": dataModel.vitranMemberOrderId ?? "",
      };

      // Only add order_status if it's not null
      if (dataModel.orderStatus != null && dataModel.orderStatus!.isNotEmpty) {
        fields["order_status"] = dataModel.orderStatus!;
      }

      // Only add vitran_distribution_center_id if it's not null
      if (dataModel.vitranDistributionCenterId != null &&
          dataModel.vitranDistributionCenterId!.isNotEmpty) {
        fields["vitran_distribution_center_id"] =
        dataModel.vitranDistributionCenterId!;
      }

      // Add products
      fields["products"] = jsonEncode(cleanedProducts);

      request.fields.addAll(fields);

      debugPrint("URL : ${request.url}");
      debugPrint("Fields : ${request.fields}");

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("Response: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }
}