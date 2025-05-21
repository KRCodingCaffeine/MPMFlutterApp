import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/AddOfferDiscountData/AddOfferDiscountData.dart';
import 'package:mpm/utils/urls.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class AddOfferDiscountRepository {
  final api = NetWorkApiService();

  Future<dynamic> submitOfferDiscount(
      AddOfferDiscountData dataModel, File? imageFile) async {
    try {
      final uri = Uri.parse(Urls.add_offer_discount_url);

      var request = http.MultipartRequest('POST', uri);

      // Add all required fields
      request.fields['member_id'] = dataModel.memberId?.toString() ?? '';
      request.fields['org_subcategory_id'] =
          dataModel.orgSubcategoryId?.toString() ?? '';
      request.fields['org_details_id'] =
          dataModel.orgDetailsID?.toString() ?? '';
      request.fields['organisation_offer_discount_id'] =
          dataModel.organisationOfferDiscountId?.toString() ?? '';
      request.fields['created_by'] = dataModel.memberId?.toString() ?? '';

      // Convert medicines list to JSON string
      if (dataModel.medicines != null && dataModel.medicines!.isNotEmpty) {
        final medicinesJson = jsonEncode(dataModel.medicines!
            .map((medicine) => medicine.toJson())
            .toList());
        request.fields['medicines'] = medicinesJson;
      } else {
        request.fields['medicines'] = '[]';
      }

      // Add image if available
      if (imageFile != null && imageFile.existsSync()) {
        final mimeType = lookupMimeType(imageFile.path);
        var fileStream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'prescription_image',
          fileStream,
          length,
          filename: imageFile.path.split('/').last,
          contentType: mimeType != null
              ? MediaType.parse(mimeType)
              : MediaType('image', 'jpeg'),
        );

        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("Submit Offer Discount Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to submit offer discount. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error submitting offer discount: $e");
      rethrow;
    }
  }
}
