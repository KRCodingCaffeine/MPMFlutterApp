import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/GetMemberSurname/GetMemberSurnameModelClass.dart';
import 'package:mpm/utils/urls.dart';

class MemberSurnameRepository {
  final NetWorkApiService _api = NetWorkApiService();

  Future<MemberSurnameModelClass> fetchMemberSurnameList() async {
    try {
      final response = await _api.getApi(Urls.member_surname_url, "");
      debugPrint("Member Surname API Response: $response");
      return MemberSurnameModelClass.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
