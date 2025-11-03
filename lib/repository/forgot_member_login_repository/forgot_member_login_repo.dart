import 'dart:convert';
import 'dart:developer';
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/ForgotMemberLogin/ForgotMemberLoginModelClass.dart';
import 'package:mpm/utils/urls.dart';

class ForgotMemberLoginRepository {
  final _api = NetWorkApiService();

  Future<ForgotMemberLoginModelClass> sendForgotMemberLoginRequest({
    required String fullName,
    required String mobile,
    required String email,
    required String message,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'full_name': fullName,
        'mobile': mobile,
        'email': email,
        'message': message,
      };

      log('Sending forgot member login request: $data');

      final response = await _api.postApi(
        data,
        Urls.forgot_member_login_url,
        "",
        "2",
      );

      log('Forgot member login response: ${jsonEncode(response)}');

      if (response != null) {
        return ForgotMemberLoginModelClass.fromJson(response);
      } else {
        throw Exception('Empty response received from forgot_member_login API');
      }
    } catch (e) {
      log('Error in forgot member login request: $e');
      rethrow;
    }
  }
}
