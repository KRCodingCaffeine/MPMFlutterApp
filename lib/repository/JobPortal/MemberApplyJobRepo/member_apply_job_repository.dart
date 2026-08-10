import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/MemberApplyJob/MemberApplyJobModelClass.dart';
import 'package:mpm/utils/urls.dart';

class MemberApplyJobRepository {
  final api = NetWorkApiService();

  Future<MemberApplyJobModelClass> memberApplyJob(
      Map<String, dynamic> body) async {
    try {
      final response = await api.postApi(
        body.map(
              (key, value) => MapEntry(
            key,
            value?.toString() ?? "",
          ),
        ),
        Urls.member_apply_job_url,
        "",
        "2",
      );

      return MemberApplyJobModelClass.fromJson(response);
    } catch (e) {
      // Handle Already Applied (409)
      if (e.toString().contains('"code":409')) {
        return MemberApplyJobModelClass(
          status: false,
          code: 409,
          message: "You have already applied for this job.",
        );
      }

      rethrow;
    }
  }
}