import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/ReferredMember/AddReferredMember/AddReferredMemberModelClass.dart';
import 'package:mpm/utils/urls.dart';

class AddReferredMemberRepository {
  final api = NetWorkApiService();

  Future<AddReferredMemberModelClass> addReferredMember(
      Map<String, dynamic> body) async {
    try {
      final url = Urls.add_referred_member_url;

      final safeBody = _convertAllValuesToStrings(body);

      final response = await api.postApi(
        safeBody,
        url,
        "",
        "1",
      );

      return AddReferredMemberModelClass.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> _convertAllValuesToStrings(
      Map<String, dynamic> body) {
    final safeBody = <String, dynamic>{};
    body.forEach((key, value) {
      safeBody[key] = value?.toString() ?? '';
    });
    return safeBody;
  }
}
