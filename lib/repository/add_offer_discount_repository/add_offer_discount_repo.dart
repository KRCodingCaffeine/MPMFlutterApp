import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/AddOfferDiscountData/AddOfferDiscountData.dart';
import 'package:mpm/utils/urls.dart';

class AddOfferDiscountRepository {
  final api = NetWorkApiService();

  Future<dynamic> submitOfferDiscount(
      AddOfferDiscountData dataModel, File? imageFile) async {
    try {
      final uri = Uri.parse(Urls.add_offer_discount_url);
      var request = http.MultipartRequest('POST', uri);

      _addFormFields(request, dataModel);

      _addMedicinesData(request, dataModel);

      await _addImageFile(request, imageFile);

      _logRequestDetails(request);

      final response = await _sendRequest(request);

      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error submitting offer discount: ${e.toString()}");
      rethrow;
    }
  }

  void _addFormFields(http.MultipartRequest request, AddOfferDiscountData dataModel) {
    request.fields.addAll({
      'member_id': dataModel.memberId?.toString() ?? '',
      'org_subcategory_id': dataModel.orgSubcategoryId?.toString() ?? '',
      'org_details_id': dataModel.orgDetailsID?.toString() ?? '',
      'organisation_offer_discount_id':
      dataModel.organisationOfferDiscountId?.toString() ?? '',
      'created_by': dataModel.memberId?.toString() ?? '',
    });
  }

  void _addMedicinesData(http.MultipartRequest request, AddOfferDiscountData dataModel) {
    request.fields['medicines'] = dataModel.medicines != null && dataModel.medicines!.isNotEmpty
        ? jsonEncode(dataModel.medicines!.map((m) => m.toJson()).toList())
        : '[]';
  }

  Future<void> _addImageFile(http.MultipartRequest request, File? imageFile) async {
    if (imageFile == null) {
      debugPrint('No image file provided');
      return;
    }

    try {
      if (!await imageFile.exists()) {
        debugPrint('Image file does not exist at path: ${imageFile.path}');
        return;
      }

      final fileLength = await imageFile.length();
      if (fileLength <= 0) {
        debugPrint('Image file is empty (0 bytes)');
        return;
      }

      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final fileName = _generateUniqueFilename(imageFile.path);

      var multipartFile = await http.MultipartFile.fromPath(
        'presecrition_image',
        imageFile.path,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );

      request.files.add(multipartFile);
      debugPrint('Added image file: $fileName ($mimeType, ${fileLength} bytes)');
    } catch (e) {
      debugPrint('Error attaching image file: ${e.toString()}');
    }
  }

  String _generateUniqueFilename(String path) {
    final originalName = path.split('/').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'offer_${timestamp}_$originalName';
  }

  void _logRequestDetails(http.MultipartRequest request) {
    debugPrint('--- Request Details ---');
    debugPrint('Endpoint: ${request.url}');
    debugPrint('Fields: ${request.fields}');
    debugPrint('Files: ${request.files.map((f) =>
    "${f.field}: ${f.filename} (${f.contentType?.mimeType})").join(", ")}');
    debugPrint('----------------------');
  }

  Future<http.Response> _sendRequest(http.MultipartRequest request) async {
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      return response;
    } catch (e) {
      debugPrint('Error sending request: ${e.toString()}');
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw HttpException(
        'Request failed with status ${response.statusCode}',
        uri: Uri.parse(Urls.add_offer_discount_url),
      );
    }

    final decoded = jsonDecode(response.body);

    // Additional validation for image URL in response
    if (decoded['status'] == true) {
      final imageUrl = decoded['data']?['image_url'] ??
          decoded['data']?['prescription_image_url'];

      if (imageUrl == null) {
        debugPrint('Warning: Server returned success but no image URL in response');
      } else {
        debugPrint('Image successfully uploaded to: $imageUrl');
      }
    }

    return decoded;
  }
}