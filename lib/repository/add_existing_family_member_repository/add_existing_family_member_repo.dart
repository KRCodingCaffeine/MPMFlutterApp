import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/AddExistingFamilyMember/addExistingFamilyMemberData.dart';
import 'package:mpm/utils/urls.dart';

class AddExistingMemberIntoFamilyRepository {
  final api = NetWorkApiService();

  Future<dynamic> addExistingMember(AddExistingMemberIntoFamilyData dataModel) async {
    try {
      final uri = Uri.parse(Urls.addExistingmemberUrl);

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'relation_id': dataModel.relationId?.toString() ?? '',
          'member_id': dataModel.memberId?.toString() ?? '',
          'current_member_id': dataModel.currentMemberId?.toString() ?? '',
        },
      );

      debugPrint('Request URL: ${uri.toString()}');
      debugPrint('Form Data: relation_id=${dataModel.relationId}, member_id=${dataModel.memberId}, current_member_id=${dataModel.currentMemberId}');
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error adding existing member to family: ${e.toString()}");
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw HttpException(
        'Request failed with status ${response.statusCode}',
        uri: Uri.parse(Urls.addExistingmemberUrl),
      );
    }

    final decoded = response.body;
    return decoded;
  }
}
