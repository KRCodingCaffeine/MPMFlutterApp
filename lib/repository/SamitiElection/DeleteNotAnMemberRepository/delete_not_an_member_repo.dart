import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/SamitiElection/DeleteNotAnMember/DeleteNotAnMemberModelClass.dart';
import 'package:mpm/utils/urls.dart';

class DeleteNotAnMemberRepository {
  final api = NetWorkApiService();

  Future<DeleteNotAnMemberModelClass> deleteNotAnMember({
    required String electionId,
  }) async {
    try {
      final url = Urls.delete_not_an_member_url;

      debugPrint('========================================');
      debugPrint('Delete Not-An-Member URL: $url');
      debugPrint('Request Fields: {election_id: $electionId}');

      final response = await api.postApi(
        {'election_id': electionId},
        url,
        "2",
        ""
      );

      debugPrint('========================================');
      debugPrint('Parsed Response: $response');

      // ✅ Force-correct status if API returns "success"
      if (response is Map<String, dynamic>) {
        final rawStatus = response['status'];
        if (rawStatus is String &&
            rawStatus.toLowerCase().trim() == 'success') {
          response['status'] = true;   // normalize for model parser
        }
      }

      return DeleteNotAnMemberModelClass.fromJson(response);
    } catch (e) {
      debugPrint('Delete Not-An-Member Repository Error: $e');
      rethrow;
    }
  }
}