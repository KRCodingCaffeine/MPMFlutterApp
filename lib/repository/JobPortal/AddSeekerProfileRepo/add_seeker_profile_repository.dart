import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/AddSeekerProfile/AddSeekerProfileModelClass.dart';
import 'package:mpm/utils/urls.dart';

class AddSeekerProfileRepository {
  final api = NetWorkApiService();

  Future<AddSeekerProfileModelClass> addSeekerProfile(
      Map<String, dynamic> body) async {
    try {
      final response = await api.postApi(
        body.map(
              (key, value) => MapEntry(
            key,
            value?.toString() ?? "",
          ),
        ),
        Urls.add_seeker_profile_url,
        "",
        "2",
      );

      return AddSeekerProfileModelClass.fromJson(response);
    } catch (e) {

      // Handle 409 response manually
      if (e.toString().contains('"code":409')) {
        return AddSeekerProfileModelClass(
          status: false,
          code: 409,
          message: "Seeker profile already exists for this member",
        );
      }

      rethrow;
    }
  }
}