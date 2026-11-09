import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/AddDoctor/AddDoctorModel.dart';
import 'package:mpm/utils/urls.dart';

class AddDoctorRepository {
  final api = NetWorkApiService();

  Future<AddDoctorModel> addDoctor(AddDoctorRequest request) async {
    try {
      final url = Urls.add_doctor_url;
      final body = request.toJson();

      debugPrint('🔵 Add Doctor API URL: $url');
      debugPrint('📤 Request Body: $body');

      final response = await api.postApi(body, url, '', '1');
      if (response is! Map) {
        throw Exception('Unable to add doctor');
      }

      debugPrint('🟢 Add Doctor Response: $response');
      return AddDoctorModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      debugPrint('❌ Error adding doctor: $e');
      rethrow;
    }
  }
}
