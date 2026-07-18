import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/JobPortal/MemberSaveJob/MemberSaveJobModelClass.dart';
import 'package:mpm/utils/urls.dart';

class MemberSaveJobRepository {
  final api = NetWorkApiService();

  Future<MemberSaveJobModelClass> memberSaveJob(
      Map<String, dynamic> body) async {
    try {
      final response = await api.postApi(
        body.map(
          (key, value) => MapEntry(
            key,
            value?.toString() ?? "",
          ),
        ),
        Urls.member_save_job_url,
        "",
        "2",
      );

      return MemberSaveJobModelClass.fromJson(response);
    } catch (e) {
      // Handle Already Saved (409)
      if (e.toString().contains('"code":409')) {
        return MemberSaveJobModelClass(
          status: false,
          code: 409,
          message: "You have already saved this job.",
        );
      }

      rethrow;
    }
  }
}
